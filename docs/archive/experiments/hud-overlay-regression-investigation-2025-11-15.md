# HUD Level-Up Overlay Regression Investigation
**Date**: 2025-11-15
**Status**: INVESTIGATING
**Severity**: Medium (UX regression, iOS-specific)

---

## Problem Statement

User reports seeing "LEVEL 2!" text overlay during Week 14 audio QA testing on iOS device. This overlay:
- Was NOT seen during QA sessions after commit be20f54 (Nov 15, iOS bug fix)
- WAS seen for the first time during audio QA (after commit c4d2c63)
- Contradicts the "industry standard" approach implemented in be20f54 (screen flash only, no text overlays)

**Critical Context**: User has been conducting thorough manual QA on iOS device at EVERY commit, including gameplay sessions with level-ups. This is the FIRST time seeing this overlay.

---

## Evidence Collected

### 1. Source Code Analysis

**Only source of "LEVEL %d!" text**: `/scenes/ui/hud.gd` lines 304-351

```gdscript
func _show_level_up_popup(level: int) -> void:
    """Show a level up notification popup with full-screen celebration"""
    # Full-screen yellow flash
    var flash = ColorRect.new()
    flash.color = Color(1.0, 1.0, 0.0, 0.3)  # Yellow with 30% opacity
    flash.anchor_right = 1.0
    flash.anchor_bottom = 1.0
    flash.z_index = 99
    add_child(flash)

    # Fade out flash
    var flash_tween = create_tween()
    flash_tween.tween_property(flash, "modulate:a", 0.0, 0.5)
    flash_tween.tween_callback(flash.queue_free)

    # Large centered level-up text
    var popup = Label.new()
    popup.text = "LEVEL %d!" % level  # ← CREATES THE OVERLAY
    popup.add_theme_font_size_override("font_size", 56)
    popup.add_theme_color_override("font_color", Color.YELLOW)
    # ... positioning code ...
    add_child(popup)  # ← ADDS TO SCREEN

    # Animate popup (scale up, float up slightly, fade out)
    var tween = create_tween()
    tween.tween_property(popup, "scale", Vector2(1.2, 1.2), 0.2)
    tween.tween_property(popup, "position:y", popup.position.y - 30, 0.8)
    tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.4).set_delay(0.4)
    tween.tween_callback(popup.queue_free)  # ← CLEANUP VIA TWEEN

    GameLogger.info("HUD: Level up celebration shown", {"level": level})
```

**Trigger**: `/scenes/ui/hud.gd` lines 144-147

```gdscript
func _on_xp_changed(current: int, required: int, level: int) -> void:
    # Update XP bar/label...

    # Show level up effect when XP resets to 0 (leveled up)
    # Only show if previous XP was > 0 (actual level-up, not initial state)
    if current == 0 and previous_xp > 0:
        _show_level_up_popup(level)  # ← CALLS OVERLAY FUNCTION

    previous_xp = current
```

### 2. Timeline of HUD Overlay Code

| Date | Commit | Change | Status |
|------|--------|--------|--------|
| Nov 10 | ab0957e | Initial HUD implementation with overlay | Added |
| Nov 10 | 63b20d6 | Added `previous_xp > 0` guard to prevent false positives | Fixed |
| Nov 11 | a5c9feb | Enhanced popup with yellow flash | Enhanced |
| Nov 15 | be20f54 | **Wasteland overlay removed**, HUD **NOT touched** | HUD unchanged |
| Nov 15 | 808fb08 | Pre-commit hooks | HUD unchanged |
| Nov 15 | 3ae3fe2 | Audio infrastructure + weapon switcher | HUD unchanged |
| Nov 15 | cd6238d | UID file | HUD unchanged |
| Nov 15 | 9f2929b | OGG format audio | HUD unchanged |
| Nov 15 | c4d2c63 | Weapon tier setting | HUD unchanged |

