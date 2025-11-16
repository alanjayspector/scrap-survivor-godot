# iOS Tween Fixes - QA Testing Guide
**Date**: 2025-11-15
**Commit**: iOS Tween comprehensive fix
**Related**: docs/experiments/ios-tween-comprehensive-audit-2025-11-15.md

---

## Overview

This document provides QA testing instructions for the comprehensive iOS Tween fixes that address 8 issues related to Tween animations not working on iOS Metal renderer.

**Summary**: All Tween-based animations have been replaced with iOS-compatible alternatives:
- **Memory leaks**: Fixed with immediate cleanup
- **Visual bugs**: Fixed with manual timer-based animations
- **Cosmetic issues**: Disabled (functionality preserved)

---

## Fixed Issues Summary

### 🔴 CRITICAL - Memory Leaks (MUST TEST)

#### 1. Drop Pickup Cleanup ✅ FIXED
**File**: `scripts/entities/drop_pickup.gd`
**Issue**: Drop pickups never removed from scene (memory leak)
**Fix**: Immediate `queue_free()` instead of Tween callback
**Impact**: Prevents memory leaks and eventual crashes

#### 2. Character Panel Cleanup ✅ FIXED
**File**: `scripts/ui/character_selection.gd`
**Issue**: Detail panels never freed from memory
**Fix**: Immediate `queue_free()` instead of Tween callback
**Impact**: Prevents memory leaks with repeated character browsing

### 🟡 MEDIUM - Visual Bugs (SHOULD TEST)

#### 3. Player Damage Flash ✅ FIXED
**File**: `scripts/entities/player.gd`
**Issue**: Player visual stuck RED after taking damage
**Fix**: Manual timer-based restoration (0.2s delay)
**Impact**: Player visual correctly flashes RED → returns to original color

#### 4. HUD Animations ✅ FIXED
**File**: `scenes/ui/hud.gd`
**Issue**: Missing visual feedback on iOS
**Fix**: Disabled cosmetic animations (wave label, bar flash, label pulse)
**Impact**: Cleaner HUD (no distracting animations), same functionality

### 🟢 LOW - Cosmetic Only (OPTIONAL TEST)

#### 5. Camera Shake ✅ FIXED
**File**: `scenes/game/wasteland.gd`
**Issue**: Camera shake doesn't work on iOS
**Fix**: Disabled (screen flash still works)
**Impact**: No camera shake on level-up (cosmetic only)

#### 6. Aura Pulse ✅ FIXED
**File**: `scripts/components/aura_visual.gd`
**Issue**: Aura ring doesn't pulse on iOS
**Fix**: Static opacity (0.5) instead of pulsing
**Impact**: Aura still functions, just doesn't pulse

#### 7. Drop Pickup Idle Animations ✅ FIXED
**File**: `scripts/entities/drop_pickup.gd`
**Issue**: Drops don't bob/pulse/rotate on iOS
**Fix**: Disabled idle animations
**Impact**: Pickups still functional, just static

#### 8. Character Card Hover ✅ FIXED
**File**: `scripts/ui/character_selection.gd`
**Issue**: Cards don't scale on tap
**Fix**: Disabled tap animations
**Impact**: Cards still selectable, just no animation

---

## Manual QA Testing Checklist

### Pre-Testing Setup
- [ ] Build and deploy to iOS device
- [ ] Enable console logging for diagnostic output
- [ ] Monitor device memory usage (Settings → General → iPhone Storage)

---

### Test 1: Drop Pickup Memory Leak (CRITICAL)
**Priority**: 🔴 CRITICAL
**Expected Time**: 5 minutes

**Steps**:
1. Start a new game on iOS device
2. Play through wave 1-3 (collect many drops)
3. Monitor console logs for drop pickup messages
4. Check device memory after collecting 50+ drops

**Expected Behavior**:
- ✅ Console shows: `[DropPickup] Calling queue_free() for immediate cleanup`
- ✅ No accumulation of invisible drop pickups in scene tree
- ✅ Memory usage stays stable (no gradual increase)

