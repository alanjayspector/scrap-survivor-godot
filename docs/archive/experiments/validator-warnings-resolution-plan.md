# Validator Warnings Resolution Plan

**Created**: 2025-11-15
**Context**: Week 14 Phase 2 Complete - Pre-Manual QA Cleanup
**Goal**: Fix all 127 non-blocking validator warnings to improve code quality, performance, and test coverage.

**Estimated Time**: 3-4 hours
**Priority**: High (performance gains) → Medium (test quality) → Low (code style)

---

## Overview

After completing Week 14 Phase 2 (Continuous Spawning System), all blocking validators are passing:
- ✅ 496/520 automated tests passing (24 skipped)
- ✅ All test method calls valid
- ✅ All test naming conventions followed
- ✅ Godot config valid
- ✅ Scene node paths valid
- ✅ Integration tests present

However, we have 127 warnings across non-blocking validators that should be addressed before manual QA for better code quality and performance.

---

## Phase 1: Performance Fixes (30 min) - HIGH PRIORITY

**Impact**: 15-80% FPS gains possible

### Task 1.1: Fix get_node() in Hot Path (15 min)

**File**: `scenes/game/wasteland.gd:802`

**Issue**: `get_node()` called in `_process()` loop - this is a hot path that runs every frame

**Fix**:
```gdscript
# Add at top of class
@onready var [node_name]: [NodeType] = $[NodePath]

# Remove get_node() call from _process()
```

**Steps**:
1. Read line 802 in wasteland.gd to identify which node is being fetched
2. Add @onready variable at class level
3. Replace get_node() call with cached reference
4. Test to ensure functionality unchanged

**Validator**: `python3 .system/validators/godot_performance_validator.py`

---

### Task 1.2: Fix String Concatenation in Loops (15 min)

**Files**:
- `scripts/resources/item_resource.gd:97`
- `scripts/ui/character_selection.gd:155`
- `scripts/ui/character_selection.gd:449`

**Issue**: String concatenation using `+` operator in loops is significantly slower than formatting

**Fix**:
```gdscript
# Before (slow)
text = text + value

# After (fast - 15-80% improvement)
text = "Text: %s" % value
# or
text = "%s%s" % [text, value]
```

**Steps**:
1. Read each file at the specified line
2. Replace string concatenation with % formatting
3. Ensure output is identical
4. Run gdformat/gdlint

**Validator**: `python3 .system/validators/godot_performance_validator.py`

---

## Phase 2: Godot Best Practices (45 min) - MEDIUM PRIORITY

### Task 2.1: Add @onready Decorators (30 min)

**Issue**: 10 Node-typed variables not using @onready decorator (Godot best practice)

**Files and Variables**:

1. `scripts/components/aura_visual.gd:11-12` (2 variables)
2. `scripts/components/camera_controller.gd:10` (1 variable)
3. `scripts/entities/drop_pickup.gd:20` (1 variable)
4. `scripts/entities/player.gd:37` (1 variable)
5. `scripts/entities/projectile.gd:47` (1 variable)
6. `scripts/systems/save_manager.gd:30` (1 variable)
7. `scripts/ui/character_selection.gd:35` (1 variable)
8. `scripts/utils/ios_label_pool.gd:27,46` (2 variables)

**Fix Pattern**:
```gdscript
# Before
var node_name: NodeType

# After
@onready var node_name: NodeType = $NodePath
```

**Steps**:
1. For each file, read the specified line
2. Check if variable is assigned in _ready() - if so, move to @onready declaration
3. If not assigned, add assignment from node path
4. Test that node is properly cached
5. Run gdformat/gdlint on each file

**Validator**: `python3 .system/validators/godot_antipatterns_validator.py`

---

### Task 2.2: Add Missing Return Type Hints (15 min)

**Issue**: 10 functions missing return type hints (GDScript best practice for type safety)

**Files and Functions**:

1. `scripts/ui/character_selection.gd`
   - `_build_detail_buttons`
   - `_animate_detail_panel_entrance`

2. `scripts/systems/drop_system.gd`
   - `process_enemy_kill`

