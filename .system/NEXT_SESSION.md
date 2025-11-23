# Next Session: Week 16 Phase 6 - QA Testing on Device

**Date**: 2025-11-23
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Current Phase**: Phase 6 - Safe Area Implementation (Code Complete, Awaiting Device QA)
**Status**: 🧪 **READY FOR QA** - Deploy to iPhone 15 Pro Max

---

## ✅ Phase 6 Implementation Complete

**Completed**: 2025-11-23
**Time Spent**: ~1.5h (as estimated)
**Status**: Code complete, all tests passing, ready for device validation

### What Was Built

**1. ScreenContainer Component** ✅
- Created [scripts/ui/components/screen_container.gd](../scripts/ui/components/screen_container.gd)
- Extends MarginContainer
- Auto-detects safe area insets via `DisplayServer.get_display_safe_area()`
- Applies margins for iOS notches, Dynamic Island, home indicator
- Responds to viewport resize events
- Zero-impact on desktop (returns early if not mobile)

**2. Applied to 3 Full-Screen Scenes** ✅
- ✅ [scenes/hub/scrapyard.tscn](../scenes/hub/scrapyard.tscn) - Hub screen
  - Updated [scripts/hub/scrapyard.gd](../scripts/hub/scrapyard.gd) node paths
- ✅ [scenes/ui/character_roster.tscn](../scenes/ui/character_roster.tscn) - Character selection
  - Updated [scripts/ui/character_roster.gd](../scripts/ui/character_roster.gd) node paths
- ✅ [scenes/ui/character_creation.tscn](../scenes/ui/character_creation.tscn) - Character creation
  - Updated [scripts/ui/character_creation.gd](../scripts/ui/character_creation.gd) node paths
  - Updated [scripts/tests/ui/character_creation_test.gd](../scripts/tests/ui/character_creation_test.gd) test paths

