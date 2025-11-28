# Week 19 - Workshop System (Part 1)
## Durability, Repair, Recycler & Storage

**Status:** PLANNING
**Date:** 2025-11-27
**Estimated Effort:** 5-6 hours
**Depends On:** Week 18 (Shop + Inventory)
**Focus:** Item durability system and Workshop economy foundation

---

## 🎯 WEEK OBJECTIVE

Implement the Workshop foundation: durability system, Repair Tab, Recycler Tab, and Storage Locker. This creates the death penalty loop and Workshop economy.

### Design Principle

> **"Death Has Consequences"** - Items degrade on death, creating meaningful risk and Workshop engagement.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Game Designer** | Death penalty balance, repair pacing |
| **Sr Economy Designer** | Component economy, repair costs, storage fees |
| **Sr Product Manager** | Tier differentiation (10%/5%/2%), monetization levers |
| **Sr SQA Engineer** | Durability edge cases, save/load validation |
| **Sr Godot Developer** | Service architecture, persistence, UI integration |

---

## 📊 CURRENT STATE ANALYSIS

### What Will Exist (After Week 18)

| Component | Status | Notes |
|-----------|--------|-------|
| `ItemService` | ✅ Week 18 | Item definitions |
| `InventoryService` | ✅ Week 18 | Character inventory |
| `ShopService` | ✅ Week 18 | Item purchasing |
| `BankingService` | ✅ Existing | Currency management |

### What's Missing

| Component | Priority | Notes |
|-----------|----------|-------|
| Durability system | **CRITICAL** | Items have HP, degrade on death |
| Workshop Components | **CRITICAL** | Secondary currency for repairs |
| Repair Tab | **CRITICAL** | Fix damaged items |
| Recycler Tab | **CRITICAL** | Items → Components |
| Storage Locker | HIGH | Protect items from death |
| Workshop UI | HIGH | Tab-based interface |

---

## 🎨 KEY DESIGN ELEMENTS

### Durability System (from INVENTORY-SYSTEM.md)

**Max Durability by Rarity:**
| Rarity | Max HP |
|--------|--------|
| Common | 100 |
| Uncommon | 200 |
| Rare | 400 |
| Epic | 800 |
| Legendary | 1600 |

**Death Penalty by Tier:**
| Tier | Durability Loss | Deaths to Destroy Common |
|------|-----------------|--------------------------|
| Free | 10% | ~10 deaths |
| Premium | 5% | ~20 deaths |
| Subscription | 2% | ~50 deaths |

**Formula:**
```gdscript
durability_loss = base_penalty[rarity] * type_multiplier[type] * random_factor(0.8, 1.2)

# Type multipliers
TYPE_MULTIPLIERS = {
    "weapon": 1.5,    # Weapons fragile
    "armor": 0.5,     # Armor durable
    "trinket": 1.0,   # Standard
    "consumable": 0.0 # No durability
}
```

### Workshop Components

**Sources:**
- Recycling items (primary)
- Combat drops (rare)

**Uses:**
- Repair items
- Crafting (Week 20)
- Fusion (Week 20)

**Yield by Tier (from recycling):**
| Tier | Component Yield |
|------|-----------------|
| Tier 1 | 5-10 |
| Tier 2 | 15-25 |
| Tier 3 | 30-50 |
| Tier 4 | 75-125 |

### Repair Costs

**Two Payment Options:**

1. **Workshop Components** (Free currency)
   - Base cost = tier × durability_lost × 2
   - With Scrap Tech skill: cost × (1.0 - scrap_tech/100)

2. **Scrap (Repair Fund)** (Convenience)
   - Cost = 3× component cost
   - Auto-deducts from Repair Fund

### Storage Locker

**Protection:**
- Items in storage: 0% durability loss on death
- Blueprints: Protected
- Components: Protected

