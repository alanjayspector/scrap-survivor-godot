# Week 16 Phase 1: UI Component Audit Report

**Date**: 2025-11-18
**Auditor**: Claude Code
**Scope**: ALL UI screens - Scrapyard, Character Roster, Character Creation/Selection, Combat HUD, Wave Complete, Game Over
**Comparison Standard**: [mobile-ui-specification.md v1.1](../mobile-ui-specification.md) (Brotato-informed, iOS HIG validated)

---

## Executive Summary

**Overall Assessment**: 🟡 **NEEDS IMPROVEMENT** - Desktop-style UI requires significant mobile optimization

**Critical Issues Found**: 4
**Medium Priority Issues**: 12
**Low Priority Issues**: 8

**Top 3 Critical Blockers**:
1. ❌ **Combat HUD Safe Area Violations** - All HUD elements positioned at 20pt from top (should be 59pt to clear notch/Dynamic Island)
2. ❌ **Missing Pause Button** - No pause button found in Combat HUD (spec requires 48×48pt button)
3. ❌ **Delete Button Too Narrow** - 50pt width vs 120pt standard (high risk of accidental taps)

**Positive Findings**:
- ✅ All text has excellent 3px black outlines for readability
- ✅ Font sizes are generally in acceptable range (28pt for stats, 40pt for timer)
- ✅ Button heights often exceed minimum (70pt in Game Over/Wave Complete)
- ✅ Good use of spacing in most screens (20-30pt button separation)

---

## Gap Analysis by Screen

### 1. Scrapyard (Hub) - [scrapyard.tscn](../../scenes/hub/scrapyard.tscn)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("SCRAP SURVIVOR")** | 48pt | 40-48pt | ✅ PASS | - | Perfect match |
| **Play Button (Width)** | 200pt | 280pt | -80pt | 🟡 Medium | Narrower than Brotato standard |
| **Play Button (Height)** | 60pt | 64pt | -4pt | 🟢 Low | Close to standard |
| **Characters Button (Width)** | 200pt | 280pt | -80pt | 🟡 Medium | Narrower than Brotato standard |
| **Settings Button (Width)** | 200pt | 280pt | -80pt | 🟡 Medium | Narrower than Brotato standard |
| **Quit Button (Width)** | 200pt | 120pt (secondary) | +80pt | ✅ PASS | Actually wider (acceptable) |
| **Button Font Size** | 28pt | 18-20pt | +8pt | ✅ PASS | Exceeds standard (better readability) |
| **Button Spacing** | 20pt | 16pt min | +4pt | ✅ PASS | Good spacing |
| **Top Margin** | 100pt | 59pt min | +41pt | ✅ PASS | Clears safe area |
| **Safe Area Handling** | None | Dynamic detection | - | 🟡 Medium | No SafeAreaContainer component |

**Screen-Specific Issues**:
- 🟡 No dynamic safe area detection (hardcoded 100pt top margin)
- 🟢 Background color: Color(0.15, 0.12, 0.1) - dark brown, contrast needs validation

---

### 2. Character Roster - [character_roster.tscn](../../scenes/ui/character_roster.tscn) + [character_card.tscn](../../scenes/ui/character_card.tscn)

#### Header Elements

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("Your Survivors")** | 48pt | 40-48pt | ✅ PASS | - | Perfect match |
| **Slot Label** | 20pt | 14-16pt (meta) | +4pt | ✅ PASS | Good for secondary info |
| **Create New Button (Width)** | 250pt | 280pt | -30pt | 🟡 Medium | Close but below standard |
| **Back Button (Width)** | 150pt | 120pt (secondary) | +30pt | ✅ PASS | Acceptable |
| **Button Height** | 60pt | 64pt | -4pt | 🟢 Low | Close to standard |

