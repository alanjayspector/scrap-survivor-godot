# Week 18 - Shop System + Item/Inventory Foundation
## Core Economy & Build Variety

**Status:** PLANNING COMPLETE - Ready for Implementation  
**Date:** 2025-11-27  
**Estimated Effort:** 8-10 hours (expanded scope)  
**Focus:** Enable players to buy items during runs, creating the core roguelite decision loop

---

## 🎯 WEEK OBJECTIVE

Implement the Shop system and Item/Inventory foundation that enables the core roguelite gameplay loop: Combat → Shop → Build Decisions → Combat.

### Design Principles

> **"Every Shop is a Decision"** - The Shop creates meaningful choices that define builds and playstyles.

> **"Tiers Gate Shops, Not Items"** - Once you own an item, it's yours forever. Tiers control WHERE you can buy, not WHAT you own.

> **"Characters Define Builds"** - Character types have different weapon slots, starting gear, and stat modifiers that create meaningful variety.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Game Designer** | Shop flow, item variety, build diversity, character archetypes |
| **Sr Economy Designer** | Pricing, reroll costs, item rarity balance |
| **Sr Product Manager** | Feature scope, MVP definition, tier gating |
| **Sr SQA Engineer** | Test coverage, edge cases, inventory validation |
| **Sr Godot Developer** | Service architecture, perk hooks, persistence |

---

## 📊 CURRENT STATE ANALYSIS

### What Exists

| Component | Status | Notes |
|-----------|--------|-------|
| `BankingService` | ✅ Implemented | Currency management (Scrap, Components, Nanites) |
| `WeaponService` | ✅ Implemented | 10 weapons with behaviors, needs migration |
| `CharacterService` | ✅ Implemented | Character CRUD, needs type configuration |
| `DropSystem` | ✅ Implemented | Pickups during combat |
| Combat loop | ✅ Implemented | Waves, enemies, player |
| Scrap collection | ✅ Implemented | Currency earned in combat |
| UI Design System | ✅ Implemented | Rarity colors, spacing, typography |

### What's Missing (This Week)

| Component | Priority | Notes |
|-----------|----------|-------|
| `ItemService` | **CRITICAL** | Unified item definitions (all types) |
| `InventoryService` | **CRITICAL** | Character inventory, slots, auto-active |
| `ShopService` | **CRITICAL** | Shop generation, purchasing, rerolls |
| Character Type System | **CRITICAL** | Weapon slots, starting items per type |
| Shop UI | **HIGH** | Between-wave shop screen |
| Perk Hooks | **HIGH** | Integration points for future perks |

---

## 🎨 KEY DESIGN DECISIONS (Confirmed with Alan)

### Decision 1: Unified Item Database (Option B - JSON Dictionary)

All items (weapons, armor, trinkets, consumables) live in a single dictionary database. Weapons migrate FROM `WeaponService.WEAPON_DEFINITIONS` TO `ItemService`.

```gdscript
# Single source of truth for all item definitions
const ITEM_DATABASE = {
    "weapon_rusty_blade": { ... },
    "armor_scrap_vest": { ... },
    "trinket_lucky_coin": { ... },
}
```

**Rationale:** Consistent data structure, easier to maintain, single source of truth.

### Decision 2: No Tier-Gated Items (Option C)

Items have NO `tier_required` field. Tiers gate SHOPS, not items.

| Scenario | Behavior |
|----------|----------|
| Free player finds Legendary in combat | ✅ Keeps it forever |
| Premium player buys from Black Market | ✅ Owns item forever |
| Subscription player cancels | ✅ Keeps ALL owned items |

**Rationale:** Simpler, fairer, avoids player rage. Subscription value comes from ACCESS and CONVENIENCE.

### Decision 3: Character Types Define Builds

Character types configure:
- Weapon slot count (1-10+)
- Inventory slot count (30-50)
- Starting items
- Stat modifiers (bonuses/penalties)
- Item tags (for future shop affinity)

**MVP Character Types (AUTHORITATIVE - see CHARACTER-SYSTEM.md):**
- 3 Free: Scavenger, Rustbucket, Hotshot
- 2 Premium: Tinkerer, Salvager
- 1 Subscription: Overclocked

**Rationale:** Original unique designs that avoid Brotato/Vampire Survivors IP concerns.

### Decision 4: Perk Hooks Required

