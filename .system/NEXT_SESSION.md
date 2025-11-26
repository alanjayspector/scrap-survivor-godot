# Next Session: Phase 8.2c - Session 3 (Final Polish)

**Date**: 2025-11-26
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Revised Plan**: [docs/design/phase-8-revised-plan.md](../docs/design/phase-8-revised-plan.md)
**Current Phase**: Phase 8.2c - Hub Visual Transformation (Session 3)
**Status**: ✅ **SESSIONS 1 & 2 COMPLETE** - Session 3 Ready

---

## ✅ COMPLETED SESSIONS

### Session 1: Background Integration (2025-11-25) ✅

**Commits**:
- `48a792c` - feat(hub): replace ColorRect background with Art Bible concept art

**What Was Done**:
1. ✅ Verified Godot project settings (canvas_items + expand)
2. ✅ Imported `scrap-town-sancturary.png` to `assets/hub/backgrounds/scrapyard_hub.png`
3. ✅ Added TextureRect background with ExpandMode.IGNORE_SIZE + stretch
4. ✅ Fixed orientation issue (rotation = -90° for landscape display)
5. ✅ Tested at 16:9, 19.5:9, 20:9 aspect ratios
6. ✅ User approval obtained

**Key Fix**: Background image was portrait-oriented in file but displays landscape in game via -90° rotation.

---

### Session 2: IconButton Component (2025-11-25) ✅

**Commits**:
- `7316009` - feat(ui): add IconButton component with Art Bible styling

**What Was Done**:
1. ✅ Created reusable `IconButton` component (`scripts/ui/components/icon_button.gd`)
2. ✅ Three size variants: Small (50pt), Medium (80pt), Large (120pt)
3. ✅ Three style variants: Primary, Secondary, Danger
4. ✅ Art Bible styling: rust orange, beveled edges, drop shadow
5. ✅ Integrated with existing ButtonAnimation for press feedback
6. ✅ Added comprehensive test suite (27 tests)
7. ✅ Updated scrapyard hub to use IconButton for navigation
8. ✅ Positioned buttons using "Hybrid Diegetic Floating" approach
9. ✅ Fixed asset validator to allow larger backgrounds (8MB vs 2MB sprites)

**Button Positions**:
| Button | Anchor | Size | Variant |
|--------|--------|------|---------|
| Start Run | Right-center (0.85, 0.5) | LARGE (120pt) | PRIMARY |
| Roster | Left-center (0.15, 0.5) | MEDIUM (80pt) | SECONDARY |
| Settings | Top-right (1.0, 0.0) | SMALL (50pt) | SECONDARY |

---

## 📋 SESSION 3: Entry Point + Polish + 10-Second Test (CURRENT)

**Estimated Time**: ~65 minutes

**Objective**: Change app entry point to Hub, add stub messages for character selection, polish, validate

### Refined Scope (Expert Panel Approved)

| Task | Time | Priority |
|------|------|----------|
| Change entry point → Hub | 15 min | 🔴 HIGH |
| Rename button label "Roster" → "Barracks" | 5 min | 🔴 HIGH |
| Settings button "Coming Soon" toast | 10 min | 🔴 HIGH |
| Start Run stub check (if no characters → toast) | 15 min | 🔴 HIGH |
| Haptic feedback validation on device | 10 min | 🔴 HIGH |
| 10-Second Impression Test | 10 min | 🔴 HIGH |
| **Total** | **~65 min** | |

### Terminology Changes (This Session)
- **Roster** → **Barracks** (button label only, scene rename in Phase 9)
- **Characters** → **Survivors** (messaging only, full update in Phase 9)
- **Create Character** → **Recruit** (messaging only)

### Stub Message Logic

**Start Run Button** (scrapyard.gd):
```
IF no characters exist:
    → Toast: "Recruit a survivor at the Barracks first"
    → Do NOT launch wasteland
ELSE IF no character selected (active_character_id empty):
    → Toast: "Select a survivor at the Barracks first"  
    → Do NOT launch wasteland
ELSE:
    → Launch wasteland with selected survivor
```

**Note**: Full selection persistence is Phase 9 work. For now, use runtime `GameState.active_character_id`.

### Explicitly Deferred to Phase 9

- ⏭️ Persist `active_character_id` in save data
- ⏭️ Add "Select" button to Barracks detail view
- ⏭️ Add Survivor Status Panel to Hub (visual indicator)
- ⏭️ Barracks Art Bible transformation (background + polish)
- ⏭️ Full scene/file rename: character_roster → barracks
- ⏭️ Controller focus states

### QA Gate Checklist (Session 3)

- [ ] App launches to Hub (not Character Roster)
- [ ] Button label shows "Barracks" (not "Roster")
- [ ] Settings button shows "Coming Soon" toast
- [ ] Start Run with no characters → "Recruit a survivor" toast
- [ ] Start Run with characters but none selected → "Select a survivor" toast
- [ ] Haptic feedback works on device
- [ ] Button press animations smooth
- [ ] 10-Second Impression Test passed (4/5)
- [ ] User declares: "This looks like a real indie game"

