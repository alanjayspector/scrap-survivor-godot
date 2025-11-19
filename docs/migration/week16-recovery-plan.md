# Week 16 Mobile UI Recovery Plan - One-Off Session

**Date**: 2025-11-18
**Branch**: `feature/week16-mobile-ui`
**Status**: Phase 2 & 3 reverted, need to recover and complete Week 16

---

## Executive Summary

Week 16 typography and touch target improvements were reverted due to test failures. This plan:
1. Investigates why UI changes broke unrelated tests
2. Uses expert panel to evaluate whether Godot theme system is better than per-element overrides
3. Provides revised Phase 2 & 3 implementation plan

---

## Background: What Happened

### Commits:
- `873284d` - Typography improvements (REVERTED in 1abe491)
- `1abe491` - Revert commit (current state)
- `4cda7d7` - Fixed unrelated PREMIUM currency bug

### What Broke:
- **Test**: `scripts/tests/drop_system_test.gd::test_scavenging_multiplies_drop_amounts`
- **Error**: `[1.065...] expected to be > than [1.1]` (probabilistic RNG failure)
- **Bizarre**: Typography changes in UI `.tscn` files broke a drop calculation test

### What Was Reverted:
**Phase 2 Typography Changes** (commit 873284d):
- Screen titles: 40pt → 48pt (+20%)
- HUD labels: 28pt → 32pt (+14%)
- Body text: 17-18pt → 20pt (+18%)
- Button text: 22pt → 24pt

**Phase 3 Touch Target Changes** (commit 873284d):
- Removed pause button from Combat HUD (redundant on iOS)
- Fixed XP bar alignment (20pt → 35pt tall)

**Net Result**: Zero progress on Week 16

---

## PHASE 1: Investigation (Required Before Proceeding)

### 1.1 RNG Seeding Analysis

**Question**: Are tests properly seeding RNG for deterministic results?

**Investigation Steps**:
1. Check if `drop_system_test.gd` uses `seed()` to ensure deterministic RNG
   ```bash
   grep -n "seed\|randomize" scripts/tests/drop_system_test.gd
   ```

2. Check if GUT framework provides test-level seeding
   ```bash
   grep -n "before_each\|seed" scripts/tests/drop_system_test.gd
   ```

3. Review the failing test at line 97:
   ```bash
   # Read the test to understand what it's doing
   ```

**Expected Findings**:
- ✅ **Best case**: Tests don't seed RNG → Easy fix, add seeding
- ⚠️ **Concerning**: Tests do seed but still fail → Real coupling issue
- 🚨 **Worst case**: UI changes somehow affect game logic → Architecture problem

**Action Items**:
- [ ] Document current RNG seeding approach
- [ ] Identify if test is truly probabilistic or should be deterministic
- [ ] If no seeding: Add `seed(12345)` to `before_each()` and re-run tests
- [ ] If seeding exists: Investigate why UI changes affect drop calculations

---

### 1.2 Scene File Change Impact Analysis

**Question**: How can `.tscn` file changes affect drop system tests?

**Investigation Steps**:
1. Compare the reverted commit to identify exact changes:
   ```bash
   git diff 1abe491 873284d -- scenes/
   ```

2. Check if any scene files instantiate or reference DropSystem:
   ```bash
   grep -r "DropSystem" scenes/
   ```

3. Check if scene loading order affects test initialization:
   ```bash
   # Look for autoload order in project.godot
   grep -A 20 "\[autoload\]" project.godot
   ```

4. Check if any UI scripts reference game logic services:
   ```bash
   # Check HUD script for DropSystem usage
   grep -n "DropSystem\|drop_system" scenes/ui/hud.gd
   ```

**Expected Findings**:
- **Most likely**: Flaky test with no real coupling
- **Possible**: Scene loading changes test execution timing
- **Unlikely but serious**: UI code incorrectly coupled to game logic

**Action Items**:
- [ ] Document any unexpected coupling between UI and game logic
- [ ] Verify scene files don't modify global state that affects tests

---

### 1.3 Test Suite Stability Check

**Goal**: Ensure the test failure is reproducible and not random

**Steps**:
1. Run tests 10 times on current branch (1abe491):
   ```bash
   for i in {1..10}; do
     python3 .system/validators/godot_test_runner.py
     echo "Run $i: $(cat test_results.txt)"
   done
   ```

2. If ALL 10 runs pass → Test is stable without typography changes
3. If ANY run fails → Test is flaky even without typography changes

**Action Items**:
- [ ] Record test stability baseline (10 runs)
- [ ] If flaky: Fix the test first before proceeding with Week 16
- [ ] If stable: Typography changes definitely triggered the failure

---

## PHASE 2: Expert Panel Review

### 2.1 Load Expert Panel

**Agent Configuration**:
```
Use Task tool with subagent_type="Plan"
Thoroughness: "very thorough"
```

**Panel Composition**:
- **Mobile UI Expert**: iOS Human Interface Guidelines specialist
- **Godot Expert**: Godot 4.x theming and UI system expert
- **Architecture Expert**: System design and maintainability

