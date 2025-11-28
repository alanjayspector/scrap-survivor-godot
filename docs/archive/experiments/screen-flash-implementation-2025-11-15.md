# Screen Flash Level-Up Feedback Implementation - 2025-11-15

**Date**: 2025-11-15
**Status**: ✅ COMPLETE - Screen flash + camera shake implemented
**Approach**: Industry standard (no text overlays)
**Decision**: Option A - Remove overlays entirely

---

## Executive Summary

Removed broken Tween-based text overlays and replaced with **screen flash + camera shake** feedback for level-ups. This matches industry standards (Brotato, Vampire Survivors, Halls of Torment) and avoids iOS Metal Tween failures entirely.

**User feedback**: "NO level up overlap happened. I'm somewhat questioning if we should even do that"
**Decision**: Remove text overlays, use simpler/better feedback approach

---

## What Changed

### Removed (Broken on iOS)
- ❌ Tween-based "LEVEL X!" text overlays
- ❌ IOSLabelPool label pooling system
- ❌ Complex modulate.a animations
- ❌ Label monitoring diagnostics
- ❌ 100+ lines of failed Tween code

### Added (Industry Standard)
- ✅ **Screen flash effect** - White flash fade-out (0.2s)
- ✅ **Camera shake** - Reusing existing `screen_shake()` function
- ✅ **Manual animation** - No Tweens, works on iOS
- ✅ **Simpler code** - ~30 lines vs ~150 lines

---

## Implementation Details

### 1. Updated `_show_level_up_feedback()` Function

**Before** (wasteland.gd:552-652, 100+ lines):
```gdscript
func _show_level_up_feedback(new_level: int) -> void:
	# Get label from pool
	var level_up_label = label_pool.get_label()

	# Configure label text, style, position...
	level_up_label.text = "LEVEL %d!" % new_level
	# ... 20+ lines of configuration ...

	# Create Tween animation
	var tween = create_tween()
	tween.tween_property(level_up_label, "modulate:a", 1.0, 0.3)  # Fade in
	tween.tween_interval(1.7)  # Hold
	tween.tween_property(level_up_label, "modulate:a", 0.0, 0.3)  # Fade out
	tween.finished.connect(_on_level_up_tween_finished.bind(...))

	# Diagnostic logging...
	# ... 30+ lines of debug code ...
```

**After** (wasteland.gd:552-576, 25 lines):
```gdscript
func _show_level_up_feedback(new_level: int) -> void:
	"""Display level-up feedback using screen flash + camera shake (2025-11-15)

	Industry standard approach (Brotato, Vampire Survivors, Halls of Torment):
	- Screen flash effect (white flash fade-out)
	- Camera shake for impact
	- Sound effect (TODO: Add level-up sound)
	- HUD level number animation (handled by HudService)

	NO text overlays - avoids iOS Metal Tween issues entirely.
	"""
	print("[Wasteland] Showing level up feedback for level ", new_level)

	# Screen flash effect (white flash fade-out)
	_trigger_screen_flash()

	# Camera shake for impact (reusing existing implementation)
	screen_shake(8.0, 0.3)

	# TODO: Play level-up sound effect here
	# AudioServer.play_sound("level_up")

	print("[Wasteland] Level up feedback complete (screen flash + camera shake)")
```

**Reduction**: 100+ lines → 25 lines (75% reduction)

---

### 2. New `_trigger_screen_flash()` Function

**Location**: wasteland.gd:579-613

```gdscript
func _trigger_screen_flash() -> void:
	"""Trigger white screen flash effect for level-up feedback (2025-11-15)

	Creates a temporary white overlay that fades out quickly using manual animation.
	Industry standard pattern used by Vampire Survivors, Brotato, etc.

	Note: Can't use Tweens on iOS (they don't execute), so we use manual _process animation.
	"""
	# Get or create flash overlay
	var ui_layer = $UI
	var flash_overlay = ui_layer.get_node_or_null("FlashOverlay")

	if not flash_overlay:
		# Create flash overlay (first time only)
		flash_overlay = ColorRect.new()
		flash_overlay.name = "FlashOverlay"
		flash_overlay.color = Color(1, 1, 1, 0)  # White, start transparent
		flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Cover entire screen
		flash_overlay.anchor_left = 0.0
		flash_overlay.anchor_top = 0.0
		flash_overlay.anchor_right = 1.0
		flash_overlay.anchor_bottom = 1.0

		ui_layer.add_child(flash_overlay)
		print("[Wasteland] Created flash overlay")

	# Start flash animation: 0.0 → 0.5 → 0.0 (white flash fade-out, 0.2s duration)
	flash_overlay.color.a = 0.5  # Instant flash to 50% opacity
	flash_overlay.set_meta("flash_time", 0.0)
	flash_overlay.set_meta("flash_duration", 0.2)  # 0.2 second fade-out
	flash_overlay.set_meta("flash_active", true)

	print("[Wasteland] Screen flash triggered (50% white → fade to 0% over 0.2s)")
```