3. `scripts/services/combat_service.gd`
   - `apply_aura_damage_to_nearby_enemies`

4. `scripts/services/error_service.gd`
   - `log_error`
   - `capture_godot_error`

5. `scripts/services/recycler_service.gd`
   - `_calculate_scrap_granted`

6. `scripts/services/weapon_service.gd`
   - `fire_weapon`

7. `scripts/entities/projectile.gd`
   - `activate`

8. `scripts/entities/enemy.gd`
   - `_play_random_sound`

**Fix Pattern**:
```gdscript
# Before
func function_name():

# After (if returns nothing)
func function_name() -> void:

# After (if returns value)
func function_name() -> ReturnType:
```

**Steps**:
1. For each function, check if it returns a value
2. Add appropriate return type (-> void if no return, -> Type if returns)
3. Run gdformat/gdlint

**Validator**: `bash .system/validators/check-patterns.sh`

---

## Phase 3: Test Quality Improvements (90 min) - MEDIUM PRIORITY

### Task 3.1: Add Missing Assertions (60 min)

**Issue**: 45 tests have no assertions - they set up scenarios but don't verify behavior

**Priority Order** (fix critical tests first):

#### High Priority - Core Combat Mechanics (25 tests)

1. **combat_service_test.gd** (7 tests)
   - `test_calculate_damage_includes_character_stats:37`
   - `test_calculate_damage_adds_melee_bonus:50`
   - `test_calculate_damage_adds_ranged_bonus:64`
   - `test_calculate_aura_damage_scales_with_resonance:125`
   - `test_calculate_aura_damage_with_no_resonance_stat:140`
   - `test_get_weapon_attack_damage:207`
   - `test_get_weapon_attack_damage_with_invalid_character:222`

2. **weapon_service_test.gd** (10 tests)
   - `test_get_weapon_damage_with_base_stats_only:170`
   - `test_get_weapon_damage_with_character_damage_bonus:182`
   - `test_get_weapon_damage_with_melee_bonus:194`
   - `test_get_weapon_damage_with_ranged_bonus:206`
   - `test_get_weapon_damage_ignores_wrong_type_bonus:220`
   - `test_get_weapon_cooldown_with_zero_attack_speed:240`
   - `test_attack_speed_reduces_cooldown:252`
   - `test_attack_speed_caps_at_75_percent:265`
   - `test_attack_speed_50_percent_reduction:278`
   - `test_get_cooldown_remaining:366`

3. **enemy_service_test.gd** (4 tests)
   - `test_damage_enemy_caps_hp_at_zero:160`
   - `test_wave_scaling_increases_enemy_hp:285`
   - `test_spawn_enemy_applies_wave_scaling:297`
   - `test_get_spawn_rate_decreases_with_wave:308`

4. **entity_classes_test.gd** (14 tests)
   - `test_player_takes_damage_correctly:71`
   - `test_player_heals_correctly:82`
   - `test_player_applies_health_item_modifiers:94`
   - `test_player_applies_speed_item_modifiers:98`
   - `test_player_equips_weapon:102`
   - `test_player_invulnerability_blocks_damage:106`
   - `test_enemy_health_percentage_calculation:163`
   - `test_projectile_activates_with_parameters:205`
   - `test_projectile_velocity_is_set:209`
   - `test_projectile_pierce_is_set:213`
   - `test_projectile_remaining_range_is_full:217`
   - `test_projectile_deactivates:221`
   - `test_player_fires_weapon:245`
   - `test_enemy_calculates_distance_to_player:249`
   - `test_player_life_steal_modifier:271`

#### Medium Priority - Progression & Systems (8 tests)

5. **drop_system_test.gd** (1 test)
   - `test_scavenging_caps_at_50_percent:109`

6. **aura_foundation_test.gd** (3 tests)
   - `test_calculate_aura_power_with_resonance:104`
   - `test_calculate_aura_power_for_all_types:128`
   - `test_calculate_aura_radius_from_pickup_range:153`

7. **character_stats_expansion_test.gd** (2 tests)
   - `test_can_update_life_steal_stat:188`
   - `test_can_update_attack_speed_stat:200`

