# Enhanced Diagnostics for iOS Ghost Rendering Investigation
**Date**: 2025-11-15
**Status**: ⚠️ FIXED - Initial implementation caused parse errors, now corrected
**Purpose**: Deep diagnostic logging to understand Tween callback failure and modulate.a rendering issue
**Files Modified**:
- [scenes/game/wasteland.gd](../../scenes/game/wasteland.gd) - Fixed parse errors, updated diagnostics
- [docs/godot-performance-monitors-reference.md](../godot-performance-monitors-reference.md) - NEW: Valid Performance constants
- [docs/experiments/ios-ghost-rendering-root-cause-solution.md](ios-ghost-rendering-root-cause-solution.md)
- [docs/experiments/ios-ghost-rendering-handoff.md](ios-ghost-rendering-handoff.md)

---

## ⚠️ CRITICAL FIX (2025-11-15 Afternoon)

### Parse Error Issue
The initial diagnostic implementation used **invalid Performance constants** that don't exist in Godot 4.5.1:
- `Performance.RENDER_2D_ITEMS_IN_FRAME` ❌
- `Performance.RENDER_2D_DRAW_CALLS_IN_FRAME` ❌

### Impact
- **wasteland.gd failed to parse** (ios.log lines 13-21)
- **Scene couldn't load** → Player never initialized → **0 HP bug**
- Game was completely broken

### Fix Applied
✅ Removed invalid Performance constants
✅ Added manual canvas item counting via `_count_canvas_items_recursive()`
✅ Added additional valid monitors (ORPHAN_NODE_COUNT, MEMORY_STATIC)
✅ Created reference doc: [godot-performance-monitors-reference.md](../godot-performance-monitors-reference.md)

