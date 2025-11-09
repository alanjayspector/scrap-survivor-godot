# Lesson 14: Established Patterns Are Documentation

**Category:** 🔴 Critical (Code Patterns)
**Last Updated:** 2025-10-19 (Session Part 10 - RLS Policy Investigation)
**Sessions:** 2025-10-19 Part 10 (Bank Duplicate Rows & RLS)

---

## The Problem

**Context:** Created migration `20251024_fix_bank_accounts_rls.sql` with 4 separate per-operation RLS policies (SELECT, INSERT, UPDATE, DELETE).

**Result:** All database queries timed out (6000ms).

**User Feedback:**

> "everything in supabase/ is as much code and documentation as anything else is in this project"

---

## What Happened

### The Wrong Approach

Created new RLS policies without checking existing patterns:

```sql
-- ❌ WRONG - 4 separate policies (violated established pattern)
CREATE POLICY "bank_accounts_select_own"
  ON public.bank_accounts
  FOR SELECT
  USING (owner_user_id = auth.uid());

CREATE POLICY "bank_accounts_insert_own"
  ON public.bank_accounts
  FOR INSERT
  WITH CHECK (owner_user_id = auth.uid());

CREATE POLICY "bank_accounts_update_own"
  ON public.bank_accounts
  FOR UPDATE
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

CREATE POLICY "bank_accounts_delete_own"
  ON public.bank_accounts
  FOR DELETE
  USING (owner_user_id = auth.uid());
```

### The Established Pattern

From `supabase/migrations/20251014_rls_owner_fastpath.sql`:

```sql
-- ✅ CORRECT - 2 policies (the established pattern)

-- 1. Generic policy (no FOR clause = INSERT/UPDATE/DELETE)
CREATE POLICY "Users can manage bank accounts for their own characters"
  ON public.bank_accounts
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- 2. SELECT-specific policy
CREATE POLICY "Users can view own bank accounts"
  ON public.bank_accounts
  FOR SELECT
  USING (owner_user_id = auth.uid());
```

**This pattern is used across ALL tables:**

- `bank_accounts`
- `inventory`
- `minions`
- `trading_cards`
- `bank_transactions`

---

## The Lesson

### Code IS Documentation

**Migration files document:**

- Established patterns that work
- Battle-tested solutions
- Design decisions
- Table structures
- Trigger behavior
- Index strategies

**Existing code documents:**

- API patterns
- Error handling strategies
- Service layer conventions
- Testing patterns

### Why Checking Patterns Matters

**Benefits:**

1. **Avoid reinventing** - Patterns exist for a reason
2. **Prevent regressions** - Deviating breaks things
3. **Maintain consistency** - Same pattern across codebase
4. **Save time** - Don't debug already-solved problems

**Costs of NOT checking:**

1. Query timeouts (production impact)
2. Wasted time debugging
3. Revert migrations needed
4. User frustration

---

## How to Find Established Patterns

### 1. Search Migration Files

```bash
# Find all RLS policies
grep -r "CREATE POLICY" supabase/migrations/*.sql

# Find all triggers
grep -r "CREATE TRIGGER" supabase/migrations/*.sql

# Find patterns for specific table
grep -B 5 -A 10 "table_name" supabase/migrations/*.sql
```

### 2. Check Similar Tables

```bash
# If working on bank_accounts, check inventory (similar pattern)
grep -A 10 "inventory" supabase/migrations/20251014_rls_owner_fastpath.sql
```

### 3. Look for Pattern Comments

```sql
-- Migration comments often explain patterns
-- Example from 20251014:
-- "7. Replace RLS policies to use direct owner comparisons"
```

### 4. Find the Source of Truth

**Key migrations that establish patterns:**

- `20251014_rls_owner_fastpath.sql` - RLS policy patterns
- `supabase/schema.sql` - Current database state
- Earlier migrations - Original designs

---

## Common Patterns in This Project

### Pattern 1: Two-Policy RLS

**When:** Character-scoped tables with `owner_user_id`

**Pattern:**

```sql
-- Generic policy (INSERT/UPDATE/DELETE)
CREATE POLICY "Users can manage X for their own characters"
  ON public.table_name
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- SELECT-specific policy
CREATE POLICY "Users can view own X"
  ON public.table_name
  FOR SELECT
  USING (owner_user_id = auth.uid());
```

**Used in:** 5+ tables

**Source:** `20251014_rls_owner_fastpath.sql`

### Pattern 2: BEFORE INSERT Triggers

**When:** Tables need denormalized owner for RLS performance

**Pattern:**

```sql
CREATE TRIGGER trg_table_owner
BEFORE INSERT OR UPDATE ON public.table_name
FOR EACH ROW
EXECUTE FUNCTION public.sync_character_owned_row();
```

**Used in:** 4+ tables

**Source:** `20251014_rls_owner_fastpath.sql`

### Pattern 3: Commit Messages

**When:** Every commit

**Pattern:**