**Diagnostic Logs to Watch**:
```
[DropPickup] collect() ENTRY
[DropPickup]   Emitting collected signal (scrap, 1)
[DropPickup]   Calling queue_free() for immediate cleanup
[DropPickup] collect() EXIT (immediate cleanup)
```

**Failure Signs**:
- ❌ Memory usage increases over time
- ❌ Scene tree shows orphaned DropPickup nodes
- ❌ Console shows old Tween animation messages

---

### Test 2: Character Panel Memory Leak (CRITICAL)
**Priority**: 🔴 CRITICAL
**Expected Time**: 3 minutes

**Steps**:
1. Go to character selection screen
2. Tap 5+ different character cards to open detail panels
3. Dismiss each panel (tap backdrop or X button)
4. Monitor console logs for panel cleanup messages

**Expected Behavior**:
- ✅ Console shows: `[CharacterSelection] Dismissing detail panel (iOS-compatible immediate cleanup)`
- ✅ Console shows: `[CharacterSelection]   Panel queued for deletion`
- ✅ No accumulation of detail panels in scene tree

**Diagnostic Logs to Watch**:
```
[CharacterSelection] Panel entrance: iOS-compatible immediate display (no animation)
[CharacterSelection] Dismissing detail panel (iOS-compatible immediate cleanup)
[CharacterSelection]   Panel instance ID: 12345
[CharacterSelection]   Panel queued for deletion
[CharacterSelection]   current_detail_panel cleared
```

**Failure Signs**:
- ❌ Scene tree shows multiple DetailPanelRoot nodes
- ❌ Memory usage increases with repeated panel opens
- ❌ Console shows old Tween animation messages

---

### Test 3: Player Damage Flash (MEDIUM)
**Priority**: 🟡 MEDIUM
**Expected Time**: 2 minutes

**Steps**:
1. Start a new game on iOS device
2. Take damage from enemy attacks (get hit 5+ times)
3. Observe player visual color after each hit
4. Monitor console logs for damage flash messages

**Expected Behavior**:
- ✅ Player flashes RED immediately when hit
- ✅ Player returns to original color after ~0.2 seconds
- ✅ No stuck RED visual
- ✅ Console shows: `[Player] _flash_damage() - iOS-compatible immediate color change`
- ✅ Console shows: `[Player] _restore_visual_color() - restoring to: ...`

**Diagnostic Logs to Watch**:
```
[Player] _flash_damage() - iOS-compatible immediate color change
[Player]   Setting ColorRect to RED (manual timer will restore)
[Player] _restore_visual_color() - restoring to: (0.2, 0.6, 1, 1)
[Player]   ColorRect color restored to: (0.2, 0.6, 1, 1)
```

**Failure Signs**:
- ❌ Player stays RED after damage
- ❌ No color change on damage
- ❌ Console shows old Tween messages

---

### Test 4: HUD Cosmetic Animations (MEDIUM)
**Priority**: 🟡 MEDIUM
**Expected Time**: 2 minutes

**Steps**:
1. Start a new game on iOS device
2. Complete wave 1 (observe wave label change)
3. Collect currency (observe currency labels)
4. Take damage (observe HP bar)

**Expected Behavior**:
- ✅ Wave label updates without scale animation
- ✅ Currency labels update without pulse animation
- ✅ HP bar updates without flash animation
- ✅ All displays function correctly (just without animations)

