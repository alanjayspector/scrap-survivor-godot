# Running Tests in Godot Editor

**Last Updated**: 2025-01-10
**Godot Version**: 4.5.1
**Test Framework**: GUT (Godot Unit Test)

This guide explains how to run tests inside the Godot Editor (non-CI mode), including resource-loading tests and weapon tests that are disabled in headless CI mode.

---

## 📋 Quick Start

### 1. Enable Resource Tests
Resource tests (weapons, items, perks) are disabled by default in headless CI. To enable them in Godot Editor:

```gdscript
# In Godot Editor Console or Project Settings
OS.set_environment("ENABLE_RESOURCE_TESTS", "true")
OS.set_environment("ENABLE_WEAPON_TESTS", "true")
```

**Alternative**: Add to Project Settings → General → Application → Boot Splash:
```
Environment Variables:
ENABLE_RESOURCE_TESTS=true
ENABLE_WEAPON_TESTS=true
```

### 2. Open GUT Panel
1. Launch Godot Editor
2. Go to **Project → Project Settings → Plugins**
3. Enable **GUT** plugin (if not already enabled)
4. GUT panel should appear at bottom of editor
5. If not visible: **View → Bottom Panel → GUT**

### 3. Run Tests
**Option A: Run All Tests**
- Click **"Run All"** button in GUT panel
- All test files will execute sequentially

**Option B: Run Single Test File**
- Click test file name in GUT panel list
- Click **"Run Selected"** button

**Option C: Run Specific Test**
- Open test file in script editor
- Click **"Run This Script"** button in GUT panel

---

## 🔧 Detailed Setup

### Install GUT Plugin (if not installed)
1. Open Godot Editor
2. **AssetLib** tab at top
3. Search for **"GUT"**
4. Download and install **GUT - Godot Unit Test** by bitwes
5. Enable in Project Settings → Plugins

### Configure GUT Settings
1. Click **GUT Settings** (gear icon) in GUT panel
2. Recommended settings:
   - **Directory**: `res://scripts/tests/`
   - **Prefix**: (empty - finds all files ending in `_test.gd`)
   - **Suffix**: `_test.gd`
   - **Include Subdirectories**: ✅ Checked
   - **Log Level**: Info (or Debug for verbose output)

### Project Settings for Test Execution
Add these to **Project Settings → General → Application → Run**:
```
Main Run Args: --headless=false
```

This ensures Godot runs in GUI mode for resource loading.

---

## 📊 Understanding Test Output

### GUT Panel Sections

#### 1. Test List (Left Side)
Shows all test files found in `scripts/tests/`:
```
✅ character_service_test.gd (43 tests)
✅ character_types_test.gd (26 tests)
✅ aura_foundation_test.gd (20 tests)
⏸️ weapon_loading_test.gd (15 tests - pending in CI)
```

#### 2. Test Results (Right Side)
```
Scripts:          18
Tests:            408
Passing Tests:    313
Risky/Pending:    95
Asserts:          659
Time:             2.834s
```

#### 3. Console Output (Bottom)
Shows detailed test execution:
```
[Pass] test_character_created_with_valid_id
[Pass] test_character_has_default_stats
[Pending] test_rusty_pistol_resource_loads
    Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true
```

### Test Status Icons
- ✅ **Green Checkmark**: Test passed
- ❌ **Red X**: Test failed
- ⏸️ **Yellow Pause**: Test pending/skipped
- ⚠️ **Orange Warning**: Test risky (no assertions)

---

## 🧪 Running Specific Test Categories

### Resource Tests (Weapons, Items, Perks)
These tests load `.tres` resource files and are disabled in headless CI.

**Enable in Godot Editor:**
```bash
# Method 1: Environment variable (terminal before launching Godot)
export ENABLE_RESOURCE_TESTS=true
export ENABLE_WEAPON_TESTS=true
godot --editor

# Method 2: In Godot Console (Debug → Run in Console)
OS.set_environment("ENABLE_RESOURCE_TESTS", "true")
OS.set_environment("ENABLE_WEAPON_TESTS", "true")
```

**Then run:**
- `weapon_loading_test.gd` - Tests weapon resource loading
- `item_loading_test.gd` - Tests item resource loading
- `perk_resource_test.gd` - Tests perk resource loading

### Service Tests
These always run (no special setup needed):
- `character_service_test.gd`
- `banking_service_test.gd`
- `recycler_service_test.gd`
- `shop_reroll_service_test.gd`
- `save_manager_test.gd`

### Integration Tests
Tests that verify multiple systems working together:
- `character_types_test.gd` - CharacterService + tier system
- `aura_foundation_test.gd` - AuraTypes + CharacterService
- `combat_service_test.gd` (Week 9+) - Weapons + Enemies + Damage

---

## 🐛 Debugging Failed Tests

