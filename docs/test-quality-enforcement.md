# Test Quality Enforcement Protocol

**Purpose**: Prevent low-quality tests from being committed. This document defines automated gates and manual review steps that Claude MUST follow.

---

## Automated Enforcement (Pre-Commit Hook)

### Phase 1: Current State (Immediate)
**Status**: Migration complete, USER STORY headers missing

**Pre-commit hook runs**:
1. ✅ `gdlint` - Code style validation
2. ✅ `gdformat --check` - Format validation
3. ✅ `godot_test_runner.py` - All tests must pass (0 failures)
4. ⚠️  `test_quality_validator.py --warn-only` - Report issues but don't block

**What blocks commits**:
- Linting errors
- Format errors
- Test failures (any test with status=failed)

**What gets reported (warnings)**:
- Missing USER STORY headers
- Smoke tests (`assert_true(true)`)
- Missing assertion failure messages
- Incorrect payment patterns

### Phase 2: Strict Enforcement (After USER STORY migration)
**Target**: Next sprint

**Pre-commit hook adds**:
4. ❌ `test_quality_validator.py` - BLOCKS commits with:
   - Smoke tests
   - Missing USER STORY headers in NEW test files
   - Incorrect payment patterns
   - Tests without clear failure messages

**Migration Required**:
- [ ] Add USER STORY headers to all 14 existing test files
- [ ] Fix incorrect payment pattern in service_integration_test.gd:71
- [ ] Add failure messages to assertions in save_integration_test.gd

---

## Manual Review Protocol (For Claude)

**BEFORE claiming "tests are complete"**, Claude MUST run this checklist:

### ✅ Pre-Completion Checklist

```bash
# 1. Run full test suite
python3 .system/validators/godot_test_runner.py
# REQUIRED: 0 failures, X passing, Y pending

# 2. Run quality validator
python3 .system/validators/test_quality_validator.py
# REQUIRED: 0 errors (smoke tests, incorrect patterns)
# ACCEPTABLE: Warnings (missing messages, missing USER STORY if migration)

# 3. Run audit script
python3 /tmp/audit_tests.py  # Or equivalent
# REQUIRED: >95% real tests (not smoke tests)

# 4. Manual spot-check: Open 3 random test files
# VERIFY:
# - [ ] Tests verify actual behavior (not just "doesn't crash")
# - [ ] Tests follow Arrange-Act-Assert pattern
# - [ ] Failure messages are clear and actionable
# - [ ] Integration tests use correct patterns (preview → pay → execute)

# 5. Check test coverage of user stories
# VERIFY: Each service/feature has tests mapping to user stories
```

### ❌ Claude is BLOCKED from claiming completion until:
1. All automated checks pass (0 test failures)
2. Quality validator shows 0 errors
3. Audit shows >95% real tests
4. Manual spot-check confirms quality

### If ANY check fails:
Claude MUST:
1. Report the failure to user explicitly
2. Fix the issue
3. Re-run ALL checks
4. NOT claim "tests are complete" until all pass

---

## Test File Requirements

### For NEW test files:
**REQUIRED** (blocking):
- [ ] USER STORY header comment
- [ ] All tests follow Arrange-Act-Assert
- [ ] All assertions have clear failure messages
- [ ] No smoke tests (`assert_true(true)`)
- [ ] Integration tests use correct patterns

**Template**: See [docs/test-file-template.md](test-file-template.md)

### For EXISTING test files (migration):
**REQUIRED** (blocking):
- [ ] All tests pass (0 failures)
- [ ] No smoke tests
- [ ] Integration tests use correct patterns

**RECOMMENDED** (warnings):
- [ ] USER STORY header (to be added in Phase 2)
- [ ] Failure messages on all assertions

---

## Pattern Enforcement

### ✅ Correct Payment Pattern
```gdscript
func test_player_runs_out_of_scrap() -> void:
    BankingService.add_currency(SCRAP, 100)

    var preview = ShopRerollService.get_reroll_preview()  # ← Read-only
    var success = BankingService.subtract_currency(SCRAP, preview.cost)  # ← Pay first
    if success:
        ShopRerollService.execute_reroll()  # ← Only execute if paid
```

