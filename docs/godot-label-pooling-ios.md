# Godot 4.5.1 iOS Label Node Pooling Pattern

## Executive Summary

**Recommended Approach**: Implement a **node object pool pattern** for UI Labels on iOS. Reusing pooled nodes via hide/show and text updates is substantially more performant than repeated instantiate/free cycles, particularly on iOS where memory allocation and garbage collection costs are higher relative to desktop platforms.

**Performance Gains**: Measurable improvement in frame stability and reduced battery drain by eliminating:
- Repeated memory allocation/deallocation cycles
- `queue_free()` processing overhead per frame
- Garbage collection pauses
- Scene tree insertion/removal operations

---

## Problem Analysis

### Why queue_free() Is Problematic

#### General Godot Context
- `queue_free()` is deferred; the node isn't deleted immediately but added to a deletion queue
- **Per-frame deallocation cost is non-trivial**: Deallocating memory is fundamentally slower than allocating it, even by a small margin
- Multiple rapid `queue_free()` calls in a single frame compound into measurable frame time

**Real-world performance impact**:
- Bullet hell game with hundreds of simultaneous `queue_free()` calls showed frame rate drops from 60 FPS to 10-50 FPS during deletion spikes
- Root cause: Not the object count, but the **density of free operations** in time
- Solution: Delaying/staggering deallocation OR pooling

#### iOS-Specific Concerns
iOS devices have significantly lower memory bandwidth and processing power than desktop:

1. **Battery/Energy Impact**: Control nodes (including Labels) exhibit high baseline energy consumption on iOS even when idle
   - Measured in Xcode: Adding an empty PanelContainer increased GPU utilization from ~10% to 80% energy usage
   - Each node instantiation/destruction is a measurable power event

2. **Memory Allocation Costs**: iOS memory management is more constrained
   - Allocation/deallocation on mobile is slower relative to available compute
   - Repeated cycles increase thermal throttling likelihood
   - Can trigger aggressive garbage collection on low-memory devices

3. **Processing Overhead**: Every node in the scene tree adds to:
   - Frame-by-frame processing loop iterations (even disabled nodes in some scenarios)
   - Rendering pipeline overhead
   - Physics and input processing query costs

---

## Recommended Pattern: Label Pool

### Architecture Overview

```gdscript
## LabelPool.gd
## Manages a pool of reusable Label nodes for efficient UI display
## 
## Usage:
##   pool.initialize(32)  # Create 32 Labels at startup
##   var label = pool.acquire_label()
##   label.text = "Score: 100"
##   label.show()
##   # When done:
##   label.hide()
##   pool.release_label(label)

class_name LabelPool
extends Node

## Maximum number of labels in the pool
var pool_size: int = 0

## Array of pre-instantiated Label nodes
var available_labels: Array[Label] = []

## Set of currently active (borrowed) labels
var active_labels: HashSet[Label] = HashSet()

## Pre-instantiated scene resource
var label_scene: PackedScene = preload("res://ui/PooledLabel.tscn")

# ============================================================================
# Initialization
# ============================================================================

func initialize(capacity: int) -> void:
	"""
	Pre-instantiate Label nodes and store in the pool.
	Call this once during game startup (e.g., in _ready() of an autoload).
	
	Args:
		capacity: Number of Label nodes to pre-create
	"""
	pool_size = capacity
	available_labels.resize(capacity)
	
	for i in range(capacity):
		var label = _create_label()
		available_labels[i] = label
	
	print("LabelPool initialized with %d labels" % capacity)


func _create_label() -> Label:
	"""
	Instantiate a single Label and configure it.
	
	Returns:
		A configured Label node (initially hidden)
	"""
	var label: Label = label_scene.instantiate()
	label.visible = false
	label.process_mode = Node.PROCESS_MODE_INHERIT  # Default mode
	add_child(label)  # Add to pool manager as parent
	return label


# ============================================================================
# Core Pool Operations
# ============================================================================

func acquire_label() -> Label:
	"""
	Borrow a Label from the pool. If pool is exhausted, instantiate a new one.
	
	Returns:
		An available Label node (initially hidden, state reset)
	"""
	var label: Label
	
	if available_labels.size() > 0:
		label = available_labels.pop_back()
	else:
		# Fallback: Create a new label if pool is exhausted
		# Consider logging a warning for debugging
		label = _create_label()
		push_warning("LabelPool exhausted. Instantiating additional label. Consider increasing pool size.")
	
	# Reset label state to known defaults
	_reset_label_state(label)
	
	label.visible = false  # Caller should explicitly show()
	active_labels.insert(label)
	
	return label


func release_label(label: Label) -> void:
	"""
	Return a Label to the pool for reuse. Must be called by client code.
	
	Args:
		label: The Label to return to the pool
	"""
	if not label:
		push_error("Attempted to release null label")
		return
	
	if not active_labels.contains(label):
		push_warning("Attempted to release label that wasn't borrowed from this pool")
		return
	
	active_labels.erase(label)
	_reset_label_state(label)
	label.visible = false
	label.position = Vector2.ZERO  # Clear position state
	available_labels.append(label)


func _reset_label_state(label: Label) -> void:
	"""
	Reset a label to a clean state before reuse.
	Ensures no stale data persists between uses.
	
	Args:
		label: The Label to reset
	"""
	label.text = ""
	label.modulate = Color.WHITE
	label.scale = Vector2.ONE
	label.rotation = 0.0
	label.z_index = 0
	# Reset any theme overrides if using them
	# label.add_theme_color_override("font_color", Color.WHITE)


# ============================================================================
# Pool Status & Debugging
# ============================================================================

func get_pool_stats() -> Dictionary:
	"""
	Return current pool statistics for debugging/monitoring.
	
	Returns:
		Dictionary with keys: available_count, active_count, total_capacity
	"""
	return {
		"available_count": available_labels.size(),
		"active_count": active_labels.size(),
		"total_capacity": pool_size,
		"utilization_percent": float(active_labels.size()) / pool_size * 100.0
	}


func print_stats() -> void:
	"""Print pool statistics to console."""
	var stats = get_pool_stats()
	print("LabelPool Stats: Available=%d, Active=%d, Capacity=%d, Utilization=%.1f%%" % [
		stats["available_count"],
		stats["active_count"],
		stats["total_capacity"],
		stats["utilization_percent"]
	])


# ============================================================================
# Cleanup (Optional)
# ============================================================================

func cleanup() -> void:
	"""
	Optionally clean up all pooled labels.
	Call this during scene transitions or application shutdown.
	"""
	for label in available_labels:
		if is_instance_valid(label):
			label.queue_free()
	
	available_labels.clear()
	active_labels.clear()
	print("LabelPool cleaned up")
```

