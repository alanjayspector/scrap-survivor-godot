# Godot 4.x CharacterBody2D Movement and Position Handling Reference

## Table of Contents

1. [Overview](#overview)
2. [move_and_slide() and global_position Updates](#move_and_slide-and-global_position-updates)
3. [Position Modification Safety](#position-modification-safety)
4. [Position Clamping Best Practices](#position-clamping-best-practices)
5. [Physics Frame Timing](#physics-frame-timing)
6. [Caveats and Gotchas](#caveats-and-gotchas)
7. [Code Examples](#code-examples)
8. [Quick Reference Table](#quick-reference-table)

---

## Overview

**CharacterBody2D** is a specialized physics body designed for user-controlled characters. Unlike RigidBody2D, it is not affected by engine physics properties (gravity, friction) but provides high-level collision detection and response through the `move_and_slide()` method. Movement should be driven through velocity changes rather than direct position manipulation.

### Key Characteristics

- Not affected by physics engine gravity or friction
- Provides wall and slope detection
- Automatically handles sliding collisions
- Requires explicit velocity-based movement logic
- Can collide with and push other physics bodies

---

## move_and_slide() and global_position Updates

### When and How move_and_slide() Updates global_position

**Direct Update Mechanism:**

The `move_and_slide()` method **directly updates** the CharacterBody2D's internal position during execution. This update occurs immediately within the physics frame when `move_and_slide()` is called.

**Process Flow:**

1. Input velocity is set on the CharacterBody2D's `velocity` property
2. `move_and_slide()` is called in `_physics_process()`
3. The method performs collision detection along the movement path
4. Collision recovery pushes the body out of overlapping colliders (using `safe_margin`)
5. The body's `global_position` is updated to the new computed position
6. Collision state flags are updated (`is_on_floor()`, `is_on_wall()`, etc.)

**Actual Position Delta:**

The actual movement applied can be retrieved using:

```gdscript
var actual_motion = get_position_delta()  # Returns Vector2
```

This represents the actual distance traveled during the last `move_and_slide()` call, accounting for collisions and sliding.

### Velocity vs. Position

**Critical Distinction:**

- `velocity`: The intended movement vector (pixels per second) that you set before calling `move_and_slide()`
- `global_position`: The actual world position after collision resolution
- `get_real_velocity()`: The actual velocity applied (affected by collisions and slopes)

When the character encounters a wall:
- `velocity` remains unchanged (your input request)
- `get_real_velocity()` returns the actual movement after sliding
- `global_position` reflects the collision-adjusted final position

**Example Scenario:**

```gdscript
func _physics_process(delta: float) -> void:
    # Set intended velocity
    velocity = Vector2(200, 0)  # 200 pixels/sec to the right
    
    # Call move_and_slide - updates global_position internally
    move_and_slide()
    
    # After execution:
    # - If no collision: global_position moved 200 * delta pixels right
    # - If collision: global_position moved less (or different direction due to sliding)
    # - velocity property is unchanged (still Vector2(200, 0))
    # - get_real_velocity() returns actual movement applied
```

---

## Position Modification Safety

### Is It Safe to Modify global_position Immediately After move_and_slide()?

**Short Answer: NOT RECOMMENDED**

Modifying `global_position` directly after `move_and_slide()` is **discouraged by Godot documentation** and can cause problems.

### Why Direct Position Modification Is Unsafe

**1. Collision Detection Desynchronization**

When you manually modify `global_position`, the CharacterBody2D's internal collision cache becomes stale. The next frame's collision checks may:
- Report false positives against surfaces already passed
- Fail to detect actual collisions
- Create "bouncing" or "jittering" artifacts

**2. Physics Engine Inconsistency**

The collision shape position and the visual position can become desynchronized:
- The collision system caches the previous frame's position for swept collision testing
- Manual position changes bypass this cache update
- This causes one-frame delays in collision response

**3. Moving Platform Velocity Loss**

If the character is on a moving platform, manually changing position can cause:
- Loss of platform velocity inheritance
- Incorrect next-frame collision detection with the platform

### Documented Approach

From official Godot 4.x documentation:

> "When moving a CharacterBody2D, you should not set its position property directly. Instead, you use the move_and_collide() or move_and_slide() methods."

**This guideline exists to maintain consistency between:**
- The body's position
- The collision shape's position
- The physics system's internal state

### Safe Alternative: Clamp the Velocity, Not the Position

Instead of clamping `global_position` after movement, clamp the `velocity` before calling `move_and_slide()`:

```gdscript
func _physics_process(delta: float) -> void:
    # Calculate desired movement
    velocity = calculate_movement_input()
    
    # Clamp velocity BEFORE move_and_slide()
    var max_speed = 300.0
    velocity = velocity.limit_length(max_speed)
    
    # Now move_and_slide() with constrained velocity
    move_and_slide()
```

---

## Position Clamping Best Practices

### Scenario: Keeping Player Within World Boundaries

**Problem:** A game world has defined boundaries (e.g., 0-1000 pixels on X axis), and the player should not leave these bounds.

**Best Practice: Use Collision Shapes as Boundaries**

The most robust solution is to place invisible collision shapes at world boundaries:

```gdscript
# In the level/world scene:
# Add StaticBody2D nodes with CollisionShape2D at boundaries
# Set them as walls or using layers/masks to prevent CharacterBody2D passage
```

**Advantages:**
- Maintains physics consistency
- Collision system automatically enforces boundaries
- No manual position manipulation needed
- Works with all collision types

### Alternative: Constrain Before Movement

If you cannot use collision shapes, clamp velocity vectors before movement:

```gdscript
const WORLD_MIN_X = 0.0
const WORLD_MAX_X = 1000.0
const WORLD_MIN_Y = 0.0
const WORLD_MAX_Y = 600.0

func _physics_process(delta: float) -> void:
    # Get input and calculate velocity
    var input_velocity = get_input_velocity()
    
    # Predict next position
    var next_position = global_position + input_velocity * delta
    
    # Check if predicted position would exceed bounds
    if next_position.x < WORLD_MIN_X or next_position.x > WORLD_MAX_X:
        input_velocity.x = 0  # Stop horizontal movement
    
    if next_position.y < WORLD_MIN_Y or next_position.y > WORLD_MAX_Y:
        input_velocity.y = 0  # Stop vertical movement
    
    velocity = input_velocity
    move_and_slide()
```

### Emergency Fix: Teleport Between Frames (Only When Necessary)

In rare cases where immediate position correction is essential (e.g., spawning, level transitions):

```gdscript
func respawn_player():
    # ONLY call this outside _physics_process
    # Typically in a signal handler or state change
    global_position = spawn_point
    velocity = Vector2.ZERO
    
    # Important: The next _physics_process() will have correct collision cache
    # because it's a fresh frame
```

### Clamping with Safe Margin Considerations

The `safe_margin` property (default 0.08 pixels) adds extra buffer for collision detection. When clamping positions:

```gdscript
const BOUNDARY_LEFT = 0.0
const BOUNDARY_RIGHT = 1000.0
const CHARACTER_RADIUS = 16.0

func constrain_position() -> void:
    # Account for character size when clamping to boundaries
    var min_x = BOUNDARY_LEFT + CHARACTER_RADIUS
    var max_x = BOUNDARY_RIGHT - CHARACTER_RADIUS
    
    global_position.x = clamp(global_position.x, min_x, max_x)
```

---

## Physics Frame Timing

### Fixed Physics Frame Rate

**Default Configuration:**

- Physics FPS: 60 per second (configurable in Project Settings)
- Physics frame duration: 1/60 â‰ˆ 0.01667 seconds
- Set via: Project Settings â†’ Physics â†’ Common â†’ Physics Fps

### _physics_process() vs _process()

**_physics_process(delta):**
- Called at fixed time intervals (60 times/second by default)
- `delta` parameter is constant (~0.01667)
- All CharacterBody2D movement should occur here
- Position updates are synchronized with physics calculations

**_process(delta):**
- Called every rendered frame (variable rate)
- `delta` varies based on frame rate
- Suitable for animations, UI, and non-physics logic
- NOT suitable for CharacterBody2D movement

### How Timing Affects Position Updates

**Frame Sequence Example (60 FPS physics):**

```
Frame 1 (t=0.0s):
  _physics_process(0.01667) called
  velocity = Vector2(300, 0)
  move_and_slide() called
  global_position updated: (100, 50) â†’ (105, 50)
  
Frame 2 (t=0.01667s):
  _physics_process(0.01667) called
  velocity = Vector2(300, 0)
  move_and_slide() called
  global_position updated: (105, 50) â†’ (110, 50)
  
Frame 3 (t=0.03334s):
  ... and so on
```

**Movement Distance Per Frame:**
- Distance = velocity Ã— delta
- At 300 pixels/second: 300 Ã— (1/60) = 5 pixels per frame

### Substepping and Multiple Physics Updates

If physics FPS exceeds render FPS (or frame rate drops below physics FPS):

**High Frame Rate (120 FPS render, 60 FPS physics):**
- Frames 1-2: One physics update per frame
- Position updates are interpolated for rendering

**Low Frame Rate (30 FPS render, 60 FPS physics):**
- Each rendered frame contains two physics updates
- Two `move_and_slide()` calls per rendered frame
- Character may skip visible frames but maintains velocity consistency

### Delta Time in move_and_slide()

`move_and_slide()` automatically applies the physics frame delta:

```gdscript
func _physics_process(delta: float) -> void:
    # delta is always the physics frame time (~0.01667 at 60 FPS)
    velocity.x = 300.0  # 300 pixels per second
    move_and_slide()
    
    # Internally, move_and_slide() calculates:
    # actual_movement = velocity * delta (approximately)
    # But may be adjusted for collisions
```

**Important:** Do NOT multiply velocity by delta before passing to `move_and_slide()`:

```gdscript
# WRONG - will result in ultra-fast movement
velocity = input_direction * speed * delta
move_and_slide()

# CORRECT - move_and_slide() handles delta internally
velocity = input_direction * speed
move_and_slide()
```

### Collision Detection Across Physics Frames

**Continuous Collision Detection (CCD):**

- `move_and_slide()` uses swept collision detection
- Movement path is traced from start to end position
- Prevents "tunneling" (passing through thin objects)
- Works per physics frame, so fast-moving objects need sufficient physics FPS

**Collision State Persistence:**

Collision flags (`is_on_floor()`, etc.) are updated each `move_and_slide()` call:

```gdscript
func _physics_process(delta: float) -> void:
    move_and_slide()
    
    if is_on_floor():  # Only true for 1 frame when landing
        jump_available = true
    
    # If you don't call move_and_slide() next frame:
    # is_on_floor() will return false next frame
```

---

## Caveats and Gotchas

### 1. Position Overshooting Boundaries

**Problem:** Character moves past intended boundary by small amount

**Cause:** Due to discrete time steps, exact boundary position may never be reached:

```gdscript
# Target position: 1000.0
# Frame N: position = 995.0, velocity = 300.0
# Frame N+1: position = 995 + (300 * 0.01667) = 1000.0 (OK)
# Frame N+2: position = 1000 + (300 * 0.01667) = 1005.0 (OVERSHOOT!)
```

**Solution: Stop Velocity at Boundary**

```gdscript
const BOUNDARY = 1000.0

func _physics_process(delta: float) -> void:
    # Predict next frame
    var next_x = global_position.x + velocity.x * delta
    
    if next_x > BOUNDARY and velocity.x > 0:
        velocity.x = 0  # Stop moving right
    
    move_and_slide()
```

### 2. Safe Margin Causing Unexpected Position Shifts

**Problem:** Character appears to "stick" to walls when near them

**Cause:** `safe_margin` pushes the body outward by 0.08 pixels for collision recovery

**Solution: Account for Safe Margin**

```gdscript
var safe_margin = get_safe_margin()  # Default: 0.08

# When checking distance to boundaries
var actual_distance = distance_to_boundary - safe_margin
```

### 3. Collision Cache Invalidation

**Problem:** After manually changing position, collisions behave erratically

**Cause:** Physics engine caches last frame's position for swept collision testing

**Solution:** Never manually modify `global_position` in `_physics_process()`

```gdscript
# WRONG in _physics_process:
move_and_slide()
global_position = global_position.clamp(...)  # Breaks collision cache

# RIGHT: Do position resets outside physics updates
func reset_position():
    global_position = spawn_point
    velocity = Vector2.ZERO
    # Call this from signal handler, not _physics_process
```

### 4. Velocity Not Modified by move_and_slide()

**Problem:** Velocity remains unchanged after collision

**Cause:** Godot 4 changed behavior from Godot 3

**In Godot 3:**
```gdscript
velocity = move_and_slide(velocity)  # Return value was modified velocity
```

**In Godot 4:**
```gdscript
move_and_slide()  # Void return; velocity property unchanged
var real_vel = get_real_velocity()  # Get actual applied velocity
```

### 5. Floor Detection Off-by-One Frames

**Problem:** `is_on_floor()` returns false for one frame after landing

**Cause:** Collision detection happens during `move_and_slide()`, but state update may lag

**Solution: Cache Floor State**

```gdscript
var was_on_floor = false

func _physics_process(delta: float) -> void:
    move_and_slide()
    
    # Current frame's floor state
    var is_floor_now = is_on_floor()
    
    # Detect landing (transition from not-on-floor to on-floor)
    if is_floor_now and not was_on_floor:
        on_landed()
    
    was_on_floor = is_floor_now
```

### 6. Diagonal Movement Speed Reduction Near Walls

**Problem:** Character slows down when moving diagonally toward a wall

**Cause:** Velocity is projected onto available sliding surfaces

**In top-down game moving diagonally toward wall:**
```
Intended velocity: (150, 150)  # Diagonal
Wall deflection: Only allow horizontal component
Applied velocity: (150, 0) or (0, 150)
Resulting speed: 150 instead of ~212
```

**Solution: Separate Axis Movement or Custom Sliding**

```gdscript
const SPEED = 300.0

func _physics_process(delta: float) -> void:
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Apply movement per axis separately
    velocity.x = input.x * SPEED
    velocity.y = input.y * SPEED
    
    move_and_slide()
```

### 7. Velocity Magnitude Changing on Slopes

**Problem:** Character moves faster downhill, slower uphill

**Cause:** Velocity is applied relative to slope surface in grounded mode

**Configuration to Disable:**

```gdscript
# In _ready() or scene properties:
floor_constant_speed = true  # Maintains speed regardless of slope
```

### 8. Platform Velocity Addition

**Problem:** Character inherits moving platform velocity unexpectedly

**Cause:** When touching a moving platform, its velocity is automatically added

**Control via:**

```gdscript
# Set how platform velocity is applied when leaving:
platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_ADD_VELOCITY  # Default
platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY  # Ignore downward
platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING  # Ignore completely
```

---

## Code Examples

### Example 1: Basic Movement with Boundary Clamping

```gdscript
extends CharacterBody2D

const SPEED = 300.0
const WORLD_BOUNDS = Rect2(Vector2(0, 0), Vector2(1000, 600))
const CHARACTER_RADIUS = 16.0

func _physics_process(delta: float) -> void:
    # Get input
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Set velocity (clamp speed before move_and_slide)
    velocity = input_direction * SPEED
    
    # Predict next position to avoid overshooting
    var next_position = global_position + velocity * delta
    
    # Clamp velocity based on predicted position
    if next_position.x - CHARACTER_RADIUS < WORLD_BOUNDS.position.x:
        velocity.x = max(velocity.x, 0)  # Can't move left
    if next_position.x + CHARACTER_RADIUS > WORLD_BOUNDS.end.x:
        velocity.x = min(velocity.x, 0)  # Can't move right
    
    if next_position.y - CHARACTER_RADIUS < WORLD_BOUNDS.position.y:
        velocity.y = max(velocity.y, 0)  # Can't move up
    if next_position.y + CHARACTER_RADIUS > WORLD_BOUNDS.end.y:
        velocity.y = min(velocity.y, 0)  # Can't move down
    
    # Apply movement
    move_and_slide()
```

### Example 2: Platformer with Clamped X-Axis

```gdscript
extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -400.0
const GRAVITY = 800.0
const LEVEL_WIDTH = 2000.0
const CHARACTER_WIDTH = 32.0

func _physics_process(delta: float) -> void:
    # Apply gravity
    velocity.y += GRAVITY * delta
    
    # Get horizontal input
    var horizontal_input = Input.get_axis("ui_left", "ui_right")
    
    # Predict horizontal movement
    var next_x = global_position.x + (horizontal_input * SPEED * delta)
    
    # Clamp horizontal velocity to level bounds
    var min_x = CHARACTER_WIDTH / 2.0
    var max_x = LEVEL_WIDTH - CHARACTER_WIDTH / 2.0
    
    if next_x < min_x and horizontal_input < 0:
        velocity.x = 0  # At left bound, can't move left
    elif next_x > max_x and horizontal_input > 0:
        velocity.x = 0  # At right bound, can't move right
    else:
        velocity.x = horizontal_input * SPEED  # Free to move
    
    # Handle jumping
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_FORCE
    
    # Apply movement
    move_and_slide()
```

### Example 3: Constrained Player with Collision Boundary

```gdscript
extends CharacterBody2D

const SPEED = 250.0
const ACCELERATION = 1200.0
const FRICTION = 800.0

@onready var collision_shape = $CollisionShape2D
@onready var play_area = $"../PlayArea"  # StaticBody2D with boundary collision

func _physics_process(delta: float) -> void:
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    if input_direction != Vector2.ZERO:
        # Accelerate in input direction
        velocity = velocity.move_toward(input_direction * SPEED, ACCELERATION * delta)
    else:
        # Apply friction
        velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    
    move_and_slide()
    
    # Note: Boundary enforcement is handled by invisible collision shapes
    # at play area edges (the play_area StaticBody2D)
```

### Example 4: Respawning (Safe Position Change)

```gdscript
extends CharacterBody2D

var spawn_point = Vector2(100, 100)

func _physics_process(delta: float) -> void:
    # Normal movement
    velocity = get_input_velocity()
    move_and_slide()
    
    # Check if should respawn (outside world, fell off, etc)
    if should_respawn():
        respawn()

func respawn() -> void:
    # SAFE: Call outside _physics_process context
    # This resets position between physics frames
    global_position = spawn_point
    velocity = Vector2.ZERO
    
    # Optional: Reset any other state
    is_alive = true

func should_respawn() -> bool:
    return global_position.y > 1000  # Fell off bottom
```

### Example 5: Monitoring Position After Movement

```gdscript
extends CharacterBody2D

var previous_position = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # Store position before movement
    previous_position = global_position
    
    # Set velocity and move
    velocity = get_movement_input() * 300.0
    move_and_slide()
    
    # Safely check actual movement
    var actual_displacement = global_position - previous_position
    var actual_speed = actual_displacement.length() / delta
    
    # Monitor for collision-induced slowdown
    if actual_speed < 250.0:
        print("Movement restricted, likely due to collision")
    
    # Use get_position_delta() for cleaner approach
    var motion_delta = get_position_delta()
    print("Motion this frame: ", motion_delta)
```

### Example 6: Velocity Limiting with Magnitude

```gdscript
extends CharacterBody2D

const MAX_SPEED = 350.0
const ACCELERATION = 1000.0

func _physics_process(delta: float) -> void:
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Calculate desired velocity
    var desired_velocity = input_direction * MAX_SPEED
    
    # Smoothly accelerate toward desired velocity
    velocity = velocity.move_toward(desired_velocity, ACCELERATION * delta)
    
    # Ensure velocity doesn't exceed maximum (safety check)
    velocity = velocity.limit_length(MAX_SPEED)
    
    move_and_slide()
```

### Example 7: Frame-Perfect Boundary Enforcement

```gdscript
extends CharacterBody2D

const SPEED = 300.0
const WORLD_LEFT = 10.0
const WORLD_RIGHT = 1990.0
const CHARACTER_HALF_WIDTH = 16.0

func _physics_process(delta: float) -> void:
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Calculate what velocity would move us this frame
    velocity.x = input_direction.x * SPEED
    velocity.y = input_direction.y * SPEED
    
    # Calculate the position we would reach
    var target_position = global_position + velocity * delta
    
    # Constrain target position
    target_position.x = clamp(
        target_position.x,
        WORLD_LEFT + CHARACTER_HALF_WIDTH,
        WORLD_RIGHT - CHARACTER_HALF_WIDTH
    )
    
    # Recalculate velocity to reach the constrained target
    velocity = (target_position - global_position) / delta
    
    move_and_slide()
```

---

## Quick Reference Table

| Aspect | Details |
|--------|---------|
| **Function** | `move_and_slide()` |
| **Return Value** | `bool` (true if collision occurred) |
| **Updates** | Modifies `global_position` directly |
| **Call Location** | `_physics_process()` only |
| **Default Physics Rate** | 60 FPS (adjustable) |
| **Safe Position Changes** | Before `_physics_process()` or after frame completes |
| **Velocity Application** | Automatic via physics frame delta |
| **Slope Behavior** | Default: speed changes on slopes; set `floor_constant_speed = true` to disable |
| **Default Safe Margin** | 0.08 pixels (for collision recovery) |
| **Max Slides** | 4 (default; increases with sharp corners) |
| **Safe Margin Use** | Pushes body away from colliders for reliable detection |
| **get_real_velocity()** | Returns actual velocity applied (affected by collisions) |
| **get_position_delta()** | Returns actual position change this frame |
| **Position Modification Risk** | HIGH - breaks collision cache |
| **Best Boundary Method** | Invisible collision shapes (StaticBody2D) |
| **Velocity Pre-Clamping** | SAFE - clamp before `move_and_slide()` |
| **Position Post-Clamping** | UNSAFE - avoid after `move_and_slide()` |

---

## Summary of Key Principles

1. **Never manually modify `global_position` in `_physics_process()`** - it breaks the collision detection cache

2. **Use `velocity` property to control movement** - set it before calling `move_and_slide()`

3. **Let `move_and_slide()` handle position updates** - it automatically applies physics frame delta and collision resolution

4. **For boundaries, use collision shapes when possible** - they provide robust, synchronized boundary enforcement

5. **For velocity clamping, check predicted position before movement** - adjust velocity to prevent overshooting

6. **Collision detection is frame-based** - exact boundary positions may not be reached due to discrete time steps

7. **Always use `_physics_process()` for CharacterBody2D movement** - not `_process()`

8. **Account for safe_margin in your calculations** - it adds 0.08 pixels of buffer for collision detection

9. **Use `get_real_velocity()` to monitor actual movement** - differs from intended `velocity` when colliding

10. **Safe position changes happen between frames** - use signal handlers or separate functions, not within `_physics_process()`
