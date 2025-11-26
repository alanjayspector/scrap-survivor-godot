# Next Session: Phase 9 - Survivor Selection Model & Barracks Polish

**Date**: 2025-11-26
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Phase 8.2c Plan**: [docs/design/phase-8-revised-plan.md](../docs/design/phase-8-revised-plan.md) ✅ COMPLETE
**Phase 9 Plan**: [docs/design/phase-9-survivor-selection.md](../docs/design/phase-9-survivor-selection.md)
**Current Phase**: Phase 9.1 - Selection Persistence + Hub State
**Status**: 🔨 **IN PROGRESS**

---

## 🔨 PHASE 9.1 IN PROGRESS

### Session Summary (2025-11-26)

**What Was Done**:
1. ✅ **Selection Persistence** - `active_character_id` now persists across app restarts
   - CharacterService ALREADY persisted it (discovered during analysis)
   - Added GameState sync from CharacterService via signals
   - GameState._ready() connects to CharacterService.active_character_changed
   - GameState.set_active_character() now updates CharacterService first
2. ✅ **Hub State Checking** - Already implemented in Phase 8.2c
   - "No Survivors" → "Recruit a survivor at the Barracks first"
   - "No Selection" → "Select a survivor at the Barracks first"
   - Selection exists → Launch wasteland
3. ✅ **Auto-select** - Already implemented in CharacterService (line 214)
   - First character created is auto-selected
4. ✅ **Clear on delete** - Already implemented in CharacterService (lines 284-293)
5. ✅ **Tests updated** - 2 tests changed to reflect new persistence behavior
6. ✅ **All 671 tests passing**

**Files Modified**:
- `scripts/autoload/game_state.gd` - Added CharacterService sync
- `scripts/tests/ui/character_creation_integration_test.gd` - Updated test expectation
- `scripts/tests/ui/first_run_flow_integration_test.gd` - Renamed + updated test

**Key Discovery**:
CharacterService already persisted `active_character_id` in its serialize/deserialize! The issue was GameState had a separate copy that wasn't synced. Fixed by making GameState listen to CharacterService signals.

---

## ⏭️ REMAINING PHASE 9 TASKS

### Session 9.2: Barracks Selection Flow + Detail View Polish (1.5h)
- [ ] Add "Select" button to Character Details screen
- [ ] Tap "Select" → sets active survivor → returns to Hub
- [ ] Update character card tap behavior (tap → detail view)
- [ ] Polish detail view with Art Bible styling

### Session 9.3: Hub Visual Indicator + Barracks Background (1h)
- [ ] Create Survivor Status Panel component (bottom-left of Hub)
- [ ] Add Art Bible background to Barracks
- [ ] Full terminology update: Roster → Barracks (file rename)

---

## ✅ PHASE 8.2c COMPLETE

### Session 3 Summary (2025-11-26)

**What Was Done**:
1. ✅ Changed entry point to Hub (scrapyard.tscn)
2. ✅ Added "Barracks" label to roster button
3. ✅ Settings button shows "Coming Soon" modal
4. ✅ Start Run validates character/selection state with helpful messages
5. ✅ Fixed MobileModal title/message not rendering (added `_update_title_label()` and `_update_message_label()` calls in `_ready()`)
6. ✅ Fixed Barracks button incorrectly disabled on first run
7. ✅ Button accessibility improvements (Barracks PRIMARY variant, Settings MEDIUM 80pt)
8. ✅ 10-Second Impression Test passed
9. ✅ Device QA passed

---

## 📋 PHASE 9: Survivor Selection Model & Barracks Polish

**Full Plan**: [docs/design/phase-9-survivor-selection.md](../docs/design/phase-9-survivor-selection.md)

**Estimated Time**: 3-4 hours (across 2-3 sessions)

**Key Objectives**:
1. ✅ **Persist Selection**: Save/load `active_character_id` in save data - DONE
2. ✅ **Hub State Awareness**: Full button state checking - DONE (Phase 8.2c)
3. ⏭️ **Barracks Selection Flow**: Tap → Detail → Select → Return to Hub
4. ⏭️ **Hub Survivor Status Panel**: Visual indicator showing selected survivor
5. ⏭️ **Barracks Art Bible**: Background + detail view polish
6. ⏭️ **Terminology**: Full rename Roster → Barracks throughout codebase

---

## 📊 Overall Progress

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 8.2c Session 1 | ✅ Complete | Background integration |
| Phase 8.2c Session 2 | ✅ Complete | IconButton component |
| Phase 8.2c Session 3 | ✅ Complete | Entry point, stubs, QA fixes |
| **Phase 8.2c** | ✅ **COMPLETE** | Hub visual transformation done |
| Phase 9.1 | ✅ **COMPLETE** | Selection persistence + Hub state |
| Phase 9.2 | ⏭️ Next | Barracks selection flow |
| Phase 9.3 | ⏭️ Pending | Hub status panel + background |

---

## 🔧 Development Environment

**Platform**: macOS (MacBook Pro)
**Project Path**: `/Users/alan/Developer/scrap-survivor-godot`
**Engine**: Godot 4, GDScript
**Test Device**: iPhone 15 Pro Max

**Git Status**:
- Branch: main
- Latest Test Run: 671/695 passing
- GDLint: Clean

---

## 🚀 Quick Start Command (Next Session)

```
PHASE 9.1 COMPLETE - Selection Persistence

COMPLETED:
✅ active_character_id persists across app restart
✅ GameState syncs from CharacterService
✅ Hub state checking (no survivors, no selection)
✅ Auto-select first character
✅ Clear selection on delete
✅ 671/695 tests passing

NEXT UP - PHASE 9.2:
1. Add "Select" button to Character Details screen
2. Tap "Select" → sets survivor → returns to Hub
3. Update card tap behavior (tap → detail view)
4. Polish detail view with Art Bible styling

READ FIRST:
- docs/design/phase-9-survivor-selection.md (Session 9.2 section)
- scripts/ui/character_details_screen.gd
- scripts/ui/character_roster.gd

REMAINING TIME: ~2.5h (Sessions 9.2 + 9.3)
```

---

**Last Updated**: 2025-11-26 (Phase 9.1 Complete)
**Status**: Phase 9.1 Complete - Ready for Phase 9.2
**Next Action**: Continue with Phase 9.2 (Barracks Selection Flow)
