# Godot 4.5.1 iOS: Temporary UI Feedback Patterns Without Node Cleanup

## Executive Summary

For iOS-safe temporary UI feedback in Godot 4.5.1, **reusing a single Label with Tween animations is the recommended pattern**. This avoids the performance penalties of instantiate/queue_free cycles and the high energy impact of creating/destroying Control nodes on iOS. Particles and shaders are supplementary approaches for specific visual effects, not primary solutions for text feedback.

---

## Problem Context: Why Node Cleanup is Problematic on iOS

### The iOS Control Node Performance Issue

iOS devices experience **significant CPU/GPU energy impact** when Control nodes are continuously created and destroyed. This is documented in Godot's issue tracking:

- Empty Control nodes (Panel, Label) consume "insane" GPU resources
- Energy profiling shows high baseline energy consumption the moment a GUI Control node exists
- The problem compounds with frequent instantiation/queue_free cycles, which are among the most taxing operations in Godot

### Why queue_free() is Costly

- `queue_free()` defers deletion to end-of-frame, holding nodes in memory temporarily
- Frequent calls create memory pressure and garbage collection pauses
- iOS's graphics pipeline is more susceptible to frame drops from these operations
- Creating new nodes via `instantiate()` triggers layout calculations and memory allocation

---

## Pattern 1: Reusable Single Label with Tween (Recommended)

### Concept

Maintain **one persistent Label node** in your scene. When feedback is needed, update its text, position, and animation, then reset it after completion.

### Implementation

```gdscript
# FeedbackLabel.gd
class_name FeedbackLabel extends Label

var current_tween: Tween

func _ready() -> void:
    # Ensure label is hidden by default
    modulate.a = 0.0
    custom_minimum_size = Vector2(100, 40)

func show_feedback(text: String, position: Vector2, duration: float = 2.0) -> void:
    # Reset previous animation if running
    if current_tween:
        current_tween.kill()
    
    # Update text and position
    self.text = text
    global_position = position
    
    # Create animation tween
    current_tween = create_tween()
    current_tween.set_parallel(true)
    
    # Fade in + move up
    current_tween.tween_property(self, "modulate:a", 1.0, 0.2)
    current_tween.tween_property(self, "position", position - Vector2(0, 30), 0.2)
    
    # Hold visible
    current_tween.tween_callback(func() -> void:
        current_tween = create_tween()
        current_tween.tween_interval(duration - 0.4)
    )
    
    # Fade out + move up
    current_tween = create_tween()
    current_tween.set_parallel(true)
    current_tween.tween_property(self, "modulate:a", 0.0, 0.2)
    current_tween.tween_property(self, "position", position - Vector2(0, 60), 0.2)
```

### Scene Structure

```
FeedbackContainer (Node)
â”œâ”€â”€ FeedbackLabel (Label)
â”‚   â”œâ”€â”€ font_size: 32
â”‚   â”œâ”€â”€ custom_colors/font_color: Color(1, 1, 1)
â”‚   â””â”€â”€ modulate.a: 0.0
```

### Usage in Game Code

```gdscript
func _on_level_up() -> void:
    var feedback = get_node("FeedbackContainer/FeedbackLabel")
    feedback.show_feedback("LEVEL UP!", player.global_position + Vector2(0, -50))

func _on_damage_taken(damage: int) -> void:
    var feedback = get_node("FeedbackContainer/FeedbackLabel")
    feedback.show_feedback("-%d" % damage, enemy.global_position)
```

### iOS Advantages

- **Single node in tree**: No add/remove cycles
- **Tween-based animation**: GPU-optimized, no script processing overhead
- **Modulate property**: Fast alpha blending, doesn't trigger layout recalculation
- **Predictable memory**: No garbage collection spikes
- **Energy efficient**: Constant energy footprint regardless of feedback frequency

### Limitations

- Only one feedback display at a time (queue multiple calls for sequential display)
- Text property changes are instant (no text animation character-by-character)
- Position offset must be calculated before calling

---

## Pattern 2: Pooled Label System (For Multiple Simultaneous Feedbacks)

### Concept

Pre-allocate a small pool of Label nodes (3-5) that are hidden by default. Reuse them in rotation, avoiding instantiation overhead.

### Implementation

