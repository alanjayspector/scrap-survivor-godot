# Lesson 30: Supabase Migration Timestamp Discipline

**Category:** 🔴 Critical (Database)
**Last Updated:** 2025-10-25
**Sessions:** 2025-10-25 (Migration Baseline Reset - PERMANENT FIX), 2025-10-24 (Telemetry RLS Issues)
**Status:** ✅ RESOLVED - Fresh baseline implemented, no more sync issues

---

## The Problem

**Context:** Every time we add a new feature requiring database changes, we encounter migration sync issues.

**Symptoms:**

- `supabase db pull` shows migrations as "reverted"
- `supabase migration list` shows migrations as "applied"
- RLS policy changes don't take effect even after "successful" push
- Telemetry INSERT operations fail with RLS violations despite "fixed" policies

**Root Cause:** Creating migration files with **future-dated timestamps** when today's date is earlier.

---

## What Happened

### The Pattern (Repeated Multiple Times)

1. Create migration file with future date: `20251028_fix_telemetry_rls.sql` (when today is 2025-10-25)
2. Run `supabase db push`
3. Migration shows as "applied" in output
4. Run `supabase db pull` - shows migration as "reverted"
5. Run `supabase migration repair --status reverted` then `--status applied`
6. Migration history table updates, but **SQL NEVER EXECUTES**
7. Issue persists, repeat cycle with new migration file

### Example Timeline

**Date: 2025-10-25 (today)**

Created migrations:

- `20251026_add_telemetry_table.sql` ❌ Future-dated
- `20251028_fix_telemetry_rls_generic_policy.sql` ❌ Future-dated
- `20251029_revert_telemetry_to_working_state.sql` ❌ Future-dated
- `20251030_fix_telemetry_rls_final.sql` ❌ Future-dated

**Result:** All marked as "reverted" by Supabase CLI, none actually executed.

---

## Why This Happens

### Supabase Migration System Behavior

1. **Timestamp-Based Ordering:**
   - Migrations are ordered by timestamp prefix: `YYYYMMDD_description.sql`
   - Supabase expects migrations to be created chronologically
   - Future dates confuse the sync algorithm

2. **Migration Repair Limitation:**
   - `supabase migration repair` ONLY updates `supabase_migrations.schema_migrations` table
   - It does NOT re-execute the SQL from migration files
   - Therefore: "applied" in history table ≠ SQL actually ran

3. **Local vs Remote State:**
   - Local schema.sql shows correct state (includes all migrations)
   - Remote database missing changes from "reverted" migrations
   - `supabase db pull` detects this mismatch

---

## The Fix

### ✅ CORRECT: Use Today's Date

```bash
# Get today's date in YYYYMMDD format
date +%Y%m%d

# Output: 20251025

# Create migration with TODAY'S date
supabase migration new 20251025_fix_telemetry_rls
```

### ✅ CORRECT: Auto-Generated Timestamps

```bash
# Let Supabase CLI generate the timestamp
supabase migration new fix_telemetry_rls

# CLI automatically uses current date/time
# Output: 20251025143052_fix_telemetry_rls.sql
```

### ❌ WRONG: Future Dates

```bash
# DON'T manually create files with future dates
touch supabase/migrations/20251028_fix_telemetry_rls.sql  # ❌ WRONG
```

---

## The Protocol

### Before Creating Any Migration

1. **Check Today's Date:**

   ```bash
   date +%Y%m%d
   ```

2. **Verify Existing Migrations:**

   ```bash
   ls -la supabase/migrations/ | tail -5
   ```

   Ensure no future-dated files exist.

3. **Create Migration:**

   ```bash
   # Option A: Let CLI generate timestamp (RECOMMENDED)
   supabase migration new descriptive_name

   # Option B: Manual timestamp (use TODAY'S date)
   supabase migration new $(date +%Y%m%d)_descriptive_name
   ```

### After Creating Migration

1. **Write SQL:**

   ```sql
   BEGIN;

   -- Your DDL/DML changes here

   COMMIT;
   ```

2. **Test Locally First:**

   ```bash
   # Apply to local Supabase
   supabase db reset

   # Verify schema
   supabase db diff
   ```

3. **Push to Remote:**

   ```bash
   supabase db push
   ```

