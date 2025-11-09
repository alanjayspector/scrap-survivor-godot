# Lesson 10: Established Patterns - Copy These, Don't Reinvent

**Category:** 🟡 Important (Reference Guide)
**Last Updated:** 2025-10-19
**Sessions:** Session 2025-10-19 Part 6 (BankOverlay fix)

---

## Purpose

This lesson documents **proven patterns already in use** in the codebase. When implementing similar features, **copy these patterns exactly** and change only the domain logic.

**Why this matters:**

- Prevents reinventing solutions (Lesson 08: DRY Principle)
- Ensures consistency across features
- Avoids bugs already solved in existing code
- Speeds up implementation

**How to use this guide:**

1. Identify which pattern matches your task
2. Find the reference implementation
3. Copy the pattern exactly
4. Change only domain-specific logic

---

## Pattern 1: Hub Overlay (Shop/Bank/Workshop)

**Use when:** Adding a new feature accessed from ScrapyardHub that shows an overlay UI

**Pattern established by:** ShopScene + ShopOverlay (original implementation)
**Followed by:** BankScene + BankOverlay, WorkshopScene + WorkshopOverlay

### Architecture

```
ScrapyardHub (user clicks button)
  ↓
FeatureScene (Phaser scene)
  ↓
FeatureOverlayManager (singleton)
  ↓
FeatureOverlay (React component)
```

### Reference Implementation

**Scene:** [src/scenes/hub/ShopScene.ts](../../scenes/hub/ShopScene.ts)
**Overlay:** [src/components/ui/ShopOverlay.tsx](../../components/ui/ShopOverlay.tsx)
**Manager:** Embedded in overlay file

### Step-by-Step Pattern

#### 1. Scene Setup (FeatureScene.ts)

```typescript
import { BaseScene } from '../BaseScene';
import { useGameStore } from '@/store/gameStore';
import { logger } from '@/utils/Logger';
import { FeatureOverlayManager } from '@/components/ui/FeatureOverlay';
import { wastelandHudManager } from '@/components/ui/WastelandHudManager';
import type { CharacterInstance } from '@/types/models';

export class FeatureScene extends BaseScene {
  private character: CharacterInstance | null = null; // ← CRITICAL: Store character

  constructor() {
    super({ key: 'FeatureScene' });
  }

  init() {
    const character = useGameStore.getState().currentCharacter;
    if (!character) {
      logger.warn('FeatureScene init: no character found, returning to hub.');
      this.scene.start('ScrapyardHub');
      return; // ← CRITICAL: Early return
    }
    this.character = character; // ← CRITICAL: Store locally
  }

  protected onSceneCreate(): void {
    wastelandHudManager.hide(); // ← Defensive: hide wasteland HUD

    const manager = FeatureOverlayManager.getInstance();
    manager.show({
      character: this.character!, // ← CRITICAL: Pass character as prop
      onClose: () => {
        this.handleClose();
      },
    });
  }

  protected onSceneShutdown(): void {
    FeatureOverlayManager.getInstance().cleanup();
  }

  private handleClose() {
    FeatureOverlayManager.getInstance().hide();
    this.scene.start('ScrapyardHub');
  }
}
```

**Key Points:**

- ✅ Store `character` in `init()` (line 9-16)
- ✅ Early return if character not found (prevents null errors)
- ✅ Pass character to overlay manager (line 22)
- ✅ Cleanup on shutdown (line 27)

#### 2. Overlay Component (FeatureOverlay.tsx)

```typescript
import React from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { DESIGN_TOKENS } from '@/config/designTokens';
import { TEST_IDS } from '@/testing/testIds';
import type { CharacterInstance } from '@/types/models';

interface FeatureOverlayProps {
  character: CharacterInstance; // ← CRITICAL: Required prop (not from store)
  onClose: () => void;
}

export const FeatureOverlay: React.FC<FeatureOverlayProps> = ({
  character, // ← CRITICAL: Receive as prop
  onClose
}) => {
  const { colors, typography, spacing, borders, shadows } = DESIGN_TOKENS;

  // Use character.id, character.user_id for service calls
  // DO NOT use useGameStore() to get character

  return (
    <div
      data-testid={TEST_IDS.ui.feature.overlayBackdrop}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        zIndex: 10000,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {/* Feature UI here */}
    </div>
  );
};
```

**Key Points:**

- ✅ Accept `character` as required prop (not optional)
- ✅ DO NOT use `useGameStore()` to get character
- ✅ Character always defined (no null checks needed in component)

#### 3. Overlay Manager (embedded in FeatureOverlay.tsx)

