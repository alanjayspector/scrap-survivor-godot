# Next Session: Phase 8.2c - Art Bible Hub Transformation

**Date**: 2025-11-25
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Revised Plan**: [docs/design/phase-8-revised-plan.md](../docs/design/phase-8-revised-plan.md)
**Current Phase**: Phase 8.2c - Hub Visual Transformation
**Status**: 🔄 **ORIENTATION CORRECTED** - Ready for Implementation

---

## 🔄 CRITICAL CORRECTION (2025-11-25)

### Previous Error: Portrait Orientation
- Plan incorrectly specified portrait (9:16) orientation
- Would have required phone rotation between hub and combat
- **Root cause**: Planning error, not original intent

### Corrected Approach: Landscape Throughout
- **All scenes = Landscape** (consistent with combat/wasteland)
- **Controller support** requires landscape
- **Matches Brotato/Vampire Survivors** conventions
- **Uses existing concept art** directly (already landscape)

### Key Discovery
The existing `scrap-town-sancturary.png` (2752×1536) is:
- Already landscape orientation ✅
- Higher resolution than needed (exceeds 1920×1080 base) ✅
- Perfect Art Bible style (no generation needed) ✅

**Massive scope reduction: Skip art generation entirely.**

---

## 📱 Mobile Screen Standards (2024-2025 Research)

### Target Aspect Ratios (Landscape)

| Aspect | Devices | Priority |
|--------|---------|----------|
| 16:9 | Baseline, older devices | Must support |
| 18:9 / 18.5:9 | Modern Android | Must support |
| 19.5:9 | iPhone 12-15 series | Must support |
| 20:9 | Flagship Android 2023-2025 | Must support |
| 21:9 | Gaming phones (ROG, etc.) | Nice to have |

### Godot 4 Project Settings

```
[display]
window/size/viewport_width = 1920
window/size/viewport_height = 1080
window/stretch/mode = "canvas_items"
window/stretch/aspect = "expand"
```

**Rationale**:
- `canvas_items` mode: Best for non-pixel-art games, smooth scaling
- `expand` aspect: No black bars, reveals more content on wider screens
- 1920×1080 base: Industry standard, good design target

### Safe Area Handling
- iPhone notch: ~44pt top, ~34pt bottom (home indicator)
- Android punch-hole: Varies, typically corner
- **Already implemented** in Phase 6 ✅

---

## 📋 Revised Session Plan (LANDSCAPE)

| Session | Focus | Time | Status |
|---------|-------|------|--------|
| **Session 1** | Background Integration + Settings | 1h | ⏭️ **NOW** |
| **Session 2** | Button Integration (IconButton component) | 1.5-2h | Pending |
| **Session 3** | Polish & 10-Second Test | 1h | Pending |

**Total Remaining**: 3-4 hours (reduced from 5-6)

---

## 🚀 SESSION 1: Background Integration

**Objective**: Set up hub with existing concept art as background

### Tasks

1. **Verify/Update Godot Project Settings**
   - Confirm stretch mode = `canvas_items`
   - Confirm stretch aspect = `expand`
   - Base resolution = 1920×1080

2. **Import Background Asset**
   - Source: `art-docs/scrap-town-sancturary.png` (2752×1536)
   - Destination: `assets/hub/backgrounds/scrapyard_hub.png`
   - Import settings: Lossy compression for mobile performance

3. **Update Scrapyard Scene**
   - Add TextureRect as background layer
   - Stretch mode: "Keep Aspect Covered" (fills screen, may crop edges)
   - Anchor: Full Rect
   - Ensure it's behind all UI elements

4. **Test Multiple Aspect Ratios**
   - 16:9 (1920×1080) - baseline
   - 19.5:9 (2340×1080) - iPhone
   - 20:9 (2400×1080) - modern Android

5. **Device QA**
   - Visual quality on iPhone
   - No banding or compression artifacts
   - Performance check (texture load time)

### QA Gate Checklist

- [ ] Background displays correctly at 16:9
- [ ] Background handles 19.5:9 without breaking
- [ ] Background handles 20:9 without breaking
- [ ] Safe areas still work correctly
- [ ] No performance regression
- [ ] User approval: "This looks like our Art Bible"

