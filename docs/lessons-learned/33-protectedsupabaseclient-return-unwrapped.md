# Lesson 33: ProtectedSupabaseClient Returns Unwrapped Data

**Date:** 2025-10-25
**Category:** 🔴 Critical (Code Patterns)
**Session:** Context Rollover - Bank Transaction INSERT-SELECT Bug (Actual Root Cause)

---

## The Problem

**Symptom:** `.insert().select()` pattern returns `undefined` even though INSERT succeeds and data exists in database.

**Error:**

```
TypeError: Cannot read properties of undefined (reading 'id')
at BankingService.ts:533
```

**Evidence:**

- Console logs show: `authUserId` matches `characterUserId` ✅
- INSERT succeeds with 85ms latency ✅
- Database query shows row was created with correct `from_owner_user_id` ✅
- Explicit RLS policies in place ✅
- `.select()` returns `undefined` ❌

**Time Lost:** 4+ hours debugging, multiple context rollovers, incorrect RLS policy migration applied

---

## Root Cause

**ProtectedSupabaseClient.query() returns unwrapped data, NOT `{ data, error }`.**

### The Bug (WRONG)

```typescript
// BankingService.ts:506-533
const transactionResult = await protectedSupabase.query(
  () => supabase.from('bank_transactions').insert(payload).select('*').single(),
  { timeout: 6000, operationName: 'bank-create-transaction-deposit' }
);

const transaction = transactionResult.data; // ❌ UNDEFINED!
```

**Why it's wrong:**

- `protectedSupabase.query()` returns `T` directly (the data)
- NOT `{ data: T, error: Error }` like raw Supabase
- Accessing `.data` on already-unwrapped data returns `undefined`

### The Fix (CORRECT)

```typescript
// BankingService.ts:506-533 (FIXED)
const transaction = await protectedSupabase.query(
  () => supabase.from('bank_transactions').insert(payload).select('*').single(),
  { timeout: 6000, operationName: 'bank-create-transaction-deposit' }
);
// transaction is already unwrapped - no .data property needed!
```

---

## Why This Was Confusing

### 1. Raw Supabase Pattern

```typescript
// Raw Supabase client (NEVER use directly!)
const { data, error } = await supabase.from('table').select();
if (error) throw error;
return data; // Must unwrap
```

### 2. ProtectedSupabaseClient Pattern (CORRECT)

```typescript
// ProtectedSupabaseClient (ALWAYS use this!)
const data = await protectedSupabase.query(() => supabase.from('table').select());
// data is already unwrapped - ready to use!
```

### 3. Why BankingService Had The Bug

The service was mixing patterns:

```typescript
// LINE 506-531: Correctly wraps supabase call
const transactionResult = await protectedSupabase.query(
  () => supabase.from('bank_transactions').insert(payload).select('*').single()
  //     ↑ This lambda returns { data, error }
  //                                        ↑ But protectedSupabase.query() unwraps it
);

// LINE 533: INCORRECTLY tries to unwrap again
const transaction = transactionResult.data; // ❌ Already unwrapped!
```

---

## Evidence From ProtectedSupabaseClient Source

**File:** `src/services/ProtectedSupabaseClient.ts`

**Lines 143-206:**

```typescript
async query<T>(
  operation: () => Promise<{ data: T | null; error: any }>,
  //                       ↑ INPUT expects wrapped Supabase response
  config: ProtectedOperationConfig<T> = {}
): Promise<T> {  // ↑ OUTPUT returns unwrapped T
  // ... circuit breaker, retry, timeout logic ...

  const result = await supabaseCircuitBreaker.execute(
    () => retrySupabaseQuery(() => withTimeout(operation(), timeout, signal))
  );

  if (result.error) {
    throw new Error(result.error.message || 'Database query failed');
  }

  return result.data;  // ← UNWRAPS HERE - returns T directly
}
```

**Key Points:**

- Input: Lambda that returns `{ data: T, error: any }` (wrapped Supabase response)
- Output: `T` directly (unwrapped)
- Unwrapping happens at line 206: `return result.data;`

