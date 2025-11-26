# Phase 8 REVISED Plan - Art Bible Visual Identity

**Document Created**: 2025-11-24
**Last Updated**: 2025-11-26 (Session 3 Scope Refinement)
**Status**: IN PROGRESS - Session 3 Ready
**Replaces**: Original Phase 8 "Metal Wall" approach (FAILED QA)

---

## 🔄 CRITICAL UPDATES

### Update 3 (2025-11-26): Session 3 Scope Refinement

**Planning Session Outcomes**:
1. **Entry Point Change**: App will launch to Hub (not Character Roster)
2. **Terminology**: Roster → Barracks, Characters → Survivors, Create → Recruit
3. **Stub Messages**: Start Run button checks for characters/selection, shows appropriate feedback
4. **Settings Button**: Shows "Coming Soon" toast (Option B selected)
5. **Phase 9 Created**: Survivor Selection Model & Barracks Polish (3-4 hours)

**Deferred to Phase 9**:
- Persist `active_character_id` in save data
- "Select" button in Barracks detail view
- Hub Survivor Status Panel (visual indicator)
- Barracks Art Bible transformation
- Full scene/file rename: character_roster → barracks

### Update 2 (2025-11-25): Orientation Correction

**Error Identified**: Previous revision incorrectly specified portrait (9:16) orientation.

**Root Cause**: Planning error. Game was always intended to be landscape throughout:
- Combat/Wasteland = Landscape
- Hub = Should also be Landscape (not portrait)
- Controller support requires landscape orientation
- Rotating phone between scenes = poor UX

**Correction**: All scenes are **LANDSCAPE**. Existing concept art is already landscape and can be used directly.

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

---

## 🎨 Art Asset Analysis

### Existing Concept Art

| Asset | Resolution | Aspect | Usability |
|-------|-----------|--------|-----------|
| `scrap-town-sancturary.png` | 2752×1536 | ~16:9 | ✅ **USED** |
| `buttons-signs.png` | - | - | ✅ UI kit reference |
| `wasteland-gate.png` | - | - | Future: Start Run visual |

---

## 📋 Revised Phase 8.2c Implementation Plan

### Overview

**Total Estimated Time**: 3-4 hours
**Approach**: Asset-driven (use existing art directly)

### Session Breakdown

| Session | Focus | Time | Status |
|---------|-------|------|--------|
| **Session 1** | Background Integration | 1h | ✅ **COMPLETE** |
| **Session 2** | Button Integration (IconButton) | 1.5-2h | ✅ **COMPLETE** |
| **Session 3** | Entry Point + Polish + 10-Second Test | ~65 min | ⏭️ **CURRENT** |

---

### SESSION 1: Background Integration ✅ COMPLETE

**Commit**: `48a792c` - feat(hub): replace ColorRect background with Art Bible concept art

**What Was Done**:
- Background integrated with -90° rotation fix for landscape display
- All aspect ratio tests passed
- User approval obtained

---

### SESSION 2: Button Integration ✅ COMPLETE

**Commit**: `7316009` - feat(ui): add IconButton component with Art Bible styling

**What Was Done**:
- IconButton component: 441 lines with 27 tests
- Three sizes (50/80/120pt), three variants (Primary/Secondary/Danger)
- Pre-commit hooks caught and fixed: trailing whitespace, line length, asset validator limits

---

### SESSION 3: Entry Point + Polish + 10-Second Test ⏭️ CURRENT

**Estimated Time**: ~65 minutes

**Objective**: Change app entry point, add stub messages, polish, validate

#### Task Breakdown

| Task | Time | Notes |
|------|------|-------|
| Change entry point → Hub | 15 min | project.godot modification |
| Rename button label "Roster" → "Barracks" | 5 min | IconButton text only |
| Settings button "Coming Soon" toast | 10 min | ModalFactory toast |
| Start Run stub check | 15 min | Character/selection validation |
| Haptic feedback validation | 10 min | iPhone 15 Pro Max |
| 10-Second Impression Test | 10 min | With participant |
| **Total** | **~65 min** | |

#### Character Selection Model (Stub Implementation)

**Current State** (from codebase investigation):
- `GameState.active_character_id` EXISTS (runtime variable)
- `GameState.set_active_character()` EXISTS
- Selection NOT persisted between app sessions
- Current entry point: `character_roster.tscn`

