# AI Research Report: Godot 4.x Camera2D Visual Jump on Scene Load

## Problem Statement

A visual camera jump occurs when spawning a player in Godot 4.x despite all logged positions showing (0, 0). The camera appears to teleport or snap to its final position rather than starting correctly centered on the player.

### Affected System
- **Game**: Top-down survival game (Scrap Survivor)
- **Engine**: Godot 4.5.1
- **Platform**: iOS (A17 Pro) + Desktop
- **Camera Type**: Camera2D with smooth following
- **Player Type**: CharacterBody2D
- **Spawn Position**: Vector2.ZERO (0, 0)

### Current Implementation

#### Spawn Sequence (wasteland.gd):
```gdscript
# 1. Create player instance
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
player_instance = PLAYER_SCENE.instantiate()

# 2. Set character ID and add to group
player_instance.character_id = char_id
player_instance.add_to_group("player")

# 3. Position at center
player_instance.global_position = Vector2.ZERO

# 4. Add to scene tree
player_container.add_child(player_instance)

# 5. Wait one frame for player _ready()
await get_tree().process_frame

# 6. Setup camera
camera.target = player_instance
camera.global_position = player_instance.global_position  # Both at (0, 0)
camera.reset_smoothing()  # Clear internal lerp buffer
camera.enabled = true
```

#### Camera Controller (_process):
```gdscript
extends Camera2D

@export var follow_smoothness: float = 5.0
@onready var target: Node2D = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
    if not target:
        return

    # Smooth follow with lerp
    var target_pos = target.global_position
    var new_camera_pos = global_position.lerp(target_pos, follow_smoothness * delta)

    # Clamp to boundaries
    new_camera_pos.x = clamp(new_camera_pos.x, boundaries.position.x, boundaries.position.x + boundaries.size.x)
    new_camera_pos.y = clamp(new_camera_pos.y, boundaries.position.y, boundaries.position.y + boundaries.size.y)

    global_position = new_camera_pos
```

### Diagnostic Evidence

All positions log correctly at (0, 0):
```
[DIAGNOSTIC] PRE-ADD: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0) Camera enabled=false
[DIAGNOSTIC] POST-ADD: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0)
[DIAGNOSTIC] AFTER-FRAME-WAIT: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0) Camera offset=(0, 0)
[DIAGNOSTIC] BEFORE reset_smoothing: Camera offset=(0, 0) Camera zoom=(1, 1)
[DIAGNOSTIC] CAMERA FINAL STATE: pos=(0.0, 0.0) offset=(0, 0) zoom=(1, 1) enabled=true target=Player:<CharacterBody2D#...>
```

**Yet visual jump still persists despite all positions being (0, 0).**

### Previously Attempted Solutions

1. âŒ Waited one frame before enabling camera - Jump persists
2. âŒ Called `camera.reset_smoothing()` - Jump persists
3. âŒ Set `camera.global_position = player.global_position` - Jump persists
4. âŒ Enabled camera AFTER player fully initialized - Jump persists

---

## Root Cause Analysis

### The Fundamental Problem

The visual camera jump occurs due to a **conflict between custom camera lerp smoothing and Camera2D's internal initialization state**. Despite all logged positions showing (0, 0), visual rendering is delayed by one or more frames due to Camera2D's internal state management.

### Camera2D Internal State: The 'first' Flag

Camera2D maintains an internal `first` boolean flag that controls special initialization logic. When the camera enters the scene tree, this flag is set to `true`, and on the first call to `get_camera_transform()`, it initializes three internal position variables:

```cpp
// From camera_2d.cpp get_camera_transform()
if (!first) {
    // Normal smoothing logic
    if (position_smoothing_enabled) {
        real_t c = position_smoothing_speed * delta;
        smoothed_camera_pos = ((camera_pos - smoothed_camera_pos) * c) + smoothed_camera_pos;
        ret_camera_pos = smoothed_camera_pos;
    } else {
        ret_camera_pos = smoothed_camera_pos = camera_pos;
    }
} else {
    // FIRST FRAME ONLY - Initialize all position variables
    ret_camera_pos = smoothed_camera_pos = camera_pos = new_camera_pos;
    first = false;
}
```

