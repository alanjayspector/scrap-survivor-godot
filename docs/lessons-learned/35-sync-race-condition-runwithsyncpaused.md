# Lesson 35: runWithSyncPaused Must Wait for In-Flight Sync

**Date:** 2025-10-25
**Category:** 🔴 Critical (Concurrency Patterns)
**Session:** Sprint 16 Phase 3 - SyncService Race Condition

---

## The Problem

**Symptom:** Duplicate key error when creating characters, even though character doesn't exist yet.

**Error:**

```
[ERROR] [ProtectedSupabase] Query failed: sync-insert-character
Error: duplicate key value violates unique constraint "character_instances_pkey"
[INFO] Character already exists remotely (race condition), marking as synced
```

**Frequency:** Intermittent - depends on timing between user action and periodic sync (30s interval)

---

## Root Cause

**SyncService.runWithSyncPaused() clears the periodic interval but doesn't wait for in-flight sync to complete.**

### The Race Condition Timeline

```
T=0.0s  Periodic sync starts (runs every 30s)
T=0.2s  Sync fetches character list from Supabase
T=0.5s  User clicks "Create Character"
T=0.5s  runWithSyncPaused() called - clears interval ✅
T=0.5s  BUT sync is still running! (syncInProgress = true) ❌
T=1.0s  Character created directly in Supabase
T=2.0s  Original sync (from T=0) completes its fetch
T=2.0s  Sync sees character doesn't exist (data from T=0.2s fetch)
T=2.0s  Sync tries INSERT on newly-created character
T=2.1s  💥 Duplicate key error!
```

**Key insight:** The fetch happened BEFORE the character was created, but the INSERT happens AFTER.

---

## The Bug

### Before Fix (WRONG)

```typescript
// SyncService.ts:127-146 (BEFORE)
async runWithSyncPaused<T>(operation: () => Promise<T>): Promise<T> {
  const wasRunning = !!this.syncInterval;

  if (wasRunning && this.syncInterval) {
    clearInterval(this.syncInterval);
    this.syncInterval = null;
    logger.debug('Periodic sync paused for critical operation');
  }

  try {
    return await operation(); // ❌ Starts immediately!
  } finally {
    const navigatorAvailable = typeof navigator !== 'undefined';
    const shouldResume = wasRunning && navigatorAvailable && navigator.onLine;

    if (shouldResume) {
      logger.debug('Resuming periodic sync after critical operation');
      this.startPeriodicSync(this.lastIntervalMs);
    }
  }
}
```

**Problem:** Clears the interval (stops FUTURE syncs) but doesn't wait for CURRENT sync to finish.

### After Fix (CORRECT)

```typescript
// SyncService.ts:127-161 (AFTER)
async runWithSyncPaused<T>(operation: () => Promise<T>): Promise<T> {
  const wasRunning = !!this.syncInterval;

  if (wasRunning && this.syncInterval) {
    clearInterval(this.syncInterval);
    this.syncInterval = null;
    logger.debug('Periodic sync paused for critical operation');
  }

  // ✅ CRITICAL: Wait for any in-flight sync to complete
  const maxWaitMs = 5000;
  const startWait = performance.now();
  while (this.syncInProgress && performance.now() - startWait < maxWaitMs) {
    logger.debug('Waiting for in-flight sync to complete before critical operation');
    await new Promise((resolve) => setTimeout(resolve, 100)); // Poll every 100ms
  }

  if (this.syncInProgress) {
    logger.warn('In-flight sync did not complete within timeout, proceeding anyway');
  }

  try {
    return await operation();
  } finally {
    // ... resume logic unchanged ...
  }
}
```

**Fix:** Polling loop waits up to 5 seconds for `syncInProgress` flag to clear before proceeding.

---

## Why Polling Instead of Promises?

### Considered Alternatives

**Option 1: Promise-based wait**

```typescript
// Could track sync promises in a Set
private syncPromises = new Set<Promise<void>>();

async syncNow() {
  const promise = this.performSync();
  this.syncPromises.add(promise);
  await promise;
  this.syncPromises.delete(promise);
}

async runWithSyncPaused<T>(operation: () => Promise<T>): Promise<T> {
  await Promise.all(this.syncPromises); // Wait for all syncs
  return await operation();
}
```

**Why not used:** More complex state management, risk of promise leaks.

**Option 2: Event-based wait**

```typescript
private syncCompleteEvent = new EventEmitter();

async runWithSyncPaused<T>(operation: () => Promise<T>): Promise<T> {
  if (this.syncInProgress) {
    await this.syncCompleteEvent.once('complete');
  }
  return await operation();
}
```

**Why not used:** Requires EventEmitter dependency, overkill for simple flag check.

**Option 3: Polling (CHOSEN)**

```typescript
while (this.syncInProgress && performance.now() - startWait < maxWaitMs) {
  await new Promise((resolve) => setTimeout(resolve, 100));
}
```

**Why chosen:**

