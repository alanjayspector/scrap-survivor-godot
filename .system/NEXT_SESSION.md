# Next Session: Week 18 Ready to Implement

**Date**: 2025-11-27
**Week 18 Status**: PLANNING COMPLETE - Ready to implement
**Current Branch**: bold-poitras
**QA Status**: N/A (planning session)

---

## SESSION SUMMARY

### Planning Session Outcome

After expert panel review of all game design documentation, we **pivoted Week 18** from Meta Progression to **Shop System + Item/Inventory Foundation**. This is because:

1. Shop System was planned for Week 7 but never implemented
2. Workshop was planned for Week 9 but never implemented
3. Core gameplay loop requires items before meta progression makes sense

### New Roadmap (Weeks 18-21)

| Week | Focus | Estimated Effort |
|------|-------|------------------|
| 18 | Shop System + Item/Inventory | 6-8 hours |
| 19 | Workshop Part 1 (Durability, Repair, Recycler, Storage) | 5-6 hours |
| 20 | Workshop Part 2 (Fusion, Craft, Blueprints) | 5-6 hours |
| 21 | Post-Run Flow + Meta Progression | 4-6 hours |

---

## WEEK 18 OVERVIEW

**Goal**: Enable core roguelite loop: Combat -> Shop -> Build Decisions -> Combat

### Key Systems

| System | Description |
|--------|-------------|
| **ItemService** | Item definitions (weapons, armor, trinkets, consumables, minions, blueprints) |
| **InventoryService** | 30 slots max, 6 weapons max, auto-active stats |
| **ShopService** | 6 items per shop, reroll escalation, rarity weighting |
| **Shop UI** | Between-wave shop screen |

### Critical Design Decisions

| Decision | Value | Notes |
|----------|-------|-------|
| Inventory slots | 30 total | Per character |
| Weapon slots | 6 max | All fire simultaneously |
| Stack limits | By rarity | C:5, U:4, R:3, E:2, L:1 |
| Shop size | 6 items | Per refresh |
| Reroll costs | 50->100->200->400->800 | Escalating |

### Weapon System Note
All 6 weapons auto-fire simultaneously at different rates/ranges. `finalDPS = Sum(allWeaponDPS) + Sum(damageBoostItems)`

---

## IMPLEMENTATION PHASES

| Phase | Effort | Focus |
|-------|--------|-------|
| 1 | 1.5-2h | ItemService + 40+ item definitions |
| 2 | 1.5-2h | InventoryService (slots, stacks, auto-active) |
| 3 | 1.5-2h | ShopService (generation, purchasing, rerolls) |
| 4 | 1.5-2h | Shop UI (between waves) |

---

## FILES CREATED THIS SESSION

- `docs/migration/week18-plan.md` - Shop System + Items (REWRITTEN)
- `docs/migration/week19-plan.md` - Workshop Part 1 (NEW)
- `docs/migration/week20-plan.md` - Workshop Part 2 (NEW)
- `docs/migration/week21-plan.md` - Post-Run + Meta (NEW)
- `docs/migration/GODOT-MIGRATION-TIMELINE-UPDATED.md` - Updated to v4.0

---

## PROJECT STATUS

**Tests**: 705/729 passing (24 pending/skipped)
**GDLint**: Clean
**All Validators**: Passing
**Git**: Planning session - ready to commit plans

---

## NEXT SESSION: Week 18 Implementation

Start with **Phase 1: ItemService + Item Definitions**

### Quick Start Tasks

1. Create `scripts/services/item_service.gd`
2. Create `scripts/resources/item_definition.gd`
3. Define 40+ item definitions (weapons, armor, trinkets, consumables)
4. Write unit tests for ItemService

### Key Files to Reference

- `docs/migration/week18-plan.md` - Full implementation plan
- `docs/game-design/systems/INVENTORY-SYSTEM.md` - Inventory design
- `docs/game-design/systems/SHOPS-SYSTEM.md` - Shop mechanics
- `scripts/services/weapon_service.gd` - Existing weapon patterns

---

## QUICK START PROMPT (Next Session)

```
Starting Week 18 implementation - Shop System + Item/Inventory Foundation.

Week 18 plan is complete. Ready to implement Phase 1: ItemService.

Please read:
1. .system/CLAUDE_RULES.md
2. docs/migration/week18-plan.md

Then begin Phase 1 implementation (create ItemService with item definitions).
```

---

**Last Updated**: 2025-11-27
**Status**: Week 18 Planning Complete, Ready to Implement