```typescript
// FeatureOverlayManager: Singleton manager
interface ManagerShowOptions {
  character: CharacterInstance; // ← CRITICAL: Required
  onClose: () => void;
}

export class FeatureOverlayManager {
  private static instance: FeatureOverlayManager | null = null;
  private container: HTMLElement | null = null;
  private root: Root | null = null;

  public static getInstance(): FeatureOverlayManager {
    if (!FeatureOverlayManager.instance) {
      FeatureOverlayManager.instance = new FeatureOverlayManager();
    }
    return FeatureOverlayManager.instance;
  }

  public show(options: ManagerShowOptions): void {
    if (!this.container) {
      this.container = document.createElement('div');
      this.container.setAttribute('id', 'feature-overlay-root');
      document.body.appendChild(this.container);
    }

    if (!this.root) {
      this.root = createRoot(this.container);
    }

    // ← CRITICAL: Pass character from options
    this.root.render(
      <FeatureOverlay
        character={options.character}
        onClose={options.onClose}
      />
    );
  }

  public hide(): void {
    if (this.root) {
      this.root.unmount();
      this.root = null;
    }
  }

  public cleanup(): void {
    this.hide();
    if (this.container) {
      this.container.remove();
      this.container = null;
    }
  }
}
```

**Key Points:**

- ✅ Singleton pattern (getInstance)
- ✅ Manager receives character in show() options
- ✅ Manager passes character to overlay component
- ✅ Cleanup unmounts React root and removes DOM container

### Why This Pattern?

**Problem it solves:**

- Character might not be in store yet when overlay renders
- Race conditions with async store access
- Null/undefined character errors during initialization

**Solution:**

- Scene guarantees character exists (early return if not)
- Scene passes character explicitly to overlay
- Overlay receives character as required prop (never null)

### Common Mistakes

❌ **WRONG: Get character from store in overlay**

```typescript
export const FeatureOverlay = ({ onClose }) => {
  const { currentCharacter } = useGameStore(); // ← Can be null!
  // Race condition risk, null errors
};
```

✅ **RIGHT: Receive character as prop**

```typescript
export const FeatureOverlay = ({ character, onClose }) => {
  // character is always defined
};
```

### Files Using This Pattern

1. **Shop System**
   - Scene: `src/scenes/hub/ShopScene.ts`
   - Overlay: `src/components/ui/ShopOverlay.tsx`
   - Status: ✅ Original implementation

2. **Banking System** (Sprint 13)
   - Scene: `src/scenes/hub/BankScene.ts`
   - Overlay: `src/components/ui/BankOverlay.tsx`
   - Status: ✅ Fixed in session 2025-10-19 Part 6
   - Fix: Added character as prop (commit 1ce9e3d)

3. **Workshop System**
   - Scene: `src/scenes/hub/WorkshopScene.ts`
   - Overlay: `src/components/ui/WorkshopOverlay.tsx`
   - Status: ✅ Follows pattern

### When to Use This Pattern

**Use when:**

- Adding new hub feature (Barracks, Marketplace, GuildHall)
- Feature requires character data
- Feature shows React overlay UI
- Feature is accessed from ScrapyardHub

**Examples of future features:**

- BarracksScene + BarracksOverlay (character recruitment)
- MarketplaceScene + MarketplaceOverlay (trading system)
- GuildHallScene + GuildHallOverlay (guild management)

### Quick Checklist

Before implementing a new hub overlay:

- [ ] Read ShopScene.ts (reference implementation)
- [ ] Read ShopOverlay.tsx (reference implementation)
- [ ] Copy the 3-file structure (Scene, Overlay, Manager)
- [ ] Scene stores character in init()
- [ ] Scene passes character to manager.show()
- [ ] Overlay accepts character as required prop
- [ ] Manager passes character to overlay component
- [ ] DO NOT use useGameStore() in overlay to get character

---

## Pattern 2: Service with ProtectedSupabaseClient

**Use when:** Creating a new service that needs to query Supabase

**Pattern established by:** ShopRerollService, RepairService
**Followed by:** BankingService (after fix in session 2025-10-19 Part 6)

### Reference Implementation

**File:** [src/services/ShopRerollService.ts](../../services/ShopRerollService.ts)

### The Pattern

```typescript
import { supabase } from '@/config/supabase';
import { protectedSupabase } from './ProtectedSupabaseClient';
import { logger } from '@/utils/Logger';

export class FeatureService {
  /**
   * Query Supabase table
   */
  static async getSomeData(id: string): Promise<SomeData> {
    try {
      const result = await protectedSupabase.query(
        () => supabase.from('table_name').select('*').eq('id', id).single(),
        {
          timeout: 6000,
          operationName: 'feature-get-data',
        }
      );

      return result.data as SomeData;
    } catch (error) {
      logger.error('Error in getSomeData', { id, error });
      throw error;
    }
  }

  /**
   * Insert/Update with ProtectedSupabaseClient
   */
  static async updateData(id: string, updates: Partial<SomeData>): Promise<void> {
    try {
      await protectedSupabase.query(
        () => supabase.from('table_name').update(updates).eq('id', id),
        {
          timeout: 6000,
          operationName: 'feature-update-data',
        }
      );

      logger.info('Update successful', { id, updates });
    } catch (error) {
      logger.error('Error in updateData', { id, error });
      throw error;
    }
  }
}
```

