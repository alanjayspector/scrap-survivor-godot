# Next Session: Week 17 Implementation

**Date**: 2025-11-27
**Week 16 Status**: ✅ **COMPLETE**
**Week 17 Status**: 🚧 **PHASE 1 IN PROGRESS**
**Current Branch**: main

---

## 🎯 CURRENT FOCUS: Phase 1 - Unified Card Component

### Expert Panel Decisions (Finalized 2025-11-27)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Tap Animation | Custom (0.95 scale, 80ms/120ms asymmetric) | Cards deserve premium feel per Marvel Snap Law |
| Selection Glow | Animated GlowPanel (NOT shader) | Mobile performance, simpler implementation |
| Portrait Display | Hybrid: silhouette PNGs for types, ColorRect for players (Phase 1) | Immediate improvement in Character Creation |
| Component Strategy | NEW `CharacterTypeCard` component | Safe migration, side-by-side operation |
| Detail Views | Type Preview Modal (Phase 2) + Player Details Overhaul (Phase 3) | Two distinct experiences |

### Phase 1 Tasks

- [x] Document expert panel decisions
- [ ] Create `CharacterTypeCard` scene via Godot editor
- [ ] Implement `character_type_card.gd` script
- [ ] Load silhouette textures for type portraits
- [ ] Migrate Character Creation to use new component
- [ ] Migrate Barracks to use new component
- [ ] Unit tests for both modes
- [ ] Device QA validation
- [ ] Deprecate old `CharacterCard`

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
| **Phase 1** | Unified Card Component | 3-4h | CRITICAL | 🚧 In Progress |
| **Phase 2** | Character Creation Overhaul | 3-4h | HIGH | ⏳ Ready |
| **Phase 3** | Character Details Overhaul | 3-4h | HIGH | ⏳ Ready |
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

**Tests**: 671/695 passing
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
Continuing Week 17 Phase 1 for Scrap Survivor.

Read these files:
1. .system/CLAUDE_RULES.md
2. .system/NEXT_SESSION.md
3. docs/migration/week17-plan.md

Current task: Create CharacterTypeCard component
- Expert panel decisions documented ✅
- Art assets ready ✅
- Ready to create scene in Godot editor

Begin CharacterTypeCard component creation.
```

---

## ⚠️ REMINDERS

1. **Use Godot editor for scene creation** (per CLAUDE_RULES)
2. **Parent-First Protocol** for dynamic UI nodes
3. **GlowPanel animation**: alpha 0.6↔1.0 over 800ms
4. **Tap animation**: 0.95 scale, 80ms down / 120ms return
5. **Test on iOS device** before marking complete

---

**Last Updated**: 2025-11-27
**Status**: Phase 1 In Progress - Expert Panel Decisions Documented