4. **VERIFY Migration Actually Applied:**

   ```bash
   # Check both migration list AND pull status
   supabase migration list
   supabase db pull

   # Should show NO reverted migrations
   # Should show NO schema differences
   ```

5. **Test the Actual Feature:**
   - Don't trust "applied" status alone
   - Manually test the feature that required the migration
   - Example: If fixing telemetry RLS, test telemetry INSERT

---

## Verification Checklist

After pushing any migration:

- [ ] `supabase migration list` shows migration as "applied"
- [ ] `supabase db pull` shows NO "reverted" migrations
- [ ] `supabase db pull` shows NO schema differences
- [ ] Manual test confirms feature works (e.g., telemetry INSERT succeeds)
- [ ] Console log shows NO RLS policy violations
- [ ] All unit tests pass

**If ANY of these fail, the migration DID NOT actually apply.**

---

## Debugging Migration Issues

### Symptom: Migration shows "applied" but feature still broken

**Likely Cause:** Migration repair ran, but SQL never executed.

**Debug Steps:**

1. **Check remote schema directly:**

   ```bash
   # Connect to remote database
   supabase db remote --db-url "postgres://..."

   # Query the specific table/policy
   SELECT * FROM pg_policies WHERE tablename = 'your_table';
   ```

2. **Compare local vs remote:**

   ```bash
   # Dump local schema
   supabase db dump -f local_schema.sql

   # Dump remote schema
   supabase db remote dump -f remote_schema.sql

   # Compare
   diff local_schema.sql remote_schema.sql
   ```

3. **Manual SQL Execution:**
   If migration SQL never ran, execute manually in Supabase Dashboard:
   - Go to SQL Editor
   - Paste migration SQL
   - Execute
   - Then run `supabase db pull` to sync state

### Symptom: Migration shows "reverted"

**Likely Cause:** Future-dated timestamp.

**Fix:**

1. **Delete the future-dated migration file:**

   ```bash
   rm supabase/migrations/20251028_*.sql
   ```

2. **Create new migration with TODAY'S date:**

   ```bash
   supabase migration new $(date +%Y%m%d)_same_description
   ```

3. **Copy SQL content** from old file to new file

4. **Push again:**
   ```bash
   supabase db push
   ```

---

## RLS Policy Patterns

### Pattern 1: User-Owned Resources

**Tables:** `character_instances`, `bank_accounts`, `inventory`, `minions`, `trading_cards`

**Policy:**

```sql
-- Generic policy (no FOR clause) with BOTH USING and WITH CHECK
CREATE POLICY "Users can manage own resources"
  ON public.table_name
  TO authenticated
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());
```

**Reference:** `20251014_rls_owner_fastpath.sql` lines 195-198 (bank_accounts)

### Pattern 2: Anonymous/Public Events

**Tables:** `telemetry_events` (no user_id column)

**Policy:**

```sql
-- INSERT-only, no user filtering (analytics via service role)
CREATE POLICY "Authenticated clients can insert telemetry"
  ON public.telemetry_events
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- No SELECT policy needed (analytics queries use service role)
```

**Reference:** `schema.sql` line 5124, working state from Oct 17

### Pattern 3: Two-Policy (Generic + SELECT)

**Tables:** `bank_accounts`, `inventory`

**Policies:**

```sql
-- Generic policy for INSERT/UPDATE/DELETE
CREATE POLICY "Users can manage own resources"
  ON public.table_name
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- SELECT-specific policy (can be more permissive)
CREATE POLICY "Users can view own resources"
  ON public.table_name
  FOR SELECT
  USING (owner_user_id = auth.uid());
```

**Reference:** `20251014_rls_owner_fastpath.sql` lines 195-203

---

## Integration with Triggers

**CRITICAL:** BEFORE INSERT triggers run BEFORE RLS WITH CHECK policies.

### Sequence of Events

1. **Application code** sends INSERT with partial data:

   ```typescript
   await supabase.from('bank_accounts').insert({
     character_id: 'char-1',
     // owner_user_id is NOT passed
     balance: 0,
   });
   ```

2. **BEFORE INSERT trigger** runs:

   ```sql
   -- Trigger auto-populates owner_user_id from character_instances
   NEW.owner_user_id := (SELECT user_id FROM character_instances WHERE id = NEW.character_id);
   ```

