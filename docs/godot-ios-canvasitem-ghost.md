# Godot 4.5.1 iOS Metal Renderer CanvasItem Ghost Rendering Issue

## Problem Statement

CanvasItem nodes (Labels and derived UI elements) in Godot 4.5.1 on iOS with Metal renderer remain visually rendered on screen for 50+ seconds even after executing all standard cleanup methods:

- `hide()`
- `remove_child()`
- `queue_free()`
- `RenderingServer.canvas_item_set_visible(false)`
- Setting `modulate.a = 0` (zero alpha)
- Moving nodes off-screen via transform

All cleanup operations execute without error in logs (indicating successful GDScript execution), but visual ghost images persist on the iOS display despite the nodes being logically removed/hidden from the scene tree.

## Context

| Property | Value |
|---|---|
| Engine Version | Godot 4.5.1 |
| Platform | iOS |
| Renderer | Metal (native driver, not MoltenVK) |
| Affected Node Types | CanvasItem derivatives (Label, Control, Node2D-based UI) |
| Symptom Duration | 50+ seconds |

## Known Related Issues

### Frame Buffer Synchronization on iOS Metal
iOS Metal rendering has documented synchronization challenges between the CPU command queue and GPU frame rendering [web:11][web:23]. The Metal driver has specific shader compilation and command execution timing that differs significantly from desktop Vulkan implementations. Frame buffer management and viewport updates may not immediately reflect scene tree changes.

### Rendering Device Command Deferral
The RenderingServer operates on a deferred command queue that batches rendering operations. On iOS Metal specifically, this queue may not flush or synchronize to the GPU display buffer immediately after visibility state changes. The rendering device maintains its own internal framebuffer cache that persists across visibility state transitions [web:25].

### Graphics API Latency Patterns
Godot's graphics abstraction layer accounts for display latency caused by:
- Graphics APIs displaying 2-3 frames late by design
- Metal's triple-buffered V-Sync (default behavior)
- Mobile device GPU execution delays that can exceed 50ms per frame

This architectural latency window can cause visual persistence of hidden/destroyed nodes [web:15][web:34].

## Verified Cleanup Pattern Issues

### Pattern 1: Standard Visibility Toggling (Ineffective)
```gdscript
# This completes immediately but ghost renders persist
label.hide()
label.visible = false
label.modulate.a = 0
```

**Reason**: Visibility state changes are processed by the scene tree but may not propagate to the Metal rendering device's active framebuffer until the next complete render cycle (which may span multiple V-Sync intervals).

### Pattern 2: Scene Tree Removal (Incomplete)
```gdscript
# Node logically removed but rendering artifacts persist
remove_child(label)
label.queue_free()
```

**Reason**: `queue_free()` marks nodes for deletion at end-of-frame, but the rendering command that drew the node in the current frame is already queued to the Metal GPU. Freeing the GDScript object doesn't retroactively remove GPU commands already submitted. The Metal command buffer for the current frame has already been encoded with draw calls for this node [web:2].

### Pattern 3: RenderingServer Direct Calls (May Not Flush)
```gdscript
# Canvas item told to hide but buffer not flushed
RenderingServer.canvas_item_set_visible(node.get_canvas_item(), false)
```

**Reason**: This call adds a command to the RenderingServer queue but does not guarantee GPU buffer synchronization. The iOS Metal driver may batch these state changes with other rendering operations, deferring the actual GPU state update until the next buffer swap.

## Root Cause Analysis

### Primary Factor: Frame Buffer Latency
The Metal driver on iOS maintains a 3-frame buffer by default for V-Sync. Rendering commands are pre-encoded into multiple framebuffers:
- Frame N (currently displayed)
- Frame N+1 (being encoded)
- Frame N+2 (pre-encoded reserve)

A visibility state change in frame N affects encoding in frame N+1, but frame N is already displayed. With 60 FPS, frame N persists for ~16ms, and the complete pipeline (current + 2 buffered frames) can display stale rendering data for up to 50ms [web:34].

### Secondary Factor: Canvas Item Rendering Cache
The CanvasItem rendering system maintains internal caches of rendered output. These caches are not invalidated immediately upon visibility state changes in the Metal renderer. The rendering device's canvas layer system keeps references to previously-encoded draw commands that persist across scene tree modifications [web:25].

### Tertiary Factor: iOS Metal Command Buffer Encoding
Unlike desktop Vulkan, which offers more immediate command queue flushing, Metal on iOS encodes all rendering commands for a frame before GPU execution begins. Once encoded, changes to scene state during that frame do not affect the GPU's execution of already-encoded commands. The 50+ second persistence suggests either:
- Multiple render cycles worth of pre-encoded buffers (50-60ms at 60 FPS suggests 3+ frame buffers)
- Metal driver's internal caching of canvas state that persists beyond scene tree updates
- iOS display compositing layer holding stale texture/bitmap data

