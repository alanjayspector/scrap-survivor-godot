# Next Session: Week 16 Phase 6 - ScreenContainer for Safe Areas

**Date**: 2025-11-23
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Current Phase**: Phase 6 - Spacing & Layout Optimization (Safe Areas)
**Status**: 📋 **READY TO START** - Phase 6

---

## ✅ What's Complete

### Character Details Polish - COMPLETE ✅
- **QA Passes**: 10-21 (12 total passes, 11 commits)
- **Major Achievements**:
  - Modal visibility fixes (Parent-First Protocol violations)
  - Modal centering fixes (manual calculation, order-of-operations)
  - Modal sizing for prominence (300px tall, 90% width, 140×64px buttons)
  - Professional mobile game quality achieved
- **Archived**: `.system/archive/NEXT_SESSION_2025-11-23_week16-character-details-complete.md`

### Week 16 Progress - ~65% Complete

**Completed Phases:**
- ✅ **Phase 0** (Partial) - Infrastructure setup (visual regression skipped)
- ⏭️ **Phase 1** (Skipped) - Audit done informally during Theme System
- ✅ **Phase 2** (~90%) - Typography via Theme System (Dynamic Type not implemented)
- ✅ **Phase 3** (~85%) - Button styles + animations (touch target verification needed)
- 🟡 **Phase 4** (~60%) - Modal works (missing progressive confirm/undo toast)
- ✅ **Phase 5** (~80%) - Haptics + animations (loading/accessibility gaps)

**Unplanned Work Completed:**
- ✅ Theme System (4h) - game_theme.tres, button styles PRIMARY/SECONDARY/DANGER/GHOST
- ✅ Haptic System (2h) - HapticManager wrapper, iOS 26.1 compatible
- ✅ ButtonAnimation (1.5h) - 0.90 scale, 50ms, integrated into 4 screens
- ✅ Character Details (6h) - 21 QA passes for modal polish

**Total Time Spent**: ~16.5h (vs 16h planned for Phases 0-7)

---

## 🎯 Phase 6: ScreenContainer for Safe Areas (NEXT)

**Goal**: Create ScreenContainer component that automatically applies safe area margins for iOS notches, Dynamic Island, and home indicator.

**Estimated Effort**: 1.5 hours

