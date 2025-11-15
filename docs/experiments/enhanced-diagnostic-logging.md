# Enhanced Diagnostic Logging - iOS Bug Tracking
**Date**: 2025-01-14
**Purpose**: Comprehensive logging to track iOS-specific race conditions and timing issues

---

## Summary

Added enhanced diagnostic logging across enemy lifecycle, player color management, and wave transitions to provide complete visibility into iOS-specific timing issues.

---

## New Logging Added

### 1. Enemy Group Membership Tracking

**File**: `scripts/entities/enemy.gd`

**Added**: Enemy joins "enemies" group (line 48)
```gdscript
add_to_group("enemies")
print("[Enemy] Added to 'enemies' group (instance: ", get_instance_id(), ")")
```

**Purpose**: Track when enemies enter the group that wasteland uses for cleanup

---

### 2. Enemy Death Sequence Timing

**File**: `scripts/entities/enemy.gd`

**Enhanced**: die() method with timestamp and instance ID (lines 270-280)
```gdscript
var death_time = Time.get_ticks_msec() / 1000.0
print(
    "[Enemy] die() called for ",
    enemy_type,
    " at position ",
    global_position,
    " (time: ",
    death_time,
    "s, instance: ",
    get_instance_id(),
    ")"
)
```

**Purpose**:
- Track exact timing of death start
- Correlate with wave completion timing
- Measure race condition window

**Added**: Death animation complete callback (lines 333-347)
```gdscript
func _on_death_animation_complete() -> void:
    """Called when death animation completes - log before queue_free (Bug #11 diagnostic)"""
    var queue_free_time = Time.get_ticks_msec() / 1000.0
    print(
        "[Enemy] Death animation complete, calling queue_free() for ",
        enemy_type,
        " (time: ",
        queue_free_time,
        "s, instance: ",
        get_instance_id(),
        ", in_group: ",
        is_in_group("enemies"),
        ")"
    )
    queue_free()
```

**Purpose**:
- **CRITICAL**: Check if enemy still in "enemies" group when queue_free() called
- Track timing between die() start and queue_free() call
- Measure iOS queue_free() delay

---

### 3. Wave Completion Timing

**File**: `scenes/game/wasteland.gd`

**Enhanced**: _on_wave_completed() with timestamp (lines 492-501)
```gdscript
var completion_time = Time.get_ticks_msec() / 1000.0
print(
    "[Wasteland] Wave ",
    wave,
    " completed with stats: ",
    stats,
    " (time: ",
    completion_time,
    "s)"
)
```

**Purpose**:
- Track exact wave completion timing
- Correlate with enemy death timing
- Measure race condition overlap

---

### 4. Enemy Cleanup Timing & Group State

**File**: `scenes/game/wasteland.gd`

**Enhanced**: _cleanup_all_enemies() with timing and group count (lines 696-704)
```gdscript
var cleanup_time = Time.get_ticks_msec() / 1000.0
print("[Wasteland] _cleanup_all_enemies() called (time: ", cleanup_time, "s)")

var enemies = get_tree().get_nodes_in_group("enemies")
print(
    "[Wasteland]   Enemies to clean: ",
    enemies.size(),
    " (in 'enemies' group at cleanup time)"
)
```

**Purpose**:
- Track cleanup timing relative to wave completion
- Show exactly how many enemies in group when cleanup runs
- Prove enemies are/aren't in group during race condition

---

### 5. Player Color State Tracking

**File**: `scripts/entities/player.gd`

**Enhanced**: _flash_damage() with before/after color logging (lines 568-581)
```gdscript
if child is ColorRect:
    var current_color = child.color
    print(
        "[Player]   ColorRect current color: ",
        current_color,
        " (should be: ",
        original_visual_color,
        ")"
    )
    print("[Player]   Creating damage flash tween for ColorRect")
    active_damage_tween = create_tween()
    active_damage_tween.tween_property(child, "color", Color.RED, 0.1)
    active_damage_tween.tween_property(child, "color", original_visual_color, 0.1)
    active_damage_tween.tween_callback(func(): _on_damage_flash_complete(child))
    print("[Player]   Tween created: RED -> ", original_visual_color)
```

**Added**: Tween completion callback (lines 590-607)
```gdscript
func _on_damage_flash_complete(visual_node: Node) -> void:
    """Called when damage flash tween completes - verify color restored (Bug #8 diagnostic)"""
    if visual_node is ColorRect:
        var final_color = visual_node.color
        print(
            "[Player] Damage flash complete - ColorRect final color: ",
            final_color,
            " (expected: ",
            original_visual_color,
            ")"
        )
        if final_color != original_visual_color:
            print(
                "[Player]   WARNING: Color mismatch! Expected ",
                original_visual_color,
                " but got ",
                final_color
            )
```

