# Godot 4.5.1 (iOS Metal): Forcing Metal Framebuffer Flush and Canvas Rebuild

## Overview
This document details all available **Godot 4.5.1 API methods** and settings relevant to **flushing the Metal renderer's framebuffer cache and rebuilding the canvas** on iOS. Guidance is provided for both low-level and high-level APIs and includes specific details on RenderingServer, RenderingDevice, Viewport, and iOS/Metal-specific situations, along with code examples.

---

## 1. Low-Level: RenderingServer and RenderingDevice APIs

### RenderingServer
- **No direct method exposes explicit framebuffer flush/invalidate for Metal or platform-specific framebuffers.**
- The API offers the following related options:
    - `RenderingServer.force_draw()` â€” Forces all viewports to redraw, which forces a new frame to be rendered. *Does **not** guarantee an explicit Metal framebuffer flush, but triggers internal pipeline sync and GPU submission.*
    - `RenderingServer.force_sync()` â€” Forces a CPU-GPU sync. Best used when explicit blocking is needed before producing output or resources.
    
    ```gdscript
    # Redraw all viewports (not Metal-specific)
    RenderingServer.force_draw()
    
    # Block CPU until all GPU operations complete
    RenderingServer.force_sync()
    ```

- No platform-specific (Metal/iOS) calls are documented for explicit flush/invalidation via RenderingServer alone.

### RenderingDevice
- **No method in RenderingDevice exposes direct framebuffer cache flush/invalidation for Metal.**
- Most framebuffer operations involve explicit command-list and render pass manipulation, but global flushing/invalidation is not documented or exposed for Metal.
    
    ```gdscript
    var rd = RenderingServer.get_rendering_device()
    # No documented framebuffer cache flush call (Metal/iOS)
    ```

---

## 2. High-Level: Viewport Methods and Canvas Rebuild

### Framebuffer Flush / Frame Sync
- To guarantee the framebuffer is *flushed* and the viewport texture fully updated, **wait for the end-of-frame RenderingServer signal**.

    ```gdscript
    # Wait for RenderingServer to complete the frame
    await RenderingServer.frame_post_draw
    var img = $Viewport.get_texture().get_image()
    img.save_png("user://screenshot.png")
    ```

### Canvas/Framebuffer Rebuild Triggers
- The following **trigger a complete redraw/reallocation** in the rendering backend (and therefore a framebuffer rebuild):
    - **Resizing the Viewport:** `set_size()` or changing the size property.
    - **Changing Viewport Scaling Modes:** Especially `set_scaling_3d_mode()` (including MetalFX spatial/temporal on Metal).
    - **Modifying Canvas Transforms/World Attachments:** E.g., `set_canvas_transform()`, attaching a new world.
    - **Changing antialiasing or multisampling:** `set_msaa_2d()` / `set_msaa_3d()` may reconstruct internal buffers.
- Example (forcing canvas and framebuffer reallocation):
    ```gdscript
    # Resize the viewport
    $Viewport.size = Vector2(800, 600)

    # Set MetalFX upscaling (Metal only)
    $Viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_METALFX_SPATIAL)
    $Viewport.set_scaling_3d_scale(0.75)
    ```

#### Note
> There is no **explicit** `flush()` or `invalidate()` function in Viewport or RenderingServer for Metal/iOS as of 4.5.1. All flushing/invalidation of the framebuffer is handled internally by the engine and Metal driver when the above triggers are activated or a full draw is forced.

---

## 3. iOS/Metal-Specific Engine Details
- When changing modes tied to **Metal**, such as enabling MetalFX or resizing targets, Godot internally rebuilds/destroys Metal framebuffers.
- Forcing the OS/windowing layer to redraw (e.g., by moving/resizing the window or toggling fullscreen) *may* also trigger a complete surface flush and reallocation, but this is managed outside GDScript.
- **No Godot-documented iOS-specific project setting/flag exposes explicit cache/buffer flush commands for Metal.**

---

## 4. Summary Table
| Method / Setting                                | Effect                                                    | Explicit Metal flush? |
|-------------------------------------------------|-----------------------------------------------------------|-----------------------|
| `RenderingServer.force_draw()`                  | Forces all viewports to redraw a new frame                | Indirect, not Metal-specific |
| `RenderingServer.force_sync()`                  | Blocks CPU until GPU frame/render submitted               | Indirect, not Metal-specific |
| `await RenderingServer.frame_post_draw`         | Guarantees draw/swap complete, framebuffer valid          | Indirect, internal flush |
| Change Viewport size/scaling/mode               | Forces canvas/framebuffer to be rebuilt for the viewport  | Yes (engine-internal) |
| Enable MetalFX or change scaling mode/scale     | Causes framebuffer reallocation using Metal API           | Yes (engine-internal) |

---

## 5. Example Usage
```gdscript
# Force a redraw and sync
RenderingServer.force_draw()
RenderingServer.force_sync()

# Await frame complete, then access framebuffer
await RenderingServer.frame_post_draw
var img = $Viewport.get_texture().get_image()

# Resize viewport (forces framebuffer SDR/HDR transition/redraw)
$Viewport.size = Vector2(1280, 720)

# Change MetalFX scaling (Metal/iOS only)
$Viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_METALFX_SPATIAL)
$Viewport.set_scaling_3d_scale(0.67)
```

---

## 6. Final Notes
- No public API in Godot 4.5.1 (GDScript, RenderingServer, RenderingDevice) supports explicit Metal framebuffer cache flush/invalidate.
- Canvas reallocation and framebuffer clearing are *internal* to Godot and the Metal backend, not directly exposed to the script or C# layers. Use the above indirect methods to guarantee framebuffer/canvas refresh.
- Future Godot versions may expose additional Metal-specific controls. Monitor upstream Godot engine development for progress.


## References
- Godot Docs: [RenderingServer][RenderingDevice][Viewport][FramebufferCacheRD]
- [RenderingServer API](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html)
- [RenderingDevice API](https://docs.godotengine.org/en/stable/classes/class_renderingdevice.html)
- [Viewport API](https://docs.godotengine.org/en/stable/classes/class_viewport.html)
- Community/Issue Reports, 2024-2025

