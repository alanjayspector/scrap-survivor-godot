# Next Session: Week 17 Implementation

**Date**: 2025-11-26 (Updated)
**Week 16 Status**: ✅ **COMPLETE**
**Week 17 Status**: ✅ **PHASE 2 COMPLETE** - Ready for Phase 3
**Current Branch**: main

---

## 🎯 CURRENT FOCUS: Phase 3 - Character Details Overhaul

### Expert Panel Decisions (Finalized 2025-11-27)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Tap Animation | Custom (0.95 scale, 80ms/120ms asymmetric) | Cards deserve premium feel per Marvel Snap Law |
| Selection Glow | Animated GlowPanel (NOT shader) | Mobile performance, simpler implementation |
| Portrait Display | Silhouette PNGs for BOTH types and players (QA Pass 4 fix) | Visual consistency across screens |
| Component Strategy | NEW `CharacterTypeCard` component | Safe migration, side-by-side operation |
| Detail Views | Type Preview Modal (Phase 2) + Player Details Overhaul (Phase 3) | Two distinct experiences |

### Phase 1 Tasks

- [x] Document expert panel decisions
- [x] Create `CharacterTypeCard` scene via Godot editor (`scenes/ui/components/character_type_card.tscn`)
- [x] Implement `character_type_card.gd` script (`scripts/ui/character_type_card.gd`)
- [x] Load silhouette textures for type portraits (all 4 types implemented)
- [x] Unit tests for both modes (34 tests, all passing - 705/729 total)
- [x] Migrate Character Creation to use new component ✅ (2025-11-26)
- [x] Migrate Barracks to use new component ✅ (2025-11-26)
- [x] QA Pass 4 - Fix "white" portrait issue ✅ (2025-11-26)
- [x] Device QA validation (Pass 5) ✅ (2025-11-26) - Approved, pragmatic pass
- [x] Deprecate old `CharacterCard` ✅ (2025-11-26)

### Phase 2 Implementation (2025-11-26) ✅ COMPLETE (Device QA Passed)

- [x] **Keyboard UX fix**: Tap outside to dismiss keyboard (iOS HIG compliance)
  - Removed auto-focus on name input
  - Added `_setup_keyboard_dismissal()` with gui_input handler
- [x] **Name input width**: Constrained to 300pt centered (was full width)
- [x] **Background applied**: `character_creation_bg.jpg` TextureRect added to scene
- [x] **Type Preview Modal**: Long-press on type card shows iOS HIG Sheet modal
  - 250×250pt silhouette portrait with type-colored border
  - Full description text
  - **Aura info section** (Scavenger=Collection, Tank=Shield, Mutant=Damage)
  - All stat bonuses displayed with +/- coloring
  - **CTA for locked types**: "Unlock with Premium/Subscription" + value prop
  - Swipe-to-dismiss and tap-outside dismiss
- [x] **Long-press works on locked types**: CTA opportunity for upgrades
- [x] **Modal stacking fix**: Dismisses existing modal before showing new
- [x] **"Select Type" button**: Unlocked types get "Select Type" + "Close"
- [x] **Upgrade flow placeholder**: Shows alert (IAP integration coming)

### QA Pass 4 Decisions (2025-11-26)

**Issue 1: Barracks Player Portrait "White"**
- Root cause: Scavenger color `(0.6, 0.6, 0.6)` appeared nearly white on dark background
- Fix applied: `setup_player()` now uses silhouettes (same as `setup_type()`)
- Result: Visual consistency between Character Creation and Barracks

**Issue 2: Silhouette Detail Lacking at Thumbnail Size**
- Decision: **DEFERRED** to Phase 2/3
- Rationale: Silhouettes are excellent at full size (512×512), will shine in detail views
- Phase 2 (Type Preview Modal): 300×300pt display
- Phase 3 (Character Details Hero Section): 200×200pt display
- Cards are "identifiers," detail views are "appreciation moments"

### Component Features Implemented

