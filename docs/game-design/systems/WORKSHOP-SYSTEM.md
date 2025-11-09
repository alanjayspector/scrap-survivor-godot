# Workshop System

**Status:** Core System - All Tiers
**Date:** 2025-01-09
**Purpose:** Item management, blueprint crafting, personalization, and storage

---

## Overview

The Workshop is the central hub for **item management, crafting, repair, and personalization**. It provides services for all player tiers, with enhanced features for Premium and Subscription tiers.

**Core Services:**
- 🔧 **Repair Station** - Restore item durability (all tiers)
- ♻️ **Recycling Station** - Convert items → Workshop Components (all tiers)
- 📦 **Storage Locker** - Per-character item/blueprint storage (all tiers, fee-based)
- 📚 **Blueprint Library** - Permanent blueprint unlocks (all tiers)
- ⭐ **Personalization Station** - Custom weapon naming and bonuses (all tiers)
- 🌐 **Quantum Storage Locker** - Cross-character item transfer (Subscription only)

**Brotato comparison:**
- 🟢 **UNIQUE TO SCRAP SURVIVOR** (Brotato has no workshop or item persistence)
- 🟢 **Personalization is unique** (Brotato has no custom naming)
- 🔴 **Durability system is friction** (Brotato has no item durability)

---

## Workshop Components (Currency)

### What Are Workshop Components?

**Workshop Components** are the primary currency for Workshop operations:
- ✅ Earned by **recycling items** (tier-based rewards)
- ✅ Used for **repairs** (durability restoration)
- ✅ Used for **generic crafting** (25 scrap + 50 components)
- ✅ Used for **personalized crafting** (200 scrap + 100 components)
- ✅ Stored in Workshop (not Banking)
- ✅ Protected by Storage Locker (character-specific)
- ✅ Transferable via Quantum Storage (Subscription only)

**Recycling Rewards:**
```
Tier 1 item: 5-10 Workshop Components
Tier 2 item: 15-25 Workshop Components
Tier 3 item: 30-50 Workshop Components
Tier 4 item: 75-125 Workshop Components
```

**Storage Limits (by Player Tier):**
```
Free tier: 75 Workshop Components max
Premium tier: 250 Workshop Components max
Subscription tier: Unlimited Workshop Components
```

**Why Workshop Components exist:**
- Provides **free repair currency** (reduces friction from durability system)
- Creates **strategic recycling decisions** (keep vs recycle?)
- Drives **Workshop engagement** (not just a repair shop)
- **No real money** required (earned through gameplay)
- **Storage limits drive CTAs** (Free/Premium fill up fast, Subscription unlimited)

---

## ATM Withdrawal (Banking Integration)

### Withdraw Banked Scrap

**Players can withdraw scrap from their Bank to their carried scrap:**
- ✅ **Instant withdrawal** (no fees, no delays)
- ✅ **Available in Workshop and Lab** (convenient access)
- ✅ **Shows banked vs carried scrap** (clear financial status)
- ✅ **Button in resource display** (one-click withdrawal)