**The issue:** You're using BOTH Camera2D's built-in position smoothing AND custom lerp smoothing in `_process()`. This creates double-smoothing where:
- Your custom `_process()` lerp moves camera gradually toward player
- Camera2D's internal smoothing then smooths that movement again
- Visual position lags behind logged `global_position`

### Position Logging vs Visual Rendering

When you log `camera.global_position`, you're reading the **node's transform position**, not the **actual visual rendering position**.

Camera2D renders based on its internal `smoothed_camera_pos` variable, which is:
- **Private** (inaccessible from GDScript)
- **Updated during `get_camera_transform()`** (called during rendering)
- **Subject to smoothing** even after `reset_smoothing()` if `position_smoothing_enabled = true`

The rendering pipeline:
```
1. Spawn code runs (player at 0,0, camera at 0,0)
2. await get_tree().process_frame
3. Camera enabled, reset_smoothing() called
4. _process() runs (custom lerp executes)
5. Camera2D._process() runs (internal smoothing executes)
6. get_camera_transform() called (calculates visual position from smoothed_camera_pos)
7. Viewport renders frame (uses smoothed_camera_pos, NOT global_position)
```

Even though you set `camera.global_position = Vector2.ZERO`, the internal `smoothed_camera_pos` variable may not get properly initialized until `get_camera_transform()` is called with the `first` flag still true.

### Camera2D Internal Position Variables

Camera2D maintains **four position-related variables**:

1. **`camera_pos`** - Target position for smoothing (affected by drag margins, limits)
2. **`smoothed_camera_pos`** - Smoothed position used for rendering (WHAT ACTUALLY DISPLAYS)
3. **`camera_screen_center`** - Actual screen center in global coordinates
4. **Node's `global_position`** - Node transform position (what you're logging - NOT what displays)

### Why reset_smoothing() Alone Isn't Sufficient

When you call `reset_smoothing()`:

```cpp
// From camera_2d.cpp
void Camera2D::reset_smoothing() {
    _update_scroll();
    smoothed_camera_pos = camera_pos;
}
```

**Critical timing issue:** If `_update_scroll()` hasn't computed `camera_pos` yet (because viewport transform isn't ready), then `smoothed_camera_pos` gets set to an outdated or uninitialized value.

The correct order must be:
1. `force_update_scroll()` - Updates viewport transform and calculates `camera_pos`
2. `reset_smoothing()` - Sets `smoothed_camera_pos = camera_pos` (now properly initialized)

Without `force_update_scroll()` first, the viewport's canvas transform doesn't update, causing the visual discrepancy.

---

## Solution: Complete Fixes

### Option 1: Disable Custom Smoothing (RECOMMENDED)

**Root approach:** Remove custom `_process()` lerp and use Camera2D's built-in smoothing exclusively.

#### Implementation:

**1. Update camera_controller.gd - Remove _process() lerp:**
```gdscript
extends Camera2D

@export var follow_smoothness: float = 5.0
var target: Node2D = null

func _ready():
    # Use built-in smoothing, not custom lerp
    position_smoothing_enabled = true
    position_smoothing_speed = follow_smoothness

func set_target(new_target: Node2D):
    target = new_target
    # Don't manually move camera in _process
```

**2. Update wasteland.gd spawn sequence:**
```gdscript
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
player_instance = PLAYER_SCENE.instantiate()
player_instance.character_id = char_id
player_instance.add_to_group("player")
player_instance.global_position = Vector2.ZERO
player_container.add_child(player_instance)

# Critical step: Wait for scene tree processing
await get_tree().process_frame

# DISABLE smoothing during spawn for instant positioning
camera.position_smoothing_enabled = false
camera.target = player_instance
camera.global_position = player_instance.global_position
camera.enabled = true

# Force immediate viewport update
camera.force_update_scroll()
camera.reset_smoothing()

# Optional: Re-enable smoothing for subsequent camera movement
# camera.position_smoothing_enabled = true
```

**Why this works:**
- Eliminates double-smoothing conflict
- `position_smoothing_enabled = false` on spawn ensures instant camera positioning
- `force_update_scroll()` then `reset_smoothing()` in correct order
- Camera is ready to follow smoothly after initial spawn

### Option 2: Keep Custom Smoothing (Advanced)

**Root approach:** Disable Camera2D's built-in smoothing entirely and use only custom logic.

#### Implementation:

