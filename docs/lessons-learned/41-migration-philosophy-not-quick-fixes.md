# Lesson 41: Migration Philosophy - Migrate, Don't Skip

**Date:** 2025-11-03 (Sprint 18, Session 09)
**Category:** Process Improvement
**Impact:** Critical - Prevents tech debt accumulation during migrations
**Related:** Lesson 38 (Approval Protocol), Platform Abstraction Patterns

---

## The Problem

**Context:** Sprint 18 - React Native Migration, iOS testing phase

When user reported `Cannot read property 'appendChild' of undefined` error (react-hot-toast breaking on React Native), AI assistant attempted to "comment out" and conditionally skip the broken functionality instead of properly migrating it to React Native equivalents.

### What AI Attempted (WRONG)

**First attempt:**

```typescript
// ❌ WRONG - Commented out toast import
// import { toast } from 'react-hot-toast';
```

**Second attempt:**

```typescript
// ❌ WRONG - Conditional runtime logic to skip on native
let toast: any = null;
if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  try {
    const toastModule = require('react-hot-toast');
    toast = toastModule.toast;
  } catch {
    // react-hot-toast not available (native), toast stays null
  }
}

// Make toast calls optional (no-op on native)
const loadingToastId = toast?.loading?.('message') ?? null;
```

**Goal:** "Unblock testing" by making toast functionality skip on React Native

---

## User Feedback (Direct Quotes)

> "you seem to be tunnel visioning again and i'm not sure why. so please take this in before doing anything else. we are doing a migration from react to react-native, things are going to break along the way. we should be fixing them as we encounter the breakage that's the whole point of this migration. do not comment away something that is broken. let's fix the thing and incrementally complete the migration as we go."

> "i want you to migrate the functionality that is currently broken to it's approrpiate react-native counterpart."

> "i rather invest upfront than accumulate tech debt"

---

## Root Cause Analysis

### Why AI Made This Mistake

**Tunnel vision on "unblocking":**

- Focused on getting CharacterSelect to load rather than completing the migration
- Treated breaking web API as an "obstacle" not "the work itself"

**Quick fix mentality:**

- Tried to work around the problem instead of solving it properly
- Prioritized speed over correctness

**Missed the bigger picture:**

- Sprint 18 is a MIGRATION project, not a compatibility layer project
- Breaking things during migration is EXPECTED and GOOD (surfaces what needs migration)
- Commenting out or conditionally skipping = tech debt, not migration

### What AI Missed

**User's explicit philosophy (stated multiple times):**

- "i rather invest upfront than accumulate tech debt"
- The entire point of Sprint 18 is to MIGRATE functionality to React Native
- Breaking web APIs = discovery of what needs migration = THE ACTUAL WORK

**The migration plan clearly shows:**

- Toast migration is Week 3 task (lines 646-674 of migration plan)
- This wasn't a "blocker" - it was the NEXT migration task we were supposed to hit
- Platform abstractions are EXPECTED work, not unexpected bugs

---

## The Correct Approach

### Core Principle

**When web-only code breaks on React Native: MIGRATE it to the native equivalent.**

### DO (Proper Migration)

```typescript
// ✅ CORRECT - Platform-specific abstractions

// packages/core/src/utils/notifications.native.ts
import { Alert } from 'react-native';

export const notifications = {
  success: (message: string) => {
    Alert.alert('Success', message);
  },
  error: (message: string) => {
    Alert.alert('Error', message);
  },
  // ... other methods
};

// packages/core/src/utils/notifications.ts (web)
import { toast } from 'react-hot-toast';

export const notifications = {
  success: (message: string) => {
    toast.success(message);
  },
  error: (message: string) => {
    toast.error(message);
  },
  // ... other methods
};

// Usage (works on both platforms)
import { notifications } from '../utils/notifications';

notifications.success('Survivor recruited!');
```

**Why this is correct:**

- Removes web-only library entirely from native path
- Implements proper React Native equivalent (Alert.alert)
- Makes it WORK on native first
- Cross-platform compatibility as secondary concern
- This is incremental migration work - it's SUPPOSED to happen

### DO NOT (Quick Fixes That Create Tech Debt)

```typescript
// ❌ Comment out broken functionality
// import { toast } from 'react-hot-toast';

// ❌ Add conditional runtime checks to skip functionality
if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  toast.loading('message');
}

// ❌ Use optional chaining to make it a no-op
toast?.loading?.('message') ?? null;

// ❌ Add Platform.OS checks everywhere
if (Platform.OS === 'web') {
  toast.success('message');
}
```

**Why these are wrong:**

- Accumulates tech debt instead of completing migration
- Functionality doesn't work on native (user expects it to)
- Creates maintenance burden (two code paths for same feature)
- Violates user's philosophy: "i rather invest upfront than accumulate tech debt"

---

## The Correct Migration Pattern

**Step-by-step process:**

### 1. Identify the Web API That's Breaking

```bash
# Error message leads you to the web-only library
Cannot read property 'appendChild' of undefined

# Find the culprit
grep -r "react-hot-toast" packages/core/
# Result: HybridCharacterService.ts:8
```

### 2. Find React Native Equivalent

**Use platform-abstraction-patterns.md:**

- Toast notifications (web) → Alert.alert (React Native)
- localStorage (web) → AsyncStorage (React Native)
- CustomEvent (web) → EventEmitter (React Native)
- navigator.onLine (web) → NetInfo (React Native)

### 3. Create Platform-Specific Abstractions

**Pattern:**

- `abstraction.native.ts` - React Native implementation
- `abstraction.ts` - Web implementation
- Same API on both platforms
- Metro/Vite automatically resolve correct version

### 4. Migrate All Usage

