# Week 16 Phase 2 & 3 QA Testing Plan

**Date**: 2025-11-18
**Tester**: Alan
**Device**: iPhone 15 Pro Max (or similar)
**Branch**: `feature/week16-mobile-ui`
**Commits**:
- Phase 2: `e4f61e2` - Typography improvements
- Phase 3: `a564142` - Touch target & button redesign

---

## ⚠️ **Known Issues Before Testing**

1. **Pause button is non-functional** - Only UI added, no signal connection
2. **Phase 2 changes may be imperceptible** - 3pt font increase (14pt→17pt) is subtle
3. **Visual regression baseline broken** - Cannot do automated comparison

---

## 📏 **Phase 2: Typography Changes (BEFORE → AFTER)**

### What Changed:
| Screen | Element | Before | After | Difference |
|--------|---------|--------|-------|------------|
| All screens | Screen titles | 36pt | 40pt | +4pt (11% increase) |
| Character Card | Stats text | 14pt | 17pt | +3pt (21% increase) |

### How to Verify:

#### Test 1: Screen Title Size (40pt)
**Screens to check**: Character Creation, Character Selection, Wave Complete, Game Over

1. Open each screen
2. **Visual check**: Title should be clearly visible
3. **Comparison**: Compare to Brotato (titles are 48pt there - ours are 40pt)
4. **Verdict**: ✅ Meets iOS HIG minimum (34pt), but conservative vs Brotato

**Expected Result**: Titles should be readable but not dramatically larger than before.

#### Test 2: Character Card Stats Text (17pt)
**Screen**: Character Roster (any character card)

1. Create a character if needed
2. View the stats line: "Level X • Best Wave Y"
3. **Visual check**: Should be readable at arm's length
4. **Measurement**: Use iOS Accessibility > Display & Text Size > Larger Text to compare
5. **Verdict**: Meets iOS HIG 17pt minimum, but QA feedback said "still looks small"

**Expected Result**: Subtle improvement - may not be perceptible without side-by-side.

---

## 🎯 **Phase 3: Touch Targets & Buttons (BEFORE → AFTER)**

### What Changed:

#### TIER 1 - Critical Safety Fixes

| Element | Screen | Before | After | Difference | Impact |
|---------|--------|--------|-------|------------|--------|
| Delete button (✕) | Character Card | 50pt | 120pt | **+140%** | Safety - prevents accidental deletion |
| Pause button | Combat HUD | Missing | 48×48pt | New feature | Gameplay essential |
| Character grid spacing | Character Selection | 8pt | 16pt | **+100%** | Prevents accidental selection |

#### TIER 2 - Primary Action Buttons (All → 280pt width)

| Button | Screen | Before | After | Difference |
|--------|--------|--------|-------|------------|
| Play | Character Card | 100pt | 280pt | **+180%** |
| Play/Characters/Settings | Hub (Scrapyard) | 200pt | 280pt | +40% |
| Create Survivor | Character Creation | 200pt | 280pt | +40% |
| Hub/Next Wave | Wave Complete | 180pt | 280pt | +56% |
| Retry/Main Menu | Game Over | 180pt | 280pt | +56% |

#### TIER 3 - Secondary Actions

| Button | Screen | Before | After | Difference |
|--------|--------|--------|-------|------------|
| Details | Character Card | 80pt | 160pt | **+100%** |
| Create New Survivor | Character Roster | 250pt | 280pt | +12% |
| Back/Wasteland | Character Selection | 200-250pt | 280pt | +12-40% |

---

## 🧪 **Step-by-Step Testing Protocol**

### Test 1: Delete Button Safety (MOST VISIBLE CHANGE)

**Screen**: Character Roster → Character Card

**BEFORE** (from screenshot `character-roster.png`):
- Delete button (✕) is very narrow - approximately 50pt
- High risk of accidental tap

**AFTER** (Phase 3):
1. Open Character Roster
2. Look at the character card
3. **Measure**: Delete button (✕) should be noticeably wider
4. **Finger test**: Rest your finger on the button - should cover it comfortably
5. **Comparison**: Button should be ~2.4x wider than before

**Expected Result**: Delete button should be **OBVIOUSLY wider** - this is the most perceptible change.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 2: Character Card Play Button (VERY VISIBLE)

**Screen**: Character Roster → Character Card

**BEFORE**:
- Play button appears narrow (100pt)