**1. Update camera_controller.gd - Ensure smoothing disabled:**
```gdscript
extends Camera2D

@export var follow_smoothness: float = 5.0
var target: Node2D = null

func _ready():
    # CRITICAL: Disable all built-in smoothing
    position_smoothing_enabled = false

func set_target(new_target: Node2D):
    target = new_target

func _process(delta: float) -> void:
    if not target or not enabled:
        return

    var target_pos = target.global_position
    
    # Your custom lerp (only runs when smoothing disabled)
    var new_camera_pos = global_position.lerp(target_pos, follow_smoothness * delta)
    
    # Apply boundaries
    if boundaries:
        new_camera_pos.x = clamp(new_camera_pos.x, boundaries.position.x, 
                                  boundaries.position.x + boundaries.size.x)
        new_camera_pos.y = clamp(new_camera_pos.y, boundaries.position.y, 
                                  boundaries.position.y + boundaries.size.y)
    
    global_position = new_camera_pos
    
    # Force viewport update to prevent one-frame rendering delay
    force_update_scroll()
```

**2. Update wasteland.gd spawn sequence:**
```gdscript
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
player_instance = PLAYER_SCENE.instantiate()
player_instance.character_id = char_id
player_instance.add_to_group("player")
player_instance.global_position = Vector2.ZERO
player_container.add_child(player_instance)

await get_tree().process_frame

# Ensure no built-in smoothing
camera.position_smoothing_enabled = false
camera.target = player_instance
camera.global_position = player_instance.global_position

# Update viewport and initialize smoothing state
camera.force_update_scroll()
camera.reset_smoothing()

camera.enabled = true
```

**Why this works:**
- Complete control over smoothing behavior
- `position_smoothing_enabled = false` prevents any built-in smoothing interference
- `force_update_scroll()` ensures viewport is updated before rendering
- Custom `_process()` provides deterministic camera movement

### Option 3: Temporary Smoothing Disable (Cleanest)

**Root approach:** Temporarily disable smoothing during spawn, then re-enable for ongoing movement.

#### Implementation:

**1. Update camera_controller.gd:**
```gdscript
extends Camera2D

@export var follow_smoothness: float = 5.0
var target: Node2D = null

func _ready():
    position_smoothing_enabled = true
    position_smoothing_speed = follow_smoothness

func set_target(new_target: Node2D):
    target = new_target

func _process(delta: float) -> void:
    if not target or not enabled:
        return
    # Built-in smoothing handles all camera movement
```

**2. Update wasteland.gd spawn sequence:**
```gdscript
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
player_instance = PLAYER_SCENE.instantiate()
player_instance.character_id = char_id
player_instance.add_to_group("player")
player_instance.global_position = Vector2.ZERO
player_container.add_child(player_instance)

await get_tree().process_frame

# Temporarily disable smoothing for spawn
camera.position_smoothing_enabled = false
camera.target = player_instance
camera.global_position = player_instance.global_position
camera.force_update_scroll()
camera.reset_smoothing()
camera.enabled = true

# Re-enable smoothing after spawn (now camera follows smoothly)
await get_tree().create_timer(0.1).timeout
camera.position_smoothing_enabled = true
```

**Why this works:**
- Combines benefits of both approaches
- Instant camera positioning on spawn (no visual jump)
- Smooth camera following immediately after spawn
- Minimal code changes required

---

## Technical Deep Dive: Camera2D Internals

### The four position variables

Camera2D manages these internal variables that affect visual rendering:

```cpp
Vector2 camera_pos;              // Target position (computed from limits/drag)
Vector2 smoothed_camera_pos;     // Smoothed position (actually rendered)
Vector2 camera_screen_center;    // Screen center position
bool first;                       // First frame flag (true in NOTIFICATION_ENTER_TREE)
```

### Rendering Transform Pipeline

The viewport rendering uses `smoothed_camera_pos`, not `global_position`:

```
camera.global_position (node property) â‰  camera.smoothed_camera_pos (internal rendering)
```

When `position_smoothing_enabled = true`:
```cpp
// In get_camera_transform(), each frame:
real_t c = position_smoothing_speed * delta;
smoothed_camera_pos = ((camera_pos - smoothed_camera_pos) * c) + smoothed_camera_pos;
ret_camera_pos = smoothed_camera_pos;  // This is what renders!
```

### force_update_scroll() Critical Behavior

