# Lesson 08: DRY Principle - Never Reinvent Existing Patterns

**Category:** 🔴 Critical (Never Violate)
**Last Updated:** 2025-10-19
**Sessions:** Session 2025-10-19 Part 5 (Recovery from E2E thrashing failure)

---

## CRITICAL RULE: Always Copy Existing Patterns, Never Invent

**Context:** Session 2025-10-19, I reinvented solutions that already existed in the codebase, wasting hours and creating bugs that were already solved.

**User Feedback:**

> "you failed to check source code and documentation you invited shit up again and wrote your own direct calls to supabase instead of using our bullet proof supabase client"

> "i cant emphasize this enough .. in terms of implementation alot of future roadmap will be exactly like Shop and now Banking you cant ignore our code base and conventions and make shit up especially when we are establishing clear easy to follow patterns for future work."

> "you know as a sr staff software engineer that software development is all about pattern recognition and and being able to apply like for like. you did none of these things."

**Lesson:** Software engineering is pattern recognition. This codebase has established patterns. Copy them. Don't invent.

---

## The Catastrophic Failure (Session 2025-10-19)

### What I Did Wrong

**Failure 1: Reinvented Supabase Error Handling**

I wrote direct `supabase.from()` calls with custom timeout/error handling.

**What Already Existed:**

- `ProtectedSupabaseClient.ts` - 390 lines of battle-tested async protection
- Circuit breaker pattern
- Request deduplication
- Optimistic UI updates
- AbortController
- Exponential backoff
- Adaptive timeouts based on latency history

**9 other services already using `protectedSupabase` successfully.**

**DRY Violation Severity:** Extreme. I reinvented 390 lines that already existed.

---

**Failure 2: Reinvented Async Loading Pattern**

I wrote `BankOverlay.tsx` from scratch with custom loading states.

**What Already Existed:**

- `ShopOverlay.tsx` - Perfect async loading pattern
- Race condition prevention
- Loading/error state handling
- Graceful degradation

**Pattern Recognition Failure:** Banking and Shopping are IDENTICAL flows:

1. Navigate from hub
2. Async data fetch
3. Render overlay with data
4. Handle loading/error states

**I should have copied ShopOverlay line-by-line.**

---

**Failure 3: Reinvented E2E Test Structure**

I wrote banking E2E tests without reading existing shop E2E tests.

**What Already Existed:**

- `tests/shop/*.spec.ts` - Established E2E conventions
- Test harness helper patterns
- Navigation helper patterns
- Defensive assertion patterns

**I should have copied shop tests and changed domain logic only.**

---

## The DRY Protocol (MANDATORY)

### Before Writing ANY New Code

**Step 1: Search for Similar Implementations**

```bash
# Adding new hub feature overlay?
find src/components/ui -name "*Overlay.tsx"
# Result: ShopOverlay.tsx, InventoryOverlay.tsx, WorkshopOverlay.tsx

# Adding new service?
ls src/services/*.ts
# Check which ones are most similar

# Adding new E2E test?
find tests -name "*.spec.ts" | head -10
# Find most similar test suite

# Adding Supabase operations?
grep -r "protectedSupabase" src/services/
# See how ALL services use ProtectedSupabaseClient
```

**Step 2: Read the Most Similar Implementation**

```bash
# For Bank feature, Shop is most similar
cat src/services/ShopService.ts          # How to use ProtectedSupabaseClient
cat src/components/ui/ShopOverlay.tsx    # How to handle async loading
cat tests/shop/shop-purchasing.spec.ts   # How to structure E2E tests
cat src/utils/testHarness.ts             # Check showShopOverlay pattern
```

**Step 3: Copy the Pattern EXACTLY**

