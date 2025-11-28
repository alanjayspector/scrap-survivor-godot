# iOS Tween Comprehensive Audit & Fix Plan
**Date**: 2025-11-15
**Status**: READY FOR IMPLEMENTATION
**Priority**: CRITICAL (Memory leaks + UX bugs)

---

## Executive Summary

Following the discovery and fix of two critical iOS Tween bugs (HUD overlay and zombie enemies), a comprehensive audit revealed **8 additional Tween-related issues** across the codebase. Of these, **2 are critical memory leaks** that must be fixed immediately.

**Root Cause**: iOS Metal renderer does not execute Tween animations (100% failure rate documented in `ios-tween-failure-analysis-2025-11-15.md`).

**Impact Summary**:
- 🔴 2 CRITICAL: Memory leaks causing crashes
- 🟡 2 MEDIUM: Visual bugs affecting UX
- 🟢 4 LOW: Cosmetic issues only

---

## Issues Inventory

### 🔴 CRITICAL - Memory Leaks (Must Fix Now)

#### 1. Drop Pickup Cleanup Failure
**File**: `scripts/entities/drop_pickup.gd:192`
**Severity**: CRITICAL
**Impact**: Drop pickups never removed from scene

**Problem**:
```gdscript
func collect() -> void:
    # ... emit signal ...

    # Collection animation
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
    tween.tween_property(self, "modulate:a", 0.0, 0.2)
    tween.tween_callback(_on_collection_animation_complete)  # ← NEVER EXECUTES ON iOS

func _on_collection_animation_complete() -> void:
    queue_free()  # ← NEVER CALLED
```

**Result**:
- Drop pickups stay in scene forever (invisible due to failed fade)
- Memory leak accumulates rapidly during gameplay
- Performance degradation
- **Eventual crash** from accumulated objects

**Proposed Solution**:
```gdscript
func collect() -> void:
    # ... emit signal ...

    # Immediate cleanup (iOS-compatible)
    queue_free()
```

**Lines to Remove**: 186-206 (collection animation + callback)

---

#### 2. Character Detail Panel Cleanup Failure
**File**: `scripts/ui/character_selection.gd:609`
**Severity**: HIGH
**Impact**: UI panels never freed from memory

**Problem**:
```gdscript
func _close_detail_panel() -> void:
    # ... animation setup ...

    # Wait for animation to complete, then remove
    tween.tween_callback(func(): panel.queue_free())  # ← NEVER EXECUTES ON iOS
```

**Result**:
- Detail panels stay in memory (invisible)
- Memory leak with repeated character browsing
- Slower accumulation than drop pickups but still problematic

**Proposed Solution**:
```gdscript
func _close_detail_panel() -> void:
    if panel:
        panel.queue_free()
    current_detail_panel = null
```

**Lines to Remove**: 591-609 (close animation + callback)
**Fallback exists**: Line 611 has `panel.queue_free()` for else case

---

### 🟡 MEDIUM - Visual Bugs (Should Fix)

#### 3. Player Damage Flash Color Stuck
**File**: `scripts/entities/player.gd:583`
**Severity**: MEDIUM
**Impact**: Player visual stays RED after taking damage

**Problem**:
```gdscript
func _flash_damage_visual() -> void:
    if child is ColorRect:
        active_damage_tween = create_tween()
        active_damage_tween.tween_property(child, "color", Color.RED, 0.1)
        active_damage_tween.tween_property(child, "color", original_visual_color, 0.1)  # ← NEVER EXECUTES
        active_damage_tween.tween_callback(func(): _on_damage_flash_complete(child))
```

**Result**:
- Player ColorRect stuck at RED after damage
- Confusing UX (looks like player is always damaged)
- Callback is diagnostic only, not critical

**Proposed Solution** (match enemy.gd pattern):
```gdscript
func _flash_damage_visual() -> void:
    # Store flash timer for manual reset
    damage_flash_timer = damage_flash_duration

    if child is ColorRect:
        child.color = Color.RED
    elif child is Sprite2D:
        child.modulate = Color.RED

# Add to _process():
func _process(delta: float) -> void:
    if damage_flash_timer > 0:
        damage_flash_timer -= delta
        if damage_flash_timer <= 0:
            _restore_visual_color()
```