### ❌ BLOCKED: Execute Before Pay
```gdscript
func test_player_runs_out_of_scrap() -> void:
    var exec = ShopRerollService.execute_reroll()  # ← WRONG! State mutates first
    var success = BankingService.subtract_currency(SCRAP, exec.charged_cost)  # ← Too late
```

**Why Blocked**: Allows item duplication exploits

### ✅ Correct Assertion Pattern
```gdscript
assert_eq(
    BankingService.get_balance(SCRAP),
    1000,
    "Balance should be 1000 after adding currency"  # ← Clear message
)
```

### ❌ BLOCKED: Smoke Test
```gdscript
func test_function_works() -> void:
    Service.do_something()
    assert_true(true, "Function executed")  # ← BLOCKED! Doesn't verify anything
```

---

## Updating the Pre-Commit Hook

### Current Hook Location
`.git/hooks/pre-commit`

### Add Quality Validator (Phase 2)
```bash
#!/bin/bash
set -e

# ... existing gdlint, gdformat, test runner ...

# Add quality validator (warn-only mode for Phase 1)
echo "Running test quality validator..."
python3 .system/validators/test_quality_validator.py --warn-only || true

# For Phase 2, change to blocking:
# python3 .system/validators/test_quality_validator.py || exit 1
```

---

## How to Use This Document

### For Claude (AI):
1. **BEFORE starting test work**: Read this document
2. **DURING test work**: Follow template from test-file-template.md
3. **BEFORE claiming complete**: Run Pre-Completion Checklist (all 5 steps)
4. **NEVER** bypass these checks - user will verify

### For User (Human):
1. Review test quality validator results in pre-commit output
2. If Claude claims "tests complete", ask: "Did you run the pre-completion checklist?"
3. If doubts, run: `python3 .system/validators/test_quality_validator.py`
4. Block Claude from proceeding until checklist passes

### For CI/CD:
1. GitHub Actions should run same validators
2. PRs blocked if quality validator fails
3. Coverage reports required

---

## Quality Validator Exit Codes

- `0`: All checks pass
- `1`: Errors detected (smoke tests, incorrect patterns)
- `2`: Warnings only (missing messages, missing USER STORY)

**Phase 1**: Exit code 2 (warnings) does NOT block commits
**Phase 2**: Exit code 1 OR 2 blocks commits

---

## Example Violation and Fix

### ❌ BLOCKED Commit
```
❌ Test Quality Errors (BLOCKING):
  • error_service_test.gd: Smoke test detected: test_log_info_executes_without_error
  • service_integration_test.gd:71: Incorrect payment pattern

💡 Fix: Remove smoke tests, use preview → pay → execute pattern
```

### ✅ After Fix
```
✅ All tests pass quality validation

Test Results:
- 203/298 passing (68.1%)
- 0 smoke tests detected
- All integration tests use correct patterns
```

---

## Migration Plan for USER STORY Headers

**Task**: Add USER STORY headers to 14 existing test files

**Estimated Time**: 1 hour

**Template**:
```gdscript
extends GutTest
## Test script for [ServiceName] using GUT framework
##
## USER STORY: "As a [user type], I want to [action] so that [benefit]"
##
## Tests [brief description]
```

**Mapping**:
- banking_service_test.gd → "As a player, I want to earn and spend currency safely"
- shop_reroll_service_test.gd → "As a player, I want to reroll shop with fair costs"
- save_integration_test.gd → "As a player, I want my progress saved reliably"
- [etc. - see test_value_analysis.md for full mapping]

---

## Enforcement Summary

| Phase | Status | Smoke Tests | USER STORY | Payment Pattern | Blocking |
|-------|--------|-------------|------------|-----------------|----------|
| 1 (Now) | Migration complete | ❌ Error | ⚠️ Warning | ❌ Error | Tests + Smoke |
| 2 (Next Sprint) | Strict | ❌ Error | ❌ Error | ❌ Error | All quality checks |

**Current State**: Phase 1 active, pre-commit hook runs validator in warn-only mode

**Goal**: Migrate to Phase 2 after adding USER STORY headers to all existing test files