- Simple implementation
- No additional state management
- 100ms polling is fast enough (user won't notice)
- 5 second timeout prevents deadlock
- Uses existing `syncInProgress` flag

---

## The syncInProgress Flag

### How It Works

```typescript
// SyncService.ts maintains a boolean flag
private syncInProgress = false;

async syncNow(): Promise<SyncResult> {
  // Prevent concurrent syncs
  if (this.syncInProgress) {
    return { success: false, synced: 0, failed: 0, errors: ['Sync in progress'] };
  }

  this.syncInProgress = true;
  this.syncStartTimestamp = performance.now();

  try {
    const result = await this.performSync();
    return result;
  } finally {
    this.syncInProgress = false; // Always cleared
  }
}
```

**Guarantees:**

- Flag set before sync starts
- Flag cleared in `finally` block (even if sync fails)
- Only one sync can run at a time

---

## Where runWithSyncPaused Is Used

### Critical Operations That Need Sync Paused

**1. Character Creation**

```typescript
// HybridCharacterService.ts:71
const character = await syncService.runWithSyncPaused(async () => {
  return await supabase.from('character_instances').insert(payload).select('*').single();
});
```

**Why:** Creating character directly in Supabase. Sync must not try to INSERT the same character.

**2. Other Critical Operations (Future)**

- Character deletion (when implemented)
- Bulk character updates
- Any operation that directly manipulates Supabase data

---

## Timeout Behavior

### Why 5 Seconds?

```typescript
const maxWaitMs = 5000; // Wait up to 5 seconds
```

**Reasoning:**

- Normal sync completes in 100-500ms
- 5 seconds is generous buffer
- If sync takes >5s, something is wrong (database issue, network problem)
- Better to proceed and log warning than block user indefinitely

### What Happens on Timeout?

```typescript
if (this.syncInProgress) {
  logger.warn('In-flight sync did not complete within timeout, proceeding anyway');
}
// Proceeds with operation despite sync still running
```

**Trade-off:**

- Risk: Might still get duplicate key error
- Benefit: User not blocked for >5 seconds
- Mitigation: Duplicate key error is caught and handled gracefully (line 440-452)

---

## Error Handling Already In Place

Even with the fix, race conditions could still occur (timeout case). But we already handle it:

```typescript
// SyncService.ts:440-452
try {
  await protectedSupabase.query(() =>
    supabase.from('character_instances').insert({
      id: localCharacter.id,
      // ...
    })
  );
} catch (insertError: any) {
  if (
    insertError.message?.includes('duplicate key') ||
    insertError.message?.includes('character_instances_pkey') ||
    insertError.code === '23505'
  ) {
    logger.info('Character already exists remotely (race condition), marking as synced', {
      id: localCharacter.id,
    });
    await localStorageService.markCharacterSynced(localCharacter.id);
    return; // Graceful handling
  }
  throw insertError;
}
```

**Defense in depth:** Even if race condition occurs, we handle it gracefully instead of crashing.

---

## Performance Impact

### Polling Overhead

- Poll every 100ms
- Maximum 50 iterations (5000ms / 100ms)
- Only runs when:
  1. Sync was recently running, AND
  2. User performs critical operation

**Typical case:**

- Sync completes in 200ms
- Polling runs 2-3 times
- Total wait: 200-300ms
- User perceives as "instant"

**Worst case:**

- Sync takes 5 seconds (database issue)
- Polling runs 50 times
- User sees 5 second loading spinner
- Still better than corrupt data

---

## Testing Strategy

### Manual Test Case

**Test 1: Normal Case (Sync Not Running)**

1. Wait for sync to complete (check logs: "Sync completed")
2. Immediately create character
3. **Expected:** Character created instantly, no duplicate key error
4. **Result:** ✅ Passes

**Test 2: Race Condition Case (Sync Running)**

1. Wait until 1-2 seconds before next sync (sync runs every 30s)
2. Create character right as sync starts
3. **Expected:** Character creation waits for sync, then proceeds
4. **Result:** ✅ Passes (with fix)
5. **Before fix:** ❌ Duplicate key error

**Test 3: Timeout Case (Sync Hanging)**

1. Simulate slow network (DevTools: Network throttling)
2. Start sync, immediately create character
3. **Expected:** Wait 5 seconds, log warning, proceed anyway
4. **Result:** ✅ Passes (logged warning)

---

## Related Patterns

### Similar Pattern in Other Services

**None found** - SyncService is the only service with this pattern.

Other services use different approaches:

- **BankingService:** No concurrent operation concerns (operations are atomic)
- **WorkshopService:** No sync pause needed (doesn't create new records)
- **ShopService:** No sync pause needed (doesn't create characters)

---

## Prevention Measures

### Code Review Checklist

When adding code that modifies Supabase directly:

- [ ] Does it create/delete records that sync also manages?
- [ ] If yes, does it use `runWithSyncPaused()`?
- [ ] Is the operation protected from concurrent modification?
- [ ] Are duplicate key errors handled gracefully?

### Future Improvements

Consider adding to `runWithSyncPaused()`:

```typescript
// Future: More detailed logging
logger.debug('Waiting for sync', {
  syncInProgress: this.syncInProgress,
  waitTimeMs: performance.now() - startWait,
  syncStartTimestamp: this.syncStartTimestamp,
});
```

---

## Related Lessons

- [Lesson 33: ProtectedSupabaseClient Returns Unwrapped Data](33-protectedsupabaseclient-return-unwrapped.md) - Related sync bug
- [Lesson 34: Game Store Must Update When Character Changes](34-game-store-reactivity-updatecharacter.md) - Related character update bug

---

## Remember

**When implementing critical operations that modify Supabase:**

1. **Use** `runWithSyncPaused()` to prevent concurrent modification
2. **Wait** for in-flight operations (don't just cancel future ones)
3. **Handle** race condition errors gracefully (defense in depth)
4. **Test** with sync running to verify no race conditions

**Pattern:**

```
Pause Interval → Wait for In-Flight → Execute Operation → Resume Interval
```

---

**Commit:** 1eb6172 - fix(sync): fix character sync duplicate key errors and currency update reactivity

**Session Reference:** Sprint 16 Phase 3 - 2025-10-25