**Storage Fees (Daily):**
| Tier | Item Cost | Blueprint Cost |
|------|-----------|----------------|
| Free | 15 scrap/item/day | 20 scrap/blueprint/day |
| Premium | 10 scrap/item/day | 10 scrap/blueprint/day |
| Subscription | FREE | FREE |

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Durability System (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Add durability to Item model**
   ```gdscript
   # Extend ItemDefinition or create ItemInstance
   class_name ItemInstance
   extends Resource

   var item_definition: ItemDefinition
   var current_durability: int
   var max_durability: int
   var instance_id: String  # Unique per item instance

   func get_durability_percent() -> float:
       return float(current_durability) / float(max_durability)

   func is_broken() -> bool:
       return current_durability <= 0
   ```

2. **Implement death penalty logic**
   ```gdscript
   # In InventoryService or new DurabilityService
   func apply_death_penalty(character_id: String, tier: String) -> Dictionary:
       var penalty_rate = DEATH_PENALTIES[tier]  # 0.10, 0.05, or 0.02
       var damaged_items = []
       var destroyed_items = []

       for item in get_character_items(character_id):
           if item.item_definition.type == "consumable":
               continue  # No durability

           var loss = calculate_durability_loss(item, penalty_rate)
           item.current_durability -= loss

           if item.current_durability <= 0:
               destroyed_items.append(item)
               remove_item(character_id, item.instance_id)
           else:
               damaged_items.append({"item": item, "loss": loss})

       return {
           "damaged": damaged_items,
           "destroyed": destroyed_items
       }
   ```

3. **Add durability UI to item cards**
   - Durability bar on item card
   - Color coding (green → yellow → red)
   - "BROKEN" indicator at 0%

4. **Unit tests**
   - Death penalty calculation
   - Type multipliers
   - Tier-based rates
   - Destruction at 0 HP

**Success Criteria:**
- [ ] Items have durability
- [ ] Death reduces durability by tier (10%/5%/2%)
- [ ] Type multipliers working
- [ ] Items destroyed at 0 HP
- [ ] Durability displayed on UI
- [ ] Unit tests passing

---

### Phase 2: Workshop Components + Recycler (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Add Workshop Components to BankingService**
   ```gdscript
   # In BankingService
   enum CurrencyType {
       SCRAP,
       COMPONENTS,  # NEW
       PREMIUM,
       NANITES
   }
   ```

2. **Create RecyclerService (or extend existing)**
   ```gdscript
   class_name RecyclerService
   extends Node

   signal item_recycled(item: ItemInstance, components: int)

   const TIER_YIELDS = {
       1: {"min": 5, "max": 10},
       2: {"min": 15, "max": 25},
       3: {"min": 30, "max": 50},
       4: {"min": 75, "max": 125}
   }

   func recycle_item(character_id: String, item: ItemInstance) -> Dictionary:
       # Calculate yield based on tier
       var tier = item.item_definition.tier
       var base_yield = randi_range(TIER_YIELDS[tier].min, TIER_YIELDS[tier].max)

       # Apply Scrap Tech bonus (future)
       # var bonus = 1.0 + (scrap_tech / 50.0)
       # var final_yield = int(base_yield * bonus)

       # Remove item from inventory
       InventoryService.remove_item(character_id, item.instance_id)

       # Add components
       BankingService.add_currency(CurrencyType.COMPONENTS, base_yield)

       item_recycled.emit(item, base_yield)
       return {"success": true, "components": base_yield}
   ```

3. **Create Recycler UI**
   - List of recyclable items
   - Show yield preview
   - Confirm before recycling
   - Animation on recycle

4. **Unit tests**
   - Yield calculations
   - Component awarding
   - Item removal

**Success Criteria:**
- [ ] Workshop Components currency exists
- [ ] RecyclerService functional
- [ ] Tier-based yields working
- [ ] Items removed on recycle
- [ ] Components awarded
- [ ] Recycler UI working

---

### Phase 3: Repair Tab (1-1.5 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create RepairService**
   ```gdscript
   class_name RepairService
   extends Node

   signal item_repaired(item: ItemInstance, cost: int, currency: String)

   func calculate_repair_cost(item: ItemInstance) -> Dictionary:
       var durability_lost = item.max_durability - item.current_durability
       var tier = item.item_definition.tier

       # Component cost
       var component_cost = tier * durability_lost * 2 / 100  # Per 1% lost

       # Scrap cost (3x components)
       var scrap_cost = component_cost * 3

       return {
           "components": component_cost,
           "scrap": scrap_cost,
           "durability_to_restore": durability_lost
       }

   func repair_with_components(character_id: String, item: ItemInstance) -> Dictionary:
       var cost = calculate_repair_cost(item)

       if BankingService.get_balance(CurrencyType.COMPONENTS) < cost.components:
           return {"success": false, "error": "INSUFFICIENT_COMPONENTS"}

       BankingService.subtract_currency(CurrencyType.COMPONENTS, cost.components)
       item.current_durability = item.max_durability

       item_repaired.emit(item, cost.components, "components")
       return {"success": true}

   func repair_with_scrap(character_id: String, item: ItemInstance) -> Dictionary:
       var cost = calculate_repair_cost(item)

       if BankingService.get_balance(CurrencyType.SCRAP) < cost.scrap:
           return {"success": false, "error": "INSUFFICIENT_SCRAP"}

       BankingService.subtract_currency(CurrencyType.SCRAP, cost.scrap)
       item.current_durability = item.max_durability

       item_repaired.emit(item, cost.scrap, "scrap")
       return {"success": true}
   ```

2. **Create Repair UI**
   - List of damaged items
   - Show repair cost (both options)
   - "Repair" buttons (Components / Scrap)
   - Durability bar before/after preview

3. **Integrate Repair Fund (if implemented)**
   - Auto-deduct from Repair Fund
   - Show Repair Fund balance

4. **Unit tests**
   - Cost calculation
   - Repair flow
   - Currency deduction

**Success Criteria:**
- [ ] RepairService functional
- [ ] Cost calculation correct
- [ ] Repair with Components works
- [ ] Repair with Scrap works
- [ ] Repair UI functional
- [ ] Durability restored to max

---

### Phase 4: Storage Locker (1-1.5 hours)
**Priority:** HIGH

#### Tasks

1. **Create StorageService**
   ```gdscript
   class_name StorageService
   extends Node

   signal item_stored(item: ItemInstance)
   signal item_retrieved(item: ItemInstance)

   var stored_items: Dictionary = {}  # character_id → Array[ItemInstance]

   func store_item(character_id: String, item: ItemInstance) -> Dictionary:
       # Move from inventory to storage
       InventoryService.remove_item(character_id, item.instance_id)

       if not stored_items.has(character_id):
           stored_items[character_id] = []
       stored_items[character_id].append(item)

       item_stored.emit(item)
       return {"success": true}

   func retrieve_item(character_id: String, item: ItemInstance) -> Dictionary:
       # Check inventory space
       if not InventoryService.can_add_item(character_id, item.item_definition).can_add:
           return {"success": false, "error": "INVENTORY_FULL"}

       # Move from storage to inventory
       stored_items[character_id].erase(item)
       InventoryService.add_item_instance(character_id, item)

       item_retrieved.emit(item)
       return {"success": true}

   func apply_storage_fees(character_id: String, tier: String) -> Dictionary:
       # Called daily or on login
       var fees = STORAGE_FEES[tier]
       var total_fee = stored_items[character_id].size() * fees.item_cost

       if BankingService.get_balance(CurrencyType.SCRAP) < total_fee:
           # Insufficient funds - items ejected or kept with debt?
           return {"success": false, "error": "INSUFFICIENT_FUNDS", "fee": total_fee}

       BankingService.subtract_currency(CurrencyType.SCRAP, total_fee)
       return {"success": true, "fee_paid": total_fee}
   ```

2. **Death penalty integration**
   - Stored items: 0% durability loss
   - Only active inventory items degrade

3. **Create Storage Locker UI**
   - Grid of stored items
   - Store/Retrieve buttons
   - Daily fee display
   - Subscription upsell (FREE storage)

4. **Unit tests**
   - Store/retrieve flow
   - Death penalty exclusion
   - Fee calculation

**Success Criteria:**
- [ ] StorageService functional
- [ ] Items can be stored/retrieved
- [ ] Stored items protected from death
- [ ] Storage fees by tier
- [ ] Storage Locker UI working

---

## 🧪 QA CHECKLIST

### Automated Tests

- [ ] Durability calculation tests
- [ ] Death penalty tests (all tiers)
- [ ] Type multiplier tests
- [ ] Recycler yield tests
- [ ] Repair cost tests
- [ ] Storage protection tests

### Manual Testing (Device)

**Durability:**
- [ ] Items show durability bar
- [ ] Death reduces durability
- [ ] Free tier: 10% loss
- [ ] Premium tier: 5% loss
- [ ] Subscription tier: 2% loss
- [ ] Items destroyed at 0%

**Recycler:**
- [ ] Recycler UI accessible
- [ ] Items can be recycled
- [ ] Components awarded correctly
- [ ] Tier-based yields work

**Repair:**
- [ ] Repair UI accessible
- [ ] Damaged items listed
- [ ] Repair cost displayed
- [ ] Repair with Components works
- [ ] Repair with Scrap works
- [ ] Durability restored

**Storage:**
- [ ] Storage Locker accessible
- [ ] Items can be stored
- [ ] Items can be retrieved
- [ ] Stored items protected from death
- [ ] Storage fees deducted (Free/Premium)
- [ ] Subscription: FREE storage

---

## 📊 SUCCESS METRICS

**Week 19 Definition of Done:**

| Metric | Target |
|--------|--------|
| Durability system | Functional |
| Death penalties | 10%/5%/2% by tier |
| Recycler | Yields components |
| Repair | Both payment methods |
| Storage | Protects from death |
| Unit tests | 100% for new services |

---

## 📂 FILE STRUCTURE

```
scripts/
├── services/
│   ├── durability_service.gd    # NEW (or extend InventoryService)
│   ├── recycler_service.gd      # UPDATE existing
│   ├── repair_service.gd        # NEW
│   └── storage_service.gd       # NEW
├── tests/
│   ├── durability_service_test.gd  # NEW
│   ├── repair_service_test.gd      # NEW
│   └── storage_service_test.gd     # NEW

scenes/
├── ui/
│   ├── workshop_screen.tscn        # NEW - tab container
│   └── components/
│       ├── repair_tab.tscn         # NEW
│       ├── recycler_tab.tscn       # NEW
│       └── storage_tab.tscn        # NEW
```

---

## 📝 NOTES FOR WEEK 20

**Workshop Part 2 (Week 20) will add:**
- Fusion Tab (combine identical items)
- Craft Tab (create from blueprints)
- Blueprint Library
- Personalization Station

**Dependencies:**
- Fusion requires same item type + same fusion tier matching
- Crafting requires Blueprint items

---

## Implementation Status (LIVING SECTION)

**Last Updated**: 2025-11-27 by Claude Code

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: Durability | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 2: Recycler | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 3: Repair | 1-1.5h | - | ⏭️ PENDING | - | - |
| Phase 4: Storage | 1-1.5h | - | ⏭️ PENDING | - | - |

**Total Estimated**: 5-6 hours

---

**Document Version:** 1.0
**Created:** 2025-11-27
**Next Review:** After Week 18 completion
