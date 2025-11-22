# Week 16 Phase 3.5 - Mid-Week Validation Checkpoint

**Date**: 2025-11-22
**Phase**: 3.5 (Mid-Week Validation Checkpoint)
**Estimated Time**: 0.5 hour
**Status**: In Progress

---

## Validation Objective

Validate that Phase 2 typography improvements create a **mobile-native experience** on real devices.

### What We're Testing

**Phase 2 Changes** (from [scripts/ui/character_selection.gd](../scripts/ui/character_selection.gd)):
- Character name: **22pt** (unchanged - header)
- Stat labels (HP/Speed/Regen): **16pt** (increased from 12pt) ⬆️ **KEY CHANGE**
- Description: **15pt** (increased from 13pt) ⬆️
- Aura labels: **14pt** (increased from 12pt) ⬆️

**Visual Hierarchy**: Name (22pt) > Stats (16pt) > Description (15pt) > Aura (14pt)

---

## Test Devices

**UPDATED 2025-11-22**: Support matrix changed to iPhone 12+ (iOS 15+) based on expert panel recommendation.

1. **iPhone 15 Pro Max** (6.7" display, 2796×1290, physical device)
   - Primary target device (largest supported)
   - Tests Dynamic Island
   - Tests latest iOS version

2. **iPhone 12 mini Simulator** (5.4" display, 2340×1080, simulator)
   - Minimum supported device size (smallest modern iPhone)
   - Tests smallest screen constraints in support matrix
   - Tests notch handling on compact device

---

## Validation Checklist

### Pre-Test Setup

- [ ] Export project to iOS (Debug build)
- [ ] Deploy to iPhone 15 Pro Max (physical device)
- [ ] Launch iPhone 8 simulator
- [ ] Deploy to iPhone 8 simulator
- [ ] Navigate to Character Selection screen on both devices

### Visual Inspection - iPhone 15 Pro Max

#### Character Cards - Overall Impression
- [ ] Cards feel "premium" and "mobile-native" (not desktop-ported)
- [ ] Stats are immediately visible and readable at arm's length
- [ ] Visual hierarchy is clear: Name > Stats > Description > Aura
- [ ] Can quickly scan and compare stats across multiple cards

#### Character Cards - Typography Details
- [ ] **Character Name (22pt)**: Clear header, properly emphasized
- [ ] **Stat Labels (16pt)**: Primary content, easy to read, "pops" visually
- [ ] **Description (15pt)**: Readable but de-emphasized (flavor text)
- [ ] **Aura Labels (14pt)**: Subtle metadata, not distracting

#### Layout & Spacing
- [ ] No text wrapping or overflow issues
- [ ] Stats don't feel cramped (85pt headroom confirmed in code)
- [ ] Cards are well-balanced (not text-heavy or sparse)
- [ ] Touch targets are comfortable (buttons already 60-200pt)

#### User Experience
- [ ] Stats are the natural first focus when scanning cards
- [ ] Can compare character stats without squinting
- [ ] Description provides context without overwhelming
- [ ] Overall impression: "This feels like a mobile game"

### Visual Inspection - iPhone 12 mini Simulator (5.4" compact)

#### Character Cards - Compact Screen Test
- [ ] All text is readable on 5.4" compact display
- [ ] No text wrapping or overflow (critical on smallest supported device)
- [ ] Stats remain prominent on compact screen
- [ ] Cards don't feel cluttered or cramped
- [ ] Visual hierarchy still clear on compact device

#### Layout Constraints
- [ ] Character selection grid displays correctly
- [ ] Cards fit within screen bounds
- [ ] No layout breaking or UI elements cut off
- [ ] Scrolling works smoothly if needed

### Comparative Analysis

#### Before vs After (Conceptual)
Since we don't have "before" screenshots on device:
- [ ] Do stats feel MORE prominent than typical mobile card UI?
- [ ] Is the hierarchy MORE clear than before (based on memory)?
- [ ] Does it feel like an improvement over "default Godot UI"?

#### Industry Comparison (Mental Reference)
Compare to mobile roguelite standards (Brotato, Slay the Spire):
- [ ] Stats prominence matches or exceeds industry standards
- [ ] Visual polish feels comparable to commercial mobile games
- [ ] Typography feels professional and intentional

---

## Success Criteria

### MUST PASS (Blocking)
- ✅ Stats are immediately readable on iPhone 15 Pro Max
- ✅ No text overflow/wrapping on iPhone 12 mini (smallest supported device)
- ✅ Visual hierarchy is clear: Name > Stats > Description > Aura
- ✅ Stats "pop" and are easy to compare across cards

### SHOULD PASS (Nice-to-have)
- ✅ Feels "mobile-native" vs "desktop-ported"
- ✅ Comparable polish to commercial mobile roguelites
- ✅ User can quickly make character selection decisions

### GO/NO-GO Decision

**GO** (Continue to Phase 4) if:
- All "MUST PASS" criteria met
- 2+ "SHOULD PASS" criteria met
- No critical usability issues discovered
- Changes represent meaningful improvement

**NO-GO** (Revisit Phase 2) if:
- Any "MUST PASS" criteria fails
- Critical layout issues on iPhone 12 mini
- Typography changes made readability worse
- Stats don't feel prominent enough for decision-making

---

## Testing Instructions

### Step 1: Deploy to iPhone 15 Pro Max

```bash
# In Godot Editor:
# 1. Project → Export → iOS (Debug)
# 2. Select iPhone 15 Pro Max as target
# 3. Build and deploy
# 4. Launch game on device
```

### Step 2: Test Character Selection (iPhone 15 Pro Max)

1. Launch game on iPhone 15 Pro Max
2. Navigate: Main Menu → Character Selection
3. View each character card (swipe/scroll through all)
4. **Take screenshots** of 2-3 representative cards
5. **Record observations** in validation report (see below)
6. Check each item in "Visual Inspection - iPhone 15 Pro Max" section

### Step 3: Deploy to iPhone 12 mini Simulator

```bash
# In Godot Editor:
# 1. Project → Export → iOS (Debug)
# 2. Select iPhone 12 mini simulator as target
# 3. Build and deploy
# 4. Launch simulator
# 5. Launch game in simulator
```

### Step 4: Test Character Selection (iPhone 12 mini Simulator)

1. Launch game in iPhone 12 mini simulator
2. Navigate: Main Menu → Character Selection
3. View each character card
4. **Take screenshots** of potential problem areas
5. **Record observations** in validation report
6. Check each item in "Visual Inspection - iPhone 12 mini Simulator" section

### Step 5: Document Findings

Fill out the validation report template (see `week16-phase3.5-validation-report.md`)

### Step 6: Make GO/NO-GO Decision

Based on validation results:
- **GO**: Proceed to Phase 4 (Dialog & Modal Patterns)
- **NO-GO**: Revisit Phase 2 typography, adjust font sizes, retest

---

## Common Issues to Watch For

### Red Flags 🚩

- Stats are NOT the first thing you notice (hierarchy broken)
- Text wraps or overflows on iPhone 8 (layout failure)
- Stats feel too small or hard to read at arm's length
- Cards feel cluttered or unbalanced
- Typography feels "random" vs "intentional"

### Green Flags ✅

- Stats immediately catch your eye (successful hierarchy)
- Text is crisp and readable on both devices
- Layout feels spacious and premium
- Can compare characters quickly without mental effort
- "Feels like a mobile app" vs "desktop UI on mobile"

---

## Validation Report Template

See: [week16-phase3.5-validation-report.md](week16-phase3.5-validation-report.md)

---

## Time Tracking

**Estimated**: 0.5 hour
**Actual**: ___ hours

**Breakdown**:
- Export and deploy: ___ min
- iPhone 15 Pro Max testing: ___ min
- iPhone 8 simulator testing: ___ min
- Documentation: ___ min
- GO/NO-GO decision: ___ min

---

## Next Steps

### If GO Decision
- Update validation report with "PASS" status
- Commit validation report
- Proceed to Phase 4: Dialog & Modal Patterns
- Update `.system/NEXT_SESSION.md`

### If NO-GO Decision
- Document specific issues in validation report
- Return to Phase 2 with specific typography adjustments
- Retest after fixes
- Do not proceed to Phase 4 until validation passes

---

**Created**: 2025-11-22
**Last Updated**: 2025-11-22
