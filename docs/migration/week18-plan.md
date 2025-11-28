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
        "stack_limit": 5,  # From rarity
        
        # Weapon-specific
        "weapon_type": "melee",  # melee, ranged
        "cooldown": 0.5,
        "range": 50,
        "special_behavior": "none",
        "projectile": null,
        
        # Visual (from existing WeaponService)
        "projectile_color": Color(0.8, 0.4, 0.2),
        "trail_width": 0.0,
        "screen_shake_intensity": 3.0
    },
    
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
    
    "trinket_lucky_coin": {
        "id": "trinket_lucky_coin",
        "name": "Lucky Coin",
        "description": "Found it in the wasteland. Feels... lucky.",
        "type": "trinket",
        "rarity": "uncommon",
        "base_price": 150,
        "stats": {
            "luck": 10,
            "harvesting": 5
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

### Phase 5: ShopService (1.5h)

**Tasks:**
1. Create `scripts/services/shop_service.gd`
2. Implement shop generation (6 items, weighted rarity)
3. Implement wave guarantees
4. Implement purchase flow (currency + inventory)
5. Implement reroll with escalating costs
6. Add perk hooks
7. Unit tests

**Success Criteria:**
- [ ] ShopService generates 6 items
- [ ] Rarity weighting working
- [ ] Wave guarantees working
- [ ] Purchase integrates with Banking + Inventory
- [ ] Reroll cost escalation working
- [ ] Perk hooks implemented
- [ ] Unit tests passing

### Phase 6: Shop UI (1.5h)

**Tasks:**
1. Create `scenes/ui/shop_screen.tscn`
2. Create shop item card component
3. Display 6 items with rarity colors
4. Show scrap balance
5. Implement purchase button
6. Implement reroll button with cost display
7. Add "Continue to Next Wave" button
8. Wire up to wave completion

**Success Criteria:**
- [ ] Shop screen displays correctly
- [ ] Items show rarity colors
- [ ] Purchase works
- [ ] Reroll works
- [ ] Scrap updates in real-time
- [ ] Can continue to next wave

### Phase 7: Integration & QA (1h)

**Tasks:**
1. End-to-end test: Create character → Combat → Shop → Purchase → Continue
2. Test all character types
3. Test slot limits (try to exceed)
4. Test stack limits
5. Device QA on iOS
6. Fix any issues found

**Success Criteria:**
- [ ] Full loop works on device
- [ ] All character types playable
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

**Week 19-20 (Workshop) will need:**
- Item durability field (add placeholder now?)
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

**Last Updated**: 2025-11-27 by Claude Code
**Current Session**: See `.system/NEXT_SESSION.md` for detailed notes

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: Item Database | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 2: Character Types | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 3: InventoryService | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 4: WeaponService Refactor | 1h | - | ⏭️ PENDING | - | - |
| Phase 5: ShopService | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 6: Shop UI | 1.5h | - | ⏭️ PENDING | - | - |
| Phase 7: Integration & QA | 1h | - | ⏭️ PENDING | - | - |
| Phase 8: Try-Before-Buy | 2h | - | ⏭️ STRETCH | - | Conversion optimization, can defer |

**Total Estimated**: 10-12 hours (8-10h core + 2h stretch)

---

**Document Version:** 2.1 (Added Phase 8 Try-Before-Buy, Deferred Integrations section)
**Created:** 2025-11-27
**Last Major Update:** 2025-11-27 - Added Phase 8, documented deferred stat modifier integrations
**Next Review:** After Phase 1 completion