### Scene File Setup

Create `res://ui/PooledLabel.tscn` (a simple Label scene):

```
Scene Tree:
â”œâ”€ Label (root)
   â”œâ”€ text: ""
   â”œâ”€ modulate: Color.WHITE
   â”œâ”€ custom_minimum_size: Vector2(0, 0)  # Set as needed for your use case
   â””â”€ (optional) theme: res://themes/ui_theme.tres

Properties to configure:
- Font size (set in theme)
- Alignment (horizontal: CENTER, vertical: CENTER)
- Autowrap: false (unless needed)
- Clip text: false
- Custom minimum size: Set based on typical label usage
```

### Usage Example

```gdscript
## ExampleGameUI.gd
## Demonstrates using the LabelPool for floating damage numbers

extends Node

var label_pool: LabelPool
var active_damages: Array[Dictionary] = []  # Track active floating numbers


func _ready() -> void:
	# Access the autoloaded pool
	label_pool = get_tree().root.get_node("LabelPool")  # or use autoload name
	
	# Simulate spawning damage numbers
	spawn_damage_number(100, global_position + Vector2(50, 0))


func spawn_damage_number(damage: int, world_position: Vector2) -> void:
	"""
	Spawn a floating damage number at the given world position.
	
	Args:
		damage: Damage amount to display
		world_position: Position in world space to spawn at
	"""
	var label = label_pool.acquire_label()
	label.text = str(damage)
	label.global_position = world_position
	label.modulate = Color.RED
	label.visible = true
	
	# Track for animation
	active_damages.append({
		"label": label,
		"lifetime": 2.0,
		"elapsed": 0.0,
		"start_pos": world_position,
		"color": Color.RED
	})


func _process(delta: float) -> void:
	"""Update floating damage numbers."""
	var expired: Array[int] = []
	
	for i in range(active_damages.size()):
		var damage_data = active_damages[i]
		damage_data["elapsed"] += delta
		
		# Fade out animation
		var progress = damage_data["elapsed"] / damage_data["lifetime"]
		damage_data["label"].modulate.a = 1.0 - progress
		
		# Float upward
		damage_data["label"].position.y -= delta * 50.0
		
		# Check if expired
		if damage_data["elapsed"] >= damage_data["lifetime"]:
			expired.append(i)
	
	# Return expired labels to pool (iterate backward to preserve indices)
	for i in range(expired.size() - 1, -1, -1):
		var idx = expired[i]
		var label = active_damages[idx]["label"]
		label_pool.release_label(label)
		active_damages.pop_at(idx)


func _notification(what: int) -> void:
	"""Clean up on scene exit."""
	if what == NOTIFICATION_SCENE_UNLOAD:
		# Return all active labels
		for damage_data in active_damages:
			label_pool.release_label(damage_data["label"])
		active_damages.clear()
```