8. **game_state_test.gd** (2 tests)
   - `test_set_current_wave_no_signal_for_same_value:43`
   - `test_set_current_character_no_signal_for_same_value:175`

9. **recycler_service_test.gd** (2 tests)
   - `test_luck_40_adds_10_percent_component_chance:136`
   - `test_luck_chance_bonus_caps_at_25_percent:146`

**Fix Pattern**:
```gdscript
# Before (test with no assertions)
func test_calculate_damage():
    var character = {...}
    var result = CombatService.calculate_damage(character, 10.0)

# After
func test_calculate_damage():
    var character = {"damage": 5.0}
    var result = CombatService.calculate_damage(character, 10.0)

    assert_not_null(result, "Should return damage value")
    assert_eq(result, 15.0, "Should add character damage to base damage")
```

**Steps**:
1. For each test, understand what behavior it's testing by reading the test name
2. Add appropriate assertions (assert_eq, assert_not_null, assert_true, etc.)
3. Always include failure messages in assertions
4. Run tests after each file to ensure they pass
5. Run gdformat/gdlint

**Validator**: `python3 .system/validators/test_patterns_validator.py`

---

### Task 3.2: Fix Memory Leaks in Tests (20 min)

**Issue**: 38 Node2D objects created in tests but never freed - potential memory leaks

**Files and Leaks**:

1. **wave_manager_test.gd** (12 spawn_container leaks)
   - Lines: 41, 56, 83, 117, 152, 194, 223, 245, 282, 322, 356, 391

2. **wasteland_camera_boundary_test.gd** (11 mock_player leaks)
   - Lines: 98, 119, 140, 161, 196, 226, 250, 274, 303, 331, 388

3. **scene_integration_test.gd** (3 enemy leaks)
   - Lines: 294, 295, 296

**Fix Pattern**:
```gdscript
# Before (memory leak)
var spawn_container = Node2D.new()
wave_manager.spawn_container = spawn_container
add_child(wave_manager)

# After (properly cleaned up)
var spawn_container = Node2D.new()
wave_manager.spawn_container = spawn_container
add_child_autofree(wave_manager)  # GUT helper
add_child_autofree(spawn_container)  # GUT helper
```

**Steps**:
1. For each file, find all Node2D.new() calls
2. Ensure they're added with add_child_autofree() instead of manual management
3. Run tests to ensure cleanup works correctly
4. Run gdformat/gdlint

**Validator**: `python3 .system/validators/test_patterns_validator.py`

---

### Task 3.3: Add Missing class_name Declarations (5 min)

**Issue**: 3 test files missing class_name declarations (GDScript convention for tests)

**Files**:
- `scripts/tests/scene_integration_test.gd`
- `scripts/tests/virtual_joystick_test.gd`
- `scripts/tests/wasteland_camera_boundary_test.gd`

**Fix Pattern**:
```gdscript
extends GutTest
class_name SceneIntegrationTest  # Add this line

## Test description...
```

**Steps**:
1. Add class_name after extends GutTest
2. Use PascalCase matching filename (e.g., scene_integration_test.gd → SceneIntegrationTest)
3. Run gdformat/gdlint

**Validator**: `python3 .system/validators/test_patterns_validator.py`

---

### Task 3.4: Add Assertion Failure Messages (5 min)

**Issue**: 3 assertions in save_integration_test.gd missing failure messages

**File**: `scripts/tests/save_integration_test.gd:221-223`

**Fix Pattern**:
```gdscript
# Before
assert_eq(BankingService.get_balance(BankingService.CurrencyType.SCRAP), 1000)

# After
assert_eq(
    BankingService.get_balance(BankingService.CurrencyType.SCRAP),
    1000,
    "Should restore scrap balance after load"
)
```

**Steps**:
1. Read lines 221-223
2. Add descriptive failure message to each assertion
3. Run tests to ensure they still pass
4. Run gdformat/gdlint

**Validator**: `python3 .system/validators/test_quality_validator.py`

---

## Phase 4: Code Style Fixes (30 min) - LOW PRIORITY