- `setup_type(type_id)` - For Character Creation (silhouette portraits)
- `setup_player(character_data)` - For Barracks (silhouette portraits - QA Pass 4 fix)
- `set_selected(bool)` - Animated breathing glow effect (Timer-based, iOS-safe)
- `set_locked(bool, tier)` - Lock overlay for tier-restricted types
- Custom tap animation (0.95 scale, 80ms down / 120ms return, _process-based)
- Long press detection (500ms for type preview modal)
- `card_pressed` and `card_long_pressed` signals

---

## 🖼️ ART ASSETS - ALL READY ✅

| Asset | Size | Location |
|-------|------|----------|
| Character Creation BG | 1.3MB | `assets/ui/backgrounds/character_creation_bg.jpg` |
| Character Details BG | 825KB | `assets/ui/backgrounds/character_details_bg.jpg` |
| Barracks Interior | 923KB | `assets/ui/backgrounds/barracks_interior.jpg` |
| Scavenger Silhouette | 380KB | `assets/ui/portraits/silhouette_scavenger.png` |
| Tank Silhouette | 361KB | `assets/ui/portraits/silhouette_tank.png` |
| Commando Silhouette | 419KB | `assets/ui/portraits/silhouette_commando.png` |
| Mutant Silhouette | 406KB | `assets/ui/portraits/silhouette_mutant.png` |
| Wasteland Gate | (existing) | `art-docs/wasteland-gate.png` |

---

## 📋 WEEK 17 PHASES

| Phase | Description | Effort | Priority | Status |
|-------|-------------|--------|----------|--------|
| **Phase 1** | Unified Card Component | 3-4h | CRITICAL | ✅ Complete |
| **Phase 2** | Character Creation Overhaul | 3-4h | HIGH | ✅ Complete |
| **Phase 3** | Character Details Overhaul | 3-4h | HIGH | 🚧 Next |
| **Phase 4** | "Enter the Wasteland" Screen | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 5** | Polish & Animation | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 6** | Scrapyard Title Polish | 0.5-1h | LOW | ⏳ Ready |

---

## 🔑 KEY DECISIONS MADE

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Character Creation BG | Barracks Recruitment Interior | Same visual family as roster |
| Run Initiation Copy | "ENTER THE WASTELAND" + "GO" | Title dramatic, button punchy |
| Character Details | Remove sidebar, add Hero Section | Simplify, "proud showcase" moment |
| Card Component | Unified for both screens | Visual consistency, reduced maintenance |
| Scrapyard Title | Primary Orange (#FF6600) | Art Bible compliance |
| Type Silhouettes | All 4 generated | Ready in `assets/ui/portraits/` |

---

## 📊 PROJECT STATUS

**Tests**: 705/729 passing (24 pending/skipped)
**GDLint**: Clean
**All Validators**: Passing

---

## 📚 KEY DOCUMENTATION

| Document | Purpose |
|----------|---------|
| `docs/migration/week17-plan.md` | Full Week 17 plan with expert panel decisions |
| `docs/migration/backlog-items.md` | Deferred work (IAP, tech debt) |
| `docs/design/art-asset-usage-guide.md` | Art asset catalog |
| `art-docs/Scrapyard_Scene_Art_Bible.md` | Color palette, style guide |

---

## 🚀 QUICK START PROMPT (Next Session)

```
Continuing Week 17 for Scrap Survivor.

Read these files:
1. .system/CLAUDE_RULES.md
2. .system/NEXT_SESSION.md
3. docs/migration/week17-plan.md

Phase 1 COMPLETE ✅
Phase 2 COMPLETE ✅

Phase 3: Character Details Overhaul
- Hero Section (200pt portrait area)
- Apply character_details_bg.jpg background
- Replace stat text icons [HP] with proper sprites
- Type color badge, unified styling
```

---

## ⚠️ REMINDERS

1. **Use Godot editor for scene creation** (per CLAUDE_RULES)
2. **Parent-First Protocol** for dynamic UI nodes
3. **GlowPanel animation**: alpha 0.6↔1.0 over 800ms
4. **Tap animation**: 0.95 scale, 80ms down / 120ms return
5. **Test on iOS device** before marking complete

---

**Last Updated**: 2025-11-26
**Status**: Phase 2 Complete - Ready for Phase 3 (Character Details Overhaul)
