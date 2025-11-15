# iOS QA Round - Bug Analysis Report
**Date**: 2025-01-14
**Test Session**: iOS Manual QA (Waves 1-5, Levels 1-5)
**Analysis Team**: SR Mobile Game Designer, SR Mobile UI/UX Designer, SR Software Engineer, SR Product Manager, SR SQA

---

## Executive Summary

Analysis of ios.log and QA screenshots reveals **3 distinct bugs** with varying severity:

### ✅ FIXED (Previous Session)
- **Bug #6**: Enemy projectiles not damaging player → FIXED ✅
  - Evidence: 11 successful `take_damage()` calls in logs
- **Bug #7**: Level-up overlays sticking/not dismissing → FIXED ✅
  - Evidence: All 4 cleanup callbacks fired successfully

### 🔴 NEW BUGS DISCOVERED
- **Bug #8** (P1): Player color transformation on damage
- **Bug #9** (P2): Level-up overlays appearing over wave complete screen
- **Bug #10** (P3): "Drop failed" log spam (informational, not actual bug)

---

## Bug #8: Player Color Transformation on Collision/Damage

**Priority**: P1 (High - Visual Quality Issue)
**Status**: Root cause identified, fix ready

### Evidence from QA
- User report: "player transforming to color of whatever they collided to"
- Logs show 11 damage flash events
- Player visual is ColorRect with blue tint

### Root Cause Analysis

**Location**: `scripts/entities/player.gd:549-550`

```gdscript
func _flash_damage() -> void:
    """Visual feedback for taking damage"""
    for child in get_children():
        if child is ColorRect:
            var tween = create_tween()
            tween.tween_property(child, "color", Color.RED, 0.1)
            tween.tween_property(child, "color", Color(0.2, 0.6, 1, 1), 0.1)  # ← HARDCODED BLUE
```

**The Problem**:
1. Damage flash is hardcoded to return to `Color(0.2, 0.6, 1, 1)` (blue)
2. This is the default scavenger color from `player.tscn:21`
3. If player's color changes for ANY reason (different character, power-up, etc.), it gets stuck at blue
4. Multiple rapid damage events can cause tween conflicts

**Impact**: Player visual becomes blue after taking damage, never returning to original color

### Solution
Store the original player color on `_ready()` and restore to that stored color instead of hardcoded value.

```gdscript
# Add class variable to store original color
var original_visual_color: Color = Color(0.2, 0.6, 1, 1)

func _ready() -> void:
    # ... existing code ...

    # Store original visual color
    for child in get_children():
        if child is ColorRect and child.name == "Visual":
            original_visual_color = child.color
            break

func _flash_damage() -> void:
    """Visual feedback for taking damage"""
    for child in get_children():
        if child is ColorRect:
            var tween = create_tween()
            tween.tween_property(child, "color", Color.RED, 0.1)
            tween.tween_property(child, "color", original_visual_color, 0.1)  # ← USE STORED COLOR
```

**Confidence**: ⭐⭐⭐⭐⭐ Very High (direct evidence in code)

---

## Bug #9: Level-Up Overlays Appearing Over Wave Complete Screen

**Priority**: P2 (Medium - UI/UX Issue)
**Status**: Root cause identified, fix needed

### Evidence from QA
Screenshots show:
- Image 3: "LEVEL 4!" overlaid on "Wave 3 Complete!" panel
- Image 6: "LEVEL 2!" overlaid on "Wave 1 Complete!" panel

### Root Cause Analysis

**Diagnostic Data**:
```
Level-up feedback created: 4
Level-up labels freed: 4
Cleanup timeout callbacks: 4 (all fired successfully)
```