### Task 4.1: Fix Constant Naming (10 min)

**Issue**: 5 constants not following SCREAMING_SNAKE_CASE convention

**Files**:

1. `scripts/tests/virtual_joystick_test.gd`
   - `VirtualJoystick` → `VIRTUAL_JOYSTICK`

2. `scripts/tests/aura_foundation_test.gd`
   - `AuraVisual` → `AURA_VISUAL`

3. `scripts/tests/entity_classes_test.gd`
   - `_WEAPON_RESOURCE_SCRIPT` (already correct)
   - `_ENEMY_RESOURCE_SCRIPT` (already correct)
   - `_ITEM_RESOURCE_SCRIPT` (already correct)

**Note**: The entity_classes_test.gd constants are already correctly named, so only 2 need fixing.

**Fix Pattern**:
```gdscript
# Before
const VirtualJoystick = preload("res://...")

# After
const VIRTUAL_JOYSTICK = preload("res://...")

# Update all usages
var joystick = VIRTUAL_JOYSTICK.instantiate()
```

**Steps**:
1. Rename constant to SCREAMING_SNAKE_CASE
2. Find all usages and update them
3. Run tests to ensure no breakage
4. Run gdformat/gdlint

**Validator**: `bash .system/validators/check-patterns.sh`

---

### Task 4.2: Rename Audio Assets (10 min)

**Issue**: 4 audio files missing category prefix (asset naming convention)

**Files to Rename**:
- `assets/audio/ui/error.ogg` → `assets/audio/ui/ui_error.ogg`
- `assets/audio/weapons/minigun.ogg` → `assets/audio/weapons/weapon_minigun.ogg`
- `assets/audio/weapons/shotgun.ogg` → `assets/audio/weapons/weapon_shotgun.ogg`
- `assets/audio/weapons/flamethrower.ogg` → `assets/audio/weapons/weapon_flamethrower.ogg`

**Process**:
1. Rename files in file system (use git mv or regular mv)
2. Delete old `.import` files (e.g., `error.ogg.import`)
3. Search codebase for old filenames and update references:
   ```bash
   grep -r "error.ogg" scripts/
   grep -r "minigun.ogg" scripts/
   grep -r "shotgun.ogg" scripts/
   grep -r "flamethrower.ogg" scripts/
   ```
4. Open Godot editor to regenerate `.import` files
5. Test audio playback

**Code References to Update**:
- Search for `preload("res://assets/audio/ui/error.ogg")`
- Search for `preload("res://assets/audio/weapons/minigun.ogg")`
- Search for `preload("res://assets/audio/weapons/shotgun.ogg")`
- Search for `preload("res://assets/audio/weapons/flamethrower.ogg")`

**Validator**: `bash .system/validators/check-imports.sh`

---

### Task 4.3: Remove Supabase Mentions (5 min)

**Issue**: 2 service files mention Supabase but don't reference it (outdated documentation)

**Files**:
- `scripts/services/banking_service.gd`
- `scripts/services/recycler_service.gd`

**Fix**:
1. Read both files
2. Search for "Supabase" mentions in comments/docs
3. Remove or update mentions if they're not relevant
4. Run gdformat/gdlint

**Validator**: `bash .system/validators/check-patterns.sh`

---

### Task 4.4: Fix Data Model Field References (5 min)

**Issue**: 5 references to non-existent character fields

**Files**:

1. `scripts/autoload/hud_service.gd` (4 occurrences)
   - Line 76: `character.get("experience")`
   - Line 128: `character.get("experience")`
   - Line 148: `character.get("experience")`
   - Line 238: `character.get("experience")`

2. `scripts/tests/scene_integration_test.gd` (1 occurrence)
   - Line 327: `character.get("xp_to_next_level")`

**Investigation Needed**:
1. Check CharacterService to find correct field names:
   ```bash
   grep -n "def.*character" scripts/services/character_service.gd
   ```
2. Look at character data structure in service
3. Update references to use correct field names

**Common Fixes**:
- `experience` might be `xp` or stored differently
- `xp_to_next_level` might be calculated, not stored

