# GDScript Test File Template (GUT Framework)

**Purpose**: Standardized test structure to prevent low-quality smoke tests and ensure tests verify real functionality.

---

## Template Structure

```gdscript
extends GutTest
## Test script for [ServiceName] using GUT framework
##
## USER STORY: "As a [user type], I want to [action] so that [benefit]"
##
## Tests [brief description of what's being tested]

class_name [ServiceName]Test


func before_each() -> void:
    # Reset service state before each test
    [ServiceName].reset()

    # Set up test preconditions (e.g., tier, state)
    # Example: BankingService.set_tier(BankingService.UserTier.PREMIUM)


func after_each() -> void:
    # Cleanup resources
    pass


## ============================================================================
## SECTION 1: [Feature Category] Tests
## User Story: "As a [user], I want to [action]"
## ============================================================================

func test_[feature]_[expected_behavior]() -> void:
    # Arrange - Set up test data
    var input = [setup test data]

    # Act - Execute the functionality
    var result = [ServiceName].[method](input)

    # Assert - Verify expected behavior
    assert_eq(result.value, expected_value, "Clear failure message")
    assert_true(result.success, "Should succeed when conditions met")


## ============================================================================
## SECTION 2: [Error Handling] Tests
## User Story: "As a [user], I want validation to prevent [bad thing]"
## ============================================================================

func test_[feature]_fails_when_[condition]() -> void:
    # Arrange
    var invalid_input = [setup invalid data]

    # Act
    var result = [ServiceName].[method](invalid_input)

    # Assert - Verify proper error handling
    assert_false(result.success, "Should fail when [condition]")
    assert_eq([state], [unchanged_value], "State should not change on failure")


## ============================================================================
## SECTION 3: [Integration] Tests
## User Story: "As a [user], I want [service A] and [service B] to work together"
## ============================================================================

func test_[feature]_integrates_with_[other_service]() -> void:
    # Arrange - Set up both services
    [ServiceA].setup()
    [ServiceB].setup()

    # Act - Trigger interaction
    var preview = [ServiceA].get_preview()
    var success = [ServiceB].process(preview.cost)
    if success:
        [ServiceA].execute()

    # Assert - Verify both services updated correctly
    assert_eq([ServiceA].state, expected_state)
    assert_eq([ServiceB].state, expected_state)


## ============================================================================
## SECTION 4: [Signal] Tests
## User Story: "As a UI developer, I want to be notified when [event] occurs"
## ============================================================================

func test_[event]_emits_[signal_name]() -> void:
    # Arrange
    watch_signals([ServiceName])

    # Act
    [ServiceName].[trigger_action]()

    # Assert - Verify signal emission
    assert_signal_emitted([ServiceName], "[signal_name]", "Signal should emit when [event]")
    var signal_params = get_signal_parameters([ServiceName], "[signal_name]", 0)
    assert_eq(signal_params[0], expected_value, "Signal should contain correct data")
```

---

## Test Quality Checklist

### ✅ DO:
- [ ] Map each test to a user story or developer requirement
- [ ] Use descriptive test names: `test_[feature]_[expected_behavior]`
- [ ] Follow Arrange-Act-Assert pattern
- [ ] Include clear failure messages in assertions
- [ ] Test both success and failure cases
- [ ] Test integration points between services
- [ ] Verify state changes (not just "didn't crash")
- [ ] Use `before_each()` to reset state (ensure test isolation)

### ❌ DON'T:
- [ ] ❌ Write smoke tests: `assert_true(true, "Function executes")`
- [ ] ❌ Test implementation details (test behavior, not internals)
- [ ] ❌ Duplicate tests (e.g., helper test = original test)
- [ ] ❌ Skip state validation (always verify expected values)
- [ ] ❌ Leave tests without failure messages
- [ ] ❌ Assume defaults (always set up preconditions explicitly)
- [ ] ❌ Test multiple behaviors in one test (one test = one behavior)

---

## Common Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Smoke Test
```gdscript
func test_function_executes_without_error() -> void:
    Service.do_something()
    assert_true(true, "Function executed")  # ← USELESS!
```
**Why Bad**: Doesn't verify the function actually worked
**Fix**: Assert on return value or state change

### ❌ Anti-Pattern 2: Missing State Verification
```gdscript
func test_add_currency() -> void:
    BankingService.add_currency(CurrencyType.SCRAP, 100)
    # ← NO ASSERTION! Test always passes
```
**Why Bad**: Doesn't verify balance increased
**Fix**: `assert_eq(BankingService.get_balance(SCRAP), 100)`

