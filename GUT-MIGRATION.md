# GUT Framework Migration Plan
## Migrating from Node-based Tests to GUT Framework

**Status**: In Progress
**Started**: Week 6 Day 6
**Estimated Completion**: Week 6 Day 7

---

## Why Migrate to GUT Now?

### Strategic Timing
- ✅ **14 test files** - Not too early (wasteful), not too late (massive refactor)
- ✅ **All tests passing** - Clean baseline to migrate from
- ✅ **Simple structure** - Most tests are basic assert() calls, easy to convert
- ✅ **Documentation ready** - [docs/godot-testing-research.md](docs/godot-testing-research.md) has 2057 lines of GUT patterns
- ✅ **Enforcement ready** - Test patterns validator already written for GUT

### Technical Benefits

**Immediate:**
- Better test structure (lifecycle hooks: before_each, after_each, before_all, after_all)
- Rich assertion library (assert_eq, assert_true, assert_signal_emitted vs basic assert())
- Proper test isolation (each test gets fresh instances)
- Class-based organization

**Medium-term:**
- Service mocking for integration tests (critical for service architecture)
- Parameterized tests reduce duplication
- Better CI/CD reporting (JUnit XML output)
- Signal testing with wait_for_signal()

**Long-term:**
- Industry-standard testing approach
- Easier onboarding for new developers
- Scalable to 100+ test files
- Test doubles (stubs, spies, mocks) for complex scenarios

---

## Migration Phases

### Phase 1: Setup GUT Framework ✅ In Progress

**Goal**: Install and configure GUT for both editor and headless execution.

**Tasks**:
1. ✅ Create this migration plan
2. ⏳ Install GUT addon from Godot Asset Library
3. ⏳ Enable GUT plugin in Project Settings
4. ⏳ Configure GUT settings (.gutconfig.json)
5. ⏳ Update godot_test_runner.py to use GUT's CLI
6. ⏳ Verify GUT runs in headless mode
7. ⏳ Update pre-commit hook to use GUT

**Estimated Time**: 30 minutes

**Success Criteria**:
- GUT panel visible in Godot editor
- Can run tests from editor GUT panel
- Can run tests headless via CLI
- Pre-commit hook executes GUT tests

---

### Phase 2: Pilot Migration (2 Test Files)

**Goal**: Convert 2 simple test files to validate migration approach.

**Selected Files**:
1. `banking_service_test.gd` - Simple service with straightforward assertions
2. `stat_service_test.gd` - Another simple service

**Tasks**:
1. Convert `banking_service_test.gd`:
   - Change `extends Node` → `extends GutTest`
   - Add `class_name BankingServiceTest`
   - Wrap `_ready()` test orchestration in `before_each()` and test methods
   - Convert `assert()` → `assert_eq()`, `assert_true()`, etc.
   - Add `after_each()` for cleanup
2. Convert `stat_service_test.gd`:
   - Same process as above
3. Run both tests in editor
4. Run both tests headless
5. Verify pre-commit hook passes
6. Document any gotchas or patterns discovered

**Estimated Time**: 1 hour

**Success Criteria**:
- Both pilot tests run successfully in editor
- Both pilot tests run successfully headless
- Pre-commit hook passes with GUT tests
- Migration pattern documented for remaining files

---

### Phase 3: Full Migration (Remaining 12 Test Files)

**Goal**: Convert all remaining test files to GUT framework.

**Files to Convert**:
1. `enemy_loading_test.gd`
2. `entity_classes_test.gd`
3. `error_service_test.gd`
4. `game_state_test.gd`
5. `item_resources_test.gd`
6. `logger_test.gd`
7. `recycler_service_test.gd`
8. `save_integration_test.gd`
9. `save_system_test.gd`
10. `service_integration_test.gd`
11. `shop_reroll_service_test.gd`
12. `weapon_loading_test.gd`

**Tasks**:
1. Convert each file following pilot pattern
2. Run all tests after each conversion
3. Fix any issues discovered
4. Update test naming to follow convention: `test_[object]_[action]_[result]`
5. Add lifecycle hooks where beneficial
6. Add class_name declarations to all tests

**Estimated Time**: 2-3 hours (10-15 min per file)

**Success Criteria**:
- All 14 test files use GUT framework
- All tests passing in editor
- All tests passing headless
- Pre-commit hook passes
- Test patterns validator shows 0 warnings (all tests use GUT)

---

### Phase 4: Enable Strict Validation

**Goal**: Switch test patterns validator from WARNING to ERROR for non-GUT tests.

**Tasks**:
1. Update `test_patterns_validator.py`:
   - Change `not_using_gut` from `severity="warning"` to `severity="error"`
2. Update `.system/hooks/pre-commit`:
   - Change test patterns validator from non-blocking to blocking
3. Update `.github/workflows/pattern-validation.yml`:
   - Remove `|| true` from test patterns check
4. Update ENFORCEMENT-SYSTEM.md:
   - Document that GUT is now required for all tests
5. Test that validator blocks non-GUT tests

**Estimated Time**: 15 minutes

**Success Criteria**:
- Validator blocks commits with non-GUT tests
- CI/CD fails on non-GUT tests
- Documentation updated

---

### Phase 5: Enhance Tests (Future)

**Goal**: Leverage GUT's advanced features to improve test quality.

**Enhancements** (prioritized):
1. **Add integration tests with proper mocking** (Week 7)
   - Mock BankingService in ShopRerollService tests
   - Mock SaveSystem in service integration tests
   - Use GUT's doubles for external dependencies

