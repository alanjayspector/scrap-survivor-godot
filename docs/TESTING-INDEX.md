# Testing Documentation Index

**Purpose**: Central index for all testing documentation and standards

---

## 📚 Core Documentation

### 1. [godot-testing-research.md](godot-testing-research.md)
**What**: Research findings on Godot testing best practices, GUT framework patterns, and common pitfalls

**When to read**:
- Before writing ANY test code
- When encountering test failures
- When learning GUT framework

**Key Topics**:
- GUT vs gdunit4 comparison
- Lifecycle hooks (`before_each`, `after_each`)
- Assertion patterns
- Test isolation strategies
- Resource loading in headless mode

---

### 2. [test-file-template.md](test-file-template.md)
**What**: Standardized test file template with quality checklist

**When to use**:
- Creating ANY new test file
- Reviewing existing tests
- Before claiming tests are "complete"

**Key Sections**:
- Template structure with USER STORY mapping
- Quality checklist (✅ DO / ❌ DON'T)
- Anti-patterns to avoid (with examples)
- Integration payment pattern (preview → pay → execute)

---

### 3. [test-quality-enforcement.md](test-quality-enforcement.md)
**What**: Automated enforcement protocol and manual review checklist

**When to use**:
- Before EVERY commit
- When pre-commit hook fails
- After completing test work

**Key Sections**:
- Pre-commit hook configuration
- Automated quality validator
- Manual review checklist (5 steps)
- Pattern enforcement rules

---

### 4. [gut-migration-phase3-status.md](gut-migration-phase3-status.md)
**What**: Complete Phase 3 migration report with all fixes applied

**When to read**:
- Understanding what was fixed and why
- Learning from past mistakes
- Reference for correct patterns

**Key Sections**:
- Final test results (203 passing, 0 failing)
- Root cause analysis of all 11 failures
- Quality audit results (99.7% real tests)
- Fixes applied (payment pattern, tier setup, etc.)

---

### 5. [godot-headless-resource-loading-guide.md](godot-headless-resource-loading-guide.md)
**What**: Technical guide for handling resource loading in headless CI

**When to read**:
- Writing tests that load .tres resources
- Debugging resource loading failures in CI
- Understanding ENABLE_RESOURCE_TESTS toggle

**Key Topics**:
- Why resources fail in headless mode
- Conditional test execution pattern
- Toggle constants (ENABLE_RESOURCE_TESTS, ENABLE_WEAPON_TESTS)

---

## 🛠️ Tools & Validators

### 1. Test Quality Validator
**Location**: `.system/validators/test_quality_validator.py`

**Usage**:
```bash
# Strict mode (blocks on errors)
python3 .system/validators/test_quality_validator.py

# Warn-only mode (report but don't block)
python3 .system/validators/test_quality_validator.py --warn-only
```

**What it checks**:
- ❌ Smoke tests (`assert_true(true)`)
- ❌ Incorrect payment patterns (execute before pay)
- ⚠️ Missing USER STORY headers
- ⚠️ Missing assertion failure messages

### 2. Test Audit Script
**Location**: `/tmp/audit_tests.py` (or run inline)

**Usage**:
```python
# Count smoke tests vs real tests across all files
python3 /tmp/audit_tests.py
```

**Output**: Per-file breakdown of real tests vs smoke tests

### 3. GUT Test Runner
**Location**: `.system/validators/godot_test_runner.py`

**Usage**:
```bash
python3 .system/validators/godot_test_runner.py
```

**What it does**:
- Runs all GUT tests in headless mode
- Reports passing/failing/pending counts
- Exits with non-zero on failures (blocks commits)

---

## 📋 Quick Reference

### Before Writing Tests
1. ✅ Read [godot-testing-research.md](godot-testing-research.md)
2. ✅ Copy [test-file-template.md](test-file-template.md) structure
3. ✅ Map tests to user stories

### While Writing Tests
1. ✅ Follow Arrange-Act-Assert pattern
2. ✅ Use correct integration patterns (preview → pay → execute)
3. ✅ Add clear failure messages to all assertions
4. ✅ Set up proper test state (e.g., PREMIUM tier for banking tests)

### Before Claiming "Complete"
1. ✅ Run full test suite (`godot_test_runner.py`) - Must pass
2. ✅ Run quality validator - Must show 0 errors
3. ✅ Run audit script - Must show >95% real tests
4. ✅ Manual spot-check 3 random files
5. ✅ Verify user story mapping

**See [test-quality-enforcement.md](test-quality-enforcement.md) for full checklist**

---

## 🚫 Common Mistakes (And How to Avoid Them)

### Mistake 1: Smoke Tests
❌ **Bad**:
```gdscript
func test_function_works() -> void:
    Service.do_something()
    assert_true(true, "Function executed")  # Doesn't verify anything!
```

✅ **Good**:
```gdscript
func test_add_currency_increases_balance() -> void:
    BankingService.add_currency(SCRAP, 100)
    assert_eq(BankingService.get_balance(SCRAP), 100, "Balance should be 100")
```

**Prevention**: Quality validator blocks smoke tests

---

### Mistake 2: Wrong Payment Pattern
❌ **Bad**:
```gdscript
var exec = ShopRerollService.execute_reroll()  # Mutates state!
var success = BankingService.subtract_currency(...)  # Too late
```

✅ **Good**:
```gdscript
var preview = ShopRerollService.get_reroll_preview()  # Read-only
var success = BankingService.subtract_currency(preview.cost)  # Pay first
if success:
    ShopRerollService.execute_reroll()  # Only if paid
```

**Prevention**: Quality validator blocks incorrect pattern

---

### Mistake 3: Missing Test State Setup
❌ **Bad**:
```gdscript
func test_save_load() -> void:
    BankingService.add_currency(SCRAP, 1000)  # FAILS! FREE tier has 0 cap
```

✅ **Good**:
```gdscript
func before_each() -> void:
    BankingService.set_tier(PREMIUM)  # Now add_currency works
```

**Prevention**: Read [gut-migration-phase3-status.md](gut-migration-phase3-status.md) for examples

---

### Mistake 4: Missing USER STORY
❌ **Bad**: No comment explaining what user need this tests

✅ **Good**:
```gdscript
## USER STORY: "As a player, I want to earn scrap from dismantling items"
```

**Prevention**: Quality validator warns when missing (will block in Phase 2)

---

## 📊 Current Test Quality Status

**As of Phase 3 completion**:
- ✅ 203/298 tests passing (68.1%)
- ✅ 0/298 failing (0%)
- ⏳ 95/298 pending (resource tests for GUI only)
- ✅ 297/298 tests verify real functionality (99.7%)
- ❌ 1/298 is documented placeholder

**Quality Metrics**:
- Smoke tests: 0 (removed)
- Incorrect payment patterns: 0 (fixed)
- Tests with clear failure messages: ~94% (3 warnings remaining)
- Tests with USER STORY headers: 0/14 (migration pending)

---

## 🎯 Next Steps

### Phase 2: Strict Enforcement
**Goal**: Add USER STORY headers to all 14 test files
**Estimated Time**: 1 hour
**Blocker**: None - can start anytime

**Tasks**:
1. Add USER STORY headers using [test-file-template.md](test-file-template.md)
2. Fix 3 remaining assertions without failure messages
3. Enable strict mode in pre-commit hook
4. Update [test-quality-enforcement.md](test-quality-enforcement.md) to Phase 2

### Future: CI/CD Integration
- Add GitHub Actions workflow
- Run quality validator on all PRs
- Require green tests before merge
- Generate coverage reports

---

## 📞 Getting Help

**If tests are failing**:
1. Check [godot-testing-research.md](godot-testing-research.md) for patterns
2. Review [gut-migration-phase3-status.md](gut-migration-phase3-status.md) for similar issues
3. Run quality validator to find pattern violations

**If unsure about test quality**:
1. Run quality validator
2. Check [test-file-template.md](test-file-template.md) anti-patterns section
3. Compare against examples in [gut-migration-phase3-status.md](gut-migration-phase3-status.md)

**If creating new tests**:
1. Start with [test-file-template.md](test-file-template.md)
2. Follow [test-quality-enforcement.md](test-quality-enforcement.md) checklist
3. Run quality validator before claiming complete
