# Mobile UX QA Fixes - Round 1

**Date**: 2025-01-11
**Status**: Plan Created, Ready for Implementation
**Context**: After manual QA on iOS device, user identified 3 critical UX issues

---

## Issues Identified (Manual QA)

1. **Font inconsistency** - Currency display (top right) looks different size/font than rest of UI
2. **LHS jarring** - HP (36pt), XP (22pt), Wave (28pt) all different sizes creates visual dissonance
3. **Joystick regression** - Not smooth like original implementation, feels choppy

---

## Expert Consultation

### Sr Mobile Game Designer Analysis

**Font Size Issue:**
> "You over-rotated on hierarchy. I said 'mobile-first sizing' but you created 5-6 different font sizes when mobile games typically use 2-3 MAX. Look at Brotato, Vampire Survivors, Magic Survival - they have:
> - ONE primary HUD font (all stats: HP, XP, Wave, Currency)
> - ONE larger focal point font (Timer)
> - ONE button font
>
> Visual consistency > aggressive hierarchy. Players need to scan the HUD quickly, and having every element a different size creates cognitive friction."

**Joystick Issue:**
> "Floating joystick is the right call, but smoothness is non-negotiable. The original had input lerping/smoothing. Check if the floating implementation removed or reduced the smoothing factor. Mobile joysticks need HEAVY smoothing (0.2-0.3 lerp factor) to feel good."

### Sr UI/UX Expert Analysis

**Visual Harmony:**
> "The current implementation breaks the Gestalt principle of similarity. When elements are grouped (HUD cluster on left, currency cluster on right), they should share visual properties. Having HP at 36pt, XP at 22pt, Wave at 28pt makes the user think they're unrelated elements."

