# Lesson 36: Debug Logging for Evidence-Based Troubleshooting

**Category:** 🔴 Critical (Development Practice)
**Date:** 2025-10-25
**Session:** Sprint 16 - Error UI Manual QA
**Status:** Active Pattern

---

## The Problem

During manual QA of ErrorToast auto-dismiss functionality, the issue was:

- Toast appeared correctly
- Close button (×) worked
- **Auto-dismiss did NOT work** (toast stayed visible forever)

**Without debug logging**, troubleshooting would have required:

1. Reading all relevant code files
2. Making educated guesses about the issue
3. Adding logging incrementally
4. Multiple test cycles to gather evidence

This is **slow and inefficient**.

---

## The Solution: Add Debug Logging UP FRONT

### What We Did

**Step 1: Added comprehensive logging to ErrorToast.tsx**

```typescript
// Auto-dismiss after duration
useEffect(() => {
  console.log('[ErrorToast] useEffect fired', { duration, hasDuration: !!duration });

  if (duration) {
    console.log('[ErrorToast] Setting timer for', duration, 'ms');
    const timer = setTimeout(() => {
      console.log('[ErrorToast] Timer fired - calling onDismiss');
      onDismiss();
    }, duration);

    return () => {
      console.log('[ErrorToast] Cleanup - clearing timer');
      clearTimeout(timer);
    };
  } else {
    console.log('[ErrorToast] No duration provided, skipping auto-dismiss');
  }
}, [duration, onDismiss]);
```

**Step 2: Added logging to ErrorDisplayManager.tsx**

```typescript
useEffect(() => {
  console.log('[ErrorDisplayManager] Starting polling');
  const interval = setInterval(() => {
    const toasts = errorService.getActiveToasts();
    if (toasts.length > 0) {
      console.log(
        '[ErrorDisplayManager] Poll found toasts:',
        toasts.map((t) => ({ id: t.id, duration: t.duration }))
      );
    }
    setActiveToasts([...toasts]);
    setActiveModal(errorService.getActiveModal());
  }, 100);

  return () => {
    console.log('[ErrorDisplayManager] Stopping polling');
    clearInterval(interval);
  };
}, []);
```

**Step 3: Ran test, observed logs**

```
22:04:09.244 [ErrorToast] useEffect fired {duration: 5000, hasDuration: true}
22:04:09.244 [ErrorToast] Setting timer for 5000 ms
22:04:09.341 [ErrorToast] Cleanup - clearing timer    <-- ❌ Only 97ms later!
22:04:09.342 [ErrorToast] useEffect fired {duration: 5000, hasDuration: true}
22:04:09.342 [ErrorToast] Setting timer for 5000 ms
22:04:09.440 [ErrorToast] Cleanup - clearing timer    <-- ❌ Again at 198ms!
```

### Evidence-Based Diagnosis

**From logs, we immediately saw:**

1. ✅ `duration` was provided (5000ms)
2. ✅ Timer was being set
3. ❌ Timer was being cleared after ~100ms
4. ❌ useEffect was firing repeatedly (every 100ms)
5. ❌ Timer never reached 5000ms

**Root cause identified in ~30 seconds:**

ErrorDisplayManager's polling (every 100ms) was causing re-renders, which triggered useEffect cleanup, which cleared the timer before it could fire.

**Solution:** Only update state when toast IDs actually change (return same reference to prevent re-render).

**Total debugging time:** ~10 minutes (with logging) vs hours (without)

---

## The Pattern: Debug Logging First

### When to Add Debug Logging

**ALWAYS add debug logging when:**

1. **Implementing complex state management** (useEffect, polling, timers)
2. **Troubleshooting non-obvious bugs** (it worked in tests, fails in browser)
3. **Integrating multiple systems** (React + Phaser, service coordination)
4. **Implementing async operations** (promises, callbacks, event handlers)

### What to Log

**Log these key events:**

1. **Entry/exit points** ("Component mounted", "Starting operation")
2. **State changes** ("Toast list changed", "Timer set for X ms")
3. **Conditional branches** ("Duration provided", "No duration, skipping")
4. **Cleanup operations** ("Clearing timer", "Unmounting component")
5. **Unexpected events** ("useEffect fired again - why?")

### Logging Format

**Use consistent prefix format:**