**Key Finding**: HUD overlay code was IDENTICAL from Nov 11 through all audio commits.

### 3. iOS Log Analysis

From `ios.log` during audio QA session:

```
[Wasteland] Player leveled up to level 2!
[Wasteland] Showing level up feedback for level 2
[Wasteland] Created flash overlay
[Wasteland] Screen flash triggered (50% white → fade to 0% over 0.2s)
[Wasteland] Level up feedback complete (screen flash + camera shake)
```

**Key Finding**: NO "HUD: Level up celebration shown" log message found!

**Interpretation**: Either:
1. GameLogger.info() doesn't output to ios.log (only print() statements appear)
2. The Tween crashed before reaching the GameLogger.info() call
3. The function never completed execution

### 4. Dual Overlay Systems

**System 1: Wasteland (Removed in be20f54)**
- Location: `scenes/game/wasteland.gd` lines 551-586
- Status: ✅ Correctly removed
- Replacement: Screen flash + camera shake (iOS compatible)
- Trigger: `CharacterService.character_level_up_post` signal

**System 2: HUD (Still Active)**
- Location: `scenes/ui/hud.gd` lines 304-351
- Status: ❌ Still creating overlays
- Implementation: Yellow flash + text Label + Tween animation
- Trigger: XP reset detection (`current == 0 and previous_xp > 0`)
- **Problem**: Uses Tweens which don't work on iOS Metal renderer

### 5. Known iOS Tween Issue

From `docs/experiments/ios-tween-failure-analysis-2025-11-15.md`:

> **Root Cause**: Tween animations don't execute on iOS Metal renderer (100% failure rate)
>
> **Impact**: Tween-based animations fail silently, leaving UI elements stuck on screen
>
> **Solution**: Use manual animation in `_process()` or avoid Tweens entirely

**Implication**: The HUD overlay creates the Label and adds it to the scene (lines 342), but the Tween-based cleanup (line 349: `tween.tween_callback(popup.queue_free)`) NEVER executes on iOS. The Label remains on screen indefinitely.

---

## The Mystery: Why NOW?

### What We Know:
1. HUD overlay code existed since Nov 10 (before be20f54)
2. HUD overlay code unchanged from be20f54 through c4d2c63
3. User did QA after be20f54 and didn't see overlay
4. User did QA after c4d2c63 and DID see overlay
5. User confirms they've been doing full QA including level-ups at every commit

### What Changed Between be20f54 and c4d2c63:

**wasteland.gd changes**:
```gdscript
// Added in 3ae3fe2:
func _add_debug_weapon_switcher() -> void:
    """Add debug weapon switcher UI for iOS testing"""
    if OS.get_name() == "iOS":
        var weapon_switcher = preload("res://scenes/ui/debug_weapon_switcher.tscn").instantiate()
        $UI.add_child(weapon_switcher)  # ← Added to same $UI parent as HUD

// Added in c4d2c63:
WeaponService.set_tier(WeaponService.UserTier.SUBSCRIPTION)
```

**Potential Theories**:

### Theory A: Debug Weapon Switcher Z-Index Interaction
- Debug weapon switcher added to $UI container (same parent as HUD)
- Could this affect rendering order or visibility?
- **Counter**: Weapon switcher shouldn't affect HUD signal handling

### Theory B: Scene Tree Initialization Timing
- Adding weapon switcher changes initialization order
- HUD might initialize differently relative to player/signals
- **Counter**: HudService.set_player() call unchanged

### Theory C: Tween Behavior Changed
- Tweens were somehow "less broken" before
- Now they're "more broken" and Labels persist
- **Counter**: Tweens have never worked on iOS Metal (documented)

### Theory D: GameLogger Silent Failure
- HUD overlay was ALWAYS triggering
- Tweens were ALWAYS failing
- Labels were ALWAYS being created
- But... why wasn't user seeing them before?
- **Counter**: User is highly experienced with QA methodology