3. **RLS WITH CHECK policy** evaluates:

   ```sql
   -- Checks the trigger-set value
   WITH CHECK (owner_user_id = auth.uid())
   ```

4. **INSERT succeeds** if `owner_user_id` matches `auth.uid()`

5. **RLS USING policy** applies to SELECT:
   ```sql
   -- SELECT returns the inserted row
   USING (owner_user_id = auth.uid())
   ```

**See Also:** [Lesson 13: Database Triggers and RLS Integration](13-database-triggers-rls.md)

---

## Common Mistakes

### ❌ Mistake 1: Using FOR INSERT Without Understanding Scope

```sql
-- This ONLY applies to INSERT operations
CREATE POLICY "Insert only"
  ON public.table_name
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Problem: SELECT, UPDATE, DELETE have NO policy → denied by default
```

**Fix:** Use generic policy (no FOR clause) OR add separate policies for each operation.

### ❌ Mistake 2: Passing Trigger-Managed Fields

```typescript
// ❌ WRONG: Passing owner_user_id when trigger sets it
await supabase.from('bank_accounts').insert({
  character_id: 'char-1',
  owner_user_id: userId, // Trigger will overwrite this!
  balance: 0,
});
```

**Fix:** Omit trigger-managed fields from INSERT payload.

### ❌ Mistake 3: Trusting "Applied" Status Alone

```bash
supabase db push
# Output: "Applied 20251028_fix.sql" ✓

# Assumption: Migration worked
# Reality: May be marked "reverted" due to future date
```

**Fix:** Always run verification checklist after push.

### ❌ Mistake 4: Using Migration Repair as Primary Fix

```bash
# ❌ WRONG approach
supabase migration repair --status reverted
supabase migration repair --status applied
# This only updates history table, doesn't re-execute SQL!
```

**Fix:** Migration repair is for fixing history table corruption, NOT for applying migrations.

---

## When Migration Repair IS Appropriate

**Use Case:** History table is corrupted but migrations actually executed.

**Scenario from Oct 24:**

- Migrations 20251021-20251024 all executed successfully on remote
- History table showed them as "reverted" due to CLI bug
- Running `supabase db pull` showed no schema differences (proof SQL executed)
- Migration repair fixed history table to match actual state

**Protocol:**

1. Verify SQL actually executed (check remote schema directly)
2. If schema is correct but history wrong, use migration repair
3. If schema is wrong, migration repair won't help

---

## Files to Check Before Creating Migrations

### 1. Current Migration List

```bash
ls -la supabase/migrations/ | tail -10
```

Look for:

