# Week 18 - Shop System + Item/Inventory Foundation
## Core Economy & Build Variety

**Status:** PLANNING
**Date:** 2025-11-27
**Estimated Effort:** 6-8 hours
**Focus:** Enable players to buy items during runs, creating the core roguelite decision loop

---

## 🎯 WEEK OBJECTIVE

Implement the Shop system and Item/Inventory foundation that enables the core roguelite gameplay loop: Combat → Shop → Build Decisions → Combat.

### Design Principle

> **"Every Shop is a Decision"** - The Shop creates meaningful choices that define builds and playstyles.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Game Designer** | Shop flow, item variety, build diversity |
| **Sr Economy Designer** | Pricing, reroll costs, item rarity balance |
| **Sr Product Manager** | Feature scope, MVP definition, tier gating |
| **Sr SQA Engineer** | Test coverage, edge cases, inventory validation |
| **Sr Godot Developer** | Service architecture, auto-active system, persistence |

---

## 📊 CURRENT STATE ANALYSIS

### What Exists

| Component | Status | Notes |
|-----------|--------|-------|
| `BankingService` | ✅ Implemented | Currency management (Scrap, Components, etc.) |
| `WeaponService` | ✅ Implemented | 10 weapons with behaviors |
| `DropSystem` | ✅ Implemented | Pickups during combat |
| Combat loop | ✅ Implemented | Waves, enemies, player |
| Scrap collection | ✅ Implemented | Currency earned in combat |

### What's Missing

| Component | Priority | Notes |
|-----------|----------|-------|
| `ItemService` | **CRITICAL** | Item definitions (all types) |
| `InventoryService` | **CRITICAL** | Character inventory, slots, auto-active |
| `ShopService` | **CRITICAL** | Shop generation, purchasing, rerolls |
| Shop UI | **CRITICAL** | Between-wave shop screen |
| Item effects | HIGH | Stats applied from owned items |

---

## 🎨 KEY DESIGN ELEMENTS

### Item Types (from INVENTORY-SYSTEM.md)

| Type | Description | Auto-Active |
|------|-------------|-------------|
| **Weapons** | Auto-fire, multiple simultaneous | ✅ Yes (6 max wielded) |
| **Armor** | Defensive stats | ✅ Yes |
| **Trinkets** | Special bonuses (luck, crit, XP) | ✅ Yes |
| **Consumables** | Temporary buffs | ✅ Yes (while owned) |
| **Minions** | AI companions (Premium+) | Special (1 active in combat) |
| **Blueprints** | Crafting recipes | N/A (Workshop use) |

### Inventory Limits (from docs)

| Limit | Value | Notes |
|-------|-------|-------|
| Total item slots | **30** | Per character |
| Weapon slots | **6** | Max simultaneously wielded |
| Stack limits | By rarity | Common: 5, Uncommon: 4, Rare: 3, Epic: 2, Legendary: 1 |

### Weapon System

- **All 6 weapons auto-fire** simultaneously
- Each weapon has own `fireRate`, `range`, `damageType`
- `finalDPS = Σ(allWeaponDPS) + Σ(damageBoostItems)`
- Different fire rates = varied attack patterns

### Shop Types (from SHOPS-SYSTEM.md)

| Shop | Access | Items | Refresh |
|------|--------|-------|---------|
| **Standard Shop** | All tiers | Weapons, Armor, Trinkets, Consumables | 4h or between waves |
| **Black Market** | Premium+ | High-risk items, Minions | 8h |
| **Atomic Vending** | Subscription | Personalized, Minion Patterns | 24h |

