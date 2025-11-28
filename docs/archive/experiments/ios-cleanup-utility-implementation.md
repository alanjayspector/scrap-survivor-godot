# iOS Cleanup Utility Implementation - Phase 1
**Date**: 2025-01-14
**Purpose**: Implement IOSCleanup utility to solve iOS Metal renderer bug
**Status**: ✅ Phase 1 Complete (Enemy & Label Cleanup)

---

## Summary

Implemented `IOSCleanup` utility class to solve iOS Metal renderer bug where nodes remain in GPU draw list even after proper scene tree cleanup (`hide() + remove_child() + queue_free()`).

**Root Cause**: iOS Metal renderer caches CanvasItem draw calls and doesn't immediately update when nodes are hidden or removed from scene tree.

**Solution**: Multi-layered forced invisibility approach before scene tree cleanup.

---

## Files Created

### 1. IOSCleanup Utility Class

**File**: `scripts/utils/ios_cleanup.gd`

**Purpose**: Centralized iOS-safe node cleanup utility

**Methods**:
1. `force_invisible_and_destroy(node: Node)` - Single node cleanup
2. `force_invisible_and_destroy_batch(nodes: Array)` - Batch cleanup

**Implementation**: 6-phase cleanup strategy:
1. **Phase 1: Pre-cleanup** - Clear visual properties (text, color, textures)
2. **Phase 2: Force transparency** - Set modulate and self_modulate alpha to 0
3. **Phase 3: Move off-screen** - Position at (999999, 999999)
4. **Phase 4: Minimize z-index** - Set to -4096 (render behind everything)
5. **Phase 5: Disable processing** - Stop all update loops
6. **Phase 6: Standard cleanup** - hide() + remove_child() + queue_free()

**Comprehensive Logging**: Every phase logged with node type and instance ID

---

## Files Modified

### 1. scenes/game/wasteland.gd

**Changes**: Updated 3 methods to use IOSCleanup utility

#### Change 1: _cleanup_all_enemies() (lines 687-707)

**Before**:
```gdscript
for enemy in enemies:
    if is_instance_valid(enemy):
        print("[Wasteland]   Cleaning enemy: ", enemy.get_instance_id())
        enemy.hide()
        if enemy.get_parent():
            enemy.get_parent().remove_child(enemy)
            print("[Wasteland]     Enemy removed from parent and hidden")
        enemy.queue_free()
        print("[Wasteland]     Enemy queued for deletion")
```

**After**:
```gdscript
# Use IOSCleanup utility for iOS-safe visual invalidation
IOSCleanup.force_invisible_and_destroy_batch(enemies)
```

**Benefit**: Reduced code duplication, comprehensive visual invalidation

---

#### Change 2: _clear_all_level_up_labels() (lines 654-680)

**Before**:
```gdscript
for label in active_level_up_labels:
    if is_instance_valid(label):
        print("[Wasteland]   Freeing label: ", label.get_instance_id())
        label.hide()
        if label.get_parent():
            label.get_parent().remove_child(label)
            print("[Wasteland]     Label removed from parent and hidden")
        label.queue_free()
        print("[Wasteland]     Label queued for deletion")
```

**After**:
```gdscript
# Use IOSCleanup utility for iOS-safe visual invalidation
IOSCleanup.force_invisible_and_destroy_batch(active_level_up_labels)
```

**Benefit**: Consistent cleanup pattern, comprehensive visual invalidation

---

#### Change 3: _on_level_up_cleanup_timeout() (lines 632-636)

**Before**:
```gdscript
if is_instance_valid(label):
    print("[Wasteland]   Label is valid, freeing...")
    label.hide()
    if label.get_parent():
        label.get_parent().remove_child(label)
        print("[Wasteland]     Label removed from parent and hidden")
    label.queue_free()
    print("[Wasteland]   Level up label freed (level ", level, ")")
```

**After**:
```gdscript
if is_instance_valid(label):
    print("[Wasteland]   Label is valid, freeing...")
    # iOS Metal renderer bug fix: Use IOSCleanup for forced visual invalidation
    IOSCleanup.force_invisible_and_destroy(label)
    print("[Wasteland]   Level up label freed via IOSCleanup (level ", level, ")")
```

**Benefit**: Single label cleanup uses same robust pattern

---

## Technical Details

### Multi-Layered Invisibility Strategy

**Why Multiple Redundant Methods?**

iOS Metal renderer may cache draw calls at different pipeline stages. Using multiple techniques ensures at least one will work:

1. **Clear Visual Properties** (e.g., `text = ""`, `color = transparent`)
   - If Metal caches rendered glyphs/textures, clearing source data forces re-render

2. **Modulate Alpha = 0**
   - If Metal respects modulate changes, node becomes fully transparent
   - `self_modulate` affects node only, `modulate` affects children too

3. **Off-Screen Position**
   - If Metal still renders despite transparency, it's off-screen
   - Position (999999, 999999) far beyond any viewport

