# Godot 4.x Rect2 Class - Comprehensive Documentation for Boundary Clamping

## Table of Contents
1. [Rect2 Overview](#rect2-overview)
2. [Rect2.position and Rect2.size Relationship](#rect2position-and-rect2size-relationship)
3. [Boundary Clamping Examples](#boundary-clamping-examples)
4. [Common Mistakes](#common-mistakes)
5. [Godot 3.x to 4.x Changes](#godot-3x-to-4x-changes)
6. [Known Issues in Godot 4.5.1](#known-issues-in-godot-451)
7. [Best Practices](#best-practices)

---

## Rect2 Overview

**Rect2** is a built-in type representing a 2D axis-aligned bounding box using floating-point coordinates. It is defined by two Vector2 properties:
- `position`: The origin point (typically the top-left corner)
- `size`: The width and height from position

### Key Properties

- **position**: `Vector2(0, 0)` - The origin point, typically the top-left corner
- **size**: `Vector2(0, 0)` - The rectangle's width and height from position
- **end**: `Vector2(0, 0)` - The ending point (calculated as `position + size`)

### Important Notes

- Godot assumes `position` is the top-left corner and `end` is the bottom-right corner
- Negative size values are NOT supported and will cause issues with most Rect2 methods
- Use `abs()` method to fix rectangles with negative sizes
- In boolean context, Rect2 evaluates to `false` only if both position and size are `Vector2.ZERO`

---

## Rect2.position and Rect2.size Relationship

### How They Work Together

```gdscript
# Basic construction
var rect = Rect2(Vector2(100, 50), Vector2(200, 150))
# position = (100, 50)
# size = (200, 150)
# end = position + size = (300, 200)

# Alternative construction with components
var rect2 = Rect2(100, 50, 200, 150)  # x, y, width, height
```

### The `end` Property

The `end` property is automatically calculated and represents the bottom-right corner:

```gdscript
var rect = Rect2(10, 10, 100, 100)
print(rect.position)  # Output: (10, 10)
print(rect.size)      # Output: (100, 100)
print(rect.end)       # Output: (110, 110)

# Setting end modifies size
rect.end = Vector2(150, 150)
print(rect.size)      # Output: (140, 140)
```

### Area Calculation

```gdscript
var rect = Rect2(0, 0, 100, 50)
var area = rect.get_area()  # Returns 5000.0 (100 * 50)

# Alternative property
print(rect.area)  # Same as get_area()
```

---

## Boundary Clamping Examples

### Example 1: Basic Player Boundary Clamping

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
var screen_size: Vector2

func _ready() -> void:
    screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
    # Get input direction
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Update velocity
    velocity = direction * speed
    
    # Move the character
    move_and_slide()
    
    # Clamp position to screen boundaries
    # Method 1: Using Vector2.clamp() with Rect2.end
    position = position.clamp(Vector2.ZERO, screen_size)
```

### Example 2: Clamping with Sprite Offset

```gdscript
extends Sprite2D

@export var speed: float = 300.0
var screen_size: Vector2
var sprite_half_size: Vector2

func _ready() -> void:
    screen_size = get_viewport_rect().size
    # Calculate half the sprite size for proper boundary detection
    sprite_half_size = texture.get_size() / 2 * scale

func _process(delta: float) -> void:
    var velocity = Vector2.ZERO
    
    if Input.is_action_pressed("ui_right"):
        velocity.x += speed
    if Input.is_action_pressed("ui_left"):
        velocity.x -= speed
    if Input.is_action_pressed("ui_down"):
        velocity.y += speed
    if Input.is_action_pressed("ui_up"):
        velocity.y -= speed
    
    position += velocity * delta
    
    # Clamp considering sprite size
    position.x = clamp(position.x, sprite_half_size.x, screen_size.x - sprite_half_size.x)
    position.y = clamp(position.y, sprite_half_size.y, screen_size.y - sprite_half_size.y)
```

### Example 3: Using Rect2 for World Boundaries

```gdscript
extends CharacterBody2D

@export var speed: float = 250.0
var world_boundary: Rect2

func _ready() -> void:
    # Define a custom world boundary (not just viewport)
    world_boundary = Rect2(0, 0, 2000, 1500)

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    
    move_and_slide()
    
    # Clamp to world boundaries using Rect2
    global_position = global_position.clamp(
        world_boundary.position, 
        world_boundary.end
    )
```

### Example 4: Camera Boundary Clamping with TileMap

```gdscript
extends Camera2D

@onready var tilemap: TileMap = $"../TileMap"

func _ready() -> void:
    set_camera_limits()

func set_camera_limits() -> void:
    if tilemap == null:
        return
    
    # Get the used rectangle of the tilemap
    var map_rect: Rect2i = tilemap.get_used_rect()
    var tile_size: Vector2i = tilemap.tile_set.tile_size
    
    # Calculate world boundaries
    var world_bounds = Rect2(
        map_rect.position * tile_size,
        map_rect.size * tile_size
    )
    
    # Set camera limits
    limit_left = int(world_bounds.position.x)
    limit_top = int(world_bounds.position.y)
    limit_right = int(world_bounds.end.x)
    limit_bottom = int(world_bounds.end.y)
```

### Example 5: Advanced Boundary Clamping with has_point()

```gdscript
extends Area2D

var movement_area: Rect2

func _ready() -> void:
    movement_area = Rect2(100, 100, 400, 300)

func _process(delta: float) -> void:
    var target_pos = get_global_mouse_position()
    
    # Check if target is within boundaries
    if movement_area.has_point(target_pos):
        global_position = target_pos
    else:
        # Clamp to boundary
        global_position = target_pos.clamp(
            movement_area.position,
            movement_area.end
        )
```

### Example 6: Creating Dynamic Boundaries

```gdscript
extends Node2D

func create_room_boundary(room_position: Vector2, room_size: Vector2) -> Rect2:
    var boundary = Rect2(room_position, room_size)
    
    # Grow the boundary outward by 50 pixels
    boundary = boundary.grow(50)
    
    return boundary

func clamp_object_to_room(object_pos: Vector2, room_rect: Rect2) -> Vector2:
    # Clamp object position to room boundaries
    return object_pos.clamp(room_rect.position, room_rect.end)
```

---

## Common Mistakes

### Mistake 1: Using Negative Size Values

**Problem:**
```gdscript
# Creating a Rect2 with negative size
var rect = Rect2(100, 100, -50, -50)  # WRONG!

# Methods like has_point() won't work correctly
if rect.has_point(Vector2(75, 75)):
    print("This won't print even though it should!")
```

**Solution:**
```gdscript
# Always use abs() to normalize negative sizes
var rect = Rect2(100, 100, -50, -50).abs()
# Now rect.position = (50, 50) and rect.size = (50, 50)

# Or construct properly from the start
var proper_rect = Rect2(50, 50, 50, 50)
```

### Mistake 2: Confusing Rect2.end with screen_size

**Problem:**
```gdscript
# This will cause an error
var screen_size = get_viewport_rect()  # Returns Rect2, not Vector2
position = position.clamp(Vector2.ZERO, screen_size)  # Type mismatch!
```

**Solution:**
```gdscript
# Correct: Use .size or .end property
var screen_rect = get_viewport_rect()
position = position.clamp(Vector2.ZERO, screen_rect.size)
# OR
position = position.clamp(screen_rect.position, screen_rect.end)
```

### Mistake 3: Not Accounting for Sprite/Node Size

**Problem:**
```gdscript
# Player sprite goes half off-screen
func _process(delta):
    position = position.clamp(Vector2.ZERO, screen_size)
    # Sprite center can be at screen edge, so half sprite is outside!
```

**Solution:**
```gdscript
# Account for sprite dimensions
var sprite_texture_size = $Sprite2D.texture.get_size()
var half_size = sprite_texture_size / 2.0

position.x = clamp(position.x, half_size.x, screen_size.x - half_size.x)
position.y = clamp(position.y, half_size.y, screen_size.y - half_size.y)
```

### Mistake 4: Misunderstanding has_area() Method

**Problem:**
```gdscript
var rect = Rect2(10, 10, -20, -20)
if rect.has_area():
    print("Has area")  # Won't print!
# Note: has_area() was has_no_area() in Godot 3.x (inverted logic)
```

**Solution:**
```gdscript
# For negative sizes, use abs() first
var rect = Rect2(10, 10, -20, -20).abs()
if rect.has_area():
    print("Now it has area")  # Will print

# Or check for zero size
if rect.size.x > 0 and rect.size.y > 0:
    print("Explicit area check")
```

### Mistake 5: Using has_point() on Right/Bottom Edges

**Problem:**
```gdscript
var rect = Rect2(0, 0, 100, 100)
# Right and bottom edges are EXCLUSIVE
print(rect.has_point(Vector2(100, 50)))   # false
print(rect.has_point(Vector2(50, 100)))   # false
print(rect.has_point(Vector2(100, 100)))  # false
```

**Solution:**
```gdscript
# If you need inclusive boundaries, check manually
func point_in_rect_inclusive(point: Vector2, rect: Rect2) -> bool:
    return (point.x >= rect.position.x and point.x <= rect.end.x and
            point.y >= rect.position.y and point.y <= rect.end.y)
```

### Mistake 6: Clamping in _process() Instead of _physics_process()

**Problem:**
```gdscript
# Inconsistent physics behavior
func _process(delta):
    move_and_slide()
    position = position.clamp(...)  # Can cause physics glitches
```

**Solution:**
```gdscript
# Use _physics_process for movement and clamping
func _physics_process(delta):
    move_and_slide()
    position = position.clamp(bounds_min, bounds_max)
```

---

## Godot 3.x to 4.x Changes

### Method Changes

| Godot 3.x | Godot 4.x | Notes |
|-----------|-----------|-------|
| `has_no_area()` | `has_area()` | **Logic inverted!** Returns true if area > 0 |
| Image.`get_rect()` | Image.`get_region()` | Method renamed |

### Property Changes

**No direct Rect2 property changes**, but related changes:

- **RectangleShape2D.extents** â†’ **RectangleShape2D.size** (value is now full size, not half-extents)
- **Camera2D.zoom** behavior inverted (higher = more zoomed in)

### Coordinate System Changes

**Important:** The coordinate system itself (Y-down) **has not changed** between Godot 3.x and 4.x for 2D. 

However, there are important changes in related areas:

1. **Camera2D.zoom property inverted:**
   ```gdscript
   # Godot 3.x
   camera.zoom = Vector2(0.5, 0.5)  # Zoomed out
   
   # Godot 4.x
   camera.zoom = Vector2(2.0, 2.0)  # Zoomed out (inverted!)
   ```

2. **TileMap and GridMap coordinate methods renamed:**
   ```gdscript
   # Godot 3.x
   var world_pos = tilemap.map_to_world(cell_pos)
   var cell_pos = tilemap.world_to_map(world_pos)
   
   # Godot 4.x
   var world_pos = tilemap.map_to_local(cell_pos)
   var cell_pos = tilemap.local_to_map(world_pos)
   ```

3. **Rect2 structure unchanged:**
   - position, size, and end properties work identically
   - Construction methods remain the same
   - All clamping logic is compatible

### Migration Checklist for Rect2

- [x] Rename `has_no_area()` â†’ `has_area()` and invert logic
- [x] Update Image.`get_rect()` â†’ Image.`get_region()`
- [x] Check RectangleShape2D usage (extents â†’ size, halve values)
- [x] Review Camera2D zoom values if using Rect2 for camera bounds
- [x] Update TileMap boundary calculations (map_to_world â†’ map_to_local)

---

## Known Issues in Godot 4.5.1

### General Rect2 Issues

As of Godot 4.5.1 (released October 14, 2025), there are **no specific critical bugs** reported for the Rect2 class itself. However, be aware of:

1. **Negative Size Handling:**
   - Rect2 with negative size values continues to be unsupported
   - Use `.abs()` method as documented
   - No plans to change this behavior

2. **Floating-Point Precision:**
   - When using `is_equal_approx()` or `==` for Rect2 comparison
   - Recommend using `is_equal_approx()` for reliability
   ```gdscript
   # Less reliable
   if rect1 == rect2:
       pass
   
   # More reliable
   if rect1.is_equal_approx(rect2):
       pass
   ```

3. **Scene Tree Modifications:**
   - Modifying Rect2 properties of nodes during physics callbacks can cause issues
   - Use `call_deferred()` when necessary
   ```gdscript
   # In physics callback
   call_deferred("update_boundary", new_rect)
   ```

### Related Issues to Watch

1. **Control.get_rect() Behavior:**
   - Control nodes return rects in local coordinates
   - Use `get_global_rect()` for global space
   ```gdscript
   # Local space (relative to parent)
   var local_rect = control.get_rect()
   
   # Global space (scene coordinates)
   var global_rect = control.get_global_rect()
   ```

2. **Camera2D Limit Precision:**
   - Camera limits use integer values
   - Rect2 uses floats, conversion may cause precision loss
   ```gdscript
   limit_left = int(boundary_rect.position.x)
   limit_right = int(boundary_rect.end.x)
   ```

### Performance Considerations

- Rect2 operations are highly optimized
- Creating Rect2 instances each frame is acceptable
- `has_point()` and `intersects()` are very fast
- `grow()` and similar methods create new Rect2 (not in-place)

---

## Best Practices

### 1. Always Validate Rect2 Size

```gdscript
func create_boundary(pos: Vector2, size: Vector2) -> Rect2:
    # Ensure size is positive
    var safe_size = Vector2(abs(size.x), abs(size.y))
    return Rect2(pos, safe_size)
```

### 2. Use Rect2 Constants When Appropriate

```gdscript
# For viewport boundaries
func get_viewport_boundary() -> Rect2:
    return get_viewport_rect()  # Already a Rect2

# For custom boundaries
const LEVEL_BOUNDS = Rect2(0, 0, 1920, 1080)
```

### 3. Prefer Vector2.clamp() for Position Clamping

```gdscript
# Modern approach (Godot 4.x)
position = position.clamp(boundary.position, boundary.end)

# Equivalent but more verbose
position.x = clamp(position.x, boundary.position.x, boundary.end.x)
position.y = clamp(position.y, boundary.position.y, boundary.end.y)
```

### 4. Cache Boundary Calculations

```gdscript
# Good: Calculate once
var screen_boundary: Rect2
func _ready():
    screen_boundary = get_viewport_rect()

func _process(delta):
    position = position.clamp(screen_boundary.position, screen_boundary.end)

# Bad: Calculate every frame
func _process(delta):
    var boundary = get_viewport_rect()  # Wasteful!
    position = position.clamp(boundary.position, boundary.end)
```

### 5. Document Coordinate Spaces

```gdscript
# Clear documentation prevents confusion
## Clamps the node to world boundaries (global coordinates)
## @param world_rect: The world boundary in global space
func clamp_to_world(world_rect: Rect2) -> void:
    global_position = global_position.clamp(
        world_rect.position,
        world_rect.end
    )
```

### 6. Use Type Hints

```gdscript
# Type safety prevents runtime errors
func set_boundary(boundary: Rect2) -> void:
    current_boundary = boundary

# Instead of
func set_boundary(boundary):  # Could be anything!
    current_boundary = boundary
```

### 7. Handle Edge Cases

```gdscript
func safe_clamp(pos: Vector2, boundary: Rect2) -> Vector2:
    # Check if boundary is valid
    if not boundary.has_area():
        push_warning("Boundary has no area, returning original position")
        return pos
    
    return pos.clamp(boundary.position, boundary.end)
```

### 8. Visualize Boundaries in Debug

```gdscript
func _draw() -> void:
    if OS.is_debug_build():
        # Draw boundary rectangle for debugging
        draw_rect(world_boundary, Color.RED, false, 2.0)
```

---

## Summary

Rect2 in Godot 4.x is a powerful and efficient class for boundary management. Key takeaways:

- **position** and **size** define the rectangle, **end** is calculated
- Always ensure size values are positive (use `.abs()` if needed)
- Use `Vector2.clamp()` with `Rect2.position` and `Rect2.end` for efficient clamping
- Be aware of edge exclusivity in `has_point()`
- The main change from Godot 3.x is `has_no_area()` â†’ `has_area()` (inverted logic)
- No critical Rect2 bugs in Godot 4.5.1

**For AI ingestion:** This document provides complete coverage of Rect2 usage patterns, common pitfalls, migration guidance, and practical code examples for boundary clamping in Godot 4.x.