All new services MUST include perk hooks per `PERKS-ARCHITECTURE.md`:
- `shop_purchase_pre` / `shop_purchase_post`
- `inventory_add_pre` / `inventory_add_post`
- `character_create_pre` (for starting items)

**Rationale:** Enables future server-side gameplay modifiers without client updates.

---

## 📋 ITEM SYSTEM DESIGN

### Item Types

| Type | Auto-Active | Slots | Notes |
|------|-------------|-------|-------|
| **Weapon** | ✅ Yes | Uses weapon slots (1-10) | All equipped weapons fire simultaneously |
| **Armor** | ✅ Yes | Uses inventory slots | Defensive stats |
| **Trinket** | ✅ Yes | Uses inventory slots | Special bonuses (luck, crit, XP) |
| **Consumable** | ✅ Yes | Uses inventory slots | Temporary buffs while owned |

**Not This Week:**
- Minions (Week 19-20 Workshop)
- Blueprints (Week 19-20 Workshop)

### Item Definition Structure

```gdscript
const ITEM_DATABASE = {
    # === WEAPON EXAMPLE ===
    "weapon_rusty_blade": {
        "id": "weapon_rusty_blade",
        "name": "Rusty Blade",
        "description": "A weathered blade. Still cuts.",
        "type": "weapon",
        "rarity": "common",
        "base_price": 75,
        "stats": {
            "damage": 15,
            "melee_damage": 5
        },
        "stack_limit": 5,  # From rarity (Common=5)
        "weapon_type": "melee",  # melee or ranged (for UI icons/filtering)
        # NOTE: Combat data (cooldown, range, projectile, visuals) stays in WeaponService
    },
    
    # === ARMOR EXAMPLE ===
    "armor_scrap_vest": {
        "id": "armor_scrap_vest",
        "name": "Scrap Vest",
        "description": "Cobbled together from junk. Better than nothing.",
        "type": "armor",
        "rarity": "common",
        "base_price": 50,
        "stats": {
            "armor": 5,
            "max_hp": 10
        },
        "stack_limit": 5
    },
    
    # === TRINKET EXAMPLE ===
    "trinket_lucky_coin": {
        "id": "trinket_lucky_coin",
        "name": "Lucky Coin",
        "description": "Found it in the wasteland. Feels... lucky.",
        "type": "trinket",
        "rarity": "uncommon",
        "base_price": 150,
        "stats": {
            "luck": 10,
            "scavenging": 5  # Note: "scavenging" not "harvesting" - matches CharacterService stats
        },
        "stack_limit": 4
    }
}
```

### Rarity System

| Rarity | Color | Stack Limit | Base Price Range | Drop Weight |
|--------|-------|-------------|------------------|-------------|
| Common | Gray `#6B7280` | 5 | 50-150 | 60% |
| Uncommon | Green `#10B981` | 4 | 150-400 | 30% |
| Rare | Blue `#3B82F6` | 3 | 400-800 | 8% |
| Epic | Purple `#A855F7` | 2 | 800-1,500 | 1.5% |
| Legendary | Gold `#F59E0B` | 1 | 1,500-3,000 | 0.5% |

### Implementation Conventions (AUTHORITATIVE)

#### Item ID Naming Convention

**All item IDs MUST use type prefixes:**
- Weapons: `weapon_rusty_blade`, `weapon_plasma_pistol`
- Armor: `armor_scrap_vest`, `armor_reinforced_plate`
- Trinkets: `trinket_lucky_coin`, `trinket_speed_chip`
- Consumables: `consumable_repair_kit`, `consumable_stim_pack`

**Rationale:**
1. Namespace clarity in unified ITEM_DATABASE
2. Prevents ID collisions (e.g., both weapon and trinket named "lucky_coin")
3. Enables prefix-based filtering: `item_id.begins_with("weapon_")`
4. Industry standard pattern (Vampire Survivors, Hades, etc.)

#### Weapon Data Migration (Phase 1 vs Phase 4)

**What MIGRATES to ItemService (Phase 1):**
- `id` (with `weapon_` prefix added)
- `name` (from `display_name`)
- `description` (NEW - add flavor text)
- `type`: "weapon"
- `rarity` (NEW - assign based on tier_required mapping)
- `base_price` (NEW - from rarity range)
- `stats` (NEW - extract damage bonuses)
- `stack_limit` (from rarity)
- `weapon_type`: "melee" or "ranged"

