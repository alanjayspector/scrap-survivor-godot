# Lesson 17: Check Existing Test Patterns Before Writing Code

**Date:** 2025-10-19 (Session Part 10 - Banking Sprint)
**Category:** 🔴 Critical (Code Quality)
**Session:** [session-log-2025-10-19-part10-bank-duplicate-rows.md](../09-archive/session-handoffs/session-log-2025-10-19-part10-bank-duplicate-rows.md)

---

## What Happened

Added `supabase.auth.getUser()` call to BankingService for debugging without checking how tests mock the Supabase client.

**Result:**

```
TypeError: Cannot read properties of undefined (reading 'getUser')
 ❯ Function.getOrCreateAccount src/services/BankingService.ts:104:44
```

**5 tests failed** because mockSupabase didn't have an `auth` property.

---

## Root Cause

1. Wrote production code that calls `supabase.auth.getUser()`
2. Did not check existing test files to see how mockSupabase is structured
3. Assumed tests would work without verifying mock structure
4. Tests failed immediately on first run

**Time Lost:** 15 minutes fixing tests that should have worked first try

---

## The Right Way

### BEFORE writing code that uses new Supabase APIs:

1. **Check existing test files:**

   ```bash
   # Find similar test patterns
   grep -r "mockSupabase" src/services/*.test.ts
   ```

2. **Review mock structure:**

   ```typescript
   // BankingService.test.ts:4-6 (OLD)
   const mockSupabase = {
     from: vi.fn(),
   };

   // TierService.test.ts:4-6 (COMPARISON)
   const mockSupabase = {
     from: vi.fn(),
   };
   // ← No auth property in either!
   ```

3. **Add mock BEFORE writing production code:**

   ```typescript
   // BankingService.test.ts:4-11 (CORRECT)
   const mockSupabase = {
     from: vi.fn(),
     auth: {
       getUser: vi.fn().mockResolvedValue({
         data: { user: { id: 'user-1' } },
         error: null,
       }),
     },
   };
   ```

4. **Write production code:**

   ```typescript
   // BankingService.ts:104
   const authUser = await supabase.auth.getUser();
   logger.debug('[Banking] Auth context', {
     authUserId: authUser.data.user?.id,
     paramUserId: userId,
   });
   ```

5. **Run tests to verify:**
   ```bash
   npm run test -- --run src/services/BankingService.test.ts
   ```

---

## Checklist: Before Using New Supabase APIs

- [ ] Search for similar API usage in existing tests
- [ ] Check how those tests mock the API
- [ ] Add mock to test file FIRST
- [ ] Write production code SECOND
- [ ] Run tests to verify mock works
- [ ] Only then proceed with implementation

---

## Test Pattern Reference

### Current Mock Structure (as of 2025-10-19)

```typescript
// Standard mockSupabase structure
const mockSupabase = {
  from: vi.fn(), // ✅ All tests use this
  auth: {
    // ✅ Only BankingService needs this
    getUser: vi.fn(),
  },
};
```

### Test Files Using Supabase Mocks

1. **BankingService.test.ts** - Uses `from` and `auth.getUser()`
2. **TierService.test.ts** - Uses only `from`
3. **HybridCharacterService.test.ts** - Uses only `from`
4. **WorkshopService.test.ts** - No direct Supabase mocking (uses service mocks)

---

## Why This Matters

**User's Perspective:**

> "instead you ignored it all and yet again wrote a bunch of code before understanding our tried and tested patterns"

**Impact:**

- Tests fail on first run (breaks CI)
- Wastes time debugging test infrastructure
- Shows lack of care for existing patterns
- Delays actual feature work

**The Pattern:**

1. Tests tell you how code is used
2. Tests show you what APIs are available
3. Tests document expected behavior
4. **Check tests BEFORE writing production code**

---

## Related Lessons

- **[Lesson 14: Established Patterns Are Documentation](14-established-patterns-documentation.md)** - Migration files and code ARE documentation
- **[Lesson 18: Follow Established Query Patterns](18-follow-established-query-patterns.md)** - Check how other services use Supabase
- **[Lesson 20: User Documentation Tells the Truth](20-user-documentation-tells-truth.md)** - Reading ≠ Following

---

## Red Flags (Stop and Check Tests)

🚩 About to call a new Supabase API (`auth`, `storage`, `functions`, etc.)
🚩 Adding a new dependency or import
🚩 Using a new method on existing mock
🚩 Writing code that interacts with external services
🚩 Any time you think "I hope this works in tests"

**If you see a red flag → Check tests FIRST, write code SECOND**

---

**Remember:** Tests are documentation. Read them before writing code that depends on them.