```gdscript
# FeedbackPool.gd
class_name FeedbackPool extends Node

@export var pool_size: int = 5
@export var label_scene: PackedScene

var available_labels: Array[Label] = []
var in_use_labels: Array[Label] = []

func _ready() -> void:
    # Pre-instantiate labels
    for i in range(pool_size):
        var label = Label.new()
        label.modulate.a = 0.0
        label.custom_minimum_size = Vector2(100, 40)
        add_child(label)
        available_labels.append(label)

func request_feedback(text: String, position: Vector2, duration: float = 2.0) -> void:
    var label: Label
    
    if available_labels.size() > 0:
        label = available_labels.pop_front()
    else:
        # All labels in use; reuse oldest
        label = in_use_labels.pop_front()
        if label and label.get_meta_list().has("current_tween"):
            (label.get_meta("current_tween") as Tween).kill()
    
    in_use_labels.append(label)
    animate_label(label, text, position, duration)

func animate_label(label: Label, text: String, position: Vector2, duration: float) -> void:
    label.text = text
    label.global_position = position
    
    var tween = create_tween()
    label.set_meta("current_tween", tween)
    
    # Fade in + move
    tween.set_parallel(true)
    tween.tween_property(label, "modulate:a", 1.0, 0.2)
    tween.tween_property(label, "position", position - Vector2(0, 30), 0.2)
    
    # Hold
    tween.tween_interval(duration - 0.4)
    
    # Fade out + move
    tween.set_parallel(true)
    tween.tween_property(label, "modulate:a", 0.0, 0.2)
    tween.tween_property(label, "position", position - Vector2(0, 60), 0.2)
    
    # Return to pool
    await tween.finished
    available_labels.append(label)
    in_use_labels.erase(label)
```

### Scene Setup

```
FeedbackPool (Node - script: FeedbackPool.gd)
â”œâ”€â”€ [Label nodes created dynamically]
```

### iOS Advantages Over Single Label

- Supports simultaneous feedback displays
- No re-parenting or node state resets
- Memory allocation happens once at startup
- No frame-to-frame instantiation

### When to Use

- Multiple UI notifications needed simultaneously
- Combat numbers floating from multiple enemies
- Achievement/milestone popups stacking

---

## Pattern 3: Particle Effects for Visual Feedback

### Concept

Use `GPUParticles2D` for non-text visual feedback (stars, sparkles, explosions) instead of labels.

### Implementation

```gdscript
# ParticleEffectManager.gd
func show_level_up_particles(position: Vector2) -> void:
    var particles = GPUParticles2D.new()
    particles.global_position = position
    
    # Configure particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_CIRCLE
    material.emission_sphere_radius = 10.0
    material.initial_velocity_min = 50.0
    material.initial_velocity_max = 150.0
    material.gravity = Vector3(0, -100, 0)
    material.scale_min = 0.5
    material.scale_max = 1.5
    
    # Load or create texture
    var texture = preload("res://assets/particle_star.png")
    
    particles.process_material = material
    particles.texture = texture
    particles.amount = 20
    particles.lifetime = 1.5
    particles.emitting = true
    
    add_child(particles)
    
    # Cleanup after particles finish
    await get_tree().create_timer(2.0).timeout
    particles.queue_free()
```

### iOS Considerations

- **GPU-accelerated**: Particle simulation offloaded to GPU
- **Single texture**: Minimize memory allocation
- **Limited lifetime**: Automatic cleanup (but use timer-based rather than node removal for consistency)
- **Better than multiple labels**: For non-text effects, particles are more efficient

### Limitations

- Cannot display text/numbers
- Requires texture asset
- Less precise positioning than labels

---

## Pattern 4: Shader-Based UI Fade (Advanced)

### Concept

Use a custom shader on a CanvasLayer to create fade/dissolve effects without per-node management.

### Shader Code

```glsl
shader_type canvas_item;
render_mode blend_mix;

uniform float fade_progress: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D noise_texture;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;
    float dissolve = mix(0.0, 1.0, fade_progress);
    
    // Dissolve edge
    float edge = step(dissolve, noise + 0.1);
    
    COLOR = base_color;
    COLOR.a *= edge;
}
```

### GDScript Integration

```gdscript
# ShaderFeedback.gd
func show_shader_feedback(text: String) -> void:
    var feedback_rect = ColorRect.new()
    var shader_material = ShaderMaterial.new()
    shader_material.shader = preload("res://shaders/ui_fade.gdshader")
    
    feedback_rect.material = shader_material
    add_child(feedback_rect)
    
    # Animate shader parameter
    var tween = create_tween()
    tween.tween_property(shader_material, "shader_parameter/fade_progress", 0.0, 0.5)
    tween.tween_interval(1.0)
    tween.tween_property(shader_material, "shader_parameter/fade_progress", 1.0, 0.5)
    
    await tween.finished
    feedback_rect.queue_free()
```