**What STAYS in WeaponService (until Phase 4 refactor):**
- `cooldown` - Combat timing
- `range` - Combat targeting
- `projectile`, `projectile_speed` - Combat behavior
- `special_behavior` - Combat mechanics (spread, pierce, etc.)
- `projectiles_per_shot`, `pierce_count`, `splash_radius` - Combat mechanics
- `projectile_color`, `trail_*`, `screen_shake_intensity` - Visual/audio
- All audio references

**Phase 4 will have WeaponService query ItemService for base stats while keeping combat-specific data.**

#### Valid Stat Keys (Phase 1)

**Item stats MUST use keys from CharacterService.DEFAULT_BASE_STATS:**

```gdscript
# Core Survival Stats
"max_hp", "hp_regen", "life_steal", "armor"

# Offense Stats  
"damage", "melee_damage", "ranged_damage", "attack_speed", "crit_chance", "resonance"

# Defense Stats
"dodge"

# Utility Stats
"speed", "luck", "pickup_range", "scavenging"
```

**Rationale:** Enables simple stat aggregation formula:
```
final_stat = base_stat + Σ(all_item_stat_bonuses)
```

New stats (e.g., durability) can be added in future weeks when consumed by new systems.

#### Tier-to-Rarity Mapping (for weapon migration)

When migrating weapons from WeaponService, map `tier_required` to `rarity`:

| WeaponService tier_required | ItemService rarity |
|-----------------------------|-------------------|
| FREE | common or uncommon |
| PREMIUM | uncommon or rare |
| SUBSCRIPTION | rare or epic |

Use judgment based on weapon power level within tier.

---

## 📋 CHARACTER TYPE SYSTEM

### Character Type Definition Structure

```gdscript
# CHARACTER TYPES - See CHARACTER-SYSTEM.md for authoritative definitions
# This is a summary for Week 18 implementation reference

const CHARACTER_TYPE_DEFINITIONS = {
    # === FREE TIER (3 types) ===
    "scavenger": {
        "id": "scavenger",
        "display_name": "Scavenger",
        "description": "Knows where the good junk is.",
        "tier_required": "free",
        "weapon_slots": 6,
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "scrap_drop_bonus": 0.10,    # +10% scrap drops
            "pickup_range_bonus": 15     # +15 pickup range
        },
        "tags": ["Economy"]
    },
    "rustbucket": {
        "id": "rustbucket",
        "display_name": "Rustbucket",
        "description": "More patches than original parts.",
        "tier_required": "free",
        "weapon_slots": 4,  # FEWER weapons (trade-off)
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "max_hp_bonus": 30,          # +30 Max HP
            "armor_bonus": 5,            # +5 Armor
            "speed_multiplier": 0.85     # -15% Speed
        },
        "tags": ["Defense", "HP"]
    },
    "hotshot": {
        "id": "hotshot",
        "display_name": "Hotshot",
        "description": "Burns bright, burns fast.",
        "tier_required": "free",
        "weapon_slots": 6,
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "damage_multiplier": 1.20,   # +20% damage
            "crit_chance_bonus": 0.10,   # +10% crit chance
            "max_hp_bonus": -20          # -20 Max HP (penalty)
        },
        "tags": ["Damage", "Crit"]
    },
    
    # === PREMIUM TIER (2 types) ===
    "tinkerer": {
        "id": "tinkerer",
        "display_name": "Tinkerer",
        "description": "Can always fit one more gadget.",
        "tier_required": "premium",
        "weapon_slots": 6,
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "stack_limit_bonus": 1,      # +1 to all stack limits
            "damage_multiplier": 0.90    # -10% damage (trade-off)
        },
        "tags": ["Build Variety"]
    },
    "salvager": {
        "id": "salvager",
        "display_name": "Salvager",
        "description": "Sees value in everything.",
        "tier_required": "premium",
        "weapon_slots": 5,  # FEWER weapons (trade-off)
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "component_yield_bonus": 0.50,  # +50% components from recycling
            "shop_discount": 0.25           # 25% off shop purchases
        },
        "tags": ["Economy", "Resource"]
    },
    
    # === SUBSCRIPTION TIER (1 type) ===
    "overclocked": {
        "id": "overclocked",
        "display_name": "Overclocked",
        "description": "Pushed past factory specs.",
        "tier_required": "subscription",
        "weapon_slots": 6,
        "inventory_slots": 30,
        "starting_items": ["weapon_rusty_blade"],
        "stat_modifiers": {
            "attack_speed_bonus": 0.25,     # +25% attack speed
            "damage_multiplier": 1.15,      # +15% damage
            "wave_hp_damage_pct": 0.05      # Takes 5% Max HP damage per wave
        },
        "tags": ["Damage", "Attack Speed", "High Risk"]
    }
}
```

