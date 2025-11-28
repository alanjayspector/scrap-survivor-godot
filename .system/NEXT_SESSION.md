# Next Session Handoff

**Updated:** 2025-11-28
**Current Branch:** `main`
**Status:** Week 18 Phase 3 COMPLETE - Phase 4 NEXT

---

## IMMEDIATE NEXT ACTION

**Begin Phase 4: InventoryService**

Phase 3 (ShopService) is complete and tests passing.

---

## SESSION ACCOMPLISHMENTS (Phase 3)

1. Created `scripts/services/shop_service.gd` (400+ lines)
2. Implemented shop generation with 6 items, weighted rarity by tier
3. Implemented wave guarantees (Uncommon+ at wave 5, Rare+ at wave 10)
4. Implemented purchase flow with BankingService integration
5. Added character discount support (`shop_discount` stat for Salvager)
6. Integrated with existing ShopRerollService for reroll cost escalation
7. Added tier-based reroll discounts (Premium 25%, Subscription 50%)
8. Implemented 6 perk hook signals
9. Created `scripts/tests/shop_service_test.gd` (60+ tests)
10. Registered ShopService as autoload in project.godot
11. Tests passing: 836/860

---

## WEEK 18 PHASE ORDER

| Phase | Description | Est. Time | Status |
|-------|-------------|-----------|--------|
| **1** | Item Database + ItemService | 1.5h | ✅ COMPLETE |
| **2** | Character Type System | 1.5h | ✅ COMPLETE |
| **3** | ShopService | 1.5h | ✅ COMPLETE |
| **4** | InventoryService | 1.5h | ⏭️ NEXT |
| **5** | WeaponService Refactor | 1h | PENDING |
| **6** | Shop UI | 1.5h | PENDING |
| **7** | Integration & QA | 1h | PENDING |
| **8** | Try-Before-Buy | 2h | STRETCH |

---

## QUICK START PROMPT

```
Continue Week 18 Phase 4: InventoryService.

Read (IN THIS ORDER):
1. .system/CLAUDE_RULES.md (ALWAYS read first - development protocols)
2. docs/migration/week18-plan.md (Phase 3 section - note: plan says Phase 3 but we reordered)
3. scripts/services/shop_service.gd (reference pattern, purchase flow)
4. scripts/services/character_service.gd (character data structure)

Tasks:
1. Create scripts/services/inventory_service.gd
2. Implement add_item with slot validation (total + weapon limits)
3. Implement remove_item
4. Implement get_inventory
5. Implement stack limit enforcement by rarity
6. Implement auto-active stat calculation
7. Add perk hooks (inventory_add_pre/post, inventory_remove_pre/post)
8. Create scripts/tests/inventory_service_test.gd
```

---

## PHASE 3 DELIVERABLES (Reference)

**ShopService Features:**
- Shop generation: 6 items with weighted rarity by tier
- Wave guarantees: Uncommon+ at wave 5, Rare+ at wave 10
- Purchase flow with BankingService
- Salvager 25% shop discount support
- Tier reroll discounts: Premium 25%, Subscription 50%
- Integrates with ShopRerollService for cost escalation (50→100→200→400→800)

**Perk Hooks:**
- `shop_generate_pre/post` - Modify shop generation
- `shop_purchase_pre/post` - Modify/block purchases
- `shop_reroll_pre/post` - Modify/block rerolls
- `shop_refreshed` - Notification of shop refresh

**Files Created:**
- `scripts/services/shop_service.gd` - Shop generation, purchases, rerolls
- `scripts/tests/shop_service_test.gd` - 60+ unit tests

**Files Updated:**
- `project.godot` - Added ShopService autoload

---

## KEY DOCUMENTS

- `docs/migration/week18-plan.md` - Master plan (v2.2)
- `docs/game-design/systems/SHOPS-SYSTEM.md` - Shop design
- `docs/game-design/systems/CHARACTER-SYSTEM.md` - Character types
- `.system/CLAUDE_RULES.md` - Development protocols

---

## ARCHITECTURE NOTES

### ShopService Usage:
```gdscript
# Generate shop
ShopService.generate_shop(wave, "premium")

# Get shop items
var items = ShopService.get_shop_items()

# Purchase item
var purchased = ShopService.purchase_item(character_id, item_id)

# Reroll shop
var new_items = ShopService.reroll_shop(character_id)

# Get reroll cost (with tier discounts)
var cost = ShopService.get_reroll_cost(character_id)
```

### Rarity Weights by Tier:
| Tier | Common | Uncommon | Rare | Epic | Legendary |
|------|--------|----------|------|------|-----------|
| Free | 60% | 30% | 8% | 1.5% | 0.5% |
| Premium | 40% | 35% | 20% | 4% | 1% |
| Subscription | 30% | 30% | 30% | 8% | 2% |

---

## KNOWN ISSUES / NOTES

1. **InventoryService Missing**: ShopService purchase flow returns item but doesn't add to inventory. Phase 4 will complete the loop.

2. **Salvager Discount**: Implemented in `calculate_purchase_price()` - reads `shop_discount` from character stats.

3. **Starting Items**: Still passed via character_create_post context, awaiting InventoryService.

---

**Git Status:** Phase 3 ready to commit
**Tests:** 836/860 passing (24 pending)
**Last Commit:** `58da47d` feat: implement Week 18 Phase 2 - Character Type System with new assets
