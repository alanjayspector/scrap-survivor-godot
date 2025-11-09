# Lesson 18: Follow Established Query Patterns

**Date:** 2025-10-19 (Session Part 10 - Banking Sprint)
**Category:** 🔴 Critical (RLS + Query Patterns)
**Session:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](../09-archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)

---

## What Happened

BankingService had redundant `.eq('owner_user_id', userId)` filtering that conflicted with RLS policies, causing INSERT-SELECT pattern failures.

**User Quote:**

> "make sure you confirm how Workshop, Barracks, and Shop are using the supabase client... this is a call back to lessons learned about looking at existing patterns in code..."

**User Feedback:**

> "you ignored it all and yet again wrote a bunch of code before understanding our tried and tested patterns"

**Impact:** 3-day debugging session for what should have been a 1-day task.

---

## Root Cause

1. Wrote BankingService queries without checking how other services query Supabase
2. Added redundant `.eq('owner_user_id', userId)` filtering
3. Didn't realize RLS policies already handle owner filtering automatically
4. Created double-filtering that conflicts with RLS INSERT-SELECT pattern

**Result:**

- INSERT succeeds (RLS allows, trigger sets owner_user_id)
- SELECT returns null (double-filter mismatch)
- "Failed to create bank account - no data returned" error
- 8 duplicate rows created in database

---

## The Established Pattern

### ✅ CORRECT: HybridCharacterService (Parent Table Query)

```typescript
// src/services/HybridCharacterService.ts:700
const result = await supabase.from('character_instances').select('*').eq('user_id', userId); // ✅ Correct - parent table uses user_id, NOT owner_user_id
```

**Why this works:**

- `character_instances` table uses `user_id` column (not `owner_user_id`)
- RLS policies filter by `user_id` automatically
- No redundant filtering needed

### ✅ CORRECT: Workshop/Shop/Barracks Pattern

```typescript
// These services DON'T query child tables directly
// They use HybridCharacterService + localStorage
// NO direct Supabase queries for character-owned data
```

**Why this works:**

- Delegates to HybridCharacterService for character data
- Avoids RLS complexity in business logic
- Single source of truth for character queries

### ❌ WRONG: BankingService (Before Fix)

```typescript
// src/services/BankingService.ts:128-130 (OLD - WRONG)
const existing = await supabase
  .from('bank_accounts')
  .select('*')
  .eq('character_id', characterId)
  .eq('owner_user_id', userId) // ❌ REDUNDANT - RLS already filters this
  .order('created_at', { ascending: false })
  .limit(1);
```

**Why this fails:**

- `bank_accounts` has RLS policies that filter by `owner_user_id` automatically
- Application code ALSO filters by `.eq('owner_user_id', userId)` - DOUBLE FILTERING
- INSERT succeeds (trigger sets owner_user_id from character_instances)
- SELECT fails (double-filter mismatch between trigger value and explicit filter)

### ✅ CORRECT: BankingService (After Fix)

```typescript
// src/services/BankingService.ts:128-130 (NEW - CORRECT)
const existing = await supabase
  .from('bank_accounts')
  .select('*')
  .eq('character_id', characterId)
  // Removed: .eq('owner_user_id', userId) - RLS handles this
  .order('created_at', { ascending: false })
  .limit(1);
```

**Why this works:**

- RLS policy filters by `owner_user_id` automatically (using JWT auth context)
- Trigger sets `owner_user_id` from `character_instances.user_id`
- No double-filtering conflict
- INSERT-SELECT pattern works correctly

---

## The Exception: Cross-Character Queries

```typescript
// src/services/BankingService.ts:258 (CORRECT - KEPT AS-IS)
async getPlayerTotalBalance(userId: string): Promise<number> {
  const result = await supabase
    .from('bank_accounts')
    .select('balance')
    .eq('owner_user_id', userId);  // ✅ CORRECT - queries across ALL user's characters
}
```

**Why `.eq('owner_user_id')` is correct here:**

- This query needs to sum balances across **all characters owned by the user**
- NOT querying for a specific character
- RLS still filters by owner, but we need to explicitly say "all my characters"

---

## How to Check Patterns BEFORE Writing Code

### 1. Search for Similar Queries

```bash
# Find how other services query character-owned tables
grep -r "\.from('.*')" src/services/*.ts | grep -v test
grep -r "owner_user_id" src/services/*.ts | grep -v test
grep -r "user_id" src/services/*.ts | grep -v test
```

### 2. Check RLS Policies