### Inventory System

**Slot Validation Rules:**
1. Total items ≤ `character.inventory_slots` (30 default)
2. Weapons ≤ `character.weapon_slots` (6 default, 4 for Rustbucket, 5 for Salvager)
3. Stack limit per rarity (Common: 5, Legendary: 1) - Tinkerer gets +1 to all

**Auto-Active Stats:**
```gdscript
# All owned items contribute to character stats
final_stat = base_stat + Σ(all_item_stat_bonuses) * character_stat_modifier
```

---

## 📋 SHOP SYSTEM DESIGN

### Standard Shop (MVP - All Tiers)

| Property | Value |
|----------|-------|
| Items per refresh | 6 |
| Item types | Weapons, Armor, Trinkets, Consumables |
| Refresh timing | Between waves (combat shop) |
| Reroll base cost | 50 scrap |
| Reroll escalation | 50 → 100 → 200 → 400 → 800 |

### Shop Generation Algorithm

```gdscript
func generate_shop(wave: int) -> Array[Dictionary]:
    var items = []
    
    for i in range(SHOP_SIZE):  # 6 items
        var rarity = _roll_rarity(wave)
        var item_type = _roll_item_type()
        var item = _get_random_item_of_type_and_rarity(item_type, rarity)
        items.append(item)
    
    # Wave guarantees
    if wave >= 5:
        _ensure_minimum_tier(items, 2)  # At least one T2+
    if wave >= 10:
        _ensure_minimum_tier(items, 3)  # At least one T3+
    
    return items

const DROP_WEIGHTS = {
    "common": 0.60,
    "uncommon": 0.30,
    "rare": 0.08,
    "epic": 0.015,
    "legendary": 0.005
}
```

---

## 📋 PERK HOOKS (Required)

Per `PERKS-ARCHITECTURE.md`, these hooks MUST be added:

### ItemService Hooks
- None (data-only service)

### InventoryService Hooks
```gdscript
signal inventory_add_pre(context: Dictionary)
# Context: character_id, item_id, allow_add, bonus_items

signal inventory_add_post(context: Dictionary)
# Context: character_id, item_id, new_inventory_count

signal inventory_remove_pre(context: Dictionary)
# Context: character_id, item_id, allow_remove

signal inventory_remove_post(context: Dictionary)
# Context: character_id, item_id, removed_item
```

### ShopService Hooks
```gdscript
signal shop_generate_pre(context: Dictionary)
# Context: wave, shop_items, allow_generate

signal shop_generate_post(context: Dictionary)
# Context: wave, final_shop_items

signal shop_purchase_pre(context: Dictionary)
# Context: character_id, item_id, base_cost, final_cost, allow_purchase

signal shop_purchase_post(context: Dictionary)
# Context: character_id, item_id, cost_paid, bonus_items

signal shop_reroll_pre(context: Dictionary)
# Context: character_id, reroll_count, base_cost, final_cost, allow_reroll

signal shop_reroll_post(context: Dictionary)
# Context: character_id, cost_paid, new_items
```

### CharacterService Hooks (Update Existing)
```gdscript
signal character_create_pre(context: Dictionary)
# Context: character_type, base_stats, starting_items, allow_create

signal character_create_post(context: Dictionary)
# Context: character_id, character_data
```

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Item Database + ItemService (1.5h)

**Tasks:**
1. Create `scripts/data/item_database.gd` with all item definitions
2. Migrate 10 weapons from `weapon_service.gd` (add rarity, price)
3. Add 10 armor items (common through rare)
4. Add 10 trinkets (uncommon through epic)
5. Add 5 consumables (common through uncommon)
6. Create `scripts/services/item_service.gd`
7. Unit tests for item loading

**Success Criteria:**
- [ ] 35+ item definitions in database
- [ ] ItemService can get item by ID
- [ ] ItemService can filter by type/rarity
- [ ] Unit tests passing

### Phase 2: Character Type System (1.5h)

**Tasks:**
1. Create `scripts/data/character_type_database.gd`
2. Add 6 character type definitions
3. Update `CharacterService` to use type definitions
4. Implement weapon slot limits per type
5. Implement inventory slot limits per type
6. Implement starting items on create
7. Add perk hooks to CharacterService
8. Unit tests

