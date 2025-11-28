# Next Session: Week 18 Implementation Ready

**Date**: 2025-11-27
**Week 18 Status**: PLANNING COMPLETE - Documentation Updated - Ready to Implement
**Current Branch**: main
**QA Status**: Tests passing (705/729)

---

## SESSION SUMMARY

### Expert Panel Review Complete

Conducted comprehensive review of:
- Existing `weapon_service.gd` (10 weapons, dictionary-based)
- `brotato-reference.md` (62 characters, 83 weapons, 177 items)
- `INVENTORY-SYSTEM.md` (30 slots, 6 weapons, auto-active)
- `SHOPS-SYSTEM.md` (3 shop types, tier gating)
- `ui-design-system.md` (rarity colors defined)
- `PERKS-SYSTEM.md` and `PERKS-ARCHITECTURE.md` (50+ hook points)

### Key Decisions Made (Confirmed with Alan)

| Decision | Value | Rationale |
|----------|-------|-----------|
| **Item Storage** | JSON Dictionary (Option B) | Single source of truth, easier maintenance |
| **Tier-Gated Items** | NO - Option C | Tiers gate SHOPS, not items. Fairer, simpler. |
| **Subscription Cancel** | Keep items forever | Once owned, always owned. Avoids player rage. |
| **Character Types** | Per-type weapon/inventory slots | Enables One Armed (1 slot), Weapon Master (10 slots) |
| **Starting Items** | Character-type specific | Free: 1 common weapon. Premium: better loadouts. |
| **Weapon Migration** | Move to ItemService | Single data source, WeaponService keeps combat logic |
| **Perk Hooks** | Required in all new services | Per PERKS-ARCHITECTURE.md |

### Documentation Updated

- ✅ `docs/migration/week18-plan.md` - Completely rewritten with expanded scope
  - Added character type system (6 types)
  - Added perk hook requirements
  - Added 7 implementation phases
  - Added expert panel decisions
  - Added file structure
  - Added comprehensive QA checklist

---

## WEEK 18 EXPANDED SCOPE

### Implementation Phases (8-10 hours total)

| Phase | Effort | Focus |
|-------|--------|-------|
| 1 | 1.5h | Item Database + ItemService (35+ items) |
| 2 | 1.5h | Character Type System (6 types, slot limits) |
| 3 | 1.5h | InventoryService (slots, stacks, auto-active) |
| 4 | 1h | WeaponService Refactor (migrate to ItemService) |
| 5 | 1.5h | ShopService (generation, purchase, reroll) |
| 6 | 1.5h | Shop UI (between waves) |
| 7 | 1h | Integration & QA |

### Character Types (MVP)

| Type | Tier | Weapon Slots | Special |
|------|------|--------------|---------|
| Scavenger | Free | 6 | Balanced starter |
| Gunslinger | Free | 6 | +25% ranged, -50% melee |
| Brawler | Free | 6 | +25% melee, -50% range |
| Weapon Master | Premium | 10 | -15% damage trade-off |
| One Armed | Premium | 1 | +100% damage, +100% attack speed |
| Collector | Subscription | 6 | 50 inventory slots, +50% luck |

### Perk Hooks Required

Per `PERKS-ARCHITECTURE.md`, these services need hooks:
- `InventoryService`: add_pre/post, remove_pre/post
- `ShopService`: purchase_pre/post, reroll_pre/post, generate_pre/post
- `CharacterService`: create_pre/post (update existing)

---

## FILES TO READ BEFORE STARTING

1. `docs/migration/week18-plan.md` - Updated implementation plan
2. `scripts/services/weapon_service.gd` - Existing weapon structure to migrate
3. `scripts/services/character_service.gd` - Needs character type integration
4. `docs/core-architecture/ui-design-system.md` - Rarity colors
5. `docs/core-architecture/PERKS-ARCHITECTURE.md` - Hook patterns

---

## NEXT SESSION: Phase 1 Implementation

Start with **Phase 1: Item Database + ItemService**

### Phase 1 Tasks

1. Create `scripts/data/item_database.gd`
   - Migrate 10 weapons from WeaponService (add rarity, price)
   - Add 10 armor items
   - Add 10 trinkets
   - Add 5 consumables
   - Total: 35+ items

2. Create `scripts/services/item_service.gd`
   - get_item(id) -> Dictionary
   - get_items_by_type(type) -> Array
   - get_items_by_rarity(rarity) -> Array
   - validate_all_items() -> bool

3. Unit tests for ItemService

### Success Criteria for Phase 1

- [ ] 35+ item definitions in database
- [ ] All 10 weapons migrated with rarity/price
- [ ] ItemService can get item by ID
- [ ] ItemService can filter by type/rarity
- [ ] Unit tests passing

---

## QUICK START PROMPT (Next Session)

```
Continuing Week 18 implementation - Shop System + Item/Inventory Foundation.

Documentation has been updated with expanded scope including:
- Character type system (6 types with different weapon slots)
- Perk hook requirements
- 7 implementation phases

Ready to implement Phase 1: Item Database + ItemService.

Please read:
1. .system/CLAUDE_RULES.md
2. docs/migration/week18-plan.md (UPDATED - read carefully)
3. scripts/services/weapon_service.gd (migration source)

Then begin Phase 1:
1. Create scripts/data/item_database.gd with 35+ items
2. Create scripts/services/item_service.gd
3. Write unit tests
```

---

## GIT STATUS

**Branch**: main
**Last Commit**: Planning session
**Uncommitted Changes**: 
- docs/migration/week18-plan.md (updated with expanded scope)

---

**Last Updated**: 2025-11-27
**Status**: Ready to Implement Phase 1