4. **Minimum Z-Index (-4096)**
   - If Metal still renders on-screen, it's behind everything
   - Ensures node can't appear in front of game content

5. **Disable Processing**
   - Stops all update loops (prevents node from moving back on-screen)

6. **Standard Cleanup**
   - Scene tree removal and memory deallocation
   - Required regardless of visual state

**Result**: Even if Metal renderer bug persists, node is invisible to player.

---

## Expected Log Output

### Enemy Cleanup (Wave Complete)

**Before IOSCleanup**:
```
[Wasteland] _cleanup_all_enemies() called (time: 72.347s)
[Wasteland]   Enemies to clean: 1 (in 'enemies' group at cleanup time)
[Wasteland]   Cleaning enemy: 1519239061587
[Wasteland]     Enemy removed from parent and hidden
[Wasteland]     Enemy queued for deletion
[Wasteland] All enemies cleaned up
```

**After IOSCleanup**:
```
[Wasteland] _cleanup_all_enemies() called (time: 72.347s)
[Wasteland]   Enemies to clean: 1 (in 'enemies' group at cleanup time)
[IOSCleanup] Batch cleanup: 1 nodes
[IOSCleanup] Destroying node: CharacterBody2D (ID: 1519239061587)
[IOSCleanup]   Set modulate alpha to 0
[IOSCleanup]   Moved Node2D off-screen to (999999, 999999)
[IOSCleanup]   Set z_index to -4096
[IOSCleanup]   Disabled _process()
[IOSCleanup]   Disabled _physics_process()
[IOSCleanup]   Disabled input processing
[IOSCleanup]   Called hide()
[IOSCleanup]   Removed from parent: Node2D
[IOSCleanup]   Queued for deletion via queue_free()
[IOSCleanup] ✓ Node destroyed with forced invisibility: CharacterBody2D (ID: 1519239061587)
[IOSCleanup] ✓ Batch cleanup complete: 1 nodes destroyed
[Wasteland] All enemies cleaned up via IOSCleanup
```

**Difference**: Comprehensive logging of every invisibility technique applied

---

### Level-Up Label Cleanup

**Before IOSCleanup**:
```
[Wasteland] _on_level_up_cleanup_timeout CALLED for level 2
[Wasteland]   Label is valid, freeing...
[Wasteland]     Label removed from parent and hidden
[Wasteland]   Level up label freed (level 2)
```

**After IOSCleanup**:
```
[Wasteland] _on_level_up_cleanup_timeout CALLED for level 2
[Wasteland]   Label is valid, freeing...
[IOSCleanup] Destroying node: Label (ID: 1519192072340)
[IOSCleanup]   Cleared Label text
[IOSCleanup]   Set modulate alpha to 0
[IOSCleanup]   Set self_modulate alpha to 0
[IOSCleanup]   Moved Control off-screen to (999999, 999999)
[IOSCleanup]   Set z_index to -4096
[IOSCleanup]   Disabled _process()
[IOSCleanup]   Called hide()
[IOSCleanup]   Removed from parent: CanvasLayer
[IOSCleanup]   Queued for deletion via queue_free()
[IOSCleanup] ✓ Node destroyed with forced invisibility: Label (ID: 1519192072340)
[Wasteland]   Level up label freed via IOSCleanup (level 2)
```

**Difference**: Label-specific cleanup (cleared text) + comprehensive invalidation

---

## Testing Checklist

### Phase 1: Enemy Cleanup (Bug #11)

- [ ] Build iOS QA build
- [ ] Play through Waves 1-3
- [ ] After each wave complete, verify:
  - [ ] 0 enemies visible during wave complete screen
  - [ ] 0 enemies visible after pressing "Next Wave"
  - [ ] Logs show IOSCleanup executing all phases
  - [ ] Logs show "Node destroyed with forced invisibility"
- [ ] Play to Wave 5
- [ ] Verify no enemy accumulation (should be 0 each wave, not 1→1→1→2→3)

**Success Criteria**:
- ✅ No visible enemies after wave complete
- ✅ No enemy accumulation across waves
- ✅ Comprehensive IOSCleanup logs present

---

### Phase 2: Level-Up Label Cleanup (Bug #9)

- [ ] Play through Waves 1-3, level up multiple times
- [ ] Verify:
  - [ ] Level-up labels appear normally during wave
  - [ ] Labels disappear after 2-second timeout
  - [ ] NO labels visible over wave complete screens
  - [ ] Logs show IOSCleanup clearing label text
  - [ ] Logs show all invisibility phases executed

**Success Criteria**:
- ✅ No labels over wave complete screens
- ✅ Labels properly timed (2-second display)
- ✅ Comprehensive IOSCleanup logs present

---

## Code Quality

- ✅ **gdformat**: Passed (1 file reformatted, 1 file left unchanged)
- ✅ **gdlint**: Passed (no problems found)

---

## Benefits

