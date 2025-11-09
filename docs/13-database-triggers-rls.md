# Lesson 13: Database Triggers and RLS Integration

**Category:** 🔴 Critical (Database)
**Last Updated:** 2025-10-19 (Session Part 10 - Banking INSERT-SELECT Fix)
**Sessions:** 2025-10-19 Part 10 (Bank Duplicate Rows & RLS)

---

## The Problem

**Context:** BankingService.getOrCreateAccount was failing with INSERT-SELECT pattern:

- INSERT operation succeeded (113ms)
- SELECT operation returned null
- Error: "Failed to create bank account - no data returned"

**Root Cause:** Passing `owner_user_id` explicitly in INSERT payload when a BEFORE INSERT trigger auto-populates this field.

---

## What Happened

### The Code

**Before (WRONG):**

```typescript
const created = await supabase
  .from('bank_accounts')
  .insert({
    character_id: characterId,
    owner_user_id: userId, // ❌ Explicit value
    balance: 0,
  })
  .select('*')
  .single();
```

**After (CORRECT):**

```typescript
const created = await supabase
  .from('bank_accounts')
  .insert({
    character_id: characterId,
    // owner_user_id is set by trigger
    balance: 0,
  })
  .select('*')
  .single();
```

### The Trigger

From `supabase/migrations/20251014_rls_owner_fastpath.sql`:

```sql
CREATE TRIGGER trg_bank_accounts_owner
BEFORE INSERT OR UPDATE ON public.bank_accounts
FOR EACH ROW
EXECUTE FUNCTION public.sync_character_owned_row();
```

The trigger function:

```sql
CREATE OR REPLACE FUNCTION public.sync_character_owned_row()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  owner_id uuid;
BEGIN
  -- Look up owner from character_instances
  SELECT user_id INTO owner_id
  FROM public.character_instances
  WHERE id = NEW.character_id;

  IF owner_id IS NULL THEN
    RAISE EXCEPTION 'Character % does not exist', NEW.character_id
      USING ERRCODE = 'foreign_key_violation';
  END IF;

  NEW.owner_user_id := owner_id;  -- Auto-populate
  RETURN NEW;
END;
$$;
```

### Why It Failed

