# Lesson 39: Directory Awareness Protocol

**Date Created:** 2025-11-02
**Last Updated:** 2025-11-03 (Session 13 - 3rd consecutive violation)
**Sprint:** 18
**Severity:** CRITICAL
**Category:** Process / Safety
**Status:** ⚠️ ACTIVE VIOLATION PATTERN - 3 consecutive sessions

---

## The Problem

AI assistants frequently start work without verifying their current directory, leading to:

- Failed commands (`cd packages/native` when already in `packages/core`)
- Wrong file operations (editing files in unexpected locations)
- Wasted time debugging "file not found" errors
- Risk of creating files in wrong locations

**Evidence:** Session 05 (Sprint 18) - Started work in `/packages/core`, tried `cd packages/native` without checking, failed.

**User Feedback:**

> "you did it just now and i've seen you do it in a few other sessions where you start work not knowing what directory you were in. this has bit us in the ass a few times now."

---

## The Root Cause

AI assistants begin sessions with no knowledge of:

- What directory they're in
- What the project root path is
- Whether previous commands changed the working directory

This leads to assumptions about current location that are often wrong.

---

## The Solution: Directory Awareness Protocol

### 🚨 THE GOLDEN RULE: ONE `cd` AT START, ABSOLUTE PATHS ALWAYS 🚨

**You are allowed to use `cd` EXACTLY ONCE per session:**

1. **At session start (Pre-flight Step 7):** `pwd && cd /home/alan/projects/scrap-survivor && pwd`
2. **For the rest of the session:** NEVER use `cd` again - ONLY use absolute paths

**This is NOT negotiable. If you find yourself typing `cd` after pre-flight, STOP.**

---

### MANDATORY: First Command of Every Session (Pre-Flight Step 7)

```bash
pwd && cd /home/alan/projects/scrap-survivor && pwd
```

**Output both directories:**

- Before cd: `/some/unknown/directory` or `/home/alan/projects/scrap-survivor/packages/core/src/services`
- After cd: `/home/alan/projects/scrap-survivor`

**This is the ONLY time you may use `cd` in the entire session.**

---

### MANDATORY: During Session - ABSOLUTE PATHS ONLY

After pre-flight, you MUST use absolute paths for ALL operations:

**✅ CORRECT - Absolute Paths:**

```bash
# Git operations
git add /home/alan/projects/scrap-survivor/packages/core/src/services/BankingService.ts

# File operations
npx tsc --noEmit -p /home/alan/projects/scrap-survivor/packages/native/tsconfig.json

# Read files
cat /home/alan/projects/scrap-survivor/packages/core/src/services/TierService.ts
```

**❌ WRONG - Using cd During Session:**

```bash
# NEVER DO THIS after pre-flight
cd packages/core/src/services  # ❌ VIOLATION
cd /home/alan/projects/scrap-survivor  # ❌ VIOLATION (even to go back to root!)

# If you ended up in wrong directory, DON'T use cd to fix it
# Use absolute paths instead
```

---

### Emergency Recovery: If You End Up in Wrong Directory

**If you accidentally end up in a subdirectory (e.g., after a tool call):**

**❌ DON'T DO THIS:**

```bash
cd /home/alan/projects/scrap-survivor  # Violates "ONE cd" rule
```

**✅ DO THIS INSTEAD:**

```bash
# Just use absolute paths for everything going forward
git add /home/alan/projects/scrap-survivor/some/file.ts
```

**The directory you're "in" doesn't matter if you always use absolute paths.**

---

## Integration with CONTINUATION_PROMPT.md

**Add to Pre-Flight Checklist (Step 7):**

```markdown
[ ] 7. VERIFY CURRENT DIRECTORY AND NAVIGATE TO PROJECT ROOT
Command: pwd && cd /home/alan/projects/scrap-survivor && pwd
Proof: State both directories (before and after cd)
```

**This must happen BEFORE:**

- Running git status
- Running npm test
- Any file operations
- Any directory navigation

---

## Safe Patterns

### ✅ CORRECT - Always Use Absolute Paths or Verify First

```bash
# Pattern 1: Absolute paths (SAFEST)
cd /home/alan/projects/scrap-survivor/packages/native
npm install base-64

# Pattern 2: Verify, then navigate
pwd
cd /home/alan/projects/scrap-survivor
cd packages/native
npm install base-64

# Pattern 3: Single-line navigation from known root
cd /home/alan/projects/scrap-survivor && cd packages/native && npm install base-64
```

### ❌ WRONG - Assumptions Without Verification

```bash
# BAD: Assumes you're in project root
cd packages/native
npm install base-64

# BAD: Relative paths without pwd check
ls -la packages/

# BAD: File operations without location verification
npm test
```

---

## Why This Matters

**Past Incidents - PATTERN OF REPEATED VIOLATIONS:**

1. **Session 05 (Sprint 18):** Failed `cd packages/native` because in wrong directory
2. **Session 11 (Sprint 18):** Used `cd` during session, violated absolute path rule
3. **Session 12 (Sprint 18):** Used `cd` during session, violated absolute path rule
4. **Session 13 (Sprint 18):** Used `cd /home/alan/projects/scrap-survivor` DURING session to fix git commit error
   - User feedback: "my dude you are fucking up directories again"
   - User feedback: "this is the 3rd consecutive session where you've made this specific kind of violation"

**Why 3 Consecutive Violations Occurred:**

The AI completed pre-flight Step 7 correctly (ONE `cd` at session start), but then:

- Read tool calls from subdirectories left shell in `/packages/core/src/services`
- AI panicked during git commit error
- Instead of using absolute path, used `cd` to "go back to root"
- **This violated the "ONE cd per session" rule**

**The Fix:**

- **AT SESSION START:** `pwd && cd /home/alan/projects/scrap-survivor && pwd` (Pre-flight Step 7)
- **DURING SESSION:** If you end up in wrong directory, DON'T use `cd` - use absolute paths
- **Example:** `git add /home/alan/projects/scrap-survivor/file.ts` (not `cd /home... && git add file.ts`)

---

## Verification Template

**Use this at start of EVERY session:**

```bash
# Step 1: Where am I?
pwd

# Step 2: Go to project root
cd /home/alan/projects/scrap-survivor

# Step 3: Confirm I'm there
pwd
# Expected output: /home/alan/projects/scrap-survivor

# Step 4: Now I can safely work
git status
```

---

## Integration Checklist

- [x] Add to CONTINUATION_PROMPT.md Pre-Flight Checklist (Step 7) - COMPLETED 2025-11-02
- [x] Enhanced with "Golden Rule" section - COMPLETED 2025-11-03 (after 3rd violation)
- [ ] Add to before-you-start-checklist.md
- [ ] Reference in lessons-learned/README.md (Critical section)
- [ ] Update all session templates to include pwd verification

**Status:** Pre-flight Step 7 exists but AI continues to violate "absolute paths only" rule during sessions

---

## Related Lessons

- Lesson 01: Git operations approval protocol
- Lesson 38: Git reset disaster (directory awareness could have prevented)
- Lesson 25: AI following problem (not following = not checking directory)

---

## Key Takeaway

**NEVER assume you know where you are. ALWAYS verify with `pwd` first.**

**Safe AI behavior:**

1. `pwd` (where am I?)
2. `cd /home/alan/projects/scrap-survivor` (go to known location)
3. `pwd` (confirm I'm there)
4. Now work safely

**Unsafe AI behavior:**

1. `cd packages/native` (assumption!)
2. Command fails
3. Confusion and wasted time

---

**Remember:** Taking 2 seconds to run `pwd` saves minutes of debugging.