2. **Use parameterized tests for repeated scenarios** (Week 7)
   - Stat calculation tests (damage, health, speed)
   - Currency conversion tests
   - Validation tests with multiple inputs

3. **Add signal testing with wait_for_signal** (Week 7)
   - Test service signals properly
   - Test UI event emissions
   - Test async operations

4. **Implement test doubles for external dependencies** (Week 8+)
   - Stub file system for save tests
   - Mock Supabase for backend tests
   - Spy on analytics events

**Estimated Time**: Ongoing as features added

---

## Migration Pattern (Template)

### Before (Node-based)

```gdscript
extends Node

func _ready() -> void:
    print("=== BankingService Test ===")
    test_initial_state()
    test_add_currency()
    print("=== Tests Complete ===")
    get_tree().quit()

func test_initial_state() -> void:
    print("--- Testing Initial State ---")
    BankingService.reset()

    assert(
        BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0,
        "Initial scrap should be 0"
    )

    print("✓ Initial balances correct")
```

### After (GUT-based)

```gdscript
extends GutTest

class_name BankingServiceTest

var service: BankingService

func before_each() -> void:
    # Fresh service instance for each test
    service = BankingService.new()
    service.reset()

func after_each() -> void:
    # Cleanup
    if service:
        service.queue_free()

func test_initial_state_scrap_balance_is_zero() -> void:
    # Arrange (done in before_each)

    # Act
    var scrap_balance = service.get_balance(BankingService.CurrencyType.SCRAP)

    # Assert
    assert_eq(scrap_balance, 0,
             "Initial scrap balance should be 0")

func test_add_currency_increases_balance() -> void:
    # Arrange
    var amount = 100

    # Act
    service.add_currency(BankingService.CurrencyType.SCRAP, amount)

    # Assert
    assert_eq(service.get_balance(BankingService.CurrencyType.SCRAP), amount,
             "Adding currency should increase balance by amount")
```

### Key Changes

1. **extends GutTest** instead of `extends Node`
2. **class_name** declaration added
3. **before_each()** sets up fresh state
4. **after_each()** cleans up
5. **assert_eq()** instead of `assert(x == y)`
6. **Descriptive test names** following convention
7. **Arrange-Act-Assert** pattern (optional but recommended)
8. **No manual orchestration** in _ready() - GUT discovers and runs tests

---

## GUT Configuration

### .gutconfig.json (to be created)

```json
{
    "dirs": [
        "res://scripts/tests/"
    ],
    "include_subdirs": true,
    "log_level": 1,
    "should_maximize": true,
    "compact_mode": false,
    "junit_xml_file": "res://test_results.xml",
    "junit_xml_timestamp": false,
    "prefix": "test_",
    "suffix": ".gd",
    "tests": [],
    "selected": "",
    "double_strategy": "SCRIPT_ONLY",
    "pre_run_script": "",
    "post_run_script": "",
    "color_output": true
}
```

### CLI Command (for headless)

```bash
# Run all tests headless
godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://scripts/tests/ -gexit

# Run all tests headless with JUnit XML output
godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://scripts/tests/ -gexit -gjunit_xml_file=res://test_results.xml
```

---

## Risk Assessment

### Low Risk
- GUT is mature (10+ years, 2000+ stars on GitHub)
- Well-documented
- Active maintenance
- Large community

### Medium Risk
- Learning curve for team (mitigated by docs/godot-testing-research.md)
- Potential CI/CD config changes (mitigated by planning)

### Mitigation Strategies
1. Pilot migration first (2 files)
2. Keep old tests until migration complete
3. Document all gotchas
4. Run both old and new tests in parallel during transition (if needed)

---

## Rollback Plan

**If migration fails or blocked:**

1. Revert changes to test files (git checkout)
2. Disable GUT plugin
3. Keep test_patterns_validator.py in non-blocking mode
4. Document blockers for future attempt

**Rollback Triggers:**
- GUT doesn't work in headless mode
- Tests fail after migration with no clear fix
- Performance issues with GUT
- Team decision to postpone

---

## Success Metrics

### Quantitative
- ✅ All 14 test files converted to GUT
- ✅ 100% test pass rate (editor)
- ✅ 100% test pass rate (headless)
- ✅ Pre-commit hook passes
- ✅ CI/CD green

### Qualitative
- ✅ Tests easier to read and understand
- ✅ Tests easier to maintain
- ✅ Test failures provide clear error messages
- ✅ New tests follow consistent pattern

---

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Setup | 30 min | 🟡 In Progress |
| Phase 2: Pilot (2 files) | 1 hour | ⚪ Not Started |
| Phase 3: Full Migration (12 files) | 2-3 hours | ⚪ Not Started |
| Phase 4: Enable Validation | 15 min | ⚪ Not Started |
| **Total** | **4-5 hours** | **25% Complete** |

Phase 5 (Enhancements) is ongoing and not included in migration timeline.

---

## References

- [GUT Framework GitHub](https://github.com/bitwes/Gut)
- [docs/godot-testing-research.md](docs/godot-testing-research.md) - Our GUT patterns guide
- [GUT Wiki](https://github.com/bitwes/Gut/wiki)
- [GUT Quick Start](https://github.com/bitwes/Gut/wiki/Quick-Start)

---

## Updates

### Week 6 Day 6 - Migration Started
- Created this migration plan
- Starting Phase 1: GUT setup