**Why ATM buttons:**
- ✅ **Reduces friction** (don't need to visit Bank scene to withdraw)
- ✅ **Convenient for crafting** (withdraw exactly what you need)
- ✅ **Clear financial status** (see banked + carried in one view)

```gdscript
# ATM withdrawal (WorkshopScene.gd)
func withdraw_from_bank(amount: int) -> void:
    if BankingService.has_banked_scrap(amount):
        BankingService.withdraw_scrap(amount)
        BankingService.add_carried_scrap(amount)
        update_resource_display()
        GameLogger.info("Withdrew %d scrap from Bank" % amount)
    else:
        ToastService.show("Insufficient banked scrap")
```

**UI Implementation:**
```
Resource Display (Top-right):
┌────────────────────────────────────┐
│ Carried Scrap: 150                  │
│ Banked Scrap: 5,000 [Withdraw All]│
│   [Withdraw 100] [Withdraw 500]     │
│ Workshop Components: 45 / 75        │
└────────────────────────────────────┘
```

---

## Scrap Tech Skill

**Scrap Tech** is the Workshop proficiency skill that affects:

### Repair Cost Reduction
```gdscript
# Base repair cost formula
func calculate_repair_cost(item_tier: int, durability_lost: int) -> int:
    var base_cost = item_tier * durability_lost * 2
    var scrap_tech_bonus = PlayerStats.get_skill("scrap_tech")
    var reduction = scrap_tech_bonus / 100.0  # 1% reduction per point
    return int(base_cost * (1.0 - reduction))

# Examples:
# Scrap Tech 0: T4 item, 10% durability lost = 80 components
# Scrap Tech 50: T4 item, 10% durability lost = 40 components
# Scrap Tech 100: T4 item, 10% durability lost = FREE repair
```

### Recycling Yield Increase
```gdscript
# Recycling rewards increase with Scrap Tech
func calculate_recycle_reward(item_tier: int) -> int:
    var base_reward = [7, 20, 40, 100][item_tier - 1]  # Mid-range of tier rewards
    var scrap_tech_bonus = PlayerStats.get_skill("scrap_tech")
    var yield_multiplier = 1.0 + (scrap_tech_bonus / 50.0)  # 2% yield per point
    return int(base_reward * yield_multiplier)

# Examples:
# Scrap Tech 0: T4 item = 100 components
# Scrap Tech 50: T4 item = 200 components
# Scrap Tech 100: T4 item = 300 components
```

### Personalization Stat Bonus
```gdscript
# Personalization bonus formula
func calculate_personalization_bonus(character_luck: int, scrap_tech: int) -> float:
    var base_bonus = 0.10  # 10% base
    var luck_bonus = character_luck / 100.0
    var tech_bonus = scrap_tech / 50.0
    return base_bonus + luck_bonus + tech_bonus

# Examples:
# Luck 0, Scrap Tech 0: 10% bonus
# Luck 50, Scrap Tech 50: 10% + 50% + 100% = 160% bonus
# Luck 100, Scrap Tech 100: 10% + 100% + 200% = 310% bonus
```

### Visual Customization Unlocks

**Scrap Tech milestones unlock visual customization options:**

| Scrap Tech Level | Unlock |
|-----------------|--------|
| 25 | Color tint customization (6 colors) |
| 50 | Particle effect customization (3 effects) |
| 75 | Sound effect customization (3 sounds) |
| 100 | Legendary glow effect (rainbow shimmer) |

---

## Repair Station

### How Repairs Work

**Durability Loss on Death:**
- Free tier: **-10% durability** per death
- Premium tier: **-5% durability** per death
- Subscription tier: **-2% durability** per death

**Repair Options:**

#### Option 1: Workshop Components (Free Currency)
```gdscript
# Pay with Workshop Components
func repair_item_with_components(item: Item) -> void:
    var durability_lost = 100 - item.durability
    var components_cost = calculate_repair_cost(item.tier, durability_lost)

    if WorkshopService.has_components(components_cost):
        WorkshopService.spend_components(components_cost)
        item.durability = 100
        GameLogger.info("Item repaired with %d components" % components_cost)
```

#### Option 2: Direct Scrap Payment
```gdscript
# Direct scrap payment (convenience option)
# Pay scrap directly instead of using components
# More expensive but useful when low on components

func repair_item_with_scrap(item: Item) -> void:
    var durability_lost = 100 - item.durability
    var scrap_cost = calculate_repair_cost(item.tier, durability_lost) * 3  # 3x component cost

    if BankingService.has_carried_scrap(scrap_cost):
        BankingService.spend_carried_scrap(scrap_cost)
        item.durability = 100
        GameLogger.info("Item repaired with scrap: %d scrap" % scrap_cost)
```

**Why two options:**
- ✅ Workshop Components: Cheaper, earned via recycling (strategic)
- ✅ Direct scrap: Convenience (no need to recycle, but 3x cost)

---

## Recycling Station

### How Recycling Works

**Players can recycle any item to earn Workshop Components:**

```gdscript
# RecyclingStation.gd
func recycle_item(item: Item) -> int:
    var tier = item.tier
    var base_reward = calculate_base_reward(tier)
    var scrap_tech = PlayerStats.get_skill("scrap_tech")

    # Scrap Tech increases yield
    var yield_multiplier = 1.0 + (scrap_tech / 50.0)
    var total_reward = int(base_reward * yield_multiplier)

    # Award components
    WorkshopService.add_components(total_reward)

    # Remove item from inventory
    InventoryService.remove_item(item)

    # Confirmation
    GameLogger.info("Recycled %s for %d components" % [item.name, total_reward])
    return total_reward

func calculate_base_reward(tier: int) -> int:
    # Mid-range rewards per tier
    match tier:
        1: return randi() % 6 + 5   # 5-10
        2: return randi() % 11 + 15  # 15-25
        3: return randi() % 21 + 30  # 30-50
        4: return randi() % 51 + 75  # 75-125
        _: return 0
```

**Strategic Decisions:**
- ✅ Keep item for stats/synergy?
- ✅ Recycle for repair currency?
- ✅ Store for later use (costs storage fees)?

---

## Storage Locker (All Tiers)

### Per-Character Item Storage

**Storage Locker protects items and blueprints from death:**
- ✅ Items in storage: **0% durability loss** on death
- ✅ Blueprints in storage: **Protected** from destruction on death
- ✅ Workshop Components in storage: **Protected** from loss on death
- ✅ **Character-specific** (not shared across characters)

**Storage Fees (Per-Character, Daily):**

| Player Tier | Item Storage Fee | Blueprint Storage Fee |
|------------|------------------|----------------------|
| Free | 15 scrap/item/day | 20 scrap/blueprint/day |
| Premium | 10 scrap/item/day | 10 scrap/blueprint/day |
| Subscription | FREE | FREE |

**Fee Deduction:**
```gdscript
# Runs daily at 00:00 UTC
func deduct_storage_fees() -> void:
    var character_id = CurrentCharacter.id
    var stored_items = StorageService.get_stored_items(character_id)
    var stored_blueprints = StorageService.get_stored_blueprints(character_id)

    var player_tier = PlayerService.get_tier()
    var item_fee = get_item_storage_fee(player_tier)
    var blueprint_fee = get_blueprint_storage_fee(player_tier)

    var total_fee = (stored_items.size() * item_fee) + (stored_blueprints.size() * blueprint_fee)

    if player_tier == "subscription":
        total_fee = 0  # FREE for Subscription tier

    if BankingService.has_scrap(total_fee):
        BankingService.spend_scrap(total_fee)
        GameLogger.info("Storage fees deducted: %d scrap" % total_fee)
    else:
        # Warning: insufficient funds
        ToastService.show("Warning: Insufficient scrap for storage fees!")
```

**Why storage fees:**
- ✅ **CTA for Premium/Subscription** (FREE storage is valuable)
- ✅ **Strategic decisions** (store everything vs selective storage)
- ✅ **Resource sink** (scrap has ongoing value)

---

## Blueprint Library (All Tiers)

### Blueprint System Overview

**Blueprints are consumable items** that unlock permanent crafting recipes:

1. **Blueprint item drops** from enemies/crates (consumable)
2. **Player unlocks blueprint** in Library (costs scrap, permanent)
3. **Crafting available**: 3 generic crafts + unlimited personalized crafts

**Blueprint Library Unlock Costs:**

| Blueprint Tier | Unlock Cost |
|---------------|-------------|
| Tier 1 | FREE |
| Tier 2 | 25 scrap |
| Tier 3 | 50 scrap |
| Tier 4 | 100 scrap |

**Why unlock costs:**
- ✅ **Strategic decisions** (which blueprints to unlock first?)
- ✅ **Scrap value** (scrap has multiple uses, not just shop)
- ✅ **Tier 1 FREE** (reduces friction for new players)

---

### Generic Crafts (Limited)

**Each blueprint unlock grants 3 generic crafts:**
- ✅ **Character-specific** (Bruiser unlocks, Bruiser gets 3 crafts)
- ✅ **No customization** (standard weapon stats)
- ✅ **Limited uses** (3 crafts total, then requires personalization)
- ✅ **Cost**: 25 scrap + 50 Workshop Components per craft

```gdscript
# Generic crafting
func craft_generic_weapon(blueprint_id: String) -> Item:
    var blueprint = BlueprintLibrary.get_blueprint(blueprint_id)
    var character_id = CurrentCharacter.id

    # Check if generic crafts available
    var crafts_used = BlueprintLibrary.get_generic_crafts_used(character_id, blueprint_id)
    if crafts_used >= 3:
        ToastService.show("No generic crafts remaining. Use Personalization Station.")
        return null

    # Check costs
    if not BankingService.has_scrap(25):
        ToastService.show("Insufficient scrap (25 required)")
        return null

    if not WorkshopService.has_components(50):
        ToastService.show("Insufficient Workshop Components (50 required)")
        return null

    # Deduct costs
    BankingService.spend_scrap(25)
    WorkshopService.spend_components(50)

    # Create item from blueprint stats
    var item = ItemFactory.create_from_blueprint(blueprint)

    # Increment crafts used
    BlueprintLibrary.increment_generic_crafts(character_id, blueprint_id)

    # Add to inventory
    InventoryService.add_item(item)

    GameLogger.info("Generic weapon crafted: %s (%d/3 crafts used)" % [item.name, crafts_used + 1])
    return item
```

---

## Personalization Station (All Tiers)

### Custom Weapon Personalization

**Unlimited personalized crafts** available after blueprint unlock:
- ✅ **Custom naming** ("Alan's Awesome Railgun")
- ✅ **Stat bonus** (based on Luck + Scrap Tech)
- ✅ **Visual customization** (unlocked via Scrap Tech milestones)
- ✅ **Soul-bound** (can't be traded/transferred)
- ✅ **Cost**: 200 scrap + 100 Workshop Components per craft

```gdscript
# PersonalizationStation.gd
func personalize_weapon(blueprint_id: String, custom_name: String, color_tint: Color, particle_effect: String) -> Item:
    var blueprint = BlueprintLibrary.get_blueprint(blueprint_id)
    var character_id = CurrentCharacter.id

    # Check costs
    if not BankingService.has_scrap(200):
        ToastService.show("Insufficient scrap (200 required)")
        return null

    if not WorkshopService.has_components(100):
        ToastService.show("Insufficient Workshop Components (100 required)")
        return null

    # Deduct costs
    BankingService.spend_scrap(200)
    WorkshopService.spend_components(100)

    # Create personalized item
    var item = ItemFactory.create_from_blueprint(blueprint)
    item.name = custom_name
    item.is_personalized = true
    item.owner_character_id = character_id
    item.soul_bound = true  # Can't transfer or trade

    # Calculate stat bonus
    var luck = CurrentCharacter.get_stat("luck")
    var scrap_tech = PlayerStats.get_skill("scrap_tech")
    var bonus_multiplier = calculate_personalization_bonus(luck, scrap_tech)

    # Apply bonus to all item stats
    apply_stat_bonus(item, bonus_multiplier)

    # Apply visual customization
    item.color_tint = color_tint
    item.particle_effect = particle_effect

    # Add to inventory
    InventoryService.add_item(item)

    GameLogger.info("Personalized weapon created: %s (%.1f%% bonus)" % [custom_name, bonus_multiplier * 100])
    return item

func apply_stat_bonus(item: Item, bonus_multiplier: float) -> void:
    # Apply bonus to all numeric stats
    for stat in item.stats:
        if typeof(item.stats[stat]) == TYPE_INT or typeof(item.stats[stat]) == TYPE_REAL:
            item.stats[stat] = int(item.stats[stat] * (1.0 + bonus_multiplier))
```

---

### Personalization Examples

**Example 1: Low Luck, Low Scrap Tech**
```
Character: Bruiser (Luck: 10, Scrap Tech: 0)
Blueprint: Tier 4 Railgun (Base: 50 Ranged Damage)

Stat Bonus: 10% (base) + 0.10 (luck/100) + 0 (scrap_tech/50) = 20%
Final Damage: 50 * 1.20 = 60 Ranged Damage

Custom Name: "Bruiser's Big Gun"
Cost: 200 scrap + 100 Workshop Components
```

**Example 2: High Luck, High Scrap Tech**
```
Character: Lucky (Luck: 100, Scrap Tech: 100)
Blueprint: Tier 4 Railgun (Base: 50 Ranged Damage)

Stat Bonus: 10% (base) + 1.00 (luck/100) + 2.00 (scrap_tech/50) = 310%
Final Damage: 50 * 4.10 = 205 Ranged Damage

Custom Name: "Lucky's Legendary Laser"
Visual: Rainbow glow effect (Scrap Tech 100 unlock)
Cost: 200 scrap + 100 Workshop Components
```

**Why personalization is powerful:**
- ✅ **Extreme scaling** with Luck + Scrap Tech investment
- ✅ **Player investment** (custom names = emotional attachment)
- ✅ **Endgame goal** (max Scrap Tech for 310% bonuses)
- ✅ **Soul-bound** prevents exploits (can't farm on alt character)

---

## Quantum Storage Locker (Subscription Only)

### Cross-Character Item Transfer

**Subscription tier unlocks cross-character item transfer:**
- ✅ **Transfer items** between characters (different builds)
- ✅ **Transfer blueprints** (share unlocks)
- ✅ **Transfer Workshop Components** (share resources)
- ✅ **One transfer per day per item** (prevents ping-ponging)
- ✅ **FREE transfers** (no additional fees beyond Subscription)

**Transfer Limits:**
```gdscript
# QuantumStorageLocker.gd
const TRANSFER_COOLDOWN_HOURS = 24

func transfer_item(item: Item, from_character_id: String, to_character_id: String) -> bool:
    # Check subscription tier
    if PlayerService.get_tier() != "subscription":
        ToastService.show("Quantum Storage requires Subscription tier")
        return false

    # Check transfer cooldown
    var last_transfer = item.get_meta("last_transfer_time", 0)
    var current_time = Time.get_unix_time_from_system()
    var hours_since_transfer = (current_time - last_transfer) / 3600.0

    if hours_since_transfer < TRANSFER_COOLDOWN_HOURS:
        var hours_remaining = TRANSFER_COOLDOWN_HOURS - hours_since_transfer
        ToastService.show("Transfer cooldown: %.1f hours remaining" % hours_remaining)
        return false

    # Perform transfer
    InventoryService.remove_item_from_character(from_character_id, item)
    InventoryService.add_item_to_character(to_character_id, item)
    item.set_meta("last_transfer_time", current_time)

    GameLogger.info("Item transferred from %s to %s: %s" % [from_character_id, to_character_id, item.name])
    return true
```

**Why daily transfer limit:**
- ✅ **Prevents ping-ponging** (can't swap items mid-run)
- ✅ **Strategic planning** (commit to transfers 24 hours in advance)
- ✅ **Balance** (can't farm items on one character for all characters daily)

**Use cases:**
- ✅ Character A unlocked rare blueprint → transfer to Character B for crafting
- ✅ Character A has excess Workshop Components → transfer to Character B for repairs
- ✅ Character A has endgame weapon → transfer to Character B for new build

---

## Workshop Scene Layout

### Scene Structure

```
WorkshopScene
├── Header
│   └── "Workshop - [Character Name]"
├── Navigation Tabs
│   ├── Repair Station
│   ├── Recycling Station
│   ├── Storage Locker
│   ├── Blueprint Library
│   ├── Personalization Station
│   └── Quantum Storage (Subscription only)
├── Resource Display (Top-right)
│   ├── Carried Scrap: [amount]
│   ├── Banked Scrap: [amount] [Withdraw →]
│   ├── Workshop Components: [amount] / [limit]
│   └── Storage Fees: [amount/day]
└── Active Tab Content
```

---

### Repair Station Tab

```
[Repair Station]

Inventory Items:
┌────────────────────────────────────┐
│ Tier 4 Railgun                      │
│ Durability: 80% (20% lost)          │
│ Repair Cost: 40 components          │
│   (Scrap Tech 50: -50% cost)        │
│                                     │
│ [Repair with Components]            │
│ [Repair with Scrap (120 scrap)]     │
└────────────────────────────────────┘
```

---

### Recycling Station Tab

```
[Recycling Station]

Inventory Items:
┌────────────────────────────────────┐
│ Tier 2 Sword                        │
│ Value: 15-25 components             │
│ Scrap Tech Bonus: +100% yield       │
│ Total: 30-50 components             │
│                                     │
│ [Recycle Item]                      │
└────────────────────────────────────┘

⚠️ Warning: Recycling is permanent!
```

---

### Storage Locker Tab

```
[Storage Locker - Character: Bruiser]

Stored Items (5):
┌────────────────────────────────────┐
│ Tier 4 Railgun                      │
│ Durability: 100% (protected)        │
│ Storage Fee: 10 scrap/day           │
│ [Retrieve]                          │
└────────────────────────────────────┘

Stored Blueprints (3):
┌────────────────────────────────────┐
│ Energy Sword Blueprint (T3)         │
│ Storage Fee: 10 scrap/day           │
│ [Retrieve]                          │
└────────────────────────────────────┘

Total Storage Fees: 80 scrap/day
[Upgrade to Subscription for FREE storage]
```

---

### Blueprint Library Tab

```
[Blueprint Library]

Unlocked Blueprints (8):
┌────────────────────────────────────┐
│ Tier 4 Railgun                      │
│ Generic Crafts: 1/3 used            │
│ Personalized Crafts: Unlimited      │
│                                     │
│ [Craft Generic (25 scrap +          │
│  50 components)]                    │
│ [Craft Personalized (200 scrap +    │
│  100 components)]                   │
└────────────────────────────────────┘

Available Blueprints (12):
┌────────────────────────────────────┐
│ Tier 3 Energy Sword                 │
│ Unlock Cost: 50 scrap               │
│ [Unlock Blueprint]                  │
└────────────────────────────────────┘
```

---

### Personalization Station Tab

```
[Personalization Station]

Blueprint: Tier 4 Railgun
Cost: 200 scrap + 100 Workshop Components

┌────────────────────────────────────┐
│ Custom Name:                        │
│ [__________________________]        │
│                                     │
│ Your Stats:                         │
│   Luck: 100                         │
│   Scrap Tech: 100                   │
│                                     │
│ Stat Bonus: 310%                    │
│   Base Damage: 50 → 205             │
│                                     │
│ Visual Customization:               │
│   Color Tint: [Rainbow ▼]           │
│   Particle Effect: [Lightning ▼]    │
│   Glow Effect: [Legendary ✓]       │
│                                     │
│ [Create Personalized Weapon]        │
└────────────────────────────────────┘

⭐ This weapon will be soul-bound to this character.
```

---

### Quantum Storage Tab (Subscription Only)

```
[Quantum Storage Locker]

💎 Subscription Feature

Transfer items between characters:

From Character: [Bruiser ▼]
To Character: [Lucky ▼]

Items Available for Transfer:
┌────────────────────────────────────┐
│ Tier 4 Railgun                      │
│ Last Transferred: Never             │
│ Cooldown: Ready                     │
│ [Transfer →]                        │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ Energy Sword Blueprint (T3)         │
│ Last Transferred: 12 hours ago      │
│ Cooldown: 12 hours remaining        │
│ [Transfer ✗]                        │
└────────────────────────────────────┘
```

---

## Technical Implementation

### Service Architecture

**WorkshopService.gd:**
```gdscript
extends Node

# Workshop Components management
var components_balance: int = 0
var components_limit: int = 75  # Updated based on player tier

# Storage management
var stored_items: Dictionary = {}  # {character_id: [items]}
var stored_blueprints: Dictionary = {}  # {character_id: [blueprint_ids]}

# Blueprint Library
var unlocked_blueprints: Dictionary = {}  # {character_id: {blueprint_id: crafts_used}}

# Repair Station
func repair_item_with_components(item: Item) -> bool:
    var cost = calculate_repair_cost(item.tier, 100 - item.durability)
    if components_balance >= cost:
        components_balance -= cost
        item.durability = 100
        return true
    return false

func repair_item_with_fund(item: Item) -> bool:
    var cost = calculate_repair_cost(item.tier, 100 - item.durability) * 3
    return BankingService.deduct_repair_fund(cost) and (item.durability = 100)

# Recycling Station
func recycle_item(item: Item) -> int:
    var reward = calculate_recycle_reward(item.tier)

    # Check storage limit
    if components_balance + reward > components_limit:
        var overflow = (components_balance + reward) - components_limit
        ToastService.show("Component storage full! Would overflow by %d." % overflow)
        if PlayerService.get_tier() != "subscription":
            ToastService.show("Upgrade to Subscription for unlimited storage!")
        return 0

    components_balance += reward
    InventoryService.remove_item(item)
    return reward

# Storage Locker
func store_item(character_id: String, item: Item) -> void:
    if not stored_items.has(character_id):
        stored_items[character_id] = []
    stored_items[character_id].append(item)
    InventoryService.remove_item(item)

func retrieve_item(character_id: String, item: Item) -> void:
    stored_items[character_id].erase(item)
    InventoryService.add_item(item)

# Blueprint Library
func unlock_blueprint(character_id: String, blueprint_id: String) -> bool:
    var blueprint = BlueprintDatabase.get(blueprint_id)
    var cost = get_unlock_cost(blueprint.tier)

    if BankingService.spend_scrap(cost):
        if not unlocked_blueprints.has(character_id):
            unlocked_blueprints[character_id] = {}
        unlocked_blueprints[character_id][blueprint_id] = 0  # 0 generic crafts used
        return true
    return false

# Personalization Station
func personalize_weapon(character_id: String, blueprint_id: String, custom_name: String, visuals: Dictionary) -> Item:
    if not BankingService.spend_scrap(200):
        return null
    if not spend_components(100):
        return null

    var blueprint = BlueprintDatabase.get(blueprint_id)
    var item = ItemFactory.create_from_blueprint(blueprint)

    # Apply personalization
    item.name = custom_name
    item.is_personalized = true
    item.soul_bound = true

    # Calculate and apply stat bonus
    var character = CharacterService.get_character(character_id)
    var luck = character.get_stat("luck")
    var scrap_tech = character.get_skill("scrap_tech")
    var bonus = 0.10 + (luck / 100.0) + (scrap_tech / 50.0)
    apply_stat_bonus(item, bonus)

    # Apply visuals
    item.color_tint = visuals.color_tint
    item.particle_effect = visuals.particle_effect

    return item

# Helper functions
func calculate_repair_cost(tier: int, durability_lost: int) -> int:
    var base_cost = tier * durability_lost * 2
    var scrap_tech = PlayerStats.get_skill("scrap_tech")
    var reduction = scrap_tech / 100.0
    return int(base_cost * (1.0 - reduction))

func calculate_recycle_reward(tier: int) -> int:
    var base = [7, 20, 40, 100][tier - 1]
    var scrap_tech = PlayerStats.get_skill("scrap_tech")
    return int(base * (1.0 + scrap_tech / 50.0))

func get_unlock_cost(tier: int) -> int:
    return [0, 25, 50, 100][tier - 1]
```

---

## Balancing Considerations

### Durability System Friction

**Problem:** Durability loss on death is frustrating (Brotato has none)

**Solution:** "Friction with Escape Hatches"
1. ✅ **Keep durability** (drives Workshop engagement)
2. ✅ **Workshop Components are FREE** (earned via recycling)
3. ✅ **Repair Fund for convenience** (passive, but 3x cost)
4. ✅ **Premium/Subscription reduce loss** (5%/2% vs 10%)
5. ✅ **Storage protects items** (0% loss if stored)

**Result:** Durability exists but with player-friendly mitigation

---

### Storage Fee Economy

**Free Tier (15 scrap/item/day):**
- Storing 10 items = 150 scrap/day
- Murder Hobo (Subscription) earns 80 scrap/day
- **Conclusion:** Free players must be selective about storage

**Premium Tier (10 scrap/item/day):**
- Storing 10 items = 100 scrap/day
- Still significant cost, but more manageable
- **Conclusion:** Premium players can store more freely

**Subscription Tier (FREE storage):**
- Unlimited storage with no fees
- **Conclusion:** Major quality-of-life improvement

**CTA effectiveness:**
- Free → Premium: "Save 33% on storage fees!"
- Premium → Subscription: "FREE storage + Quantum transfer!"

---

### Personalization Power Budget

**Base weapons (no personalization):**
- Tier 4 Railgun: 50 Ranged Damage

**Low investment (Luck 0, Scrap Tech 0):**
- Personalized: 60 Ranged Damage (+20%)
- **Conclusion:** Minimal power gain, but cheap early game

**High investment (Luck 100, Scrap Tech 100):**
- Personalized: 205 Ranged Damage (+310%)
- **Conclusion:** Massive endgame power spike

**Balance:**
- ✅ **Requires heavy stat investment** (Luck + Scrap Tech = 200 points)
- ✅ **Expensive per craft** (200 scrap + 100 components)
- ✅ **Soul-bound** (can't farm on alts)
- ✅ **Competes with other stats** (opportunity cost of not investing in Damage/HP/etc.)

**Power compared to Brotato:**
- Brotato: No personalization, fixed weapon stats
- Scrap Survivor: Extreme scaling potential with investment
- **Conclusion:** Personalization is a unique endgame progression path

---

## Analytics Tracking

### Key Metrics

**Workshop engagement:**
- % of players using Repair Station per week
- % of players using Recycling Station per week
- Average Workshop Components balance
- Most recycled items (by tier)

**Storage usage:**
- Average items stored per tier (Free/Premium/Subscription)
- Storage fee revenue per tier
- % of players at storage capacity

**Blueprint system:**
- Blueprint unlock rate per tier
- Generic crafts used vs personalized crafts
- Most popular blueprints for personalization

**Personalization:**
- % of players creating personalized weapons
- Average Scrap Tech investment
- Average personalization stat bonus
- Most popular visual customizations

**Conversion:**
- Free → Premium conversion driven by storage fees
- Premium → Subscription conversion driven by FREE storage

---

## Open Questions

**For discussion:**
1. Should Workshop Components be tradeable between players?
   - **Recommendation:** No, keeps Workshop engagement per-player

2. Should personalized weapons lose durability?
   - **Recommendation:** Yes, but repair costs reduced by 50% (investment reward)

3. Should there be a max storage limit per character?
   - **Recommendation:** Yes, Free=20 items, Premium=50 items, Subscription=unlimited

4. Should Blueprint Library unlocks be account-wide or character-specific?
   - **Current design:** Character-specific
   - **Alternative:** Account-wide (reduces grind)

---

## Summary

The Workshop System provides:
- ✅ **Item persistence** (Brotato has none)
- ✅ **Personalization** (custom naming, stat bonuses, visuals)
- ✅ **Strategic depth** (repair, recycle, store decisions)
- ✅ **Tier differentiation** (storage fees drive Premium/Subscription CTAs)
- ✅ **Endgame progression** (Scrap Tech scaling, 310% max bonuses)
- ✅ **Friction mitigation** (Workshop Components earned free, escape hatches for durability)

**Workshop is a core differentiator from Brotato** and provides long-term player engagement through crafting, personalization, and resource management.

---

## References

- [STAT-SYSTEM.md](./STAT-SYSTEM.md) - Scrap Tech skill definition
- [ITEM-STATS-SYSTEM.md](./ITEM-STATS-SYSTEM.md) - Blueprint system, item tiers
- [BANKING-SYSTEM.md](./BANKING-SYSTEM.md) - Repair Fund integration
- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Quantum Storage feature