#### Character Card Component

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Play Button (Width)** | 100pt | 280pt | -180pt | 🔴 **CRITICAL** | Far below standard - awkward to tap |
| **Play Button (Height)** | 60pt | 64pt | -4pt | 🟢 Low | Close |
| **Play Button Font** | 20pt | 18-20pt | ✅ PASS | - | Perfect |
| **Details Button (Width)** | 80pt | 160pt | -80pt | 🟡 Medium | Half the standard width |
| **Details Button Font** | 16pt | 18-20pt | -2pt | 🟢 Low | Borderline small |
| **Delete Button (Width)** | 50pt | 120pt | -70pt | 🔴 **CRITICAL** | Too narrow - high accidental tap risk |
| **Delete Button Font** | 24pt | 18-20pt | +4pt | ✅ PASS | Good (large for emphasis) |
| **Spacer (Play→Delete)** | 20pt | 16pt min | +4pt | ✅ PASS | Good separation |
| **Card Height** | 80pt | 140pt (item card) | -60pt | 🟡 Medium | Compact but workable |
| **Character Name Font** | 24pt | 18-20pt (button) | +4pt | ✅ PASS | Good |
| **Character Type Font** | 18pt | 14-16pt (meta) | +2pt | ✅ PASS | Good |
| **Stats Font** | 14pt | 17pt (body) | -3pt | 🟢 Low | Slightly small for mobile |
| **HBoxContainer Separation** | 12pt | 16pt min | -4pt | 🟢 Low | Below recommended gap |
| **VBoxContainer Separation** | 2pt | 4pt min | -2pt | 🟢 Low | Very tight (internal spacing) |

**Screen-Specific Issues**:
- 🔴 **Delete button is CRITICAL safety issue** - 50pt width makes accidental taps likely
- 🟡 Play button width (100pt) feels awkward on mobile - should be primary action size
- 🟢 DeleteConfirmationDialog uses default Godot ConfirmationDialog (desktop-style, small)

---

### 3. Character Creation - [character_creation.tscn](../../scenes/ui/character_creation.tscn)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("Create Your Survivor")** | 36pt | 40-48pt | -4pt | 🟡 Medium | Below screen title standard |
| **Subtitle** | 20pt | 14-16pt (meta) | +4pt | ✅ PASS | Good |
| **Input Labels** | 24pt | 18-20pt | +4pt | ✅ PASS | Good |
| **Name Input Height** | 60pt | 56pt min | +4pt | ✅ PASS | Good touch target |
| **Name Input Font** | 20pt | 17pt (body) | +3pt | ✅ PASS | Good |
| **Cancel Button (Width)** | 150pt | 120pt (secondary) | +30pt | ✅ PASS | Acceptable |
| **Create Button (Width)** | 200pt | 280pt | -80pt | 🟡 Medium | Primary action should be wider |
| **Button Height** | 60pt | 64pt | -4pt | 🟢 Low | Close |
| **Button Font** | 24pt | 18-20pt | +4pt | ✅ PASS | Good |
| **Margins (Horizontal)** | 20pt | 24pt | -4pt | 🟢 Low | Slightly below standard |
| **Margins (Vertical)** | 40pt | 24pt min | +16pt | ✅ PASS | Good |
| **Main Separation** | 20pt | 16pt min | +4pt | ✅ PASS | Good |
| **Grid Separation** | 15pt | 16pt min | -1pt | 🟢 Low | Just below minimum |

**Screen-Specific Issues**:
- 🟡 Title slightly small for screen-level heading
- 🟡 Create button (primary action) should be 280pt wide

---

### 4. Character Selection - [character_selection.tscn](../../scenes/ui/character_selection.tscn)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("Choose Your Survivor")** | 36pt | 40-48pt | -4pt | 🟡 Medium | Below screen title standard |
| **Subtitle** | 18pt | 14-16pt (meta) | +2pt | ✅ PASS | Good |
| **Back Button (Width)** | 200pt | 280pt | -80pt | 🟡 Medium | Could be wider |
| **Wasteland Button (Width)** | 250pt | 280pt | -30pt | 🟡 Medium | Close but below |
| **Button Height** | 60pt | 64pt | -4pt | 🟢 Low | Close |
| **Button Font** | 28pt | 18-20pt | +8pt | ✅ PASS | Excellent (very readable) |
| **Margins (Horizontal)** | 20pt | 24pt | -4pt | 🟢 Low | Slightly below |
| **Margins (Vertical)** | 40pt | 24pt min | +16pt | ✅ PASS | Good |
| **Main Separation** | 20pt | 16pt min | +4pt | ✅ PASS | Good |
| **Grid Separation** | 8pt | 16pt min | -8pt | 🟡 Medium | **HALF the minimum** - accidental tap risk |