---

## How This Bug Persisted Through RLS Policy Changes

### Timeline of Investigation

1. **Initial Symptom:** `transaction` is `undefined` at line 533
2. **Hypothesis 1:** RLS policies are wrong (generic vs explicit)
   - Created migration 20251025210526 with explicit policies
   - Applied to remote database
   - Updated extensive documentation (Lessons 21, 32)
   - **Result:** Bug persisted ❌

3. **Evidence Gathering:**
   - SQL queries proved data exists ✅
   - SQL queries proved explicit policies in place ✅
   - All user IDs match ✅
   - Hard refresh performed multiple times ✅
   - **Yet bug still occurs** ❌

4. **Hypothesis 2:** Client-side caching issue
   - User performed hard refresh (Ctrl+Shift+R) 3x
   - **Result:** Bug persisted ❌

5. **Finally Checked:** BankingService.ts code at line 533
   - Found `.data` access on already-unwrapped result
   - **This was the bug all along** ✅

---

## Why The Migration Was Applied Unnecessarily

**The explicit RLS policies were NOT needed to fix this bug.**

The generic policy was working fine:

```sql
CREATE POLICY "Users manage their own bank transactions"
  ON public.bank_transactions
  USING ((from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid()))
  WITH CHECK ((from_owner_user_id = auth.uid()) OR (to_owner_user_id = auth.uid()));
```

**Evidence:**

- character_instances uses same generic pattern and works
- bank_accounts had explicit policies but that wasn't why it worked
- The bug was in TypeScript code, not RLS policies

**However:** The explicit policies are still a good practice for `.insert().select()` patterns (Lesson 32), so the migration is not harmful, just unnecessary for fixing THIS bug.

---

## Verification Checklist

When debugging "INSERT succeeded but SELECT returned undefined":

- [ ] **Step 1:** Check the code accessing the result
  - Is it using `.data` on `protectedSupabase.query()` result? → BUG
  - Is it accessing the result directly? → Correct

- [ ] **Step 2:** Check RLS policies (if Step 1 is correct)
  - Does table use `.insert().select()` pattern?
  - Are explicit FOR policies needed? (See Lesson 32)

- [ ] **Step 3:** Check trigger-managed fields (if Steps 1-2 are correct)
  - Does trigger set fields correctly?
  - Do trigger-set values match RLS policy conditions?

---

## Pattern Reference

### ✅ CORRECT - All ProtectedSupabaseClient Usage

```typescript
// INSERT with SELECT
const transaction = await protectedSupabase.query(() =>
  supabase.from('table').insert(data).select('*').single()
);
// transaction is T, not { data: T }

// SELECT query
const rows = await protectedSupabase.query(() => supabase.from('table').select('*'));
// rows is T[], not { data: T[] }

// UPDATE query
const updated = await protectedSupabase.query(() =>
  supabase.from('table').update(data).eq('id', id).select('*').single()
);
// updated is T, not { data: T }

// RPC call
const result = await protectedSupabase.rpc('function_name', params);
// result is T, not { data: T }
```

### ❌ WRONG - Double Unwrapping

```typescript
// NEVER do this
const result = await protectedSupabase.query(() => supabase.from('table').select('*'));
const data = result.data; // ❌ result.data is undefined!
```

---

## Additional Instance: SyncService Bug (2025-10-25)

**Same bug found and fixed in SyncService.ts:**

### The Bug in SyncService

```typescript
// SyncService.ts:338-360 (BEFORE FIX)
const remoteCharacter = await supabaseMetrics.trackQuery('sync_fetch_character', async () => {
  try {
    return await protectedSupabase.query(() =>
      supabase.from('character_instances').select('*').eq('id', localCharacter.id).maybeSingle()
    );
  } catch (error) {
    return { data: null, error }; // Wrapping error in Supabase format
  }
});

// Line 365: Checking .data on unwrapped result!
if (remoteCharacter.data) {
  // ❌ BUG - remoteCharacter is already unwrapped
  const remoteVersion = remoteCharacter.data.version;
}
```

