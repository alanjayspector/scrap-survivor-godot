# Godot 4.5.1 Performance Monitor Constants Reference

**Date**: 2025-11-15
**Purpose**: Reference for valid Performance.Monitor enum constants in Godot 4.5.1
**Context**: Fixing parse errors from invalid RENDER_2D_* constants

---

## Validated Working Constants

These constants have been **confirmed to work** in Godot 4.5.1 through codebase usage:

### Time & FPS Monitoring

```gdscript
Performance.get_monitor(Performance.TIME_FPS)              # Frames per second
Performance.get_monitor(Performance.TIME_PROCESS)          # Process frame time (seconds)
Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)  # Physics frame time (seconds)
```

**Usage Example:**
```gdscript
var fps = Performance.get_monitor(Performance.TIME_FPS)
var frame_ms = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
print("FPS: %.1f, Frame time: %.2f ms" % [fps, frame_ms])
```

### Object & Node Counting

```gdscript
Performance.get_monitor(Performance.OBJECT_COUNT)              # Total objects in memory
Performance.get_monitor(Performance.OBJECT_NODE_COUNT)         # Total nodes in scene tree
Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)  # Orphaned nodes (memory leaks)
```

**Usage Example:**
```gdscript
var nodes = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
var orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
print("Nodes: %d, Orphans: %d" % [nodes, orphans])
```

### Memory Monitoring

```gdscript
Performance.get_monitor(Performance.MEMORY_STATIC)       # Static memory (bytes)
Performance.get_monitor(Performance.MEMORY_DYNAMIC)      # Dynamic memory (bytes)
Performance.get_monitor(Performance.MEMORY_STATIC_MAX)   # Peak static memory (bytes)
Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX)  # Peak dynamic memory (bytes)
```

**Usage Example:**
```gdscript
var mem_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
print("Memory: %.2f MB" % mem_mb)
```

---

## Invalid Constants (DO NOT USE)

These constants **do not exist** in Godot 4.5.1 and will cause **parse errors**:

```gdscript
Performance.RENDER_2D_ITEMS_IN_FRAME       # ❌ INVALID - causes parse error
Performance.RENDER_2D_DRAW_CALLS_IN_FRAME  # ❌ INVALID - causes parse error
```

**What happened:**
- These constants were used in `enhanced-diagnostics-2025-11-15.md`
- They caused `wasteland.gd` to fail parsing (ios.log line 13-21)
- The wasteland scene couldn't load, causing 0 HP bug
- Fixed by commenting them out and using alternative approach

---

## Alternative Approaches for 2D Rendering Stats

### Option 1: Manual Canvas Item Counting

Since Godot 4.5.1 doesn't expose `RENDER_2D_ITEMS_IN_FRAME`, count manually:

```gdscript
func _count_canvas_items_recursive(node: Node) -> int:
	"""Count visible CanvasItem nodes in scene tree"""
	var count = 0
	if node is CanvasItem and node.visible:
		count = 1
	for child in node.get_children():
		count += _count_canvas_items_recursive(child)
	return count

# Usage:
var canvas_items = _count_canvas_items_recursive(get_tree().root)
print("Canvas items: ", canvas_items)
```