**MVP Scope:** Standard Shop only (others are config changes later)

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: ItemService + Item Definitions (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create `ItemService`**
   - Item definition loading
   - Item creation/instantiation
   - Rarity system
   - Item type categorization

2. **Define item data structure**
   ```gdscript
   class_name ItemDefinition
   extends Resource

   @export var item_id: String
   @export var name: String
   @export var description: String
   @export var type: String  # weapon, armor, trinket, consumable, minion, blueprint
   @export var rarity: String  # common, uncommon, rare, epic, legendary
   @export var tier: int  # 1-4
   @export var base_price: int
   @export var stats: Dictionary  # {stat_name: value}
   @export var tags: Array[String]  # Item tags for shop affinity
   @export var stack_limit: int  # Based on rarity
   @export var is_premium: bool
   @export var limit_per_run: int  # 0 = unlimited, 1 = one-limit items

   # Weapon-specific
   @export var fire_rate: float
   @export var range: float
   @export var damage_type: String
   @export var projectile_count: int
   ```

3. **Create initial item definitions**
   - 10-15 weapons (expand existing)
   - 10-15 armor items
   - 10-15 trinkets
   - 5-10 consumables
   - Total: ~40-55 items for MVP

4. **Unit tests**
   - Item loading
   - Rarity validation
   - Stats calculation

**Success Criteria:**
- [ ] ItemService created and registered
- [ ] 40+ item definitions created
- [ ] All item types represented
- [ ] Unit tests passing

---

### Phase 2: InventoryService (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create `InventoryService`**
   - Add/remove items
   - Slot management (30 total, 6 weapons)
   - Stack limit enforcement
   - Auto-active stat calculation

2. **Implement inventory model**
   ```gdscript
   class_name InventoryService
   extends Node

   signal inventory_changed(character_id: String)
   signal item_added(character_id: String, item: Dictionary)
   signal item_removed(character_id: String, item_id: String)
   signal stats_recalculated(character_id: String, stats: Dictionary)

   const MAX_TOTAL_SLOTS = 30
   const MAX_WEAPON_SLOTS = 6

   # Stack limits by rarity
   const STACK_LIMITS = {
       "common": 5,
       "uncommon": 4,
       "rare": 3,
       "epic": 2,
       "legendary": 1
   }

   func can_add_item(character_id: String, item_def: ItemDefinition) -> Dictionary:
       # Check total slots
       # Check weapon slots if weapon
       # Check stack limits
       # Return {can_add: bool, reason: String}

   func add_item(character_id: String, item_def: ItemDefinition) -> Dictionary:
       # Add item to inventory
       # Recalculate auto-active stats
       # Emit signals

   func get_auto_active_stats(character_id: String) -> Dictionary:
       # Sum all item stats for character
       # All items in inventory contribute
   ```

3. **Implement character-type slot allocation**
   - Tank: 15 defensive, 10 offensive, 5 utility
   - DPS: 15 offensive, 10 defensive, 5 utility
   - Support: 15 utility, 10 defensive, 5 offensive

4. **Integrate with existing systems**
   - Connect to CharacterService
   - Update StatService to include inventory stats

5. **Unit tests**
   - Add/remove items
   - Slot limit enforcement
   - Stack limit enforcement
   - Auto-active stat calculation

**Success Criteria:**
- [ ] InventoryService created and registered
- [ ] 30-slot limit enforced
- [ ] 6-weapon limit enforced
- [ ] Stack limits by rarity working
- [ ] Auto-active stats calculating
- [ ] Unit tests passing

---

### Phase 3: ShopService (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create `ShopService`**
   - Shop inventory generation
   - Item purchasing
   - Reroll system
   - Price calculation

2. **Implement shop model**
   ```gdscript
   class_name ShopService
   extends Node

   signal shop_refreshed(shop_type: String, items: Array)
   signal item_purchased(item: Dictionary, price: int)
   signal shop_rerolled(shop_type: String, cost: int)

   const SHOP_SIZE = 6  # Items per shop
   const BASE_REROLL_COST = 50
   const REROLL_ESCALATION = [50, 100, 200, 400, 800]

   var current_shop_items: Array = []
   var reroll_count: int = 0

   func generate_shop(wave: int, character_tags: Array) -> Array:
       # Generate SHOP_SIZE items
       # Weight by rarity (60% common, 30% uncommon, 8% rare, 2% epic/legendary)
       # 5% chance to match character tags
       # Wave guarantees (Wave 5: T2, Wave 10: T3, etc.)

   func purchase_item(character_id: String, item_index: int) -> Dictionary:
       # Validate can purchase (inventory space, currency)
       # Deduct currency via BankingService
       # Add item via InventoryService
       # Remove from shop

   func reroll_shop() -> Dictionary:
       # Deduct reroll cost
       # Increment reroll_count
       # Generate new shop
   ```

3. **Implement tier/rarity weighting**
   ```gdscript
   const DROP_WEIGHTS = {
       "common": 0.60,
       "uncommon": 0.30,
       "rare": 0.08,
       "epic": 0.015,
       "legendary": 0.005
   }

   # Wave guarantees
   const WAVE_GUARANTEES = {
       5: {"min_tier": 2},
       10: {"min_tier": 3},
       15: {"min_tier": 3},
       20: {"min_tier": 4}  # Boss wave
   }
   ```

4. **Implement character tag affinity**
   - 5% chance shop selects from character's tagged items
   - Tags: Max HP, Damage, Speed, Luck, etc. (23 tags)

5. **Unit tests**
   - Shop generation
   - Purchase flow
   - Reroll cost escalation
   - Wave guarantees

**Success Criteria:**
- [ ] ShopService created and registered
- [ ] Shop generates 6 items
- [ ] Rarity weighting working
- [ ] Wave guarantees working
- [ ] Reroll with escalating costs
- [ ] Purchase integrates with Banking + Inventory
- [ ] Unit tests passing

---

### Phase 4: Shop UI (1.5-2 hours)
**Priority:** HIGH

#### Tasks

1. **Create Shop screen scene**
   - `scenes/ui/shop_screen.tscn`
   - Grid of item cards (6 items)
   - Scrap balance display
   - Reroll button with cost
   - "Continue" button

2. **Shop item card component**
   - Item name, icon
   - Rarity indicator (color)
   - Stats preview
   - Price
   - "Buy" button
   - "Can't Afford" state
   - "Inventory Full" state

3. **Wire up shop flow**
   - Show between waves
   - Trigger from wave completion
   - Return to combat on "Continue"

4. **Integrate multi-weapon display**
   - Show current weapons (6 slots)
   - Indicate which slot new weapon would take
   - Preview DPS change

5. **Device QA**
   - Touch targets (44pt minimum)
   - Scroll if needed
   - Art Bible compliance

**Success Criteria:**
- [ ] Shop screen accessible between waves
- [ ] All 6 items displayed
- [ ] Purchase works and updates UI
- [ ] Reroll works with escalating costs
- [ ] Scrap balance updates correctly
- [ ] "Continue" returns to combat
- [ ] Device QA passed

---

## 🧪 QA CHECKLIST

### Automated Tests

- [ ] ItemService unit tests
- [ ] InventoryService unit tests
- [ ] ShopService unit tests
- [ ] Stack limit tests
- [ ] Slot limit tests
- [ ] Auto-active stat tests
- [ ] Purchase flow integration tests

### Manual Testing (Device)

**Shop Flow:**
- [ ] Shop appears between waves
- [ ] 6 items displayed correctly
- [ ] Prices shown for each item
- [ ] Can purchase item (currency deducted)
- [ ] Item appears in inventory
- [ ] Reroll button works
- [ ] Reroll cost escalates
- [ ] "Continue" returns to combat

**Inventory:**
- [ ] Can't exceed 30 item slots
- [ ] Can't exceed 6 weapon slots
- [ ] Stack limits enforced
- [ ] Auto-active stats apply to character

**Weapons:**
- [ ] Multiple weapons fire simultaneously
- [ ] Different fire rates work
- [ ] New weapon adds to loadout (up to 6)

---

## 📊 SUCCESS METRICS

**Week 18 Definition of Done:**

| Metric | Target |
|--------|--------|
| Item definitions | 40+ |
| Shop items displayed | 6 |
| Inventory slots | 30 (6 weapons) |
| Unit test coverage | 100% for new services |
| Device QA | All manual tests passing |

---

## 📂 FILE STRUCTURE

```
scripts/
├── services/
│   ├── item_service.gd           # NEW
│   ├── inventory_service.gd      # NEW
│   └── shop_service.gd           # NEW
├── resources/
│   └── item_definition.gd        # NEW
├── tests/
│   ├── item_service_test.gd      # NEW
│   ├── inventory_service_test.gd # NEW
│   └── shop_service_test.gd      # NEW

scenes/
├── ui/
│   ├── shop_screen.tscn          # NEW
│   └── components/
│       └── shop_item_card.tscn   # NEW

resources/
└── items/
    ├── weapons/                   # NEW - weapon definitions
    ├── armor/                     # NEW - armor definitions
    ├── trinkets/                  # NEW - trinket definitions
    └── consumables/               # NEW - consumable definitions
```

---

## 📝 NOTES FOR WEEK 19

**Workshop Part 1 (Week 19) will build on this:**
- Durability system (items have HP)
- Repair Tab (fix damaged items)
- Recycler Tab (items → Workshop Components)
- Storage Locker (protect items from death)

**Dependencies:**
- InventoryService must track item durability
- Items must be identifiable for repair costs

---

## Implementation Status (LIVING SECTION)

**Last Updated**: 2025-11-27 by Claude Code
**Current Session**: See `.system/NEXT_SESSION.md` for detailed notes

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: ItemService | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 2: InventoryService | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 3: ShopService | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 4: Shop UI | 1.5-2h | - | ⏭️ PENDING | - | - |

**Total Estimated**: 6-8 hours

---

**Document Version:** 1.0
**Created:** 2025-11-27
**Next Review:** After Phase 1 completion