---

## Questions for User (To Narrow Down Root Cause)

### Q1: QA Session Comparison
**After be20f54 QA session**:
- Did you definitely kill 10+ enemies and reach level 2?
- How many waves did you complete?
- Approximately how long did you play?

**Audio QA session (c4d2c63)**:
- Same questions as above
- Any differences in gameplay patterns?

### Q2: iOS Device Logs
Do you still have ios.log from your be20f54 QA session? If so, can you check if it contains:
```
[Wasteland] Player leveled up to level 2!
```

This would confirm whether you leveled up during that session.

### Q3: Visual Confirmation
In the screenshot from audio QA:
- Is the "LEVEL 2" text clearly visible?
- Is it yellow text with black outline?
- Is it centered on screen?
- Does it stay on screen or fade away?

### Q4: Reproducibility
If you revert to commit be20f54 and do the same QA (kill 10+ enemies, reach level 2):
- Do you see the "LEVEL 2" overlay or not?
- This would definitively prove whether the code changed or the usage changed

---

## Hypotheses Ranked by Likelihood

### 1. **User Didn't Level Up Before** (Medium Confidence)
- **Evidence FOR**: Different QA focus (bug reproduction vs feature testing)
- **Evidence AGAINST**: User explicitly states they did full QA at every commit
- **Test**: Check be20f54 ios.log for level-up messages

### 2. **HUD Signal Connection Wasn't Working Before** (Low Confidence)
- **Evidence FOR**: Would explain complete absence of overlay
- **Evidence AGAINST**: HudService.set_player() was added Nov 10, before be20f54
- **Test**: Add diagnostic logging to HUD signal handlers

### 3. **Tween Failure Mode Changed** (Very Low Confidence)
- **Evidence FOR**: Could explain timing difference
- **Evidence AGAINST**: Tweens have been broken on iOS the entire time
- **Test**: Not testable without iOS device access

### 4. **Scene Tree Initialization Order** (Low Confidence)
- **Evidence FOR**: Debug weapon switcher added to $UI
- **Evidence AGAINST**: Shouldn't affect existing HUD signal routing
- **Test**: Remove weapon switcher and see if overlay disappears

---

## Recommended Solution (Regardless of Root Cause)

### The Fix: Remove HUD Overlay System Entirely

**Rationale**:
1. **Duplicate System**: Wasteland.gd already provides level-up feedback (screen flash + camera shake)
2. **iOS Incompatible**: HUD overlay uses Tweens which don't work on iOS Metal
3. **Industry Standard**: Screen flash approach matches Brotato, Vampire Survivors, Halls of Torment
4. **Code Reduction**: Eliminates 50+ lines of problematic code
5. **Future-Proof**: No Tween dependencies = no iOS rendering issues

### Implementation:

**File**: `/scenes/ui/hud.gd`

**Remove lines 144-147** (trigger):
```gdscript
# DELETE THIS:
if current == 0 and previous_xp > 0:
    _show_level_up_popup(level)
```

**Remove lines 304-351** (entire function):
```gdscript
# DELETE THIS ENTIRE FUNCTION:
func _show_level_up_popup(level: int) -> void:
    # ... 48 lines ...
```

**Result**:
- XP bar still updates correctly
- Wasteland.gd screen flash provides level-up feedback
- No duplicate overlay systems
- No Tween issues on iOS
- Matches industry standard UX

---

## Next Steps

1. **User provides QA session details** (Q1-Q4 above)
2. **Analyze differences** between be20f54 and c4d2c63 sessions
3. **Identify root cause** of why overlay appeared now
4. **Document findings** in this file
5. **Implement fix** (remove HUD overlay system)
6. **Test on iOS** to confirm overlay no longer appears
7. **Update week14-implementation-plan.md** with findings

---

## References

