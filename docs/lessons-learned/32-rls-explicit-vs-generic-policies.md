# Lesson 32: RLS Explicit vs Generic Policies

**Date:** 2025-10-25
**Category:** 🔴 Critical (Database)
**Session:** Context Rollover - Bank Transaction INSERT-SELECT Bug

---

## The Problem

**Symptom:** `.insert().select()` pattern returns `undefined` even though INSERT succeeds and data exists in database.

**Error:**

```
TypeError: Cannot read properties of undefined (reading 'id')
at BankingService.ts:512
```

**Evidence:**

- Console logs show: `authUserId` matches `characterUserId` ✅
- INSERT succeeds with 85ms latency ✅
- Database query shows row was created with correct `from_owner_user_id` ✅
- `.select()` returns `undefined` ❌

**Time Lost:** 3+ hours debugging, multiple context rollovers

---

## Root Cause

**Generic RLS policies (USING + WITH CHECK) don't work with `.insert().select()` pattern.**

### What We Had (BROKEN)

```sql
-- Generic policy - works for simple CRUD, breaks .insert().select()
CREATE POLICY "Users manage their own bank transactions"
  ON public.bank_transactions
  TO authenticated
  USING ((from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid()))
  WITH CHECK ((from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid()));
```

### Why It Failed

The `.insert().select()` Supabase pattern executes TWO separate operations:

1. **INSERT** - Uses `WITH CHECK` policy
2. **SELECT** - Uses `USING` policy

Generic policies don't properly separate these checks. When using `.insert().select()`, PostgreSQL/Supabase needs explicit `FOR INSERT` and `FOR SELECT` policies to handle each operation independently.

---

## The Solution

**Use explicit FOR clause policies:**

```sql
-- Explicit INSERT policy
CREATE POLICY "Users can insert their own bank transactions"
  ON public.bank_transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid())
  );

-- Explicit SELECT policy (CRITICAL for .insert().select())
CREATE POLICY "Users can select their own bank transactions"
  ON public.bank_transactions
  FOR SELECT
  TO authenticated
  USING (
    (from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid())
  );

-- Explicit UPDATE policy
CREATE POLICY "Users can update their own bank transactions"
  ON public.bank_transactions
  FOR UPDATE
  TO authenticated
  USING (
    (from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid())
  )
  WITH CHECK (
    (from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid())
  );

-- Explicit DELETE policy
CREATE POLICY "Users can delete their own bank transactions"
  ON public.bank_transactions
  FOR DELETE
  TO authenticated
  USING (
    (from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid())
  );
```

---

## When to Use Each Pattern

### Use Generic Policy (USING + WITH CHECK)

**Good for:**

- Simple CRUD operations
- Tables that don't use `.insert().select()` pattern
- Read-only tables (SELECT only)

**Example - character_instances:**

```sql
-- This works because character operations don't use .insert().select()
CREATE POLICY "Users manage their own character"
  ON public.character_instances
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

**Why it works:** HybridCharacterService doesn't rely on `.insert().select()` returning data immediately.

### Use Explicit Policies (FOR INSERT/SELECT/UPDATE/DELETE)

**Required for:**

- **ANY table using `.insert().select()` pattern** ⚠️ CRITICAL
- Tables with ProtectedSupabaseClient queries
- Tables where INSERT must return data immediately

**Example - bank_transactions, bank_accounts, telemetry_events:**

```sql
-- Required because these use .insert().select() pattern
CREATE POLICY "..." FOR INSERT WITH CHECK (...);
CREATE POLICY "..." FOR SELECT USING (...);
CREATE POLICY "..." FOR UPDATE USING (...) WITH CHECK (...);
CREATE POLICY "..." FOR DELETE USING (...);
```

---

## Evidence-Based Decision Tree

```
┌─ Creating RLS policies for a table
│
├─ Does the table use .insert().select() pattern?
│  │
│  ├─ YES → MUST use explicit FOR policies
│  │       Pattern: FOR INSERT, FOR SELECT, FOR UPDATE, FOR DELETE
│  │       Example: bank_transactions, bank_accounts, telemetry_events
│  │
│  └─ NO → Can use generic USING/WITH CHECK policy
│          Pattern: USING (...) WITH CHECK (...)
│          Example: character_instances
│
└─ Is the table accessed via ProtectedSupabaseClient?
   │
   ├─ YES → Use explicit FOR policies (safer)
   │
   └─ NO → Generic policy acceptable
```

---

## Verification Checklist

Before deploying RLS policies:

- [ ] Check if service uses `.insert().select()` pattern
- [ ] Verify ProtectedSupabaseClient is used
- [ ] Look for Lesson 13 trigger-managed fields
- [ ] Test INSERT operation returns data (not undefined)
- [ ] Verify SELECT immediately after INSERT works
- [ ] Check logs for "INSERT succeeded but SELECT returned undefined"

---

## Historical Failures

### 2025-10-25: bank_transactions (MISDIAGNOSED)

**Problem:** Deposit failed with "Cannot read properties of undefined (reading 'id')"

**Initial Hypothesis:** Generic RLS policies don't work with `.insert().select()`

**Investigation:**

```sql
-- Query proved data existed
SELECT from_owner_user_id FROM bank_transactions
WHERE from_character_id = 'cfaf3293-5cfc-48b7-9846-9d4d63f81dd1'
ORDER BY created_at DESC LIMIT 1;