1. **Code passed** `owner_user_id = userId` (authenticated user's ID)
2. **Trigger ran** BEFORE INSERT and looked up owner from `character_instances`
3. **Trigger overwrote** `owner_user_id` with value from lookup
4. **INSERT succeeded** with trigger-set value
5. **RLS policy checked** `WHERE owner_user_id = auth.uid()`
6. **SELECT failed** because the row's `owner_user_id` might not match `auth.uid()` in all cases

---

## The Fix

**Remove explicit `owner_user_id` from INSERT payload and let trigger set it.**

### Why This Works

- Trigger is `SECURITY DEFINER` - runs with elevated privileges
- Trigger enforces data integrity (owner must exist in `character_instances`)
- RLS policies check the trigger-set value, ensuring consistency
- No mismatch between what we pass and what the trigger sets

---

## The Lesson

### ✅ DO

1. **Check for BEFORE INSERT/UPDATE triggers** before writing INSERT/UPDATE code
2. **Read the migration files** - they document trigger behavior
3. **Let triggers handle auto-populated fields** - don't pass them explicitly
4. **Trust the trigger** - it's designed to enforce data integrity

### ❌ DON'T

1. **Don't pass values** for fields that triggers auto-populate
2. **Don't assume** you need to pass all NOT NULL columns
3. **Don't fight the trigger** - it will overwrite your values anyway
4. **Don't skip reading migrations** - they ARE documentation

---

## How to Identify Trigger-Managed Fields

### 1. Check Migration Files

```bash
# Search for triggers on the table
grep -r "CREATE TRIGGER.*table_name" supabase/migrations/
```

### 2. Check Trigger Functions

```bash
# Find what fields the trigger modifies
grep -A 20 "NEW\." supabase/migrations/20251014_rls_owner_fastpath.sql
```

### 3. Look for BEFORE INSERT Triggers

```sql
-- These run BEFORE the row is inserted
CREATE TRIGGER trigger_name
BEFORE INSERT OR UPDATE
```

### 4. Check Function Body

```sql
-- Look for field assignments
NEW.owner_user_id := owner_id;  -- This field is auto-populated!
```

---

## Common Trigger Patterns in This Project

### Pattern 1: Owner Denormalization

**Purpose:** Optimize RLS policy checks by caching `user_id` from `character_instances`

**Trigger:** `sync_character_owned_row()`

**Tables:**

- `bank_accounts`
- `inventory`
- `minions`
- `trading_cards`

**Fields Auto-Populated:**

- `owner_user_id`

**Migration:** `20251014_rls_owner_fastpath.sql`

### Pattern 2: Bank Transaction Owners

**Purpose:** Track both sender and receiver owners for bank transfers

**Trigger:** `sync_bank_transaction_owners()`

**Tables:**

- `bank_transactions`

**Fields Auto-Populated:**

- `from_owner_user_id`
- `to_owner_user_id`

**Migration:** `20251014_rls_owner_fastpath.sql`

---

## Integration with RLS Policies

### Why Triggers + RLS Work Together

**Triggers:**

- Run BEFORE INSERT/UPDATE (before RLS checks WITH CHECK)
- Set `owner_user_id` from authoritative source (`character_instances`)
- Enforce referential integrity

**RLS Policies:**

- Check `owner_user_id = auth.uid()` for row visibility
- Use the trigger-set value for consistency
- Prevent unauthorized access

### The Two-Policy Pattern

From `20251014_rls_owner_fastpath.sql`:

```sql
-- Generic policy for INSERT/UPDATE/DELETE
CREATE POLICY "Users can manage bank accounts for their own characters"
  ON public.bank_accounts
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- SELECT-specific policy
CREATE POLICY "Users can view own bank accounts"
  ON public.bank_accounts
  FOR SELECT
  USING (owner_user_id = auth.uid());
```

**Why this pattern works:**

1. Trigger sets `owner_user_id` BEFORE INSERT
2. WITH CHECK policy verifies `owner_user_id = auth.uid()`
3. INSERT succeeds if user owns the character
4. SELECT policy uses same check for visibility

---

## Testing with Triggers

### Mock Behavior in Tests

Triggers don't run in unit tests (no actual database). Your tests should:

1. **Not pass trigger-managed fields** in INSERT payloads
2. **Assume trigger sets the field correctly**
3. **Mock the result** with the field populated

**Example:**

```typescript
// ✅ Correct - don't pass owner_user_id in INSERT
const insertMock = vi.fn().mockReturnValue({
  select: vi.fn().mockReturnValue({
    single: vi.fn().mockResolvedValue({
      data: {
        id: 'account-1',
        character_id: 'char-1',
        owner_user_id: 'user-1', // Mock includes it
        balance: 0,
      },
      error: null,
    }),
  }),
});

// ❌ Wrong - passing owner_user_id in INSERT
await supabase.from('bank_accounts').insert({
  character_id: 'char-1',
  owner_user_id: 'user-1', // Don't do this!
  balance: 0,
});
```

---

## Debugging Trigger Issues

### Symptom: INSERT succeeds but SELECT returns null

**Cause:** Trigger is setting a field value that doesn't match RLS policy

**Debug Steps:**

1. Check trigger function - what does it set?
2. Check RLS policies - what do they check?
3. Verify `auth.uid()` matches the trigger-set value
4. Remove explicit field from INSERT payload

### Symptom: INSERT fails with foreign key violation

**Cause:** Trigger validates referential integrity and the referenced row doesn't exist

**Debug Steps:**

1. Check trigger RAISE EXCEPTION messages
2. Verify the referenced record exists (e.g., character_id in character_instances)
3. Check the lookup query in trigger function

### Symptom: INSERT is slow (> 100ms)

**Cause:** Trigger is doing expensive lookups or doesn't have proper indexes

**Debug Steps:**

1. Check if trigger does JOINs or subqueries
2. Verify indexes exist on lookup columns
3. Review `20251014_rls_owner_fastpath.sql` for index creation

---

## Related Lessons

- [Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md) - Migration files document patterns
- [Lesson 15: Evidence-Based Database Work](15-evidence-based-database-work.md) - Check state before changes
- [09-ai-execution-protocol.md](09-ai-execution-protocol.md) - Read docs BEFORE coding

---

## Quick Reference

**Before writing INSERT/UPDATE code:**

```bash
# 1. Check for triggers
grep -r "CREATE TRIGGER.*your_table" supabase/migrations/

# 2. Read trigger function
grep -A 30 "CREATE.*FUNCTION.*trigger_name" supabase/migrations/

# 3. Identify auto-populated fields
grep "NEW\." supabase/migrations/trigger_file.sql
```

**Don't pass these fields in INSERT:**

- `owner_user_id` (set by `sync_character_owned_row()`)
- `from_owner_user_id` (set by `sync_bank_transaction_owners()`)
- `to_owner_user_id` (set by `sync_bank_transaction_owners()`)

---

## Summary

**BEFORE INSERT triggers auto-populate fields. Don't pass them explicitly.**

**The Protocol:**

1. Check migration files for triggers on the table
2. Read trigger function to see what fields it sets
3. Omit those fields from INSERT payload
4. Trust the trigger to set them correctly
5. RLS policies will check the trigger-set values

**Why this matters:**

- Prevents INSERT-SELECT pattern failures
- Ensures data integrity
- Avoids fighting the database design
- Respects established patterns

---

**Session Reference:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)