**Reference**: [week16-implementation-plan.md lines 2745-3157](../docs/migration/week16-implementation-plan.md#phase-6-spacing--layout-optimization)

### What Phase 6 Delivers

**1. ScreenContainer Component**
- Auto-detects safe area insets on iOS
- Applies margins to prevent UI overlap with notches/Dynamic Island/home indicator
- Reusable across all screens

**2. Safe Area Application**
- Apply ScreenContainer to all 7 main screens
- Test on iPhone 15 Pro Max (physical device) - validate Dynamic Island, notch, home indicator
- Test on iPhone 8 (simulator) - baseline validation

**3. Responsive Scaling**
- Ensure UI scales properly across device sizes
- Viewport-based sizing where appropriate

### Implementation Tasks

**Create ScreenContainer (`scripts/ui/components/screen_container.gd`):**
```gdscript
extends MarginContainer
class_name ScreenContainer
## Automatically applies safe area insets for notches, Dynamic Island, home indicator

func _ready() -> void:
	_apply_safe_area_insets()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _apply_safe_area_insets() -> void:
	if not OS.has_feature("mobile"):
		return  # No safe areas on desktop

	# Get safe area from viewport
	var safe_area = DisplayServer.get_display_safe_area()
	var viewport_size = get_viewport().get_visible_rect().size

	# Calculate insets
	var inset_top = safe_area.position.y
	var inset_left = safe_area.position.x
	var inset_bottom = viewport_size.y - (safe_area.position.y + safe_area.size.y)
	var inset_right = viewport_size.x - (safe_area.position.x + safe_area.size.x)

	# Apply as margins
	add_theme_constant_override("margin_top", int(inset_top))
	add_theme_constant_override("margin_left", int(inset_left))
	add_theme_constant_override("margin_bottom", int(inset_bottom))
	add_theme_constant_override("margin_right", int(inset_right))
```

**Screens to Update:**
- Hub (scrapyard.tscn)
- Character Roster (character_roster.tscn)
- Character Creation (character_creation.tscn)
- Wave Complete (wave_complete_screen.tscn)
- Game Over (game_over_screen.tscn)
- Character Details Panel (character_details_panel.tscn)
- Combat HUD (wasteland.tscn - or defer to Phase 7)

### Success Criteria

- [ ] ScreenContainer component created and tested
- [ ] All 6 menu screens use ScreenContainer (Combat HUD in Phase 7)
- [ ] Tested on iPhone 15 Pro Max - no UI overlap with Dynamic Island, notch, home indicator
- [ ] Tested on iPhone 8 (simulator) - no layout breakage
- [ ] All 647/671 tests still passing
- [ ] Scene instantiation validator passing (20/20 scenes)

---

## 🔮 After Phase 6

**Phase 7: Combat HUD Mobile Optimization** (2h)
- Apply all mobile patterns to combat HUD
- Safe area compliance
- Touch target validation (pause button ≥60×60px)
- Test during actual gameplay

**Phase 8: Visual Identity & Delight ⭐ CRITICAL** (4-6h)
- **MANDATORY** - Transforms functional UI into visually-distinctive game
- Wasteland color palette (rust/yellow/red replacing purple/gray)
- Button texture overlays (metal plates, rivets, weathering)
- Icon prominence (24-32px, not 16px decorative)
- Typography impact (bolder headers, shadows, outlines)
- Delight layer (enhanced feedback, transitions, micro-interactions)
- Competitor parity validation ("10-Second Impression Test")

**Without Phase 8**: We have a mobile-native app, not a compelling game
**With Phase 8**: Visually distinctive, thematically consistent, screenshot-worthy

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

---

## 📁 Key Files & Documentation

**Week Plan:**
- `docs/migration/week16-implementation-plan.md` - Master plan (95% immutable, status tracker living)

**Recently Updated:**
- `.system/CLAUDE_RULES.md` - Added Modal Layout Protocol, Destructive UI Standards, Session/Week Plan Protocol
- `.system/week16-phase-analysis.md` - Phase-by-phase completion analysis

**Components:**
- `scripts/ui/components/mobile_modal.gd` - Modal component (QA Pass 21 proven)
- `scripts/ui/components/modal_factory.gd` - Modal factory with show_confirmation/show_destructive_confirmation
- `scripts/ui/components/button_animation.gd` - Button press animation (0.90 scale, 50ms)
- `scripts/ui/theme/theme_helper.gd` - create_styled_button(), add_button_animation()
- `scripts/autoload/haptic_manager.gd` - Haptic feedback wrapper (iOS 26.1 compatible)

**Theme System:**
- `themes/game_theme.tres` - Main theme resource
- `themes/styles/button_*.tres` - PRIMARY, SECONDARY, DANGER, GHOST button styles
- `themes/icons/game/` - 25 Kenney icons (CC0, 2x resolution)

---

## 🎓 Recent Lessons Learned (QA Passes 20-21)

### Lesson 1: Modal Layout Order-of-Operations
**Problem**: Modal appeared shifted right/down instead of centered
**Root Cause**: Called `set_anchors_and_offsets_preset()` BEFORE setting size → offsets calculated with size=0
**Solution**: Manual calculation with correct order:
1. Set size FIRST
2. Set anchors (0.5, 0.5, 0.5, 0.5)
3. Calculate offsets based on ACTUAL size (-W/2, -H/2, W/2, H/2)

**Now documented in**: `.system/CLAUDE_RULES.md` - Modal & Dialog Layout Protocol

### Lesson 2: Size Conveys Importance
**Problem**: 220px modal felt "not serious enough" for character deletion
**Solution**: 300px modal (+36%), 140×64px buttons (+17%), larger fonts (28pt/20pt)
**User Feedback**: "make the modal larger and more prominent" → we did → "success"

**Now documented in**: `.system/CLAUDE_RULES.md` - Destructive Operation UI Standards

### Lesson 3: Investigation Protocol Works
**What Worked**:
- User called out trial-and-error after QA Pass 17
- Spawned expert investigation panel
- Found 4 distinct root causes (not just 1)
- Systematic fixes, no more guessing

**Takeaway**: After 1-2 failed QA passes → STOP and investigate systematically

---

## 🚀 Quick Start Prompt for Next Session

### If Continuing Phase 6 (ScreenContainer):

```
Continue with Week 16 Phase 6 (ScreenContainer for Safe Areas).

1. Read docs/migration/week16-implementation-plan.md (lines 2745-3157) for Phase 6 spec
2. Create scripts/ui/components/screen_container.gd (MarginContainer with safe area auto-detection)
3. Apply ScreenContainer to 6 menu screens (hub, roster, creation, wave_complete, game_over, character_details)
4. Test on iPhone 15 Pro Max (physical) - validate Dynamic Island, notch, home indicator
5. Test on iPhone 8 (simulator) - validate no layout breakage
6. Run tests: python3 .system/validators/godot_test_runner.py
7. Update week16-implementation-plan.md status tracker (Phase 6 complete)
8. Update NEXT_SESSION.md (Phase 7 next)
```

### If User Says "Continue from Last Session":

This IS the current session state. Phase 6 (ScreenContainer) is next.

---

## 🧭 Git Status

**Branch**: main
**Last Commit**: `27b0409` - docs: updated next_session
**Untracked/Modified**:
- `.system/NEXT_SESSION.md` (this file - new)
- `.system/CLAUDE_RULES.md` (updated - 3 new sections)
- `docs/migration/week16-implementation-plan.md` (updated - Phase 8 added, status tracker added)
- `.system/week16-phase-analysis.md` (new - phase completion analysis)

**Tests**: ✅ 647/671 passing
**Validators**: ✅ All passing

---

## 🎯 Success Criteria for "Week 16 Complete"

**Code Complete** (Phases 0-8):
- ✅ Phases 0-5: ~80% complete (foundation done)
- 📋 Phase 6: Pending (ScreenContainer) ← NEXT
- 📋 Phase 7: Pending (Combat HUD)
- 📋 Phase 8: Pending (Visual Identity) ← CRITICAL, NON-OPTIONAL

**Quality Gates:**
- [ ] All 647+ tests passing
- [ ] Safe areas validated on iPhone 15 Pro Max (no overlap)
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
**Next Phase**: Phase 6 - ScreenContainer for Safe Areas
**Estimated Time**: 1.5h (Phase 6) + 2h (Phase 7) + 4-6h (Phase 8) = **7.5-9.5h remaining**
**Quality Bar**: Mobile-native ergonomics + visually-distinctive aesthetics + competitor parity
