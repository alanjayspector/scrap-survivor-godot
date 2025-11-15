# iOS Cleanup - Iteration 2: RenderingServer Direct Calls
**Date**: 2025-01-14
**Purpose**: Escalate to RenderingServer direct manipulation after IOSCleanup Phase 1 failed
**Status**: ⏳ Testing

---

## What Failed in Iteration 1

IOSCleanup Phase 1 executed **ALL cleanup phases perfectly**, but ghost images persisted.

### Evidence from QA

**Level 3 Label Timeline**:
- Created and displayed at line 3073
- Cleaned up at line 3192-3211 (all phases executed)
- Wave 2 completed at line 4125 (**51 seconds later**)
- User reports: "LEVEL 3!" visible over "Wave 2 Complete!" screen

**Cleanup Phases Confirmed Executed**:
- ✅ Cleared Label text
- ✅ Set modulate alpha to 0
- ✅ Set self_modulate alpha to 0
- ✅ Moved Control off-screen to (999999, 999999)
- ✅ Set z_index to -4096
- ✅ Disabled _process()
- ✅ Disabled _physics_process()
- ✅ Disabled input processing
- ✅ Called hide()
- ✅ Removed from parent: CanvasLayer
- ✅ Queued for deletion via queue_free()

**Result**: Ghost image remained visible for **51 seconds after cleanup**.

### Enemy Accumulation Pattern

- Wave 1: 1 enemy to clean (all phases executed)
- Wave 2: 1 enemy to clean (all phases executed)
- Wave 3: 1 enemy to clean (all phases executed)
- Wave 4: **5 enemies to clean** (all phases executed, but accumulating)

---

## Root Cause Refinement

**Previous Hypothesis**: iOS Metal renderer caches CanvasItem draw calls in GPU draw list

**Refined Hypothesis**: iOS Metal renderer caches **rendered pixels** (framebuffer/texture) at GPU level, not just scene tree state

**Evidence**:
1. Node completely removed from scene tree ✓
2. All node properties invalidated ✓
3. Ghost image persists for 51+ seconds ✓

**Conclusion**: The Metal renderer has a **cached framebuffer or texture atlas** that it continues to composite over the scene even after source nodes are destroyed.

---

## Iteration 2 Approach: Direct RenderingServer Manipulation

Since GDScript-level property changes don't affect the Metal renderer's cache, we're escalating to direct RenderingServer calls to manipulate the render pipeline.

### Phase 6: RenderingServer Forced Invisibility (NEW)

**Added to IOSCleanup utility** (lines 120-132):

```gdscript
# === PHASE 6: RenderingServer forced invisibility (iOS Metal renderer fix) ===

# Try to force Metal renderer to update by directly manipulating canvas item
if node is CanvasItem:
    var canvas_item_rid = node.get_canvas_item()
    if canvas_item_rid.is_valid():
        # Force render server to mark this canvas item as invisible
        RenderingServer.canvas_item_set_visible(canvas_item_rid, false)
        print("[IOSCleanup]   RenderingServer: Forced canvas_item invisible")

        # Try to force canvas item to be removed from draw list
        RenderingServer.canvas_item_set_draw_index(canvas_item_rid, -999999)
        print("[IOSCleanup]   RenderingServer: Set draw_index to -999999")
```

**Theory**:
- `RenderingServer.canvas_item_set_visible()` directly tells Metal renderer to remove from draw list
- `RenderingServer.canvas_item_set_draw_index()` forces item to render position -999999 (hopefully culled)

---

### Viewport Refresh Method (NEW)

**Added to wasteland.gd** (lines 708-730):

```gdscript
func _force_viewport_refresh() -> void:
    """Force iOS Metal renderer to flush cached framebuffer and rebuild canvas

    iOS Metal renderer bug: Ghost images persist even after nodes are cleaned up.
    This attempts to force the renderer to rebuild by manipulating viewport settings.

    Reference: docs/experiments/ios-rendering-pipeline-bug-analysis.md
    """
    print("[Wasteland] _force_viewport_refresh() - attempting to flush Metal renderer cache")

    var viewport = get_viewport()
    if viewport:
        # Method 1: Toggle viewport transparency to force redraw
        var original_transparent = viewport.transparent_bg
        viewport.transparent_bg = not original_transparent
        viewport.transparent_bg = original_transparent
        print("[Wasteland]   Toggled viewport transparency")

        # Method 2: Force canvas layer redraw by toggling UI layer visibility
        var ui_layer = get_node_or_null("UI")
        if ui_layer and ui_layer is CanvasLayer:
            ui_layer.visible = false
            ui_layer.visible = true
            print("[Wasteland]   Toggled UI CanvasLayer visibility")

        print("[Wasteland] ✓ Viewport refresh complete")
    else:
        print("[Wasteland]   WARNING: No viewport found!")
```