**Note**: HP/timer warning pulses are still present (they use Tween but won't work on iOS - acceptable known limitation).

**Failure Signs**:
- ❌ Wave number doesn't update
- ❌ Currency doesn't update
- ❌ HP bar doesn't update

---

### Test 5: Cosmetic Features (LOW)
**Priority**: 🟢 LOW
**Expected Time**: 3 minutes

**Steps**:
1. Start game and level up (observe lack of camera shake)
2. Equip aura ability (observe static aura ring)
3. Collect drops (observe static pickups)
4. Select character cards (observe no tap animation)

**Expected Behavior**:
- ✅ Level-up shows screen flash (no camera shake)
- ✅ Aura ring is visible but static (no pulsing)
- ✅ Drop pickups are visible but static (no bob/rotate)
- ✅ Character cards can be tapped (no scale animation)

**Note**: These are cosmetic only - all functionality works.

---

## Performance Metrics to Monitor

### Memory Usage (iOS Settings → General → iPhone Storage)
- **Baseline** (game start): ~XXX MB
- **After 5 waves** (many drops collected): Should be < Baseline + 50 MB
- **After 10 character panel opens/closes**: Should be < Baseline + 20 MB

### Frame Rate
- **Target**: 60 FPS on iPhone 12+
- **Acceptable**: 30+ FPS on older devices
- **No stuttering** when collecting drops or opening panels

### Battery Drain
- **Expected**: Similar to pre-fix version
- **No excessive heat** from orphaned animations

---

## Known Limitations (After Fix)

The following visual effects won't work on iOS (cosmetic only - all game functionality works):
- ❌ Drop pickup idle animations (bob, pulse, rotate)
- ❌ Camera shake on level-up
- ❌ Aura pulse animation
- ❌ Character card hover/tap animations
- ❌ HUD cosmetic pulses/flashes
- ❌ HP/timer warning pulses (important - may need manual implementation later)

**All game functionality works correctly** - only visual polish is affected.

---

## Regression Testing

### Desktop Testing (Quick Validation)
Before deploying to iOS, test on desktop to catch obvious issues:

```bash
# Run game on desktop
godot4 --path . scenes/game/wasteland.tscn

# Test sequence:
# 1. Collect 20+ drops → verify immediate cleanup
# 2. Browse 5+ characters → verify panel cleanup
# 3. Take damage 5+ times → verify color restoration
# 4. Complete wave 1-3 → verify no crashes
```

### iOS Device Testing (Critical Validation)
1. **Deploy to TestFlight or direct device**
2. **Run all manual tests above**
3. **Monitor device console via Xcode**
4. **Check memory usage via Instruments**

---

## Troubleshooting

### Issue: Drop pickups still accumulating
**Check**:
- Console logs show "immediate cleanup" messages
- No Tween-related error messages
- Godot version is 4.x (Tweens changed in 4.0)

### Issue: Player stuck RED after damage
**Check**:
- Console shows "iOS-compatible immediate color change"
- Console shows "_restore_visual_color()" after ~0.2s
- damage_flash_duration is 0.2 (not 0.1)

### Issue: Character panels not cleaning up
**Check**:
- Console shows "Panel queued for deletion"
- No Tween-related error messages
- current_detail_panel is set to null

---

## Success Criteria

**Pass if ALL of the following**:
- ✅ No memory leaks after 10 minutes of gameplay
- ✅ No visual bugs (stuck colors, missing panels)
- ✅ All game functionality works (drops collect, characters select, damage works)
- ✅ No console errors related to Tweens
- ✅ Frame rate is stable (no stuttering)

**Known acceptable limitations**:
- ℹ️ Some cosmetic animations disabled (expected)
- ℹ️ HP/timer warnings don't pulse (acceptable, low priority)

---

## References

- **Audit Document**: `docs/experiments/ios-tween-comprehensive-audit-2025-11-15.md`
- **Root Cause Analysis**: `docs/experiments/ios-tween-failure-analysis-2025-11-15.md`
- **Previous Fixes**:
  - Commit `b2b93d0`: HUD overlay fix
  - Commit `5126e2a`: Zombie enemy fix

---

**QA Sign-off**:
- [ ] Critical tests passed (Issues #1-2)
- [ ] Medium tests passed (Issues #3-4)
- [ ] Low tests reviewed (Issues #5-8)
- [ ] No regressions on desktop
- [ ] No regressions on iOS
- [ ] Performance acceptable

**Tester**: _________________
**Date**: _________________
**Device**: _________________
**iOS Version**: _________________