```typescript
// ❌ WRONG: Invent new Supabase error handling
const { data, error } = await supabase.from('bank_accounts').select('*').timeout(5000); // Custom timeout logic

if (error) {
  // Custom error handling
}

// ✅ RIGHT: Copy ProtectedSupabaseClient pattern from ShopService
import { protectedSupabase } from './ProtectedSupabaseClient';

const account = await protectedSupabase.query(() => supabase.from('bank_accounts').select('*'), {
  timeout: 6000,
  operationName: 'bank-get-account',
  optimistic: cachedAccount, // Pattern from ShopService
});
```

**Step 4: Change ONLY Domain Logic**

```typescript
// Copy ShopOverlay.tsx async loading pattern
// Change ONLY:
// - "shop" → "bank"
// - ShopService → BankingService
// - shop_reroll_state → bank_accounts
// - Domain-specific UI (shop items vs bank balance)

// Keep IDENTICAL:
// - Loading state handling
// - Error state handling
// - useEffect structure
// - Async flow
```

---

## Universal Patterns in This Codebase

### Pattern 1: All Services Use ProtectedSupabaseClient

**NEVER use direct `supabase` imports in services.**

```typescript
// ❌ BANNED
import { supabase } from '@/config/supabase';
const { data } = await supabase.from('table').select('*');

// ✅ REQUIRED
import { protectedSupabase } from './ProtectedSupabaseClient';
const data = await protectedSupabase.query(() => supabase.from('table').select('*'), {
  timeout: 6000,
  operationName: 'meaningful-name',
});
```

**Services using this pattern (as of 2025-10-19):**

- ShopService
- BankingService
- TelemetryService
- RepairService
- RecyclerService
- ShopRerollService
- perksService
- workshop/utils/workshopStorage

**Count: 8+ services**

**If you're the 9th service, you MUST use the same pattern.**

---

### Pattern 2: All Hub Overlays Handle Async Loading

**NEVER invent custom loading patterns.**

```typescript
// ✅ Universal Hub Overlay Pattern (from ShopOverlay.tsx)
const HubOverlay = ({ onClose }) => {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState(null);

  useEffect(() => {
    ServiceClass.fetchData()
      .then(setData)
      .catch((err) => setError(err.message))
      .finally(() => setIsLoading(false));
  }, [dependencies]);

  // Loading state
  if (isLoading) {
    return <LoadingSpinner message="Loading..." />;
  }

  // Error state
  if (error) {
    return <ErrorMessage message={error} onRetry={() => window.location.reload()} />;
  }

  // Success state
  return <ActualUI data={data} onClose={onClose} />;
};
```

**Overlays using this pattern:**

- ShopOverlay
- BankOverlay (after fix)
- WorkshopOverlay
- InventoryOverlay

**Future overlays that WILL use this pattern:**

- BarracksOverlay
- MarketplaceOverlay
- GuildHallOverlay

---

### Pattern 3: All Manager Singletons Follow Same Structure

```typescript
// ✅ Universal Manager Pattern (from WaveCompleteModalManager)
class FeatureManager {
  private static instance: FeatureManager;
  private root: Root | null = null;
  private container: HTMLDivElement | null = null;

  private constructor() {
    // Private constructor
  }

  static getInstance(): FeatureManager {
    if (!this.instance) {
      this.instance = new FeatureManager();
    }
    return this.instance;
  }

  show(props: FeatureProps): void {
    if (!this.container) {
      this.container = document.createElement('div');
      document.body.appendChild(this.container);
      this.root = createRoot(this.container);
    }
    this.root.render(<FeatureComponent {...props} />);
  }

  hide(): void {
    if (this.root && this.container) {
      this.root.unmount();
      document.body.removeChild(this.container);
      this.root = null;
      this.container = null;
    }
  }
}

export const featureManager = FeatureManager.getInstance();
```

**Managers using this pattern:**

- WaveCompleteModalManager
- ShopOverlayManager
- BankOverlayManager
- WorkshopOverlayManager
- DeathModalManager

---

### Pattern 4: All E2E Tests Follow Same Structure