```bash
# Find RLS policy migrations for the table
find supabase/migrations -name "*.sql" -exec grep -l "bank_accounts.*POLICY" {} \;

# Read the policy definitions
cat supabase/migrations/20251025_revert_bank_rls_to_working_pattern.sql
```

### 3. Check for Triggers

```bash
# Find triggers that auto-populate fields
find supabase/migrations -name "*.sql" -exec grep -l "TRIGGER.*bank_accounts" {} \;

# Read the trigger definition
cat supabase/migrations/20251014_rls_owner_fastpath.sql
```

### 4. Compare Your Code to Existing Patterns

**Before:**

```typescript
// Your new code
supabase.from('my_table').select('*').eq('owner_user_id', userId);
```

**Check:**

```typescript
// How does HybridCharacterService do it?
supabase.from('character_instances').select('*').eq('user_id', userId);
// ↑ Uses user_id, NOT owner_user_id

// How do Workshop/Shop do it?
// They DON'T query directly - they use HybridCharacterService
```

**Adjust:**

```typescript
// Fixed code (let RLS handle filtering)
supabase.from('my_table').select('*').eq('character_id', characterId);
// No owner_user_id needed - RLS filters automatically
```

---

## RLS + Query Pattern Rules

### Rule 1: Don't Double-Filter What RLS Already Filters

```typescript
// ❌ WRONG: Double-filtering
supabase
  .from('bank_accounts')
  .select('*')
  .eq('character_id', characterId)
  .eq('owner_user_id', userId); // ← RLS already does this!

// ✅ CORRECT: Let RLS handle owner filtering
supabase.from('bank_accounts').select('*').eq('character_id', characterId);
```

### Rule 2: Check if Triggers Auto-Populate Fields

```typescript
// ❌ WRONG: Passing field that trigger sets
await supabase.from('bank_accounts').insert({
  character_id: characterId,
  balance: 0,
  owner_user_id: userId, // ← Trigger sets this automatically!
});

// ✅ CORRECT: Let trigger set it
await supabase.from('bank_accounts').insert({
  character_id: characterId,
  balance: 0,
  // owner_user_id omitted - trigger handles it
});
```

### Rule 3: Only Use Explicit Filtering for Cross-Entity Queries

```typescript
// ✅ CORRECT: Cross-character query
async getPlayerTotalBalance(userId: string) {
  return supabase
    .from('bank_accounts')
    .select('balance')
    .eq('owner_user_id', userId);  // ✅ Correct - summing across ALL characters
}

// ✅ CORRECT: Single-character query
async getAccount(characterId: string) {
  return supabase
    .from('bank_accounts')
    .select('*')
    .eq('character_id', characterId);  // ✅ Correct - RLS filters by owner
}
```

---

## Checklist: Before Writing Character-Owned Queries

- [ ] Search for similar queries in existing services
- [ ] Check RLS policies for the table (look in migrations/)
- [ ] Check for BEFORE INSERT/UPDATE triggers
- [ ] Determine if query is single-character or cross-character
- [ ] If single-character: Let RLS handle owner filtering (no `.eq('owner_user_id')`)
- [ ] If cross-character: Use explicit `.eq('owner_user_id')` to query all owned records
- [ ] Verify trigger doesn't auto-populate fields you're passing in INSERT
- [ ] Test with actual auth context (not just unit tests)

---

## Related Lessons

- **[Lesson 13: Database Triggers and RLS Integration](13-database-triggers-rls.md)** - How triggers work with RLS
- **[Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md)** - Migration files document patterns
- **[Lesson 15: Evidence-Based Database Work](15-evidence-based-database-work.md)** - Gather evidence before changes

---

## Red Flags (Check Pattern Before Proceeding)

🚩 About to add `.eq('owner_user_id', userId)` to a query
🚩 About to pass `owner_user_id` in an INSERT
🚩 Writing first query for a new character-owned table
🚩 INSERT-SELECT pattern returning null unexpectedly
🚩 Getting "multiple rows returned" for single-character query

**If you see a red flag → Check existing patterns FIRST**

---

## Time Cost Breakdown

**If Pattern Checked First:** ~2 hours

- 30 min: Search existing queries
- 30 min: Review RLS policies and triggers
- 30 min: Write code following pattern
- 30 min: Test and verify

**If Pattern Ignored:** ~3 days (what actually happened)

- Day 1: Write code wrong, tests pass (mocked), deploy breaks
- Day 2: Debug INSERT-SELECT failures, try wrong fixes
- Day 3: User shows duplicates, finally check patterns, fix correctly

**Time Saved by Following This Lesson:** 2.9 days

---

**Remember:** RLS policies and triggers are invisible to application code. Check migrations BEFORE writing queries.