**Success Criteria:**
- [ ] 6 character types defined
- [ ] Characters created with correct slot limits
- [ ] Starting items granted on creation
- [ ] Tier validation working
- [ ] Unit tests passing

### Phase 3: InventoryService (1.5h)

**Tasks:**
1. Create `scripts/services/inventory_service.gd`
2. Implement add_item with slot validation
3. Implement remove_item
4. Implement get_inventory
5. Implement weapon slot limit enforcement
6. Implement stack limit enforcement
7. Implement auto-active stat calculation
8. Add perk hooks
9. Unit tests

**Success Criteria:**
- [ ] InventoryService created
- [ ] Slot limits enforced (total + weapons)
- [ ] Stack limits enforced by rarity
- [ ] Auto-active stats calculating
- [ ] Perk hooks implemented
- [ ] Unit tests passing

**Technical Notes:**
> ⚠️ **PERFORMANCE WARNING (2025-11-28)**: The `calculate_stats` function calls `ItemService.get_item()` for every item, creating a deep copy each time.
> - **Impact:** Frequent calls (e.g., every frame) will cause GC pressure.
> - **Recommendation:** Acceptable for Phase 4 (only called on inventory change). For Phase 5/Combat, implement caching or `get_item_read_only` to avoid allocation.

> ⚠️ **PERSISTENCE REQUIREMENT (2025-11-28)**: `InventoryService` MUST implement `serialize()` and `deserialize()` to support the SaveManager. This was identified as a critical gap during expert review.

### Phase 4: WeaponService Refactor (1h)

**Tasks:**
1. Remove `WEAPON_DEFINITIONS` from WeaponService
2. Add helper to get weapon data from ItemService
3. Keep combat logic (fire, cooldown, audio)
4. Update weapon equip to use InventoryService
5. Verify all existing tests still pass
6. Integration test: weapon combat with new system

**Success Criteria:**
- [ ] WeaponService uses ItemService for data
- [ ] Combat still works correctly
- [ ] Audio still plays
- [ ] All existing tests passing

### Phase 5: ShopService Refactor for Hub Model (1h)

> ⚠️ **COURSE CORRECTION (2025-11-28)**: Shop is a HUB SERVICE, not a combat feature.
> The shop is accessed from the Scrapyard hub, NOT between waves during combat.
> See SHOPS-SYSTEM.md: "Location: Hub → Shop"

**Context:**
- Phase 3 created ShopService with wave-based generation (INCORRECT)
- Shop should be a hub spoke like Barracks, Workshop, Lab
- Refresh is time-based (4h or daily), not wave-based

**Tasks:**
1. Remove wave parameter from `generate_shop()`
2. Add `last_refresh_timestamp` tracking
3. Implement `check_refresh_needed()` - 4-hour refresh cycle
4. Implement `check_empty_stock_refresh()` - FREE refresh when all items purchased
5. Add `get_time_until_refresh()` for UI countdown
6. Update tests for hub model
7. Keep existing: rarity weighting, tier discounts, perk hooks

**API Changes:**
```gdscript
# BEFORE (wave-based - WRONG)
func generate_shop(wave: int, tier: String) -> Array

# AFTER (hub-based - CORRECT)
func generate_shop(tier: String) -> Array
func check_refresh_needed() -> bool  # True if 4h passed
func check_empty_stock_refresh() -> bool  # True if stock = 0
func get_time_until_refresh() -> int  # Seconds until next refresh
func get_shop_items() -> Array  # Returns current stock (may auto-refresh)
```

**Success Criteria:**
- [ ] ShopService generates 6 items (no wave parameter)
- [ ] 4-hour refresh cycle working
- [ ] Empty stock triggers FREE auto-refresh
- [ ] `get_time_until_refresh()` returns correct countdown
- [ ] Existing tests updated and passing
- [ ] Perk hooks still working

### Phase 6: Hub Shop UI (2h)

> **Design Reference:** Shop is accessed from scrapyard hub (per SHOPS-SYSTEM.md: "Location: Hub → Shop")
> Store concept art: `art-docs/scrapyard-store.png` ("SCRAP HEAP" truck with OPEN sign)

**Tasks:**
1. Create/commission `assets/icons/hub/icon_shop_final.svg`
   - Recommended: Shopping bag, crate, or cart icon (universal commerce symbol)