```typescript
// ✅ Universal E2E Test Pattern (from shop-purchasing.spec.ts)
import { test, expect } from '@playwright/test';
import { signInTestUser } from '../fixtures/auth-helpers';
import {
  selectFirstCharacter,
  navigateToFeature,
  closeOverlay,
} from '../fixtures/navigation-helpers';
import { seedCharacter } from '../fixtures/test-harness';
import { TEST_IDS } from '../../src/testing/testIds';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await signInTestUser(page);
    await selectFirstCharacter(page);
  });

  test.afterEach(async ({ page }) => {
    await closeOverlay(page);
  });

  test('should do specific thing', async ({ page }) => {
    // Arrange: Set up test data
    await seedCharacter(page, { currency: 5000 });

    // Act: Perform user action
    await navigateToFeature(page);

    // Assert: Verify expected outcome
    await expect(page.getByTestId(TEST_IDS.ui.feature.overlay)).toBeVisible();
  });
});
```

**E2E tests following this pattern:**

- tests/shop/\*.spec.ts
- tests/banking/\*.spec.ts (after rewrite)
- tests/inventory/\*.spec.ts
- tests/workshop/\*.spec.ts

---

## How to Recognize When to Copy vs. Invent

### ✅ COPY (99% of the time)

**Copy when:**

- Adding new hub feature (copy Shop)
- Adding new service (copy existing service + ProtectedSupabaseClient)
- Adding new E2E tests (copy existing E2E tests)
- Adding new overlay (copy ShopOverlay)
- Adding new manager (copy existing manager)
- Adding Supabase operations (use ProtectedSupabaseClient)
- Adding async operations (copy async patterns)

**Copy signs:**

- "I'm adding a Bank feature" → Shop exists, copy it
- "I'm adding inventory tests" → Shop tests exist, copy them
- "I'm calling Supabase" → ProtectedSupabaseClient exists, use it

---

### 🚨 INVENT (1% of the time, get approval first)

**Invent ONLY when:**

- Building entirely new system (no similar code exists)
- User explicitly requests new approach
- Existing pattern is proven broken (with evidence)

**Invent process:**

1. Search exhaustively for existing patterns
2. Document why existing patterns don't fit
3. Propose new pattern to user
4. Get explicit approval
5. THEN implement

**Example:**

```
"I need to implement real-time websocket sync. We don't have any websocket
code in the codebase. I propose using Supabase Realtime with this approach:
[detailed plan]. Should I proceed or is there an existing pattern I missed?"
```

---

## The Shop/Bank/Hub Feature Universal Pattern

**CRITICAL:** All future hub features will follow Shop/Bank pattern.

### Complete Implementation Checklist

**Before writing code:**

- [ ] Read `ShopService.ts` (service pattern)
- [ ] Read `ShopOverlay.tsx` (overlay pattern)
- [ ] Read `tests/shop/*.spec.ts` (E2E pattern)
- [ ] Read `src/utils/testHarness.ts` (test helper pattern)

**Service Layer:**

- [ ] Import `protectedSupabase` (not direct `supabase`)
- [ ] Copy ShopService async operation pattern
- [ ] Use meaningful `operationName` for logging
- [ ] Handle errors via ProtectedSupabaseClient (not custom try/catch)

**Overlay Layer:**

- [ ] Copy ShopOverlay async loading pattern
- [ ] useState for loading/error/data
- [ ] useEffect for data fetching
- [ ] Render loading state, error state, success state
- [ ] Use DESIGN_TOKENS (not custom styles)

**Manager Layer:**

- [ ] Copy WaveCompleteModalManager singleton pattern
- [ ] Private constructor
- [ ] getInstance() static method
- [ ] show() creates root if needed
- [ ] hide() unmounts and cleans up

**E2E Tests:**

- [ ] Copy shop E2E test structure
- [ ] Use test fixtures (auth-helpers, navigation-helpers, test-harness)
- [ ] Use TEST_IDS (not CSS selectors)
- [ ] beforeEach: signIn + selectCharacter
- [ ] afterEach: closeOverlay
- [ ] Defensive assertions (handle both disabled and error states)

