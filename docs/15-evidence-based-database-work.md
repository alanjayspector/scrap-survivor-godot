# Lesson 15: Evidence-Based Database Work

**Category:** 🔴 Critical (Database)
**Last Updated:** 2025-10-19 (Session Part 10 - Migration Versioning)
**Sessions:** 2025-10-19 Part 10 (Bank Duplicate Rows & RLS)

---

## The Problem

**Context:** Migration `20251024_fix_bank_accounts_rls.sql` failed with version conflict.

**My Response:** Renamed migration multiple times without checking database state:

- `20251019_fix_bank_accounts_rls.sql` → Failed (version exists)
- `20251019_02_fix_bank_accounts_rls.sql` → Failed (same version)
- Multiple rename attempts → Thrashing

**User Feedback:**

> "my dude.. i know you have Sr DBA experience AND have worked on supabase integration projects before you can do this with correctly with proper data points and evidence for what you are doing instead of thrashing.. what information would give you a better picture of where to go?"

---

## What Happened

### The Wrong Approach (Thrashing)

```bash
# ❌ WRONG - Guessing and renaming without evidence
git mv 20251019_fix.sql 20251019_02_fix.sql
npx supabase db push  # Fails again

git mv 20251019_02_fix.sql 20251020_fix.sql
npx supabase db push  # Still might fail

# This is thrashing - making changes without data
```

### The Right Approach (Evidence-Based)

```bash
# ✅ CORRECT - Gather evidence first
npx supabase db push --debug  # See actual error
npx supabase migration list --db-url "$DATABASE_URL"  # Check versions
psql "$DATABASE_URL" -c "SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 10"

# Now rename with confidence
git mv old_name.sql 20251024_fix.sql  # Using available version
npx supabase db push  # Succeeds
```

---

## The Lesson

### Evidence-Based Workflow

**1. Gather Data First**

```bash
# What migrations are applied?
npx supabase migration list --db-url "$DATABASE_URL"

# What's the error?
npx supabase db push --debug

# What versions exist?
ls -la supabase/migrations/ | grep 2025
```

**2. Analyze Evidence**

```
# Output shows: 20251019 already exists
# Next available: 20251024 (today's date)
```

**3. Make Informed Decision**

```bash
# Use version that doesn't conflict
git mv migration.sql supabase/migrations/20251024_name.sql
```

**4. Verify Solution**

```bash
# Apply and confirm success
npx supabase db push --debug
```

---

## Common Database Operations

### Creating Migrations

**❌ Wrong:**

```bash
# Just create with today's date
touch supabase/migrations/20251019_new_feature.sql
# Might conflict with existing migrations!
```

**✅ Correct:**

```bash
# 1. Check existing versions
ls supabase/migrations/ | grep 20251019

# 2. If exists, use next available date
# 3. Create migration with unique version
touch supabase/migrations/20251024_new_feature.sql
```

### Debugging Migration Failures

**❌ Wrong:**

```bash
npx supabase db push  # Fails
# Immediately try to fix without understanding error
```

**✅ Correct:**

```bash
# 1. Use --debug flag
npx supabase db push --debug

# 2. Read the full error message
# 3. Check what migration failed
# 4. Verify database state
psql "$DATABASE_URL" -c "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 5"

# 5. Fix based on evidence
```

### Checking Database State

**❌ Wrong:**

```bash
# Assume table structure from memory
# Write migration based on assumptions
```

**✅ Correct:**

```bash
# 1. Check actual table structure
psql "$DATABASE_URL" -c "\d+ table_name"

# 2. Check existing policies
psql "$DATABASE_URL" -c "\d+ table_name" | grep -A 20 "Policies"

# Or use Supabase command
psql "$DATABASE_URL" -c "SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'table_name'"

# 3. Write migration based on reality
```

### Verifying Migrations Applied

**❌ Wrong:**

```bash
# Assume migration applied successfully
# Move on without checking
```

**✅ Correct:**

```bash
# 1. List applied migrations
npx supabase migration list --db-url "$DATABASE_URL"

# 2. Check schema_migrations table
psql "$DATABASE_URL" -c "SELECT version, name FROM schema_migrations ORDER BY version DESC LIMIT 10"

# 3. Verify changes took effect
psql "$DATABASE_URL" -c "SELECT * FROM pg_policies WHERE tablename = 'your_table'"
```

---

## Evidence Sources

### 1. Supabase CLI

```bash
# List migrations
npx supabase migration list --db-url "$DATABASE_URL"

# Push with debug output
npx supabase db push --debug

# Push specific migration
npx supabase db push --include-all --debug
```

### 2. PostgreSQL CLI

```bash
# Table structure
psql "$DATABASE_URL" -c "\d+ table_name"

# RLS policies
psql "$DATABASE_URL" -c "SELECT * FROM pg_policies WHERE tablename = 'table_name'"

# Triggers
psql "$DATABASE_URL" -c "SELECT tgname, tgtype, proname FROM pg_trigger t JOIN pg_proc p ON t.tgfoid = p.oid WHERE tgrelid = 'table_name'::regclass"

# Applied migrations
psql "$DATABASE_URL" -c "SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 10"
```

### 3. File System

```bash
# List migration files
ls -la supabase/migrations/

# Check for version conflicts
ls supabase/migrations/ | grep 20251019

# Find migrations by name
find supabase/migrations -name "*rls*"
```

### 4. Schema Files