**Validator**: `python3 .system/validators/data_model_consistency_validator.py`

---

## Validation & Testing Strategy

### After Each Phase

Run relevant validators to confirm fixes:

```bash
# After Phase 1 (Performance)
python3 .system/validators/godot_performance_validator.py
# Expected: 0 warnings

# After Phase 2 (Best Practices)
python3 .system/validators/godot_antipatterns_validator.py
bash .system/validators/check-patterns.sh
# Expected: 0 antipattern warnings, 0 missing return types

# After Phase 3 (Test Quality)
python3 .system/validators/test_patterns_validator.py
python3 .system/validators/test_quality_validator.py
python3 .system/validators/godot_test_runner.py
# Expected: 0 test pattern warnings, 496/520 tests passing

# After Phase 4 (Code Style)
bash .system/validators/check-imports.sh
python3 .system/validators/data_model_consistency_validator.py
bash .system/validators/check-patterns.sh
# Expected: 0 import warnings, 0 data model warnings
```

### Final Comprehensive Validation

Run all validators at once:

```bash
# Quick validation script
echo "=== Running All Validators ===" && \
python3 .system/validators/godot_test_runner.py && \
python3 .system/validators/test_method_validator.py && \
python3 .system/validators/test_naming_validator.py && \
python3 .system/validators/test_patterns_validator.py && \
python3 .system/validators/test_quality_validator.py && \
python3 .system/validators/godot_antipatterns_validator.py && \
python3 .system/validators/godot_performance_validator.py && \
python3 .system/validators/godot_config_validator.py && \
python3 .system/validators/scene_node_path_validator.py && \
python3 .system/validators/data_model_consistency_validator.py && \
bash .system/validators/check-imports.sh && \
bash .system/validators/check-patterns.sh && \
echo "=== All Validators Complete ==="
```

### Always Run After Changes

```bash
# Format and lint
gdformat [modified_files]
gdlint [modified_files]

# Run tests if code changes
python3 .system/validators/godot_test_runner.py
```

---

## Success Criteria

- **Phase 1**: ✅ 0 performance warnings (from 4)
- **Phase 2**: ✅ 0 antipattern warnings (from 11), ✅ 0 missing return types (from 10)
- **Phase 3**: ✅ 0 test pattern warnings (from 83), ✅ All 520 tests passing
- **Phase 4**: ✅ 0 import warnings (from 4), ✅ 0 data model warnings (from 5)

**Final Goal**: All 127 warnings resolved, all validators passing

---

## Time Estimates

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| Phase 1: Performance | 2 tasks | 30 min |
| Phase 2: Best Practices | 2 tasks | 45 min |
| Phase 3: Test Quality | 4 tasks | 90 min |
| Phase 4: Code Style | 4 tasks | 30 min |
| **Total** | **12 tasks** | **3-4 hours** |

---

## Implementation Tips

1. **Work in order**: Phases are prioritized by impact (performance → quality → style)

2. **Commit frequently**: Consider committing after each phase for easy rollback:
   ```bash
   git add .
   git commit -m "fix: resolve Phase 1 performance warnings (get_node in hot path)"
   ```

3. **Test early**: Run tests after Phase 3 to catch any breakage before style fixes

4. **Can parallelize**:
   - Phases 1-2 (performance/best practices) are independent
   - Phases 3-4 (tests/style) are independent
   - Could split work between two sessions if needed

5. **Use validators**: Run validators after each task to confirm fixes immediately

6. **Format/lint always**: Run gdformat + gdlint after every file modification

7. **Read before fixing**: Always read the specific line mentioned to understand context

---

## Post-Cleanup

Once all warnings are resolved:

1. **Update documentation**: Note validator warnings resolution in week14-implementation-plan.md
2. **Prepare for Manual QA**: System ready for iOS testing with clean codebase
3. **Performance baseline**: Note any FPS improvements from Phase 1 fixes
4. **Test coverage**: Celebrate improved test assertion coverage

---

**Last Updated**: 2025-11-15
**Status**: Ready for implementation
**Next Session**: Use this document as implementation guide
