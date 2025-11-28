# Week 20 - Workshop System (Part 2)
## Fusion, Crafting, Blueprints & Personalization

**Status:** PLANNING
**Date:** 2025-11-27
**Estimated Effort:** 5-6 hours
**Depends On:** Week 19 (Durability, Repair, Recycler, Storage)
**Focus:** Complete Workshop with Fusion and Crafting systems

---

## 🎯 WEEK OBJECTIVE

Complete the Workshop system with Fusion Tab, Craft Tab, Blueprint Library, and Personalization Station. This enables item progression and build customization.

### Design Principle

> **"Every Item Can Improve"** - Fusion and Crafting create meaningful item progression paths.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Game Designer** | Fusion balance, crafting depth |
| **Sr Economy Designer** | Blueprint costs, fusion tier caps |
| **Sr Product Manager** | Personalization value, tier features |
| **Sr SQA Engineer** | Edge cases, fusion matching rules |
| **Sr Godot Developer** | Service architecture, UI components |

---

## 📊 CURRENT STATE ANALYSIS

### What Will Exist (After Week 19)

| Component | Status | Notes |
|-----------|--------|-------|
| `ItemService` | ✅ Week 18 | Item definitions |
| `InventoryService` | ✅ Week 18 | Character inventory |
| `DurabilityService` | ✅ Week 19 | Item HP system |
| `RecyclerService` | ✅ Week 19 | Items → Components |
| `RepairService` | ✅ Week 19 | Fix damaged items |
| `StorageService` | ✅ Week 19 | Protect items |
| Workshop Components | ✅ Week 19 | Secondary currency |

### What's Missing

| Component | Priority | Notes |
|-----------|----------|-------|
| Fusion Tab | **CRITICAL** | Combine identical items |
| Craft Tab | **CRITICAL** | Create from blueprints |
| Blueprint Library | HIGH | Manage blueprints |
| Personalization | MEDIUM | Custom weapons |

---

## 🎨 KEY DESIGN ELEMENTS

### Fusion System (from GAME-DESIGN.md)

**Fusion Rules:**
- Combine **2 identical items** (same item_id)
- Items must be **same fusion tier**
- Result: **+1 fusion tier** (+10% stats)

**Fusion Tier Caps by Rarity:**
| Rarity | Max Fusion Tier |
|--------|-----------------|
| Common | 3 |
| Uncommon | 5 |
| Rare | 7 |
| Epic | 10 |
| Legendary | 15 |

**Fusion Cost:**
- Components based on tier
- Higher tiers = higher cost

**Example:**
```
2x Rusty Pistol (Tier 0) → 1x Rusty Pistol (Tier 1, +10% stats)
2x Rusty Pistol (Tier 1) → 1x Rusty Pistol (Tier 2, +20% stats)
```

### Crafting System (from WORKSHOP-SYSTEM.md)

**Blueprint Sources:**
- Drops (rare)
- Shop (purchase)
- Events (rewards)

**Craft Types:**

1. **Generic Crafts** (Limited)
   - 3 uses per blueprint
   - Cost: 25 scrap + 50 components
   - Standard stats

2. **Personalized Crafts** (Unlimited)
   - Unlimited uses
   - Cost: 200 scrap + 100 components
   - Stat bonus based on Luck + Scrap Tech
   - Custom naming
   - Visual customization

**Personalization Bonus Formula:**
```gdscript
bonus = 0.10 + (luck / 100.0) + (scrap_tech / 50.0)

# Examples:
# Luck 0, Scrap Tech 0: 10% bonus
# Luck 50, Scrap Tech 50: 160% bonus
# Luck 100, Scrap Tech 100: 310% bonus
```

### Blueprint Library

**Unlock Costs:**
| Tier | Cost |
|------|------|
| Tier 1 | FREE |
| Tier 2 | 25 scrap |
| Tier 3 | 50 scrap |
| Tier 4 | 100 scrap |