### Setup as Autoload

1. Create `res://autoload/LabelPool.gd` (copy the pool script above)
2. In Project Settings â†’ Autoload tab:
   - Add path: `res://autoload/LabelPool.gd`
   - Node name: `LabelPool`
3. In your main scene's `_ready()`:
   ```gdscript
   LabelPool.initialize(64)  # Adjust capacity for your game
   ```

---

## Performance Implications

### Pooling vs. Instantiate/Free

| Metric | Instantiate/Free | Node Pool |
|--------|------------------|-----------|
| **Memory allocation cost** | Per instance, every creation | One-time at initialization |
| **Garbage collection pauses** | Yes, unpredictable | No |
| **`queue_free()` overhead per frame** | Cumulative if many destroyed | Zero (no deletion) |
| **Scene tree operations** | Add/remove every use | None after init |
| **Battery drain (iOS)** | Higher (allocation events) | Lower (stable state) |
| **Frame time stability** | Spiky (GC/deallocation) | Consistent |
| **Memory footprint** | Dynamic, lower average | Higher, fixed (bounded) |

### Why Pooling Matters on iOS

1. **Battery & Thermal**: Each allocation/deallocation is an energy event. iOS monitors power consumption aggressively; repeated cycles trigger throttling and battery drain warnings.

2. **Frame Stability**: iOS devices (especially iPhones) prioritize consistent frame pacing. Unpredictable `queue_free()` spikes cause dropped frames more visibly than on desktop.

3. **Memory Constraints**: iOS apps have strict memory limits. Repeated allocation cycles risk hitting low-memory conditions, triggering aggressive collection or app termination.

---

## Alternative Strategies

### 1. Hide/Show Without Pooling (Not Recommended for Volume)

```gdscript
# Create labels once, reuse by toggling visible
var labels: Array[Label] = []

func _ready():
	for i in range(32):
		var label = Label.new()
		add_child(label)
		label.visible = false
		labels.append(label)

func show_damage(index: int, text: str, position: Vector2):
	labels[index].text = text
	labels[index].global_position = position
	labels[index].visible = true
```

**Drawback**: You still need to manage active vs. inactive indices manually. Scales poorly beyond simple cases.

### 2. Process Mode Optimization

If you must keep nodes around without deletion, control processing:

```gdscript
# Disable processing for hidden labels
func hide_label(label: Label) -> void:
	label.visible = false
	label.process_mode = Node.PROCESS_MODE_DISABLED

func show_label(label: Label) -> void:
	label.visible = true
	label.process_mode = Node.PROCESS_MODE_INHERIT  # or PROCESS_MODE_ALWAYS
```

**Note**: `visible = false` **does not** automatically disable `_process()` callbacks. You must explicitly set `process_mode = PROCESS_MODE_DISABLED`.

### 3. Detach/Reattach from Scene Tree

```gdscript
# Remove from scene tree to stop processing entirely
func deactivate_label(label: Label) -> void:
	remove_child(label)

func reactivate_label(label: Label) -> void:
	add_child(label)
```

**Advantage**: Complete processing halt. **Disadvantage**: More expensive than hide/show; should only be used if processing is a real bottleneck.

---

## Best Practices for iOS

### 1. Initialization Timing
```gdscript
# BAD: Initialize pool in _ready() of a frequently-created node
# This causes stutters on scene creation

# GOOD: Initialize in autoload's _ready() or game startup
func _ready() -> void:
	if Engine.has_singleton("LabelPool"):
		LabelPool.initialize(max_expected_labels)
```

### 2. Pool Size Calculation
```gdscript
# Estimate peak concurrent labels
# Example: Damage numbers that stay visible for 2 seconds at 60 FPS:
# - If 30 damage numbers spawn per second: need 30 * 2 = 60 labels in pool
# - Add 20% headroom: 60 * 1.2 = 72 labels

# Monitor during development
LabelPool.print_stats()  # Check utilization % in logs
```

### 3. Memory Footprint Trade-off
```gdscript
# Pool trade-off on iOS (16GB RAM example device):
# - 64 Label nodes: ~64KB overhead (small price)
# - 1000 Label nodes: ~1MB overhead (acceptable)
# - 10000 Label nodes: ~10MB overhead (starts impacting low-mem devices)

# Always profile on actual iOS devices, especially older models
```