**Stub Logic for Start Run**:
```gdscript
func _on_start_run_pressed() -> void:
    var character_count = CharacterService.get_character_count()
    
    if character_count == 0:
        # No survivors exist
        _show_toast("Recruit a survivor at the Barracks first")
        return
    
    if GameState.active_character_id.is_empty():
        # Survivors exist but none selected
        _show_toast("Select a survivor at the Barracks first")
        return
    
    # Has selected survivor - launch wasteland
    get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")
```

#### Terminology Changes (This Session)

| Old | New | Scope |
|-----|-----|-------|
| Roster | Barracks | Button label only |
| Characters | Survivors | Toast messages only |
| Create Character | Recruit | Toast messages only |

**Full terminology update** (scene names, file names, all references) deferred to Phase 9.

#### QA Gate Checklist

- [ ] App launches to Hub (scrapyard.tscn)
- [ ] Button label shows "Barracks" (not "Roster")
- [ ] Settings button shows "Coming Soon" toast
- [ ] Start Run with no characters → "Recruit a survivor" toast
- [ ] Start Run with characters but none selected → "Select a survivor" toast
- [ ] Haptic feedback works on iPhone 15 Pro Max
- [ ] Button press animations smooth and responsive
- [ ] 10-Second Impression Test passed (4/5 positive responses)
- [ ] User declares: "This looks like a real indie game"

#### 10-Second Impression Test

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

- [x] Hub background uses Art Bible concept art
- [x] Background handles 16:9 to 20:9 aspect ratios
- [x] Stretch settings = canvas_items + expand
- [x] Icon buttons integrated with Art Bible styling
- [x] Button positions work across aspect ratios
- [x] Start Run is clearly the primary action
- [ ] App launches to Hub (not Character Roster)
- [ ] Start Run validates character/selection state
- [ ] Button press feedback smooth and polished
- [ ] 10-Second Impression Test passed (4/5)
- [ ] User declares: "This looks like a real indie game"

---

## 📝 Files to Create/Modify

**Session 3 Files**:

| File | Action | Notes |
|------|--------|-------|
| `project.godot` | Modify | Entry point → scrapyard.tscn |
| `scripts/hub/scrapyard.gd` | Modify | Stub messages, selection check |
| `scenes/hub/scrapyard.tscn` | Modify | Button label "Barracks" |

**Already Complete (Sessions 1-2)**:
- `assets/hub/backgrounds/scrapyard_hub.png` - Art Bible background
- `scenes/ui/components/icon_button.tscn` - Reusable button scene
- `scripts/ui/components/icon_button.gd` - IconButton component
- `scripts/tests/ui/icon_button_test.gd` - Test suite

---

## 🚀 Quick Start for Session 3

```
SESSION 3 READY (Entry Point + Polish + 10-Second Test)

COMMITS MADE:
- 48a792c: feat(hub): replace ColorRect background with Art Bible concept art
- 7316009: feat(ui): add IconButton component with Art Bible styling

CODEBASE STATE:
✅ GameState.active_character_id exists (runtime)
✅ Character selection infrastructure ready
⚠️ Entry point is character_roster.tscn (needs change)
⚠️ Selection not persisted (Phase 9 work)

TASKS:
1. Change entry point: project.godot → scrapyard.tscn
2. Rename button label: "Roster" → "Barracks"
3. Settings button: "Coming Soon" toast
4. Start Run: Stub check for characters/selection
5. Haptic feedback validation on device
6. 10-Second Impression Test
7. Get user approval

ESTIMATED TIME: ~65 minutes
```

---

## 📋 PHASE 9 PREVIEW: Survivor Selection Model & Barracks Polish

**Full Plan**: See `docs/design/phase-9-survivor-selection.md`

**Estimated Time**: 3-4 hours (across 2-3 sessions)

**Key Objectives**:
1. **Persist Selection**: Save/load `active_character_id`
2. **Hub Awareness**: Full state checking on all buttons
3. **Barracks Selection Flow**: Tap → Detail → Select → Return to Hub
4. **Hub Visual Indicator**: Survivor Status Panel
5. **Barracks Art Bible**: Background + detail view polish
6. **Terminology**: Full rename Roster → Barracks throughout codebase

---

**Document Version**: 4.0
**Created**: 2025-11-24
**Updated**: 2025-11-26 (Session 3 Scope Refinement)
**Author**: Expert Panel (Claude)
**Status**: IN PROGRESS - Session 3 Ready
