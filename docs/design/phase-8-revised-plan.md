# Phase 8 REVISED Plan - Art Bible Visual Identity

**Document Created**: 2025-11-24
**Last Updated**: 2025-11-25 (Orientation Correction)
**Status**: APPROVED - LANDSCAPE ORIENTATION CONFIRMED
**Replaces**: Original Phase 8 "Metal Wall" approach (FAILED QA)

---

## 🔄 CRITICAL UPDATES

### Update 2 (2025-11-25): Orientation Correction

**Error Identified**: Previous revision incorrectly specified portrait (9:16) orientation.

**Root Cause**: Planning error. Game was always intended to be landscape throughout:
- Combat/Wasteland = Landscape
- Hub = Should also be Landscape (not portrait)
- Controller support requires landscape orientation
- Rotating phone between scenes = poor UX

**Correction**: All scenes are **LANDSCAPE**. Existing concept art is already landscape and can be used directly.

**Impact**: 
- Skip art generation entirely (existing art is perfect)
- Session 1 reduced from 1.5-2h to ~1h
- No Banana Nano needed

### Update 1 (2025-11-24): Metal Wall → Art Bible

**Original Phase 8.2c Direction** (Sessions 1-2):
- ColorRect-based procedural metal wall
- Programmatic rivets, seams, rust overlays
- User feedback: "looks flat", "doesn't convey fortress", "reads as grid"
- **QA Gate FAILED**

**Solution**: Use existing concept art that already captures Art Bible vision.

---

## 📱 Mobile Screen Standards (2024-2025)

### Target Aspect Ratios (Landscape)

| Aspect | Resolution Example | Devices | Support |
|--------|-------------------|---------|---------|
| **16:9** | 1920×1080 | Baseline, older devices, tablets | ✅ Required |
| **18:9** | 2160×1080 | Transitional Android | ✅ Required |
| **18.5:9** | 2220×1080 | Samsung Galaxy S8-S9 era | ✅ Required |
| **19.5:9** | 2340×1080 | iPhone 12-15 series | ✅ Required |
| **20:9** | 2400×1080 | Modern flagship Android | ✅ Required |
| **21:9** | 2520×1080 | Gaming phones (ROG, Red Magic) | ⚪ Nice to have |

### Godot 4 Project Settings (MANDATORY)

```gdscript
# project.godot - Display settings
[display]
window/size/viewport_width = 1920
window/size/viewport_height = 1080
window/stretch/mode = "canvas_items"
window/stretch/aspect = "expand"
```

**Setting Rationale**:

| Setting | Value | Why |
|---------|-------|-----|
| `viewport_width` | 1920 | Industry standard base width |
| `viewport_height` | 1080 | 16:9 baseline, most compatible |
| `stretch/mode` | `canvas_items` | Best for non-pixel-art, smooth scaling |
| `stretch/aspect` | `expand` | No black bars, reveals more on wider screens |

### How "expand" Handles Different Aspects

```
16:9 device:  [========GAME========]     (full art visible)
19.5:9 device: [====GAME====|+extra+]    (reveals more width)
20:9 device:  [===GAME===|++extra++]     (reveals even more)
```

**Key insight**: With `expand`, we don't crop - we reveal MORE content on wider screens. This means our 2752×1536 art (which is wider than 16:9) will show more of the scene on modern phones.

---

## 🎨 Art Asset Analysis

### Existing Concept Art

| Asset | Resolution | Aspect | Usability |
|-------|-----------|--------|-----------|
| `scrap-town-sancturary.png` | 2752×1536 | ~16:9 | ✅ **USE DIRECTLY** |
| `buttons-signs.png` | - | - | ✅ UI kit reference |
| `wasteland-gate.png` | - | - | Future: Start Run visual |

### Why Existing Art Works

1. **Resolution**: 2752×1536 exceeds our 1920×1080 base (1.43x larger)
2. **Aspect**: ~16:9, compatible with all target devices
3. **Style**: Already matches Art Bible perfectly (it IS the Art Bible reference)
4. **Quality**: High-detail painterly style, visible brushwork

### Import Strategy

```
Source: art-docs/scrap-town-sancturary.png (2752×1536, 6MB)
Destination: assets/hub/backgrounds/scrapyard_hub.png
Compression: Lossy (mobile performance)
Filter: Linear (smooth scaling)
```

---

## 📋 Revised Phase 8.2c Implementation Plan

### Overview

**Total Estimated Time**: 3-4 hours (down from original 9-11 hours)
**Approach**: Asset-driven (use existing art directly)

### Session Breakdown

| Session | Focus | Time | Status |
|---------|-------|------|--------|
| **Session 1** | Background Integration + Settings | 1h | ⏭️ **NEXT** |
| **Session 2** | Button Integration (IconButton) | 1.5-2h | Pending |
| **Session 3** | Polish & 10-Second Test | 1h | Pending |

---

### SESSION 1: Background Integration

**Estimated Time**: 1 hour

**Objective**: Set up hub scene with existing concept art as background

**Tasks**:

1. **Verify Godot Project Settings**
   ```
   Project → Project Settings → Display → Window
   - Viewport Width: 1920
   - Viewport Height: 1080
   - Stretch Mode: canvas_items
   - Stretch Aspect: expand
   ```

2. **Import Background Asset**
   - Copy `art-docs/scrap-town-sancturary.png` to `assets/hub/backgrounds/`
   - Rename to `scrapyard_hub.png` (fix typo)
   - Configure import settings for mobile