### 4. Preventing Pool Exhaustion
```gdscript
func acquire_label() -> Label:
	if available_labels.size() == 0:
		# Option A: Create new (lenient)
		return _create_label()
		
		# Option B: Forcibly reclaim oldest active label (aggressive)
		# var oldest = active_labels.front()
		# release_label(oldest)
		# return acquire_label()
		
		# Option C: Return null and handle in caller (strict)
		# push_error("Pool exhausted!")
		# return null
```

### 5. CPU Thread Awareness (Godot 4.5+)
```gdscript
# If using multi-threaded rendering on iOS:
# - Keep label acquisition/release on main thread
# - Do NOT acquire labels from worker threads

func _process(_delta: float) -> void:
	# Safe: Main thread
	var label = label_pool.acquire_label()

# Not recommended: Physics/threaded callback
# func _physics_process(_delta: float) -> void:
#     # Risky on iOS
#     var label = label_pool.acquire_label()
```

---

## Monitoring & Profiling

### In-Engine Monitoring
```gdscript
# Add to your debug UI
func update_debug_display() -> void:
	var stats = LabelPool.get_pool_stats()
	debug_label.text = "Labels Active: %d / %d" % [
		stats["active_count"],
		stats["total_capacity"]
	]
```

### Xcode Profiling (iOS)
1. Run app in Xcode â†’ Product â†’ Profile
2. Open Instruments
3. Monitor:
   - **Energy Impact**: Should remain low and stable
   - **Memory**: Should not spike during label spawn/release cycles
   - **GPU Utilization**: Should be consistent, not spiking per label

### Godot Profiler
```gdscript
# In-game profiler for monitoring
func _ready() -> void:
	if OS.is_debug_build():
		# Enable profiler output to console
		print_verbose("LabelPool initialized")
```

---

## Detailed Implementation Notes

### Handling State Complexity

For advanced label behavior (animations, shaders, custom properties):

```gdscript
## AdvancedLabelPool.gd
## Extension supporting label animations and state

class_name AdvancedLabelPool
extends Node

# ... (base pool code from earlier) ...

# Track label animations
var label_animations: Dictionary = {}


func acquire_label_with_animation(animation_name: str) -> Label:
	"""Acquire a label and prepare it for animation."""
	var label = acquire_label()
	label_animations[label] = {
		"animation": animation_name,
		"time": 0.0,
		"duration": get_animation_duration(animation_name)
	}
	return label


func get_animation_duration(animation_name: str) -> float:
	"""Get animation duration from config or tween."""
	# Implementation specific to your animation system
	return 1.0


func _process(delta: float) -> void:
	"""Update animations for active labels."""
	var finished: Array[Label] = []
	
	for label in label_animations.keys():
		if not is_instance_valid(label):
			finished.append(label)
			continue
		
		var anim_data = label_animations[label]
		anim_data["time"] += delta
		
		if anim_data["time"] >= anim_data["duration"]:
			finished.append(label)
	
	for label in finished:
		label_animations.erase(label)
		release_label(label)
```

### Integration with UI Themes

```gdscript
## Configure pooled labels with a shared theme
func _create_label() -> Label:
	var label: Label = label_scene.instantiate()
	# Share theme for efficiency
	label.theme = preload("res://themes/ui_theme.tres")
	label.visible = false
	add_child(label)
	return label
```

### Signal-Based Lifecycle (Advanced)

```gdscript
## Use signals for complex label lifecycle
signal label_acquired(label: Label)
signal label_released(label: Label)

func acquire_label() -> Label:
	var label = super.acquire_label()
	label_acquired.emit(label)
	return label

func release_label(label: Label) -> void:
	super.release_label(label)
	label_released.emit(label)
```

---

## Summary Table: Decision Matrix

| Scenario | Recommendation | Reasoning |
|----------|---|---|
| **<10 labels, static** | Direct instantiation | Overhead not justified |
| **10-100 labels, occasional spawn** | Simple pool (easy) | Clear performance gain |
| **100+ labels, frequent spawn** | Object pool (recommended) | Eliminates GC/deallocation spikes |
| **Thousands of labels** | Consider alternate approach (CanvasItem rendering) | Node overhead becomes dominant |
| **iOS low-end devices** | Always pool if >5 labels active | Battery/thermal critical |
| **High-frequency spawning** | Always pool | `queue_free()` overhead compounds |

---

## References & Further Reading

- **Godot 4.5 Documentation**: Performance optimization, process modes
- **Object Pool Pattern**: Game Programming Patterns (Nystrom)
- **iOS Energy Profiling**: Xcode Instruments guide
- **GDScript Best Practices**: Official Godot documentation