**Lines to Modify**: 570-590 (damage flash function)
**Pattern**: Same as `enemy.gd:258-264` (already fixed)

---

#### 4. HUD Animation Failures
**File**: `scenes/ui/hud.gd` (multiple locations)
**Severity**: MEDIUM
**Impact**: Missing visual feedback on iOS

**Problems**:

1. **Wave label scale** (lines 157-159) - Cosmetic
2. **Timer warning pulse** (lines 250-252) - Important visual feedback
3. **HP warning pulse** (lines 311-313) - Important visual feedback
4. **Bar flash** (lines 286-288) - Cosmetic
5. **Label pulse** (lines 296-298) - Cosmetic

**Most Critical**: HP warning pulse and timer warning pulse provide important game state feedback.

**Proposed Solution**:
- Remove cosmetic Tween animations (wave label, bar flash, label pulse)
- For HP/timer warnings: Consider manual animation in `_process()` if important for iOS UX

**Decision Point**: Discuss with user whether HP/timer warning animations are critical enough to implement manual animation.

---

### 🟢 LOW - Cosmetic Only (Optional Fixes)

#### 5. Camera Shake (Wasteland)
**File**: `scenes/game/wasteland.gd:846-861`
**Impact**: Camera shake doesn't work on iOS
**Priority**: LOW (cosmetic feedback only)

**Note**: Screen flash already works for level-up feedback. Camera shake is extra polish.

---

#### 6. Aura Pulse Animation
**File**: `scripts/components/aura_visual.gd:146-149`
**Impact**: Aura visual doesn't pulse on iOS
**Priority**: LOW (cosmetic only, aura still functions)

---

#### 7. Drop Pickup Idle Animations
**File**: `scripts/entities/drop_pickup.gd:212-227`
**Impact**: Drops don't bob/pulse/rotate on iOS
**Priority**: LOW (cosmetic only, pickups still functional)