```bash
# Current schema
cat supabase/schema.sql | grep -A 20 "table_name"

# Recent schema snapshot
cat supabase/schema_fresh_*.sql | grep -A 20 "table_name"
```

---

## Common Scenarios

### Scenario 1: Migration Version Conflict

**Symptoms:**

```
Error: duplicate key value violates unique constraint "schema_migrations_pkey"
Detail: Key (version)=(20251019) already exists.
```

**Evidence to Gather:**

```bash
# What versions are applied?
psql "$DATABASE_URL" -c "SELECT version FROM schema_migrations WHERE version LIKE '2025%' ORDER BY version DESC"

# What files exist locally?
ls supabase/migrations/ | grep 2025

# What's the next available version?
# Use next date (20251024, 20251025, etc.)
```

**Solution:**

```bash
git mv old_file.sql supabase/migrations/YYYYMMDD_new_name.sql
# Where YYYYMMDD is next available version
```

### Scenario 2: RLS Policy Timeout

**Symptoms:**

```
Error: Query timeout after 6000ms
```

**Evidence to Gather:**

```bash
# What policies exist?
psql "$DATABASE_URL" -c "SELECT policyname, cmd FROM pg_policies WHERE tablename = 'table_name'"

# How many policies?
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM pg_policies WHERE tablename = 'table_name'"

# Are there indexes?
psql "$DATABASE_URL" -c "\d+ table_name" | grep -A 10 "Indexes"
```

**Solution:**

- Compare with working tables
- Check established patterns (2 policies vs 4)
- Revert to known-good pattern

### Scenario 3: Trigger Not Firing

**Symptoms:**

- Field not auto-populated
- NULL values in NOT NULL columns

**Evidence to Gather:**

```bash
# Does trigger exist?
psql "$DATABASE_URL" -c "SELECT tgname, proname FROM pg_trigger t JOIN pg_proc p ON t.tgfoid = p.oid WHERE tgrelid = 'table_name'::regclass"

# What does trigger function do?
psql "$DATABASE_URL" -c "\df+ trigger_function_name"

# Is BEFORE or AFTER?
psql "$DATABASE_URL" -c "SELECT tgname, tgtype FROM pg_trigger WHERE tgrelid = 'table_name'::regclass"
# tgtype 2 = BEFORE, tgtype 4 = AFTER
```

**Solution:**

- Verify trigger exists
- Check trigger timing (BEFORE vs AFTER)
- Don't pass trigger-managed fields explicitly

---

## The Protocol (Mandatory)

### Before ANY Database Change:

**1. Check Current State**

```bash
# What exists now?
psql "$DATABASE_URL" -c "\d+ table_name"
```

**2. Identify What Needs to Change**

```bash
# What's the gap between current and desired?
# Document the difference
```

**3. Check for Conflicts**

```bash
# Will this conflict with existing migrations?
ls supabase/migrations/ | grep $(date +%Y%m%d)

# Will this conflict with existing constraints?
psql "$DATABASE_URL" -c "\d+ table_name" | grep -E "Constraints|Indexes|Policies"
```

**4. Plan the Change**

```bash
# Write migration SQL
# Test locally first if possible
```

**5. Apply with Verification**

```bash
# Apply
npx supabase db push --debug

# Verify
psql "$DATABASE_URL" -c "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
```

---

## Tools and Flags

### Supabase CLI Flags

```bash
--debug            # Show detailed output
--include-all      # Include all pending migrations
--db-url URL       # Specify database URL
--password PASS    # Database password
```

### PostgreSQL CLI Commands

```bash
\d+ table_name              # Describe table with details
\df+ function_name          # Describe function
\dt                         # List tables
\di                         # List indexes
\l                          # List databases
```

### Useful Queries

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'table_name';

-- Check triggers
SELECT * FROM pg_trigger WHERE tgrelid = 'table_name'::regclass;

-- Check applied migrations
SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 10;

-- Check table size
SELECT pg_size_pretty(pg_total_relation_size('table_name'));
```

---

## Self-Check Questions

Before making database changes, ask:

1. **What is the current state?**
   - Run queries to verify
   - Don't assume from memory

2. **What exactly needs to change?**
   - Be specific
   - Document the gap

3. **What could go wrong?**
   - Version conflicts?
   - Data loss?
   - Performance impact?

4. **How will I verify success?**
   - What query proves it worked?
   - What error would indicate failure?

5. **Can I revert if needed?**
   - Is there a rollback plan?
   - Can I undo this change?

---

## Summary

**Gather evidence BEFORE making database changes.**

**The Protocol:**

1. **Check state** - Use --debug, psql, ls commands
2. **Analyze evidence** - Read errors, check versions
3. **Make informed decision** - Based on data, not assumptions
4. **Verify solution** - Confirm it worked

**Why this matters:**

- Database operations are often irreversible
- Thrashing wastes time and breaks things
- Evidence prevents mistakes
- Confidence comes from data, not guesses

**User's expectation:**

> "you have Sr DBA experience... figure it out yourself with proper data points"

This means:

- Use diagnostic tools
- Read error messages completely
- Check actual database state
- Make decisions based on evidence
- Don't guess and retry

**Anti-pattern:** Thrashing (making changes without data)

**Good pattern:** Evidence-based decisions

---

## Related Lessons

- [Lesson 13: Database Triggers and RLS Integration](13-database-triggers-rls.md) - Understanding triggers
- [Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md) - Check migrations first
- [09-ai-execution-protocol.md](09-ai-execution-protocol.md) - Think before acting

---

**Session Reference:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)