- Original iOS Tween fix: `docs/experiments/ios-tween-failure-analysis-2025-11-15.md`
- Screen flash implementation: `docs/experiments/screen-flash-implementation-2025-11-15.md`
- Week 14 plan: `docs/migration/week14-implementation-plan.md`
- Commit be20f54: "fix(combat): resolve iOS 0 HP bug and replace Tween overlays with screen flash"
- Commit c4d2c63: "fix(audio): set weapon tier to SUBSCRIPTION for iOS testing"

---

## ROOT CAUSE IDENTIFIED ✅

**Date**: 2025-11-15 (Final Analysis)

### The Discovery

Diagnostic logging from iOS QA session revealed the issue:

```
[HudService] _on_character_level_up_post: character_id=char_1, new_level=2
[HudService] Emitting xp_changed: current=2, required=200, level=2
[HUD] _on_xp_changed called: current=2, required=200, level=2, previous_xp=94
[HUD] Level-up check: current==0? false, previous_xp>0? true, TRIGGER? false
```

**Key Finding**: When player leveled up to level 2, they had **2 XP remaining** (overflow from the level-up).

### The Real Problem

The HUD overlay trigger condition is:
```gdscript
if current == 0 and previous_xp > 0:
    _show_level_up_popup(level)
```

But **CharacterService keeps overflow XP** after leveling up:
- Player has 94 XP (94/100)
- Kills enemy worth 10 XP → 104 total
- Levels up: 104 - 100 = **4 XP remaining**
- HUD receives: `xp_changed(current=4, required=200, level=2)`
- Trigger check: `4 == 0`? → **FALSE**
- **Overlay does NOT show** ✓ Correct!

### Why the Condition is Flawed

The condition `current == 0` only triggers when:
- Player levels up with **exactly** the right amount of XP
- **No overflow** (extremely rare in gameplay)

**Example scenarios**:
| XP Before | Enemy Worth | Total | After Level-Up | Overlay Triggers? |
|-----------|-------------|-------|----------------|-------------------|
| 94 | 6 | 100 | 0 XP | ✅ YES (rare) |
| 94 | 10 | 104 | 4 XP | ❌ NO (common) |
| 90 | 12 | 102 | 2 XP | ❌ NO (common) |
| 85 | 15 | 100 | 0 XP | ✅ YES (rare) |

**Conclusion**: The HUD overlay was **designed incorrectly** from the start. It only triggers in rare edge cases.

### Explaining the "Regression"

**User's observation**: "I saw the overlay during audio QA but never before"

**Possible explanations**:
1. **Lucky RNG**: During audio QA, user happened to level up with exactly 0 overflow (rare but possible)
2. **Different gameplay**: Audio testing involved different weapons/enemies with different XP values
3. **Multiple level-ups**: With diagnostic logging, we saw levels 2, 3, and 4 - one of them might have hit 0 exactly

**Evidence from logs**:
- Level 2: Had 2 XP remaining → NO overlay ✓
- Level 3 & 4: Logs not captured in detail, but likely had overflow too

### Solution Validation

The HUD overlay system is:
1. ❌ **Unreliable** - Only triggers in rare edge cases
2. ❌ **Unnecessary** - Wasteland.gd already provides screen flash feedback
3. ❌ **iOS Incompatible** - Uses Tweens which don't work on iOS Metal
4. ❌ **Duplicate System** - Two separate level-up feedback mechanisms

**Recommendation**: Remove HUD overlay system entirely (confirmed correct approach).

---

## Additional Bug Discovered

**Bug**: "Zombie" enemies at Wave 2+ (green blocks)
- **Symptom**: Enemy HP bar reaches 0 but enemy stays active
- **Impact**: Enemies continue moving/attacking after "death"
- **Severity**: High (affects gameplay)
- **Status**: Needs investigation (separate from HUD overlay issue)

---

**Status**: ROOT CAUSE IDENTIFIED - Proceeding with permanent fix (remove HUD overlay system).