```cpp
void Camera2D::_update_scroll() {
    // Recalculates camera_pos based on limits, drag margins, target position
    // Applies boundary clamping
    // Updates viewport canvas_transform
    viewport->set_canvas_transform(xform);  // THIS updates visual rendering
}

void Camera2D::force_update_scroll() {
    _update_scroll();  // Immediately recalculates everything
}
```

**Why it's critical:** Without calling `force_update_scroll()` before `reset_smoothing()`, the viewport canvas transform doesn't update, so the visual position misaligns with the node position.

### Correct Initialization Sequence

The proper order for spawn initialization:

```gdscript
# 1. Disable smoothing (prevents lerping from uninitialized state)
camera.position_smoothing_enabled = false

# 2. Set camera position
camera.global_position = player_instance.global_position

# 3. Update all internal state (camera_pos, viewport transform)
camera.force_update_scroll()

# 4. Align smoothed_camera_pos with camera_pos
camera.reset_smoothing()

# 5. Enable camera rendering
camera.enabled = true

# 6. Optional: Re-enable smoothing for following movement
# camera.position_smoothing_enabled = true
```

**Diagram of state alignment:**
```
Before: global_position=(0,0), camera_pos=?, smoothed_camera_pos=?, viewport.transform=?
Step 3: force_update_scroll() â†’ camera_pos=(0,0), viewport.transform correct
Step 4: reset_smoothing() â†’ smoothed_camera_pos=(0,0)
After:  global_position=(0,0), camera_pos=(0,0), smoothed_camera_pos=(0,0) âœ“ ALIGNED
```

---

## iOS-Specific Behavior

The visual jump may be more pronounced on iOS due to:

1. **Higher refresh rates** - A17 Pro supports 120Hz ProMotion (vs typical 60Hz desktop)
2. **Metal rendering pipeline** - Different timing characteristics than OpenGL
3. **Frame buffering** - iOS display system buffers frames differently
4. **Vsync timing** - Metal rendering syncs differently with display refresh

### Mitigation for iOS:

```gdscript
# Detect platform and adjust
var platform_smoothing: float = 5.0
if OS.get_name() == "iOS":
    platform_smoothing = 10.0  # Faster smoothing for high-refresh displays

camera.position_smoothing_speed = platform_smoothing
```

---

## Potential Secondary Issues: CharacterBody2D Collision

If player spawns overlapping collision geometry, physics may push the player on first frame:

```gdscript
# Verify no collision-based movement on spawn:
await get_tree().process_frame
var spawn_pos = player_instance.global_position
await get_tree().physics_frame
print("Player pos after physics: ", player_instance.global_position)
# Should equal spawn_pos, if collision-free
```

If player moves after physics frame, add margin around spawn or ensure collision-free zone.

---

## Alternative Approaches

### A. Camera2D as Player Child (Simplest)

For games without complex camera requirements:

```gdscript
# player.tscn
Player (CharacterBody2D)
  â””â”€ Camera2D
      - enabled: true
      - position_smoothing_enabled: false (or tune as needed)
      - position: Vector2.ZERO (relative to player)
      - zoom: Vector2.ONE
```

**Advantages:**
- Camera automatically follows player
- Zero spawn code needed
- No visual jump possible (camera is child of player)

**Disadvantages:**
- Less control over boundaries
- Camera constraints difficult to implement
- Can't smoothly pan to different targets

### B. Verify Visual Position with get_screen_center_position()

For debugging, use the actual rendered position:

```gdscript
# Compare logical vs visual position
func debug_camera_position():
    var logical_pos = camera.global_position
    var visual_pos = camera.get_screen_center_position()
    
    if logical_pos != visual_pos:
        print("MISMATCH!")
        print("  Logical (node): ", logical_pos)
        print("  Visual (render): ", visual_pos)
        print("  Difference: ", visual_pos - logical_pos)
    else:
        print("Positions aligned âœ“")
```

This reveals whether smoothing is causing the discrepancy.

---

## Related Godot Issues and Documentation

The visual jump problem relates to several documented Godot engine issues:

### GitHub Issues
- **#50807** - `reset_smoothing()` does not work as described
  - Documents that reset_smoothing() requires force_update_scroll() first
  
- **#28492** - Camera2D has one-frame delay
  - Describes rendering lagging one frame behind position changes
  