**Screen-Specific Issues**:
- 🟡 **Grid separation is 8pt** - high risk of selecting wrong character card (should be 16pt minimum)
- 🟡 Title slightly small

---

### 5. Combat HUD - [hud.tscn](../../scenes/ui/hud.tscn)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **HP Bar Position (Top)** | 20pt | 59pt | -39pt | 🔴 **CRITICAL** | Overlaps notch/Dynamic Island |
| **HP Bar Position (Left)** | 20pt | 24pt | -4pt | 🟢 Low | Slightly inside margin |
| **HP Bar Width** | 330pt | 180pt | +150pt | ✅ PASS | Wider is fine |
| **HP Bar Height** | 35pt | 48pt | -13pt | 🟡 Medium | Should be taller |
| **HP Label Font** | 28pt | 28-32pt | ✅ PASS | - | Perfect match |
| **HP Label Outline** | 3px | 3px | ✅ PASS | - | Perfect |
| **XP Bar Position (Top)** | 65pt | N/A | N/A | 🔴 **CRITICAL** | Should be at BOTTOM (34pt from bottom) |
| **XP Bar Height** | 25pt | 40pt | -15pt | 🟡 Medium | Should be taller |
| **XP Bar Width** | 330pt | 342pt | -12pt | 🟢 Low | Close |
| **XP Label Font** | 28pt | 20pt | +8pt | 🟢 Low | Larger than spec (acceptable) |
| **Wave Label Font** | 28pt | 16-20pt | +8pt | ✅ PASS | Good (readable) |
| **Wave Timer Position (Top)** | 20pt | 59pt | -39pt | 🔴 **CRITICAL** | Overlaps notch/Dynamic Island |
| **Wave Timer Font** | 40pt | 16-20pt | +20pt | ✅ PASS | **EXCELLENT** - very readable |
| **Currency Position (Top)** | 20pt | 59pt | -39pt | 🔴 **CRITICAL** | Overlaps notch/Dynamic Island |
| **Currency Position (Right)** | 20pt | 24pt | -4pt | 🟢 Low | Slightly inside margin |
| **Currency Font** | 28pt | 20pt | +8pt | ✅ PASS | Good |
| **Pause Button** | **MISSING** | 48×48pt required | N/A | 🔴 **CRITICAL** | No pause button found |

**Screen-Specific Issues**:
- 🔴 **ALL top-positioned HUD elements at 20pt from top** - will overlap Dynamic Island on iPhone 14/15 Pro
- 🔴 **XP Bar is at TOP instead of BOTTOM** - spec requires 34pt from bottom edge (above home indicator)
- 🔴 **NO PAUSE BUTTON** - spec requires 48×48pt pause button at top-right (59pt from top, 24pt from right)
- ✅ Font sizes are generally GOOD (28pt for stats, 40pt for timer - very readable)
- ✅ All text has 3px black outlines (excellent for combat readability)

**Safe Area Violations Summary**:
- HP Bar: 20pt from top ❌ (should be 59pt)
- Wave Timer: 20pt from top ❌ (should be 59pt)
- Currency: 20pt from top ❌ (should be 59pt)
- XP Bar: Positioned at top ❌ (should be at bottom, 34pt from edge)

---

### 6. Wave Complete Screen - [wave_complete_screen.tscn](../../scenes/ui/wave_complete_screen.tscn)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("Wave 1 Complete!")** | 36pt | 40-48pt | -4pt | 🟡 Medium | Below screen title standard |
| **Hub Button (Width)** | 180pt | 280pt | -100pt | 🟡 Medium | Should be wider |
| **Next Wave Button (Width)** | 180pt | 280pt | -100pt | 🟡 Medium | Should be wider |
| **Button Height** | 70pt | 64pt | +6pt | ✅ PASS | **Exceeds standard!** |
| **Button Font** | 22pt | 18-20pt | +2pt | ✅ PASS | Good |
| **Button Separation** | 30pt | 16pt min | +14pt | ✅ PASS | Excellent spacing |
| **Margin (All Sides)** | 24pt | 24pt | ✅ PASS | - | Perfect |