3. **Update Scrapyard Scene**
   ```
   Scrapyard (Control - full rect)
   ├── Background (TextureRect)
   │   - texture = scrapyard_hub.png
   │   - stretch_mode = "Keep Aspect Covered"
   │   - anchors = full rect
   └── UILayer (CanvasLayer)
       └── ScreenContainer (existing)
   ```

4. **Test Multiple Aspect Ratios**
   - Resize editor window to simulate:
     - 16:9 (1920×1080)
     - 19.5:9 (2340×1080)
     - 20:9 (2400×1080)

5. **Device QA**

**QA Gate Checklist**:
- [ ] Project settings correct (canvas_items + expand)
- [ ] Background displays at all aspect ratios without breaking
- [ ] Art maintains quality (no compression artifacts)
- [ ] Safe areas still function
- [ ] Performance acceptable (< 100ms load)
- [ ] User approval

---

### SESSION 2: Button Integration

**Estimated Time**: 1.5-2 hours

**Objective**: Position icon buttons on hub using Art Bible UI kit styling

**Button Assets** (from Phase 8.2b):
- `assets/icons/hub/icon_start_run_final.svg` ✅
- `assets/icons/hub/icon_roster_final.svg` ✅
- `assets/icons/hub/icon_settings_final.svg` ✅

**Button Style** (from `buttons-signs.png` reference):
- Metal plate background (orange for primary)
- Weathered/scratched texture
- Dark border with slight bevel
- Drop shadow for depth

**Button Placement** ("Hybrid Diegetic Floating"):

| Button | Position | Size | Visual Anchor |
|--------|----------|------|---------------|
| **Start Run** | Right-center | 120×120pt | Toward gate area |
| **Roster** | Left-center | 80×80pt | Toward barracks |
| **Settings** | Top-right | 50×50pt | Universal convention |

**Implementation**:

1. Create `IconButton` component (if not exists)
2. Style buttons to match Art Bible UI kit
3. Position using anchors + safe area offsets
4. Wire up navigation signals
5. Test touch targets (≥44pt)

**QA Gate Checklist**:
- [ ] Buttons visible and readable on background
- [ ] Button hierarchy clear (Start Run = hero)
- [ ] Touch targets adequate
- [ ] Navigation functional
- [ ] Style matches Art Bible

---

### SESSION 3: Polish & Validation

**Estimated Time**: 1 hour

**Objective**: Final polish and 10-Second Impression Test

**Polish Tasks**:
1. Button press feedback (scale + haptic)
2. Hover/focus states for controller
3. Transition animation when leaving hub

**10-Second Impression Test**:

Show hub screenshot to someone unfamiliar with project:

1. "What genre is this game?" → Target: "Roguelite", "Survivor"
2. "What's the setting?" → Target: "Post-apocalyptic", "Wasteland"
3. "Does this look professional?" → Target: "Yes"
4. "Would you pay $10?" → Target: "Yes" or "Probably"
5. "Which button starts the game?" → Target: Points to Start Run

**Pass Criteria**: 4/5 positive responses

---

## 🎯 Success Criteria: Phase 8.2c Complete

**All must be TRUE**:

- [ ] Hub background uses Art Bible concept art
- [ ] Background handles 16:9 to 20:9 aspect ratios
- [ ] Stretch settings = canvas_items + expand
- [ ] Icon buttons integrated with Art Bible styling
- [ ] Button positions work across aspect ratios
- [ ] Start Run is clearly the primary action
- [ ] 10-Second Impression Test passed (4/5)
- [ ] User declares: "This looks like a real indie game"

---

## 📝 Files to Create/Modify

**New Files**:
- `assets/hub/backgrounds/scrapyard_hub.png` - Copied from art-docs
- `scripts/ui/components/icon_button.gd` - Reusable component (if needed)
- `scenes/ui/components/icon_button.tscn` - Component scene (if needed)

**Modified Files**:
- `project.godot` - Verify stretch settings
- `scenes/hub/scrapyard.tscn` - Add background + buttons
- `scripts/hub/scrapyard.gd` - Button logic

**Reference Files** (read-only):
- `art-docs/Scrapyard_Scene_Art_Bible.md` - Style guide
- `art-docs/scrap-town-sancturary.png` - Background source
- `art-docs/buttons-signs.png` - UI kit reference

---

## 🚀 Quick Start for Next Session

```
✅ Orientation Correction COMPLETE (portrait → landscape)
✅ Existing art confirmed usable
⏭️ NEXT: Session 1 - Background Integration

NO ART GENERATION NEEDED - Use existing scrap-town-sancturary.png

SESSION 1 TASKS:
1. Verify project.godot stretch settings
2. Copy art-docs/scrap-town-sancturary.png to assets/hub/backgrounds/
3. Add TextureRect background to scrapyard.tscn
4. Test multiple aspect ratios (16:9, 19.5:9, 20:9)
5. Device QA
6. User approval

GODOT SETTINGS TO VERIFY:
- display/window/size/viewport_width = 1920
- display/window/size/viewport_height = 1080  
- display/window/stretch/mode = "canvas_items"
- display/window/stretch/aspect = "expand"

ESTIMATED TIME: 1 hour
```

---

**Document Version**: 2.0
**Created**: 2025-11-24
**Updated**: 2025-11-25 (Orientation correction)
**Author**: Expert Panel (Claude)
**Status**: APPROVED - Ready for Implementation
