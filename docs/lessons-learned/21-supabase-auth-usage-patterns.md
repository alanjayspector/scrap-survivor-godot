# Lesson 21: Supabase Auth Usage Patterns

**Date:** 2025-10-19 (Session Part 11 - Banking Test Fix)
**Category:** 🟢 Reference (Pattern Documentation)
**Session:** [session-log-2025-10-19-part11-banking-comprehensive-review.md](../09-archive/session-handoffs/session-log-2025-10-19-part11-banking-comprehensive-review.md)

---

## Summary

After 72+ hours debugging banking issues, we discovered critical patterns about how Supabase auth methods are (and aren't) used across our services. This lesson documents these patterns to prevent future test mocking issues.

---

## Critical ProtectedSupabaseClient Patterns (Added 2025-10-19, Updated 2025-10-25)

These patterns caused production failures and MUST be followed:

### Pattern 1: .insert().select() Requires Explicit FOR SELECT Policy (CRITICAL)

**Rule:** Tables using `.insert().select()` pattern MUST have explicit `FOR SELECT` RLS policy, not generic USING/WITH CHECK.

```sql
-- ❌ WRONG - Generic policy doesn't work with .insert().select()
CREATE POLICY "Generic policy"
  ON public.table_name
  TO authenticated
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- ✅ CORRECT - Explicit policies required
CREATE POLICY "Insert policy"
  ON public.table_name
  FOR INSERT TO authenticated
  WITH CHECK (owner_user_id = auth.uid());

CREATE POLICY "Select policy"
  ON public.table_name
  FOR SELECT TO authenticated
  USING (owner_user_id = auth.uid());
```

**Why:** The `.insert().select()` pattern executes two separate operations:

1. INSERT - checked by WITH CHECK policy
2. SELECT - checked by USING policy

Generic policies (without FOR clause) don't properly separate these checks, causing SELECT to return undefined even when INSERT succeeds.

**Real Failures:**

- 2025-10-25: bank_transactions `.insert().select()` returned undefined (3 hours debugging)
- 2025-10-19: Similar issue with telemetry_events
- Pattern: INSERT succeeds, data is in database, but SELECT returns undefined

**Evidence Session:** 2025-10-25 - Verified via SQL query that trigger set correct from_owner_user_id, rows exist in database, but `.insert().select()` still returned undefined until explicit policies added.

**Tables Requiring Explicit Policies:**

- ✅ bank_accounts (has explicit policies - works)
- ✅ bank_transactions (fixed 2025-10-25 with explicit policies)
- ✅ telemetry_events (has explicit policies - works)
- ⚠️ ANY table using ProtectedSupabaseClient with `.insert().select()` pattern

### Pattern 2: INSERT Operations MUST Include .select()

**Rule:** All INSERT operations through ProtectedSupabaseClient MUST add `.select()` to return data.

```typescript
// ❌ WRONG - Throws "Query returned null data"
await protectedSupabase.query(() => supabase.from('table').insert([record]), {
  operationName: 'operation-name',
});

// ✅ CORRECT - Returns data
await protectedSupabase.query(() => supabase.from('table').insert([record]).select(), {
  operationName: 'operation-name',
});
```

**Why:** INSERT without `.select()` returns `{data: null, error: null}` by design. ProtectedSupabaseClient throws error on null data (ProtectedSupabaseClient.ts:189-190).

**Real Failure:** TelemetryService failed on every character creation until fixed.

### Pattern 3: Never Double-Filter on owner_user_id

**Rule:** NEVER add `.eq('owner_user_id', userId)` or `.eq('from_owner_user_id', userId)` to queries. Let RLS handle ALL ownership filtering.

```typescript
// ❌ WRONG - Causes 6s timeout
const result = await supabase
  .from('bank_transactions')
  .select('*')
  .eq('from_owner_user_id', userId) // ← NEVER DO THIS
  .order('created_at', { ascending: false });

// ✅ CORRECT - Fast (< 400ms)
const result = await supabase
  .from('bank_transactions')
  .select('*')
  // RLS filters by owner automatically
  .order('created_at', { ascending: false });
```

**Why:** RLS already filters by `owner_user_id = auth.uid()`. Adding redundant application filter creates performance issues and query plan conflicts.

**Real Failure:** BankingService.getTransactionHistory() timed out after 6 seconds until fixed.

**Reference:** See ProtectedSupabaseClient.ts line 189-190 for null data check. See bank_transactions RLS policy in supabase/schema.sql line 5067.

---

## Key Finding: Most Services Don't Use Auth Methods

### Evidence-Based Analysis

**Command Run:**

```bash
grep -r "supabase\.auth\." src/services --include="*.ts"
```

**Result:**

```
src/services/BankingService.ts:104:      const authUser = await supabase.auth.getUser();
src/services/BankingService.ts:105:      const session = await supabase.auth.getSession();
```

**Interpretation:**

- **Only BankingService** uses `supabase.auth.*` methods
- All other services rely on **RLS (Row Level Security)** for auth
- Auth is **implicit** via Supabase RLS policies, not explicit via auth method calls

---

## Service-by-Service Pattern Analysis

### Services That DON'T Use Auth Methods

**1. HybridCharacterService**

- Uses: `supabase.from('character_instances')`
- Auth: Implicit via RLS filtering by `user_id = auth.uid()`
- Pattern: Query tables directly, RLS handles ownership

**2. TierService**

- Uses: `supabase.from('user_entitlements')`
- Auth: Implicit via RLS filtering by `user_id = auth.uid()`
- Pattern: Service receives userId as parameter, RLS validates

**3. WorkshopService**

- Uses: No direct Supabase calls (uses HybridCharacterService)
- Auth: Delegated to HybridCharacterService
- Pattern: Pure business logic, delegates data access

**4. ShopService**

- Uses: No direct Supabase calls
- Auth: Delegated to other services
- Pattern: Pure business logic

**5. FeatureAccessService**

- Uses: TierService wrapper
- Auth: Delegated to TierService
- Pattern: Authorization layer, delegates data access

### Services That DO Use Auth Methods

**BankingService (Only One)**

- Uses: `supabase.auth.getUser()` and `supabase.auth.getSession()`
- Purpose: **Debugging only** - added during Part 10 to diagnose RLS issues
- Lines: 104-114 in BankingService.ts

```typescript
// Added for debugging RLS INSERT-SELECT pattern issues
const authUser = await supabase.auth.getUser();
const session = await supabase.auth.getSession();
logger.debug('[Banking] Auth context', {
  authUserId: authUser.data.user?.id,
  paramUserId: userId,
  match: authUser.data.user?.id === userId,
  hasSession: !!session.data.session,
  hasAccessToken: !!session.data.session?.access_token,
});
```

**Why BankingService is Different:**

- Needed to diagnose why INSERT succeeded but SELECT returned null
- Logging auth context helped identify RLS policy mismatch
- Other services never needed this because they followed established patterns

---

## RLS Pattern (Established)

### How Auth Works Implicitly

**Database Level (Migration 20251014):**

```sql
-- RLS Policy for bank_accounts
CREATE POLICY "Users can view own bank accounts"
ON public.bank_accounts
FOR SELECT
USING (owner_user_id = auth.uid());

CREATE POLICY "Users can manage bank accounts for their own characters"
ON public.bank_accounts
USING (owner_user_id = auth.uid())
WITH CHECK (owner_user_id = auth.uid());
```

**Application Level:**

```typescript
// ✅ CORRECT: Let RLS handle auth filtering
const result = await supabase.from('bank_accounts').select('*').eq('character_id', characterId);
// NO .eq('owner_user_id', userId) needed - RLS filters automatically

// ❌ WRONG: Double filtering (redundant + breaks INSERT-SELECT pattern)
const result = await supabase
  .from('bank_accounts')
  .select('*')
  .eq('character_id', characterId)
  .eq('owner_user_id', userId); // ← Redundant, conflicts with RLS
```

**Why This Works:**

- Supabase automatically injects `owner_user_id = auth.uid()` into every query
- Application doesn't need to filter by owner_user_id explicitly
- RLS policies run with elevated privileges (SECURITY DEFINER)

---

## Test Mocking Patterns

### Services WITHOUT Auth Usage (Most Services)

**Pattern:** Mock `supabase.from()` only

```typescript
// Example: TierService.test.ts
const mockSupabase = {
  from: vi.fn(),
  // NO auth property needed
};
```

**Why:** Service doesn't call `supabase.auth.*` methods

### Services WITH Auth Usage (BankingService Only)

**Pattern:** Mock both `supabase.from()` and `supabase.auth`

```typescript
// BankingService.test.ts
const mockSupabase = {
  from: vi.fn(),
  auth: {
    getUser: vi.fn().mockResolvedValue({
      data: { user: { id: 'user-1' } },
      error: null,
    }),
    getSession: vi.fn().mockResolvedValue({
      data: {
        session: {
          user: { id: 'user-1' },
          access_token: 'mock-access-token',
        },
      },
      error: null,
    }),
  },
};
```

**Why:** Service calls both `supabase.auth.getUser()` and `supabase.auth.getSession()`

**Structure to Match:**

```typescript
// Supabase auth response structure
interface AuthUserResponse {
  data: {
    user: { id: string } | null;
  };
  error: Error | null;
}

interface AuthSessionResponse {
  data: {
    session: {
      user: { id: string };
      access_token: string;
    } | null;
  };
  error: Error | null;
}
```

---

## When to Add Auth Methods to Services

### ❌ Don't Add Auth Methods For:

1. **Ownership verification** - RLS handles this automatically
2. **User identification** - Pass userId as parameter, RLS validates
3. **Access control** - Use TierService/FeatureAccessService

### ✅ Do Add Auth Methods For:

1. **Debugging RLS issues** - Temporary logging to diagnose auth context
2. **Admin operations** - Service accounts, elevated privileges
3. **Auth flow management** - Login, logout, session refresh (AuthService)

**Example (Debugging Only):**

```typescript
// TEMPORARY: Remove after debugging RLS issue
const authUser = await supabase.auth.getUser();
logger.debug('Auth context for debugging', {
  authUserId: authUser.data.user?.id,
  paramUserId: userId,
  match: authUser.data.user?.id === userId,
});
```

---

## The Test Mocking Issue (What Happened)

### Root Cause

**Session Part 10:**

1. Added `supabase.auth.getSession()` call to BankingService for debugging (line 105)
2. Didn't check existing test patterns before adding
3. Test mock only had `getUser()`, missing `getSession()`
4. 5 tests started failing: "getSession is not a function"

**Session Part 11:**

1. Comprehensive review found the pattern discrepancy
2. Added missing `getSession()` mock
3. All 320 tests passing

### What Should Have Happened (Lesson 17)

**Before adding `supabase.auth.getSession()` call:**

1. Check existing test file: `src/services/BankingService.test.ts`
2. See what's in mockSupabase.auth object
3. Add getSession to mock FIRST
4. Then add getSession call to service
5. Tests pass on first run

**Pattern:**

```
Check test patterns → Update mocks → Add production code → Tests pass
```

**Not:**

```
Add production code → Tests fail → Update mocks → Tests pass
```

---

## Decision Tree: Do I Need Auth Methods?

```
┌─ Writing a new service that uses Supabase
│
├─ Does it query user-owned data (characters, inventory, bank accounts)?
│  │
│  ├─ YES → Use RLS pattern (no auth methods needed)
│  │      Pattern: Pass userId parameter, query by entity ID, let RLS filter
│  │      Example: HybridCharacterService, TierService
│  │
│  └─ NO → Continue...
│
├─ Does it need to verify current auth state for debugging?
│  │
│  ├─ YES → Add auth methods (getUser/getSession) + update test mock
│  │      Pattern: Add mock FIRST, then add service code
│  │      Example: BankingService (debugging only)
│  │
│  └─ NO → Continue...
│
└─ Does it manage auth flow (login/logout/refresh)?
   │
   ├─ YES → Auth methods required (this is AuthService)
   │      Pattern: Full auth mock with sign-in, sign-out, getSession
   │
   └─ NO → Don't add auth methods
         Pattern: Use RLS, delegate to other services
```

---

## Checklist: Adding Auth Methods to Service

If you determine auth methods are needed (rare):

- [ ] Document WHY auth methods are needed (not just for ownership checks)
- [ ] Check existing test file for mock structure
- [ ] Add auth methods to mock FIRST
- [ ] Add auth method calls to service code
- [ ] Run tests immediately (should pass on first try)
- [ ] Add comment in service explaining auth usage

**Example Comment:**

```typescript
// Auth methods used for debugging RLS INSERT-SELECT pattern
// Remove after RLS policies confirmed working in production
// See: docs/lessons-learned/21-supabase-auth-usage-patterns.md
const authUser = await supabase.auth.getUser();
```

---

## Anti-Patterns (What NOT to Do)

### ❌ Anti-Pattern 1: Auth for Ownership Checks

```typescript
// WRONG: Using auth to verify ownership
const authUser = await supabase.auth.getUser();
if (authUser.data.user?.id !== userId) {
  throw new Error('Unauthorized');
}
```

**Why Wrong:** RLS already enforces this. Redundant check.

**Correct:**

```typescript
// RIGHT: Let RLS handle ownership
const result = await supabase.from('bank_accounts').select('*').eq('character_id', characterId);
// RLS returns empty if user doesn't own character
```

### ❌ Anti-Pattern 2: Double Filtering

```typescript
// WRONG: Filtering by owner_user_id in application code
const result = await supabase
  .from('bank_accounts')
  .select('*')
  .eq('character_id', characterId)
  .eq('owner_user_id', userId); // ← RLS already filters this
```

**Why Wrong:** RLS already filters by owner_user_id. Creates double-filter mismatch and performance issues.

**Real Impact:** Caused 6-second timeout in `getTransactionHistory()` (2025-10-19).

**Correct:**

```typescript
// RIGHT: Only filter by entity ID
const result = await supabase.from('bank_accounts').select('*').eq('character_id', characterId);
// RLS adds: AND owner_user_id = auth.uid()
```

**Pattern:** Let RLS handle ALL ownership filtering. Never add `.eq('owner_user_id', userId)` or `.eq('from_owner_user_id', userId)` in application code.

### ❌ Anti-Pattern 3: INSERT Without .select() Through ProtectedSupabaseClient

```typescript
// WRONG: INSERT without .select() when using ProtectedSupabaseClient
await protectedSupabase.query(() => supabase.from('telemetry_events').insert([record]), {
  operationName: 'telemetry-insert',
});
// → Error: "Query returned null data"
```

**Why Wrong:**

- INSERT operations return `{data: null, error: null}` by design (unless you add `.select()`)
- ProtectedSupabaseClient throws error when `result.data === null` (line 189-190)
- This is NOT a Supabase error - it's expected behavior

**Real Impact:** Caused telemetry failures on every character creation (2025-10-19).

**Correct:**

```typescript
// RIGHT: Add .select() to INSERT operations
await protectedSupabase.query(() => supabase.from('telemetry_events').insert([record]).select(), {
  operationName: 'telemetry-insert',
});
// Now returns data instead of null
```

**Pattern:** All INSERTs through ProtectedSupabaseClient MUST include `.select()` to return data.

**See also:** BankingService uses `.insert({...}).select('*').single()` for transaction records (line 450).

### ❌ Anti-Pattern 4: Production Code Before Test Mocks

```typescript
// WRONG: Add auth call to service, then fix tests
// Service: BankingService.ts
const session = await supabase.auth.getSession();
// → Tests fail: "getSession is not a function"
// → Then add mock
```

**Why Wrong:** Test-driven pattern violated. Creates failing tests.

**Correct:**

```typescript
// RIGHT: Update mock first, then add service code
// Test: BankingService.test.ts
auth: {
  getUser: vi.fn().mockResolvedValue({...}),
  getSession: vi.fn().mockResolvedValue({...}), // Add this first
}

// Then add to service:
const session = await supabase.auth.getSession(); // Tests pass
```

---

## Related Lessons

- **[Lesson 17: Check Test Patterns Before Coding](17-check-test-patterns-before-coding.md)** - This issue is a perfect example
- **[Lesson 18: Follow Established Query Patterns](18-follow-established-query-patterns.md)** - RLS + Query patterns
- **[Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md)** - Check existing services first

---

## Quick Reference Card

### 🚨 CRITICAL PATTERNS (Must Follow)

**Pattern 1: INSERT with ProtectedSupabaseClient**

```typescript
// ✅ ALWAYS add .select() to INSERT
await protectedSupabase.query(() => supabase.from('table').insert([record]).select());
```

**Pattern 2: Never Double-Filter owner_user_id**

```typescript
// ✅ Let RLS handle ownership - NEVER add .eq('owner_user_id', userId)
const result = await supabase.from('table').select('*').eq('entity_id', id);
```

---

### Before Using `supabase.auth.*` Methods

1. Ask: "Why do I need this? Can RLS handle it?"
2. Check existing services - do they use auth methods?
3. If yes: Check test mock structure
4. Update mock FIRST
5. Add service code SECOND
6. Tests should pass on first run

**Default pattern (99% of services):**

- No auth methods
- RLS handles ownership
- Pass userId as parameter
- Query by entity ID only
- **NEVER filter by owner_user_id** (RLS does this)

**Exception (BankingService):**

- Auth methods for debugging only
- Mock includes getUser + getSession
- Should be removed after RLS confirmed working

---

**Remember:**

- Most services don't need auth methods - RLS is implicit
- All INSERTs need `.select()` when using ProtectedSupabaseClient
- Never add redundant owner_user_id filters - causes timeouts

---

**Session Reference:** [session-log-2025-10-19-part11-banking-comprehensive-review.md](../09-archive/session-handoffs/session-log-2025-10-19-part11-banking-comprehensive-review.md)

**User Quote:**

> "make sure you document our usage patterns that's a lesson we shouldnt repeat, thats valuable information we should add to our documentation"
