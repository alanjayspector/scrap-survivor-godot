# Floating Joystick Implementation Plan

**Priority**: P1 - Critical for TestFlight distribution
**Estimated Time**: 30-45 minutes (implementation + testing)
**Status**: Ready to implement

---

## Problem Statement

Current fixed-position joystick causes:
- Users lose track of joystick position
- Thumb strays outside control zone → unresponsive controls
- Awkward for different hand positions/sizes
- Poor accessibility for left-handed players

**User Feedback**: "it either becomes non responsive, or i'm straying out of whatever the zone is to use it but it's really really annoying"

---

## Solution: Floating Joystick (Industry Standard)

Joystick appears wherever user touches and follows their thumb.

**Benefits**:
- Never lose control - joystick spawns at touch point
- Works for all hand positions (left, right, any size)
- Natural feel - no "straying out of zone"
- Matches industry standards (Brotato, Vampire Survivors, Archero)

---

## Technical Design

### Current Implementation

**File**: `scripts/ui/virtual_joystick.gd`

**Current State**:
```gdscript
# Fixed position in bottom-left
position = Vector2(100, get_viewport_rect().size.y - 150)
max_distance = 85.0  # pixels from center
DEAD_ZONE_THRESHOLD = 12.0  # pixels
```

**Issues**:
- Fixed `position` set in `_ready()`
- Uses `_gui_input()` which only captures touches within Control node bounds
- Offset calculated from fixed center, not dynamic touch point

---

### Target Implementation

**Architecture Changes**:

1. **Dynamic State Machine**
```gdscript
enum JoystickState {
    INACTIVE,    # No touch, joystick hidden
    ACTIVE       # Touch active, joystick visible
}
```

2. **Touch Tracking**
```gdscript
var touch_origin: Vector2 = Vector2.ZERO  # Where user first touched
var touch_index: int = -1  # Track specific touch (multi-touch safe)
var touch_zone_rect: Rect2  # Left half of screen
```

3. **Viewport-Level Input**
- Replace `_gui_input()` with `_input()` to capture touches anywhere
- Check if touch is in left half of screen (movement zone)
- Position joystick at touch point dynamically

---

## Implementation Steps

### Step 1: Architecture Setup (5 minutes)

**Goal**: Add state machine and touch tracking variables

**Changes to `scripts/ui/virtual_joystick.gd`**:

```gdscript
# Add at top of script (after class_name)
enum JoystickState {
    INACTIVE,
    ACTIVE
}

# Add new variables
var state: JoystickState = JoystickState.INACTIVE
var touch_origin: Vector2 = Vector2.ZERO
var touch_index: int = -1
var touch_zone_rect: Rect2
```

**Update `_ready()`**:
```gdscript
func _ready() -> void:
    add_to_group("virtual_joystick")

    # REMOVE THIS LINE:
    # position = Vector2(100, get_viewport_rect().size.y - 150)

    # ADD: Hide joystick initially
    base.visible = false
    stick.visible = false

    # ADD: Define touch zone (left half of screen)
    var viewport_size = get_viewport_rect().size
    touch_zone_rect = Rect2(0, 0, viewport_size.x / 2, viewport_size.y)
```

---

### Step 2: Touch Begin Handler (10 minutes)

**Goal**: Spawn joystick at touch point

**Replace `_gui_input()` with `_input()`**:

```gdscript
# REMOVE _gui_input() entirely
# ADD:
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventScreenDrag:
        _handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        # Only capture touches in left half of screen
        if touch_zone_rect.has_point(event.position) and state == JoystickState.INACTIVE:
            # Start floating joystick
            touch_origin = event.position
            touch_index = event.index
            is_pressed = true
            state = JoystickState.ACTIVE

            # Position joystick at touch point
            global_position = touch_origin
            base.visible = true
            stick.visible = true
            stick.position = Vector2.ZERO
    else:
        # Touch released
        if event.index == touch_index:
            is_pressed = false
            state = JoystickState.INACTIVE
            base.visible = false
            stick.visible = false
            current_direction = Vector2.ZERO
            direction_changed.emit(Vector2.ZERO)
            touch_index = -1
```

---

### Step 3: Touch Drag Handler (10 minutes)

**Goal**: Track thumb movement relative to spawn point

**Add drag handling**:

```gdscript
func _handle_drag(event: InputEventScreenDrag) -> void:
    if is_pressed and event.index == touch_index and state == JoystickState.ACTIVE:
        # Calculate offset from touch origin (not fixed center)
        var offset = event.position - touch_origin
        _update_stick_position_from_offset(offset)


func _update_stick_position_from_offset(offset: Vector2) -> void:
    """Update stick position from touch offset (replaces old _update_stick_position)"""
    var offset_length: float = offset.length()

    # Clamp to max distance
    if offset_length > max_distance:
        offset = offset.normalized() * max_distance
        offset_length = max_distance

    # Always update stick visual position
    stick.position = offset

    # Apply dead zone for movement
    if offset_length > DEAD_ZONE_THRESHOLD:
        current_direction = offset.normalized()
        direction_changed.emit(current_direction)
    else:
        current_direction = Vector2.ZERO
        direction_changed.emit(Vector2.ZERO)
```