**3. Skipped 2 Modal/Overlay Scenes** ✅
- ⏭️ character_details_panel.tscn - Modal content (doesn't need safe areas)
- ⏭️ wave_complete_screen.tscn - Centered overlay (doesn't need safe areas)

### Architecture Pattern

**Background vs Content:**
```
Screen Root (Control)
  ├─ Background (ColorRect) - OUTSIDE ScreenContainer (full bleed)
  └─ ScreenContainer - INSIDE (safe area wrapper)
      ├─ TitleContainer
      ├─ ContentContainer
      └─ ButtonsContainer
```

**Why This Works:**
- Background extends under notches (visual continuity)
- Interactive content respects safe areas (no overlap with system UI)
- Desktop: ScreenContainer has zero margins (no-op)
- iOS: ScreenContainer applies safe area margins automatically

### Validation Results

**Scene Instantiation:** ✅ All 20 scenes pass
**Automated Tests:** ✅ 647/671 passing (24 skipped as expected)
**Validators:** ✅ All passing

---

## 🧪 Phase 6 QA - Device Testing Required

### QA Checklist (iPhone 15 Pro Max)

**Hub Screen (scrapyard.tscn):**
- [ ] Title "SCRAP SURVIVOR" not obscured by Dynamic Island
- [ ] Menu buttons (Play, Characters, Settings, Quit) not obscured by notch
- [ ] Menu buttons not overlapping home indicator area
- [ ] Background extends under notches (full bleed)

**Character Roster (character_roster.tscn):**
- [ ] "Your Survivors" title not obscured by Dynamic Island
- [ ] Bottom buttons (Create New, Back) not overlapping home indicator
- [ ] Character list scrolls correctly with safe area margins
- [ ] Background extends under notches

**Character Creation (character_creation.tscn):**
- [ ] "Create Your Survivor" title not obscured by Dynamic Island
- [ ] Bottom buttons (Cancel, Create & Play) not overlapping home indicator
- [ ] Name input field visible and accessible
- [ ] Character type cards visible and tappable

**Desktop Validation (optional but recommended):**
- [ ] All 3 screens look identical to before (zero visual change)
- [ ] ScreenContainer has zero margins on desktop

### Expected Behavior

**On iPhone 15 Pro Max:**
- Title content should have ~60px top margin (Dynamic Island clearance)
- Bottom buttons should have ~34px bottom margin (home indicator clearance)
- Side margins minimal (~0-10px, depends on safe area)
- **No UI elements should overlap system UI**

**On Desktop:**
- **No visual change** - ScreenContainer returns early if not mobile
- Margins should be 0px on all sides

### If QA Fails

**Common Issues:**
1. **UI still overlapping** → ScreenContainer not in scene tree or wrong parent
2. **Too much margin** → Safe area calculation incorrect
3. **Desktop has margins** → `OS.has_feature("mobile")` check failing

**Debug Steps:**
1. Add logging to ScreenContainer._apply_safe_area_insets()
2. Print safe_area values
3. Check that ScreenContainer is actually in the scene tree
4. Verify parent-child relationships in scene files

---

## 📋 Week 16 Progress - ~70% Complete

**Completed Phases:**
- ✅ **Phase 0** (Partial) - Infrastructure setup
- ⏭️ **Phase 1** (Skipped) - Audit done informally
- ✅ **Phase 2** (~90%) - Typography via Theme System
- ✅ **Phase 3** (~85%) - Button styles + animations
- 🟡 **Phase 4** (~60%) - Modal works (missing progressive confirm/undo toast)
- ✅ **Phase 5** (~80%) - Haptics + animations
- 🧪 **Phase 6** (100% code, 0% QA) - ScreenContainer (AWAITING DEVICE QA)

**Time Tracking:**
- Estimated: 1.5h (Phase 6)
- Actual: 1.5h (Phase 6 implementation)
- Total Week 16: ~18h spent (vs 16h planned through Phase 6)

---

## 🔮 After Phase 6 QA

**Phase 7: Combat HUD Mobile Optimization** (2h)
- Apply ScreenContainer to wasteland.tscn (combat screen)
- Safe area compliance for pause button, HP bar, XP bar
- Touch target validation (pause button ≥60×60px)
- Test during actual gameplay (10-minute playtest)

**Phase 8: Visual Identity & Delight** ⭐ **CRITICAL** (4-6h)
- **MANDATORY** for Week 16 completion
- Wasteland color palette (rust/yellow/red replacing purple/gray)
- Button texture overlays (metal plates, rivets, weathering)
- Icon prominence (24-32px, not 16px decorative)
- Typography impact (bolder headers, shadows, outlines)
- Delight layer (enhanced feedback, transitions, micro-interactions)
- Competitor parity validation ("10-Second Impression Test")

**Without Phase 8**: Mobile-native app, but generic looking
**With Phase 8**: Visually distinctive, thematically consistent, screenshot-worthy

---

## 🚀 Quick Start Prompt for Next Session

### If QA Passed:

```
Phase 6 QA passed on iPhone 15 Pro Max! Continue with Phase 7.

1. Read docs/migration/week16-implementation-plan.md (Phase 7 section)
2. Apply ScreenContainer to wasteland.tscn (combat HUD)
3. Update wasteland.gd script node paths
4. Test during 10-minute combat playtest
5. Validate pause button ≥60×60px touch target
6. Update NEXT_SESSION.md (Phase 8 next)
```

### If QA Failed:

```
Phase 6 QA failed on iPhone 15 Pro Max. Debug and fix.

Issue found: [USER WILL PROVIDE]

Debug steps:
1. Add logging to ScreenContainer._apply_safe_area_insets()
2. Print safe_area rect values
3. Check scene tree structure in failing screen
4. Verify ScreenContainer is applied correctly
5. Fix and redeploy
```

### If User Says "Continue from Last Session":

Phase 6 code is complete. Awaiting device QA feedback from user.

---

## 📁 Files Modified in This Session

**Created:**
- `scripts/ui/components/screen_container.gd` (new component)

**Modified Scenes:**
- `scenes/hub/scrapyard.tscn` (added ScreenContainer)
- `scenes/ui/character_roster.tscn` (added ScreenContainer)
- `scenes/ui/character_creation.tscn` (added ScreenContainer)

**Modified Scripts:**
- `scripts/hub/scrapyard.gd` (updated node paths)
- `scripts/ui/character_roster.gd` (updated node paths)
- `scripts/ui/character_creation.gd` (updated node paths + _setup_slot_usage_banner)

**Modified Tests:**
- `scripts/tests/ui/character_creation_test.gd` (updated node paths)

**Total Changes:**
- 1 new file
- 7 modified files
- 0 deleted files

---

## 📊 Current Test Status

```
✅ All 647/671 tests passing
✅ 0 failed, 24 skipped (expected)
✅ All 20 scenes instantiate successfully
✅ All validators passing
✅ Scene structure valid
✅ Component usage valid
```

**No regressions introduced by Phase 6 changes.**

---

## 🧭 Git Status

**Branch**: main
**Last Commit**: `27b0409` - docs: updated next_session
**Modified (not yet committed):**
- `.system/NEXT_SESSION.md` (this file - updated for Phase 6 complete)
- `scripts/ui/components/screen_container.gd` (new)
- `scenes/hub/scrapyard.tscn` (ScreenContainer added)
- `scenes/ui/character_roster.tscn` (ScreenContainer added)
- `scenes/ui/character_creation.tscn` (ScreenContainer added)
- `scripts/hub/scrapyard.gd` (node paths updated)
- `scripts/ui/character_roster.gd` (node paths updated)
- `scripts/ui/character_creation.gd` (node paths updated)
- `scripts/tests/ui/character_creation_test.gd` (node paths updated)

**Ready to commit after QA passes.**

---

## 🎯 Success Criteria for "Week 16 Complete"

**Code Complete** (Phases 0-8):
- ✅ Phases 0-5: ~80% complete (foundation done)
- 🧪 Phase 6: Code complete, awaiting QA ← **CURRENT**
- 📋 Phase 7: Pending (Combat HUD)
- 📋 Phase 8: Pending (Visual Identity) ← **CRITICAL, NON-OPTIONAL**

**Quality Gates:**
- ✅ All 647/671 tests passing
- [ ] Safe areas validated on iPhone 15 Pro Max (no overlap) ← **NEXT**
- [ ] Combat HUD validated during gameplay
- [ ] **"10-Second Impression Test" passed** (Phase 8):
  - [ ] Genre identifiable (roguelite/survivor)
  - [ ] Theme identifiable (wasteland/post-apocalyptic)
  - [ ] Looks professional (worth $10+)
  - [ ] Wasteland color palette visible (rust/yellow/red)
  - [ ] Buttons have character (metal plates, not generic rectangles)
  - [ ] Icons prominent (24-32px, thematic)
  - [ ] "Would I screenshot this?" = YES for all major screens
  - [ ] You're proud to show this to others

**Week 16 NOT complete until Phase 8 validation passes.** Visual identity is mandatory.

---

**Last Updated**: 2025-11-23
**Next Action**: Deploy to iPhone 15 Pro Max and run QA checklist above
**Estimated Time Remaining**: 0.5h (Phase 6 QA) + 2h (Phase 7) + 4-6h (Phase 8) = **6.5-8.5h**
**Quality Bar**: Mobile-native ergonomics + visually-distinctive aesthetics + competitor parity