- **#74203** - Camera2D renders the position of the previous frame
  - Shows smoothed_camera_pos lags behind global_position
  
- **#16323** - Camera2D with smoothing enabled has intermittent position jumps
  - Multiple cases of visual jumps due to smoothing initialization
  
- **#62441** - Camera2D limits don't clamp camera position properly
  - Boundary clamping issues related to state management

### Key Takeaway from Issues
The common theme: **Camera2D requires careful state initialization**, especially when enabling cameras dynamically after scene load. The internal smoothing state must be explicitly synchronized with the desired camera position.

---

## Verification Checklist

After implementing a fix, verify with:

```gdscript
# Immediate post-spawn verification
print("Step 1 - Node position: ", camera.global_position)
print("Step 2 - Screen center: ", camera.get_screen_center_position())
print("Step 3 - Should match: ", camera.global_position == camera.get_screen_center_position())

# Visual verification
# Watch the player spawn - camera should:
# âœ“ Appear instantly centered on player at (0, 0)
# âœ“ Show NO visual jump or teleport
# âœ“ Immediately start smooth following (if smoothing enabled)
# âœ“ Stay centered on player during movement

# Enable this for continuous monitoring:
if DEBUG_MODE:
    print("Camera pos: ", camera.get_screen_center_position())
```

---

## Recommended Solution Summary

**For Scrap Survivor (top-down survival game):**

**Recommended:** Option 1 (Disable Custom Smoothing)

**Rationale:**
- Simplest to implement and maintain
- Uses Camera2D's built-in smoothing (optimized, well-tested)
- Eliminates double-smoothing conflict completely
- No custom frame-dependent code needed
- Works identically on iOS and desktop

**Implementation steps:**
1. Remove the `_process()` lerp from camera_controller.gd
2. Add `position_smoothing_enabled = true` and `position_smoothing_speed = 5.0` in `_ready()`
3. Update spawn sequence in wasteland.gd with the provided code
4. Test on both iOS and desktop

**Expected outcome:**
- Camera appears instantly at (0, 0) on spawn
- Zero visual jump
- Smooth camera following during gameplay
- Consistent behavior across platforms

---

## Testing Protocol

```gdscript
# Test spawn behavior
func test_camera_spawn():
    # Before spawn
    assert(camera.global_position == Vector2.ZERO)
    assert(camera.enabled == false)
    
    # Spawn player
    spawn_player_at_zero()
    await get_tree().process_frame
    
    # After spawn setup
    setup_camera_for_player()
    
    # Verify no jump occurred
    var screen_center = camera.get_screen_center_position()
    assert(screen_center == Vector2.ZERO, "Camera not at origin: " + str(screen_center))
    
    # Simulate player movement
    player_instance.global_position = Vector2(100, 100)
    await get_tree().process_frame
    
    # Camera should be following with smoothing
    var new_screen_center = camera.get_screen_center_position()
    assert(new_screen_center.distance_to(Vector2(100, 100)) < 10, "Camera not following")
    
    print("âœ“ Camera spawn test passed")
```

---

## Code Files to Modify

### 1. camera_controller.gd (Recommended Option 1)
- Remove `_process()` method entirely
- Add `_ready()` with smoothing configuration
- Simplify to just store target reference

### 2. wasteland.gd
- Add `force_update_scroll()` before `reset_smoothing()`
- Set `position_smoothing_enabled = false` during spawn
- Add diagnostic output for verification

### 3. Configuration (Optional)
- Create camera config export variables
- Platform-specific smoothing values
- Boundary configuration

---

## Summary

**Root Cause:** Double-smoothing conflict + improper initialization order of Camera2D internal state

**Primary Issue:** Custom `_process()` lerp conflicts with Camera2D's built-in smoothing, and `reset_smoothing()` is called without `force_update_scroll()` first

**Solution:** Use Camera2D's built-in smoothing exclusively, ensure correct initialization order (force_update_scroll â†’ reset_smoothing), and disable smoothing during spawn for instant positioning

**Why positions log correctly but visual jumps:** `global_position` is the node's transform position, but rendering uses the internal `smoothed_camera_pos` variable which isn't visually synchronized until `get_camera_transform()` executes during rendering

**Implementation:** Choose Option 1 (recommended) or Option 2/3 depending on desired camera control requirements
