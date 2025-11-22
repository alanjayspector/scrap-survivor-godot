# Git Hooks Improvements
**Week 16 - Process Improvement**

## Problem
Empty commits (commit 777eeff) where work was claimed but no file changes existed, leading to GitHub CI failures that could have been caught locally.

## Solution: Multi-Layer Validation

### 1. Empty Commit Detection (Pre-Commit Hook)
**Location:** `.git/hooks/pre-commit` (lines 95-106)

**What it does:**
- Detects commits with no staged file changes
- Blocks empty commits (except merges and explicit `--allow-empty`)
- Runs BEFORE any validators, failing fast

**Error message:**
```
❌ ERROR: Attempting to create empty commit
   No files staged for commit

   This check prevents commits where work is claimed but no changes exist.
   If you need an empty commit (rare), use: git commit --allow-empty
```

**Prevents:**
- Commits where Edit tool failed but commit proceeded
- Commits claiming fixes with no actual file changes

### 2. Fix Claim Validation (Commit-Msg Hook)
**Location:** `.system/hooks/commit-msg` (lines 17-31)

**What it does:**
- Checks if commit message starts with "fix"
- Verifies that files are actually being changed
- Allows merges to be empty

**Error message:**
```
❌ Commit message claims 'fix' but no files are being changed

   This prevents empty commits claiming to fix issues.
   Either stage your changes or use a different commit type.
```

**Prevents:**
- Specifically targets "fix" commits with no changes
- Catches the exact scenario from commit 777eeff

### 3. Pre-Push Full Validation
**Location:** `.git/hooks/pre-push`

**What it does:**
- Runs full `gdlint scripts/` before push (same as GitHub Actions)
- Runs `gdformat --check scripts/` to verify formatting
- Catches issues BEFORE they reach GitHub CI

**Benefits:**
- Immediate local feedback vs waiting for GitHub CI
- Saves time (no push → wait → fail → fix → push cycle)
- Same validation as CI, so if pre-push passes, CI should pass

**Error message:**
```
❌ Pre-push validation failed

Fix the errors above before pushing to avoid GitHub CI failure
```

## How This Prevents The Issue

**Original Problem Flow:**
1. Claude attempts to fix enum (Edit tool fails silently)
2. Claude commits with message "fix: ..." (empty commit created ❌)
3. User pushes to GitHub
4. GitHub Actions fails (enum still broken)
5. Time wasted debugging

**New Protected Flow:**
1. Claude attempts to fix enum (Edit tool fails silently)
2. Claude tries to commit with "fix: ..."
3. **Pre-commit hook:** "❌ No files staged" → commit blocked ✅
4. OR: Commit succeeds with files, user pushes
5. **Pre-push hook:** Runs full gdlint → catches enum error ✅
6. User fixes locally, no GitHub CI failure

## Testing The Hooks

### Test Empty Commit Detection
```bash
# This should FAIL with empty commit error
git commit --allow-empty -m "test: empty commit"

# This should SUCCEED (explicit override)
git commit --allow-empty -m "test: empty commit" --allow-empty
```

### Test Fix Claim Validation
```bash
# Stage no files, try to commit a fix
git commit -m "fix: broken feature"
# Should FAIL: "Commit message claims 'fix' but no files are being changed"
```

### Test Pre-Push Validation
```bash
# Introduce a lint error in a script
echo "var x = 1  # line too long line too long line too long line too long line too long line too long line too long line too long line too long" >> scripts/test.gd
git add scripts/test.gd
git commit -m "test: add bad script"

# Try to push
git push origin main
# Should FAIL with gdlint errors before push completes
```

## Bypass Options (Emergencies Only)

### Skip Pre-Commit
```bash
git commit --no-verify  # ⚠️ Bypasses ALL pre-commit checks
```

### Skip Pre-Push
```bash
git push --no-verify  # ⚠️ Bypasses pre-push validation
```

**⚠️ Warning:** Only use `--no-verify` in genuine emergencies. These flags bypass all safety checks.

## Process Improvements for Claude

1. **Verify Edits Before Commit:**
   - After Edit tool, re-read affected section
   - Confirm changes actually applied

2. **Show Git Diff Before Commit:**
   - Run `git diff --cached` to see what's being committed
   - Verify changes match intent

3. **Post-Commit Verification:**
   - After commit, read file again to verify persistence
   - Catches cases where changes reverted

## Related Files
- `.git/hooks/pre-commit` - Enhanced with empty commit detection
- `.system/hooks/commit-msg` - Enhanced with fix claim validation
- `.git/hooks/pre-push` - NEW: Full lint before push
- `.github/workflows/gdscript-lint.yml` - GitHub Actions CI (matches pre-push)

## Maintenance
All hooks are version-controlled:
- Pre-commit: `.git/hooks/pre-commit` (generated from install script)
- Commit-msg: Symlinked to `.system/hooks/commit-msg` ✅
- Pre-push: `.git/hooks/pre-push` (generated)

To regenerate hooks after clone: `./install-hooks.sh` (if exists)