### iOS Considerations

- **Shader compilation overhead**: Only use for complex effects
- **For simple fades**: Use modulate alpha instead (cheaper)
- **Noise texture**: Minimal VRAM impact but adds complexity

### When to Use

- Unique visual effects (dissolve transitions, complex blends)
- Brand-specific UI style requiring custom rendering
- Multiple overlapping effects that need blending

---

## Comparative Performance Analysis

| Approach | Memory | CPU | GPU | Energy Impact | iOS Safe | Notes |
|----------|--------|-----|-----|----------------|----------|-------|
| Reusable Label + Tween | Very Low | Very Low | Low | Minimal | âœ… Best | Single display, simple animations |
| Pooled Labels | Low | Low | Low | Low | âœ… Excellent | Multiple simultaneous displays |
| Particle System | Low | Very Low | Medium | Low | âœ… Good | Visual effects, not text |
| Shader-Based | Medium | Medium | High | Medium | âš ï¸ Conditional | Complex effects only |
| Instantiate/queue_free | High | High | High | **High** | âŒ Avoid | Frequent GC, node tree churn |

---

## Best Practices for iOS Implementation

### 1. Avoid Control Node Churn

```gdscript
# âŒ BAD: Creates/destroys Label every time
func bad_feedback() -> void:
    var label = Label.new()
    label.text = "LEVEL UP!"
    add_child(label)
    await get_tree().create_timer(2.0).timeout
    label.queue_free()

# âœ… GOOD: Reuse existing Label
func good_feedback() -> void:
    $FeedbackLabel.show_feedback("LEVEL UP!", player.position)
```

### 2. Use Modulate Alpha for Fading

```gdscript
# âœ… PREFERRED: Modulate alpha (GPU-accelerated blending)
tween.tween_property(label, "modulate:a", 0.0, 0.5)

# âš ï¸ AVOID: Animating font size (triggers re-layout)
tween.tween_property(label, "add_theme_font_size_override", 48, 0.5)
```

### 3. Scale Instead of Font Size

```gdscript
# âœ… GOOD: Scale property (GPU transform)
tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.3)

# âŒ BAD: Font size override (re-render, battery drain)
label.add_theme_font_size_override("font_sizes/font_size", 48)
```

### 4. Parallel Tweens for Combined Animations

```gdscript
# âœ… CORRECT: Animations run together
var tween = create_tween()
tween.set_parallel(true)
tween.tween_property(label, "modulate:a", 1.0, 0.2)
tween.tween_property(label, "position", target_pos, 0.2)

# âŒ INEFFICIENT: Animations sequential, longer total time
var tween = create_tween()
tween.tween_property(label, "modulate:a", 1.0, 0.2)
tween.tween_property(label, "position", target_pos, 0.2)
```

### 5. Disable Processing for Unused Nodes

```gdscript
# For pooled systems, ensure hidden nodes don't process
func return_to_pool(label: Label) -> void:
    label.set_process(false)
    label.set_physics_process(false)
    available_labels.append(label)
```

### 6. Avoid CanvasLayer for Simple UI

```gdscript
# âŒ UNNECESSARY: CanvasLayer overhead for basic feedback
$CanvasLayer/FeedbackLabel.show_feedback(...)

# âœ… BETTER: Direct child or Control container
$FeedbackContainer/FeedbackLabel.show_feedback(...)
```

---

## Recommended Architecture for Mobile Games

### Complete Example: Multi-Scenario Feedback System

```gdscript
# UIFeedbackManager.gd
class_name UIFeedbackManager extends Node

@onready var damage_label: Label = $DamageLabel
@onready var healing_label: Label = $HealingLabel
@onready var combo_label: Label = $ComboLabel

func _ready() -> void:
    damage_label.modulate.a = 0.0
    healing_label.modulate.a = 0.0
    combo_label.modulate.a = 0.0

func show_damage(amount: int, position: Vector2) -> void:
    _animate_label(damage_label, "-%d" % amount, position, 1.5, Color.RED)

func show_healing(amount: int, position: Vector2) -> void:
    _animate_label(healing_label, "+%d" % amount, position, 1.5, Color.GREEN)

func show_combo(combo_count: int, position: Vector2) -> void:
    _animate_label(combo_label, "x%d" % combo_count, position, 2.0, Color.YELLOW)

func _animate_label(
    label: Label,
    text: String,
    position: Vector2,
    duration: float,
    color: Color
) -> void:
    label.text = text
    label.global_position = position
    label.modulate.a = 1.0
    label.add_theme_color_override("font_color", color)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "modulate:a", 0.0, duration)
    tween.tween_property(
        label,
        "position",
        position - Vector2(0, 80),
        duration
    )
```