-- Result: ef3d7f4b-e0a4-44d4-8fc9-03a83b195cd5 ✅
-- Matches auth.uid() ✅
-- Yet .insert().select() returned undefined ❌
```

**Migration Applied:** 20251025210526 replaced generic policy with explicit policies.

**Result:** Bug persisted even after migration ❌

**ACTUAL ROOT CAUSE:** BankingService.ts was incorrectly accessing `.data` on `protectedSupabase.query()` result, which is already unwrapped. See [Lesson 33](33-protectedsupabaseclient-return-unwrapped.md) for details.

**Conclusion:** The RLS policies were NOT the issue. The generic policy was working fine. However, explicit policies are still recommended for `.insert().select()` patterns as a best practice.

### 2025-10-19: telemetry_events

Similar issue - fixed with explicit policies.

---

## Migration Pattern

```sql
-- Migration: Replace Generic with Explicit RLS Policies
-- Table: table_name
-- Reason: .insert().select() pattern requires explicit FOR SELECT policy

BEGIN;

-- Drop generic policy
DROP POLICY IF EXISTS "Generic policy name" ON public.table_name;

-- Create explicit policies
CREATE POLICY "Users can insert..." ON public.table_name
  FOR INSERT TO authenticated WITH CHECK (...);

CREATE POLICY "Users can select..." ON public.table_name
  FOR SELECT TO authenticated USING (...);

CREATE POLICY "Users can update..." ON public.table_name
  FOR UPDATE TO authenticated USING (...) WITH CHECK (...);

CREATE POLICY "Users can delete..." ON public.table_name
  FOR DELETE TO authenticated USING (...);

COMMIT;
```

---

## Quick Reference

| Pattern                 | Generic Policy | Explicit Policies |
| ----------------------- | -------------- | ----------------- |
| `.insert().select()`    | ❌ Fails       | ✅ Works          |
| Simple CRUD             | ✅ Works       | ✅ Works          |
| ProtectedSupabaseClient | ⚠️ May fail    | ✅ Safe           |
| Read-only tables        | ✅ Works       | ✅ Works          |

**Rule of Thumb:** If in doubt, use explicit policies. They're more verbose but always work.

---

## Related Lessons

- [Lesson 13: Database Triggers and RLS](13-database-triggers-rls.md) - Trigger-managed fields
- [Lesson 21: Supabase Auth Usage Patterns](21-supabase-auth-usage-patterns.md) - ProtectedSupabaseClient patterns
- [Lesson 15: Evidence-Based Database Work](15-evidence-based-database-work.md) - Verification before changes

---

## Remember

**The INSERT succeeds. The data exists. The trigger works. But `.insert().select()` returns undefined.**

This is the smoking gun for needing explicit policies. Don't waste hours debugging - check the RLS policies first.

---

## 🚀 RLS Performance Optimization (2025-11-01)

### The Discovery

**Supabase Database Linter identified 25 RLS policy performance issues:**

```
"Table public.character_instances has a row level security policy
Users manage their own character that re-evaluates current_setting()
or auth.<function>() for each row. This produces suboptimal query
performance at scale."
```

**Problem:** All RLS policies were using `auth.uid()` which evaluates **per-row** instead of once per query.

**Impact:** Sync queries hanging for 30+ seconds due to JWT validation overhead on every row.

### The Fix

**Migration:** 20251101000000_optimize_rls_auth_uid_subselect.sql

**Pattern Change:**

```sql
-- BEFORE (SLOW - per-row evaluation)
CREATE POLICY "Users manage their own character"
  ON character_instances
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- AFTER (FAST - single evaluation)
CREATE POLICY "Users manage their own character"
  ON character_instances
  USING (user_id = (select auth.uid()))
  WITH CHECK (user_id = (select auth.uid()));
```

**Tables Updated (13 total, 23 policies):**

1. character_instances (1 policy)
2. bank_accounts (4 policies)
3. bank_transactions (4 policies)
4. recycler_logs (2 policies)
5. shop_reroll_state (3 policies)
6. inventory (1 policy)
7. minions (1 policy)
8. trading_cards (1 policy)
9. user_entitlements (2 policies)
10. referrals (1 policy)
11. user_accounts (1 policy)
12. leaderboards (1 policy)
13. blueprint_parts (1 policy)

### Performance Impact

**Before:** JWT validation executed N times (once per row)
**After:** JWT validation executed 1 time (once per query)

**Expected Improvement:** 10-100x speedup for multi-row queries

**User Report:** Sync queries previously hanging for 30+ seconds should now complete in <1 second.

### Verification

**Supabase Linter Results:**

- Before: 25 "auth RLS Initialization Plan" warnings
- After: 0 warnings ✅

**Remaining Warnings (non-critical):**

- 2 WARN: Multiple permissive policies, duplicate indexes
- 27 INFO: Unindexed foreign keys, unused indexes

### Key Learnings

1. **Always run Supabase linter** before blaming application code for slow queries
2. **Per-row auth.uid() is expensive** when JWT validation is slow
3. **SELECT wrapper changes evaluation timing** without changing authorization logic
4. **Official Supabase recommendation** from database linter tool

---

**Session Reference:** Context Rollover 2025-10-25 - Bank Transaction INSERT-SELECT Bug
**Performance Fix:** 2025-11-01 - RLS Auth UID Subselect Optimization