**Remove old `_update_stick_position()` function** - it's replaced by the above.

---

### Step 4: Visual Polish (5 minutes)

**Goal**: Ensure smooth show/hide transitions

**Verify visibility logic**:
- `base.visible = false` in `_ready()`
- `base.visible = true` when touch begins
- `base.visible = false` when touch ends
- Same for `stick`

**Optional Enhancement** (can skip for now):
```gdscript
# Add fade-in/out for smoother UX
var tween: Tween
func _show_joystick() -> void:
    base.visible = true
    stick.visible = true
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(base, "modulate:a", 1.0, 0.1)

func _hide_joystick() -> void:
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(base, "modulate:a", 0.0, 0.1)
    tween.tween_callback(func(): base.visible = false; stick.visible = false)
```

---

## Testing Checklist

### Desktop Testing (Quick Verification)
- [ ] Run game in Godot editor
- [ ] Joystick hidden on startup
- [ ] Click left side of screen → joystick appears at click point
- [ ] Drag mouse → player moves
- [ ] Release mouse → joystick disappears
- [ ] Click again → joystick appears at new location

### iOS Device Testing (Critical)
- [ ] Export to iOS (Runnable IPA)
- [ ] Install on device
- [ ] Launch game
- [ ] Touch left side of screen
- [ ] Joystick appears instantly at touch point
- [ ] Drag thumb → smooth player movement
- [ ] Lift thumb → joystick disappears
- [ ] Touch new location → joystick reappears there
- [ ] Test rapid tap/drag cycles (no lag or glitches)
- [ ] Test edge cases:
  - [ ] Touch near screen edge
  - [ ] Touch during wave transition
  - [ ] Multi-touch (joystick + tap buttons)
- [ ] Play full wave (no unresponsive zones)
- [ ] Verify feels ~95%+ better than fixed position

---

## Known Edge Cases & Solutions

### 1. Multi-Touch Conflicts
**Problem**: User touches UI button while using joystick
**Solution**: `touch_index` tracking ensures each touch is independent

### 2. Joystick Appears in Wrong Place
**Problem**: Touch registered outside intended zone
**Solution**: `touch_zone_rect` restricts to left half only

### 3. HUD Button Interference
**Problem**: Touching HUD elements might capture touch
**Solution**: UI elements in right half of screen, joystick zone is left half

### 4. Performance
**Problem**: Frequent position updates might cause lag
**Mitigation**:
- Input events are already optimized by Godot
- Position updates only during active drag
- No complex calculations (just offset math)

---

## Rollback Plan

If floating joystick has critical issues:

1. **Quick Fix**: Increase max_distance to 150px, reduce dead_zone to 5px
2. **Full Rollback**: Revert to commit before floating joystick changes
3. **Hybrid**: Keep fixed position but increase zone size significantly

---

## Success Criteria

**Must Have**:
- [x] Joystick spawns at touch point
- [x] No unresponsive zones
- [x] Works for left and right hand
- [x] Smooth drag tracking
- [x] No conflicts with UI

**Nice to Have** (can add later):
- [ ] Fade in/out animation
- [ ] Haptic feedback on touch
- [ ] Visual indicator for dead zone

---

## Post-Implementation

After successful testing:

1. **Commit changes**:
   ```bash
   git add scripts/ui/virtual_joystick.gd
   git commit -m "feat: implement floating joystick for mobile controls

   - Joystick spawns at touch point instead of fixed position
   - Touch-anywhere UX matches industry standards (Brotato, VS)
   - Solves 'straying out of zone' responsiveness issues
   - Works for all hand positions and sizes
   - Left-half touch zone prevents UI conflicts

   Closes mobile control usability issues"
   ```

2. **Test one more time on device**

3. **Prepare new TestFlight build**:
   - Export to Xcode (Runnable OFF)
   - Run privacy cleanup script
   - Archive and upload
   - Distribute to testers

4. **Update documentation**:
   - Mark Phase 2 as complete in timeline
   - Update mobile controls plan
   - Note improved UX metrics

---

## Reference Files

- **Implementation**: `scripts/ui/virtual_joystick.gd`
- **Scene**: `scenes/ui/hud.tscn` (contains VirtualJoystick node)
- **Player Integration**: `scripts/entities/player.gd` (connects to joystick signals)
- **Documentation**: `docs/MOBILE-TOUCH-CONTROLS-PLAN.md`

---

## Quick Start for Next Session

```
1. Open scripts/ui/virtual_joystick.gd
2. Follow Step 1: Architecture Setup
3. Follow Step 2: Touch Begin Handler
4. Follow Step 3: Touch Drag Handler
5. Test in editor (desktop mouse simulation)
6. Export to iOS and test on device
7. If successful, commit and prepare TestFlight build
```

---

**Ready to implement in next session with full token budget!**