**AFTER**:
1. Open Character Roster
2. Look at the character card
3. **Measure**: Play button should be much wider (280pt)
4. **Visual check**: Should be the most prominent button on the card
5. **Comparison**: Should be 2.8x wider than before

**Expected Result**: Play button should dominate the right side of the character card.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 3: Hub Primary Buttons

**Screen**: Scrapyard (Main Hub)

**BEFORE**:
- Play, Characters, Settings buttons were 200pt wide

**AFTER**:
1. Open Scrapyard
2. Look at the three main buttons
3. **Visual check**: Buttons should appear substantial and easy to tap
4. **Comparison**: Should be ~40% wider than before

**Expected Result**: Moderate increase - might be subtle.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 4: Combat HUD Pause Button (NEW FEATURE)

**Screen**: Wasteland (in combat)

**BEFORE**: No pause button existed

**AFTER**:
1. Start a combat session (Wasteland)
2. Look at top-right corner
3. **Visual check**: Should see "⏸" button at top-right
4. **Position check**: Should be 59pt from top (below notch), 24pt from right edge
5. **Size check**: 48×48pt - comfortable tap target

⚠️ **KNOWN ISSUE**: Button is visible but **NOT FUNCTIONAL** - tapping won't pause the game.

**Expected Result**: Button should be visible but won't do anything yet.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 5: Character Selection Grid Spacing

**Screen**: Character Selection (when choosing character to play)

**BEFORE**:
- Character cards had 8pt spacing between them
- Risk of selecting wrong character

**AFTER**:
1. Open Character Selection screen (needs 2+ characters)
2. Look at the grid of character cards
3. **Visual check**: Should be more space between cards
4. **Finger test**: Try tapping between cards - should have clear separation

**Expected Result**: Spacing should be doubled (16pt) - might be subtle.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 6: Wave Complete Buttons

**Screen**: Wave Complete (after completing a wave)

**BEFORE**:
- Hub/Next Wave buttons were 180pt wide

**AFTER**:
1. Complete a wave in combat
2. Look at the Wave Complete screen
3. **Visual check**: Hub and Next Wave buttons should be wider
4. **Comparison**: Should be ~56% wider

**Expected Result**: Moderate increase - might be subtle.

**✅ PASS / ❌ FAIL**: _______________

---

### Test 7: Game Over Buttons

**Screen**: Game Over (after dying)

**BEFORE**:
- Retry/Main Menu buttons were 180pt wide

**AFTER**:
1. Die in combat (or trigger Game Over)
2. Look at Game Over screen
3. **Visual check**: Retry and Main Menu buttons should be wider
4. **Comparison**: Should be ~56% wider

**Expected Result**: Moderate increase - might be subtle.

**✅ PASS / ❌ FAIL**: _______________

---

## 📊 **Expected Perceptibility**

### **VERY OBVIOUS** (You should definitely see these):
- ✅ **Delete button width** (50pt → 120pt) - **140% increase**
- ✅ **Character Card Play button** (100pt → 280pt) - **180% increase**
- ✅ **Pause button** (new feature - visible at top-right)

### **MODERATE** (You might notice these):
- 📏 **Hub buttons** (200pt → 280pt) - 40% increase
- 📏 **Wave Complete/Game Over buttons** (180pt → 280pt) - 56% increase
- 📏 **Character grid spacing** (8pt → 16pt) - 100% increase

### **SUBTLE** (May not be perceptible without measurement):
- 📏 **Screen titles** (36pt → 40pt) - 11% increase
- 📏 **Stats text** (14pt → 17pt) - 21% increase
- 📏 **Create New Survivor button** (250pt → 280pt) - 12% increase

---

## 🔍 **Measurement Tools**

### Option 1: iOS Screenshot Markup
1. Take screenshot
2. Open in Photos
3. Tap Edit → Markup
4. Use ruler tool to measure button widths
5. 1 point (pt) ≈ 1 pixel at 1x scale

### Option 2: Physical Measurement
1. Use a ruler on the screen
2. Measure button width in mm
3. Compare before/after screenshots

### Option 3: Godot Editor
1. Open the scene files in Godot
2. Select the button nodes
3. Check `custom_minimum_size` property
4. Verify the values match the expected sizes

---

## 🎯 **Success Criteria**

### Phase 2 (Typography):
- ✅ All screen titles should be 40pt (check in Godot editor)
- ✅ Character Card stats text should be 17pt (check in Godot editor)
- ⚠️ **Visual difference may be imperceptible** - this is expected for small font size changes