**Finding**: The cleanup IS working (Bug #7 is truly fixed), BUT:

1. **Timing Issue**: Level-up labels have 2-second cleanup timer
2. **State Transition**: Wave complete panel appears when wave ends
3. **UI Layering**: Level-up labels added to `$UI` layer, which may be above wave complete panel
4. **Result**: If player levels up near end of wave, label persists through state transition

**Timeline Example**:
```
0:00 - Player kills enemy, gains XP, levels up to 4
0:00 - "LEVEL 4!" label created, cleanup timer set to 2 seconds
0:01 - Player kills last enemy in wave
0:01 - Wave complete panel appears
0:02 - Level-up label still visible OVER wave complete panel
```

### Solution Options

**Option A: Immediate cleanup on state change** (Recommended)
```gdscript
# In wasteland.gd _on_wave_completed()
func _on_wave_completed(wave_number: int, stats: Dictionary) -> void:
    # Clear any active level-up labels before showing complete screen
    _clear_all_level_up_labels()

    # ... existing wave complete logic ...
```

**Option B: Reduce cleanup timer to 1 second**
- Faster cleanup, less likely to overlap with wave complete
- Simpler change, but doesn't guarantee fix

**Option C: UI layer ordering**
- Ensure wave complete panel is above level-up labels in z-index
- Doesn't fix the issue, just hides it

**Recommendation**: Option A (immediate cleanup) - most robust

**Confidence**: ⭐⭐⭐⭐ High (timing analysis + screenshot evidence)

---

## Bug #10: "Drop Failed" Log Spam

**Priority**: P3 (Low - Not Actually a Bug)
**Status**: False alarm - working as intended

### Evidence from Logs
```
[DropSystem] Drop failed  (30 occurrences)
```

### Analysis
Looking at context around "Drop failed" messages:

```
[DropSystem] Drop failed
[DropSystem] Rolling for components chance: 0.3
[DropSystem] Roll: 0.105214394629 vs 0.3
[DropSystem] Drop succeeded! Amount: 2 Final: 2
```

**Finding**: "Drop failed" is NOT an error - it's logging that certain drop types (components, nanites) failed their RNG probability roll. This is normal behavior.

**Explanation**:
- Each enemy death rolls for multiple drop types
- "Drop failed" = RNG roll didn't meet threshold for that specific drop type
- System then tries next drop type
- Final result is correct (some enemies drop scrap only, some drop components, etc.)

### Recommendation
**No fix needed** - this is informational logging, not a bug. Could reduce log verbosity in production build if desired.

---

## Additional Findings

### ✅ Positive Results
1. **Player damage is working** - 11 successful `take_damage()` calls
2. **Currency pickup is working** - 77 successful `collect()` calls, 0 duplicate collections
3. **Level-up cleanup is working** - All 4 cleanup callbacks fired (iOS GC fix successful)
4. **Wave progression is working** - 4 waves completed with correct stats

### Performance Notes
- Wave 1: 48.9 seconds, 20 enemies killed
- Wave 2: 63.3 seconds, 25 enemies killed
- Wave 3: 72.7 seconds, 30 enemies killed
- Wave 4: 49.2 seconds, 35 enemies killed

---

## Recommended Fixes (Priority Order)

### 1. Fix Bug #8: Player Color Transformation (P1)
- **Effort**: Low (5 minutes)
- **Risk**: Very Low
- **Impact**: High (fixes visual quality issue)

### 2. Fix Bug #9: Level-Up Overlay Timing (P2)
- **Effort**: Low (10 minutes)
- **Risk**: Low
- **Impact**: Medium (improves UX)

### 3. Reduce "Drop Failed" Logging (P3 - Optional)
- **Effort**: Trivial (comment out 1 line)
- **Risk**: None
- **Impact**: Cleaner logs

---

## Test Plan for Next QA Round

After implementing fixes:

1. **Bug #8 Verification**:
   - Play through waves 1-5
   - Take damage from multiple enemy types
   - Verify player color remains consistent (doesn't turn blue)
   - Check with different characters if available

2. **Bug #9 Verification**:
   - Level up near end of wave (timing critical)
   - Verify level-up label clears when wave complete panel appears
   - Test with rapid level-ups (multiple levels in one wave)

3. **Regression Testing**:
   - Verify Bug #6 (player damage) still works
   - Verify Bug #7 (level-up cleanup) still works
   - Check currency pickup still functions correctly

---

## Diagnostic Logging Assessment

The comprehensive logging added in previous session was **extremely valuable**:

✅ **What Worked**:
- Player damage ENTRY/EXIT logging revealed successful execution
- Level-up cleanup logging proved iOS GC fix worked
- Currency pickup logging showed no duplicate collections
- Drop system logging (though verbose) showed normal RNG behavior

✅ **What to Keep**:
- Player damage logging (critical for future debugging)
- Level-up feedback logging (helps with timing analysis)
- Currency pickup guard logging (prevents edge cases)

⚠️ **What to Reduce** (optional):
- "Drop failed" messages (normal RNG, not errors)
- Visual node instance IDs (too verbose for production)

---

## Senior Team Sign-Off

**SR Software Engineer**: Root cause confirmed for Bug #8, fix is straightforward. Bug #9 needs state transition cleanup.

**SR Mobile UI/UX Designer**: Level-up overlays on complete screen is jarring UX. Option A (immediate cleanup) is best user experience.

**SR Mobile Game Designer**: Color transformation breaks immersion. Fix is critical for visual polish.

**SR SQA**: Diagnostic logging strategy was excellent. Recommend keeping enhanced logging for iOS builds until platform is stable.

**SR Product Manager**: Bug #8 is user-facing visual issue, prioritize for next build. Bug #9 is edge case but worth fixing for polish.

---

**Next Steps**: Implement fixes for Bug #8 and Bug #9, then request another iOS QA session for verification.
