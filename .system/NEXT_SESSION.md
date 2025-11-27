# Next Session: Week 17 Implementation

**Date**: 2025-11-27
**Week 16 Status**: ✅ **COMPLETE**
**Week 17 Status**: 📋 **PLANNING COMPLETE - READY TO IMPLEMENT**
**Current Branch**: main

---

## 🎯 WEEK 17 FOCUS

**Theme:** Core Character Management Experience Polish

Transform Barracks, Character Creation, and Character Details from "MVP functional" to "emotionally compelling, production-quality" UI.

### Design Principle (Established Week 16)
> **"Marvel Snap Law"** - Characters are the stars, UI serves them.

---

## 📋 WEEK 17 PHASES

| Phase | Description | Effort | Priority | Status |
|-------|-------------|--------|----------|--------|
| **Phase 1** | Unified Card Component | 3-4h | CRITICAL | ⏳ Ready |
| **Phase 2** | Character Creation Overhaul | 3-4h | HIGH | ⏳ Ready |
| **Phase 3** | Character Details Overhaul | 3-4h | HIGH | ⏳ Ready |
| **Phase 4** | "Enter the Wasteland" Screen | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 5** | Polish & Animation | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 6** | Scrapyard Title Polish | 0.5-1h | LOW | ⏳ Ready |

**Total Estimated Effort:** 15-19 hours

---

## 🖼️ ART ASSETS - ALL READY ✅

All art assets have been generated and optimized for mobile:

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

Previews available in `art-docs/preview/` for reference.

---

## 🔑 KEY DECISIONS MADE

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Character Creation BG | Barracks Recruitment Interior | Same visual family as roster, "recruiting" metaphor |
| Run Initiation Copy | "ENTER THE WASTELAND" + "GO" | Title dramatic, button simple/punchy |
| Character Details | Remove sidebar, add Hero Section | Simplify, create "proud showcase" moment |
| Card Component | Unified for both screens | Visual consistency, reduced maintenance |
| Scrapyard Title | Primary Orange (#FF6600) | Art Bible compliance, better visibility |
| Type Silhouettes | Generate all 4 now | Dedicated week, no deferring |

---

## 📊 PROJECT STATUS

**Tests**: 671/695 passing
**GDLint**: Clean
**All Validators**: Passing

**Git Log (Recent)**:
```
f510d7a fix(barracks): replace purple scroll background with semi-transparent charcoal
aaf6799 feat(barracks): replace background with Option C dark gradient
dd2be38 feat(barracks): Phase 9.3 - Hub status panel + file renames
a8d08fe fix(barracks): separate viewing from selecting characters
```

---

## 📚 KEY DOCUMENTATION

| Document | Purpose |
|----------|---------|
| `docs/migration/week17-plan.md` | Full Week 17 implementation plan |
| `docs/migration/backlog-items.md` | Deferred work (IAP, tech debt) |
| `docs/design/art-asset-usage-guide.md` | Art asset catalog & recommendations |
| `art-docs/Scrapyard_Scene_Art_Bible.md` | Color palette, style guide |

---

## 🚀 QUICK START PROMPT (Next Session)

```
Starting Week 17 Phase 1 implementation for Scrap Survivor.

Read these files:
1. .system/CLAUDE_RULES.md (project rules)
2. .system/NEXT_SESSION.md (this file)
3. docs/migration/week17-plan.md (full implementation plan)

Week 17 Focus: Core character management experience polish
- Phase 1: Unified Card Component (CharacterTypeCard)
- Screens: Barracks, Character Creation, Character Details
- Art assets needed (prompts in NEXT_SESSION.md)

Ready to begin Phase 1: Unified Card Component
```

---

## ⚠️ REMINDERS

1. **All art assets are ready** - no generation needed, start coding immediately
2. **Keyboard fix is CRITICAL** in Phase 2 - current UX violates iOS HIG
3. **Remove sidebar** from Character Details (simplify to single-character view)
4. **Use wasteland-gate.png** for "Enter the Wasteland" screen (already have it!)
5. **Scrapyard title fix** is quick win - Primary Orange (#FF6600) with Burnt Umber outline

---

**Last Updated**: 2025-11-27
**Status**: Week 17 Planning Complete - ALL ASSETS READY - Begin Phase 1
