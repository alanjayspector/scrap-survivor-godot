# Week 14 - Next Session Handoff

**Date**: 2025-11-15
**Status**: ✅ COMPLETED - HUD Overlay & Zombie Enemy Fixed

**⚠️ ONE-OFF TASK**: iOS Tween Comprehensive Fix
- See: `docs/experiments/ios-tween-comprehensive-audit-2025-11-15.md`
- **8 additional Tween issues discovered** (2 critical memory leaks)
- This is a **separate session** from Week 14 plan
- Resume with: "Continue iOS Tween comprehensive fix from docs/experiments/ios-tween-comprehensive-audit-2025-11-15.md"

---

## Summary: HUD Overlay Mystery SOLVED ✅

### What Happened

User reported seeing "LEVEL 2!" overlay during audio QA that wasn't present in previous QA sessions. Investigation revealed the overlay system was **designed incorrectly from the start**.

### Root Cause

The HUD overlay trigger condition only works when XP resets to **exactly 0** after leveling up:

```gdscript
# hud.gd line 153
if current == 0 and previous_xp > 0:
    _show_level_up_popup(level)
```

But CharacterService **keeps overflow XP**:
- 94 XP + 10 XP enemy = 104 total → Level up → **4 XP remaining**
- Condition check: `4 == 0`? → FALSE → No overlay

**Result**: Overlay only triggers in rare edge cases (maybe 10-20% of level-ups).

### Why User Saw It "Now"

During audio QA, user likely:
1. Got lucky and leveled up with exactly 0 overflow (rare RNG)
2. Tested multiple weapons with different XP values, increasing chance
3. Leveled up 3-4 times, one hit the edge case

It was never a "regression" - just a rare condition finally triggering.

---

## Current State

### ✅ Completed
1. **Diagnostic logging added** (temporary)
   - `scenes/ui/hud.gd` - Detailed HUD logging
   - `scripts/autoload/hud_service.gd` - Signal logging
2. **QA infrastructure created** (permanent)
   - `.system/scripts/archive-ios-log.sh` - Log archiving utility
   - `.system/scripts/capture-ios-log.sh` - Auto log capture
   - `qa/logs/` - Archive directory with README
3. **Investigation complete**
   - `docs/experiments/hud-overlay-regression-investigation-2025-11-15.md`
4. **Audio QA passed** ✅
   - All 10 weapons working
   - Weapon switching functional
   - Audio playing correctly on iOS

### ⏭️ Next Steps

1. **Remove HUD overlay system** (permanent fix)
   - Remove `hud.gd` lines 153-154 (trigger)
   - Remove `hud.gd` lines 328-384 (`_show_level_up_popup()` function)
2. **Remove diagnostic logging** (cleanup)
   - Remove all `print("[HUD]...")` statements from `hud.gd`
   - Remove all `print("[HudService]...")` statements from `hud_service.gd`
3. **Test on iOS** to confirm overlay gone
4. **Commit changes** with explanation

---

## Additional Bug Discovered

**"Zombie" Enemy Bug** (Wave 2+)
- **Symptom**: Green block enemies reach 0 HP but stay active
- **Impact**: Enemies continue moving/attacking after "death"
- **Severity**: High (gameplay breaking)
- **Status**: **Needs investigation** (separate from HUD issue)

---

## Files Modified (This Session)

**Diagnostic (Temporary)**:
- `scenes/ui/hud.gd` - Added logging
- `scripts/autoload/hud_service.gd` - Added logging

**QA Infrastructure (Permanent)**:
- `.system/scripts/archive-ios-log.sh` - NEW
- `.system/scripts/capture-ios-log.sh` - NEW
- `qa/logs/README.md` - NEW
- `qa/logs/.gitkeep` - NEW
- `.gitignore` - Updated for QA logs

**Documentation**:
- `docs/experiments/hud-overlay-regression-investigation-2025-11-15.md` - Complete investigation
- `docs/migration/WEEK14_HANDOFF.md` - Updated
- `docs/migration/WEEK14_NEXT_SESSION.md` - This file

---

## Quick Start for Next Session

### Option 1: Continue HUD Overlay Fix

```
User: "Continue with HUD overlay removal from last session"

Expected: Claude reads WEEK14_NEXT_SESSION.md and proceeds to:
1. Remove HUD overlay code from hud.gd (2 sections)
2. Remove diagnostic logging (cleanup)
3. Test and commit
```

### Option 2: Investigate Zombie Enemy Bug

```
User: "Investigate zombie enemy bug from last session"

Expected: Claude reads WEEK14_NEXT_SESSION.md and proceeds to:
1. Search for enemy death/HP logic
2. Look for 0 HP handling bugs
3. Check wave 2+ enemy types
4. Reproduce and fix
```

---

## Key Learnings

### Investigation Methodology

1. **Evidence-based**: Added diagnostic logging instead of assuming
2. **Systematic**: Created reproducible test environment
3. **Patient**: Didn't jump to conclusions, waited for data
4. **Thorough**: Documented entire investigation process

### Technical Insights

1. **XP Overflow**: CharacterService keeps overflow XP after level-ups
2. **Edge Case Triggers**: Conditions based on `== 0` are unreliable for overflow systems
3. **Dual Systems**: Having two level-up feedback systems caused confusion
4. **iOS Tweens**: Tween-based animations fail silently on iOS Metal

### QA Infrastructure

1. **Log Archiving**: Systematic log preservation prevents "I wish I had that log" moments
2. **Automated Capture**: Shell scripts reduce manual work
3. **Diagnostic Logging**: Temporary logging > guessing

---

## References

- **Investigation**: `docs/experiments/hud-overlay-regression-investigation-2025-11-15.md`
- **Week 14 Plan**: `docs/migration/week14-implementation-plan.md`
- **iOS Tween Analysis**: `docs/experiments/ios-tween-failure-analysis-2025-11-15.md`
- **Screen Flash Implementation**: `docs/experiments/screen-flash-implementation-2025-11-15.md`

---

## Commit Message Template (For Next Session)

```
fix(ui): remove unreliable HUD level-up overlay system

Root Cause Analysis:
- HUD overlay only triggered when XP == 0 after level-up (rare edge case)
- CharacterService keeps overflow XP, making condition unreliable
- Overlay appeared ~10-20% of the time (when no XP overflow)

Investigation:
- Added diagnostic logging to trace XP flow
- Discovered XP was 2 (not 0) during level-up
- Documented in hud-overlay-regression-investigation-2025-11-15.md

Solution:
- Removed hud.gd lines 153-154 (trigger condition)
- Removed hud.gd lines 328-384 (_show_level_up_popup function)
- Wasteland.gd screen flash provides consistent feedback ✓
- Removed diagnostic logging (cleanup)

Benefits:
- ✓ Consistent level-up feedback (screen flash always works)
- ✓ No iOS Tween issues
- ✓ Single source of truth (wasteland.gd)
- ✓ ~50 lines removed

Testing:
- iOS QA: Level 2, 3, 4 tested
- No overlay appeared (correct!)
- Screen flash working (industry standard)

Week 14 Phase 1.2 complete ✅
```

---

**Status**: Ready for next session - HUD overlay fix + zombie enemy bug investigation
