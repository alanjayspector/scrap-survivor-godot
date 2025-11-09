# Lesson 34: Game Store Must Update When Character Changes

**Date:** 2025-10-25
**Category:** 🟡 Important (React Patterns)
**Session:** Sprint 16 Phase 3 - Banking Currency Reactivity Bug

---

## The Problem

**Symptom:** After withdrawing scrap from bank, character currency doesn't appear in UI when switching to deposit tab.

**User Report:**

> "i dont see the scrap i withdraw when i go over to the deposit tab"

**Evidence:**

- Withdrawal completes successfully (logs show currency updated in DB)
- Character local storage updated correctly
- But UI doesn't update reactively - shows stale currency value

**Time Lost:** ~30 minutes debugging UI state, investigating BankOverlay hooks

---

## Root Cause

**HybridCharacterService.updateCharacter() updates local storage but NOT the game store.**

### Why This Matters

React components use `useGameStore` to get reactive character data:

```typescript
// BankOverlay.tsx
const currentCurrency = useGameStore(
  (state) => state.currentCharacter?.currency ?? character.currency
);
```

When `HybridCharacterService.updateCharacter()` modifies character (e.g., during withdrawal), it:

1. ✅ Updates local storage (IndexedDB)
2. ❌ **Does NOT update game store** → UI doesn't re-render

---

## The Bug

### Before Fix (WRONG)

```typescript
// HybridCharacterService.ts:754-823 (BEFORE)
static async updateCharacter(
  characterId: string,
  updates: Partial<CharacterInstance>
): Promise<void> {
  // ... validation ...

  const updatedCharacter: LocalCharacter = {
    ...localCharacter,
    ...updates,
    last_played: new Date().toISOString(),
    dirty: true,
    version: (localCharacter.version || 0) + 1,
  };

  await localStorageService.saveCharacter(updatedCharacter);

  logger.info('Character updated locally (INSTANT)', {
    characterId,
    markedDirty: true,
  });

  // ❌ MISSING: No game store update!
}
```

### After Fix (CORRECT)

```typescript
// HybridCharacterService.ts:754-823 (AFTER)
static async updateCharacter(
  characterId: string,
  updates: Partial<CharacterInstance>
): Promise<void> {
  // ... validation and local storage update ...

  await localStorageService.saveCharacter(updatedCharacter);

  logger.info('Character updated locally (INSTANT)', {
    characterId,
    markedDirty: true,
  });

  // ✅ Update game store if this is the current character
  const currentState = useGameStore.getState();
  if (currentState.currentCharacter?.id === characterId) {
    useGameStore.setState({
      currentCharacter: this.convertLocalToRemote(updatedCharacter),
    });
  }
}
```

---

## Why The Pattern Existed Elsewhere But Not Here

The game store update pattern WAS implemented in `handleWeaponInstanceMigration()` (lines 1004-1009), but NOT in the main `updateCharacter()` method.

This created inconsistent behavior:

- ✅ Weapon updates trigger UI reactivity
- ❌ Currency/stat updates don't trigger UI reactivity

---

## The Flow of Data Updates

### Typical Character Update Flow

```
BankingService.withdraw()
    ↓
HybridCharacterService.updateCharacter(characterId, { currency: newAmount })
    ↓
localStorageService.saveCharacter(updatedCharacter)
    ↓
useGameStore.setState({ currentCharacter: ... })  ← ADDED
    ↓
BankOverlay re-renders with new currency
```

### What Components Rely On

```typescript
// Components use reactive store subscriptions
const currentCurrency = useGameStore((state) => state.currentCharacter?.currency);

// NOT one-time prop values
// ❌ const currentCurrency = character.currency; // Won't update!
```

---

## Key Implementation Details

### 1. Only Update If Current Character

```typescript
const currentState = useGameStore.getState();
if (currentState.currentCharacter?.id === characterId) {
  // Only update store for the character currently in play
  useGameStore.setState({ currentCharacter: ... });
}
```

**Why:** Multiple characters exist in local storage. Only update the store if we're modifying the currently-active character.

### 2. Use convertLocalToRemote()

```typescript
useGameStore.setState({
  currentCharacter: this.convertLocalToRemote(updatedCharacter),
});
```

**Why:** Game store expects `CharacterInstance` type (without `dirty`, `last_synced` fields). The `convertLocalToRemote()` helper strips LocalCharacter-specific fields.

### 3. Update After Local Storage Save

