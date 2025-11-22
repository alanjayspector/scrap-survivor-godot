# Next Session: Week 16 Mobile UI Standards Overhaul

**Last Updated**: 2025-11-22
**Current Branch**: `main`
**Current Phase**: Phase 2 (Typography Fixes)
**Status**: Phase 0-1 complete, ~9 hours remaining

---

## Quick Start

If continuing this work, say: **"continue with Week 16 Phase 2"**

---

## Week 16 Progress

**Goal**: Transform desktop-style UI into mobile-native experience (iOS HIG compliant)

**Total Time**: 16.5 hours estimated → **~9 hours remaining** (3.5 hours saved!)

### Completed Phases ✅

#### Phase 0: Pre-Work & Baseline (0.5h) ✅
- Visual regression infrastructure ([scripts/debug/visual_regression.gd](scripts/debug/visual_regression.gd))
- Analytics autoload stub ([scripts/autoload/analytics.gd](scripts/autoload/analytics.gd))
- Baseline screenshots (tests/visual_regression/baseline/)
- Branch: Using `main` (feature/week16-mobile-ui was abandoned)

#### Phase 1: UI Component Audit (1.5h) ✅
- **Created**: UI audit tool ([scripts/debug/ui_audit.gd](scripts/debug/ui_audit.gd))
- **Created**: Mobile UI spec ([docs/ui-standards/mobile-ui-spec.md](docs/ui-standards/mobile-ui-spec.md))
- **Generated**: Full audit report ([docs/ui-audit-report.md](docs/ui-audit-report.md))
- **Generated**: Phase 1 summary ([docs/week16-phase1-summary.md](docs/week16-phase1-summary.md))

**Audit Results**:
- ✅ **ALL buttons iOS HIG compliant** (0 violations, 100% pass rate)
- ✅ **8 of 9 screens perfect** (0 critical issues)
- 🚨 **1 screen needs fix**: character_selection.tscn (15 labels at 12pt)

#### Phase 3: Touch Targets (COMPLETE!) ✅
- **Skipped implementation** - ALL buttons already meet standards!
- 0 buttons < 44pt (iOS minimum)
- 0 buttons < 60pt (recommended)
- Button range: 60-200pt (excellent)
- **Time saved**: 3 hours

---

### Current Phase: Phase 2 (Typography Fixes)

**Status**: Ready to start
**Estimated Time**: 1 hour (down from 2.5h - minimal work needed)

#### Critical Fix Required 🚨
- **File**: [scenes/ui/character_selection.tscn](scenes/ui/character_selection.tscn)
- **Issue**: 15 stat labels at 12pt (below 13pt minimum)
- **Fix**: Increase font size from 12pt → 13pt
- **Labels affected**: "+5 Scavenging", "+20 Max Hp", "Aura: Collect", etc.

#### Optional Improvements ⚠️
- 16 labels at 13-16pt (below 17pt recommended for body text)
- Mostly secondary content (descriptions, captions, metadata)
- Can improve in Phase 2 or defer to polish

#### Implementation Steps
1. Open [scenes/ui/character_selection.tscn](scenes/ui/character_selection.tscn) in Godot
2. Find all stat labels (currently 12pt)
3. Increase to 13pt minimum
4. Re-run UI audit to verify (Debug Menu → Run UI Audit)
5. Commit: `fix: increase character_selection stat labels to 13pt minimum (iOS HIG)`

---

### Upcoming Phases

#### Phase 3.5: Mid-Week Validation Checkpoint (0.5h)
- Manual QA on iPhone 15 Pro Max
- Test on iPhone 8 simulator
- Verify improvements feel better than baseline
- **GO/NO-GO decision point**

#### Phase 4: Dialog & Modal Patterns (2h)
- Redesign confirmation dialogs (larger, mobile-native)
- Standardize modal presentation (full-screen overlays)
- Improve CharacterDetailsPanel sizing/spacing
- Add dismiss gestures (swipe down, tap outside)
- Progressive delete confirmation (prevent accidents)