2. Add ShopButton to `scenes/hub/scrapyard.tscn`
   - Position: 35% from left (between Barracks and Bank)
   - Size: Same as Barracks (button_size = 1)
   - Label: "Shop"
3. Create `scenes/ui/shop.tscn` (hub shop scene)
   - Background: Use `art-docs/scrapyard-store.png` or derive from it
   - Layout: 6 item cards in grid (2x3 or 3x2)
   - Header: "SCRAP HEAP" with scrap balance
   - Footer: Reroll button + Back to Hub button
4. Create `scenes/ui/components/shop_item_card.tscn`
   - Item name, rarity color border, stats, price
   - Purchase button (disabled if insufficient scrap)
   - "SOLD" overlay for purchased items
5. Wire scrapyard → shop navigation
6. Wire shop → scrapyard back navigation
7. Implement refresh countdown display ("Next refresh: 2h 34m")
8. Show "Shop refreshed!" toast on auto-refresh

**Week 18 Hub Layout (4 buttons - single row):**
```
┌─────────────────────────────────────────────────────────────┐
│ [SCRAP SURVIVOR]                        [Settings ⚙️]       │
│                                                             │
│   [Barracks]    [Shop]    [Bank]        [Start Run]        │
│     (15%)       (35%)     (55%)           (85%)            │
│                                                             │
│ [Survivor Panel]                                            │
└─────────────────────────────────────────────────────────────┘
```

**Future Hub Layout (Week 19+, second row for premium services):**
```
┌─────────────────────────────────────────────────────────────┐
│   [Barracks]    [Shop]    [Bank]        [Start Run]        │
│     (15%)       (35%)     (55%)           (85%)            │
│                                                             │
│        [Foundry]   [Lab]   [Black Mkt]   [Atomic]          │
│          (20%)     (40%)     (60%)        (80%)            │
└─────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [ ] Shop button visible in scrapyard (35% position)
- [ ] Shop scene displays 6 items with rarity colors
- [ ] Refresh countdown visible
- [ ] Purchase deducts scrap, marks item as SOLD
- [ ] Reroll works with escalating cost display
- [ ] Back button returns to scrapyard
- [ ] Empty stock triggers refresh with toast notification

### Phase 6.5: Hub Bank UI (1h)

> **Design Reference:** Bank is the "SCRAP TRUST & EXCHANGE" truck in hub art center.
> Per BANKING-SYSTEM.md: Deposit/withdraw scrap, protect from death penalties.

**Tasks:**
1. Create/commission `assets/icons/hub/icon_bank_final.svg`
   - Recommended: Vault door, safe, or coins icon
2. Add BankButton to `scenes/hub/scrapyard.tscn`
   - Position: 55% from left (between Shop and Start Run)
   - Size: Same as Barracks (button_size = 1)
   - Label: "Bank"
3. Create `scenes/ui/bank.tscn` (hub bank scene)
   - Header: "SCRAP TRUST & EXCHANGE" with carried/banked balance
   - Deposit section: Amount input + Deposit button
   - Withdraw section: Amount input + Withdraw button
   - Quick buttons: "Deposit All", "Withdraw 100", "Withdraw 500"
   - Footer: Back to Hub button
4. Wire scrapyard → bank navigation
5. Wire bank → scrapyard back navigation
6. Integrate with BankingService (already exists)
7. Show balance updates in real-time

**Bank Features (from BANKING-SYSTEM.md):**
- Deposit carried scrap → banked (safe from death)
- Withdraw banked scrap → carried (for shop/combat)
- Quantum Storage tab (Subscription only) - transfer between characters

**Success Criteria:**
- [ ] Bank button visible in scrapyard (55% position)
- [ ] Bank scene displays carried + banked balance
- [ ] Deposit works (deducts carried, adds banked)
- [ ] Withdraw works (deducts banked, adds carried)
- [ ] Quick buttons work correctly
- [ ] Back button returns to scrapyard
- [ ] Balance updates in real-time

### Phase 7: Integration & QA (1h)

**Tasks:**
1. End-to-end test: Hub → Shop → Purchase → Back to Hub → Combat
2. Test shop refresh cycle (4-hour or manual reroll)
3. Test empty stock auto-refresh (buy all 6 → free refresh)
4. Test all character types (Salvager 25% discount)
5. Test slot limits with InventoryService
6. Device QA on iOS
7. Fix any issues found

**Success Criteria:**
- [ ] Full hub loop works on device
- [ ] Shop accessible from scrapyard
- [ ] Purchases add items to inventory
- [ ] Refresh mechanics working correctly
- [ ] All character types can shop
- [ ] No crashes or errors
- [ ] Performance acceptable

### Phase 8: Try-Before-Buy Flow (2h) - STRETCH GOAL

**Description:** Allow FREE players to trial Premium/Subscription characters for 1 run before purchasing.

**Tasks:**
1. Add `is_trial` flag to character data structure
2. Create trial character creation flow (bypasses tier check, marks as trial)
3. Create "Try" button UI on locked character type cards
4. Track trial state during combat run
5. Create post-run conversion screen (show stats, upgrade CTA)
6. Analytics events: trial_started, trial_completed, conversion_success
7. Clean up trial character if not converted (or keep with lock)
8. Unit tests for trial flow

**Success Criteria:**
- [ ] FREE player can tap "Try" on Tinkerer
- [ ] Trial run works identically to normal run
- [ ] Post-run screen shows conversion option
- [ ] Trial character blocked from future use without upgrade
- [ ] Analytics events firing

**Note:** This is a conversion optimization feature. Core Week 18 functionality works without it. Can be deferred to Week 19 if time constrained.

---

## 📂 FILE STRUCTURE

```
scripts/
├── data/
│   ├── item_database.gd            # NEW - All item definitions
│   └── character_type_database.gd  # NEW - Character type definitions
├── services/
│   ├── item_service.gd             # NEW - Item data access
│   ├── inventory_service.gd        # NEW - Player inventory
│   ├── shop_service.gd             # NEW - Shop generation/purchase
│   ├── weapon_service.gd           # MODIFIED - Remove definitions, keep combat
│   └── character_service.gd        # MODIFIED - Add type system
├── tests/
│   ├── item_service_test.gd        # NEW
│   ├── inventory_service_test.gd   # NEW
│   ├── shop_service_test.gd        # NEW
│   └── character_type_test.gd      # NEW