```bash
git commit -m "$(cat <<'EOF'
type(scope): lowercase imperative subject

Optional body explaining why.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Source:** `docs/development-guide/commit-guidelines.md`

### Pattern 4: Service Layer Error Handling

**When:** All service methods

**Pattern:**

```typescript
try {
  const result = await operation();
  logger.info('Operation succeeded', { context });
  return result;
} catch (error) {
  logger.error('Operation failed', { context, error });
  throw error; // Re-throw for caller
}
```

**Used in:** 10+ services

**Source:** Existing service files

---

## When to Deviate from Patterns

### ✅ OK to Deviate If:

1. **Pattern doesn't fit** - New use case not covered by pattern
2. **User approves** - Explicit permission to try new approach
3. **Document reasoning** - Add comment explaining why
4. **Plan for migration** - If pattern needs updating, plan it properly

### ❌ Don't Deviate If:

1. **You haven't checked** - Didn't look for existing patterns
2. **Seems easier** - Shortcuts often break things
3. **Different project experience** - This project has its own conventions
4. **Time pressure** - Rushing leads to regressions

---

## The Protocol (Mandatory)

### Before Implementing Anything:

**1. Check Documentation**

```bash
# Check docs folder
ls docs/development-guide/
# Read relevant guide
cat docs/development-guide/coding-standards.md
```

**2. Search Existing Code**

```bash
# Find similar implementations
grep -r "pattern keyword" src/
# Find similar migrations
grep -r "table name" supabase/migrations/
```

**3. Identify the Pattern**

```bash
# Look for repeated structure
# Count occurrences to verify it's a pattern
grep -c "pattern" relevant_files
```

**4. Follow the Pattern**

```typescript
// Copy pattern from existing code
// Adapt to your specific use case
// Keep same structure
```

**5. Document Deviations**

```typescript
// If you MUST deviate, explain why
/**
 * NOTE: This deviates from standard pattern because:
 * - Reason 1
 * - Reason 2
 * - Approved by user on 2025-10-19
 */
```

---

## Real Example from Session 10

### What I Did Wrong

1. **Didn't check migrations** - Created RLS policies without looking at existing ones
2. **Assumed approach** - Thought per-operation policies made sense
3. **Ignored established pattern** - 20251014 already defined the pattern
4. **Caused production issue** - Query timeouts affected testing

### What I Should Have Done

```bash
# 1. Check existing RLS policies
grep -r "POLICY.*bank_accounts" supabase/migrations/

# Output would show:
# 20251014_rls_owner_fastpath.sql:CREATE POLICY "Users can manage bank accounts"
# 20251014_rls_owner_fastpath.sql:CREATE POLICY "Users can view own bank accounts"

# 2. Read the migration
cat supabase/migrations/20251014_rls_owner_fastpath.sql

# 3. See the pattern (2 policies, not 4)

# 4. Copy the pattern for any fixes needed
```

### The Fix

Created `20251025_revert_bank_rls_to_working_pattern.sql` to restore established pattern.

**Lesson:** Could have avoided entire issue by checking patterns first.

---

## Documentation Locations

### Primary Documentation

**Development Guides:**

- `docs/development-guide/coding-standards.md`
- `docs/development-guide/commit-guidelines.md`
- `docs/development-guide/testing-strategy.md`

**Database Patterns:**

- `supabase/migrations/20251014_rls_owner_fastpath.sql` - RLS and trigger patterns
- `supabase/schema.sql` - Current state
- `supabase/migrations/*.sql` - Historical context

**Code Patterns:**

- `src/services/` - Service layer patterns
- `src/components/ui/` - Component patterns
- `src/utils/` - Utility patterns

### Secondary Documentation

**Lessons Learned:**

- `docs/lessons-learned/*.md` - Common mistakes and solutions

**Session Logs:**

- `docs/archive/session-handoffs/*.md` - Historical decisions

---

## Self-Check Questions

Before implementing anything new, ask:

1. **Has this been done before in this project?**
   - If yes → Find it and copy the pattern
   - If no → Check if similar pattern exists

2. **What files document this area?**
   - Database → migrations, schema.sql
   - Code → similar service/component files
   - Process → docs/development-guide/

3. **What pattern do they follow?**
   - How many times repeated?
   - Any variations?
   - Comments explaining why?

4. **Am I following the pattern?**
   - Same structure?
   - Same naming?
   - Same conventions?

5. **If deviating, why?**
   - Can I explain to user?
   - Is it worth the risk?
   - Have I documented it?

---

## Summary

**Everything in the repository IS documentation.**

**The Protocol:**

1. **Before implementing** - Search for existing patterns
2. **Check multiple sources** - Migrations, code, docs
3. **Identify the pattern** - Look for repetition
4. **Follow the pattern** - Copy structure exactly
5. **Document deviations** - If you must deviate, explain why

**Why this matters:**

- Patterns exist for a reason (usually learned from mistakes)
- Deviating breaks consistency and often breaks functionality
- Checking patterns is faster than debugging regressions
- Respect previous work - don't reinvent solved problems

**User's expectation:**

> "everything in supabase/ is as much code and documentation as anything else is in this project"

This applies to ALL folders:

- `supabase/` - Database patterns
- `src/` - Code patterns
- `docs/` - Process patterns
- `.husky/` - Git hook patterns

**Treat ALL code as documentation.**

---

## Related Lessons

- [Lesson 13: Database Triggers and RLS Integration](13-database-triggers-rls.md) - Trigger patterns
- [Lesson 09: AI Execution Protocol](09-ai-execution-protocol.md) - Read docs BEFORE coding
- [Lesson 01: Git Operations](01-git-operations.md) - Commit message patterns

---

**Session Reference:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)