## Recommended Cleanup Patterns

### Pattern A: Combined Approach (Most Reliable)
```gdscript
# Explicit ordering to ensure RenderingServer is notified
label.visible = false
label.modulate.a = 0.0

# Give RenderingServer one frame to update
await get_tree().process_frame

# Then remove from tree
remove_child(label)

# Finally free
label.queue_free()
```

**Rationale**: Separating visibility change (frame 1) from tree removal (frame 2) ensures RenderingServer has time to update its internal canvas state before the node object is destroyed.

### Pattern B: Immediate Free with Visibility Pre-flag
```gdscript
label.visible = false
label.modulate.a = 0.0

# Free immediately (not deferred)
# Use only if you don't reference this node after
label.free()
```

**Rationale**: Immediate `free()` bypasses the frame-end queue but risks crashes if the node is still referenced. Only safe if cleanup is the last operation on that node reference.

### Pattern C: RenderingServer Direct + Manual Flush
```gdscript
var canvas_item = label.get_canvas_item()
RenderingServer.canvas_item_set_visible(canvas_item, false)

# Force a frame to process rendering commands
await get_tree().process_frame
await get_tree().process_frame

# Now safe to remove/free
remove_child(label)
label.queue_free()
```

**Rationale**: Multiple `process_frame` awaits provide time for Metal's command buffer queues to work through their backlog.

### Pattern D: Manual Viewport/Canvas Layer Refresh
```gdscript
label.visible = false

# Manually request canvas layer update
# This may trigger faster refresh than automatic scene update
var canvas_layer = label.get_parent()  # Must be CanvasLayer or CanvasItem parent
if canvas_layer:
    canvas_layer.queue_redraw()

await get_tree().process_frame
label.queue_free()
```

**Rationale**: Explicitly requesting a canvas redraw may bypass lazy update optimization that delays rendering refreshes.

## Project Settings Optimization

### Reduce V-Sync Buffer Count
```ini
# project.godot
[display]
window/vsync/swapchain_image_count = 2
```

Reducing from 3 (default) to 2 buffered frames decreases the window where stale rendering data persists. Trade-off: May increase input latency.

### Disable V-Sync for Testing
```ini
[display]
window/vsync/mode = 0  # Disabled
```

Testing without V-Sync can reveal whether the issue is purely buffer-related or involves Canvas caching.

### Mobile Renderer Settings
```ini
[rendering]
renderer/rendering_device = "metal"
quality/intended_usage/framebuffer_allocation = 1  # Mobile (uses lower precision)
```

Verify Metal (not MoltenVK) is active.

## Known Godot Framework Limitations

### Visibility Inheritance Issue
CanvasItem visibility is hierarchicalâ€”a hidden parent propagates visibility to children through the tree traversal. However, the rendering device maintains separate state from the scene tree. Changes to `visible` property don't atomically update all rendering device state [web:3].

### Node Freeing Timing
`queue_free()` occurs at the end of the frame, but rendering commands for that frame are already encoded by that point. The rendering pipeline's frame is logically complete before node cleanup executes [web:33].

### Canvas Item Layer Decoupling
Canvas items and their parent CanvasLayer can become decoupled during rapid show/hide cycles. The rendering cache may reference the node even after tree removal [web:9].

## Workarounds for Production

### Workaround 1: Pool and Disable Pattern
Instead of destroying UI nodes, reuse them:
```gdscript
# Don't destroy, just hide and move far off-screen
label.position = Vector2(-10000, -10000)  # Beyond viewport
label.visible = false
label.modulate.a = 0

# Add to pool for reuse
ui_pool.append(label)
```

This avoids the cleanup race condition entirely.

### Workaround 2: Staggered Cleanup Queue
```gdscript
var nodes_to_cleanup = []

func queue_cleanup(node):
    nodes_to_cleanup.append(node)

func _process(_delta):
    if nodes_to_cleanup.size() > 0:
        var node = nodes_to_cleanup.pop_front()
        node.visible = false
        node.modulate.a = 0
        await get_tree().process_frame
        await get_tree().process_frame
        remove_child(node)
        node.queue_free()
```

Process one node per frame to avoid overwhelming the Metal command queue.

### Workaround 3: Separate UI Viewport
Create a secondary SubViewport with custom rendering:
```gdscript
# Use SubViewport with separate render target
var ui_viewport = SubViewport.new()
add_child(ui_viewport)
# Add UI to viewport instead of main scene
# Faster to destroy SubViewport than individual nodes
```

SubViewport destruction may be more reliable than individual CanvasItem cleanup.

## Testing and Diagnosis