scenes/
├── ui/
│   ├── shop_screen.tscn            # NEW
│   └── components/
│       └── shop_item_card.tscn     # NEW
```

---

## 🧪 QA CHECKLIST

### Automated Tests

- [ ] ItemService: Load all items, validate fields
- [ ] ItemService: Get items by type/rarity
- [ ] InventoryService: Add item within limits
- [ ] InventoryService: Block when slot limit exceeded
- [ ] InventoryService: Block when weapon limit exceeded
- [ ] InventoryService: Enforce stack limits
- [ ] InventoryService: Calculate auto-active stats
- [ ] ShopService: Generate 6 items
- [ ] ShopService: Rarity weighting
- [ ] ShopService: Wave guarantees
- [ ] ShopService: Purchase flow
- [ ] ShopService: Reroll escalation
- [ ] CharacterService: Create with type
- [ ] CharacterService: Grant starting items
- [ ] CharacterService: Tier validation

### Manual Testing (Device)

**Character Creation:**
- [ ] Can create Scavenger (Free)
- [ ] Can create Rustbucket (Free)
- [ ] Can create Hotshot (Free)
- [ ] Premium types blocked for Free tier (shows CTA)
- [ ] Starting weapon appears in inventory

**Shop Flow:**
- [ ] Shop appears between waves
- [ ] 6 items displayed correctly
- [ ] Rarity colors correct
- [ ] Prices shown for each item
- [ ] Can purchase item (currency deducted)
- [ ] Item appears in inventory
- [ ] Reroll button works
- [ ] Reroll cost escalates
- [ ] "Continue" returns to combat

**Inventory Limits:**
- [ ] Can't exceed inventory slot limit
- [ ] Can't exceed weapon slot limit
- [ ] Stack limits enforced
- [ ] Rustbucket can only have 4 weapons
- [ ] Salvager can only have 5 weapons

---

## 📊 SUCCESS METRICS

| Metric | Target |
|--------|--------|
| Item definitions | 35+ |
| Character types | 6 |
| Shop items displayed | 6 |
| Perk hooks implemented | 10+ |
| Unit test coverage | 100% for new services |
| Device QA | All manual tests passing |

---

## 📝 DEPENDENCIES FOR FUTURE WEEKS

**Week 19-20 (Workshop/Foundry) will need:**
- ~~Item durability field~~ ✅ DONE (2025-11-28) - Instance-based storage with durability HP
- Durability perk hooks (`durability_damage_pre/post`, `durability_repair_pre/post`) - Deferred to Foundry
- Death penalty (tier-based durability damage on death) - Uses `apply_durability_damage()`
- Mr Fix-It repair service (subscription) - Uses `repair_item()`
- Blueprint item type
- Minion item type

**Week 21 (Meta Progression) will need:**
- Item tags for shop affinity
- Character tags
- XP/leveling hooks

---

## 🔮 DEFERRED INTEGRATIONS (Documented for Future Work)

These stat modifiers are defined in Phase 2 but consumed elsewhere:

### stack_limit_bonus (Tinkerer: +1)
- **Defined in:** CharacterTypeDatabase (Phase 2)
- **Stored on:** Character stats when created
- **Consumed by:** InventoryService.get_stack_limit() (Phase 3)
- **Implementation:**
```gdscript
func get_stack_limit(character_id: String, rarity: String) -> int:
    var base_limit = RARITY_STACK_LIMITS[rarity]  # Common=5, Legendary=1
    var character = CharacterService.get_character(character_id)
    var bonus = character.stats.get("stack_limit_bonus", 0)
    return base_limit + bonus