### 10-Second Impression Test Questions

1. "What genre is this game?" → Target: "Roguelite", "Survivor"
2. "What's the setting?" → Target: "Post-apocalyptic", "Wasteland"
3. "Does this look professional?" → Target: "Yes"
4. "Would you pay $10?" → Target: "Yes" or "Probably"
5. "Which button starts the game?" → Target: Points to Start Run

---

## 📋 PHASE 9: Survivor Selection Model & Barracks Polish (NEXT PHASE)

**See**: [docs/design/phase-9-survivor-selection.md](../docs/design/phase-9-survivor-selection.md)

**Estimated Time**: 3-4 hours (across 2-3 sessions)

**Objectives**:
1. Persist `active_character_id` in save data
2. Hub state awareness (full button state checking)
3. Barracks selection flow (Tap → Detail → Select → Return to Hub)
4. Hub Survivor Status Panel (visual indicator)
5. Barracks Art Bible transformation (background, detail view polish)
6. Full terminology update: Roster → Barracks, Characters → Survivors

---

## 📁 Files Created/Modified (Sessions 1-2)

### New Files
```
assets/hub/backgrounds/scrapyard_hub.png     # Art Bible background
scenes/ui/components/icon_button.tscn        # Reusable button scene
scripts/ui/components/icon_button.gd         # IconButton component (441 lines)
scripts/tests/ui/icon_button_test.gd         # Test suite (27 tests)
```

### Modified Files
```
scenes/hub/scrapyard.tscn                    # Background + IconButtons
scripts/hub/scrapyard.gd                     # Button logic (211 lines)
.system/validators/check-imports.sh          # Background size limit fix
```

### Session 3 Will Modify
```
project.godot                                # Entry point → Hub
scripts/hub/scrapyard.gd                     # Stub messages, button rename
scenes/hub/scrapyard.tscn                    # Button label "Barracks"
```

---

## 🧩 IconButton Component Reference

### Usage
```gdscript
var btn = preload("res://scenes/ui/components/icon_button.tscn").instantiate()
parent.add_child(btn)
btn.setup(icon_texture, "Label", IconButton.ButtonSize.LARGE, IconButton.ButtonVariant.PRIMARY)
```

### Enums
```gdscript
enum ButtonSize { SMALL, MEDIUM, LARGE }  # 50pt, 80pt, 120pt
enum ButtonVariant { PRIMARY, SECONDARY, DANGER }
```

---

## 📊 Phase 8.2c Progress

| Session | Focus | Status |
|---------|-------|--------|
| Session 1 | Background Integration | ✅ Complete |
| Session 2 | IconButton Component | ✅ Complete |
| Session 3 | Entry Point + Polish + 10-Second Test | ⏭️ **CURRENT** |

**Overall Phase 8.2c**: ~80% complete (2/3 sessions done)

---

## 🔧 Development Environment

**Platform**: macOS (MacBook Pro)
**Project Path**: `/Users/alan/Developer/scrap-survivor-godot`
**Engine**: Godot 4, GDScript
**Test Device**: iPhone 15 Pro Max

**Git Status**:
- Branch: main
- Latest Commits: 
  - `7316009` - feat(ui): add IconButton component with Art Bible styling
  - `48a792c` - feat(hub): replace ColorRect background with Art Bible concept art

---

## 🚀 Quick Start Command (Session 3)

```
SESSION 3 READY (Entry Point + Polish + 10-Second Test)

WHAT'S ALREADY DONE:
✅ Background integrated with Art Bible concept art
✅ IconButton component created with Art Bible styling
✅ Three buttons positioned (Start Run, Barracks, Settings)
✅ All validations passing (647/671 tests)

CODEBASE FINDINGS:
✅ GameState.active_character_id EXISTS (runtime variable)
✅ GameState.set_active_character() EXISTS
✅ CharacterService.set_active_character() EXISTS
⚠️ Selection NOT persisted between sessions (Phase 9 work)
⚠️ Current entry point: character_roster.tscn (needs change)

TASKS:
1. Change entry point: project.godot → scrapyard.tscn
2. Rename button label: "Roster" → "Barracks"
3. Settings button: Show "Coming Soon" toast
4. Start Run: Add stub check for characters/selection
5. Test haptic feedback on iPhone 15 Pro Max
6. Run 10-Second Impression Test with participant
7. Get user approval

ESTIMATED TIME: ~65 minutes
```

---

**Last Updated**: 2025-11-26 (Pre-Session 3 Planning)
**Status**: Session 3 Ready
**Next Action**: Entry point change, button rename, stub messages, polish, 10-Second Test
**Estimated Time**: ~65 minutes