```typescript
// Before (web-only)
import { toast } from 'react-hot-toast';
toast.success('Message');

// After (cross-platform)
import { notifications } from '../utils/notifications';
notifications.success('Message');
```

### 5. Test on Both Platforms

- Native: Verify Alert.alert() appears
- Web: Verify toast still works
- No functionality lost, works on both platforms

---

## Forcing Function for Future

**Before implementing ANY fix for broken web code on native:**

### 1. Ask: Is this a compatibility issue or a migration issue?

**Compatibility:**

- Different APIs on both platforms, both need to work
- Solution: Platform-specific abstraction

**Migration:**

- Web-only code, needs native replacement
- Solution: MIGRATE to native equivalent properly

### 2. If migration issue:

- STOP thinking about "quick fixes"
- READ the migration plan/philosophy
- IMPLEMENT the native equivalent properly
- This is EXPECTED work, not a blocker

### 3. If tempted to comment out or conditionally skip:

- STOP immediately
- Recognize this as tech debt, not migration
- Discuss with user if uncertain about correct approach

---

## Evidence This Pattern Works

**Toast Migration Results:**

- **Files created:** 2 (notifications.native.ts, notifications.ts)
- **Files modified:** 1 (HybridCharacterService.ts)
- **Lines of code:** ~130 total
- **Time invested:** ~30 minutes
- **Tech debt created:** 0
- **Functionality migrated:** 100%
- **User satisfaction:** High (acknowledged correct approach)

**What would have happened with quick fix:**

- **Files created:** 0
- **Files modified:** 1 (HybridCharacterService.ts with conditionals)
- **Lines of code:** ~15
- **Time invested:** ~5 minutes
- **Tech debt created:** Medium (conditional logic, no-op functionality)
- **Functionality migrated:** 0% (skipped on native)
- **User satisfaction:** Low (violates migration philosophy)

---

## Related Patterns

**This lesson applies to ALL platform abstractions:**

| Web API          | React Native | Migration Status     |
| ---------------- | ------------ | -------------------- |
| react-hot-toast  | Alert.alert  | ✅ Lesson 41 example |
| localStorage     | AsyncStorage | ⏸️ Next migration    |
| CustomEvent      | EventEmitter | ⏸️ Pending           |
| navigator.onLine | NetInfo      | ⏸️ Pending           |

**Follow this lesson for each migration:**

1. Web API breaks → Good (surfaces migration need)
2. Find RN equivalent → Check platform-abstraction-patterns.md
3. Create abstractions → .native.ts + .ts
4. Migrate usage → Import from abstraction
5. Test both platforms → Verify works everywhere

---

## Integration with Other Lessons

**Lesson 38 (Approval Protocol):**

- Get approval for irreversible operations
- Migration work is NOT irreversible (it's the goal)
- But document the approach before implementing

**Platform Abstraction Patterns:**

- This lesson is the "why" behind the patterns document
- Patterns document is the "how" to implement correctly
- Together they form complete migration guidance

**User Philosophy:**

- "i rather invest upfront than accumulate tech debt"
- This lesson enforces that philosophy in migration work
- Breaking = discovering work = good
- Quick fixes = tech debt = bad

---

## Checklist for AI Assistants

**When web-only code breaks on React Native:**

- [ ] Recognize: "This is migration work, not a bug"
- [ ] Read: platform-abstraction-patterns.md for RN equivalent
- [ ] Plan: Create .native.ts and .ts abstractions
- [ ] Implement: Proper migration (not conditional workaround)
- [ ] Test: Verify works on both platforms
- [ ] Document: Update migration status tracker

**Red flags (STOP and reconsider):**

- [ ] Am I commenting out functionality?
- [ ] Am I adding `if (typeof window !== 'undefined')`?
- [ ] Am I using optional chaining to skip on native?
- [ ] Am I thinking "let's unblock testing"?
- [ ] Am I treating this as a bug to work around?

**If ANY red flag is YES → Read this lesson again, then implement proper migration**

---

## Success Metrics

**How to know you're doing migration correctly:**

✅ **Good signs:**

- Creating .native.ts and .ts files
- Removing web-only imports
- Implementing RN equivalents (Alert, AsyncStorage, etc.)
- Functionality works on both platforms
- No conditional Platform.OS checks in business logic
- Migration status tracker updated

❌ **Bad signs:**

- Commenting out broken code
- Adding runtime platform checks
- Using optional chaining to skip functionality
- Thinking "this is blocking progress"
- No new files created (just conditional logic)
- Functionality doesn't work on native

---

## User Quotes to Remember

> "we are doing a migration from react to react-native, things are going to break along the way"

> "we should be fixing them as we encounter the breakage that's the whole point of this migration"

> "do not comment away something that is broken. let's fix the thing and incrementally complete the migration as we go"

> "i rather invest upfront than accumulate tech debt"

**Translation for AI:**

- Breaking during migration = EXPECTED
- Fix = MIGRATE to RN equivalent
- Don't skip = Make it work properly
- Invest upfront = Do it right the first time

---

## Summary

**The Pattern:**

When web-only code breaks on React Native:

1. ✅ Recognize this as migration work (not a blocker)
2. ✅ Find the React Native equivalent
3. ✅ Create platform-specific abstractions
4. ✅ Migrate all usage properly
5. ✅ Test on both platforms

**The Anti-Pattern:**

When web-only code breaks on React Native:

1. ❌ Comment it out
2. ❌ Add conditional checks
3. ❌ Use optional chaining to skip
4. ❌ Think "let's unblock testing"
5. ❌ Create tech debt

**Remember:** Breaking during migration isn't a problem to solve. It's the WORK itself.

---

**Last Updated:** 2025-11-03
**Sprint:** 18 (React Native Migration)
**Session:** 09 (Deep Link + Android + Production Testing)