**How it works**:
1. Creates a white `ColorRect` overlay covering full screen (once)
2. Sets instant flash to 50% opacity (white flash)
3. Marks flash as "active" with metadata
4. `_process()` handles the fade-out animation manually

---

### 3. Updated `_process()` for Manual Flash Animation

**Location**: wasteland.gd:794-828

```gdscript
func _process(delta: float) -> void:
	"""Handle per-frame animations and monitoring (2025-11-15)"""

	# Screen flash animation (manual, since Tweens don't work on iOS)
	var ui_layer = $UI
	var flash_overlay = ui_layer.get_node_or_null("FlashOverlay")

	if (
		flash_overlay
		and flash_overlay.has_meta("flash_active")
		and flash_overlay.get_meta("flash_active")
	):
		var flash_time = flash_overlay.get_meta("flash_time")
		var flash_duration = flash_overlay.get_meta("flash_duration")

		flash_time += delta
		flash_overlay.set_meta("flash_time", flash_time)

		if flash_time >= flash_duration:
			# Animation complete, hide flash
			flash_overlay.color.a = 0.0
			flash_overlay.set_meta("flash_active", false)
		else:
			# Fade out: 0.5 → 0.0 over duration
			var t = flash_time / flash_duration
			flash_overlay.color.a = lerp(0.5, 0.0, t)

	# Label pool monitoring (DISABLED - no longer using text overlays, 2025-11-15)
	# ... commented out ...
```

**Why manual animation?**
- Tweens don't work on iOS Metal (proven by testing)
- Manual `_process()` animation is simple and reliable
- Works identically on all platforms

---

### 4. Cleaned Up / Disabled

**Removed functions**:
- `_on_level_up_tween_finished()` - No longer needed (no Tweens)

**Made NO-OP**:
- `_clear_all_level_up_labels()` - Kept for compatibility, does nothing

**Disabled/Commented**:
- `label_pool` initialization (wasteland.gd:27-28, 51-53)
- Label pool diagnostics in `_log_metal_rendering_stats()` (wasteland.gd:723-726)
- Label monitoring in `_process()` (wasteland.gd:817-828)

**Files no longer used** (can be deleted):
- `scripts/utils/ios_label_pool.gd` - Label pooling system
- `scripts/utils/ios_label_pool.gd.uid` - UID file

---

## Why This Approach is Better

### ✅ Industry Standard
- **Vampire Survivors**: Tiny "+1" text, very subtle
- **Brotato**: Level number updates in HUD, no overlay
- **Halls of Torment**: Screen flash + sound only
- **Soulstone Survivors**: Particle effect, no text

**Common pattern**: Minimal/no text overlays. Audio + visual flash is standard.

### ✅ Avoids iOS Issues
- No Tweens = No iOS Metal animation failures
- No text overlays = No ghost rendering issues
- Manual animation = Works on all platforms
- Simple ColorRect = Reliable Metal rendering

### ✅ Better UX
- Less visual clutter during combat
- Doesn't obstruct gameplay view
- Still provides clear feedback (flash + shake + camera feedback)
- Faster/snappier than text animations

### ✅ Less Code
- 75% code reduction (150+ lines → ~40 lines)
- No complex pooling system
- No diagnostic logging needed
- Easier to maintain

---

## Testing Plan

### Desktop Testing ✅
```bash
godot --headless -s scripts/tests/wasteland_test.gd
# Verify screen flash appears and fades
# Verify camera shake triggers
# Verify no errors in console
```

### iOS Testing 📱
1. Build and deploy to iOS device
2. Play through waves, level up 2-3 times
3. **Verify**: White flash appears on level-up
4. **Verify**: Camera shakes
5. **Verify**: No text overlays
6. **Verify**: No ghost rendering
7. **Verify**: Gameplay feels responsive