### Scene Layout

```
UIFeedbackManager (Node - script: UIFeedbackManager.gd)
â”œâ”€â”€ DamageLabel (Label)
â”‚   â”œâ”€â”€ theme_overrides/font_sizes/font_size: 28
â”œâ”€â”€ HealingLabel (Label)
â”‚   â”œâ”€â”€ theme_overrides/font_sizes/font_size: 28
â””â”€â”€ ComboLabel (Label)
    â”œâ”€â”€ theme_overrides/font_sizes/font_size: 32
```

### Usage

```gdscript
# In Player.gd or GameManager.gd
func take_damage(amount: int) -> void:
    health -= amount
    UIFeedbackManager.show_damage(amount, global_position)

func heal(amount: int) -> void:
    health += amount
    UIFeedbackManager.show_healing(amount, global_position)
```

---

## Decision Tree: Which Pattern to Use?

```
Need temporary UI feedback?
â”‚
â”œâ”€ Single feedback at a time?
â”‚  â””â”€ YES â†’ Pattern 1: Reusable Label (RECOMMENDED)
â”‚
â”œâ”€ Multiple simultaneous feedbacks?
â”‚  â”œâ”€ < 5 items on screen
â”‚  â”‚  â””â”€ Pattern 2: Pooled Labels
â”‚  â””â”€ Many particles/effects
â”‚     â””â”€ Pattern 3: GPU Particles
â”‚
â”œâ”€ Complex visual effect (not text)?
â”‚  â”œâ”€ Dissolve/fade transitions
â”‚  â”‚  â””â”€ Pattern 4: Shader
â”‚  â””â”€ Sparkles/explosions/particles
â”‚     â””â”€ Pattern 3: GPU Particles
â”‚
â””â”€ Maximum iOS optimization needed?
   â””â”€ Use Pattern 1 or 2 exclusively
```

---

## Testing on iOS Device

### Performance Profiling

1. **Xcode Energy Impact**: Profile app during intense feedback cycles
2. **Frame Rate Monitor**: Use Godot's built-in FPS counter (`OS.get_static_memory_usage()`)
3. **Thermal Throttling**: Test on older devices (iPhone 11 or earlier)

### Validation Checklist

- [ ] No frame drops during peak feedback (20+ simultaneous effects)
- [ ] Thermal state remains "Normal" after 5 min of continuous effects
- [ ] Memory usage stable (no GC spikes)
- [ ] Battery drain comparable to UI-less build

---

## Troubleshooting

### Issue: Label Text Appears Blurry or Pixelated

**Solution**: Ensure custom font size is set via theme override, not scaled transform:
```gdscript
label.add_theme_font_size_override("font_sizes/font_size", 32)
```

### Issue: Animation Stuttering on Older iOS Devices

**Solution**: Reduce animation complexity; use shorter durations (< 1 second):
```gdscript
tween.tween_property(label, "modulate:a", 0.0, 0.3)  # Shorter is smoother
```

### Issue: Multiple Feedback Calls Overlap/Queue

**Solution**: Implement feedback queue or use pooled system (Pattern 2):
```gdscript
# Add to queue if previous animation still running
if current_tween and current_tween.is_running():
    feedback_queue.append({"text": text, "pos": pos})
else:
    show_feedback(text, pos)
```

### Issue: High Energy Impact Despite Using Reusable Labels

**Solution**: Verify label is truly hidden when not in use:
```gdscript
# Ensure modulate.a reaches 0.0, not just near-zero
if label.modulate.a < 0.01:
    label.modulate.a = 0.0
```

---

## Summary

**The iOS-safe pattern for temporary UI feedback is: Reuse a single (or pooled) Label node with Tween-based animations, using modulate.a for alpha and scale for size. Avoid instantiation/queue_free cycles, font size animations, and unnecessary CanvasLayers. For multiple simultaneous effects, implement object pooling. For purely visual effects, use GPU particles. Reserve shaders for complex effects only.**

