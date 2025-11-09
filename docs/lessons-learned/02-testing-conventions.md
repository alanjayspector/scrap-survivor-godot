# Lesson 02: Testing Conventions

**Category:** 🔴 Critical (Never Violate)
**Last Updated:** 2025-10-19 (Updated after critical failure)
**Sessions:** 2025-10-19 Part 2 (E2E Tests), Part 4 (Sprint 13 Wrap-up)

---

## CRITICAL RULE: Always Run Tests You Write

**Context 1:** Session 2025-10-19 Part 2, I wrote `bank-deposit.spec.ts` but didn't run it.

**Self-Assessment:**

> "I didn't run the E2E tests I wrote:
>
> - Uncertain if bank-deposit.spec.ts actually passes
> - May have syntax errors or selector issues
> - User has to debug in next session"
>
> **Grade: C-**

**Context 2:** Session 2025-10-19 Part 4, I wrote `bank-withdraw.spec.ts` and `bank-tier-upsell.spec.ts`, committed them, claimed "Sprint 13 100% Complete", and **never ran ANY of them**.

**User Feedback:**

> "Also i did not see you run ANY of the e2e tests to see if the work you did actually works.. its like all the work you just did for 09-lessons-learned just got truncated from your brain. another loss in confidence."

**Grade: F** - I violated this lesson IMMEDIATELY after documenting it.

**Lesson:** NEVER claim tests are "complete" without executing them and verifying they pass.

**This happened TWICE in one session, including after I documented it. This is systemic failure.**

**Why This Matters:**

- Untested tests may have syntax errors
- Selectors might not match actual UI
- Test logic might not match implementation
- User wastes next session debugging your work
- Breaks trust ("you said it works")

---

## The Test Execution Protocol

### Before Claiming "Done"

**Mandatory Steps:**

1. ✅ Run the test(s) you wrote
2. ✅ Verify all tests pass
3. ✅ Check for warnings/errors in output
4. ✅ Fix any failures immediately
5. ✅ Run again to confirm fix
6. ✅ Only then commit with "tests passing" claim

### Running Tests

**Unit/Integration Tests:**

```bash
npm run test                          # All tests
npm run test -- src/services/BankingService.test.ts  # Specific file
npm run test -- --watch              # Watch mode
```

**E2E Tests:**

```bash
# Use direct Playwright commands (recommended as of 2025-10-20)
npx playwright test                                    # All E2E tests
npx playwright test tests/banking/bank-deposit.spec.ts  # Single test
npx playwright test tests/banking/                     # All tests in directory
npx playwright test --project=chromium --workers=1     # Single browser, sequential (debugging)
npx playwright test --ui                              # Interactive UI mode
```

**DEPRECATED (2025-10-20):** `./scripts/test-helpers.sh`

- Replaced by direct Playwright commands and VSCode Playwright extension
- Legacy references in old session logs can be ignored
- See session-log-2025-10-20-e2e-test-fixes.md for deprecation rationale

**⚠️ CRITICAL: Use `--project=chromium --workers=1` when debugging**

When debugging E2E test failures:

- Single browser = clear error messages
- Sequential execution = no thrashing
- Full parallel suite only for final validation/CI

**NEVER:**

- ❌ Spawn multiple test runs simultaneously
- ❌ Move to next test file while current has failures
- ❌ Run all browsers in parallel when debugging

**Type Checking:**

```bash
npx tsc --noEmit                     # Check types
npx tsc --noEmit src/components/ui/BankOverlay.tsx  # Specific file
```

**Linting:**

```bash
npm run lint                         # Check all
npx eslint --fix src/components/ui/BankOverlay.tsx  # Fix specific file
```

---

## E2E Test Execution Protocol (CRITICAL)

**Context:** Session 2025-10-19 Part 5, I spawned multiple unterminated Playwright sessions, didn't check results, and thrashed for hours.

**NEVER Spawn Multiple Test Runs Simultaneously**

### The One-File-At-A-Time Protocol