**Theory**:
- Toggling viewport settings forces Metal to invalidate cached framebuffer
- Toggling UI layer visibility forces canvas redraw

---

## Files Modified

### 1. scripts/utils/ios_cleanup.gd

**Changes**:
- Added Phase 6: RenderingServer direct calls
- Now 7 phases total (was 6)

**New Log Output**:
```
[IOSCleanup]   RenderingServer: Forced canvas_item invisible
[IOSCleanup]   RenderingServer: Set draw_index to -999999
```

---

### 2. scenes/game/wasteland.gd

**Changes**:
- Added `_force_viewport_refresh()` method (lines 708-730)
- Updated `_clear_all_level_up_labels()` to call viewport refresh (line 674)
- Updated `_cleanup_all_enemies()` to call viewport refresh (line 703)

**New Log Output**:
```
[Wasteland] _force_viewport_refresh() - attempting to flush Metal renderer cache
[Wasteland]   Toggled viewport transparency
[Wasteland]   Toggled UI CanvasLayer visibility
[Wasteland] ✓ Viewport refresh complete
```

---

## Expected Log Pattern

### Label Cleanup (with RenderingServer + Viewport Refresh)

```
[Wasteland] _on_level_up_cleanup_timeout CALLED for level 3
[Wasteland]   Label is valid, freeing...
[IOSCleanup] Destroying node: Label (ID: 792102700773)
[IOSCleanup]   Cleared Label text
[IOSCleanup]   Set modulate alpha to 0
[IOSCleanup]   Set self_modulate alpha to 0
[IOSCleanup]   Moved Control off-screen to (999999, 999999)
[IOSCleanup]   Set z_index to -4096
[IOSCleanup]   Disabled _process()
[IOSCleanup]   Disabled _physics_process()
[IOSCleanup]   Disabled input processing
[IOSCleanup]   RenderingServer: Forced canvas_item invisible          ← NEW
[IOSCleanup]   RenderingServer: Set draw_index to -999999             ← NEW
[IOSCleanup]   Called hide()
[IOSCleanup]   Removed from parent: CanvasLayer
[IOSCleanup]   Queued for deletion via queue_free()
[IOSCleanup] ✓ Node destroyed with forced invisibility: Label (ID: 792102700773)
[Wasteland]   Level up label freed via IOSCleanup (level 3)
[Wasteland] _force_viewport_refresh() - attempting to flush Metal cache  ← NEW
[Wasteland]   Toggled viewport transparency                              ← NEW
[Wasteland]   Toggled UI CanvasLayer visibility                          ← NEW
[Wasteland] ✓ Viewport refresh complete                                  ← NEW
```

---

### Enemy Cleanup (Wave Complete)

```
[Wasteland] _cleanup_all_enemies() called (time: 130.069s)
[Wasteland]   Enemies to clean: 1 (in 'enemies' group at cleanup time)
[IOSCleanup] Batch cleanup: 1 nodes
[IOSCleanup] Destroying node: CharacterBody2D (ID: 991063704924)
[IOSCleanup]   Set modulate alpha to 0
[IOSCleanup]   Set self_modulate alpha to 0
[IOSCleanup]   Moved Node2D off-screen to (999999, 999999)
[IOSCleanup]   Set z_index to -4096
[IOSCleanup]   Disabled _process()
[IOSCleanup]   Disabled _physics_process()
[IOSCleanup]   Disabled input processing
[IOSCleanup]   RenderingServer: Forced canvas_item invisible          ← NEW
[IOSCleanup]   RenderingServer: Set draw_index to -999999             ← NEW
[IOSCleanup]   Called hide()
[IOSCleanup]   Removed from parent: Node2D
[IOSCleanup]   Queued for deletion via queue_free()
[IOSCleanup] ✓ Node destroyed with forced invisibility: CharacterBody2D
[IOSCleanup] ✓ Batch cleanup complete: 1 nodes destroyed
[Wasteland] _force_viewport_refresh() - attempting to flush Metal cache  ← NEW
[Wasteland]   Toggled viewport transparency                              ← NEW
[Wasteland]   Toggled UI CanvasLayer visibility                          ← NEW
[Wasteland] ✓ Viewport refresh complete                                  ← NEW
[Wasteland] All enemies cleaned up via IOSCleanup
```

