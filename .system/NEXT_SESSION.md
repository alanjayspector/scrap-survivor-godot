# Next Session Handoff

**Updated:** 2025-11-28
**Current Branch:** `main`
**Status:** Week 18 Phase 4 COMPLETE - Phase 5 NEXT

---

## SESSION ACCOMPLISHMENTS (2025-11-28)

### Phase 4: InventoryService - COMPLETE

**Initial Implementation (Gemini 3 Pro-High):**
- Created `scripts/services/inventory_service.gd`
- Created `scripts/tests/inventory_service_test.gd`
- Basic add/remove, slot limits, stack limits, perk hooks

**Claude Review & Fixes:**
1. **Tinkerer stack_limit_bonus** - Was defined but not consumed. Now applied in `_validate_stack_limit()`
2. **GameLogger** - Added throughout for observability
3. **reset()** method - Added for testing/new game
4. **Persistence** - Fixed version warning, added timestamp
5. **Test pollution bug** - Fixed `before_each` to use `duplicate(true)` preventing shared mock mutation

**Durability Placeholder Added:**
- Changed data model from item IDs to item INSTANCES
- Each instance has `{instance_id, item_id, durability: {current_hp, max_hp}}`
- Durability by rarity: Common=100, Uncommon=200, Rare=400, Epic=800, Legendary=1600
- APIs: `apply_durability_damage()`, `repair_item()`, `get_durability_percent()`
- Save format v2 with v1→v2 migration for backwards compatibility
- 8 new durability tests added

**Deferred to Foundry (Week 19+):**
- Durability perk hooks (`durability_damage_pre/post`, `durability_repair_pre/post`)
- Death penalty (tier-based durability damage)
- Mr Fix-It repair service (subscription feature)

---

## IMMEDIATE NEXT ACTION

**Begin Phase 5: ShopService Hub Refactor**

ShopService was implemented with wave-based generation (incorrect).
Needs refactor to time-based hub model per SHOPS-SYSTEM.md.

**Key Changes:**
- Remove wave parameter from `generate_shop()`
- Add `_last_refresh_timestamp` tracking
- Implement `check_refresh_needed()` - 4-hour cycle
- Implement `check_empty_stock_refresh()` - FREE refresh when all items purchased
- Add `get_time_until_refresh()` for UI countdown

---

## WEEK 18 PHASE ORDER (UPDATED)

| Phase | Description | Est. Time | Status |
|-------|-------------|-----------|--------|
| **1** | Item Database + ItemService | 1.5h | ✅ COMPLETE |
| **2** | Character Type System | 1.5h | ✅ COMPLETE |
| **3** | ShopService | 1.5h | ✅ COMPLETE (needs refactor in Phase 5) |
| **4** | InventoryService | 1.5h | ✅ COMPLETE (with durability placeholder) |
| **5** | ShopService Refactor for Hub Model | 1h | ⏭️ NEXT |
| **6** | Hub Shop UI | 2h | PENDING |
| **6.5** | Hub Bank UI | 1h | PENDING |
| **7** | Integration & QA | 1h | PENDING |
| **8** | Try-Before-Buy | 2h | STRETCH |

**Total Estimated**: 12-14 hours
**Actual So Far**: ~6.5h for Phases 1-4

---

## QUICK START PROMPT

```
Continue Week 18 Phase 5: ShopService Hub Refactor.

⚠️ Read SHOPS-SYSTEM.md first - Shop is a HUB SERVICE with time-based refresh.

Read (IN THIS ORDER):
1. .system/CLAUDE_RULES.md (development protocols)
2. docs/game-design/systems/SHOPS-SYSTEM.md (shop design - "Location: Hub → Shop")
3. docs/migration/week18-plan.md (Phase 5 section)
4. scripts/services/shop_service.gd (current implementation to refactor)

Tasks:
1. Remove wave parameter from generate_shop()
2. Add _last_refresh_timestamp tracking
3. Implement check_refresh_needed() - 4-hour refresh cycle
4. Implement check_empty_stock_refresh() - FREE refresh when stock = 0
5. Add get_time_until_refresh() for UI countdown
6. Update tests for hub model
7. Keep: rarity weighting, tier discounts, perk hooks
```

---

## KEY FILES CHANGED THIS SESSION

### New Files:
- `scripts/services/inventory_service.gd` - Instance-based inventory with durability
- `scripts/tests/inventory_service_test.gd` - 25 tests including durability

### Modified Files:
- `scripts/data/item_database.gd` - Added `base_durability` to RARITY_CONFIG
- `docs/migration/week18-plan.md` - Updated status, durability notes

---

## INVENTORYSERVICE API REFERENCE

```gdscript
# Adding items (returns instance_id on success, "" on failure)
var instance_id = InventoryService.add_item(character_id, item_id)

# Getting inventory
var instances = InventoryService.get_inventory(character_id)  # Array of instance dicts
var item_ids = InventoryService.get_item_ids(character_id)    # Array of strings (compat)

# Removing items
InventoryService.remove_item(character_id, item_id)           # Remove first instance
InventoryService.remove_item_by_instance(character_id, instance_id)  # Remove specific

# Stats
var stats = InventoryService.calculate_stats(character_id)

# Durability (placeholder - full system in Foundry)
var survived = InventoryService.apply_durability_damage(character_id, instance_id, damage)
InventoryService.repair_item(character_id, instance_id, heal_amount)
var percent = InventoryService.get_durability_percent(character_id, instance_id)

# Persistence
var data = InventoryService.serialize()
InventoryService.deserialize(data)  # Handles v1→v2 migration
InventoryService.reset()
```

---

## KNOWN ISSUES / NOTES

1. **ShopService Needs Refactor**: Phase 5 will remove wave parameter, add time-based refresh

2. **add_item() Return Type Change**: Now returns String (instance_id) instead of bool. But `if add_item(...):` still works because non-empty strings are truthy.

3. **Salvager Discount**: Already implemented in ShopService `calculate_purchase_price()`

4. **No Shop/Bank Icons Yet**: Need to create/commission for Phase 6/6.5

---

**Git Status:** Phase 4 complete, ready for commit
**Tests:** 857/881 passing (24 pending - projectile tests etc.)
**Ready to Commit:** Yes - inventory_service.gd, inventory_service_test.gd, item_database.gd, week18-plan.md