**Screen-Specific Issues**:
- 🟡 Title slightly small
- 🟡 Buttons should be wider (280pt for primary actions)
- ✅ Button height (70pt) is EXCELLENT - exceeds standard

---

### 7. Game Over Screen - [wasteland.tscn](../../scenes/game/wasteland.tscn:60-150)

| Element | Current | Standard | Gap | Priority | Notes |
|---------|---------|----------|-----|----------|-------|
| **Title ("Game Over")** | 36pt | 40-48pt | -4pt | 🟡 Medium | Below screen title standard |
| **XP Gained Label** | 26pt | 24-28pt (section header) | ✅ PASS | - | Good |
| **Level Up Label** | 28pt | 24-28pt | ✅ PASS | - | Good |
| **Retry Button (Width)** | 180pt | 280pt | -100pt | 🟡 Medium | Should be wider |
| **Main Menu Button (Width)** | 180pt | 280pt | -100pt | 🟡 Medium | Should be wider |
| **Button Height** | 70pt | 64pt | +6pt | ✅ PASS | **Exceeds standard!** |
| **Button Font** | 22pt | 18-20pt | +2pt | ✅ PASS | Good |
| **Button Separation** | 15pt | 16pt min | -1pt | 🟢 Low | Just below minimum |
| **Margin (All Sides)** | 24pt | 24pt | ✅ PASS | - | Perfect |
| **XP Progress Bar Height** | 30pt | 40pt | -10pt | 🟢 Low | Could be taller |

**Screen-Specific Issues**:
- 🟡 Title slightly small
- 🟡 Buttons should be wider (280pt for primary actions)
- ✅ Button height (70pt) is EXCELLENT - exceeds standard
- 🟢 Button separation (15pt) is just below 16pt minimum

---

## Priority Matrix - All Issues

### 🔴 CRITICAL (Fix in Phase 2-3)

| Screen | Issue | Current | Target | Impact |
|--------|-------|---------|--------|--------|
| **Combat HUD** | HP Bar top position | 20pt | 59pt | Overlaps Dynamic Island on iPhone 14/15 Pro |
| **Combat HUD** | Wave Timer top position | 20pt | 59pt | Overlaps Dynamic Island |
| **Combat HUD** | Currency top position | 20pt | 59pt | Overlaps Dynamic Island |
| **Combat HUD** | XP Bar position | Top (65pt) | Bottom (34pt from edge) | Wrong location entirely |
| **Combat HUD** | **Missing Pause Button** | None | 48×48pt at top-right | Cannot pause during combat |
| **Character Card** | Delete button width | 50pt | 120pt | High accidental tap risk |
| **Character Card** | Play button width | 100pt | 280pt | Awkward to tap, not primary-action sized |

### 🟡 MEDIUM (Fix in Phase 3-5)

| Screen | Issue | Current | Target | Impact |
|--------|-------|---------|--------|--------|
| **All Hub Screens** | Primary button widths | 200-250pt | 280pt | Narrower than Brotato standard |
| **Character Selection** | Grid separation | 8pt | 16pt | Accidental card selection risk |
| **Combat HUD** | HP Bar height | 35pt | 48pt | Less visible during combat |
| **Combat HUD** | XP Bar height | 25pt | 40pt | Less visible |
| **Character Card** | Details button width | 80pt | 160pt | Small touch target |
| **Character Creation/Selection** | Screen titles | 36pt | 40-48pt | Below standard for screen headers |
| **Wave Complete/Game Over** | Screen titles | 36pt | 40-48pt | Below standard |
| **All Screens** | No SafeAreaContainer | Hardcoded margins | Dynamic detection | Won't adapt to different devices |

### 🟢 LOW (Polish in Phase 5-6)