### 1. Check Console Output
Failed tests show detailed error messages:
```
[Fail] test_character_level_up_increases_stats
  Expected: 105
  Got: 100
  At line 42 in character_service_test.gd
```

### 2. Use Breakpoints
1. Open test file in script editor
2. Click line number to add breakpoint (red dot)
3. Run test
4. Godot pauses at breakpoint
5. Inspect variables in debugger panel

### 3. Add Debug Prints
```gdscript
func test_my_feature() -> void:
    var character_id = CharacterService.create_character("Test")
    print("Character ID: ", character_id)  # Debug output

    var character = CharacterService.get_character(character_id)
    print("Character stats: ", character.stats)  # Debug output

    assert_not_null(character, "Character should exist")
```

### 4. Run Single Test in Isolation
Sometimes tests fail due to shared state. Run single test to isolate issue:
```gdscript
# Add "only" prefix to test name
func only_test_my_feature() -> void:
    # Test code here

# GUT will ONLY run tests prefixed with "only_"
```

### 5. Check Test Dependencies
Some tests depend on other services being initialized:
```gdscript
func before_each() -> void:
    # Reset service state before each test
    CharacterService.reset()
    BankingService.reset()
    # etc.
```

---

## 📁 Test File Structure

### Standard Test File Template
```gdscript
extends GutTest
## Test script for [System Name] using GUT framework
##
## USER STORY: "As a [role], I want [feature], so that [benefit]"
##
## Week [X] Phase [Y]: Tests [specific functionality]

class_name MySystemTest


func before_each() -> void:
    # Reset service state before each test
    MyService.reset()


func after_each() -> void:
    # Cleanup after each test
    pass


## ============================================================================
## SECTION 1: [Category Name]
## User Story: "[Specific user story for this section]"
## ============================================================================


func test_feature_works() -> void:
    # Arrange - Set up test conditions
    var input_data = {"value": 10}

    # Act - Execute the feature
    var result = MyService.do_something(input_data)

    # Assert - Verify the outcome
    assert_eq(result, 20, "Feature should double the value")
```

### Test Naming Conventions
- **Test files**: `*_test.gd` (e.g., `character_service_test.gd`)
- **Test functions**: `test_*` (e.g., `test_character_created_successfully()`)
- **Setup**: `before_each()` and `after_each()`
- **Sections**: Use comments to organize tests by category

---

## ⚡ Performance Tips

### 1. Use `add_child_autofree()` for Nodes
```gdscript
# ❌ Bad - Manual cleanup required
var node = MyNode.new()
add_child(node)
# ... test code ...
node.queue_free()

# ✅ Good - GUT cleans up automatically
var node = MyNode.new()
add_child_autofree(node)
```

### 2. Await Frame Delays for Visual Tests
```gdscript
func test_aura_visual_appears() -> void:
    var aura = AuraVisual.new()
    add_child_autofree(aura)

    # Wait for _ready() to be called
    await wait_frames(2)

    # Now test the visual
    assert_not_null(aura._particles, "Particles should be created")
```

### 3. Use `gut.p()` for Pending Tests
```gdscript
func test_future_feature() -> void:
    gut.p("This test is pending implementation")
    # Test code here (won't run, marked as pending)
```

### 4. Parallelize Tests with `pending_test_*`
Mark slow tests as pending during development:
```gdscript
func pending_test_slow_integration() -> void:
    # This won't run during normal test execution
    # Remove "pending_" prefix when ready
```

---

## 🎯 Common Test Scenarios

### Testing Services (Autoload Singletons)
```gdscript
func test_character_service_creates_character() -> void:
    # Arrange
    CharacterService.reset()
    CharacterService.set_tier(CharacterService.UserTier.FREE)

    # Act
    var character_id = CharacterService.create_character("Hero")

    # Assert
    assert_ne(character_id, "", "Should return valid ID")
    var character = CharacterService.get_character(character_id)
    assert_not_null(character, "Character should exist")
```

### Testing Scenes/Nodes
```gdscript
func test_aura_visual_creates_particles() -> void:
    # Arrange
    var AuraVisual = load("res://scripts/components/aura_visual.gd")
    var aura_visual = AuraVisual.new()
    add_child_autofree(aura_visual)

    # Wait for _ready()
    await wait_frames(2)

    # Assert
    var has_particles = false
    for child in aura_visual.get_children():
        if child is GPUParticles2D:
            has_particles = true
            break

    assert_true(has_particles, "Should create GPUParticles2D")
```

### Testing Signals
```gdscript
func test_character_created_signal_emitted() -> void:
    # Arrange
    var signal_watcher = watch_signals(CharacterService)
    CharacterService.set_tier(CharacterService.UserTier.FREE)

    # Act
    var character_id = CharacterService.create_character("Hero")

    # Assert
    assert_signal_emitted(CharacterService, "character_created")
    assert_signal_emit_count(CharacterService, "character_created", 1)
```