- Highest timestamp (should be ≤ today's date)
- Any future-dated files (delete these)

### 2. Migration History

```bash
supabase migration list
```

Look for:

- Any "reverted" status
- Gaps in sequence
- Timestamps matching file names

### 3. Schema Sync Status

```bash
supabase db pull
```

Look for:

- Any "reverted" migrations in output
- Any schema differences in output
- Should be clean if fully synced

### 4. Recent Session Logs

```bash
ls -la docs/archive/session-handoffs/session-log-2025-10-*.md | tail -3
```

Check if recent sessions encountered migration issues.

---

## Related Lessons

- [Lesson 13: Database Triggers and RLS Integration](13-database-triggers-rls.md) - Trigger + RLS patterns
- [Lesson 15: Evidence-Based Database Work](15-evidence-based-database-work.md) - Verify before changing
- [Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md) - Migration files document patterns
- [09-ai-execution-protocol.md](../development-guide/09-ai-execution-protocol.md) - Read docs BEFORE coding

---

## Quick Reference

**Before ANY migration work:**

```bash
# 1. What's today's date?
date +%Y%m%d

# 2. What migrations exist?
ls -la supabase/migrations/ | tail -5

# 3. Are there any future-dated files?
# If YES → delete them first

# 4. Create migration with TODAY'S date
supabase migration new $(date +%Y%m%d)_descriptive_name

# 5. Write SQL with BEGIN/COMMIT
# 6. Test locally: supabase db reset
# 7. Push: supabase db push

# 8. VERIFY (all must pass):
supabase migration list        # Check "applied"
supabase db pull              # Check no "reverted", no diff
# Manual test the actual feature
```

**RLS Policy Checklist:**

- [ ] Read established patterns in `20251014_rls_owner_fastpath.sql`
- [ ] Identify table type (user-owned vs anonymous)
- [ ] Use generic policy (no FOR clause) for user-owned resources
- [ ] Use FOR INSERT + WITH CHECK for anonymous events
- [ ] Test actual INSERT/SELECT operations after migration
- [ ] Check console for RLS violations

**Never:**

- ❌ Create future-dated migration files
- ❌ Use migration repair to "fix" features (it doesn't re-execute SQL)
- ❌ Trust "applied" status without verification
- ❌ Pass fields that triggers auto-populate

---

## Summary

**MIGRATIONS MUST USE TODAY'S DATE OR EARLIER. Future dates cause silent failures.**

**The Golden Rule:**

```bash
# ALWAYS let CLI generate timestamp OR use $(date +%Y%m%d)
supabase migration new descriptive_name

# NEVER manually type future dates
```

**Verification Protocol:**

1. Migration list shows "applied" ✓
2. Db pull shows no "reverted" ✓
3. Db pull shows no schema diff ✓
4. Manual feature test works ✓

**If verification fails:** SQL didn't execute. Run manually in Supabase Dashboard, then `supabase db pull`.

---

**Why this matters:**

- Prevents week-long thrashing cycles
- Ensures migrations actually apply
- Maintains sync between local and remote
- Avoids false confidence from "applied" status

**This pattern has caused issues:** 2025-10-24 (telemetry), 2025-10-25 (same), every feature addition this month.

**Session Reference:** session-log-2025-10-25-bank-transaction-timeout.md

---

## 🎯 PERMANENT FIX (2025-10-25)

### The Solution: Fresh Schema Baseline

After recurring migration sync issues blocking development every session, we implemented **Option 1: Fresh Schema Baseline** to permanently resolve the problem.

**What We Did:**

1. **Archived all old migrations** to `migrations_archive_20251025/`
2. **Marked old remote migrations as reverted** (20251012-20251026)
3. **Created clean baseline** with current remote schema
4. **New migration format** uses hour+minute timestamps: `YYYYMMDDHHMM_description.sql`

**Result:**

```bash
$ supabase migration list

   Local        | Remote       | Time (UTC)
  --------------|--------------|--------------
   202510251100 | 202510251100 | 202510251100
```

✅ Perfect sync - no more conflicts
✅ Migration system works cleanly
✅ No more 15-30 minute debugging per session

### New Migration Workflow

**From now on:**

```bash
# Create migration (CLI auto-generates timestamp with hour+minute)
supabase migration new feature_name
# Creates: 202510251130_feature_name.sql

# Push to database
supabase db push

# Verify sync (should always match)
supabase migration list
```

**Key Change:** Timestamps now include hour+minute (12 digits) to prevent same-day collisions.

### Files Archived

**Location:** `supabase/migrations_archive_20251025/`

- 37 migration files from 20251012-20251026
- All superseded and conflicting migrations
- Preserved in git history for reference

### Schema Verification

**Schema.sql is now source of truth:**

- Pulled directly from remote database: `supabase db dump`
- 1189 lines (cleaner than previous 5000+ version)
- Verified to match remote exactly
- bank_transactions includes: character_name, balance_after columns ✅

### Why This Approach

**DBA Best Practice: Schema Baseline**

When migration history gets corrupted:

1. Dump current production schema
2. Archive old migrations
3. Create single baseline migration
4. Mark as applied
5. All future migrations are clean, additive

**This is standard practice** when migration systems get out of sync.

### Going Forward

**Rules:**

1. ✅ Use `supabase migration new` (auto-generates timestamp)
2. ✅ Timestamp format: `YYYYMMDDHHMM` (12 digits)
3. ✅ Never manually create migration files
4. ✅ Verify `supabase migration list` shows sync after push
5. ✅ Pull schema after migrations: `supabase db dump -f supabase/schema.sql`

**No more:**

- ❌ Migration repair thrashing
- ❌ Timestamp collisions
- ❌ Local/remote sync issues
- ❌ Wasted development time

**Permanent resolution confirmed:** session-log-2025-10-25-bank-transaction-timeout.md