| Screen | Issue | Current | Target | Impact |
|--------|-------|---------|--------|--------|
| **Character Card** | Stats font size | 14pt | 17pt | Slightly small |
| **Character Card** | HBoxContainer separation | 12pt | 16pt | Tight spacing |
| **Character Creation** | Horizontal margins | 20pt | 24pt | Minor spacing issue |
| **Character Selection** | Horizontal margins | 20pt | 24pt | Minor spacing issue |
| **Game Over** | Button separation | 15pt | 16pt | Just below minimum |
| **Game Over** | XP Progress Bar height | 30pt | 40pt | Could be taller |
| **Combat HUD** | Left/right margins | 20pt | 24pt | Minor spacing issue |

---

## Contrast Ratio Analysis

**Background Colors Found**:
- Scrapyard/Character Roster: `Color(0.15, 0.12, 0.1)` ≈ `#26201A` (dark brown)
- Wave Complete/Game Over: `Color(0, 0, 0, 0.7)` = 70% black overlay
- Combat HUD: Transparent (gameplay visible)

**Text Colors**:
- Titles: Gold/Yellow `Color(0.9, 0.7, 0.3)` ≈ `#E6B34D`
- Body text: White `Color(1, 1, 1)` = `#FFFFFF`
- Secondary text: Gray `Color(0.7, 0.7, 0.7)` ≈ `#B3B3B3`
- Success: Green `Color(0.3, 0.8, 0.3)` ≈ `#4DCC4D`

**Contrast Validation Needed**:
- ⚠️ Need to calculate contrast ratios against WCAG AA (4.5:1 for body, 3:1 for large text)
- ⚠️ Gold title on dark brown background needs verification
- ✅ All text has 3px black outlines (significantly improves readability)

---

## Brotato Standard Comparison

**What We Match**:
- ✅ Font sizes for stats/HUD (28pt HP, 40pt timer matches or exceeds Brotato)
- ✅ Text outlines (3px black on critical labels)
- ✅ Button heights in Game Over/Wave Complete (70pt exceeds Brotato 64pt)
- ✅ Good spacing between buttons (20-30pt exceeds 16pt minimum)

**What We're Missing**:
- ❌ Button widths (200pt vs Brotato 280pt primary standard)
- ❌ Safe area compliance (20pt top margins vs Brotato 59pt)
- ❌ XP bar position (top vs Brotato bottom)
- ❌ Pause button (missing entirely)
- ⚠️ Screen titles (36pt vs Brotato 40-48pt)

---

## iOS HIG Compliance

### Touch Targets (44pt Minimum)

| Element | Width | Height | Compliant? |
|---------|-------|--------|------------|
| Hub buttons | 200pt | 60pt | ✅ Yes |
| Play button (card) | 100pt | 60pt | ✅ Yes (but awkward) |
| Details button | 80pt | 60pt | ✅ Yes (but awkward) |
| Delete button | **50pt** | 60pt | ⚠️ **Marginal** (width barely exceeds 44pt) |
| Wave Complete buttons | 180pt | 70pt | ✅ Yes |
| Game Over buttons | 180pt | 70pt | ✅ Yes |

**Verdict**: All buttons meet 44pt minimum, but some are awkward (narrow width relative to height).

### Typography (17pt Body Minimum)

| Element | Size | Compliant? |
|---------|------|------------|
| Stats text (card) | 14pt | ❌ No (below 17pt) |
| Button labels | 20-28pt | ✅ Yes |
| HUD labels | 28pt | ✅ Yes |
| Timer | 40pt | ✅ Yes |

**Verdict**: Stats text (14pt) is below iOS HIG 17pt body minimum.

### Safe Areas

| Screen | Top Margin | Bottom Margin | Compliant? |
|--------|-----------|---------------|------------|
| Scrapyard | 100pt | N/A | ✅ Yes (exceeds 59pt) |
| Character screens | 40pt | 40pt | ❌ No (below 59pt top) |
| Combat HUD | **20pt** | N/A | ❌ **No** (critical overlap) |
| XP Bar (should be bottom) | N/A | N/A | ❌ **No** (wrong position) |

**Verdict**: Combat HUD is NOT compliant - will overlap notch/Dynamic Island on iPhone 14/15 Pro.

---

## Recommendations for Phase 2+

### Immediate Actions (Phase 2-3)