```typescript
await localStorageService.saveCharacter(updatedCharacter);
// ↑ Save first (source of truth)

useGameStore.setState({ currentCharacter: ... });
// ↑ Then update store (derived state for UI)
```

**Why:** Local storage is persistent. If store update fails, we still have the data. If we updated store first and save failed, store would be out of sync.

---

## Services That Call updateCharacter()

All these services now get automatic UI reactivity after this fix:

1. **BankingService** - deposit/withdraw operations
2. **WorkshopService** - repair operations (if they update character)
3. **ShopService** - purchase operations
4. **Game scenes** - stat changes during gameplay
5. **Any service** that modifies character data

---

## Related Pattern: Character Prop vs Store Subscription

### ❌ Anti-Pattern (One-Time Prop)

```typescript
// BankOverlay receives character as prop
export const BankOverlay: React.FC<{ character: CharacterInstance }> = ({ character }) => {
  // ❌ WRONG: Using prop value directly (won't update)
  const currentCurrency = character.currency;

  return <div>Currency: {currentCurrency}</div>;
  // Won't update when character changes!
}
```

### ✅ Correct Pattern (Reactive Subscription)

```typescript
export const BankOverlay: React.FC<{ character: CharacterInstance }> = ({ character }) => {
  // ✅ CORRECT: Subscribe to store for reactive updates
  const currentCurrency = useGameStore(
    (state) => state.currentCharacter?.currency ?? character.currency
  );

  return <div>Currency: {currentCurrency}</div>;
  // Updates reactively when character.currency changes!
}
```

**Pattern:** Use `character` prop for **initial data** (when component mounts), but `useGameStore` subscription for **reactive updates** (during component lifetime).

---

## Testing Strategy

### Manual Test Case

1. Start game, open bank
2. Withdraw all scrap (e.g., 200 scrap)
3. **Without refreshing**, switch to Deposit tab
4. **Expected:** Character currency shows +200 scrap
5. **Before fix:** Currency shows 0 (stale)
6. **After fix:** Currency shows +200 (reactive) ✅

### Evidence From Logs

**Withdrawal completes:**

```
16:37:50.050 [INFO] Character updated locally
16:37:50.194 [INFO] Withdrawal successful {"amount":200}
```

**User switches to deposit tab:**

```
16:38:20.470 [INFO] [Banking] Deposit START
16:38:20.682 [DEBUG] [Banking] Player total balance {"totalBalance":0}
```

❌ Balance still 0 - UI didn't update

**After fix applied:**

- Character updates propagate to store immediately
- UI re-renders with new currency value
- No stale data in deposit tab

---

## Prevention Measures

### Code Review Checklist

When adding/reviewing code that modifies character data:

- [ ] Does it call `HybridCharacterService.updateCharacter()`?
- [ ] If not, does it manually update the game store?
- [ ] Are UI components using `useGameStore` subscriptions (not just props)?
- [ ] Does the update flow work without page refresh?

### Future Improvements

Consider creating a `useReactiveCharacter()` hook:

```typescript
// Future: Centralized reactive character pattern
function useReactiveCharacter(characterId: string) {
  return useGameStore((state) =>
    state.currentCharacter?.id === characterId ? state.currentCharacter : null
  );
}
```

---

## Related Services Verified

Checked these services DON'T have separate character update logic that bypasses `HybridCharacterService`:

- ✅ BankingService - uses HybridCharacterService.updateCharacter()
- ✅ WorkshopService - uses HybridCharacterService.updateCharacter()
- ✅ ShopService - uses HybridCharacterService.updateCharacter()
- ✅ Game scenes - use HybridCharacterService.updateCharacter()

All services properly route through the main update method, so all get reactive store updates automatically.

---

## Related Lessons

- [Lesson 21: Supabase Auth Usage Patterns](21-supabase-auth-usage-patterns.md) - Service patterns
- [Lesson 33: ProtectedSupabaseClient Returns Unwrapped Data](33-protectedsupabaseclient-return-unwrapped.md) - Related banking bug

---

## Remember

**When modifying character data:**

1. **Always use** `HybridCharacterService.updateCharacter()`
2. **Never update** local storage directly without updating store
3. **Components must** use `useGameStore` subscriptions for reactive updates
4. **Test without** page refresh to verify reactivity

**Pattern:**

```
Modify Data → Update Local Storage → Update Game Store → UI Re-renders
```

---

**Commit:** 1eb6172 - fix(sync): fix character sync duplicate key errors and currency update reactivity

**Session Reference:** Sprint 16 Phase 3 - 2025-10-25