**Test Harness Helpers:**

- [ ] Copy showShopOverlay pattern
- [ ] Add to src/utils/testHarness.ts
- [ ] Add wrapper to tests/fixtures/test-harness.ts
- [ ] Add navigation helper to tests/fixtures/navigation-helpers.ts

---

## Real-World Example: What I Should Have Done

### What I Did (WRONG)

```bash
# Started writing BankingService.ts from scratch
vim src/services/BankingService.ts

# Invented custom Supabase error handling
# Invented custom timeout logic
# Invented custom async patterns

# Result: Race conditions, timeouts, bugs already solved
```

### What I Should Have Done (RIGHT)

```bash
# Step 1: Find similar implementation
ls src/services/*.ts
# See: ShopService.ts, RecyclerService.ts, WorkshopService.ts

# Step 2: Read ShopService (most similar to Bank)
cat src/services/ShopService.ts
# Observe: Uses protectedSupabase for all operations
# Observe: operationName for debugging
# Observe: Timeout values
# Observe: Error handling pattern

# Step 3: Copy ShopService structure exactly
cp src/services/ShopService.ts src/services/BankingService.ts

# Step 4: Change ONLY domain logic
# - ShopService → BankingService
# - shop_reroll_state → bank_accounts
# - shop logic → bank logic
# Keep: ProtectedSupabaseClient usage, error handling, async patterns

# Result: Works immediately, no race conditions, follows established patterns
```

**Time saved:** 4+ hours of debugging race conditions I reinvented.

---

## Success Metrics

**You're following DRY when:**

- ✅ Before coding, you search for similar implementations
- ✅ You read existing code before writing new code
- ✅ You copy patterns and change only domain logic
- ✅ You use ProtectedSupabaseClient for Supabase operations
- ✅ You copy ShopOverlay async loading pattern for new overlays
- ✅ You copy existing E2E test structure
- ✅ User doesn't say "we already have that pattern"

**You're violating DRY when:**

- ❌ User says "you reinvented X"
- ❌ You write custom error handling for Supabase
- ❌ You invent new async loading patterns
- ❌ You create race conditions already solved
- ❌ You write E2E tests without reading existing tests
- ❌ User has to point you to existing implementations
- ❌ You waste hours debugging problems already solved

---

## Anti-Patterns Checklist

**Before committing ANY code, verify:**

- [ ] Did I search for similar implementations?
- [ ] Did I read the most similar code?
- [ ] Am I using ProtectedSupabaseClient (not direct supabase)?
- [ ] Am I copying ShopOverlay pattern (not inventing custom async)?
- [ ] Am I copying existing E2E test structure?
- [ ] Am I inventing ANYTHING that might already exist?

**If you answer "I invented X" to any question:**

1. Stop immediately
2. Search codebase for existing X
3. If found, delete your code and copy existing pattern
4. If not found, ask user before proceeding

---

## Software Engineering Principle

> "Don't Repeat Yourself (DRY)" - Every good codebase establishes patterns

**In this codebase:**

- ProtectedSupabaseClient is THE pattern for Supabase
- ShopOverlay is THE pattern for async hub overlays
- Existing E2E tests are THE pattern for new E2E tests

**Copy these patterns. Don't invent alternatives.**

**User Quote:**

> "software development is all about pattern recognition and and being able to apply like for like"

**This is the essence of being a good engineer.**

---

## Related Lessons

- [04-context-gathering.md](04-context-gathering.md) - Search before assuming
- [02-testing-conventions.md](02-testing-conventions.md) - E2E test patterns
- [03-user-preferences.md](03-user-preferences.md) - No assumptions

## Session References

- [session-log-2025-10-19-part5-recovery.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part5-recovery.md)

---

**GOLDEN RULE: If it exists, copy it. If it doesn't exist, ask first.**
