# Lesson 11: Defensive Development - Logging and Validation

**Category:** 🟡 Important (Standard Practice)
**Last Updated:** 2025-10-19
**Sessions:** Session 2025-10-19 Part 8 (Banking overlay debugging)

---

## Purpose

Defensive logging and validation should be the **keystone of all development**, not an afterthought when debugging fails.

**Why this matters:**

- Catches issues early in development (not in production)
- Provides diagnostic breadcrumbs when things go wrong
- Documents assumptions and data flow
- Speeds up debugging significantly
- Builds confidence in code correctness

---

## The Problem (Session 2025-10-19 Part 8)

**Issue:** Bank overlay not rendering - "Cannot read properties of undefined (reading 'xl')"

**AI approach (WRONG):**

1. Made assumptions about the root cause
2. Fixed useBankValidation parameter (correct fix)
3. Assumed that would solve the overlay rendering
4. When it didn't work, tried to debug by reading code
5. Got stuck guessing what was undefined
6. User had to suggest: "you know you can also add logging right?"

**User response:**

> "defensive logging and logic should be the keystone of all your development really"

**Impact:** Wasted 30+ minutes guessing instead of instrumenting code to observe actual behavior.

---

## The Solution: Defensive Development Pattern

### 1. Add Logging FIRST, Not Last

**❌ WRONG (Reactive Debugging):**

```typescript
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  const { colors, typography, spacing } = DESIGN_TOKENS;
  const { user } = useGameStore();
  // ... component logic
  // ERROR OCCURS
  // Now add logging to debug
};
```

**✅ RIGHT (Defensive Development):**

```typescript
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  console.log('[BankOverlay] Render start', { character: character?.id, DESIGN_TOKENS });
  const { colors, typography, spacing } = DESIGN_TOKENS;
  console.log('[BankOverlay] Destructured', {
    colors: !!colors,
    typography: !!typography,
    spacing: !!spacing,
  });
  const { user } = useGameStore();
  console.log('[BankOverlay] User loaded', { userId: user?.id, tier: user?.current_tier });
  // ... component logic
};
```

**Benefits:**

- See exactly what data is flowing through component
- Catch undefined/null values immediately
- Document component lifecycle
- Can be removed after feature is stable

---

### 2. Validate Assumptions at Boundaries

**Component entry points:**

```typescript
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  // Validate critical props
  if (!character) {
    console.error('[BankOverlay] No character provided!');
    return <div>Error: No character</div>;
  }

  if (!character.id || !character.user_id) {
    console.error('[BankOverlay] Invalid character', character);
    return <div>Error: Invalid character data</div>;
  }

  console.log('[BankOverlay] Valid character', { id: character.id });
  // ... rest of component
};
```

**Service entry points:**

```typescript
export class BankingService {
  static async deposit(characterId: string, userId: string, amount: number) {
    // Validate inputs
    if (!characterId || !userId) {
      logger.error('[BankingService] Missing required IDs', { characterId, userId });
      throw new Error('Missing required IDs for deposit');
    }

    if (amount <= 0) {
      logger.error('[BankingService] Invalid amount', { amount });
      throw new Error('Deposit amount must be positive');
    }

    logger.info('[BankingService] Deposit starting', { characterId, userId, amount });
    // ... service logic
  }
}
```

---

### 3. Log State Transitions

**Scene lifecycle:**

```typescript
export class BankScene extends BaseScene {
  init() {
    logger.info('[BankScene] init - getting character from store');
    const character = useGameStore.getState().currentCharacter;

    if (!character) {
      logger.warn('[BankScene] No character found, returning to hub');
      this.scene.start('ScrapyardHub');
      return;
    }

    logger.info('[BankScene] Character loaded', { id: character.id, name: character.name });
    this.character = character;
  }

  protected onSceneCreate(): void {
    logger.info('[BankScene] onSceneCreate - showing overlay', { characterId: this.character?.id });
    // ... show overlay
  }

  protected onSceneShutdown(): void {
    logger.info('[BankScene] onSceneShutdown - cleanup');
    // ... cleanup
  }
}
```

---

### 4. Defensive Null/Undefined Checks

**Use optional chaining + nullish coalescing:**

```typescript
// ❌ WRONG: Assumes data exists
const balance = account.balance;
const currency = character.currency;

// ✅ RIGHT: Defensive with fallbacks
const balance = account?.balance ?? 0;
const currency = character?.currency ?? 0;
const userName = user?.name ?? 'Unknown User';
```

**Validate before critical operations:**

```typescript
const handleDeposit = async (amount: number) => {
  if (!account) {
    console.error('[BankOverlay] Cannot deposit - no account');
    toast.error('Bank account not loaded');
    return;
  }

  if (amount <= 0) {
    console.error('[BankOverlay] Invalid deposit amount', { amount });
    toast.error('Invalid amount');
    return;
  }

  console.log('[BankOverlay] Starting deposit', { amount, currentBalance: account.balance });
  // ... perform deposit
};
```

---

### 5. Log External Dependencies

**Supabase calls:**

```typescript
static async getAccount(characterId: string, userId: string) {
  logger.info('[BankingService] Getting account', { characterId, userId });

  const result = await protectedSupabase.query(
    () => supabase.from('bank_accounts').select('*').eq('character_id', characterId).single(),
    { timeout: 6000, operationName: 'banking-get-account' }
  );

  logger.info('[BankingService] Account retrieved', { hasAccount: !!result.data });
  return result.data;
}
```