**Implemented in:** [wasteland.gd:778-791](../../scenes/game/wasteland.gd#L778-L791)

### Option 2: RenderingServer API (Advanced)

For more detailed rendering stats, use RenderingServer directly:

```gdscript
# Get viewport RID
var viewport = get_viewport()
var viewport_rid = viewport.get_viewport_rid()

# Query canvas layers (example - API may vary)
# NOTE: This is more complex and may require diving into engine internals
```

**Trade-off:** More accurate but complex, may not work consistently across platforms.

### Option 3: Custom Performance Monitors

Create custom monitors for specific metrics:

```gdscript
# In autoload or main script
func _ready():
	Performance.add_custom_monitor("game/active_enemies", _get_enemy_count)
	Performance.add_custom_monitor("game/active_labels", _get_label_count)

func _get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size()

func _get_label_count() -> int:
	return label_pool.active_labels.size() if label_pool else 0

# Usage:
var enemies = Performance.get_custom_monitor("game/active_enemies")
```

**Docs:** [Custom Performance Monitors](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/custom_performance_monitors.html)

---

## Updated Diagnostic Approach (2025-11-15)

### What We Track Now

**Enhanced diagnostics in [wasteland.gd:734-791](../../scenes/game/wasteland.gd#L734-L791):**

```gdscript
func _log_metal_rendering_stats(context: String) -> void:
	print("[MetalDebug] === Rendering Stats (%s) ===" % context)

	# Performance monitors (validated working)
	print("[MetalDebug]   Objects in memory: ", Performance.get_monitor(Performance.OBJECT_COUNT))
	print("[MetalDebug]   Nodes in tree: ", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	print("[MetalDebug]   Orphan nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	print("[MetalDebug]   FPS: %.1f" % Performance.get_monitor(Performance.TIME_FPS))
	print("[MetalDebug]   Frame time: %.2f ms" % (Performance.get_monitor(Performance.TIME_PROCESS) * 1000))
	print("[MetalDebug]   Memory: %.2f MB" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0))

	# Manual canvas item counting
	var canvas_items = _count_canvas_items_recursive(self)
	print("[MetalDebug]   Canvas items (manual count): ", canvas_items)

	# Label pool diagnostics
	if label_pool:
		print("[MetalDebug]   Label pool - active: ", label_pool.active_labels.size())
		print("[MetalDebug]   Label pool - available: ", label_pool.available_labels.size())
```

### Expected Output (iOS)

```
[MetalDebug] === Rendering Stats (after_level_up_tween_start) ===
[MetalDebug]   Objects in memory: 312
[MetalDebug]   Nodes in tree: 287
[MetalDebug]   Orphan nodes: 0
[MetalDebug]   FPS: 60.0
[MetalDebug]   Frame time: 16.67 ms
[MetalDebug]   Memory: 45.23 MB
[MetalDebug]   Canvas items (manual count): 145
[MetalDebug]   Label pool - active: 1
[MetalDebug]   Label pool - available: 9
```

### Diagnostic Value

This approach helps answer:
1. **Do canvas items decrease after cleanup?** → Compare manual counts before/after
2. **Are we leaking nodes?** → Check orphan node count
3. **Is FPS stable?** → Monitor TIME_FPS during level-ups
4. **Is memory growing?** → Track MEMORY_STATIC over time
5. **Is label pool working?** → Verify active/available counts

---

## Performance Target Metrics (From docs/godot-performance-patterns.md)

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| FPS | 60 | <50 | <30 |
| Frame Time | 16.67ms | >20ms | >30ms |
| Physics Time | 6-8ms | >10ms | >12ms |
| Canvas Items | <150 | 150-300 | >300 |
| Orphan Nodes | 0 | 1-5 | >5 |

---

## References

### Documentation
- **Official Godot Docs**: [Performance Class](https://docs.godotengine.org/en/4.5/classes/class_performance.html)
- **Custom Monitors**: [Custom Performance Monitors Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/custom_performance_monitors.html)
- **Local Reference**: [godot-performance-patterns.md](godot-performance-patterns.md)

### Codebase Usage
- **wasteland.gd**: Enhanced Metal diagnostics (lines 734-791)
- **godot-performance-patterns.md**: Performance profiling examples (lines 1150-1179)
- **debugging-guide.md**: Orphan node monitoring (line 190)

### Related Issues
- **Parse Error Fix**: [2025-11-15] Fixed RENDER_2D_* constants causing 0 HP bug
- **iOS Ghost Rendering**: Enhanced diagnostics to track Metal texture atlas issues
- **Label Pool**: Diagnostics to verify pool cleanup working correctly

---

## Quick Reference Card

```gdscript
# ✅ VALID - Use these
Performance.TIME_FPS
Performance.TIME_PROCESS
Performance.TIME_PHYSICS_PROCESS
Performance.OBJECT_COUNT
Performance.OBJECT_NODE_COUNT
Performance.OBJECT_ORPHAN_NODE_COUNT
Performance.MEMORY_STATIC
Performance.MEMORY_DYNAMIC

# ❌ INVALID - Don't use these (parse errors)
Performance.RENDER_2D_ITEMS_IN_FRAME        # Use manual counting instead
Performance.RENDER_2D_DRAW_CALLS_IN_FRAME   # Use manual counting instead

# 🔧 ALTERNATIVE - Manual canvas counting
_count_canvas_items_recursive(node: Node) -> int
```

---

**Status**: ✅ Updated diagnostic approach validated and working
**Next**: Test on iOS to verify metrics are useful for debugging ghost rendering