---

## 📁 Reference Files

**Art Assets**:
- `art-docs/scrap-town-sancturary.png` - Hub background (USE THIS)
- `art-docs/buttons-signs.png` - UI kit for Session 2

**Icon Assets** (Ready for Session 2):
- `assets/icons/hub/icon_start_run_final.svg` ✅
- `assets/icons/hub/icon_roster_final.svg` ✅
- `assets/icons/hub/icon_settings_final.svg` ✅

---

## 🎯 Button Placement Strategy (Session 2)

**"Hybrid Diegetic Floating"** - Buttons float over scene but positions suggest world geography:

| Button | Position | Size | Rationale |
|--------|----------|------|-----------|
| **Start Run** | Center-right (toward gate) | 120×120pt | Primary action |
| **Roster** | Left side (toward barracks) | 80×80pt | Secondary action |
| **Settings** | Top-right corner | 50×50pt | Utility, universal convention |

**Button Style**: Metal plate from `buttons-signs.png` (orange primary, weathered edges)

---

## ✅ What's Already Complete

**From Previous Sessions**:
- ✅ Phase 8.1: Wasteland color palette defined
- ✅ Phase 8.2a: Research & reference gathering
- ✅ Phase 8.2b: Icon design complete (3 SVG icons)
- ✅ Expert panel review of existing art assets
- ✅ Orientation correction (portrait → landscape)

---

## 📊 Week 16 Progress

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 0-1 | ✅ Done | Infrastructure, audit |
| Phase 2 | ✅ ~90% | Typography via Theme System |
| Phase 3 | ✅ ~85% | Button styles + animations |
| Phase 4 | 🟡 ~60% | Modal works, missing progressive confirm |
| Phase 5 | ✅ ~80% | Haptics + animations done |
| Phase 6 | ✅ Done | Safe area implementation |
| Phase 7 | ✅ Done | Combat HUD optimized |
| **Phase 8** | 🔨 **IN PROGRESS** | Visual Identity - 8.1, 8.2a, 8.2b done |

**Overall**: ~85% complete, only Phase 8.2c remains

---

## 🔧 Development Environment

**Platform**: macOS (MacBook Pro)
**Project Path**: `/Users/alan/Developer/scrap-survivor-godot`
**Engine**: Godot 4, GDScript

**Git Status**:
- Branch: main
- Latest Commit: `9b9c27d` - feat(ui): complete Phase 8.2b icon design

---

## 📝 Session Handoff Notes

### Lessons Learned
1. **Always confirm orientation** before generating art
2. **Check existing assets** before building from scratch
3. **Portrait mode was a planning error** - game was always intended landscape
4. Controller support requires landscape orientation

### Key Decisions Made (2025-11-25)
1. **Orientation**: Landscape throughout (corrected from portrait error)
2. **Art approach**: Use existing concept art (no generation needed)
3. **Stretch settings**: `canvas_items` + `expand` (industry standard)
4. **Base resolution**: 1920×1080 (covers 16:9 to 21:9 range)

### What NOT to Do
- ❌ Don't generate portrait art (wrong orientation)
- ❌ Don't use black bars (expand handles aspect ratios)
- ❌ Don't assume planning docs are correct without verification

---

## 🚀 Quick Start Command

```
SESSION 1 READY (Background Integration)

ORIENTATION: LANDSCAPE (corrected from portrait error)
ART GENERATION: NOT NEEDED (use existing concept art)

TASKS:
1. Verify Godot project settings (stretch mode/aspect)
2. Import art-docs/scrap-town-sancturary.png to assets/hub/backgrounds/
3. Update scrapyard.tscn with TextureRect background
4. Test at multiple aspect ratios (16:9, 19.5:9, 20:9)
5. Device QA
6. Get user approval

SETTINGS TO VERIFY:
- window/stretch/mode = "canvas_items"
- window/stretch/aspect = "expand"
- Base resolution = 1920×1080

ESTIMATED TIME: 1 hour
```

---

**Last Updated**: 2025-11-25
**Status**: Session 1 Ready (Background Integration)
**Next Action**: Verify project settings, import background
**Estimated Time**: 1 hour
