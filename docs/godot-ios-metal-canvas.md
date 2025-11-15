# Godot 4.5 iOS Metal Rendering Pipeline: CanvasItem Architecture

## Overview

Godot 4.5 uses a **frame-by-frame reconstruction model** for 2D rendering on iOS Metal, not a persistent render cache. Each frame, the rendering system completely rebuilds the draw list based on the current scene tree state.

---

## Frame-by-Frame Draw List Reconstruction

### Visibility-Driven Culling

Godot's viewport processes visible canvas items each frame. The batching system iterates through the scene tree in painter's order (back to front) and only includes items where `is_visible_in_tree()` returns true. Hidden nodes are automatically excluded from the draw command generation.

### Per-Frame Command Recording

The RenderingDevice backend (which underlies Metal on iOS) records command buffers fresh each frame. This is the standard approach across modern graphics APIsâ€”command buffers are not reused between frames. Recording is efficient enough that this is the intended design pattern.

---

## Render Cache Architecture

### No Persistent GPU-Side Render Cache

Godot does **not** maintain a persistent GPU-side render cache for 2D canvas items. Instead:

- Each frame, the system walks the scene tree to build an item list
- The **RasterCanvasBatcher** processes consecutive items with similar properties (texture, material, blend mode) into batches
- Draw calls are only generated for visible itemsâ€”the batching step respects visibility culling
- Once a frame is submitted to the GPU, the draw list is discarded and rebuilt from scratch next frame

### Implications

If you hide a node and then show it again, it incurs **no GPU cache lookup cost**â€”it's simply redrawn as part of the normal batching process.

---

## Scene Tree State and GPU Rendering State Synchronization

### Relationship Model

The relationship between scene tree changes and GPU state operates through a **deterministic, frame-synchronized pipeline** with **one-way, frame-delayed** synchronization:

- Scene tree changes affect what draw commands are generated
- These commands are then submitted to Metal
- There is **no bidirectional feedback** or persistent GPU-side scene state representation

### Frame Processing Pipeline

#### 1. Scene Tree Query Phase

The viewport queries all CanvasItem descendants to determine visibility. This uses `is_visible_in_tree()` checks and canvas layer assignments.

#### 2. Item List Building

Visible items are collected with metadata:
- Transform
- Z-index
- Canvas layer
- Material
- Texture

Items are sorted by canvas layer first, then by z-index, respecting painter's order.

#### 3. Batching Stage

The batcher groups consecutive items that share rendering state:

| Batch Break Condition | Impact |
|---|---|
| Material changes | Breaks batch |
| Texture changes | Breaks batch |
| Z-order/layering constraints | Must be respected |
| Light masks and visibility layers | Add filtering conditions |

#### 4. Command Buffer Recording

All draw commands for the frame are recorded into a single command buffer per frame. Metal compiles these into GPU instructions.

---

## GPU Synchronization on iOS

### Metal Synchronization Points

Metal on iOS uses explicit **synchronization points** to ensure GPU/CPU coherency:

- **Command buffer submission**: Once all draw commands are recorded, the command buffer is submitted to Metal's command queue
- **Render pass boundaries**: Each render pass (e.g., opaque items, then transparent items) includes automatic barriers to ensure previous work completes before the next stage begins
- **Frame boundaries**: At frame end, Metal waits for the GPU to finish before the next frame begins (if V-Sync is enabled, which is typical on iOS)

### Hidden Node Visibility Update Flow

When you hide a CanvasItem node:

1. `set_visible(false)` queues a `NOTIFICATION_VISIBILITY_CHANGED` notification
2. This does **not** immediately update the GPUâ€”it only marks the node's internal state
3. On the **next frame**, the viewport's item culling phase skips this node entirely
4. The draw list for that frame is rebuilt without the hidden node
5. The new command buffer is submitted to Metal
6. GPU rendering reflects the visibility change on the **next rendered frame** (typically <16ms on iOS at 60fps)

### Removed Node Update Flow

When a node is removed from the scene tree:

1. The node is removed from the scene tree
2. On the **next frame**, the viewport no longer encounters the node during tree traversal
3. The item list is rebuilt without that node
4. The new command buffer is submitted to Metal
5. GPU rendering reflects the removal immediately in the next frame

---

## Render Target Update Behavior

### Default Behavior

**Viewport render targets update every frame by default**. There is no automatic optimization that caches render target contents.

### Update Mode Variations

