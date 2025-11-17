# AI Research Request: Godot 4.x Camera2D Visual Jump on Scene Load

## Problem Statement

We have a **visual camera jump** when spawning a player in Godot 4.x that persists despite multiple attempted fixes. The camera positions log correctly (all at 0,0) but the user observes a visible jump/teleport on screen.

## Context

**Game**: Top-down survival game (Scrap Survivor)
**Engine**: Godot 4.5.1
**Platform**: iOS (A17 Pro) + Desktop
**Camera Type**: Camera2D with smooth following (`follow_smoothness = 5.0`)
**Player Type**: CharacterBody2D
**Spawn Position**: Vector2.ZERO (0, 0)

## Current Implementation

### Spawn Sequence (wasteland.gd):
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

### Camera Controller (_process):
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

## Diagnostic Log Output

```
[DIAGNOSTIC] PRE-ADD: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0) Camera enabled=false
[DIAGNOSTIC] POST-ADD: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0)
[DIAGNOSTIC] AFTER-FRAME-WAIT: Player global_pos=(0.0, 0.0) Camera global_pos=(0.0, 0.0) Camera offset=(0, 0)
[DIAGNOSTIC] BEFORE reset_smoothing: Camera offset=(0, 0) Camera zoom=(1, 1)
[DIAGNOSTIC] CAMERA FINAL STATE: pos=(0.0, 0.0) offset=(0, 0) zoom=(1, 1) enabled=true target=Player:<CharacterBody2D#...>
```

**All positions are (0, 0) - yet visual jump still occurs!**

## What We've Already Tried

1. ❌ **Waited one frame before enabling camera** - Jump persists
2. ❌ **Called `camera.reset_smoothing()`** - Jump persists
3. ❌ **Set camera.global_position = player.global_position** - Jump persists
4. ❌ **Enabled camera AFTER player fully initialized** - Jump persists

## Research Questions

### Primary Questions:
1. **Why does visual jump occur when all logged positions are (0, 0)?**
   - Is there a difference between `global_position` and what's actually rendered?
   - Could viewport transform be causing the jump?
   - Is there a one-frame delay between position set and visual update?

2. **Camera2D.reset_smoothing() behavior**
   - Does it clear ALL internal state or just the lerp buffer?
   - Does it need to be called BEFORE setting target or AFTER?
   - Is there additional state we're not resetting?

3. **Viewport rendering timing**
   - When does the viewport actually render relative to global_position changes?
   - Could the camera be rendering at a different position than global_position for one frame?
   - Does `get_screen_center_position()` differ from `global_position`?

### Investigation Areas:

**A. Camera2D Internal State**
- What internal variables does Camera2D maintain beyond global_position?
- Does `offset` affect visual position even when set to (0, 0)?
- Could `drag_*` properties cause visual jump even when disabled?
- Does `position_smoothing_enabled` need explicit false setting?

**B. Scene Tree Timing**
- Does add_child() trigger immediate rendering or defer to next frame?
- When does Camera2D._process() first run relative to our camera.enabled = true?
- Could the camera be rendering BEFORE we set global_position?

**C. CharacterBody2D Spawn Behavior**
- Does CharacterBody2D have any internal position adjustment on first _physics_process?
- Could collision detection be moving the player on first frame?
- Does the player sprite/visual render at a different position than global_position initially?

**D. iOS-Specific Behavior**
- Are there iOS Metal rendering quirks with Camera2D position updates?
- Does iOS have different frame timing than desktop?
- Could this be related to vsync or frame buffering?

### Specific Technical Questions:

1. **Camera2D.reset_smoothing() source code**
   - What EXACTLY does it do internally?
   - Does it reset `prev_camera_pos` or equivalent internal tracking?

2. **Alternative approaches**
   - Should we use `force_update_scroll()` instead of/in addition to reset_smoothing()?
   - Should we disable `position_smoothing_enabled` temporarily?
   - Should we manually set `camera.offset` to compensate?

3. **Viewport camera transform**
   - Could `get_canvas_transform()` be misaligned on first frame?
   - Should we force a viewport update before rendering?

## Expected Behavior

Camera should appear instantly centered on player at (0, 0) with **zero visual movement or jump**.

## Actual Behavior

User observes a **visible jump/teleport** where the camera appears to start at one position and then snap to (0, 0), despite all diagnostics showing (0, 0) from the start.

## Research Deliverables Requested

1. **Root cause explanation** - Why positions log correctly but visual jump occurs
2. **Godot 4.x Camera2D internals** - What state affects visual rendering beyond global_position
3. **Recommended fix** - Step-by-step solution with rationale
4. **Alternative approaches** - If standard methods don't work, what's the workaround?
5. **Similar known issues** - Links to Godot GitHub issues, forum posts, or documentation

## References Provided

- `docs/godot-camera2d-movement.md` - CharacterBody2D movement best practices
- `docs/godot-camera2d-boundaries.md` - Camera2D boundary setup
- `scripts/components/camera_controller.gd` - Our Camera2D implementation

## Priority

**HIGH** - This is a user-facing visual bug that makes the game feel unpolished. We need a definitive solution.