#### Phase 5: Visual Feedback & Polish (2h)
- Loading indicators for scene transitions
- Improve color contrast (WCAG AA compliance)
- Accessibility settings (animations, haptics, sounds)
- Audio feedback coverage
- **Note**: Button animations & haptics already complete!

#### Phase 6: Spacing & Layout Optimization (1.5h)
- Apply mobile spacing scale (16-32pt margins)
- **ScreenContainer component** for safe area insets
- Test on iPhone 15 Pro Max (notch/Dynamic Island)
- Test on iPhone 8 (no notch)
- Verify responsive scaling

#### Phase 7: Combat HUD Mobile Optimization (2h)
- Audit Combat HUD (XP bar, health, timer, wave counter)
- Ensure HUD respects safe areas
- Optimize font sizes for mobile readability
- Verify HUD doesn't occlude gameplay
- Add touch-friendly pause button
- Test during actual combat

---

## Current Codebase State

### New Systems (Created This Session)
- **UI Audit Tool** ([scripts/debug/ui_audit.gd](scripts/debug/ui_audit.gd))
  - Automated measurement of fonts, buttons, spacing
  - Flags iOS HIG violations
  - Exports markdown reports
  - Accessible via Debug Menu

### Existing Systems (Already Working)
- **Theme System** ([themes/game_theme.tres](themes/game_theme.tres))
  - Primary/Secondary/Danger/Ghost button styles
  - Consistent styling across all screens

- **HapticManager** ([scripts/autoload/haptic_manager.gd](scripts/autoload/haptic_manager.gd))
  - Light/Medium/Heavy haptic patterns
  - iOS 26.1 compatible
  - Platform-aware (no-op on desktop)

- **ButtonAnimation** ([scripts/ui/components/button_animation.gd](scripts/ui/components/button_animation.gd))
  - 0.90 scale on press (10% reduction)
  - 50ms/100ms animations
  - Accessibility-aware

- **UIIcons** ([scripts/ui/theme/ui_icons.gd](scripts/ui/theme/ui_icons.gd))
  - 25 Kenney icons (CC0)
  - Located in themes/icons/game/

