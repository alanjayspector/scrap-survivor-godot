# Godot 4.x Project-Level Coordinate and World Size Settings

## Overview

Godot 4.x does **not impose hard project-level limits** on world coordinate space through standard project settings. Instead, coordinate space limitations arise from fundamental floating-point precision constraints and optional rendering/physics configurations. This document details all coordinate space considerations, project settings that affect world boundaries, and physics configurations.

---

## 1. Floating-Point Precision Limits (Core Constraints)

### Single-Precision Coordinates (Default)

By default, Godot 4.x uses **32-bit floating-point vectors** for coordinate storage (`Vector2` and `Vector3`), despite GDScript using 64-bit floats. This creates fundamental precision limitations:

**Usable Coordinate Range (Integer Representation):**
- Between **-16,777,216** and **16,777,216**
- Beyond this range, individual integer values cannot be reliably distinguished

**Practical Precision Ranges:**

| Coordinate Range | Single-Precision Step Size | Notes |
|---|---|---|
| [1; 2] | ~0.0000001 | Peak precision near origin |
| [8; 16] | ~0.000001 | Good precision |
| [256; 512] | ~0.00003 | Acceptable |
| [2048; 4096] | ~0.0002 | Still usable |
| [8192; 16384] | ~0.001 | Precision degrading |
| [32768; 65536] | ~0.0039 | Noticeable precision loss |
| > 262,144 | > ~0.0313 | Significant precision loss |

**Visual Effects of Lost Precision:**
- Objects "vibrate" or "shimmer" when far from origin
- Physics bodies may not collide properly
- Character movement becomes erratic (not walking straight)
- Rendering artifacts and model snapping

### Recommended Safe Ranges (Single-Precision)

- **Small-scale games:** < 1,024 units (excellent precision)
- **Medium-scale open worlds:** < 8,192 Ã— 8,192 meters (acceptable for first-person games)
- **Large worlds (split into levels):** Center each level portion around origin

**When NOT to use single-precision:**
- 3D space simulation games
- Planetary-scale games
- Games requiring very large coordinate values AND precise small-scale interactions
- Games exceeding ~262,144 units from origin

---

## 2. Double-Precision Coordinates (Large World Coordinates)

### Enabling Double-Precision

Large World Coordinates (also called **double-precision physics**) must be enabled at **compile time**, not through project settings. This provides exponentially greater precision.

**Compilation Requirement:**
```bash
scons precision=double
```

**Result:** All Vector types become 64-bit, dramatically increasing precision range.

**Double-Precision Range (Integer Representation):**
- Between **-9 quadrillion** and **9 quadrillion**
- Step sizes remain far smaller even at extreme distances

**Performance Trade-offs:**
- Increased memory usage (~10-15% overhead)
- Reduced performance, especially on 32-bit CPUs
- Not recommended for low-end mobile devices
- GDExtensions must be recompiled
- Multiplayer netcode requires matching precision on all clients

**Note:** Double-precision builds have `.double` suffix to distinguish them from standard binaries.

---

## 3. Rendering Limits Affecting Coordinate Space

### Viewport and Camera Far Plane

**Project Setting Path:** Not a project.godot settingâ€”configured per Camera3D node

**Camera3D Properties:**
- **Near:** Default `0.05` (minimum distance camera can see)
- **Far:** Default `4000.0` (maximum render distance)

**Limitations:**
- Camera far plane limited to **~699,050 meters** for XR rendering
- Beyond ~1,000,000m far plane in XR causes rendering failure
- Large far plane values (>10,000,000) cause z-buffer precision issues
- Very large coordinate values (>>1,000,000) visible artifacting occurs

**Recommendation:** Keep camera far plane as small as practically possible; use dynamic adjustment based on gameplay conditions.

### Viewport Size Limits

**Hard Limit:**
- Maximum texture/viewport dimensions: **16,384 Ã— 16,384 pixels** per dimension

**Practical Limits by Platform:**
- **Desktop/Laptop:** 8,192 Ã— 8,192 supported; older GPUs may not support this
- **Mobile:** 4,096 Ã— 4,096 typical maximum
- **Recommended minimum for compatibility:** 4,096 Ã— 4,096

These limits apply to:
- SubViewport custom sizes
- Texture dimensions
- Render-to-texture operations

---

## 4. Physics World Settings

### 3D Physics Configuration

**Project Settings Path:** `Project Settings > Physics > 3D`

#### Default Gravity

**Setting Name:** `physics/3d/default_gravity`
- **Default Value:** `9.8` (m/sÂ²)
- **Effect:** Applied uniformly to all RigidBody3D nodes unless overridden
- **No hard coordinate limits:** Can be any numeric value

**Code Access:**
```gdscript
# Get current gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Set at runtime (changes world space but not project.godot)
PhysicsServer3D.area_set_param(
    get_viewport().find_world_3d().space,
    PhysicsServer3D.AREA_PARAM_GRAVITY,
    new_gravity_value
)
```

#### Default Gravity Vector

**Setting Name:** `physics/3d/default_gravity_vector`
- **Default Value:** `Vector3(0, -1, 0)` (downward)
- **Effect:** Direction gravity pulls; unit vector (normalized)
- **No coordinate limits:** Directional only

**Code Access:**
```gdscript
# Set gravity direction at runtime
PhysicsServer3D.area_set_param(
    get_viewport().find_world_3d().space,
    PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
    Vector3(0, -1, 0)
)
```

### 2D Physics Configuration

**Project Settings Path:** `Project Settings > Physics > 2D`

#### Default Gravity (2D)

**Setting Name:** `physics/2d/default_gravity`
- **Default Value:** `980` (pixels/sÂ²)
- **Effect:** All RigidBody2D nodes fall with this acceleration
- **No coordinate limits:** Can be adjusted per game needs