### ❌ Anti-Pattern 3: Execute Before Pay
```gdscript
func test_reroll() -> void:
    var execution = ShopRerollService.execute_reroll()  # ← Mutates state!
    var success = BankingService.subtract_currency(...)  # May fail
    # State already changed even if payment fails!
```
**Why Bad**: Allows item duplication exploits
**Fix**: `preview → pay → execute` pattern

### ❌ Anti-Pattern 4: Missing Tier Setup
```gdscript
func test_save_load() -> void:
    BankingService.add_currency(SCRAP, 1000)  # ← FAILS! FREE tier has 0 cap
```
**Why Bad**: Test doesn't actually test save/load
**Fix**: Set PREMIUM tier in `before_each()`

---

## Example: Good Test File

```gdscript
extends GutTest
## Test script for ShopRerollService using GUT framework
##
## USER STORY: "As a player, I want to reroll shop offerings with escalating costs"
##
## Tests reroll mechanics, cost calculations, and progressive scaling.

class_name ShopRerollServiceTest


func before_each() -> void:
    ShopRerollService.reset_reroll_count()
    BankingService.set_tier(BankingService.UserTier.PREMIUM)


## ============================================================================
## Cost Calculation Tests
## User Story: "As a player, I want fair, predictable reroll costs"
## ============================================================================

func test_exponential_cost_progression() -> void:
    # Arrange - Empty (using initial state)

    # Act - Execute 6 rerolls
    var costs = []
    for i in range(6):
        var exec = ShopRerollService.execute_reroll()
        costs.append(exec.charged_cost)

    # Assert - Verify exponential progression (50 * 2^count)
    assert_eq(costs[0], 50, "First reroll should cost 50")
    assert_eq(costs[1], 100, "Second reroll should cost 100 (2x)")
    assert_eq(costs[2], 200, "Third reroll should cost 200 (4x)")
    assert_eq(costs[3], 400, "Fourth reroll should cost 400 (8x)")
    assert_eq(costs[4], 800, "Fifth reroll should cost 800 (16x)")
    assert_eq(costs[5], 1600, "Sixth reroll should cost 1600 (32x)")


## ============================================================================
## Payment Integration Tests
## User Story: "As a player, I want rerolls to cost currency properly"
## ============================================================================

func test_player_runs_out_of_scrap_rerolling() -> void:
    # Arrange
    BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
    var total_spent = 0

    # Act - Try to reroll 3 times (only 1 will succeed)
    for i in range(3):
        var preview = ShopRerollService.get_reroll_preview()
        var success = BankingService.subtract_currency(
            BankingService.CurrencyType.SCRAP, preview.cost
        )
        if success:
            ShopRerollService.execute_reroll()
            total_spent += preview.cost
        else:
            break  # Stop on insufficient funds

    # Assert - Only first reroll succeeded (100 scrap - 50 cost = 50 remaining)
    assert_eq(total_spent, 50, "Should have spent 50 scrap (only first reroll)")
    assert_eq(
        BankingService.get_balance(BankingService.CurrencyType.SCRAP),
        50,
        "Should have 50 scrap remaining"
    )
```

---

## Review Questions Before Committing Tests

1. **Does each test map to a user story?**
   - If not, is it testing infrastructure/developer requirements?

2. **Does each test verify actual behavior?**
   - No `assert_true(true)` tests
   - All assertions check meaningful values

3. **Does each test follow Arrange-Act-Assert?**
   - Setup → Execute → Verify

4. **Are failure messages clear and actionable?**
   - Good: `"Should have 50 scrap remaining after first reroll"`
   - Bad: `"Test failed"`

5. **Are integration tests using correct patterns?**
   - Payment: `preview → pay → execute`
   - Save/load: Set tier before testing

6. **Can I refactor the implementation without breaking tests?**
   - Tests should verify behavior, not implementation

7. **Do tests isolate failures?**
   - One failure should point to one bug
   - Tests shouldn't cascade fail

---

## Template Usage Instructions

1. **Copy this template** to start a new test file
2. **Replace placeholders** ([ServiceName], [feature], etc.)
3. **Map tests to user stories** from docs/features/ or user story backlog
4. **Run quality checklist** before committing
5. **Audit existing tests** if they don't meet these standards

**Goal**: Every test should answer "What user-facing behavior does this verify?" If you can't answer that, delete the test.