**See:** [wasteland.gd:734-791](../../scenes/game/wasteland.gd#L734-L791) for updated implementation

---

## Summary of Changes

### Phase 1: Documentation Updates ✅

**Updated Files**:
1. `ios-ghost-rendering-root-cause-solution.md`:
   - Marked status as ❌ FAILED
   - Added test evidence section with ios.log timeline and screenshot analysis
   - Documented TWO separate bugs discovered
   - Added investigation plan for next steps

2. `ios-ghost-rendering-handoff.md`:
   - Updated executive summary to reflect failure
   - Documented that modulate.a pattern FAILED in testing
   - Added TWO BUGS DISCOVERED section

### Phase 2: Enhanced Diagnostic Logging ✅

**All changes in `wasteland.gd`**:

#### 1. Tween Lifecycle Monitoring

**Added Signal Connections** (lines 587-594):
```gdscript
# Track tween step completion
tween.step_finished.connect(func(idx: int):
    print("[TweenDebug] Step %d complete. Label modulate.a: %.3f" % [idx, level_up_label.modulate.a])
)

# Track tween loop completion (if any)
tween.loop_finished.connect(func(loop_count: int):
    print("[TweenDebug] Loop %d finished" % loop_count)
)
```

**Purpose**: Determine if Tween steps are executing even though `finished` signal doesn't fire.

**Expected Output** (if working correctly):
```
[TweenDebug] Tween created for level 2 label ID: 317978576556
[TweenDebug] Fade-in animation added (0.0 → 1.0, 0.3s)
[TweenDebug] Hold interval added (1.7s)
[TweenDebug] Fade-out animation added (1.0 → 0.0, 0.3s)
[TweenDebug] Tween.finished signal connected to cleanup callback
[TweenDebug] Step 0 complete. Label modulate.a: 1.000
[TweenDebug] Step 1 complete. Label modulate.a: 1.000
[TweenDebug] Step 2 complete. Label modulate.a: 0.000
[Wasteland] _on_level_up_tween_finished CALLED for level 2
```

**Diagnostic Questions Answered**:
- ✅ Do Tween steps execute at all?
- ✅ What is the actual modulate.a value at each step?
- ✅ Does the `finished` signal ever fire?
- ✅ If not, which step fails to complete?

#### 2. Real-Time Label State Monitoring

**Added `_process()` Function** (lines 749-768):
```gdscript
func _process(delta: float) -> void:
    """ENHANCED DIAGNOSTIC: Monitor active labels in real-time (2025-11-15)"""
    label_monitor_timer += delta

    if label_monitor_timer >= LABEL_MONITOR_INTERVAL:
        label_monitor_timer = 0.0

        # Check if we have any active labels
        if label_pool and label_pool.active_labels.size() > 0:
            print("[LabelMonitor] Active labels: ", label_pool.active_labels.size())
            for label in label_pool.active_labels:
                if is_instance_valid(label):
                    print("[LabelMonitor]   Label ID: %d, text: '%s', modulate.a: %.3f, visible: %s" % [
                        label.get_instance_id(),
                        label.text,
                        label.modulate.a,
                        label.visible
                    ])
```

**Purpose**: Poll active labels every second to see their current state, even if callbacks don't fire.

**Expected Output**:
```
[LabelMonitor] Active labels: 1
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 1.000, visible: true
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 0.850, visible: true
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 0.350, visible: true
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 0.000, visible: true
```

**Diagnostic Questions Answered**:
- ✅ Is modulate.a actually changing over time?
- ✅ Does it reach 0.0 eventually?
- ✅ How long does the label stay at modulate.a=0.0 before being cleaned up?
- ✅ Is the label still "visible=true" as expected?

#### 3. Metal Rendering Stats Logging

**Added `_log_metal_rendering_stats()` Function** (lines 709-728):
```gdscript
func _log_metal_rendering_stats(context: String) -> void:
    """ENHANCED DIAGNOSTIC: Log Metal rendering stats (2025-11-15)"""
    print("[MetalDebug] === Rendering Stats (%s) ===" % context)
    print("[MetalDebug]   Canvas items in frame: ",
          Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME))
    print("[MetalDebug]   Draw calls in frame: ",
          Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME))
    print("[MetalDebug]   Objects in frame: ",
          Performance.get_monitor(Performance.OBJECT_COUNT))
    print("[MetalDebug]   Nodes in tree: ",
          Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
    print("[MetalDebug]   FPS: %.1f" % Performance.get_monitor(Performance.TIME_FPS))
    print("[MetalDebug]   Frame time: %.2f ms" % (Performance.get_monitor(Performance.TIME_PROCESS) * 1000))
```

**Called at Key Moments**:
1. After level-up Tween starts
2. After Tween `finished` callback (if it fires)
3. After `_clear_all_level_up_labels()` during wave complete
4. After wave complete cleanup

**Expected Output**:
```
[MetalDebug] === Rendering Stats (after_level_up_tween_start) ===
[MetalDebug]   Canvas items in frame: 145
[MetalDebug]   Draw calls in frame: 23
[MetalDebug]   Objects in frame: 312
[MetalDebug]   Nodes in tree: 287
[MetalDebug]   FPS: 60.0
[MetalDebug]   Frame time: 16.67 ms
```

**Diagnostic Questions Answered**:
- ✅ Do canvas item counts decrease after cleanup?
- ✅ Do draw calls decrease after cleanup?
- ✅ Is FPS stable throughout the process?
- ✅ Are there frame time spikes during Tween or cleanup?

#### 4. Enhanced Cleanup Logging

**Added Before/After modulate.a Logging** (lines 649, 653):
```gdscript
print("[Wasteland]   Label modulate.a BEFORE cleanup: %.3f" % label.modulate.a)
label_pool.return_label(label)
print("[Wasteland]   Label modulate.a AFTER cleanup: %.3f" % label.modulate.a)
```

**Purpose**: Confirm that `return_label()` actually sets `modulate.a=0.0`.

---

## Expected Test Results

### If Tween Works But Rendering Fails

**Logs Will Show**:
```
[TweenDebug] Step 0 complete. Label modulate.a: 1.000
[TweenDebug] Step 1 complete. Label modulate.a: 1.000
[TweenDebug] Step 2 complete. Label modulate.a: 0.000
[Wasteland] _on_level_up_tween_finished CALLED
[Wasteland]   Label modulate.a BEFORE cleanup: 0.000
[Wasteland]   Label modulate.a AFTER cleanup: 0.000
[MetalDebug] === Rendering Stats (after_level_up_tween_finished) ===
[MetalDebug]   Canvas items in frame: 145  ← Should decrease
[MetalDebug]   Draw calls in frame: 23     ← Should decrease
```

**But screenshot shows**: Ghost "LEVEL 2!" still visible

**Conclusion**: Tween works, modulate.a=0.0 set correctly, but Metal ignores it

---

### If Tween Fails to Complete

**Logs Will Show**:
```
[TweenDebug] Step 0 complete. Label modulate.a: 1.000
[TweenDebug] Step 1 complete. Label modulate.a: 1.000
← MISSING Step 2 ←
← MISSING _on_level_up_tween_finished ←

[LabelMonitor] Active labels: 1
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 1.000, visible: true
← modulate.a stuck at 1.000 ←
```

**Conclusion**: Tween step 2 (fade-out) never executes, label stays at full alpha

---

### If Tween Steps Execute But Signal Doesn't Fire

**Logs Will Show**:
```
[TweenDebug] Step 0 complete. Label modulate.a: 1.000
[TweenDebug] Step 1 complete. Label modulate.a: 1.000
[TweenDebug] Step 2 complete. Label modulate.a: 0.000
← MISSING _on_level_up_tween_finished ←

[LabelMonitor] Active labels: 1
[LabelMonitor]   Label ID: 317978576556, text: 'LEVEL 2!', modulate.a: 0.000, visible: true
← Label at 0.0 but callback never fired ←
```

**Conclusion**: Tween executes but `finished` signal broken on iOS

**Workaround**: Use polling instead of signals

---

### If Everything Works Correctly (Unlikely)

**Logs Will Show**:
```
[TweenDebug] Step 2 complete. Label modulate.a: 0.000
[Wasteland] _on_level_up_tween_finished CALLED
[Wasteland]   Label modulate.a BEFORE cleanup: 0.000
[Wasteland]   Label modulate.a AFTER cleanup: 0.000
[IOSLabelPool] Returning label to pool
[LabelMonitor] Active labels: 0
```

**And screenshot shows**: No ghost rendering

**Conclusion**: Tween pattern works, previous test was anomaly

---

## Next Steps After iOS QA Test

### Scenario A: Tween Works, Rendering Fails

**Evidence Needed**:
- ✅ All Tween steps complete
- ✅ modulate.a reaches 0.0
- ✅ Callback fires
- ❌ Ghost rendering persists

**Next Tests** (in order):
1. Test `RenderingServer.force_sync()` after Tween
2. Test multi-frame await pattern (3-5 frames)
3. Test manual `queue_redraw()` on canvas layers
4. Test SubViewport isolation (Tier 3)

**Root Cause**: Metal texture atlas ignores alpha changes

---

### Scenario B: Tween Callback Never Fires

**Evidence Needed**:
- ✅ All Tween steps complete
- ✅ modulate.a reaches 0.0
- ❌ Callback never fires

**Next Tests**:
1. Replace signal with polling in `_process()`:
   ```gdscript
   # Check if tween is done manually
   if not tween.is_running() and label.modulate.a < 0.01:
       _on_level_up_tween_finished(label, level)
   ```
2. Test alternative cleanup trigger (Timer-based)

**Root Cause**: iOS Tween signal system broken

---

### Scenario C: Tween Steps Don't Complete

**Evidence Needed**:
- ✅ Step 0, Step 1 complete
- ❌ Step 2 never completes
- ❌ modulate.a stuck at 1.0

**Next Tests**:
1. Simplify Tween (remove interval, single fade-out)
2. Test manual property animation instead of Tween
3. Test different Tween modes (`TWEEN_PROCESS_PHYSICS` vs `TWEEN_PROCESS_IDLE`)

**Root Cause**: iOS Tween animation system broken

---

### Scenario D: Metal Shows High Canvas Item Count

**Evidence Needed**:
```
[MetalDebug] === Rendering Stats (after_wave_complete_cleanup) ===
[MetalDebug]   Canvas items in frame: 145  ← SAME as before cleanup
[MetalDebug]   Draw calls in frame: 23     ← SAME as before cleanup
```

**Next Tests**:
1. Call `RenderingServer.force_draw()` to rebuild draw list
2. Test viewport size change to force framebuffer reallocation
3. File Godot bug report with Performance monitor evidence

**Root Cause**: Metal renderer not updating draw list after modulate changes

---

## Research Prompts for External AI

**If Scenario A (Tween works, rendering fails)**:
```
In Godot 4.5.1 on iOS Metal, I'm experiencing persistent ghost rendering of Label nodes.
Evidence shows:
- Tween animations complete successfully (all steps execute)
- modulate.a reaches 0.0 correctly
- Callbacks fire as expected
- BUT Performance.RENDER_2D_ITEMS_IN_FRAME count doesn't decrease after cleanup
- Labels remain visually rendered despite modulate.a=0.0

This suggests the Metal renderer's draw list doesn't update when shader uniforms change.
Has anyone encountered this? Are there RenderingServer calls to force draw list rebuild on iOS?
```

**If Scenario B (Tween callbacks don't fire)**:
```
Godot 4.5.1 iOS: Tween.finished signal never fires despite animation completing.
Evidence:
- tween.step_finished signals fire for all steps
- Final step shows modulate.a reaching target value (0.0)
- BUT tween.finished signal never emits
- Works perfectly on desktop/Android

Is this a known iOS Tween signal bug? Should I poll tween.is_running() instead?
```

---

## Files Modified

**1. scenes/game/wasteland.gd**:
- Lines 29-31: Added label monitor timer variables
- Lines 583-620: Enhanced Tween lifecycle logging
- Lines 635: Added Metal stats after Tween start
- Lines 649-664: Enhanced cleanup logging with before/after modulate.a
- Lines 515, 522: Added Metal stats after wave complete cleanup
- Lines 709-728: Added `_log_metal_rendering_stats()` function
- Lines 749-768: Added `_process()` with real-time label monitoring

**2. docs/experiments/ios-ghost-rendering-root-cause-solution.md**:
- Lines 1-4: Updated status to FAILED
- Lines 8-60: Rewrote executive summary with test evidence
- Lines 63-113: Added test evidence section with ios.log timeline + screenshot
- Lines 649-701: Rewrote conclusion with investigation plan

**3. docs/experiments/ios-ghost-rendering-handoff.md**:
- Lines 1-5: Updated status to FAILED
- Lines 9-23: Rewrote executive summary with TWO BUGS DISCOVERED

---

## Success Metrics

After next iOS QA test, we should have:
1. ✅ **Clear evidence** of which component fails (Tween vs Rendering)
2. ✅ **Quantitative data** on Performance monitors (canvas items, draw calls)
3. ✅ **Timeline precision** (exact step where failure occurs)
4. ✅ **Actionable next steps** based on scenario matrix above

**This diagnostic data will enable focused Tier 2/3 testing instead of guessing.**