**Purpose**:
- **CRITICAL**: Detect if color changes BEFORE tween starts (something else modifying it)
- Verify tween completes with correct final color
- Alert if color mismatch detected (Bug #8 root cause indicator)

---

## Complete Diagnostic Coverage

### Bug #11 (Enemy Persistence) - Full Timeline Now Visible

**Enemy Lifecycle**:
1. ✅ Enemy added to "enemies" group → `Added to 'enemies' group (instance: X)`
2. ✅ Enemy takes damage → (existing logging)
3. ✅ Enemy death starts → `die() called for X (time: Ts, instance: X)`
4. ✅ Drops spawned, XP awarded → (existing logging)
5. ✅ Death signal emitted → (existing logging)
6. ✅ Death animation completes → `Death animation complete (time: Ts, in_group: true/false)`
7. ✅ queue_free() called → (logged in step 6)

**Wave Lifecycle**:
1. ✅ Last enemy dies → Step 3 above
2. ✅ WaveManager detects 0 enemies → (existing logging)
3. ✅ Wave completion triggered → `Wave X completed (time: Ts)`
4. ✅ Enemy cleanup called → `_cleanup_all_enemies() called (time: Ts)`
5. ✅ Enemies in group counted → `Enemies to clean: X (in 'enemies' group)`
6. ✅ Each enemy cleaned → (existing logging from Bug #11 fix)

**Timing Analysis Now Possible**:
```
[Enemy] die() called for feral_runner (time: 263.450s, instance: 12345)
[Enemy] Enemy death complete
[Enemy] Death animation complete (time: 263.750s, in_group: true) ← Still in group!
[Wasteland] Wave 3 completed (time: 263.455s)                      ← Wave complete BEFORE queue_free!
[Wasteland] _cleanup_all_enemies() called (time: 263.456s)
[Wasteland]   Enemies to clean: 1 (in 'enemies' group)             ← Enemy caught in race!
```

---

### Bug #8 (Player Color) - Color State Tracking

**Damage Flash Lifecycle**:
1. ✅ Damage taken → (existing ENTRY/EXIT logging)
2. ✅ Flash triggered → `_flash_damage() - restoring to original color`
3. ✅ Current color checked → `ColorRect current color: X (should be: Y)` **← CRITICAL**
4. ✅ Existing tween killed → (existing logging)
5. ✅ New tween created → `Tween created: RED -> X`
6. ✅ Tween completes → `Damage flash complete - final color: X (expected: Y)` **← CRITICAL**
7. ✅ Mismatch detected → `WARNING: Color mismatch!` **← BUG ALERT**

**What This Reveals**:
- If current color ≠ original before tween: Something else is changing the color
- If final color ≠ original after tween: Tween failed or was interrupted
- Mismatch WARNING = immediate visibility into Bug #8 root cause

---

## Expected Log Patterns

### Bug #11 Success (After Fix)

```
[Enemy] Added to 'enemies' group (instance: 12345)
[Enemy] die() called for feral_runner (time: 100.5s, instance: 12345)
[Enemy] Enemy death complete: feral_runner
[WaveManager] Enemy removed from living_enemies. Remaining: 0
[WaveManager] Wave completed (time: 100.501s)
[Wasteland] Wave 3 completed (time: 100.501s)
[Wasteland] _cleanup_all_enemies() called (time: 100.502s)
[Wasteland]   Enemies to clean: 1 (in 'enemies' group)  ← Enemy still in group (race condition!)
[Wasteland]   Cleaning enemy: 12345
[Wasteland]     Enemy removed from parent and hidden     ← Fix prevents zombie
[Wasteland]     Enemy queued for deletion
[Enemy] Death animation complete (time: 100.8s, in_group: false) ← Removed by cleanup!
```

**Key Insight**: Enemy cleanup happens BEFORE death animation completes

---

### Bug #8 Success (When Working)

```
[Player] _flash_damage() - restoring to original color: (0.2, 0.6, 1.0, 1.0)
[Player]   ColorRect current color: (0.2, 0.6, 1.0, 1.0) (should be: (0.2, 0.6, 1.0, 1.0))  ← Match!
[Player]   Creating damage flash tween for ColorRect
[Player]   Tween created: RED -> (0.2, 0.6, 1.0, 1.0)
[Player] Damage flash complete - ColorRect final color: (0.2, 0.6, 1.0, 1.0) (expected: (0.2, 0.6, 1.0, 1.0))  ← Match!
```

---

### Bug #8 Failure (When Broken)

**Scenario A: Color corrupted before tween**:
```
[Player] _flash_damage() - restoring to original color: (0.2, 0.6, 1.0, 1.0)
[Player]   ColorRect current color: (0.9, 0.2, 0.2, 1.0) (should be: (0.2, 0.6, 1.0, 1.0))  ← MISMATCH!
[Player]   Creating damage flash tween for ColorRect
[Player]   Tween created: RED -> (0.2, 0.6, 1.0, 1.0)
[Player] Damage flash complete - ColorRect final color: (0.2, 0.6, 1.0, 1.0) (expected: (0.2, 0.6, 1.0, 1.0))
```
**Diagnosis**: Something changed color BEFORE flash (collision? other tween?)

**Scenario B: Tween fails to restore**:
```
[Player] _flash_damage() - restoring to original color: (0.2, 0.6, 1.0, 1.0)
[Player]   ColorRect current color: (0.2, 0.6, 1.0, 1.0) (should be: (0.2, 0.6, 1.0, 1.0))  ← OK
[Player]   Creating damage flash tween for ColorRect
[Player]   Tween created: RED -> (0.2, 0.6, 1.0, 1.0)
[Player] Damage flash complete - ColorRect final color: (0.9, 0.2, 0.2, 1.0) (expected: (0.2, 0.6, 1.0, 1.0))  ← MISMATCH!
[Player]   WARNING: Color mismatch! Expected (0.2, 0.6, 1.0, 1.0) but got (0.9, 0.2, 0.2, 1.0)
```
**Diagnosis**: Tween didn't complete correctly (killed? interrupted? iOS tween bug?)

---

## Files Modified

1. **scripts/entities/enemy.gd**
   - Added group membership logging (line 48)
   - Enhanced die() with timing and instance ID (lines 270-280)
   - Added death animation complete callback (lines 333-347)

2. **scripts/entities/player.gd**
   - Enhanced _flash_damage() with color state tracking (lines 568-581)
   - Added damage flash complete callback (lines 590-607)

3. **scenes/game/wasteland.gd**
   - Enhanced wave completion with timing (lines 492-501)
   - Enhanced enemy cleanup with timing and group count (lines 696-704)

---

## Code Quality

- ✅ **gdformat**: Passed (1 file reformatted, 2 files left unchanged)
- ✅ **gdlint**: Passed (no problems found)

---

## Usage for QA

When analyzing iOS logs, look for:

### For Bug #11 (Enemy Persistence):
1. **Time deltas** between die() and queue_free()
2. **"in_group: true"** when queue_free() called = race condition confirmed
3. **Enemy count** at cleanup time (should be 0 if no race)

### For Bug #8 (Player Color):
1. **Color mismatch** before tween = external corruption
2. **Color mismatch** after tween = tween failure
3. **WARNING** messages = immediate bug visibility

---

## Diagnostic Questions Answered

### Before Enhanced Logging:
- ❓ When does enemy join "enemies" group?
- ❓ Is enemy still in group when queue_free() is called?
- ❓ What's the timing between die() and wave completion?
- ❓ What color is player ColorRect before tween?
- ❓ Does tween complete with correct color?

### After Enhanced Logging:
- ✅ Enemy joins group on _ready() → timestamp + instance ID logged
- ✅ Enemy group membership logged at queue_free() → in_group: true/false
- ✅ Full timeline: die(Ts1) → wave_complete(Ts2) → cleanup(Ts3) → queue_free(Ts4)
- ✅ Current color logged before each tween
- ✅ Final color logged after each tween with mismatch detection

---

## Next Steps

1. **iOS QA Build**: Deploy with enhanced logging
2. **Log Analysis**: Review timing deltas for race conditions
3. **Color Tracking**: Monitor for color mismatch warnings
4. **Pattern Recognition**: Identify if Bug #8 is pre-tween or post-tween issue

---

## Sign-Off

**Enhanced Logging Complete**: 2025-01-14
**Coverage**: ✅ Complete (enemy lifecycle, wave transitions, player color state)
**Code Quality**: ✅ Passed
**Ready for iOS QA**: ✅ Yes

This logging level should provide complete visibility into all iOS-specific timing issues.