### Testing Resources
```gdscript
func test_weapon_resource_loads() -> void:
    # Skip if in headless mode
    if not OS.has_feature("editor"):
        gut.p("Disabled for headless CI")
        return

    # Arrange & Act
    var weapon = load("res://resources/weapons/rusty_pistol.tres")

    # Assert
    assert_not_null(weapon, "Weapon resource should load")
    assert_eq(weapon.damage, 10, "Should have correct damage")
```

---

## 🚀 Advanced Features

### Custom Assertions
```gdscript
func assert_almost_eq(actual: float, expected: float, tolerance: float = 0.01, msg: String = "") -> void:
    var diff = abs(actual - expected)
    assert_true(diff <= tolerance,
        "%s: Expected %s ± %s, got %s (diff: %s)" % [msg, expected, tolerance, actual, diff]
    )
```

### Parametric Tests (Data-Driven)
```gdscript
func test_damage_calculation_for_all_weapon_types() -> void:
    var test_cases = [
        {"weapon": "rusty_blade", "expected": 15},
        {"weapon": "plasma_pistol", "expected": 10},
        {"weapon": "void_cannon", "expected": 50}
    ]

    for case in test_cases:
        var weapon = WeaponService.WEAPON_DEFINITIONS[case.weapon]
        assert_eq(weapon.base_damage, case.expected,
            "Weapon %s should have damage %d" % [case.weapon, case.expected]
        )
```

### Test Fixtures (Shared Setup)
```gdscript
var test_character_id: String

func before_each() -> void:
    CharacterService.reset()
    CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
    test_character_id = CharacterService.create_character("TestHero", "mutant")

func test_feature_1() -> void:
    # Use test_character_id here

func test_feature_2() -> void:
    # Use test_character_id here
```

---

## 📚 Additional Resources

### GUT Documentation
- [GUT Wiki](https://github.com/bitwes/Gut/wiki)
- [GUT API Reference](https://bitwes.github.io/Gut/)

### Godot Testing Best Practices
- [Godot Unit Testing Guide](https://docs.godotengine.org/en/stable/tutorials/best_practices/unit_testing.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

### Project-Specific Docs
- [test-file-template.md](./test-file-template.md) - Template for new tests
- [godot-testing-research.md](./godot-testing-research.md) - Testing research notes
- [gut-migration-phase3-status.md](./gut-migration-phase3-status.md) - GUT migration progress

---

## 🔧 Troubleshooting: Tests Not Showing Up

### If GUT Panel is Empty (No Tests Listed)

**Step 1: Verify GUT Configuration**
```bash
# Check your godot-gut.config file
cat godot-gut.config | grep -E "dirs|prefix|suffix|include_subdirs"
```

Should show:
```json
"dirs": ["res://scripts/tests"],
"prefix": "",
"suffix": "_test.gd",
"include_subdirs": true
```

**Step 2: Manually Configure in GUT Panel**
1. Open GUT panel (bottom of Godot editor)
2. Click **⚙️ Settings** (gear icon)
3. In the settings window:
   - **Directories**: Click **+** button, add `res://scripts/tests`
   - **Prefix**: Leave empty (delete if there's `test_` in there)
   - **Suffix**: Type `_test.gd`
   - **Include Subdirectories**: Check the box ✅
4. Click **Save As**, save to project root as `godot-gut.config`
5. Close settings window
6. Click **🔄 Refresh** button in GUT panel

**Step 3: Force Reload**
1. **Project → Reload Current Project** in Godot menu
2. Wait for editor to reload
3. Open GUT panel again
4. Tests should now appear

**Step 4: Check GUT Panel Mode**

If you see a GUT panel but it's in "window mode" instead of "panel mode":
1. Right-click the GUT tab
2. Select "Move to Bottom Panel" or similar
3. Or use: **Editor → Editor Layout → GUT** (if available)

**Step 5: Verify Test Files Are Valid**
```bash
# Check that test files extend GutTest
head -1 scripts/tests/character_service_test.gd
```

Should output: `extends GutTest`

If not, the file isn't a valid GUT test file.

**Step 6: Try Command Line Test**
```bash
# From project root, run the test discovery script
godot --headless --script test_runner.gd
```

This will show if GUT can find your tests outside of the editor.

---

## ✅ Troubleshooting Checklist

- [ ] GUT plugin installed and enabled?
- [ ] Test directory set to `res://scripts/tests/`?
- [ ] Test file ends with `_test.gd`?
- [ ] Test functions start with `test_`?
- [ ] Environment variables set for resource tests?
- [ ] Services reset in `before_each()`?
- [ ] Using `add_child_autofree()` for nodes?
- [ ] Awaiting frames for visual tests?
- [ ] Check console output for error messages?

---

**Document Version**: 1.0
**Last Updated**: 2025-01-10
**Maintained By**: Scrap Survivor Dev Team