### Phase 3 (Touch Targets):
- ✅ Delete button should be **obviously wider** (50pt → 120pt)
- ✅ Character Card Play button should be **very wide** (100pt → 280pt)
- ✅ All primary buttons should be 280pt wide
- ✅ Pause button should be visible at top-right
- ✅ Grid spacing should be doubled (8pt → 16pt)

---

## 🚨 **What To Do If You Can't See Differences**

### Option 1: Compare in Godot Editor
The **most reliable** way to verify changes:

1. Open Godot editor
2. Open a scene file (e.g., `scenes/ui/character_card.tscn`)
3. Select a button node (e.g., `DeleteButton`)
4. Check the Inspector → `custom_minimum_size` property
5. Verify the values:
   - Delete button: should be `(120, 60)`
   - Play button: should be `(280, 60)`
   - Details button: should be `(160, 60)`

### Option 2: Git Diff Verification
Check the actual code changes:

```bash
# View Phase 3 changes
git diff e4f61e2..a564142 scenes/ui/character_card.tscn

# Look for lines like:
# -custom_minimum_size = Vector2(50, 60)    # BEFORE
# +custom_minimum_size = Vector2(120, 60)   # AFTER
```

### Option 3: Create Before/After Screenshots
1. Checkout the commit before Phase 3: `git checkout e4f61e2`
2. Take screenshots of each screen
3. Checkout Phase 3: `git checkout a564142`
4. Take screenshots again
5. Compare side-by-side in an image editor

---

## 🤔 **Why You Might Not See Big Differences**

### 1. **Dynamic Layout**
Godot's UI system uses flexible layouts - buttons might expand to fill available space, making width changes less obvious.

### 2. **Screen Resolution**
On high-DPI displays (like iPhone 15 Pro Max), point sizes are scaled. A 280pt button might not look dramatically different from a 200pt button.

### 3. **Conservative Changes**
The Phase 2 typography changes (3-4pt) are intentionally conservative to meet iOS HIG minimums, not Brotato's more aggressive sizing.

### 4. **Aspect Ratio**
In landscape mode, buttons have more horizontal space, so width increases might not be as noticeable.

---

## 📝 **QA Findings Template**

**Date**: _______________
**Device**: _______________
**iOS Version**: _______________

### Phase 2 Typography:
- Screen titles (40pt): ☐ Verified ☐ Not perceptible ☐ Failed
- Stats text (17pt): ☐ Verified ☐ Not perceptible ☐ Failed

### Phase 3 Critical Fixes:
- Delete button (120pt): ☐ **Obviously wider** ☐ Subtle ☐ Failed
- Pause button (48×48pt): ☐ Visible ☐ Missing ☐ Wrong position
- Grid spacing (16pt): ☐ More space ☐ No difference ☐ Failed

### Phase 3 Primary Buttons (280pt):
- Character Card Play: ☐ Very wide ☐ Subtle ☐ Failed
- Hub buttons: ☐ Wider ☐ Subtle ☐ Failed
- Wave Complete buttons: ☐ Wider ☐ Subtle ☐ Failed
- Game Over buttons: ☐ Wider ☐ Subtle ☐ Failed

### Overall Assessment:
- **Phase 2 impact**: ☐ Noticeable ☐ Subtle ☐ Imperceptible
- **Phase 3 impact**: ☐ Significant ☐ Moderate ☐ Minimal
- **Recommendation**: ☐ Proceed to Phase 4 ☐ Revisit changes ☐ Abandon approach

### Notes:
_______________________________________________________
_______________________________________________________
_______________________________________________________

---

## 🎯 **Next Steps Based on Results**

### If changes are **perceptible and valuable**:
- ✅ Proceed to Phase 4 (Dialog & Modal Patterns)
- Document successful changes
- Capture new baseline screenshots

### If changes are **subtle but correct**:
- ⚠️ Consider more aggressive sizing (Brotato uses 280pt buttons consistently)
- Consider bumping typography further (20pt stats text vs 17pt)
- Proceed to Phase 4 but flag for potential revision

### If changes are **imperceptible**:
- 🚨 **STOP** and reassess approach
- Consider reverting to original sizes
- Discuss alternative mobile UI strategy
- Do NOT proceed to Phase 4 until strategy is clarified

---

**End of QA Plan**