### 2.2 Questions for Expert Panel

#### Question 1: Per-Element Overrides vs Godot Theme System

**Context**:
- Current approach: `theme_override_font_sizes/font_size = 48` on individual nodes
- Alternative: Create a global Theme resource with consistent styles

**Reference Documents**:
- [mobile-ui-specification.md](../mobile-ui-specification.md) - Target sizes and rationale
- [week16-phase1-audit-report.md](week16-phase1-audit-report.md) - Current state analysis

**Ask the Panel**:

1. **Godot Expert**:
   - "What are the pros/cons of per-element `theme_override_*` vs a centralized Theme resource?"
   - "For a mobile game with 20+ UI scenes, which approach scales better?"
   - "Can Theme inheritance solve the 'button text too small' issue elegantly?"
   - "Show code example: How to create a Theme with 48pt titles, 20pt body, 280pt button widths"

2. **Mobile UI Expert**:
   - "Review [mobile-ui-specification.md](../mobile-ui-specification.md) - Are the target sizes (48pt titles, 20pt body) appropriate for iPhone 15 Pro Max in landscape?"
   - "Compare to Brotato mobile UI - Are we matching industry standards?"
   - "iOS HIG says 17pt minimum - Why did 17pt→20pt feel imperceptible to the user?"

3. **Architecture Expert**:
   - "Why would changing font sizes in `.tscn` files break `drop_system_test.gd`?"
   - "Is there hidden coupling between UI and game logic that needs addressing?"
   - "Should we refactor before continuing Week 16?"

**Deliverable**:
- [ ] Expert panel consensus: **Per-element overrides** OR **Theme system**
- [ ] If Theme: Detailed implementation plan with code examples
- [ ] If Overrides: Explanation of why + how to avoid test breakage

---

### 2.3 Review Original Phase 2 & 3 Goals

**Reference**: [week16-v2-implementation-plan.md](week16-v2-implementation-plan.md)

**Original Phase 2: Typography Improvements**
- **Goal**: Increase font sizes to iOS HIG minimums
- **Target sizes**:
  - Screen titles: 40pt (originally 36pt)
  - Body text: 17pt minimum (originally 14pt)
  - HUD labels: 28pt (originally 24pt)
- **Rationale**: Meet iOS HIG 17pt minimum for readability

**Original Phase 3: Touch Target & Button Redesign**
- **Goal**: Meet iOS HIG 44pt minimum touch targets
- **Changes**:
  - Primary buttons: 280pt width (was 100-200pt)
  - Delete button: 120pt width (was 50pt) - SAFETY CRITICAL
  - Grid spacing: 16pt (was 8pt)
  - Pause button: REMOVED (redundant on iOS auto-pause)

**User Feedback** (from session):
- "I can't see the differences other than the delete button"
- "Text still looks small - I'm squinting on some text"
- "Be more aggressive about text"
- **Key quote**: "Why is it so hard to simply meet HIG requirements?"

**Analysis**:
- Conservative approach (17pt, 40pt) was **imperceptible** to user
- Need **aggressive** approach like Brotato (48pt titles, 20pt body)
- But aggressive approach broke tests... why?

**Ask the Panel**:
- "Was the conservative iOS HIG approach (17pt) a mistake?"
- "Should we have gone Brotato-aggressive (48pt, 20pt) from the start?"
- "How do we make changes perceptible on high-DPI iPhone 15 Pro Max?"

---

## PHASE 3: Revised Implementation Plan

### 3.1 Decision Gate: Theme vs Overrides

**IF Expert Panel says "Use Theme System":**

#### Revised Phase 2: Create Mobile Theme Resource

**Steps**:
1. Create `themes/mobile_theme.tres` with:
   ```gdscript
   # Typography sizes (Brotato-aggressive)
   - Title font: 48pt
   - Subtitle font: 20pt
   - Body font: 20pt (not 17pt - too small)
   - Button font: 24pt

   # Touch targets
   - Primary button: 280pt min width, 60pt height
   - Secondary button: 160pt min width, 60pt height
   - Touch target minimum: 48×48pt
   ```

2. Apply theme to all UI scenes:
   ```gdscript
   # In each scene's root Control node
   theme = preload("res://themes/mobile_theme.tres")
   ```

3. Override only where needed (special cases)

**Deliverable**:
- [ ] `themes/mobile_theme.tres` created
- [ ] Applied to all 10+ UI scenes
- [ ] Visual regression: New screenshots vs baseline
- [ ] Tests passing

---

**IF Expert Panel says "Keep Per-Element Overrides":**

#### Revised Phase 2: Re-apply Typography Changes (After Test Fix)

**Prerequisites**:
1. Fix `drop_system_test.gd` flakiness (add RNG seeding)
2. Verify tests pass 10/10 times
3. Understand why original changes broke tests