```bash
# Step 1: Run ONE test file (single browser, sequential)
npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1

# Step 2: WAIT for completion (don't spawn another!)
# Look for "X passed, Y failed" in output
# Process must complete before running next command

# Step 3: If failures, read error context
cat test-results/banking-bank-deposit-*/error-context.md
# OR
ls -la test-results/ | grep banking

# Step 4: Fix based on error messages
# - Check source code for the feature
# - Verify test IDs match components
# - Check async timing issues
# - Read similar passing tests for patterns

# Step 5: Re-run SAME test to verify fix
npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1

# Step 6: Only after passing, move to next file
npx playwright test tests/banking/bank-withdraw.spec.ts --project=chromium --workers=1
```

### What NOT To Do

**❌ NEVER:**

- Spawn new test run while previous is running
- Complain about failures without reading `error-context.md`
- Fix based on stale test results (always re-run after fix)
- Move to next test file while current has failures
- Run all tests at once when implementing new feature

**Why These Are Banned:**

- Unterminated processes consume resources and hang system
- Stale results cause wrong fixes (you're debugging old code)
- Multiple simultaneous runs create confusion about which failure is which
- Can't debug 5 test files at once - fix 1 at a time systematically

### When Test Fails

**Systematic Debugging Process:**

```bash
# 1. Read the error message carefully
cat test-results/banking-bank-deposit-*/error-context.md

# 2. Common failure modes:
# - "locator.click: Target element not found"
#   → Test ID doesn't exist in component, check TEST_IDS
# - "expect(received).toBe(expected)"
#   → Assertion wrong, check actual vs expected values
# - "timeout 30000ms exceeded"
#   → Element not loading, check if overlay renders correctly

# 3. Check the actual component
cat src/components/ui/BankOverlay.tsx | grep -A 5 "data-testid"

# 4. Check similar passing test for pattern
cat tests/shop/shop-purchasing.spec.ts | grep -A 10 "should purchase"

# 5. Fix based on evidence (not guessing)

# 6. Re-run to verify fix works
./scripts/test-helpers.sh run tests/banking/bank-deposit.spec.ts
```

### After User Gives You "Ah Hah Moment" Fix

**CRITICAL: Always Re-Run Tests After Applying Fix**

**What I Did Wrong (Session 2025-10-19):**

- User pointed me to ShopOverlay pattern fix
- I applied the fix to BankOverlay
- I complained tests were still failing
- **I was looking at test results from BEFORE I applied the fix**

**What I Should Have Done:**

1. User gives fix ("copy ShopOverlay async loading pattern")
2. I apply fix to BankOverlay.tsx
3. I re-run tests: `./scripts/test-helpers.sh run tests/banking/`
4. Tests now pass (fix worked!)
5. I report: "Applied ShopOverlay pattern, tests now passing"

**NEVER trust stale test results. Always re-run after fixes.**

---

## Test Coverage Expectations

### When Writing New Features

**Minimum Requirements:**

- ✅ Unit tests for service layer (if applicable)
- ✅ Component renders without crashing (if UI component)
- ✅ E2E tests for user journeys (if user-facing feature)
- ✅ All tests passing before commit

**Example (Sprint 13 Banking):**

- `BankingService.ts` → 30 unit tests (100% coverage)
- `BankOverlay.tsx` → Renders in Storybook
- `bank-deposit.spec.ts` → 4 E2E tests covering deposit flows

### When Refactoring

**Minimum Requirements:**

- ✅ All existing tests still pass
- ✅ No regressions in test count
- ✅ Type checking passes
- ✅ Linting passes (0 errors)

**Example (Sprint 12 Workshop Refactor):**

- Started: 291 tests passing
- After refactor: 291 tests passing
- Verified: No new TypeScript errors

---

## E2E Test Development Best Practices

### CRITICAL: Pattern Analysis First

**Before writing OR fixing E2E tests, ALWAYS:**

1. **Find similar PASSING tests first** - Never write/fix from scratch
2. **Compare working patterns** - Understand why they work
3. **Identify component requirements** - What props/state do overlays need?
4. **Check common helpers** - seedCharacter, setUserTier, etc.

**Why This Matters:**

- Prevents reinventing existing patterns
- Identifies copy-paste bugs (e.g., missing props)
- Saves 30-60 minutes of debugging time
- Ensures consistency across test suite

### Pattern Analysis Workflow

**When debugging E2E test failure:**

```bash
# Step 1: Read error screenshot/context
cat test-results/*/error-context.md

# Step 2: Find PASSING similar test
ls tests/shop/     # If debugging bank, check shop
ls tests/banking/  # Find passing tests in same category

# Step 3: Compare patterns side-by-side
# Example: bank-deposit FAILING vs shop-purchasing PASSING

# Step 4: Look for differences
# - Missing imports?
# - Different helper usage?
# - Missing props to overlay managers?
# - Different beforeEach/afterEach setup?

# Step 5: Apply working pattern to failing test
```

**Real Example (Session 2025-10-20):**

```bash
# FAILING: bank-deposit.spec.ts showing currency=0
# PASSING: shop-purchasing.spec.ts showing currency correctly

# Pattern comparison revealed:
# ShopOverlayManager.show({ character: {...}, onClose: ... })  ✅
# BankOverlayManager.show({ onClose: ... })  ❌ Missing character prop!

# Fix: Copy Shop pattern to Bank
```

### Common E2E Test Pitfalls

**Pitfall #1: Overlay Manager Props**

**Problem:** Copy-paste bug where required props are omitted

**How to Detect:**

```bash
# Compare overlay manager calls
grep -A 5 "ShopOverlayManager.*show" src/utils/testHarness.ts
grep -A 5 "BankOverlayManager.*show" src/utils/testHarness.ts

# Look for missing props (character, shopItems, etc.)
```

**Fix Pattern:**

```typescript
// ✅ CORRECT (Shop pattern)
ShopOverlayManager.getInstance().show({
  character: { ...store.currentCharacter! },
  shopItems: items,
  onClose: () => ShopOverlayManager.getInstance().hide(),
});

// ❌ WRONG (Copy-paste bug)
BankOverlayManager.getInstance().show({
  onClose: () => BankOverlayManager.getInstance().hide(),
  // Missing: character prop!
});

// ✅ FIXED (Apply Shop pattern)
BankOverlayManager.getInstance().show({
  character: { ...store.currentCharacter! }, // ← ADD THIS
  onClose: () => BankOverlayManager.getInstance().hide(),
});
```

**Pitfall #2: Root Cause vs Symptoms**

**Problem:** Fixing symptoms (tier gates, validation) before understanding root cause

**Wrong Approach:**

1. Test shows tier gate blocking access → Add setUserTier() ✅
2. Still failing with currency=0 → Add more waits ❌
3. Still failing → Try different order ❌
4. Give up, ask user ❌

**Correct Approach:**

1. Read error screenshot → Currency shows as 0
2. Trace data flow → BankDepositTab gets currentScrap from character prop
3. Check where character comes from → BankOverlay receives as prop
4. Check who calls BankOverlay → testHarness.showBankOverlay()
5. Compare with working pattern → Shop passes character, Bank doesn't
6. Fix root cause → Add character prop
7. Test passes ✅

**Protocol:**

```markdown
When E2E test shows wrong data (currency=0, items missing, etc.):

1. **Trace data flow first** (UI ← Component ← Overlay ← Manager ← Test Harness)
2. **Compare with passing similar test**
3. **Identify exact difference**
4. **Fix root cause, not symptoms**
5. **Verify fix with re-run**
```

---

## E2E Testing Patterns

### Reading Required Materials

**Before writing E2E tests, read:**

1. `docs/testing/playwright-guide.md` - Conventions, patterns
2. `tests/fixtures/` - Available helpers (auth, navigation, test harness)
3. Similar existing tests - Pattern reference

**Example from Session:**

```
I read:
✅ docs/testing/playwright-guide.md
✅ tests/shop/shop-purchasing.spec.ts (reference pattern)
✅ tests/fixtures/test-harness.ts (available helpers)

This gave me the right patterns for bank-deposit.spec.ts
```

### Test Structure Pattern

**Standard Pattern (follows shop-purchasing.spec.ts):**

```typescript
import { test, expect } from '@playwright/test';
import { signInTestUser } from '../fixtures/auth-helpers';
import { selectFirstCharacter, navigateToBank, closeOverlay } from '../fixtures/navigation-helpers';
import { seedCharacter, setBankBalance } from '../fixtures/test-harness';
import { TEST_IDS } from '../../src/testing/testIds';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await signInTestUser(page);
    await selectFirstCharacter(page);
  });

  test.afterEach(async ({ page }) => {
    await closeOverlay(page);
  });

  test('should do something specific', async ({ page }) => {
    // Arrange: Set up test data
    await seedCharacter(page, { currency: 5000 });

    // Act: Perform user action
    await navigateToBank(page);

    // Assert: Verify expected outcome
    await expect(page.getByTestId(TEST_IDS.ui.bank.overlay)).toBeVisible();
  });
});
```

### Key Principles

**1. Use Test IDs (Not CSS Selectors)**

```typescript
// ✅ Good: Reliable, semantic
page.getByTestId(TEST_IDS.ui.bank.depositButton);

// ❌ Bad: Brittle, breaks with styling changes
page.locator('.bank-overlay .deposit-button');
```

**2. Use Test Harness Helpers**

```typescript
// ✅ Good: Uses offline test harness
await seedCharacter(page, { currency: 5000 });
await setBankBalance(page, characterId, 1000);

// ❌ Bad: Tries to call real Supabase
await page.evaluate(() => {
  fetch('/api/characters/update', { ... })
});
```

**3. Defensive Assertions**

```typescript
// ✅ Good: Works regardless of UX implementation
const isDisabled = await button.isDisabled().catch(() => false);
if (!isDisabled) {
  await button.click();
  await expect(page.getByText(/error pattern/i)).toBeVisible();
} else {
  expect(isDisabled).toBe(true);
}

// ❌ Bad: Assumes specific implementation
await expect(button).toBeDisabled();
```

**Why Defensive?** UI might disable button OR show error message. Test works either way.

**4. CRITICAL: Understand Playwright Parallel Execution**

**Problem Discovered (Session 2025-10-19 Part 6):**

When running `./scripts/test-helpers.sh run tests/banking/bank-deposit.spec.ts`, Playwright does NOT run "one test":

```typescript
// playwright.config.ts
fullyParallel: true,  // Tests run in parallel
workers: undefined,   // Uses all CPU cores
projects: [
  { name: 'chromium' },
  { name: 'Mobile Chrome' },
  { name: 'Mobile Safari' },
]
```

**What actually happens:**

- Spawns 3 SIMULTANEOUS test runs (one per browser project)
- Each test file runs 3 times in parallel
- Mixed error messages from 3 different contexts
- Exactly the "thrashing" behavior from Lesson 08

**How to prevent thrashing:**

```bash
# ❌ BAD: Spawns 3 parallel browser contexts
npx playwright test tests/banking/bank-deposit.spec.ts

# ✅ GOOD: Single browser, sequential execution
npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1
```

**Why this matters:**

When debugging E2E test failures:

- Need clear error messages from ONE browser
- Need to fix and re-run in same environment
- Parallel execution = mixed errors = thrashing
- Sequential execution = clear diagnosis = fast fixes

**Sr SQA Insight:** Always run E2E tests with `--project=chromium --workers=1` during development/debugging. Only run full parallel suite (all browsers) during final validation or CI.

**Commands:**

```bash
# ❌ BAD: Spawns 3 parallel browser contexts
npx playwright test tests/banking/bank-deposit.spec.ts

# ✅ GOOD: Single browser, sequential execution
npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1
```

**5. Generous Timeouts**

```typescript
// ✅ Good: Accounts for Phaser/Supabase initialization
await page.getByTestId(TEST_IDS.ui.bank.overlay).waitFor({ timeout: 10000 });

// ❌ Bad: Default 5s timeout may be too short
await page.getByTestId(TEST_IDS.ui.bank.overlay).waitFor();
```

---

## Common Test Failures

### Failure Mode 1: Selector Not Found

**Error:**

```
Error: locator.click: Target element not found
```

**Causes:**

- Test ID doesn't exist in UI component
- Component not rendered yet (need `waitFor`)
- Test harness not properly initialized

**Fix:**

```typescript
// 1. Verify test ID exists in component
const depositButton = page.getByTestId(TEST_IDS.ui.bank.depositButton);

// 2. Wait for element
await depositButton.waitFor({ timeout: 10000 });

// 3. Then interact
await depositButton.click();
```

### Failure Mode 2: Test Harness Unavailable

**Error:**

```
Error: Test harness unavailable. Ensure dev server is running in test mode.
```

**Causes:**

- Dev server not running with `VITE_TEST_MODE=true`
- Wrong URL (not localhost:5173)
- Test harness not initialized in main.tsx

**Fix:**

```bash
# Run dev server in test mode
VITE_TEST_MODE=true npm run dev

# Run tests in separate terminal
./scripts/test-helpers.sh run tests/banking/bank-deposit.spec.ts
```

### Failure Mode 3: Race Conditions

**Error:**

```
Error: expect(received).toBe(expected)
Expected: 4000
Received: 5000
```

**Causes:**

- Assertion ran before async operation completed
- UI update not yet reflected in game store
- Transaction not yet processed

**Fix:**

```typescript
// ❌ Bad: Immediate assertion
await depositButton.click();
const currency = await getCurrency(page);
expect(currency).toBe(4000);

// ✅ Good: Wait for expected state
await depositButton.click();
await page.waitForTimeout(1000); // Allow transaction to complete
const currency = await getCurrency(page);
expect(currency).toBe(4000);

// ✅ Better: Wait for specific condition
await depositButton.click();
await expect(async () => {
  const currency = await getCurrency(page);
  expect(currency).toBe(4000);
}).toPass({ timeout: 5000 });
```

---

## Test-Driven Development Pattern

### Ideal Flow (When Possible)

1. **Write failing test first**

   ```bash
   npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1
   # FAIL: depositButton not found
   ```

2. **Add test ID to component**

   ```tsx
   <button data-testid={TEST_IDS.ui.bank.depositButton}>Deposit</button>
   ```

3. **Run test again**

   ```bash
   npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1
   # PASS: All tests passed
   ```

4. **Commit with test results**

   ```bash
   git add src/components/ui/BankDepositTab.tsx tests/banking/bank-deposit.spec.ts
   git commit -m "feat(banking): add deposit tab with e2e tests

   Tests: 4/4 passing
   - Display bank overlay with deposit tab
   - Allow premium user to deposit scrap
   - Prevent deposit exceeding per-character cap
   - Show insufficient scrap error"
   ```

---

## Storybook Integration

**User Requirement (Session 2025-10-19):**

> "make sure storybook is integrated also"

**Lesson:** When user says "make sure X is integrated", X is non-negotiable.

### When to Create Storybook Stories

**Always create stories for:**

- ✅ New UI components (overlays, tabs, modals)
- ✅ Components with multiple states (loading, error, success)
- ✅ Components with tier-specific variations
- ✅ Complex interactions (forms, multi-step flows)

**Example (Sprint 13 - I MISSED THIS):**

- Created: `BankOverlay.tsx`, `BankDepositTab.tsx`, `BankWithdrawTab.tsx`
- Should have created: `BankOverlay.stories.tsx`
- Scenarios needed:
  - Premium user with 0 balance
  - Premium user with 5000 balance
  - Premium user near cap (9500/10000)
  - Free tier blocked state
  - Subscription tier with high balance

### Story Pattern

```typescript
// src/components/ui/BankOverlay.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { BankOverlay } from './BankOverlay';

const meta: Meta<typeof BankOverlay> = {
  title: 'UI/BankOverlay',
  component: BankOverlay,
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<typeof BankOverlay>;

export const PremiumWithBalance: Story = {
  args: {
    // Component props here
  },
};

export const FreeTierBlocked: Story = {
  args: {
    // Component props here
  },
};
```

### Running Storybook

```bash
npm run storybook  # Starts on http://localhost:6006
```

---

## Test Harness Patterns

### Window-Scoped Storage

**Pattern:** Store mocked data on window object for test access

```typescript
// src/utils/testHarness.ts
public setBankBalance(characterId: string, balance: number): void {
  const key = `__TEST_BANK_BALANCE_${characterId}__`;
  (window as any)[key] = balance;
}

public getBankBalance(characterId: string): number | undefined {
  const key = `__TEST_BANK_BALANCE_${characterId}__`;
  return (window as any)[key];
}
```

**Why This Pattern:**

- Consistent with existing shop/workshop helpers
- Simple to implement (no complex mocking)
- Works in offline harness mode
- Easy to clear between tests

### Test Fixture Wrappers

**Pattern:** Provide Playwright-friendly wrappers for harness methods

```typescript
// tests/fixtures/test-harness.ts
export const setBankBalance = async (page: Page, characterId: string, balance: number) => {
  await page.evaluate(
    ({ charId, bal }) => {
      const harness = (window as HarnessWindow).__SCRAP_TEST_HARNESS__;
      if (!harness) {
        throw new Error('Test harness unavailable.');
      }
      harness.setBankBalance(charId, bal);
    },
    { charId: characterId, bal: balance }
  );
};
```

**Why Wrappers:**

- Playwright's `page.evaluate()` requires serialization
- Wrappers handle type safety and error messages
- Tests import clean functions, not complex evaluation code

---

## Mobile-First Testing

**This project tests on mobile viewports by default:**

```typescript
// playwright.config.ts
projects: [
  {
    name: 'mobile-chrome',
    use: { ...devices['Pixel 5'] },
  },
  {
    name: 'mobile-safari',
    use: { ...devices['iPhone 12'] },
  },
];
```

### Touch Target Requirements

**Minimum size:** 44x44px (iOS/Android guideline)

**Test for:**

- Buttons are tappable on mobile
- Overlays fill screen appropriately
- Text is readable on small screens
- No horizontal scrolling required

---

## Test Documentation Requirements

### In Commit Messages

**Always include test results:**

```bash
git commit -m "feat(banking): add deposit functionality

Tests: 320/321 passing (1 skipped)
- BankingService: 29/30 passing
- E2E deposit: 4/4 passing
- All existing tests: No regressions

Skipped: rollback test (death protection refactored to messaging-only)"
```

### In Session Logs

**Document test execution:**

````markdown
## Testing

**Test Results:**

- Unit Tests: ✅ 320/321 passing (1 skipped)
- E2E Tests: ✅ 4/4 passing
- TypeScript: ✅ Clean compilation
- ESLint: ✅ 0 errors

**Commands Run:**

```bash
npm run test        # 320/321 passing
npx playwright test tests/banking/bank-deposit.spec.ts --project=chromium --workers=1  # 4/4 passing
npx tsc --noEmit    # 0 errors
```
````

**Skipped Tests:**

- `BankingService.test.ts` - rollback test no longer applicable

````

---

## What "All Tests Passing" Means

### Minimum Bar

When claiming "all tests passing", you must have run:

1. ✅ **Unit/Integration Tests**
   ```bash
   npm run test
   # All tests passing (or document skipped tests with reason)
````

2. ✅ **Type Checking**

   ```bash
   npx tsc --noEmit
   # No new type errors (pre-existing warnings OK if documented)
   ```

3. ✅ **Linting**

   ```bash
   npm run lint
   # 0 errors (warnings OK if acceptable)
   ```

4. ✅ **E2E Tests (if you wrote them)**
   ```bash
   npx playwright test tests/banking/ --project=chromium --workers=1
   # All new E2E tests passing
   ```

### Acceptable Exceptions

**Skipped Tests:**

- Document reason in commit message
- Ensure skip is intentional (not commented out to hide failure)

**Pre-Existing Warnings:**

- TypeScript warnings from other files (not your changes)
- ESLint warnings (user accepts 70 warnings as baseline)

**Acceptable Warning Example:**

```
react-refresh warning: DeathModalManager export
Reason: Singleton pattern requires export, acceptable trade-off
```

---

## Summary

**NEVER claim tests are complete without running them.**

**The Protocol:**

1. Write test
2. Run test
3. Verify it passes
4. Fix failures immediately
5. Run again to confirm
6. Document results in commit
7. Only then claim "done"

**User expects:**

- Tests you write actually work
- No debugging your work in next session
- Confidence in "all tests passing" claims

**My responsibility:**

- Run tests before committing
- Fix failures immediately
- Document test results accurately
- Never assume tests work without verification

---

## Related Lessons

- [03-user-preferences.md](03-user-preferences.md) - Token management, session wrap-up

## E2E Banking Test Patterns (Session 2025-10-20)

**Context:** Fixed 4/4 bank-deposit E2E tests after discovering multiple mocking and reactive state issues.

### Pattern: Mock getOrCreateAccount, Not getAccount

**Discovery:** useBankAccount hook calls `BankingService.getOrCreateAccount()`, not `getAccount()`.

**Evidence:** Session 2025-10-20 - Balance showed 0 instead of 9500 because mock targeted wrong method.

**Correct Pattern:**

```typescript
// testHarness.ts - mockBankingOperations()
BankingService.getOrCreateAccount = async (characterId: string, userId: string) => {
  const balanceKey = `__TEST_BANK_BALANCE_${characterId}__`;
  const balance = (window as any)[balanceKey] ?? 0;

  return {
    id: `mock-account-${characterId}`,
    character_id: characterId,
    owner_user_id: userId,
    balance, // From window state set by test
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
};
```

**Why It Matters:**

- useBankAccount.refreshAccount() runs on mount → calls getOrCreateAccount
- If wrong method mocked, balance reads from real DB (likely 0)
- Test's setBankBalance() sets window state that mock should read

### Pattern: Tier Reading from Game Store

**Discovery:** User tier must be read from `store.user.current_tier` or `store.user.tier`, not `store.userTier`.

**Evidence:** Session 2025-10-20 - Toast showed "cap of 0 scrap" because tier defaulted to 'free'.

**Correct Pattern:**

```typescript
// Read tier with fallback chain
const tier = store.user?.current_tier || store.user?.tier || 'free';
```

**Why It Matters:**

- gameStore.setUserTier() updates both `user.tier` and `user.current_tier`
- `store.userTier` doesn't exist - was incorrect assumption
- Wrong tier → wrong balance caps → validation failures

### Pattern: Button Disabled State for Amount Validation

**Discovery:** Deposit button must check if specific amount exceeds maxDeposit, not just general canDeposit flag.

**Evidence:** Session 2025-10-20 - Test expected button disabled when 1000 + 9500 > 10000 cap, but button was enabled.

**Correct Pattern:**

```typescript
// BankDepositTab.tsx
const maxDeposit = Math.min(currentScrap, balanceCaps.perCharacter - currentBalance);

<button
  disabled={
    !canDeposit ||
    isDepositing ||
    !depositAmount ||
    parseInt(depositAmount, 10) <= 0 ||
    parseInt(depositAmount, 10) > maxDeposit  // ← CRITICAL CHECK
  }
>
  Deposit Scrap
</button>
```

**Why It Matters:**

- `canDeposit` is general (can user deposit at all?)
- Specific amount check needed (would THIS amount exceed cap?)
- Better UX than allowing click then showing error

### Pattern: Reactive Currency in Overlays

**Discovery:** BankOverlay receives character as prop, but currency needs Zustand selector for reactive updates.

**Evidence:** Session 2025-10-20 - Currency didn't update after deposit because prop wasn't reactive.

**Correct Pattern:**

```typescript
// BankOverlay.tsx
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  // Character prop provides initial data
  // BUT currency needs reactive subscription for updates
  const currentCurrency = useGameStore(
    (state) => state.currentCharacter?.currency ?? character.currency
  );

  // Pass reactive currency to child components
  return <BankDepositTab currentScrap={currentCurrency} />;
};
```

**Why It Matters:**

- Follows GlobalHeader pattern for reactive currency display
- Character prop gives initial values (ID, name, stats)
- Zustand selector watches for currency changes from deposits/withdraws
- Without selector, UI shows stale currency after operations

### Pattern: Screenshot-Driven Debugging

**Discovery:** E2E test screenshots reveal exact validation errors and state mismatches.

**Evidence:**

- Screenshot showed toast: "Deposit would exceed per-character cap of 0 scrap" → revealed tier bug
- Screenshot showed balance: "0 / 10,000 scrap" instead of "9,500 / 10,000" → revealed wrong method mocked

**Pattern:**

```bash
# Read screenshot from failed test
cat test-results/.../test-failed-1.png

# Look for:
1. Toast error messages (reveal validation logic bugs)
2. Display values (reveal mock/state issues)
3. Button states (reveal disabled logic bugs)
```

**Why It Matters:**

- Visual evidence > reading code assumptions
- Toast messages show EXACT error strings from validation
- Balance displays show whether mocks are working
- Button states show whether disabled logic is correct

## Resources

- [docs/testing/playwright-guide.md](/home/alan/projects/scrap-survivor/docs/testing/playwright-guide.md)
- [tests/fixtures/](/home/alan/projects/scrap-survivor/tests/fixtures/)
- [scripts/test-helpers.sh](/home/alan/projects/scrap-survivor/scripts/test-helpers.sh)
- [24-context-rollover-resilience.md](24-context-rollover-resilience.md) - Git commit post-rollover checklist

## Session References

- [session-log-2025-10-19-part2-e2e-tests.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part2-e2e-tests.md)
- Session 2025-10-20: E2E banking test fixes (4/4 tests passing)
