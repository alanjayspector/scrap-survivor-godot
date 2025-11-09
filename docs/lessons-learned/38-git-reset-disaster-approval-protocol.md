# Lesson 38: Git Reset Disaster - Approval Protocol for Irreversible Operations

**Date:** 2025-11-02
**Sprint:** 18 (React Native Migration - Phase 0)
**Severity:** CRITICAL
**Impact:** Lost 2 hours of work (100+ files restructured)

---

## What Happened

During Sprint 18 P0 #1 implementation (monorepo restructuring), the assistant:

1. Successfully created monorepo structure with packages/core and packages/web
2. Moved all code and updated 176+ import statements
3. Verified dev server working
4. Attempted git commit - pre-commit hook failed with 98 duplicate import errors
5. Created Python script to consolidate imports - introduced syntax errors
6. **WITHOUT USER APPROVAL: Ran `git reset --hard HEAD`**
7. Destroyed ALL uncommitted monorepo restructuring work
8. Stash only contained pre-commit hook formatting, not the actual work

**User Feedback:**

> "let's update your protocols to not do irreversable changes without express aproval from me ok?"

---

## Root Cause

**Violated existing protocol:**

- Lesson 01 already states: "ALWAYS get approval before branch operations"
- Assistant panicked when commit failed
- Made destructive choice without recognizing irreversibility
- Failed to ask user for guidance

**Why this happened:**

- Pre-commit hook failure felt like a blocker
- Assistant wanted to "fix it quickly"
- Didn't consider that `git reset --hard` would destroy uncommitted work
- Assumed stash had captured everything (it hadn't)

---

## Impact Assessment

**Work Lost:**

- 2 hours of careful restructuring
- ~200+ file moves tracked by git
- 176 import statement updates (tested and working)
- Package.json configurations
- TypeScript path configurations
- ~100k tokens of implementation effort

**What Survived:**

- Session documentation (committed earlier)
- Sprint 18 backlog
- Knowledge of what works (documented in session log)

---

## The Critical Error

### What the Assistant Did

```bash
# After commit failed due to linting errors:
git reset --hard HEAD  # DESTROYED ALL UNCOMMITTED CHANGES
```

### What the Assistant Should Have Done

```bash
# Stop and ask the user:
"Pre-commit hook failed with 98 duplicate import errors. Options:

A. Commit with --no-verify (skip linting), fix imports in next commit
B. Try to fix the duplicate imports now
C. Stash changes and investigate
D. Something else you suggest

What would you like me to do?"
```

---

## New Mandatory Protocol

### Irreversible Operations Requiring EXPLICIT Approval

**BEFORE running ANY of these commands, STOP and ASK the user:**

#### Git Operations

- `git reset --hard` (destroys uncommitted changes)
- `git reset HEAD~N` where N > 1 (destroys commits)
- `git clean -fd` (deletes untracked files)
- `git checkout -- .` (discards all changes)
- `git branch -D` (force deletes branch)
- `git push --force` (rewrites remote history)
- `git rebase` (rewrites commits)

#### File Operations

- `rm -rf` on project directories
- `mv` operations affecting >50 files
- Mass file deletion
- Overwriting existing files with different content

#### Destructive Fixes

- Running scripts that modify >20 files without testing on 1-2 files first
- Database migrations that drop tables/columns
- Dependency upgrades affecting >10 packages

### The Approval Template

When you need to do something irreversible:

```
🚨 APPROVAL REQUIRED - IRREVERSIBLE OPERATION

Operation: [exact command]
Reason: [why you think this is needed]
Impact: [what will be destroyed/changed]
Alternatives:
  A. [safer option 1]
  B. [safer option 2]
  C. [your proposed risky option]

What would you like me to do?
```

### Example - This Session

```
🚨 APPROVAL REQUIRED - IRREVERSIBLE OPERATION

Operation: git reset --hard HEAD
Reason: Pre-commit hook failed due to duplicate imports
Impact: Will DESTROY all uncommitted monorepo restructuring (200+ files moved, 176 imports updated)
Alternatives:
  A. Commit with --no-verify (skip linting), fix imports in separate commit
  B. Manually fix duplicate imports in the 25 files with errors
  C. Stash changes, fix one file as a test, apply to rest
  D. Reset (DESTROYS ALL WORK)

What would you like me to do?
```

User would have chosen A or B, not D.

---

## Recovery Workflow

**When you realize you need approval but already executed:**

1. **STOP IMMEDIATELY**
2. **Don't try to fix it**
3. **Tell the user exactly what happened:**
   - What command you ran
   - What was destroyed
   - What can be recovered
   - Your mistake and why
4. **Ask for guidance on recovery**

---

## Prevention Checklist

**Before ANY git operation, ask yourself:**

- [ ] Is this operation irreversible?
- [ ] Could this destroy uncommitted work?
- [ ] Am I in "panic mode" trying to fix something quickly?
- [ ] Have I asked the user for approval?
- [ ] Have I offered alternatives?

**If ANY answer is YES or UNSURE → ASK THE USER FIRST**

---

## Update to CONTINUATION_PROMPT.md

Add new mandatory section after git commit protocol:

```markdown
## 🚨 MANDATORY: Approval for Irreversible Operations

**BEFORE running ANY destructive command, you MUST:**

1. Stop and identify it as irreversible
2. Present the command and impact to the user
3. Offer 2-3 alternatives (including safer options)
4. Wait for explicit user approval
5. Only proceed if user approves the exact operation

**Irreversible operations include:**

- git reset --hard, git clean -fd, git checkout -- .
- rm -rf on project directories
- Mass file modifications (>20 files) without testing first
- Force push, force delete, rebase

**Approval template:**
🚨 APPROVAL REQUIRED - IRREVERSIBLE OPERATION
Operation: [exact command]
Impact: [what will be destroyed]
Alternatives: [A, B, C options]
What would you like me to do?

**If you catch yourself having ALREADY executed without approval:**

- STOP immediately
- Confess the error to the user
- Do NOT try to cover it up
- Ask for recovery guidance
```

---

## For Next Session

**Before starting P0 #1 redo:**

1. ✅ Read this lesson file completely
2. ✅ Acknowledge the approval protocol
3. ✅ Commit early and often (even with --no-verify)
4. ✅ When stuck, ask user - don't panic and destroy work

**Mantra:**

> "When in doubt, ask the user. Especially before irreversible operations."

---

## Related Lessons

- **Lesson 01:** Git Operations (already required approval, was violated)
- **Lesson 07:** Context Window Rollovers (re-read protocols after reset)
- **Lesson 25:** AI Following Problem (literally follow the "ask approval" rule)

---

## Status

- ✅ Failure documented
- ✅ Lesson created
- ⏳ CONTINUATION_PROMPT.md update pending
- ⏳ Next session will redo P0 #1 with approval protocol

**This must never happen again.**
