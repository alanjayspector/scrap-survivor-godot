# Godot Testing Guide

## Overview

This project uses **custom scene-based testing** with automated pre-commit validation. Tests run in Godot headless mode to avoid conflicts with the editor.

## File Naming Convention

**IMPORTANT**: All test files MUST follow this naming pattern:

### Test Scripts
```
scripts/tests/*_test.gd
```

**Examples:**
- ✅ `banking_service_test.gd`
- ✅ `error_service_test.gd`
- ✅ `game_state_test.gd`
- ❌ `test_banking_service.gd` (old pattern - deprecated)
- ❌ `BankingServiceTest.gd` (wrong case)

### Test Scenes
```
scenes/tests/*_test.tscn
```

**Examples:**
- ✅ `banking_service_test.tscn`
- ✅ `error_service_test.tscn`
- ❌ `test_banking_service.tscn` (old pattern - deprecated)

### Why This Convention?

1. **GUT Framework Compatibility**: The `*_test.gd` pattern is the standard for GUT (Godot Unit Test framework)
2. **Future-Proof**: Easy migration to GUT/GdUnit4 in Week 8+ if needed
3. **Auto-Discovery**: Test frameworks can automatically find `*_test.gd` files
4. **Consistency**: Industry standard for Godot testing

## Creating a New Test

### 1. Create Test Script

Create `scripts/tests/my_service_test.gd`:

```gdscript
extends Node
## Test script for MyService
##
## Run this test:
## 1. Open scenes/tests/my_service_test.tscn in Godot
## 2. Press F5 to run
## 3. Check Output panel for results


func _ready() -> void:
	print("=== MyService Test ===")
	print()

	test_initialization()
	test_functionality()

	print()
	print("=== MyService Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


func test_initialization() -> void:
	print("--- Testing Initialization ---")

	assert(MyService != null, "MyService should be autoloaded")
	print("✓ MyService autoloaded")


func test_functionality() -> void:
	print("--- Testing Functionality ---")

	MyService.do_something()
	assert(MyService.value == 42, "Value should be 42")
	print("✓ Functionality works")
```

### 2. Create Test Scene

Create `scenes/tests/my_service_test.tscn`:

```
[gd_scene load_steps=2 format=3 uid="uid://unique_id_here"]

[ext_resource type="Script" path="res://scripts/tests/my_service_test.gd" id="1_test"]

[node name="MyServiceTest" type="Node"]
script = ExtResource("1_test")
```

### 3. Register Test in Runner

Edit `.system/validators/godot_test_runner.py`:

```python
TEST_SCENES = [
    "scenes/tests/banking_service_test.tscn",
    "scenes/tests/my_service_test.tscn",  # Add your test here
]
```

### 4. Run Tests

**Manual (in Godot):**
1. Open `scenes/tests/my_service_test.tscn`
2. Press F5
3. Check Output panel

**Automated (pre-commit):**
```bash
git add .
git commit -m "Add MyService tests"
# Tests run automatically before commit
```

## Test Structure Best Practices

### Use Helper Functions

```gdscript
func test_something() -> void:
	print("--- Testing Something ---")

	# Setup
	var obj = setup_test_object()

	# Execute
	var result = obj.do_something()

	# Assert
	assert(result == expected, "Result should match expected")
	print("✓ Test passed")
```

### Test Edge Cases

```gdscript
func test_edge_cases() -> void:
	print("--- Testing Edge Cases ---")

	# Test null input
	var result = MyService.process(null)
	assert(result == null, "Should handle null")
	print("✓ Handles null input")

	# Test empty input
	result = MyService.process("")
	assert(result == "", "Should handle empty")
	print("✓ Handles empty input")

	# Test invalid input
	result = MyService.process(-1)
	assert(result == 0, "Should clamp negative")
	print("✓ Handles invalid input")
```

### Lambda Capture Pattern

**IMPORTANT**: GDScript lambdas capture by value. To mutate captured variables:

```gdscript
# ❌ WRONG - Doesn't modify outer variable
var received = false
signal_name.connect(func(): received = true)
assert(received, "Signal should fire")  # FAILS!

# ✅ CORRECT - Use array wrapper
var received = [false]
signal_name.connect(func(): received[0] = true)
assert(received[0], "Signal should fire")  # WORKS!
```