**Storage:**
- Protected in Storage Locker
- Can be transferred (Subscription - Quantum Storage)

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Fusion System (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Extend ItemInstance for fusion**
   ```gdscript
   # In ItemInstance
   var fusion_tier: int = 0

   func get_fusion_stat_multiplier() -> float:
       return 1.0 + (fusion_tier * 0.10)  # +10% per tier

   func get_fused_stats() -> Dictionary:
       var base_stats = item_definition.stats.duplicate()
       var multiplier = get_fusion_stat_multiplier()
       for stat in base_stats:
           base_stats[stat] *= multiplier
       return base_stats
   ```

2. **Create FusionService**
   ```gdscript
   class_name FusionService
   extends Node

   signal items_fused(result_item: ItemInstance, consumed_items: Array)

   const FUSION_TIER_CAPS = {
       "common": 3,
       "uncommon": 5,
       "rare": 7,
       "epic": 10,
       "legendary": 15
   }

   func can_fuse(item_a: ItemInstance, item_b: ItemInstance) -> Dictionary:
       # Must be same item type
       if item_a.item_definition.item_id != item_b.item_definition.item_id:
           return {"can_fuse": false, "reason": "DIFFERENT_ITEMS"}

       # Must be same fusion tier
       if item_a.fusion_tier != item_b.fusion_tier:
           return {"can_fuse": false, "reason": "DIFFERENT_FUSION_TIER"}

       # Check tier cap
       var rarity = item_a.item_definition.rarity
       if item_a.fusion_tier >= FUSION_TIER_CAPS[rarity]:
           return {"can_fuse": false, "reason": "MAX_FUSION_REACHED"}

       return {"can_fuse": true}

   func fuse_items(character_id: String, item_a: ItemInstance, item_b: ItemInstance) -> Dictionary:
       var check = can_fuse(item_a, item_b)
       if not check.can_fuse:
           return {"success": false, "error": check.reason}

       # Calculate component cost
       var cost = calculate_fusion_cost(item_a)
       if BankingService.get_balance(CurrencyType.COMPONENTS) < cost:
           return {"success": false, "error": "INSUFFICIENT_COMPONENTS"}

       # Deduct cost
       BankingService.subtract_currency(CurrencyType.COMPONENTS, cost)

       # Remove both items
       InventoryService.remove_item(character_id, item_a.instance_id)
       InventoryService.remove_item(character_id, item_b.instance_id)

       # Create fused item
       var fused = item_a.duplicate()
       fused.instance_id = generate_uuid()
       fused.fusion_tier += 1
       fused.current_durability = fused.max_durability  # Full durability

       # Add to inventory
       InventoryService.add_item_instance(character_id, fused)

       items_fused.emit(fused, [item_a, item_b])
       return {"success": true, "result": fused}

   func calculate_fusion_cost(item: ItemInstance) -> int:
       var tier = item.item_definition.tier
       var fusion_tier = item.fusion_tier
       return tier * 20 * (fusion_tier + 1)  # Higher tiers cost more
   ```

3. **Create Fusion UI**
   - Two item slots for selection
   - "Same item + same fusion tier" validation
   - Fusion cost display
   - Result preview (+10% stats)
   - "Fuse" button
   - Animation on fusion

4. **Unit tests**
   - Fusion validation (same item, same tier)
   - Tier cap enforcement
   - Cost calculation
   - Result item creation

**Success Criteria:**
- [ ] FusionService functional
- [ ] Same item + same tier validation
- [ ] Tier caps by rarity
- [ ] Stats increase +10% per fusion
- [ ] Fusion UI working
- [ ] Unit tests passing

---

### Phase 2: Blueprint System (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create Blueprint model**
   ```gdscript
   class_name Blueprint
   extends Resource

   var blueprint_id: String
   var item_definition_id: String  # What this blueprint creates
   var tier: int
   var generic_uses_remaining: int = 3
   var is_unlocked: bool = false
   var unlock_cost: int
   ```

2. **Create BlueprintService**
   ```gdscript
   class_name BlueprintService
   extends Node

   signal blueprint_unlocked(blueprint: Blueprint)
   signal item_crafted(item: ItemInstance, blueprint: Blueprint)

   var blueprints: Dictionary = {}  # character_id → Array[Blueprint]

   func unlock_blueprint(character_id: String, blueprint: Blueprint) -> Dictionary:
       if blueprint.is_unlocked:
           return {"success": false, "error": "ALREADY_UNLOCKED"}

       if BankingService.get_balance(CurrencyType.SCRAP) < blueprint.unlock_cost:
           return {"success": false, "error": "INSUFFICIENT_SCRAP"}

       BankingService.subtract_currency(CurrencyType.SCRAP, blueprint.unlock_cost)
       blueprint.is_unlocked = true

       blueprint_unlocked.emit(blueprint)
       return {"success": true}

   func craft_generic(character_id: String, blueprint: Blueprint) -> Dictionary:
       if blueprint.generic_uses_remaining <= 0:
           return {"success": false, "error": "NO_GENERIC_USES"}

       var cost = {"scrap": 25, "components": 50}
       if not can_afford(cost):
           return {"success": false, "error": "INSUFFICIENT_FUNDS"}

       # Deduct cost
       BankingService.subtract_currency(CurrencyType.SCRAP, cost.scrap)
       BankingService.subtract_currency(CurrencyType.COMPONENTS, cost.components)

       # Create item
       var item_def = ItemService.get_definition(blueprint.item_definition_id)
       var item = create_item_instance(item_def)

       # Add to inventory
       InventoryService.add_item_instance(character_id, item)

       # Decrement uses
       blueprint.generic_uses_remaining -= 1

       item_crafted.emit(item, blueprint)
       return {"success": true, "item": item}
   ```

3. **Create Blueprint Library UI**
   - Grid of blueprints
   - Locked/unlocked states
   - Generic uses remaining
   - Unlock cost display
   - "Craft" buttons

4. **Unit tests**
   - Blueprint unlock
   - Generic craft (3 uses)
   - Cost deduction

**Success Criteria:**
- [ ] BlueprintService functional
- [ ] Blueprint unlock with cost
- [ ] Generic crafts (3 uses)
- [ ] Items created correctly
- [ ] Blueprint Library UI working
- [ ] Unit tests passing

---

### Phase 3: Personalization Station (1.5-2 hours)
**Priority:** MEDIUM

#### Tasks

1. **Extend BlueprintService for personalization**
   ```gdscript
   func craft_personalized(
       character_id: String,
       blueprint: Blueprint,
       custom_name: String,
       luck: int,
       scrap_tech: int
   ) -> Dictionary:
       var cost = {"scrap": 200, "components": 100}
       if not can_afford(cost):
           return {"success": false, "error": "INSUFFICIENT_FUNDS"}

       # Deduct cost
       BankingService.subtract_currency(CurrencyType.SCRAP, cost.scrap)
       BankingService.subtract_currency(CurrencyType.COMPONENTS, cost.components)

       # Calculate bonus
       var bonus = 0.10 + (luck / 100.0) + (scrap_tech / 50.0)

       # Create item with bonus
       var item_def = ItemService.get_definition(blueprint.item_definition_id)
       var item = create_item_instance(item_def)
       item.custom_name = custom_name
       item.personalization_bonus = bonus
       item.is_soulbound = true  # Can't transfer

       # Add to inventory
       InventoryService.add_item_instance(character_id, item)

       item_crafted.emit(item, blueprint)
       return {"success": true, "item": item, "bonus": bonus}
   ```

2. **Extend ItemInstance for personalization**
   ```gdscript
   var custom_name: String = ""
   var personalization_bonus: float = 0.0
   var is_soulbound: bool = false

   func get_display_name() -> String:
       if custom_name != "":
           return custom_name
       return item_definition.name

   func get_personalized_stats() -> Dictionary:
       var base = get_fused_stats()
       var multiplier = 1.0 + personalization_bonus
       for stat in base:
           base[stat] *= multiplier
       return base
   ```

3. **Create Personalization UI**
   - Blueprint selection
   - Custom name input
   - Stat bonus preview (based on Luck + Scrap Tech)
   - Cost display (200 scrap + 100 components)
   - "Craft" button
   - Result preview

4. **Visual customization (if time)**
   - Color tint options (Scrap Tech 25+)
   - Particle effects (Scrap Tech 50+)
   - Sound effects (Scrap Tech 75+)

**Success Criteria:**
- [ ] Personalized crafts work
- [ ] Bonus based on Luck + Scrap Tech
- [ ] Custom naming
- [ ] Soulbound flag set
- [ ] Personalization UI working

---

### Phase 4: Workshop UI Integration (0.5-1 hour)
**Priority:** HIGH

#### Tasks

1. **Update Workshop screen**
   - Add Fusion tab
   - Add Craft tab
   - Ensure all tabs accessible

2. **Tab navigation**
   - Repair (Week 19)
   - Recycler (Week 19)
   - Storage (Week 19)
   - Fusion (NEW)
   - Craft (NEW)

3. **Device QA**
   - Touch targets
   - Scroll behavior
   - Tab switching

**Success Criteria:**
- [ ] All Workshop tabs accessible
- [ ] Tab navigation smooth
- [ ] Device QA passed

---

## 🧪 QA CHECKLIST

### Automated Tests

- [ ] Fusion validation tests
- [ ] Fusion tier cap tests
- [ ] Fusion cost tests
- [ ] Blueprint unlock tests
- [ ] Generic craft tests
- [ ] Personalization bonus tests

### Manual Testing (Device)

**Fusion:**
- [ ] Fusion UI accessible
- [ ] Can select two identical items
- [ ] Same fusion tier required
- [ ] Fusion cost displayed
- [ ] Fusion creates +1 tier item
- [ ] Stats increase 10% per tier
- [ ] Tier caps enforced

**Blueprints:**
- [ ] Blueprint Library accessible
- [ ] Locked blueprints show cost
- [ ] Can unlock blueprints
- [ ] Generic crafts work (3 uses)
- [ ] Uses decrement correctly

**Personalization:**
- [ ] Personalization UI accessible
- [ ] Custom name input works
- [ ] Bonus preview shows correctly
- [ ] Crafted items have bonus
- [ ] Soulbound items can't transfer

---

## 📊 SUCCESS METRICS

**Week 20 Definition of Done:**

| Metric | Target |
|--------|--------|
| Fusion system | Functional |
| Tier caps | By rarity |
| Blueprint crafts | Generic + Personalized |
| Personalization bonus | Luck + Scrap Tech formula |
| Workshop tabs | All 5 accessible |

---

## 📂 FILE STRUCTURE

```
scripts/
├── services/
│   ├── fusion_service.gd        # NEW
│   └── blueprint_service.gd     # NEW
├── resources/
│   └── blueprint.gd             # NEW
├── tests/
│   ├── fusion_service_test.gd   # NEW
│   └── blueprint_service_test.gd # NEW

scenes/
├── ui/
│   └── components/
│       ├── fusion_tab.tscn      # NEW
│       ├── craft_tab.tscn       # NEW
│       └── blueprint_card.tscn  # NEW
```

---

## 📝 NOTES FOR WEEK 21

**Post-Run Flow + Meta Progression (Week 21) will add:**
- Post-run summary screen
- Scrap → Chips conversion
- Meta progression upgrades
- Complete roguelite loop

**Dependencies:**
- Shop must exist (Week 18)
- Workshop must exist (Weeks 19-20)

---

## Implementation Status (LIVING SECTION)

**Last Updated**: 2025-11-27 by Claude Code

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: Fusion | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 2: Blueprints | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 3: Personalization | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 4: UI Integration | 0.5-1h | - | ⏭️ PENDING | - | - |

**Total Estimated**: 5-6 hours

---

**Document Version:** 1.0
**Created:** 2025-11-27
**Next Review:** After Week 19 completion