**Store access:**

```typescript
const { user, currentCharacter } = useGameStore();
console.log('[Component] Store state', {
  hasUser: !!user,
  hasCharacter: !!currentCharacter,
  userId: user?.id,
  characterId: currentCharacter?.id,
});
```

---

## When to Add Logging

### Always Log:

- Component/scene entry and exit
- Service method entry (with parameters)
- State mutations
- External API calls (before and after)
- Error conditions
- Data transformations

### Consider Logging:

- Loop iterations (if complex logic)
- Conditional branches (if non-obvious)
- Async operations (start and completion)
- User interactions (clicks, form submissions)

### Don't Log:

- Sensitive data (passwords, tokens)
- High-frequency events (mousemove, scroll)
- Trivial getters/setters

---

## Logging Levels

**Use appropriate logger levels:**

```typescript
// Development info
console.log('[Component] Normal flow', data);
logger.info('[Service] Operation started', params);

// Warnings (non-critical issues)
logger.warn('[Component] Fallback used', { reason });
console.warn('[Service] Rate limit approaching');

// Errors (critical issues)
logger.error('[Component] Operation failed', error);
console.error('[Service] Database error', { error, context });
```

---

## Production Considerations

**For production code:**

1. **Use logger service (not console):**

   ```typescript
   // ✅ GOOD: Can be disabled in production
   logger.debug('[Component] Render details', data);

   // ❌ BAD: Always logs
   console.log('[Component] Render details', data);
   ```

2. **Add log levels:**

   ```typescript
   if (process.env.NODE_ENV === 'development') {
     console.log('[Component] Development-only details', data);
   }
   ```

3. **Remove noisy logs:**
   - After feature is stable, remove excessive debug logs
   - Keep error logs and critical warnings
   - Keep entry/exit logs for major flows

---

## Real-World Example: Banking Overlay Debug

**Without defensive logging (Session Part 8 - first attempt):**

```typescript
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  const { colors, typography, spacing } = DESIGN_TOKENS;
  const { user } = useGameStore();
  // ... 100+ lines of logic
  // Error: Cannot read 'xl' of undefined
  // AI spends 30 minutes guessing what's undefined
};
```

**With defensive logging (Session Part 8 - after user suggestion):**

```typescript
export const BankOverlay: React.FC<BankOverlayProps> = ({ character, onClose }) => {
  console.log('[BankOverlay] Render start', { character: character?.id, DESIGN_TOKENS });
  const { colors, typography, spacing } = DESIGN_TOKENS;
  console.log('[BankOverlay] Destructured', { colors: !!colors, typography: !!typography });
  // Now browser console shows EXACTLY what's undefined
  // Fix identified in < 5 minutes
};
```

**Result:** 6x faster debugging (30 min → 5 min)

---

## Checklist: Before Writing Any Feature

**Before implementing:**

- [ ] Plan where to add defensive logging (entry, exit, state changes)
- [ ] Plan validation points (props, parameters, external data)
- [ ] Plan error handling (what if X is null/undefined?)
- [ ] Plan fallback values (nullish coalescing)

**While implementing:**

- [ ] Add logging at component/function entry
- [ ] Validate all external inputs (props, API responses)
- [ ] Use optional chaining for all nested access
- [ ] Log before and after state mutations
- [ ] Log before and after async operations

**After implementing:**

- [ ] Test with logging enabled - does it help debug?
- [ ] Verify all error conditions are logged
- [ ] Verify all critical paths have breadcrumbs
- [ ] Consider removing noisy logs (keep critical ones)

---

## Anti-Patterns

### ❌ Logging Without Context

```typescript
console.log('Error'); // What error? Where? Why?
```

### ✅ Logging With Context

```typescript
logger.error('[BankingService] Deposit failed', {
  characterId,
  amount,
  error: error.message,
  timestamp: Date.now(),
});
```

---

### ❌ Assuming Data Exists

```typescript
const balance = account.balance; // What if account is null?
```

### ✅ Defensive Access

```typescript
const balance = account?.balance ?? 0;
if (!account) {
  logger.warn('[Component] No account found, using default balance');
}
```

---

### ❌ Silent Failures

```typescript
try {
  await deposit(amount);
} catch (error) {
  // Silently fail
}
```

### ✅ Logged Failures

```typescript
try {
  logger.info('[Component] Starting deposit', { amount });
  await deposit(amount);
  logger.info('[Component] Deposit successful');
} catch (error) {
  logger.error('[Component] Deposit failed', { amount, error });
  toast.error('Failed to deposit');
}
```

---

## Key Takeaway

**Defensive logging and validation should be your FIRST instinct, not your LAST resort.**

When writing any new code:

1. Add logging FIRST (entry, exit, critical points)
2. Add validation FIRST (null checks, type guards)
3. Add error handling FIRST (try/catch, fallbacks)
4. Then write the happy path

**Think:** "How will I debug this when it breaks?"

Not "I'll add logging if it breaks."

---

## Related Lessons

- [02-testing-conventions.md](02-testing-conventions.md) - Test BEFORE claiming done
- [04-context-gathering.md](04-context-gathering.md) - Docs BEFORE coding
- [08-dry-principle.md](08-dry-principle.md) - Copy patterns, don't invent

---

## Session References

- Session 2025-10-19 Part 8: Banking overlay debug (30 min wasted without logging)
- User quote: "defensive logging and logic should be the keystone of all your development really"

---

**Remember: Log early, log often, validate everything.**