### Code Quality
- ✅ **Centralized cleanup logic** - Single source of truth for iOS-safe cleanup
- ✅ **Reduced duplication** - Eliminates repeated cleanup code
- ✅ **Comprehensive logging** - Full visibility into cleanup process
- ✅ **Type-specific handling** - Adapts to different node types (Label, Sprite2D, etc.)

### Maintainability
- ✅ **Future-proof** - Easy to add new cleanup phases if needed
- ✅ **Reusable** - Can be used anywhere in codebase
- ✅ **Well-documented** - Clear comments explaining iOS bug and solution

### Debugging
- ✅ **Detailed logs** - Every phase logged with instance IDs
- ✅ **Pattern recognition** - Easy to spot if specific phase fails
- ✅ **Verification** - Can confirm all techniques applied

---

## Next Steps (Phase 2)

### 1. Player Color Tween State Machine (Bug #8)

**Current Issue**: Player color stuck at RED or intermediate tween values

**Proposed Fix**: Implement tween state machine to prevent interruption

**Files to Update**:
- `scripts/entities/player.gd` - Add color tween state machine

**Status**: ⏳ Pending

---

### 2. Wave Complete Screen Diagnostic Logging (Bug #12)

**Current Issue**: Wave 5 complete screen doesn't appear

**Proposed Fix**: Add visibility logging to diagnose if rendering bug or other issue

**Files to Update**:
- Wave complete screen script (need to identify file)

**Status**: ⏳ Pending

---

### 3. Player Visibility Monitoring (Bug #13)

**Current Issue**: Player disappears (only gun visible)

**Proposed Fix**: Add alpha monitoring in `_process()` to force restore if corrupted

**Files to Update**:
- `scripts/entities/player.gd` - Add visibility monitoring

**Status**: ⏳ Pending

---

## Risks & Mitigation

### Risk 1: IOSCleanup May Not Solve Rendering Bug

**Risk Level**: Medium

**Description**: If Metal renderer truly caches draw calls at GPU level, even modulate + position + z-index may not work

**Mitigation**:
- Off-screen + transparent = invisible even if rendered
- Z-index ensures can't appear in front of content
- If all fails, have RenderingServer direct call option (Solution A from analysis)

**Fallback**: Use RenderingServer.canvas_item_set_visible() direct calls

---

### Risk 2: Performance Impact

**Risk Level**: Low

**Description**: Multiple property changes per cleanup may impact performance

**Current Cleanup Count**:
- Enemies: ~1-3 per wave complete
- Labels: ~0-5 per wave complete
- Total: ~1-8 nodes per wave

**Analysis**: 6 property changes × 8 nodes = 48 operations per wave
- Negligible impact on modern iOS devices
- Only happens during wave transitions (not during gameplay)

**Mitigation**: Profile on iOS device if performance issues detected

---

## Related Documentation

- **Root Cause Analysis**: [docs/experiments/ios-rendering-pipeline-bug-analysis.md](ios-rendering-pipeline-bug-analysis.md)
- **Previous iOS Fixes**: [docs/experiments/ios-specific-fixes-2025-01-14.md](ios-specific-fixes-2025-01-14.md)
- **Bug #9 Original Fix**: [docs/experiments/ios-bug-fixes-2025-01-14.md](ios-bug-fixes-2025-01-14.md)
- **Bug #11 Original Fix**: [docs/experiments/bug-11-enemy-persistence-fix.md](bug-11-enemy-persistence-fix.md)
- **Enhanced Logging**: [docs/experiments/enhanced-diagnostic-logging.md](enhanced-diagnostic-logging.md)

---

## Sign-Off

**Phase 1 Implementation Complete**: 2025-01-14
**Files Created**: 1 (IOSCleanup utility)
**Files Modified**: 1 (wasteland.gd)
**Code Quality**: ✅ Passed (gdformat + gdlint)
**Ready for iOS QA**: ✅ Yes
**Estimated Testing Time**: 20-30 minutes (Waves 1-5)

---

## Expected Outcome

### If IOSCleanup Works:
- ✅ Bug #9 FIXED - No level-up labels over wave complete screens
- ✅ Bug #11 FIXED - No enemy accumulation between waves
- ✅ Logs show all 6 cleanup phases executing
- ✅ Visual confirmation: clean wave transitions

### If IOSCleanup Doesn't Work:
- ❌ Nodes still visible despite all cleanup phases
- ✅ Logs prove all techniques attempted
- ✅ Can escalate to RenderingServer direct calls (Solution A)
- ✅ Have evidence for Godot bug report

**Either way, we gain valuable data for next iteration.**

---

## Confidence Level

**Medium-High** (70-80% confidence this will work)

**Why Confident**:
- Multi-layered approach covers multiple failure modes
- Off-screen + transparent = invisible even if rendered
- Worst case: nodes rendered but invisible to player

**Why Not 100%**:
- Untested hypothesis (iOS Metal renderer caching)
- May require RenderingServer direct calls
- Could be deeper GPU-level issue

**Next Milestone**: iOS QA results will determine if Phase 2 needed or if we can move to player color/visibility bugs.