```

### wave_hp_damage_pct (Overclocked: 0.05 = 5%)
- **Defined in:** CharacterTypeDatabase (Phase 2)
- **Stored on:** Character stats when created
- **Consumed by:** Combat scene on `wave_completed` signal
- **Implementation Location:** `scenes/combat/wasteland.gd` or combat controller
- **Implementation:**
```gdscript
func _on_wave_completed(wave: int, stats: Dictionary):
    var character = CharacterService.get_active_character()
    var wave_damage_pct = character.stats.get("wave_hp_damage_pct", 0.0)
    if wave_damage_pct > 0:
        var damage = int(character.stats.max_hp * wave_damage_pct)
        player.take_damage(damage)
        GameLogger.info("Overclocked wave damage", {"wave": wave, "damage": damage})
```
- **Week:** Can be wired in Phase 7 Integration or Week 19

### shop_discount (Salvager: 0.25 = 25%)
- **Defined in:** CharacterTypeDatabase (Phase 2)
- **Stored on:** Character stats when created
- **Consumed by:** ShopService.calculate_price() (Phase 5)
- **Implementation:**
```gdscript
func calculate_price(character_id: String, base_price: int) -> int:
    var character = CharacterService.get_character(character_id)
    var discount = character.stats.get("shop_discount", 0.0)
    return int(base_price * (1.0 - discount))
```

### component_yield_bonus (Salvager: 0.50 = 50%)
- **Defined in:** CharacterTypeDatabase (Phase 2)
- **Stored on:** Character stats when created
- **Consumed by:** RecyclerService or InventoryService when recycling items
- **Week:** Week 19-20 Workshop system

---

## Implementation Status (LIVING SECTION)

**Last Updated**: 2025-11-28 by Claude Code
**Current Session**: See `.system/NEXT_SESSION.md` for detailed notes

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: Item Database | 1.5h | ~1.5h | ✅ DONE | 2025-11-27 | ItemService + ItemDatabase created |
| Phase 2: Character Types | 1.5h | ~1.5h | ✅ DONE | 2025-11-27 | 6 character types, portraits, CharacterTypeDatabase |
| Phase 3: ShopService | 1.5h | ~1.5h | ✅ DONE | 2025-11-27 | Hub model, perk hooks, rerolls |
| Phase 4: InventoryService | 1.5h | ~2h | ✅ DONE | 2025-11-28 | Instance-based with durability placeholder. Gemini implementation, Claude review+fixes |
| Phase 5: ShopService Hub Refactor | 1h | - | ⏭️ PENDING | - | Needs wave param removal, time-based refresh |
| Phase 6: Hub Shop UI | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 6.5: Hub Bank UI | 1h | - | ⏭️ PENDING | - | - |
| Phase 7: Integration & QA | 1h | - | ⏭️ PENDING | - | - |
| Phase 8: Try-Before-Buy | 2h | - | ⏭️ STRETCH | - | Conversion optimization, can defer |

**Total Estimated**: 10-12 hours (8-10h core + 2h stretch)
**Actual So Far**: ~6.5h for Phases 1-4

---

**Document Version:** 2.3 (Phase 4 complete with durability)
**Created:** 2025-11-27
**Last Major Update:** 2025-11-28 - Phase 4 InventoryService complete with instance-based durability placeholder
**Next Review:** After Phase 5 completion