**Why this caused duplicate key errors:**

1. Sync fetches character: `protectedSupabase.query()` returns character object or null
2. Code checks `remoteCharacter.data` which is undefined on character object
3. Check fails, sync thinks character doesn't exist remotely
4. Sync tries INSERT on existing character → duplicate key error

### The Fix

```typescript
// SyncService.ts:338-382 (AFTER FIX)
let remoteCharacterData: any = null;
let fetchError: any = null;

try {
  remoteCharacterData = await supabaseMetrics.trackQuery('sync_fetch_character', async () => {
    return await protectedSupabase.query(() =>
      supabase.from('character_instances').select('*').eq('id', localCharacter.id).maybeSingle()
    );
  });
} catch (error: any) {
  fetchError = error;
}

// Direct check on unwrapped data
if (remoteCharacterData) {
  // ✅ CORRECT
  const remoteVersion = remoteCharacterData.version;
}
```

**Evidence from logs:**

```
15:15:13.422 [DEBUG] [ProtectedSupabase] Query succeeded: sync-fetch-character {"latency":"122ms"}
15:15:13.423 [DEBUG] Inserting new character to Supabase
15:15:13.599 [ERROR] duplicate key value violates unique constraint "character_instances_pkey"
```

Character existed in database (proven by SQL query), but sync fetch returned it correctly and code failed to detect it due to `.data` access bug.

**Commit:** 1eb6172 - fix(sync): fix character sync duplicate key errors and currency update reactivity

---

## Related Services To Audit

**Potential Instances of Same Bug:**

Search for: `protectedSupabase.query` + `.data` access

```bash
grep -r "protectedSupabase\.query" src/services/ | grep "\.data"
```

**Instances Found and Fixed:**

- ✅ BankingService.ts (2025-10-25) - deposit/withdraw .data access
- ✅ SyncService.ts (2025-10-25) - syncCharacter .data access

**Verified Clean:**

- ✅ All other protectedSupabase.query() calls checked (2025-10-25)

---

## Test Coverage

**BankingService.test.ts:**

- ✅ 29/30 tests passing (1 skipped)
- ✅ deposit() test passes after fix
- ✅ withdraw() test passes after fix

**Key Test:**

```typescript
test('deposit creates transaction record', async () => {
  const transaction = await BankingService.deposit(characterId, userId, 100);
  expect(transaction).toBeDefined(); // Now passes!
  expect(transaction.id).toBeDefined();
});
```

---

## Prevention Measures

### For Future Development

1. **Code Review Checklist:**
   - Any `protectedSupabase.query()` call should assign directly to variable
   - Never access `.data` or `.error` on `protectedSupabase.query()` result

2. **Linting Rule (Future):**

   ```typescript
   // ESLint rule to catch this pattern:
   // Error: Do not access .data on protectedSupabase.query() result
   const result = await protectedSupabase.query(...);
   const data = result.data;  // ← Should be linting error
   ```

3. **Documentation:**
   - Add this lesson to CONTINUATION_PROMPT.md
   - Update Lesson 21 to reference this lesson
   - Add to "Common Pitfalls" section

---

## Related Lessons

- [Lesson 21: Supabase Auth Usage Patterns](21-supabase-auth-usage-patterns.md) - ProtectedSupabaseClient usage
- [Lesson 32: RLS Explicit vs Generic Policies](32-rls-explicit-vs-generic-policies.md) - RLS policy patterns (still valid)
- [Lesson 13: Database Triggers and RLS](13-database-triggers-rls.md) - Trigger-managed fields

---

## Remember

**The unwrapping happens inside ProtectedSupabaseClient.query().**

```
Raw Supabase { data, error }
    ↓ (passed to protectedSupabase.query)
    ↓ (circuit breaker + retry + timeout)
    ↓ (error handling)
    ↓ (return result.data)
Your Code ← T (already unwrapped)
```

**Never try to unwrap again - it's already done for you.**

---

**Session Reference:** Context Rollover 2025-10-25 - Bank Transaction INSERT-SELECT Bug (Actual Root Cause)