**Recommendation:**
- Unified 28pt for all non-focal HUD elements
- Timer at 40pt (only exception - it's the pressure mechanic)
- Currency at 28pt (same as HUD - they're both reference info)
- This creates 2 visual groups: "HUD cluster" (28pt) + "Timer focal point" (40pt)

**Accessibility Note:**
> "28pt is still well above iOS HIG minimum (17pt body text). With 3px black outlines, it'll be perfectly readable on mobile. The outlines do more for readability than size differences."

---

## Implementation Plan

### Fix 1: Font Size Harmonization (2-Tier System)

**Goal**: Reduce from 5 font sizes to 2 for visual consistency

**Changes Needed:**

#### scenes/ui/hud.tscn
- **HPLabel**: 36pt → **28pt** (harmonize with HUD cluster)
- **XPLabel**: 22pt → **28pt** (harmonize with HUD cluster)
- **WaveLabel**: 28pt → **28pt** (already correct)
- **WaveTimerLabel**: 48pt → **40pt** (focal point, but less overwhelming)
- **ScrapLabel**: 20pt → **28pt** (harmonize with HUD cluster)
- **ComponentsLabel**: 20pt → **28pt** (harmonize with HUD cluster)
- **NanitesLabel**: 20pt → **28pt** (harmonize with HUD cluster)

#### scenes/game/wasteland.tscn
- **VictoryLabel**: 32pt → **32pt** (keep - screen header)
- **NextWaveButton**: 28pt → **28pt** (already correct)
- **GameOverLabel**: 32pt → **32pt** (keep - screen header)
- **RetryButton**: 28pt → **28pt** (already correct)
- **MainMenuButton**: 28pt → **28pt** (already correct)

#### scenes/ui/wave_complete_screen.tscn
- **VictoryLabel**: 32pt → **32pt** (keep - screen header)
- **NextWaveButton**: 28pt → **28pt** (already correct)

**Result**: 2 primary sizes (28pt HUD, 40pt timer) + 32pt headers + 56pt level-up

---

### Fix 2: Joystick Smoothness Investigation

**Goal**: Restore smooth movement feel from original joystick implementation

**Investigation Steps:**

1. **Find original joystick code** (pre-floating implementation)
   - Search git history for joystick changes
   - Identify commit: `8f978b7` (quick wins) and `0cfa40f` (floating)

2. **Compare implementations**
   - Check for `lerp()` or smoothing in original
   - Look for `delta` usage differences
   - Verify movement damping/interpolation

3. **Likely culprits:**
   - Missing `lerp()` on player velocity
   - Direct input application (no smoothing)
   - Changed delta multiplier
   - Frame-rate dependency introduced

**Files to check:**
- `scenes/ui/virtual_joystick.gd` (if exists)
- `scripts/components/player_controller.gd` (or equivalent)
- `scenes/entities/player.gd`

**Original smoothing pattern (likely):**
```gdscript
# Original (smooth)
velocity = velocity.lerp(input_direction * speed, 0.2)

# Current (might be choppy)
velocity = input_direction * speed  # No smoothing
```

**Fix approach:**
- Add back input smoothing/lerping
- Use 0.2-0.3 lerp factor for mobile feel
- Ensure delta is applied consistently

---

### Fix 3: Testing Protocol

**After font changes:**
1. Visual QA - Check HUD looks harmonious
2. Verify timer still prominent but not overwhelming
3. Confirm currency readable when shown between waves

**After joystick fix:**
1. Test smooth movement in all directions
2. Verify no jitter or stuttering
3. Check responsiveness (not too sluggish)

**Full regression test:**
1. Run automated tests (`python3 .system/validators/godot_test_runner.py`)
2. Manual device test (5-wave run minimum)
3. Verify all 3 issues resolved

---

## Files to Modify

### Font Harmonization:
- `scenes/ui/hud.tscn` (7 labels)

### Joystick Smoothness:
- TBD (investigation needed - likely player controller or joystick script)

---

## Success Criteria

**Font Consistency:**
- [ ] All HUD elements (HP, XP, Wave, Currency) are 28pt
- [ ] Timer is 40pt (focal point but not overwhelming)
- [ ] Visual harmony - no jarring size differences
- [ ] User confirms consistency improvement

**Joystick Smoothness:**
- [ ] Movement feels smooth and responsive
- [ ] No jitter or choppy movement
- [ ] Matches or exceeds original joystick feel
- [ ] User confirms smoothness improvement

**No Regressions:**
- [ ] All tests passing (437/461)
- [ ] Text outlines still present (3px black)
- [ ] HP percentage display working
- [ ] Animations working (HP pulse, timer pulse, level-up)
- [ ] Currency hiding during combat working

---

## Commit Strategy

**Single commit after all fixes:**
```
fix: mobile UX QA round 1 - font harmony + joystick smoothness

Addresses 3 issues from iOS device QA testing:

1. Font Harmonization (2-tier system)
   - Unified HUD cluster: 28pt (HP, XP, Wave, Currency)
   - Focal point: 40pt (Timer only)
   - Reduces from 5 font sizes to 2 for visual consistency
   - Follows Gestalt principle of similarity
   - Still exceeds iOS HIG minimum (17pt)

2. Joystick Smoothness
   - Restored input lerping/smoothing from original
   - [Details of fix based on investigation]
   - Feels responsive and smooth on mobile

3. Testing
   - All automated tests passing (437/461)
   - Manual QA on iOS device confirms improvements

Expert consultation: Sr Mobile Game Designer + Sr UI/UX Expert
Reference: docs/MOBILE-UX-QA-FIXES.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Notes

- Keep all existing mobile UX improvements (outlines, animations, polish)
- Only change font sizes and fix joystick
- Maintain test coverage (no regressions)
- User approval required before commit

---

## Related Documents

- [MOBILE-UX-OPTIMIZATION-PLAN.md](../MOBILE-UX-OPTIMIZATION-PLAN.md) - Original expert plan
- [week12-implementation-plan.md](migration/week12-implementation-plan.md) - Week 12 tracking
- [GODOT-MIGRATION-TIMELINE-UPDATED.md](migration/GODOT-MIGRATION-TIMELINE-UPDATED.md) - Timeline