### Profiling Checklist
- [ ] Enable Godot's frame profiler: `Project > Tools > Monitor`
- [ ] Watch "Canvas Items" count during hide/cleanup
- [ ] Watch Metal GPU utilization in Xcode Instruments (Renderer cycles)
- [ ] Record Metal frame encoder time during visibility state change

### Debug Script
```gdscript
# Attach to test label
func test_cleanup():
    print("Frame %d: About to hide" % Engine.get_physics_frames())
    label.hide()
    
    for i in range(10):
        await get_tree().process_frame
        var visible = label.is_visible_in_tree()
        print("Frame %d: visible_in_tree=%s" % [Engine.get_physics_frames(), visible])
    
    print("Frame %d: About to remove" % Engine.get_physics_frames())
    remove_child(label)
    
    print("Frame %d: About to queue_free" % Engine.get_physics_frames())
    label.queue_free()
    
    for i in range(5):
        await get_tree().process_frame
        print("Frame %d: Post-free, tree nodes=%d" % [Engine.get_physics_frames(), get_tree().get_node_count()])
```

## iOS-Specific Considerations

### Metal Driver Differences from Desktop
- Metal shaders must be pre-transpiled from GLSLâ†’SPIR-Vâ†’MSL
- Lazy shader compilation on iOS Metal can delay framebuffer updates [web:11]
- Metal does not support GPU-CPU synchronization points that Vulkan offers

### iPhone vs iPad Behavior Variance
Behavior may differ between device generations:
- Older devices (iPhone XS) may show longer persistence (GPU queue backlog)
- Newer devices (iPhone 14+) with faster GPUs may show shorter persistence
- iPad Pro may have different V-Sync configuration than iPhones

## References to Known Godot Issues

### Related GitHub Issues
- **Canvas rendering persistence**: Issues discussed in forum but not formally tracked as of 4.5.1
- **iOS Metal shader compilation delays** [web:11]: Documented in Beta 4 issues, may affect framebuffer state propagation
- **RenderingServer command buffering**: Architectural limitation acknowledged in internal rendering architecture docs [web:23]
- **CanvasLayer visibility inheritance** [web:3]: Known limitation with visibility layer propagation

### Related Documentation
- **Internal Rendering Architecture** [web:23]: Explains Metal vs. Vulkan differences, frame buffering
- **Fixing Jitter and Input Lag** [web:34]: Documents V-Sync buffer implications
- **Reducing Stutter from Pipeline Compilations** [web:32]: Metal shader compilation latency

## Conclusion

The 50+ second ghost rendering persistence is likely an intersection of iOS Metal's frame buffering architecture (3-frame default V-Sync buffer), CanvasItem rendering cache state that outlives scene tree updates, and Metal GPU command queues that pre-encode frames before visibility state changes propagate.

**Most reliable mitigation**: Implement Pattern A (combined approach) with multiple `await get_tree().process_frame` calls between visibility change and actual node removal, combined with Project Settings changes to reduce V-Sync buffer count.

**Engineering recommendation**: If this persists, file a detailed bug report to Godot GitHub with Metal profiler traces showing framebuffer state before/after cleanup, as it may warrant a Metal driver fix to force immediate framebuffer invalidation on CanvasItem visibility changes.

---

## Appendix: Pattern Decision Tree

```
START: Need to hide/remove CanvasItem

â”œâ”€ Is this UI that might be shown again?
â”‚  â””â”€ YES â†’ Use Workaround 1 (Pool pattern)
â”‚           Don't destroy, just hide far off-screen
â”‚
â”œâ”€ Is this a one-time cleanup at level end?
â”‚  â””â”€ YES â†’ Use Workaround 3 (Viewport destruction)
â”‚           Destroy entire SubViewport instead of individual nodes
â”‚
â””â”€ Is this real-time UI cleanup during gameplay?
   â””â”€ YES â†’ Check node count and cleanup rate
           â”œâ”€ Many nodes, high frequency â†’ Use Workaround 2 (Staggered queue)
           â””â”€ Few nodes, low frequency â†’ Use Pattern A (Combined approach)
                                        â”œâ”€ Set visible=false, modulate.a=0
                                        â”œâ”€ await process_frame
                                        â”œâ”€ remove_child()
                                        â””â”€ queue_free()
```

## Implementation Template

```gdscript
# Generic UI cleanup function for iOS Metal reliability
func cleanup_canvas_item_reliable(node: CanvasItem) -> void:
    # Step 1: Hide via multiple mechanisms
    node.visible = false
    node.modulate.a = 0.0
    
    # Step 2: Let RenderingServer process
    await get_tree().process_frame
    
    # Step 3: Remove from tree
    if node.get_parent():
        node.get_parent().remove_child(node)
    
    # Step 4: Final frame to ensure GPU processes removal
    await get_tree().process_frame
    
    # Step 5: Queue deletion
    node.queue_free()
```

Use this function instead of direct cleanup calls for production iOS Metal builds.