#### Default Gravity Vector (2D)

**Setting Name:** `physics/2d/default_gravity_vector`
- **Default Value:** `Vector2(0, 1)` (downward in 2D screen space)
- **Effect:** Gravity direction in 2D world

### WorldBoundaryShape2D and WorldBoundaryShape3D

These are physics shapes, **not project settings**, but define collision boundaries:

**WorldBoundaryShape2D:**
- Infinite line collision shape (half-plane)
- Normal vector determines collision direction
- Used for endless floors or boundaries
- **No coordinate limits on shape position**

**WorldBoundaryShape3D:**
- Infinite plane collision shape
- Normal determines which side is solid
- With Jolt Physics: Has finite size adjustable via `world_margin` property

---

## 5. Display and Rendering Settings (Canvas/Window)

### Base Window/Canvas Size

**Project Settings Path:** `Project Settings > Display > Window`

**Setting Names:**
- `display/window/size/viewport_width` - Default: `1152`
- `display/window/size/viewport_height` - Default: `648`

**Effect:** Base render resolution; does NOT limit world coordinate space

### Stretch Mode and Canvas

**Project Settings Path:** `Project Settings > Display > Window > Stretch`

**Setting Names:**
- `display/window/stretch/mode` - Default: `"disabled"`
- `display/window/stretch/aspect` - Default: `"ignore"`

**Modes:**
- `disabled`: 1 unit = 1 pixel; no coordinate limits
- `canvas_items`: Renders at base size then scales; no coordinate limits
- `viewport`: Renders to viewport at base size; no coordinate limits

**Effect:** Only affects visual scaling, NOT coordinate space limits

### Maximum Texture Size (Implicit Limit)

**Project Settings Path:** No direct setting; hardware determined

**Practical Limits:**
- Desktop: 8,192 Ã— 8,192 pixels supported on most modern GPUs
- Mobile: 4,096 Ã— 4,096 typical
- Web/Browser: Varies widely

**Note:** This limits renderable texture dimensions, not coordinate values.

---

## 6. Origin Shifting Alternative

For games that cannot recompile with double-precision:

**Technique:** Keeping the player at `(0, 0, 0)` and moving all other objects around the player

**Advantages:**
- Works with single-precision floats
- Maintains precision near player
- No compilation needed

**Disadvantages:**
- Complex game logic required
- Problematic for multiplayer
- Manual implementation needed

---

## 7. Physics Engine Configuration (Jolt vs Default)

**Project Settings Path:** `Project Settings > Physics > 3D > Physics Engine`

**Options:**
- `DEFAULT` - Built-in Godot physics
- `JOLT` (Godot 4.3+) - Third-party Jolt Physics engine

**Note:** Neither provides coordinate space restrictions through settings; Jolt does provide different precision characteristics.

---

## 8. Useful Project.godot Reference

**Key Settings for Coordinate Space Management:**

```ini
# Rendering limits
rendering/textures/vram_compression/import_etc2_astc=true
rendering/textures/default_filters/use_nearest=false

# Physics defaults (3D)
physics/3d/default_gravity=9.8
physics/3d/default_gravity_vector=Vector3(0, -1, 0)

# Physics defaults (2D)
physics/2d/default_gravity=980
physics/2d/default_gravity_vector=Vector2(0, 1)

# Display settings
display/window/size/viewport_width=1152
display/window/size/viewport_height=648
display/window/stretch/mode="disabled"
display/window/stretch/aspect="ignore"

# No project settings for maximum world coordinates
# Limits are enforced by floating-point precision (32-bit by default)
```

---

## 9. Summary: Coordinate Space Constraints

| Limit Type | Default Value | How to Override |
|---|---|---|
| **Vector Precision** | 32-bit (single) | Recompile with `precision=double` |
| **Integer Coordinate Range** | Â±16,777,216 | None; inherent to 32-bit floats |
| **Recommended Safe Range** | 0 to Â±8,192 units | Use origin shifting beyond this |
| **Physics World Gravity** | 9.8 m/sÂ² (3D) / 980 px/sÂ² (2D) | `physics/3d/default_gravity` setting |
| **Camera Render Distance** | 4000.0 units far plane | Per-camera `Camera3D.far` property |
| **Viewport/Texture Size** | 16,384 Ã— 16,384 max | Hardware dependent; no project setting |
| **WorldBoundary Shapes** | Infinite (or finite with Jolt) | Per-shape configuration |

---

## 10. Best Practices

### For Small to Medium Games (< 8,192 Ã— 8,192 meters)
1. Keep single-precision (default)
2. Center levels around origin when possible
3. Use camera far plane wisely (test precision at distance)

### For Large Open-World Games
1. Use origin shifting technique (if no recompile capability)
2. Split world into level-loaded regions
3. Or: Recompile with `precision=double`

### For Space/Planetary Simulation
1. Recompile engine with `precision=double`
2. Recompile all GDExtensions with matching precision
3. Ensure all networking code handles double precision
4. Use optimized physics settings (lower tick rate if needed)

### For VR/XR Applications
1. Keep camera far plane < 700,000 meters
2. Test on target hardware for texture size support
3. Consider origin shifting for large worlds

---

## References

- Godot 4.x Large World Coordinates Documentation
- Godot 4.x ProjectSettings API Documentation
- Godot 4.x Camera3D Reference
- Godot 4.x Physics Settings Reference
- IEEE 754 Floating-Point Standards

---

**Document generated for Godot 4.x (all versions)**

*Note: This document focuses on project-level settings. Individual nodes may have additional constraints or configurations specific to their type.*