### Key Points

- ✅ Import both `supabase` (for query builder) and `protectedSupabase` (for execution)
- ✅ Wrap ALL supabase calls with `protectedSupabase.query()`
- ✅ Use 6000ms timeout (standard)
- ✅ Use descriptive `operationName` (feature-action format)
- ✅ Let ProtectedSupabaseClient handle errors (don't catch result.error)

### Why This Pattern?

**Benefits:**

- Circuit breaker protection (fail fast if Supabase down)
- Automatic retries with exponential backoff
- Request deduplication (prevent double-clicks)
- Adaptive timeouts (learns from latency)
- Consistent error handling

**Without this pattern:**

- Race conditions
- Timeout hangs
- No retry logic
- Manual error handling

### Common Mistakes

❌ **WRONG: Direct supabase calls**

```typescript
const { data, error } = await supabase.from('table').select('*');
if (error) throw error; // Manual error handling
```

✅ **RIGHT: Wrapped with ProtectedSupabaseClient**

```typescript
const result = await protectedSupabase.query(() => supabase.from('table').select('*'), {
  timeout: 6000,
  operationName: 'feature-get',
});
// ProtectedSupabaseClient handles errors automatically
```

### Files Using This Pattern

1. ShopRerollService ✅
2. RepairService ✅
3. RecyclerService ✅
4. BankingService ✅ (fixed in commit 013d9c6)
5. TelemetryService ✅
6. WorkshopService ✅

**Rule:** ALL new services MUST use this pattern.

---

## Pattern 3: E2E Test Structure

**Use when:** Writing new Playwright E2E tests

**Pattern established by:** tests/shop/shop-purchasing.spec.ts
**Followed by:** tests/banking/\*.spec.ts (Sprint 13)

### Reference Implementation

**File:** [tests/shop/shop-purchasing.spec.ts](../../tests/shop/shop-purchasing.spec.ts)

### The Pattern

```typescript
import { test, expect } from '@playwright/test';
import { signInTestUser } from '../fixtures/auth-helpers';
import {
  selectFirstCharacter,
  navigateToFeature,
  closeOverlay,
} from '../fixtures/navigation-helpers';
import { seedCharacter, setFeatureData } from '../fixtures/test-harness';
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
    await setFeatureData(page, characterId, someValue);

    // Act: Perform user action
    await navigateToFeature(page);
    await page.getByTestId(TEST_IDS.ui.feature.actionButton).click();

    // Assert: Verify expected outcome
    await expect(page.getByTestId(TEST_IDS.ui.feature.result)).toBeVisible();
  });
});
```

### Key Points

- ✅ Use test fixtures (auth-helpers, navigation-helpers, test-harness)
- ✅ Use TEST_IDS (not CSS selectors)
- ✅ beforeEach: sign in + select character
- ✅ afterEach: close overlay (cleanup)
- ✅ Arrange-Act-Assert structure

### Running E2E Tests

**Development/Debugging:**

```bash
./scripts/test-helpers.sh run-single tests/feature/test-file.spec.ts
```

- Single browser (chromium)
- Sequential execution (no parallel thrashing)

**Final Validation:**

```bash
./scripts/test-helpers.sh run tests/feature/
```

- All 3 browsers (chromium, mobile chrome, mobile safari)
- Parallel execution

**See:** [02-testing-conventions.md](02-testing-conventions.md) - Playwright Parallel Execution section

---

## How to Use This Guide

**When implementing a new feature:**

1. **Identify the pattern type**
   - Hub overlay? → Pattern 1
   - Service with Supabase? → Pattern 2
   - E2E tests? → Pattern 3

2. **Read the reference implementation**
   - Don't skip this step!
   - Understand WHY the pattern exists

3. **Copy the pattern exactly**
   - Use the code snippets as templates
   - Change only domain-specific logic

4. **Verify you followed the pattern**
   - Use the checklists
   - Compare your code to the reference

**Example: Adding a new Barracks feature**

1. Pattern type: Hub overlay (Pattern 1)
2. Reference: ShopScene.ts + ShopOverlay.tsx
3. Copy:
   - BarracksScene stores character in init()
   - BarracksOverlay accepts character as prop
   - BarracksOverlayManager passes character through
4. Verify: Character is prop (not from store) ✅

---

## Related Lessons

- [08-dry-principle.md](08-dry-principle.md) - Why copying patterns matters
- [02-testing-conventions.md](02-testing-conventions.md) - E2E testing patterns
- [04-context-gathering.md](04-context-gathering.md) - How to find patterns

---

## Maintenance

**When to update this file:**

- New pattern emerges across 2+ features
- Existing pattern evolves (document the change)
- Pattern violation discovered (add to "Common Mistakes")

**Format:**

- Pattern name and use case
- Reference implementation (link to file)
- Code examples with annotations
- Why the pattern exists
- Common mistakes
- Files using the pattern

---

**Remember: If a pattern exists, copy it. Don't reinvent.**