---

## Testing Checklist

### Success Criteria

- [ ] Play through Waves 1-3
- [ ] Level up multiple times (2, 3, 4)
- [ ] Verify NO "LEVEL X!" labels visible over wave complete screens
- [ ] Verify NO inactive enemies visible after wave complete
- [ ] Check logs for new RenderingServer calls
- [ ] Check logs for viewport refresh execution

### Expected Behaviors if Working

1. **Labels**:
   - Appear normally during wave
   - Disappear after 2 seconds
   - NO labels over wave complete screens
   - Logs show RenderingServer calls + viewport refresh

2. **Enemies**:
   - Clean wave transitions
   - No inactive enemies on screen
   - Enemy count stable (1→1→1→1, not 1→1→1→5)
   - Logs show RenderingServer calls + viewport refresh

3. **Performance**:
   - No visual flicker from viewport toggling
   - No frame drops during cleanup
   - Smooth wave transitions

---

## If This Fails

If RenderingServer direct calls + viewport refresh still don't work, we have exhausted GDScript-level solutions and need to consider:

### Option A: Alternative Rendering Approach

Don't use Labels for level-up feedback:
- Use particles instead (different render path)
- Use a custom shader that can be forced to transparent
- Use a single reusable label that just changes text (never clean up)

### Option B: Godot Engine Bug Report

File detailed bug report with Godot:
- Minimal reproduction case
- iOS Metal renderer specific
- Document all attempted workarounds
- Request engine-level fix

### Option C: Workaround - Persistent Labels

Accept the rendering bug and work around it:
- Create labels once at startup
- Reuse same label, just change text
- Never clean up (avoid triggering the bug)
- Hide by setting text to "" and moving off-screen

### Option D: Escalate to RenderingDevice (Vulkan/Metal Direct)

Bypass Godot's rendering abstraction entirely:
- Use RenderingDevice for direct Metal control
- Manually flush GPU command buffers
- Nuclear option, significant complexity

---

## Code Quality

- ✅ **gdformat**: Passed (0 files reformatted, 2 files left unchanged)
- ✅ **gdlint**: Passed (no problems found)

---

## Risk Assessment

### High Risk

**RenderingServer calls may not affect Metal cache**:
- We're assuming Metal respects RenderingServer calls
- May need even deeper engine modifications

**Mitigation**: Have Option C (workaround) ready if this fails

### Medium Risk

**Viewport toggling may cause visual flicker**:
- Toggling transparency/visibility may cause brief flash

**Mitigation**: If flicker occurs, remove viewport toggle, rely only on RenderingServer

### Low Risk

**Performance impact from viewport refresh**:
- Only called during wave transitions
- Minimal performance concern

---

## Iteration History

### Iteration 1: IOSCleanup Multi-Layered Approach
**Status**: ❌ FAILED
**Phases**: 6 (clear properties, modulate, off-screen, z-index, disable processing, standard cleanup)
**Result**: Ghost images persisted for 51+ seconds after cleanup

### Iteration 2: RenderingServer + Viewport Refresh
**Status**: ⏳ TESTING
**Phases**: 7 (added RenderingServer direct calls + viewport refresh)
**Hypothesis**: Direct render pipeline manipulation will force Metal cache flush

---

## Related Documentation

- **Root Cause Analysis**: [ios-rendering-pipeline-bug-analysis.md](ios-rendering-pipeline-bug-analysis.md)
- **Iteration 1**: [ios-cleanup-utility-implementation.md](ios-cleanup-utility-implementation.md)
- **iOS QA Session 1**: QA reported level-up overlay persisting despite Iteration 1

---

## Sign-Off

**Iteration 2 Implementation Complete**: 2025-01-14
**Files Modified**: 2 (ios_cleanup.gd, wasteland.gd)
**Code Quality**: ✅ Passed
**Ready for iOS QA**: ✅ Yes

**Confidence Level**: Medium (40-50%)

**Why Lower Confidence**:
- Iteration 1 failed completely despite perfect execution
- Metal renderer bug may be deeper than RenderingServer level
- May require engine-level fix

**Why Not Zero**:
- RenderingServer is lower-level than node properties
- Viewport toggling may force full render refresh
- Two different approaches combined (direct calls + refresh)

**Next Steps**: iOS QA will determine if we need Iteration 3 or if we pivot to workaround strategies.