**Changes** (same as before, but more aggressive):
- Screen titles: 36pt → **48pt** (+33%, not +11%)
- Body text: 14pt → **20pt** (+43%, not +21%)
- HUD labels: 24pt → **32pt** (+33%, not +14%)
- Button text: 20pt → **24pt** (+20%)

**Modified files** (same as commit 873284d):
- `scenes/ui/character_creation.tscn`
- `scenes/ui/character_selection.tscn`
- `scenes/ui/character_card.tscn`
- `scenes/ui/hud.tscn`
- `scenes/ui/wave_complete_screen.tscn`
- `scenes/game/wasteland.tscn` (Game Over screen)

**Safety Checks**:
- Run tests after EACH file change to identify which scene breaks tests
- If tests fail: Bisect to find the specific property causing failure
- Document any unexpected coupling

**Deliverable**:
- [ ] Typography changes applied
- [ ] Tests passing (647/671, 0 failures)
- [ ] Visual regression: Confirm changes are PERCEPTIBLE
- [ ] User validation: "Can you see the difference now?"

---

#### Revised Phase 3: Touch Target Improvements (Unchanged)

**Changes** (same as original):
- Primary buttons: 280pt width everywhere
- Delete button: 120pt width (safety)
- Grid spacing: 16pt (prevent mis-taps)
- Pause button: REMOVED (redundant)
- XP bar: 35pt tall (fix alignment)

**Files to modify**:
- `scenes/ui/character_card.tscn` (Delete: 50pt→120pt, Play: 100pt→280pt)
- `scenes/ui/character_selection.tscn` (spacing: 8pt→16pt)
- `scenes/ui/hud.tscn` (remove PauseButton, fix XP bar)
- All other scenes: standardize to 280pt primary buttons

**Safety Checks**:
- Test after each scene change
- Verify no test breakage

**Deliverable**:
- [ ] Touch targets meet 48pt minimum
- [ ] Primary buttons standardized to 280pt
- [ ] Tests passing
- [ ] User validation: "Delete button feels safer now?"

---

### 3.2 Testing Protocol

**After each phase**:
1. Run full test suite: `python3 .system/validators/godot_test_runner.py`
2. Capture screenshots for visual regression
3. Compare to baseline ([docs/migration/week16-baseline-screenshots/](week16-baseline-screenshots/))
4. Get user validation on actual device

**Success Criteria**:
- ✅ All tests passing (647/671 minimum)
- ✅ Changes are PERCEPTIBLE on iPhone 15 Pro Max
- ✅ User says "I can see the difference now"
- ✅ Meets mobile-ui-specification.md targets

---

## Quick Reference: Key Documents

1. **Mobile UI Specification**: `docs/mobile-ui-specification.md`
   - Target sizes, rationale, iOS HIG requirements

2. **Week 16 Plan**: `docs/migration/week16-v2-implementation-plan.md`
   - Original 8-phase plan, detailed breakdown

3. **Phase 1 Audit**: `docs/migration/week16-phase1-audit-report.md`
   - Current state analysis, gaps identified

4. **Baseline Screenshots**: `docs/migration/week16-baseline-screenshots/`
   - Before images for visual regression

5. **QA Plan**: `qa/week16-phase2-phase3-qa-plan.md`
   - Testing checklist, perceptibility ratings

---

## Expected Timeline

**Session 1 (Investigation + Panel)**:
- Investigation: 30 minutes
- Expert panel review: 45 minutes
- Decision on approach: 15 minutes
- **Total**: ~90 minutes

**Session 2 (Implementation)**:
- Phase 2 (Typography): 45 minutes
- Phase 3 (Touch Targets): 30 minutes
- Testing & validation: 30 minutes
- **Total**: ~105 minutes

**Total**: ~3 hours to complete Week 16 properly

---

## Success Criteria for This Plan

- [ ] Investigation complete: Know WHY tests failed
- [ ] RNG seeding issue identified and fixed
- [ ] Expert panel decision: Theme OR Overrides (with rationale)
- [ ] Phase 2 & 3 completed using chosen approach
- [ ] All tests passing
- [ ] Changes are VISIBLY different on device
- [ ] User satisfied: "This is what I wanted"

---

## Notes for Fresh Session

**Context to provide**:
- User has iPhone 15 Pro Max (physical device for testing)
- User is frustrated that Phase 2/3 were "imperceptible"
- User wants aggressive sizing like Brotato, not conservative iOS HIG minimums
- User values test stability - don't bypass guardrails
- Week 16 is important to user - wants polished UI before inviting testers

**Git State**:
```bash
# Current branch
git checkout feature/week16-mobile-ui

# Relevant commits
git log --oneline -5
# 4cda7d7 - fix: remove invalid CurrencyType.PREMIUM references
# 1abe491 - revert: aggressive typography improvements - broke tests
# 873284d - fix: aggressive typography improvements (REVERTED)
```

**Test Status**:
```bash
# Should be passing
python3 .system/validators/godot_test_runner.py
# Expected: 647 passed / 671 total, 0 failures
```

---

**End of Recovery Plan**