## Running Tests

### Manual Testing in Godot

1. Open Godot editor
2. Navigate to `scenes/tests/`
3. Double-click test scene
4. Press F5 to run
5. Check Output panel for results

### Automated Pre-Commit Testing

Tests run automatically on `git commit`:

```bash
git add scripts/services/my_service.gd
git commit -m "Add MyService"

# Output:
🔍 Running pre-commit checks...
Running Godot tests in headless mode...
  Testing banking_service_test... ✓
  Testing my_service_test... ✓

✅ All tests passed (2 scenes)
```

### Bypass Tests (Use Sparingly)

```bash
git commit --no-verify -m "WIP: incomplete changes"
```

**Only use `--no-verify` for:**
- Work in progress commits
- Non-code changes (docs, assets)
- Emergency hotfixes (fix in next commit!)

## Test Runner Behavior

### When Godot is Open

```
⚠️  Godot is running - skipping automated tests
   Run tests manually in Godot, or close Godot to enable automated testing
```

**Why?** Headless tests can conflict with open editor. Solution:
1. Close Godot before committing, OR
2. Run tests manually in editor

### Test Timeout

Tests timeout after **10 seconds**. If your test times out:

1. **Check for `get_tree().quit()`**: Must be at end of `_ready()`
2. **Infinite loops**: Debug logic errors
3. **Waiting for signals**: Use immediate assertions, not yields

## Validation System

### Pre-Commit Checks (in order)

1. **gdlint**: GDScript static analysis
2. **gdformat**: Code formatting
3. **Test naming validator**: Warns if `test_*.gd` pattern used (non-blocking)
4. **Godot config validator**: project.godot validation
5. **Resource validator**: .tres/.tscn validation
6. **Documentation validator**: Required docs exist
7. **Godot test runner**: Runs all test scenes in headless mode

### Non-Blocking vs Blocking

**Blocking (Fails Commit):**
- gdlint errors
- gdformat violations
- Test failures
- Config/resource errors

**Non-Blocking (Warns Only):**
- Test naming convention warnings

## Future: GUT Framework Migration

Our `*_test.gd` naming convention makes GUT migration straightforward.

### When to Migrate

- **Week 8**: Setting up CI/CD
- **20+ test files**: Auto-discovery valuable
- **Team expansion**: Framework standardization
- **Need reports**: HTML/JUnit XML output

### Migration Steps

1. Install GUT addon: `addons/gut/`
2. Update test extends: `extends Node` → `extends GutTest`
3. Update assertions: `assert(x == y)` → `assert_eq(x, y)`
4. Update pre-commit: Use GUT command-line runner
5. Get reports: HTML test results

See `.system/docs/week-08/godot-testing-frameworks-research.md` for details.

## Troubleshooting

### "Tests Complete" not detected

**Cause**: Missing print statement
**Fix**: Ensure test prints exactly:
```gdscript
print("=== MyService Tests Complete ===")
```

### Test hangs / times out

**Cause**: Missing `get_tree().quit()`
**Fix**: Add to end of `_ready()`:
```gdscript
func _ready() -> void:
	run_tests()
	get_tree().quit()  # CRITICAL!
```

### Test passes in editor, fails in hook

**Cause**: Different environment (headless vs editor)
**Fix**:
- Don't rely on visual features
- Don't use Input/display in tests
- Test pure logic only

### "Project locked" error

**Cause**: Godot editor is open
**Fix**: Close Godot before committing, or run tests manually

## Examples

See existing tests for patterns:
- [banking_service_test.gd](../../scripts/tests/banking_service_test.gd) - Service testing
- [game_state_test.gd](../../scripts/tests/game_state_test.gd) - Signal testing
- [error_service_test.gd](../../scripts/tests/error_service_test.gd) - Error handling

## Summary

✅ **DO:**
- Use `*_test.gd` naming convention
- Add `get_tree().quit()` to all tests
- Test pure logic, not visuals
- Use array wrapper for lambda captures
- Print clear test sections
- Add new tests to test runner

❌ **DON'T:**
- Use `test_*.gd` naming (deprecated)
- Forget `get_tree().quit()` (causes timeout)
- Test Input/display in headless mode
- Use `--no-verify` habitually
- Skip edge case testing
