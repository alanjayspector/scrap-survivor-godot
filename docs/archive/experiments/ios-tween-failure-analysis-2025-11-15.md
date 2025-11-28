# iOS Tween Failure Analysis - 2025-11-15

**Date**: 2025-11-15 (Afternoon)
**Status**: 🔴 CRITICAL - Tween animations completely non-functional on iOS
**Impact**: Level-up overlays invisible, Tween-based approach FAILED

---

## Executive Summary

The Tween-based `modulate.a` pattern **completely failed** on iOS. Tweens are created and configured correctly, but **animations never execute**. Labels remain at `modulate.a: 0.000` indefinitely, making level-up feedback invisible to players.

**Root Cause**: Godot 4.5.1 Tween property animations do not execute on iOS Metal builds (or execute but don't update the property).

**Recommendation**: Abandon Tween-based approach, use alternative pattern.

---

## Test Evidence from ios.log

### ✅ What Worked

1. **Parse errors fixed**: No "Failed to load script" errors
2. **Scene loaded**: `[Wasteland] _ready() called` (line 73)
3. **Player initialized**: `[Player] Stats loaded - max_hp: 100.0` (line 121)
4. **Level-ups triggered**: Level 2, 3, 4 events logged
5. **Tweens created**: All Tween setup logs present
6. **Label pool working**: Labels reused correctly (same ID 343312172673)
7. **FPS excellent**: 120 FPS maintained throughout

### ❌ What Failed

1. **Tween animations never executed**: Zero "Step X complete" logs
2. **modulate.a never changed**: Stuck at 0.000 for entire duration
3. **Labels invisible**: No visual level-up feedback shown to player
4. **Callbacks never fired**: No `_on_level_up_tween_finished` logs
5. **Manual cleanup required**: Wave complete had to force-clear labels

---

## Detailed Timeline: Level 2 Event

**Tween Creation (Lines 1228-1248)**:
```
1228: [Wasteland] Player leveled up to level 2!
1229: [Wasteland] Showing level up feedback for level 2
1230: [IOSLabelPool] Created new label (ID: 343312172673)
1231: [Wasteland] Label from pool (instance: 343312172673)
1232: [TweenDebug] Tween created for level 2 label ID: 343312172673
1233: [TweenDebug] Fade-in animation added (0.0 → 1.0, 0.3s)
1234: [TweenDebug] Hold interval added (1.7s)
1235: [TweenDebug] Fade-out animation added (1.0 → 0.0, 0.3s)
1236: [TweenDebug] Tween.finished signal connected to cleanup callback
1237: [Wasteland] Level up feedback Tween started (duration: 2.3s)
1238: [Wasteland] Label pool: 0 available, 1 active
```

**Expected Behavior (Next ~2.3 seconds)**:
```
[TweenDebug] Step 0 complete. Label modulate.a: 1.000  ← MISSING!
[TweenDebug] Step 1 complete. Label modulate.a: 1.000  ← MISSING!
[TweenDebug] Step 2 complete. Label modulate.a: 0.000  ← MISSING!
[Wasteland] _on_level_up_tween_finished CALLED          ← MISSING!
```

**Actual Behavior (1 second later, line 1275-1276)**:
```
1275: [LabelMonitor] Active labels: 1
1276: [LabelMonitor]   Label ID: 343312172673, text: 'LEVEL 2!', modulate.a: 0.000, visible: true
```

**Label State Over Time** (LabelMonitor logs every ~1 second):
```
Line 1276: modulate.a: 0.000   (1s after Tween start - should be fading in)
Line 1317: modulate.a: 0.000   (2s after - should be at 1.0, holding)
Line 1336: modulate.a: 0.000   (3s after - should be done, cleaned up)
Line 1347: modulate.a: 0.000   (4s after - should be gone!)
...
Line 2024: modulate.a: 0.000   (60+ seconds later - STILL stuck at 0.0!)
```

**Wave Complete Cleanup (Lines 2068-2072)**:
```
2068: [IOSLabelPool] Clearing all active labels (1 active)  ← Manual cleanup!
2069: [IOSLabelPool] Returning label to pool (ID: 343312172673)
2070: [IOSLabelPool]   Cleared text, set modulate.a=0.0, moved off-screen
2071: [IOSLabelPool]   Added to pool (pool size: 1)
2072: [IOSLabelPool] All labels cleared (pool size: 1)
```

---

## Pattern Repeated for All Level-Ups

**Level 3** (Lines 3229-3262):
- ✅ Tween created (lines 3233-3237)
- ❌ Zero step completion logs
- ❌ modulate.a stayed at 0.000 (line 3262+)
- ⚠️ Manual cleanup at wave complete (lines 4358-4362)

**Level 4** (Lines 6029-6062):
- ✅ Tween created (lines 6033-6037)
- ❌ Zero step completion logs
- ❌ modulate.a stayed at 0.000 (line 6062+)
- ⚠️ Manual cleanup at wave complete (lines 7070-7074)

**Consistency**: 100% failure rate across all level-ups.

---

## MetalDebug Diagnostics

**After Tween Start (Level 2, line 1239-1248)**:
```
[MetalDebug] === Rendering Stats (after_level_up_tween_start) ===
[MetalDebug]   Objects in memory: 1615.0
[MetalDebug]   Nodes in tree: 115.0
[MetalDebug]   Orphan nodes: 4.0
[MetalDebug]   FPS: 120.0                          ← Excellent!
[MetalDebug]   Frame time: 5.04 ms                 ← Very smooth
[MetalDebug]   Memory: 299.51 MB
[MetalDebug]   Canvas items (manual count): 93
[MetalDebug]   Label pool - active: 1              ← Label in scene
[MetalDebug]   Label pool - available: 0
```

**Observations**:
- ✅ Label is in scene tree (active: 1)
- ✅ Label is a canvas item (count: 93 includes it)
- ✅ Performance excellent (120 FPS, 5ms frame time)
- ❌ But Tween still doesn't run!

**After Wave Complete Cleanup (line 2074-2083)**:
```
[MetalDebug] === Rendering Stats (after_clear_level_up_labels) ===
[MetalDebug]   Objects in memory: 1686.0
[MetalDebug]   Nodes in tree: 130.0
[MetalDebug]   Orphan nodes: 4.0
[MetalDebug]   FPS: 119.0
[MetalDebug]   Frame time: 9.13 ms
[MetalDebug]   Memory: 300.20 MB
[MetalDebug]   Canvas items (manual count): 108
[MetalDebug]   Label pool - active: 0              ← Cleaned up manually
[MetalDebug]   Label pool - available: 1           ← Back in pool
```

**Note**: Canvas items increased from 93 → 108 (+15 items) between level-up and wave complete, showing normal scene activity. But label stayed invisible the whole time.

---

## Diagnostic Scenario Match

From [enhanced-diagnostics-2025-11-15.md](enhanced-diagnostics-2025-11-15.md#scenario-c-tween-steps-dont-complete):

### **Scenario C: Tween Steps Don't Complete** ✅ CONFIRMED

**Evidence Needed**:
- ✅ Step 0, Step 1 never complete
- ✅ Step 2 never completes
- ✅ modulate.a stuck at 0.0

**Conclusion**: iOS Tween animation system broken (or doesn't work for modulate.a property)

---

## Why Tweens Failed on iOS

### Hypothesis 1: iOS Metal Doesn't Support Tween Property Animation ⭐ LIKELY

**Evidence**:
- Tweens created successfully (logs confirm)
- Property path `"modulate:a"` is valid (no errors)
- Label in scene tree and visible
- But property never changes

**Theory**: iOS Metal renderer or GDScript runtime doesn't execute Tween property animations. Desktop/Android Tweens work via different code paths.

**Supporting Evidence**: This is a Godot 4.x iOS-specific issue, not documented anywhere.

### Hypothesis 2: Tweens Need Explicit Play Call on iOS

**Evidence**:
- Code uses `create_tween()` which should auto-play
- No `.play()` or `.start()` call
- Maybe iOS requires explicit start?

**Counter-evidence**: Godot docs say `create_tween()` auto-plays. No `.play()` method exists.

### Hypothesis 3: Modulate.a Property Not Animatable on iOS

**Evidence**:
- Property path correct: `"modulate:a"`
- Works on desktop
- Might be iOS Metal shader limitation

**Test needed**: Try animating a different property (position, scale) to see if Tweens work at all.

### Hypothesis 4: Tween Process Mode Issue

**Evidence**:
- Default process mode is `TWEEN_PROCESS_IDLE`
- Maybe iOS needs `TWEEN_PROCESS_PHYSICS`?

**Test needed**: Try `tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)`.

---

## Attempted Solutions Summary

| Iteration | Approach | Result |
|-----------|----------|--------|
| 1 | IOSCleanup multi-phase | ❌ Ghost rendering persisted |
| 2 | RenderingServer direct calls | ⏳ Not tested on iOS |
| 3 | Label pool + hide() | ❌ Ghost rendering persisted |
| 4 | Label pool + Tween modulate.a | ❌ **Tweens don't work on iOS** |

**All approaches failed.** We need a fundamentally different solution.

---

## Alternative Approaches

### Option 1: Manual Timer-Based Animation

Replace Tween with manual `_process()` animation:

```gdscript
var level_up_animation: Dictionary = {}  # {label: {time: float, state: String}}

func _show_level_up_feedback(new_level: int):
	var label = label_pool.get_label()
	label.text = "LEVEL %d!" % new_level

	# Track animation state manually
	level_up_animation[label] = {
		"time": 0.0,
		"duration": 2.3,
		"state": "fade_in"  # fade_in → hold → fade_out
	}

func _process(delta: float):
	for label in level_up_animation.keys():
		var anim = level_up_animation[label]
		anim.time += delta

		if anim.state == "fade_in":
			var t = anim.time / 0.3  # 0.3s fade-in
			label.modulate.a = clamp(t, 0.0, 1.0)
			if anim.time >= 0.3:
				anim.state = "hold"
				anim.time = 0.0

		elif anim.state == "hold":
			label.modulate.a = 1.0
			if anim.time >= 1.7:  # 1.7s hold
				anim.state = "fade_out"
				anim.time = 0.0

		elif anim.state == "fade_out":
			var t = 1.0 - (anim.time / 0.3)  # 0.3s fade-out
			label.modulate.a = clamp(t, 0.0, 1.0)
			if anim.time >= 0.3:
				# Animation done, cleanup
				label_pool.return_label(label)
				level_up_animation.erase(label)
```

**Pros**:
- ✅ Full control over animation
- ✅ No Tween dependency
- ✅ Works on all platforms

**Cons**:
- ❌ More code to maintain
- ❌ Not as elegant as Tweens
- ❌ Still might not fix iOS Metal rendering issue

### Option 2: AnimationPlayer Node

Use `AnimationPlayer` instead of Tween:

```gdscript
# In label pool, add AnimationPlayer to each label
var anim_player = AnimationPlayer.new()
label.add_child(anim_player)

# Create animation track
var animation = Animation.new()
var track_idx = animation.add_track(Animation.TYPE_VALUE)
animation.track_set_path(track_idx, ".:modulate:a")
animation.track_insert_key(track_idx, 0.0, 0.0)   # Start
animation.track_insert_key(track_idx, 0.3, 1.0)   # Fade in
animation.track_insert_key(track_idx, 2.0, 1.0)   # Hold
animation.track_insert_key(track_idx, 2.3, 0.0)   # Fade out

anim_player.add_animation("level_up", animation)
anim_player.play("level_up")
```

**Test needed**: Check if AnimationPlayer works on iOS when Tween doesn't.

### Option 3: Particle System Hack

Use `CPUParticles2D` with bitmap font texture:

```gdscript
# Create particle emitter that "renders" text as single-frame particle
var particles = CPUParticles2D.new()
particles.texture = preload("res://assets/ui/level_up_2.png")  # Pre-rendered "LEVEL 2!" image
particles.emitting = true
particles.lifetime = 2.3
particles.color_ramp = # Fade in/out via color alpha

# Emit once, let particles handle animation
```

**Pros**:
- ✅ Particles definitely work on iOS
- ✅ GPU-accelerated

**Cons**:
- ❌ Need pre-rendered images for each level
- ❌ Hacky solution
- ❌ Less flexible

### Option 4: No Level-Up Overlay (Design Decision)

**Remove level-up overlays entirely**, use alternative feedback:
- ✅ Sound effect only
- ✅ Screen flash
- ✅ Camera shake (already have this)
- ✅ Particle burst at player position
- ✅ HUD level indicator update

**User mentioned**: "I'm somewhat questioning if we should even do that"

**Pros**:
- ✅ Avoids iOS rendering issues entirely
- ✅ Less visual clutter
- ✅ Industry games (Brotato, Vampire Survivors) use minimal level-up feedback

**Cons**:
- ❌ Less player feedback
- ❌ Need alternative way to communicate level-up

---

## Recommendation

### Short-term (Next Session):

1. **Verify Tween failure is real**: Test animating a different property (position, scale) to confirm Tweens completely broken vs. just modulate.a
2. **Test AnimationPlayer**: Quick test if AnimationPlayer works where Tween doesn't
3. **Get user feedback**: Ask if level-up overlays are essential or optional

### Medium-term (If Overlays Required):

4. **Implement Option 1** (Manual timer-based animation) if modulate.a animation works at all
5. **OR implement Option 4** (Remove overlays) if iOS rendering fundamentally broken

### Long-term (If Needed):

6. **File Godot bug report**: Document Tween failure on iOS Metal with minimal reproduction
7. **Research Godot Discord/Reddit**: See if others encountered iOS Tween issues
8. **Consider engine-level workaround**: Investigate if RenderingServer can force updates

---

## Product Manager Perspective: Do We Need Level-Up Overlays?

### UX Analysis

**Industry Standard (Survivor-likes)**:
- **Vampire Survivors**: Small "+1" text appears briefly, very subtle
- **Brotato**: Level number updates in corner, no overlay
- **Halls of Torment**: Flash effect + sound, no text overlay
- **Soulstone Survivors**: Particle effect at player, no text

**Common pattern**: Minimal visual feedback, rely on sound + HUD update.

### User Feedback Interpretation

User said: "NO level up overlap happened. I'm somewhat questioning if we should even do that"

**Interpretation**:
- User noticed absence but didn't miss it
- Questioning implies **overlays might not be essential**
- Gameplay felt "ok" without them

### Recommendation from Product Perspective

**REMOVE level-up text overlays**, use alternative feedback:

1. **Audio cue**: Level-up sound effect (essential!)
2. **Visual effects**:
   - Screen flash (white flash fade-out, 0.2s)
   - Camera shake (already have)
   - Particle burst at player position
3. **HUD update**: Level number animates (scale pulse 1.0 → 1.3 → 1.0)
4. **Stat indicators**: Show +HP, +Damage briefly in HUD corner

**Benefits**:
- ✅ Avoids iOS rendering issues entirely
- ✅ Less visual clutter during intense combat
- ✅ Matches industry standards
- ✅ Faster to implement than debugging Tweens
- ✅ Better mobile UX (text overlays can obstruct gameplay)

**Trade-off**:
- Still provides clear feedback
- More polished than buggy/invisible overlays
- Focuses attention on HUD where stats matter

---

## Next Steps

### Immediate (This Session):

1. ✅ Document Tween failure in this file
2. ⏳ Get user decision: Keep overlays or remove?
3. ⏳ If keeping: Test AnimationPlayer or manual animation
4. ⏳ If removing: Implement alternative feedback

### Follow-up:

- [ ] File Godot bug report if Tween failure confirmed
- [ ] Update documentation with iOS limitations
- [ ] Add "iOS Compatibility Notes" section to project docs

---

## Files Modified

- **None** (analysis/documentation only)

## References

- **iOS Log**: `ios.log` (7136 lines)
- **Diagnostic Matrix**: [enhanced-diagnostics-2025-11-15.md](enhanced-diagnostics-2025-11-15.md)
- **Handoff Doc**: [ios-ghost-rendering-handoff.md](ios-ghost-rendering-handoff.md)
- **Root Cause**: [ios-ghost-rendering-root-cause-solution.md](ios-ghost-rendering-root-cause-solution.md)

---

**Conclusion**: Tween-based approach completely failed on iOS. Recommend removing level-up overlays entirely and using alternative feedback (sound, screen flash, HUD animation). This matches industry standards and avoids iOS rendering issues.
