# Scrap Survivor: Complete Game Design Document

**Genre:** Wave-based Roguelite Survival
**Inspiration:** Brotato, Vampire Survivors
**Platform:** Godot 4.4 (targeting Mobile + Desktop)
**Version:** 1.0 (Godot Migration)

---

## Table of Contents

1. [Core Gameplay Loop](#1-core-gameplay-loop)
2. [Game Systems Overview](#2-game-systems-overview)
3. [Combat System](#3-combat-system)
4. [Character System](#4-character-system)
5. [Inventory & Items](#5-inventory--items)
6. [Shop System](#6-shop-system)
7. [Workshop System](#7-workshop-system)
8. [Resource Economy](#8-resource-economy)
9. [Progression Systems](#9-progression-systems)
10. [Monetization & Tiers](#10-monetization--tiers)
11. [Hub (The Scrapyard)](#11-hub-the-scrapyard)
12. [Technical Architecture](#12-technical-architecture)

---

## 1. Core Gameplay Loop

**The Loop:**
```
Hub (Scrapyard) → Character Select → Combat (The Wasteland) →
Shop/Workshop → Repeat → Death/Victory → Hub
```

### 1.1 Detailed Flow

1. **The Scrapyard (Hub)**
   - Navigate between game features
   - Manage characters
   - Access shop, workshop, banking
   - View progression/stats

2. **Character Selection**
   - Choose from saved characters
   - Each character has independent progress
   - Character slots limited by tier (3/15/50)

3. **The Wasteland (Combat)**
   - Wave-based survival combat
   - Auto-fire weapons
   - Collect scrap from enemies
   - Find items/weapons as drops
   - Progress through waves

4. **Shop (Between Waves)**
   - Purchase weapons, armor, consumables
   - Reroll for new items (costs scrap)
   - Tier-gated premium items

5. **Workshop (Between Runs)**
   - Repair damaged items (restore durability)
   - Fuse duplicate items (upgrade fusion tier)
   - Craft items from blueprints
   - Dismantle items for resources (Recycler)

6. **Progression**
   - Characters gain XP and level up
   - Unlock new character types
   - Unlock premium weapons/items
   - Track highest wave reached

### 1.2 Session Structure

**Short Session (5-10 minutes):**
- Enter combat
- Survive 5-10 waves
- Die or shop
- Return to hub

**Long Session (20-30 minutes):**
- Multiple runs
- Workshop management
- Character progression
- High wave pushing

---

## 2. Game Systems Overview

### 2.1 Core Systems

| System | Purpose | Status (Godot) |
|--------|---------|----------------|
| **Character** | Character management, persistence | ⏳ Week 6 Days 4-5 |
| **Combat** | Wave-based survival combat | 📋 Week 8 |
| **Inventory** | Item management, auto-active stats | 📋 Week 7 |
| **Shop** | Item purchasing marketplace | 📋 Week 7 |
| **Workshop** | Repair, fusion, crafting | 📋 Week 9 |
| **Banking** | Currency management | ✅ Implemented (Week 5) |
| **Recycler** | Item dismantling | ✅ Implemented (Week 5) |
| **Tier/Monetization** | Feature gating, IAP | 📋 Week 7 |
| **Save** | Persistence, auto-save | ✅ Implemented (Week 6) |

### 2.2 Supporting Systems

| System | Purpose | Status (Godot) |
|--------|---------|----------------|
| **Stat** | Stat calculation, combat math | ✅ Implemented (Week 4) |
| **Error** | Error handling, logging | ✅ Implemented (Week 4) |
| **Logger** | Activity logging | ✅ Implemented (Week 4) |
| **Supabase** | Cloud sync, auth | 📋 Week 7 |
| **Tutorial** | First-time user experience | 📋 Week 13 |
| **Settings** | Player preferences | 📋 Week 12 |

---

## 3. Combat System

**See:** [docs/game-design/systems/COMBAT-SYSTEM.md](game-design/systems/COMBAT-SYSTEM.md)

### 3.1 Core Mechanics

**Player:**
- Top-down movement (WASD/joystick)
- Auto-fire weapons toward cursor/touch
- Stats from character + items + weapons
- Death triggers durability loss

**Enemies:**
- 3 enemy types (direct, zigzag, steady)
- Spawn in waves (interval-based)
- Scale health/speed/damage per wave
- Drop scrap + items on death

**Waves:**
- Progressive difficulty scaling
- Health: +25% per wave
- Speed: +5% per wave
- Damage: +10% per wave
- Max 30 enemies on screen (mobile performance)

**Combat Loop:**
```
Wave Start → Enemies Spawn → Player Fights →
Wave Clear → Shop Phase → Next Wave
```

### 3.2 Enemy Types

| Type | Behavior | Health | Speed | Notes |
|------|----------|--------|-------|-------|
| **Direct** | Straight toward player | 100% | 100% | Basic enemy |
| **Zigzag** | Zigzag pattern | 80% | 120% | Harder to hit |
| **Steady** | Slow, tanky | 200% | 60% | High HP |

### 3.3 Scaling Formula

```gdscript
# Enemy scaling (per wave)
enemy_health = base_health * (1 + (current_wave * 0.25))
enemy_speed = base_speed * (1 + (current_wave * 0.05))
enemy_damage = base_damage * (1 + (current_wave * 0.10))

# Example: Wave 10
health = 100 * (1 + (10 * 0.25)) = 350
speed = 100 * (1 + (10 * 0.05)) = 150
damage = 10 * (1 + (10 * 0.10)) = 20
```

### 3.4 Performance Targets

- **60 FPS** on mobile (iOS/Android)
- **Max 30 enemies** on screen
- **Object pooling** for enemies + projectiles
- **Collision optimization** (spatial hashing)

---

## 4. Character System

**See:** [docs/game-design/systems/CHARACTER-SYSTEM.md](game-design/systems/CHARACTER-SYSTEM.md)

### 4.1 Character Types

**Free Tier (3 types):**

| Type | HP | Speed | Weapon | Luck | Playstyle |
|------|-----|-------|--------|------|-----------|
| **Scavenger** | 100 | 200 | Pistol | 15 | Balanced, high luck |
| **Soldier** | 150 | 180 | Rifle | 5 | Tank, low luck |
| **Engineer** | 80 | 190 | Wrench | 10 | Speed, tech focus |

**Premium Tier (additional types):**
- Medic
- Berserker
- Sniper
- (More to be designed)

### 4.2 Character Progression

**Per-Character Stats:**
```gdscript
class CharacterData:
    var id: String              # UUID
    var name: String            # Player-chosen name
    var character_type: String  # "scavenger", "soldier", etc
    var level: int              # Current level (1-100)
    var experience: int         # XP points
    var stats: Dictionary       # Base stats
    var weapons: Array          # Equipped weapons
    var currency: Dictionary    # Scrap, premium currency
    var current_wave: int       # Current run progress
    var highest_wave: int       # Best wave reached
    var death_count: int        # Times died
    var total_kills: int        # Enemies killed
```

**Experience/Leveling:**
- XP gained from enemy kills
- Level up improves base stats
- Formula: `xp_required = level * 100`

### 4.3 Character Limits (Tier-Based)

| Tier | Character Slots | Notes |
|------|----------------|-------|
| **Free** | 3 slots | Base game |
| **Premium** | 15 slots | One-time purchase |
| **Subscription** | 50 active + 200 archived | Monthly subscription |

---

## 5. Inventory & Items

**See:** [docs/game-design/systems/INVENTORY-SYSTEM.md](game-design/systems/INVENTORY-SYSTEM.md)

### 5.1 Auto-Active Inventory

**Key Concept:** All owned items automatically contribute stats (no equip/unequip)

**Why?**
- Mobile-friendly (no micromanagement)
- Faster gameplay pace
- Encourages collection
- Simplifies UI

### 5.2 Item Types

| Type | Purpose | Stackable | Example Stats |
|------|---------|-----------|---------------|
| **Weapon** | Primary damage source | No | +damage, +fire_rate |
| **Armor** | Defense, survival | Yes | +max_health, +armor |
| **Consumable** | Temporary buffs | Yes | +speed (1 min) |
| **Trinket** | Special bonuses | Yes | +luck, +xp_gain |

### 5.3 Item Rarities

| Rarity | Color | Drop Rate | Stat Bonus | Fusion Cap |
|--------|-------|-----------|------------|------------|
| **Common** | Gray | 50% | 1x | Tier 3 |
| **Uncommon** | Green | 30% | 1.25x | Tier 5 |
| **Rare** | Blue | 15% | 1.5x | Tier 7 |
| **Epic** | Purple | 4% | 2x | Tier 10 |
| **Legendary** | Gold | 1% | 3x | Tier 15 |

### 5.4 Durability System

**All items have durability:**
- **Max Durability:** Determined by rarity
- **Durability Loss:** On character death
- **Broken Items:** 0 durability = inactive (no stats)
- **Repair:** Workshop service (costs scrap + components)

**Formula:**
```gdscript
durability_loss_on_death = max_durability * 0.10  # Lose 10% per death
```

### 5.5 Storage Model

**Critical Architecture Note:** (See DATA-MODEL.md)

Inventory spans TWO locations:

1. **Weapons:** Stored IN `CharacterInstance.weapons[]`
2. **Other Items:** Stored in separate `InventoryService`

**Why?**
- Historical: Weapons implemented first
- Performance: Weapons accessed frequently in combat
- Godot Migration: Will consolidate to single location

---

## 6. Shop System

**See:** [docs/game-design/systems/SHOP-SYSTEM.md](game-design/systems/SHOP-SYSTEM.md)

### 6.1 Shop Mechanics

**When Available:**
- Between waves (combat pause)
- In hub (pre-run shopping)

**Features:**
- Browse items filtered by type
- Purchase with scrap currency
- Reroll inventory (costs scrap)
- Tier-gated premium items

### 6.2 Shop Reroll

**Already Implemented:** `ShopRerollService` (Week 5)

**Costs:**
- 1st reroll: 50 scrap
- 2nd reroll: 100 scrap (2x)
- 3rd reroll: 200 scrap (4x)
- Resets daily (based on game day)

**Formula:**
```gdscript
cost = BASE_COST * (2 ** reroll_count)
```

### 6.3 Item Pricing

**Price Scaling by Rarity:**

| Rarity | Base Price | Weapon Price | Armor Price |
|--------|------------|--------------|-------------|
| Common | 50 | 75 | 40 |
| Uncommon | 100 | 150 | 80 |
| Rare | 200 | 300 | 160 |
| Epic | 500 | 750 | 400 |
| Legendary | 1500 | 2250 | 1200 |

**Premium Items:**
- Marked with `isPremium: true`
- Require Premium tier access
- Higher base stats
- Distinct visual style

---

## 7. Workshop System

**See:** [docs/game-design/systems/WORKSHOP-SYSTEM.md](game-design/systems/WORKSHOP-SYSTEM.md)

### 7.1 Workshop Services

**Three Tabs:**

1. **Repair Tab**
   - Restore item durability
   - Cost: Scrap + Workshop Components
   - Rarity-based pricing

2. **Fusion Tab**
   - Combine duplicate items
   - Increases fusion tier (+10% stats per tier)
   - Requires 2 identical items
   - Max tier based on rarity

3. **Craft Tab**
   - Create items from blueprints
   - Cost: Scrap + Workshop Components
   - Unlock blueprints via drops

### 7.2 Repair Costs

**Formula:**
```gdscript
scrap_cost = base_repair_cost[rarity] * (1 - (durability / max_durability))
component_cost = base_component_cost[rarity] * (1 - (durability / max_durability))
```

**Base Costs:**

| Rarity | Scrap | Components |
|--------|-------|------------|
| Common | 20 | 2 |
| Uncommon | 40 | 4 |
| Rare | 80 | 8 |
| Epic | 200 | 20 |
| Legendary | 500 | 50 |

### 7.3 Fusion System

**Fusion Tiers:**
- Combine 2 identical items → +1 fusion tier
- Each tier: +10% to all stats
- Max tier depends on rarity (see 5.3)

**Example:**
```
Rare Sword (Tier 0): 50 damage
Rare Sword (Tier 1): 55 damage (+10%)
Rare Sword (Tier 2): 60.5 damage (+21%)
```

**Cannot fuse:**
- Different items
- Different rarities
- Max tier reached

---

## 8. Resource Economy

### 8.1 Currency Types

| Currency | Earned From | Used For | Tier Access |
|----------|-------------|----------|-------------|
| **Scrap** | Enemy kills, recycling | Shop, workshop, rerolls | All tiers |
| **Workshop Components** | Recycling items | Workshop repairs | All tiers |
| **Premium Currency** | IAP, referrals | Premium items | All tiers |

### 8.2 Scrap Sources

**During Combat:**
- Enemy kills: 5-20 scrap (based on enemy type)
- Wave completion bonuses
- Scrap pickups (random drops)

**From Recycler:**
- Dismantle items for scrap + components
- Rarity-based yields (see RecyclerService, Week 5)

**Formula (Recycler):**
```gdscript
scrap_granted = base_scrap[rarity] * luck_modifier * radioactivity_modifier
components_granted = base_components[rarity] * luck_modifier
```

### 8.3 Economy Balance Targets

**Early Game (Waves 1-10):**
- Earn: ~500 scrap per run
- Spend: ~300 scrap (shop + rerolls)
- Net: +200 scrap (save for repairs)

**Mid Game (Waves 10-20):**
- Earn: ~1500 scrap per run
- Spend: ~1000 scrap (better items)
- Net: +500 scrap

**Late Game (Waves 20+):**
- Earn: ~3000 scrap per run
- Spend: ~2000 scrap (legendaries, fusions)
- Net: +1000 scrap

---

## 9. Progression Systems

### 9.1 Short-Term Progression (Per Run)

**Within Combat:**
- Gain XP from kills
- Level up mid-run
- Stat improvements
- Unlock abilities (planned)

**Between Waves:**
- Shop purchases
- Temporary power spikes

### 9.2 Medium-Term Progression (Per Character)

**Across Runs:**
- Permanent character level
- Weapon collection
- Item inventory
- Workshop upgrades
- Highest wave tracking

### 9.3 Long-Term Progression (Account-Wide)

**Meta Progression:**
- Unlock character types
- Unlock premium weapons
- Referral rewards
- Tier upgrades
- Achievements (planned)

### 9.4 Death Penalty

**On Character Death:**
- All items lose 10% durability
- Broken items (0 durability) stop providing stats
- Character returns to hub
- No loss of items/weapons (persist)
- No loss of scrap/currency

**Recovery:**
- Repair items in workshop
- Costs scrap + components
- Encourages recycling low-tier items

---

## 10. Monetization & Tiers

**See:**
- [docs/tier-experiences/free-tier.md](tier-experiences/free-tier.md)
- [docs/tier-experiences/premium-tier.md](tier-experiences/premium-tier.md)
- [docs/tier-experiences/subscription-tier.md](tier-experiences/subscription-tier.md)
- [docs/core-architecture/monetization-architecture.md](core-architecture/monetization-architecture.md)

### 10.1 Tier Overview

| Tier | Price | Character Slots | Weapon Access | Banking | Special Features |
|------|-------|----------------|---------------|---------|------------------|
| **Free** | $0 | 3 | 15 weapons | Per-character | Full gameplay |
| **Premium** | $4.99 one-time | 15 (+expansions) | 23 weapons | Per-character | Premium items |
| **Subscription** | $2.99/month | 50 active + 200 archive | 23 weapons | Quantum Banking | Mr. Fix-It, Quantum Storage |

### 10.2 Referral System (Community Growth Model)

**Free Tier Unlocks via Referrals:**

| Referrals | Reward | Value |
|-----------|--------|-------|
| 1 referral | 500 scrap bonus | $0.50 equivalent |
| 2 referrals | Permanent revive | Game-changer |
| 3 referrals | 25% premium discount | $1.25 off |
| 5 referrals | Free Premium Pack | $4.99 value |

**Philosophy:**
- Reward community growth
- No ads for any tier
- Free tier is complete game (not demo)
- IAP is optional enhancement

### 10.3 Feature Gating

**Free Tier Access:**
- ✅ Full combat experience
- ✅ 3 character slots
- ✅ 15 basic weapons
- ✅ Shop, workshop basics
- ✅ Banking (per-character)
- ❌ Premium items
- ❌ Quantum features

**Premium Tier Unlocks:**
- ✅ 15 character slots (base)
- ✅ 8 premium weapons
- ✅ Premium character types
- ✅ Prerequisite for subscription

**Subscription Tier Unlocks:**
- ✅ 50 active + 200 archive slots
- ✅ Quantum Banking (cross-character currency transfers)
- ✅ Quantum Storage (cross-character item transfers)
- ✅ Mr. Fix-It (passive item repair)
- ✅ Hall of Fame (character archiving)

### 10.4 Implementation (Godot)

**TierService** (Week 7):
```gdscript
class_name TierService

enum UserTier {
    FREE = 0,
    PREMIUM = 1,
    SUBSCRIPTION = 2
}

# Check feature access
func has_feature_access(feature: String) -> bool:
    match feature:
        "premium_weapons":
            return current_tier >= UserTier.PREMIUM
        "quantum_banking":
            return current_tier >= UserTier.SUBSCRIPTION
        _:
            return false

# Get character slot limit
func get_character_slot_limit() -> int:
    match current_tier:
        UserTier.FREE: return 3
        UserTier.PREMIUM: return 15
        UserTier.SUBSCRIPTION: return 50
```

---

## 11. Hub (The Scrapyard)

**See:** [docs/game-design/systems/HUB-SYSTEM.md](game-design/systems/HUB-SYSTEM.md)

### 11.1 Hub Navigation

**Main Destinations:**

| Button | Destination | Purpose | Status |
|--------|-------------|---------|--------|
| **Combat** | The Wasteland | Enter combat | Week 8 |
| **Shop** | Item Shop | Purchase items | Week 7 |
| **Workshop** | Workshop | Repair, fuse, craft | Week 9 |
| **Characters** | Character Manager | Create, select characters | Week 6 |
| **Banking** | Currency Manager | View balances | Week 5 ✅ |
| **Settings** | Settings Menu | Preferences | Week 12 |
| **Upgrade** | IAP Modal | Purchase tiers | Week 7 |

### 11.2 Hub UI Layout

**Persistent Elements:**
- Character name/level display
- Currency display (scrap, premium)
- Current tier indicator
- Navigation menu

**Dynamic Content:**
- Daily challenges (planned)
- Event notifications (planned)
- Achievement progress (planned)

---

## 12. Technical Architecture

**See:** [docs/core-architecture/PATTERN-CATALOG.md](core-architecture/PATTERN-CATALOG.md)

### 12.1 Service Architecture

**Pattern:** Service-oriented design (autoload singletons)

**Core Services:**
```gdscript
# Business Logic Services
- CharacterService (character CRUD, persistence)
- InventoryService (item management)
- ShopService (purchasing logic)
- WorkshopService (repair, fusion, crafting)
- BankingService (currency management) ✅
- RecyclerService (item dismantling) ✅
- TierService (feature gating)
- StatService (stat calculations) ✅

# System Services
- SaveSystem (low-level save/load) ✅
- SaveManager (coordinate service saves) ✅
- ErrorService (error handling) ✅
- Logger (activity logging) ✅
- SupabaseClient (cloud sync, auth)
```

### 12.2 Data Flow

**Typical Flow:**
```
User Action (UI) → Service Method → Business Logic →
Emit Signal → SaveManager Auto-Save → UI Update
```

**Example (Purchase Item):**
```gdscript
# UI
ShopUI.on_purchase_clicked(item):
    ShopService.purchase_item(item)

# Service
ShopService.purchase_item(item):
    if BankingService.subtract_currency(item.price):
        InventoryService.add_item(item)
        item_purchased.emit(item)
        # SaveManager auto-saves

# UI Listens
ShopService.item_purchased.connect(on_item_purchased)
```

### 12.3 Persistence Strategy

**Local-First Approach:**
- Primary storage: Godot ConfigFile (user://)
- Cloud sync: Supabase (optional, Week 7+)
- Auto-save: Every 5 minutes + on major events
- Save slots: 0-9 (slot 0 = auto-save)

**Save Format:**
```ini
[metadata]
version=1
slot=0
timestamp=1699564800

[services.banking]
version=1
balances={"scrap":1000,"premium":50}

[services.character]
version=1
characters=[...]
active_character_id="uuid"
```

### 12.4 Signal-Driven Architecture

**Key Signals:**
```gdscript
# BankingService
signal currency_changed(type: int, new_balance: int)

# CharacterService
signal character_created(character: Dictionary)
signal character_updated(character: Dictionary)
signal active_character_changed(character: Dictionary)

# ShopService
signal item_purchased(item: Dictionary)

# RecyclerService
signal item_dismantled(template_id: String, outcome: Dictionary)

# SaveManager
signal save_started()
signal save_completed(success: bool)
```

**Benefits:**
- Decoupled UI from business logic
- Easy to add new listeners
- Auto-save triggers on any state change

### 12.5 Quality Enforcement

**Pre-commit Validation:**
- Native class name checker (BLOCKING)
- Service API consistency (BLOCKING)
- Test method validator (BLOCKING)
- GDScript linting (BLOCKING)
- All tests must pass (BLOCKING)

**Test Coverage:**
- Unit tests for each service
- Integration tests for cross-service flows
- Combat system tests (Week 8+)

---

## Appendix: Quick Reference

### Godot Migration Status

**✅ Completed:**
- Week 1-3: Environment, configs, resources
- Week 4: Foundation services (GameState, ErrorService, Logger, StatService)
- Week 5: Business services (Banking, Recycler, ShopReroll)
- Week 6 Days 1-3: SaveSystem, SaveManager, quality validators

**⏳ In Progress:**
- Week 6 Days 4-5: CharacterService (local-only)

**📋 Planned:**
- Week 7: InventoryService, ShopService, Supabase
- Week 8: Combat system (player, enemies, waves)
- Week 9: Workshop system (repair, fusion, craft)
- Week 10-11: Items, weapons, drops
- Week 12-13: UI (hub, menus, combat HUD)
- Week 14-16: Testing, polish, deployment

### Key Files

**Game Design:**
- This document (GAME-DESIGN.md)
- docs/game-design/systems/*.md
- docs/tier-experiences/*.md

**Technical:**
- docs/core-architecture/*.md
- docs/godot/*.md
- .system/docs/week-06/*.md

### Contacts

**Developer:** Alan Spector
**Repository:** scrap-survivor-godot
**Original Repo:** scrap-survivor (React Native + Phaser)

---

**Last Updated:** November 9, 2025
**Document Version:** 1.0
**Migration Week:** Week 6

🎮 Ready to build an awesome game!