- **UPDATE_ALWAYS (default)**: Render target updates every frame
- **UPDATE_ONCE**: Render target only renders once and then stops
- **CanvasGroup nodes**: Have built-in render targets, update every frame, and cannot currently be configured otherwise in 4.5

### Frame-Level Processing

Each frame, the viewport:
1. Iterates through its canvas items
2. Builds a fresh command buffer
3. Submits it to Metal
4. Waits for completion before the next frame

---

## Metal Rendering Architecture Details

### Shader Compilation Strategy

Metal uses lazy compilation on iOS by default in Godot 4.4+:

- Ubershaders are compiled at startup or first use
- Optimized pipelines compile on-demand when first encountered
- This affects frame times but doesn't interact directly with draw list caching

### Metal Command Buffer Architecture

Per-frame flow:

1. Godot's RenderingDevice creates a command buffer via Metal
2. All draw commands are encoded into this buffer
3. The buffer is committed to the command queue
4. Metal waits for the frame to finish rendering before the next frame's buffer can be processed
5. **No GPU-side draw list persistence exists between frames**

### AABB and Visibility Culling

Godot performs **bounding-box culling** for CanvasItems based on their bounds:

- If an item's AABB is outside the viewport, it may be culled before reaching the batcher
- This is separate from visibility stateâ€”an invisible node is culled regardless of AABB
- Both mechanisms work independently to minimize GPU work

---

## Performance Implications

### Efficient Operations

Since the draw list is rebuilt each frame:

- **Hiding/showing nodes is efficient**: No GPU state needs to be updated; the next frame simply won't include the hidden node
- **Removing nodes from the tree is efficient**: They're garbage collected, and the item list naturally excludes them next frame
- **Frequent visibility changes don't cause GPU thrashing**: The CPU records a new command buffer, but this is designed to be fast

### Potential Bottlenecks

If you're manipulating dozens of visibility states per frame, this can cause the CPU to spend significant time rebuilding batches. However, this is still far more efficient than trying to manage individual GPU resources.

---

## Direct Answers to Key Questions

### Q: When does Metal update its draw list when nodes are hidden/removed?

**A:** On the **next frame during the batching phase**. Metal doesn't see the change immediately; Godot rebuilds the command buffer first.

### Q: Is there a render cache that persists after scene tree changes?

**A:** **No**. Each frame is a fresh start. The only "cache" is the draw commands within a single frame's command buffer. Once submitted and executed, the command buffer is discarded, and the next frame starts from scratch.

### Q: What's the relationship between scene tree state and GPU rendering state on iOS?

**A:** **One-way, frame-delayed**:
- Scene tree changes affect what draw commands are generated
- These commands are then submitted to Metal
- There is no bidirectional feedback or persistent GPU-side scene state representation
- Visibility changes typically appear on-screen within 16ms (one frame at 60fps)

---

## Technical Data Structure Summary

| Component | Scope | Lifetime | Update Frequency |
|---|---|---|---|
| Scene Tree State | CPU | Persistent across frames | On-demand (when changed) |
| Item List | CPU | Single frame | Every frame |
| Batches | CPU | Single frame | Every frame |
| Command Buffer | GPU | Single frame | Every frame |
| GPU Render State | GPU | Single frame | Every frame (via command buffer) |
| Render Cache | None | N/A | N/A |

---

## Implementation Considerations for Developers

### Best Practices

1. **Visibility changes are cheap**: Use `set_visible()` liberallyâ€”it's designed to be frame-efficient
2. **Batch visibility changes**: If changing many nodes' visibility, batch them within a single frame if possible
3. **AABB matters**: Ensure custom CanvasItems set proper AABB for culling efficiency
4. **Material changes are expensive**: Changing materials per-node can break batches; consolidate where possible
5. **Monitor layer assignments**: Excessive canvas layers prevent batching optimization

### Debugging

- Use Godot's built-in profiler to monitor draw call countâ€”it should remain stable if batching is working
- Hiding nodes should not increase draw call count on subsequent frames
- Removing nodes should reduce draw call count on subsequent frames

---

## Summary

Godot 4.5's iOS Metal rendering pipeline rebuilds the canvas draw list every frame from the scene tree state. There is no persistent GPU-side render cache. When nodes are hidden or removed, the change is reflected in the GPU rendering on the next frame after Godot rebuilds its command buffer. This frame-by-frame reconstruction model provides deterministic, efficient rendering while maintaining tight synchronization between scene tree state and GPU rendering state.