**Note**: These are separate from the critical cleanup issue (#1). Idle animations are just visual flair.

---

#### 8. Character Card Hover Animations
**File**: `scripts/ui/character_selection.gd:280-282, 707-710`
**Impact**: Cards don't scale on hover/click
**Priority**: LOW (cosmetic feedback only)

---

## Implementation Plan

### Session Structure

**Priority Order**:
1. 🔴 **CRITICAL** - Fix memory leaks first (Issues #1, #2)
2. 🟡 **MEDIUM** - Fix visual bugs (Issues #3, #4)
3. 🟢 **LOW** - Optional cosmetic fixes (Issues #5-8)

### Commit Strategy

**Option A: Single Comprehensive Commit**
```
fix(ios): remove all Tween animations for iOS Metal compatibility

- Fix drop pickup memory leak (immediate cleanup)
- Fix character panel memory leak (immediate cleanup)
- Fix player damage flash (manual timer-based)
- Remove HUD cosmetic Tween animations
- Document remaining cosmetic issues as known limitations
```

**Option B: Separate Commits by Priority**
```
Commit 1: fix(ios): fix critical memory leaks from Tween callbacks
Commit 2: fix(ios): fix player damage flash and HUD animations
Commit 3 (optional): fix(ios): remove cosmetic Tween animations
```

**Recommendation**: Option A (single comprehensive commit) - clean sweep of all Tween issues.

---

## Fix Details

### Issue #1: Drop Pickup Cleanup

**File**: `scripts/entities/drop_pickup.gd`

**Remove lines 186-206**:
```gdscript
# DELETE THIS:
    # Play collection animation (scale up + fade out)
    print("[DropPickup]   Creating collection animation tween")
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
    tween.tween_property(self, "modulate:a", 0.0, 0.2)
    tween.tween_callback(_on_collection_animation_complete)
    print("[DropPickup]   Animation tween started")
    print("[DropPickup] ═══ collect() EXIT (animation started) ═══")


func _on_collection_animation_complete() -> void:
    """Called when collection animation completes - cleanup"""
    print("[DropPickup] ═══ _on_collection_animation_complete() ENTRY ═══")
    print("[DropPickup]   Currency: ", currency_type, " x", amount)
    print("[DropPickup]   Instance ID: ", get_instance_id())
    print("[DropPickup]   Is inside tree: ", is_inside_tree())
    print("[DropPickup]   Is queued for deletion: ", is_queued_for_deletion())
    print("[DropPickup]   Calling queue_free()")
    queue_free()
    print("[DropPickup] ═══ _on_collection_animation_complete() EXIT ═══")
```

**Replace with**:
```gdscript
    # Immediate cleanup (iOS-compatible - Tweens don't work on iOS Metal renderer)
    queue_free()
```

**Also remove idle animations (lines 212-227)** - optional, cosmetic only:
```gdscript
func _start_idle_animations() -> void:
    """Start looping animations for visual appeal (disabled for iOS compatibility)"""
    # NOTE: Idle animations disabled - Tweens don't work on iOS Metal renderer
    # Pickups are still fully functional, just without cosmetic bob/pulse/rotate
    pass
```

---

### Issue #2: Character Panel Cleanup

**File**: `scripts/ui/character_selection.gd`

**Replace lines 591-612**:
```gdscript
# OLD (with Tween animation):
    if content_panel and backdrop:
        var tween = create_tween()
        tween.set_parallel(true)

        # Backdrop fade-out
        var backdrop_style = backdrop.get_theme_stylebox("panel")
        if backdrop_style and backdrop_style is StyleBoxFlat:
            tween.tween_property(backdrop_style, "bg_color", Color(0, 0, 0, 0), 0.2)

        # Content panel slide-down
        (
            tween
            . tween_property(content_panel, "offset_top", 1000, 0.25)
            . set_ease(Tween.EASE_IN)
            . set_trans(Tween.TRANS_CUBIC)
        )

        # Wait for animation to complete, then remove
        tween.tween_callback(func(): panel.queue_free())
    else:
        panel.queue_free()

    current_detail_panel = null
```

**NEW (immediate cleanup)**:
```gdscript
    # Immediate cleanup (iOS-compatible - Tweens don't work on iOS Metal renderer)
    if panel:
        panel.queue_free()
    current_detail_panel = null
```

**Also remove card hover animations (optional)** - lines 280-282, 707-710.

---

### Issue #3: Player Damage Flash

**File**: `scripts/entities/player.gd`

**Add variable** (after line 55):
```gdscript
var damage_flash_timer: float = 0.0
var damage_flash_duration: float = 0.2
```

**Replace lines 570-590**:
```gdscript
# OLD (with Tween):
        if child is ColorRect:
            active_damage_tween = create_tween()
            active_damage_tween.tween_property(child, "color", Color.RED, 0.1)
            active_damage_tween.tween_property(child, "color", original_visual_color, 0.1)
            active_damage_tween.tween_callback(func(): _on_damage_flash_complete(child))
        elif child is Sprite2D:
            active_damage_tween = create_tween()
            active_damage_tween.tween_property(child, "modulate", Color.RED, 0.1)
            active_damage_tween.tween_property(child, "modulate", Color.WHITE, 0.1)
```

**NEW (timer-based)**:
```gdscript
func _flash_damage_visual() -> void:
    """Visual feedback for taking damage (iOS-compatible - no Tweens)"""
    damage_flash_timer = damage_flash_duration

    var visual = get_node_or_null("Visual")
    if not visual:
        return

    # Immediate color change
    if visual is ColorRect:
        visual.color = Color.RED
    elif visual is Sprite2D:
        visual.modulate = Color.RED
```

**Add to _process() or _physics_process()**:
```gdscript
    # Update damage flash timer
    if damage_flash_timer > 0:
        damage_flash_timer -= delta
        if damage_flash_timer <= 0:
            _restore_visual_color()
```

**Add new function**:
```gdscript
func _restore_visual_color() -> void:
    """Restore visual color after damage flash"""
    var visual = get_node_or_null("Visual")
    if not visual:
        return

    if visual is ColorRect:
        visual.color = original_visual_color
    elif visual is Sprite2D:
        visual.modulate = Color.WHITE
```

**Remove callback function** (lines 593-614):
```gdscript
# DELETE: _on_damage_flash_complete() - no longer needed
```

---

### Issue #4: HUD Animations

**File**: `scenes/ui/hud.gd`

**Cosmetic animations to remove**:

1. **Wave label scale** (lines 157-159):
```gdscript
# DELETE:
    var tween = create_tween()
    tween.tween_property(wave_label, "scale", Vector2(1.5, 1.5), 0.2)
    tween.tween_property(wave_label, "scale", Vector2(1.0, 1.0), 0.2)
```

2. **Bar flash** (lines 286-288):
```gdscript
# DELETE entire _flash_bar() function or simplify to:
func _flash_bar(bar: ProgressBar, flash_color: Color) -> void:
    """Flash a progress bar (iOS-compatible - no animation)"""
    # Disabled for iOS compatibility - Tweens don't work on iOS Metal renderer
    pass
```

3. **Label pulse** (lines 296-298):
```gdscript
# DELETE entire _pulse_label() function or simplify to:
func _pulse_label(label: Label) -> void:
    """Pulse a label (iOS-compatible - no animation)"""
    # Disabled for iOS compatibility - Tweens don't work on iOS Metal renderer
    pass
```

**Important warnings to keep** (discuss with user):

4. **Timer warning pulse** (lines 250-252) - Could be important for gameplay
5. **HP warning pulse** (lines 311-313) - Could be important for low HP awareness

**Decision**: Keep HP/timer warnings as Tweens for now (they won't work on iOS but also won't break anything). Can revisit if user reports UX issues.

---

## Testing Plan

### After Fixes

1. **Desktop Testing** (quick validation):
   - Collect drops → verify immediate cleanup
   - Browse characters → verify panel cleanup
   - Take damage as player → verify color restoration
   - Verify HUD still displays correctly (no animations)

2. **iOS Testing** (critical validation):
   - Play wave 1-3 on iOS device
   - Collect multiple drops → check memory doesn't accumulate
   - Browse character details repeatedly → check memory
   - Take damage → verify no stuck RED visual
   - Check game performance over 5+ minutes

3. **Memory Profiling** (if available):
   - Monitor node count during gameplay
   - Verify drop pickups/panels are freed
   - Check for memory leaks

---

## Known Limitations (After Fix)

**Visual effects that won't work on iOS**:
- Drop pickup idle animations (bob, pulse, rotate)
- Camera shake on level-up
- Aura pulse animation
- Character card hover animations
- HUD cosmetic pulses/flashes
- HP/timer warning pulses (important - may need manual implementation)

**All game functionality works correctly** - only visual polish is affected.

---

## References

- **Root Cause**: `docs/experiments/ios-tween-failure-analysis-2025-11-15.md`
- **Previous Fixes**:
  - Commit `b2b93d0`: HUD overlay fix
  - Commit `5126e2a`: Zombie enemy fix
- **Pattern**: Immediate cleanup instead of Tween callbacks

---

## Quick Start for Next Session

**User prompt**:
```
Continue iOS Tween comprehensive fix from docs/experiments/ios-tween-comprehensive-audit-2025-11-15.md

Please fix all 8 issues following the implementation plan. Priority: Critical (#1-2) → Medium (#3-4) → Low (#5-8).
```

**Expected flow**:
1. Read this document
2. Create todo list (8 items)
3. Fix issues in priority order
4. Commit with comprehensive message
5. Test and verify

---

**Status**: READY FOR IMPLEMENTATION
**Estimated time**: 30-45 minutes for all fixes
**Risk**: LOW (following proven pattern from enemy/HUD fixes)