```typescript
console.log('[ComponentName] Event description', { relevantData });
console.warn('[ComponentName] Warning condition', { context });
console.error('[ComponentName] Error occurred', { error });
```

**Benefits:**

- Easy to filter in console (search for `[ComponentName]`)
- Clear event description
- Structured data for inspection
- Consistent across codebase

### Example: Good Debug Logging

```typescript
// ✅ GOOD: Comprehensive logging
useEffect(() => {
  console.log('[Modal] useEffect triggered', {
    isOpen,
    hasActions: !!actions,
    dependency: onClose,
  });

  if (!isOpen) {
    console.log('[Modal] Not open, skipping setup');
    return;
  }

  console.log('[Modal] Disabling Phaser input');
  const game = window.__PHASER_GAME__;

  if (!game) {
    console.warn('[Modal] Phaser game not found');
    return;
  }

  const scene = game.scene.getScenes(true)[0];
  if (scene?.input) {
    scene.input.enabled = false;
    console.log('[Modal] Phaser input disabled');

    return () => {
      console.log('[Modal] Cleanup - re-enabling Phaser input');
      scene.input.enabled = true;
    };
  }
}, [isOpen, onClose]);
```

**vs. Bad Debug Logging:**

```typescript
// ❌ BAD: Minimal/no logging
useEffect(() => {
  if (!isOpen) return;

  const game = window.__PHASER_GAME__;
  if (!game) return;

  const scene = game.scene.getScenes(true)[0];
  if (scene?.input) {
    scene.input.enabled = false;
    return () => {
      scene.input.enabled = true;
    };
  }
}, [isOpen, onClose]);
```

---

## When to Remove Debug Logging

**After the fix is verified:**

1. Keep logging for CRITICAL paths (errors, warnings)
2. Remove verbose logging for common paths (every render, every tick)
3. Remove temporary debugging logs added for specific bug hunt

**Example cleanup:**

```typescript
// Before (during debugging)
console.log('[ErrorToast] useEffect fired', { duration, hasDuration: !!duration });
console.log('[ErrorToast] Setting timer for', duration, 'ms');
console.log('[ErrorToast] Timer fired - calling onDismiss');
console.log('[ErrorToast] Cleanup - clearing timer');

// After (cleaned up)
useEffect(() => {
  if (duration) {
    const timer = setTimeout(() => {
      onDismiss();
    }, duration);

    return () => clearTimeout(timer);
  }
}, [duration, onDismiss]);
```

**Keep warnings/errors:**

```typescript
// ✅ KEEP: Warnings for edge cases
if (!phaserGame) {
  console.warn('[ErrorModal] Phaser game not found, cannot disable input');
  return;
}
```

---

## Benefits

### 1. Faster Root Cause Analysis

**Without logging:** 2-4 hours of trial-and-error debugging
**With logging:** 5-10 minutes to identify root cause

### 2. Evidence-Based Decisions

- Logs show EXACTLY what happened (not guesses)
- Can see timing issues (100ms polling vs 5000ms timer)
- Can see unexpected re-renders, cleanup calls, etc.

### 3. Better Understanding of Code Flow

- Logs reveal how components actually interact
- Shows execution order (was cleanup called before or after?)
- Reveals React rendering behavior

### 4. Easier Collaboration

- User can paste logs in chat
- AI can diagnose from logs (no file reading needed)
- Clear evidence for code reviews

---

## Related Lessons

- **Lesson 19:** Evidence-Based Debugging (not tool thrashing)
- **Lesson 11:** Defensive Development (log early, log often)
- **Lesson 04:** Context Gathering (gather evidence before acting)

---

## Action Items

**For AI Assistants:**

1. When implementing complex features, **add debug logging UP FRONT**
2. When troubleshooting bugs, **add comprehensive logging FIRST**
3. After fix is verified, **remove verbose logs** (keep warnings/errors)
4. Use consistent logging format: `console.log('[Component] Event', { data })`

**For Code Reviews:**

1. Verify logging exists for complex state management
2. Ensure warnings exist for edge cases
3. Check that temporary debug logs are removed before merge

---

**Bottom Line:** Debug logging is NOT wasted effort. It saves hours of troubleshooting by providing instant, concrete evidence of what's actually happening in the code. Add it UP FRONT, not as an afterthought.