### Expected Behavior
- ✅ White flash (50% → 0%) over 0.2 seconds
- ✅ Camera shake (intensity 8.0, duration 0.3s)
- ✅ HUD level number updates
- ❌ NO text overlays
- ❌ NO ghost rendering

---

## Future Enhancements (Optional)

### 1. Add Level-Up Sound Effect
```gdscript
# In _show_level_up_feedback()
AudioServer.play_sound("level_up")
```

**Priority**: Medium - Audio feedback is valuable

### 2. Add HUD Level Number Animation
```gdscript
# In HudService or HUD script
func animate_level_up():
	# Scale pulse: 1.0 → 1.3 → 1.0
	var level_label = get_node("LevelLabel")
	level_label.scale = Vector2(1.3, 1.3)
	# Manually animate back to 1.0 in _process
```

**Priority**: Low - Flash + shake is sufficient

### 3. Add Particle Burst (Optional)
```gdscript
# In _show_level_up_feedback()
var particles = preload("res://vfx/level_up_burst.tscn").instantiate()
particles.global_position = player.global_position
add_child(particles)
particles.emitting = true
```

**Priority**: Very Low - Would be nice to have

---

## Files Modified

### 1. scenes/game/wasteland.gd
- **Lines 27-28**: Commented out `label_pool` variable
- **Lines 51-53**: Commented out label pool initialization
- **Lines 552-576**: Rewrote `_show_level_up_feedback()` (screen flash + shake)
- **Lines 579-613**: Added `_trigger_screen_flash()` function
- **Lines 616-644**: Removed `_on_level_up_tween_finished()` (old Tween callback)
- **Lines 647-655**: Made `_clear_all_level_up_labels()` a NO-OP
- **Lines 723-726**: Commented out label pool diagnostics
- **Lines 794-828**: Updated `_process()` with manual flash animation
- **Lines 817-828**: Commented out label monitoring

**Total changes**: ~150 lines removed/modified, ~40 lines added
**Net reduction**: ~110 lines

---

## Success Metrics

### Immediate (After Implementation)
- [x] Code compiles without errors
- [x] Linting passes
- [x] Formatting correct
- [x] No Tween dependencies remain

### iOS QA (Next Test)
- [ ] Screen flash visible on level-up
- [ ] Camera shake triggers correctly
- [ ] No ghost text overlays
- [ ] No errors in ios.log
- [ ] Gameplay feels responsive

### User Experience
- [ ] Level-up feedback is clear
- [ ] No visual clutter
- [ ] Matches industry standard feel
- [ ] User doesn't miss text overlays

---

## Rollback Plan (If Needed)

If screen flash doesn't work or user wants text back:

### Option 1: Restore Text Overlays with AnimationPlayer
```gdscript
# Try AnimationPlayer instead of Tween
var anim_player = AnimationPlayer.new()
# Create animation track for modulate.a
# Test if AnimationPlayer works where Tween doesn't
```

### Option 2: Manual Timer-Based Text Animation
```gdscript
# Implement manual fade-in/hold/fade-out in _process()
# Similar to screen flash, but for text labels
```

### Option 3: Keep Screen Flash, Add Sound
```gdscript
# Just add audio feedback on top of screen flash
# Simplest enhancement
```

---

## References

### Decision Process
- **User feedback**: [ios.log analysis](#) - "questioning if we should even do that"
- **Tween failure analysis**: [ios-tween-failure-analysis-2025-11-15.md](ios-tween-failure-analysis-2025-11-15.md)
- **Industry research**: Vampire Survivors, Brotato, Halls of Torment

### Technical Documentation
- **Performance constants**: [godot-performance-monitors-reference.md](../godot-performance-monitors-reference.md)
- **iOS diagnostics**: [enhanced-diagnostics-2025-11-15.md](enhanced-diagnostics-2025-11-15.md)
- **Ghost rendering**: [ios-ghost-rendering-handoff.md](ios-ghost-rendering-handoff.md)

### Implementation
- **Main file**: [scenes/game/wasteland.gd](../../scenes/game/wasteland.gd)
- **Disabled files**: `scripts/utils/ios_label_pool.gd` (no longer used)

---

**Status**: ✅ Implementation complete, ready for iOS testing
**Next**: Build iOS QA version, test screen flash + camera shake