### Fixed This Session
- ✅ Visual regression viewport bug ([scripts/debug/visual_regression.gd:66](scripts/debug/visual_regression.gd#L66))
- ✅ HapticManager SaveManager dependency ([scripts/autoload/haptic_manager.gd:67](scripts/autoload/haptic_manager.gd#L67))

---

## Test Status

**Automated Tests**: ✅ 647/671 passing
**Manual QA**: Pending (after Phase 2 fixes)
**UI Audit**: Complete (see [docs/ui-audit-report.md](docs/ui-audit-report.md))

---

## Git Status

**Branch**: `main`
**Last Commits**:
- `e866409` - style: apply code quality cleanup for validator warnings
- `232f29f` - chore: add missing metadata and documentation files
- `dc8b840` - feat: add ButtonAnimation component with scale feedback
- `e6ae281` - refactor: implement HapticManager wrapper for iOS 26.1 compatibility

**Uncommitted Changes**:
- New: [scripts/debug/ui_audit.gd](scripts/debug/ui_audit.gd)
- New: [docs/ui-standards/mobile-ui-spec.md](docs/ui-standards/mobile-ui-spec.md)
- New: [docs/ui-audit-report.md](docs/ui-audit-report.md)
- New: [docs/week16-phase1-summary.md](docs/week16-phase1-summary.md)
- Modified: [scripts/debug/debug_menu.gd](scripts/debug/debug_menu.gd) (added UI audit)
- Modified: [scenes/debug/debug_menu.tscn](scenes/debug/debug_menu.tscn) (added UIAuditContainer)
- Modified: [scripts/debug/visual_regression.gd](scripts/debug/visual_regression.gd) (viewport fix)
- Modified: [scripts/autoload/haptic_manager.gd](scripts/autoload/haptic_manager.gd) (SaveManager fix)

**Ready to commit**: Phase 1 completion (audit infrastructure + fixes)

---

## Key Reference Documents

### Week 16 Planning
- **Master Plan**: [docs/migration/week16-implementation-plan.md](docs/migration/week16-implementation-plan.md)
- **Phase 1 Summary**: [docs/week16-phase1-summary.md](docs/week16-phase1-summary.md)
- **UI Audit Report**: [docs/ui-audit-report.md](docs/ui-audit-report.md)
- **Mobile UI Spec**: [docs/ui-standards/mobile-ui-spec.md](docs/ui-standards/mobile-ui-spec.md)

### Previous Work (Pre-Week 16)
- **Archived Session**: [.system/archive/NEXT_SESSION_2025-11-22_pre-week16-alignment.md](.system/archive/NEXT_SESSION_2025-11-22_pre-week16-alignment.md)
  - Theme System Phase 1 & 2
  - Icon System
  - Haptic Feedback System
  - ButtonAnimation Component
  - Code Quality Cleanup

### Research & Standards
- **iOS HIG**: iOS Human Interface Guidelines (external)
- **WCAG AA**: Web Content Accessibility Guidelines (external)
- **Brotato Reference**: [docs/brotato-reference.md](docs/brotato-reference.md)
- **Gemini Haptic Research**: [docs/gemini-haptic-research.md](docs/gemini-haptic-research.md)

---

## Success Criteria Tracking

### Week 16 Overall Goals
- [ ] All text ≥ 13pt minimum (**15 labels need fix**)
- [x] All buttons ≥ 44pt (iOS HIG) ✅ **100% compliant**
- [ ] All buttons have haptics (**most done, Combat HUD pending**)
- [ ] All buttons have press animations (**most done**)
- [ ] Safe areas respected (notch/home indicator) (**Phase 6**)
- [ ] Combat HUD mobile-optimized (**Phase 7**)
- [ ] "Feels like mobile app" QA passed (**Phase 3.5 checkpoint**)

### Current Phase Success Criteria (Phase 2)
- [ ] character_selection.tscn: 15 labels increased to 13pt minimum
- [ ] Re-run UI audit: 0 labels < 13pt
- [ ] Optional: Improve 16pt labels to 17pt
- [ ] Automated tests still passing (647/671)

---

## Quick Commands

### Run UI Audit
```bash
# In Godot:
# 1. Launch game (F5)
# 2. Open Debug Menu (QA button in Hub)
# 3. Click "Run UI Audit (All Screens)"
# 4. Check console for results
# 5. Click "Export Audit Report" → saves to docs/ui-audit-report.md
```

### Run Tests
```bash
python3 .system/validators/godot_test_runner.py
```

### Commit Phase 1 Work
```bash
git add .
git commit -m "feat(ui): add Week 16 Phase 1 UI audit infrastructure

- Add ui_audit.gd for automated UI measurements
- Create mobile-ui-spec.md with iOS HIG standards
- Generate ui-audit-report.md (15 issues found)
- Integrate audit into Debug Menu
- Fix visual_regression.gd viewport bug
- Fix haptic_manager.gd SaveManager dependency

Results: 100% button compliance, 1 screen needs typography fix

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Time Estimate Breakdown

**Original**: 16.5 hours total
**Completed**: 2 hours (Phase 0 + Phase 1)
**Saved**: 3.5 hours (Phase 2 reduced + Phase 3 complete)
**Remaining**: ~9 hours

| Phase | Original | Actual/Est | Status |
|-------|----------|------------|--------|
| Phase 0 | 0.5h | 0.5h | ✅ Complete |
| Phase 1 | 2.5h | 1.5h | ✅ Complete |
| Phase 2 | 2.5h | 1h | 🔨 Next |
| Phase 3 | 3h | 0h | ✅ Complete (skipped) |
| Phase 3.5 | 0.5h | 0.5h | ⏭️ Pending |
| Phase 4 | 2h | 2h | ⏭️ Pending |
| Phase 5 | 2h | 2h | ⏭️ Pending |
| Phase 6 | 1.5h | 1.5h | ⏭️ Pending |
| Phase 7 | 2h | 2h | ⏭️ Pending |
| **Total** | **16.5h** | **~11h** | **2h done, 9h remaining** |

---

**Session Date**: 2025-11-22
**Last Updated**: 2025-11-22 (Phase 1 complete, ready for Phase 2)

**Next Session Prompt**: "continue with Week 16 Phase 2"