1. **Combat HUD Safe Area Fix** 🔴
   - Move all top HUD elements to 59pt from top (HP, timer, currency)
   - Move XP bar to bottom (34pt from bottom edge)
   - Add pause button (48×48pt) at top-right (59pt from top, 24pt from right)

2. **Character Card Button Resize** 🔴
   - Delete button: 50pt → 120pt width
   - Play button: 100pt → 280pt width
   - Details button: 80pt → 160pt width

3. **Implement SafeAreaContainer** 🟡
   - Create `SafeAreaContainer` component from mobile-ui-specification.md
   - Apply to all screens
   - Use dynamic safe area detection instead of hardcoded margins

### Secondary Actions (Phase 4-5)

4. **Button Width Standardization** 🟡
   - Primary buttons: 200-250pt → 280pt (Hub, Character Creation/Selection, Wave Complete, Game Over)
   - Secondary buttons: Keep 120-150pt (acceptable)

5. **Typography Fixes** 🟡
   - Screen titles: 36pt → 40-48pt (Character Creation/Selection, Wave Complete, Game Over)
   - Stats text: 14pt → 17pt (Character Card)

6. **Spacing Improvements** 🟢
   - Character Selection grid: 8pt → 16pt separation
   - Character Card HBox: 12pt → 16pt separation
   - Horizontal margins: 20pt → 24pt (where applicable)

### Polish Actions (Phase 6)

7. **Combat HUD Height Adjustments** 🟢
   - HP Bar: 35pt → 48pt height
   - XP Bar: 25pt → 40pt height

8. **Contrast Validation** 🟢
   - Calculate all contrast ratios vs WCAG AA
   - Verify gold title on dark brown ≥ 3:1 (large text)
   - Verify gray text ≥ 4.5:1 (body text)

---

## Phase 2+ Implementation Priority

### Week 16 Phase 2: Touch Targets & Buttons (3 hours)
- ✅ Fix Delete button width (50pt → 120pt)
- ✅ Fix Play button width (100pt → 280pt)
- ✅ Fix Details button width (80pt → 160pt)
- ✅ Standardize primary button widths across all screens (200-250pt → 280pt)
- ✅ Add 48×48pt pause button to Combat HUD

### Week 16 Phase 6: Spacing & Layout (1.5 hours)
- ✅ Create SafeAreaContainer component
- ✅ Apply SafeAreaContainer to all screens
- ✅ Fix grid separations (8pt → 16pt in Character Selection)

### Week 16 Phase 7: Combat HUD Mobile Optimization (2 hours)
- ✅ Move HP/Timer/Currency to 59pt from top
- ✅ Move XP bar to bottom (34pt from edge)
- ✅ Increase HP bar height (35pt → 48pt)
- ✅ Increase XP bar height (25pt → 40pt)
- ✅ Add pause button (48×48pt, top-right)
- ✅ Test on iPhone 15 Pro Max physical device

### Week 16 Phase 2: Typography System (2.5 hours)
- ✅ Increase screen titles (36pt → 40-48pt)
- ✅ Increase stats text (14pt → 17pt)
- ✅ Create Godot Theme resource with standardized sizes

### Week 16 Phase 5: Visual Feedback & Polish (2 hours)
- ✅ Validate contrast ratios (WCAG AA compliance)
- ✅ Add button press animations
- ✅ Add haptic feedback

---

## Success Metrics

**Phase 1 Complete** ✅
- [x] All screens audited
- [x] Gap analysis completed
- [x] Priority matrix created
- [x] Baseline screenshots captured

**Phase 2-7 Ready** 🎯
- [ ] 7 Critical issues identified (fix in Phase 2-3)
- [ ] 8 Medium issues identified (fix in Phase 3-5)
- [ ] 8 Low issues identified (fix in Phase 5-6)
- [ ] Clear implementation roadmap created

---

**Next Steps**: Begin Week 16 Phase 2 (Typography System Overhaul) and Phase 3 (Touch Target & Button Redesign)

**Estimated Total Effort**: 11.5 hours remaining (Phases 2-7)

---

**Report Generated**: 2025-11-18
**Baseline Screenshots**: `tests/visual_regression/baseline/*.png` (6 scenes captured)
