# Scrap Survivor: Complete Game Design Document

**Genre:** Wave-based Roguelite Survival
**Inspiration:** Brotato, Vampire Survivors
**Platform:** Godot 4.5.1 (targeting Mobile + Desktop)
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
12. [Perks System](#12-perks-system)
13. [Minions System](#13-minions-system)
14. [Goals System](#14-goals-system)
15. [Special Events](#15-special-events)
16. [Trading Cards](#16-trading-cards)
17. [Black Market](#17-black-market)
18. [Atomic Vending Machine](#18-atomic-vending-machine)
19. [Subscription Services](#19-subscription-services)
20. [Personalization System](#20-personalization-system)
21. [Advisor System](#21-advisor-system)
22. [Achievements](#22-achievements)
23. [Feature Request System](#23-feature-request-system)
24. [Controller Support](#24-controller-support)
25. [Radioactivity System](#25-radioactivity-system)
26. [Technical Architecture](#26-technical-architecture)

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
| **Subscription** | $2.99/month | 50 active + 200 archive | 23 weapons | Quantum Banking | Quantum Storage, Atomic Vending, Hall of Fame |

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
- ✅ Atomic Vending Machine (weekly personalized shop)
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

## 12. Perks System

**See:** [docs/game-design/systems/PERKS-SYSTEM.md](game-design/systems/PERKS-SYSTEM.md)

### 12.1 Overview

The Perks System provides server-injected gameplay modifiers that alter core mechanics through a hook-based architecture. Perks are server-authoritative, dynamically delivered, and integrate seamlessly with all game systems without requiring client code changes.

**Key Features:**
- **Server-Driven:** All perk logic defined server-side (Supabase Edge Functions)
- **Hook Architecture:** 50+ injection points across all game systems
- **Dynamic Discovery:** Clients query available perks at runtime
- **Anti-Cheat:** Server validates all perk applications and stat calculations

### 12.2 Perk Categories

| Category | Examples | Tier Access |
|----------|----------|-------------|
| **Combat** | +20% damage, explosive crits | All tiers |
| **Economy** | 2x scrap drops, -50% shop costs | All tiers |
| **Survival** | +1 revive, damage immunity | Premium+ |
| **Meta** | 2x XP gain, permanent luck boost | Subscription |

### 12.3 Technical Integration

Perks inject into game systems via standardized hook points:
- **Pre-hooks:** Modify inputs (e.g., `shop_purchase_pre` adjusts price)
- **Post-hooks:** Modify outputs (e.g., `enemy_death_post` grants bonus scrap)
- **Event-hooks:** Trigger on events (e.g., `wave_complete` spawns loot)

**Status:** Designed, implementation planned (Week 10+)

---

## 13. Minions System

**See:** [docs/game-design/systems/MINIONS-SYSTEM.md](game-design/systems/MINIONS-SYSTEM.md)

### 13.1 Overview

Minions are AI-controlled combat companions that fight alongside the player during Wasteland runs. Managed through the Barracks hub location, minions provide tactical variety, passive bonuses, and add strategic depth to character builds.

**Key Features:**
- **6 Minion Types:** Tank, DPS, Support, Ranged, Melee, Hybrid
- **Progression:** Per-minion XP, levels, and equipment slots
- **Active Slots:** 3 simultaneous minions in combat
- **Formation Control:** Player-defined positioning (Front/Mid/Back)

### 13.2 Minion Types

| Type | Role | Stats | Special Ability |
|------|------|-------|----------------|
| **Scrap Bot** | Tank | High HP, Low Damage | Taunt enemies |
| **Turret Drone** | DPS | Glass cannon | High fire rate |
| **Medic Bot** | Support | Healing aura | Auto-revive player |
| **Sniper Drone** | Ranged | Long range, precision | Headshot bonus |
| **Brawler Bot** | Melee | AOE damage | Stun attacks |
| **Hybrid Sentinel** | Hybrid | Balanced | Adaptive mode switching |

### 13.3 Tier Access

- **Free Tier:** 1 active minion slot, 3 roster slots
- **Premium Tier:** 2 active minion slots, 10 roster slots
- **Subscription Tier:** 3 active minion slots, 25 roster slots

**Status:** Designed, implementation planned (Week 11+)

---

## 14. Goals System

**See:** [docs/game-design/systems/GOALS-SYSTEM.md](game-design/systems/GOALS-SYSTEM.md)

### 14.1 Overview

The Goals System provides structured objectives across multiple timeframes (daily, weekly, seasonal) with tier-based participation and rewards. Goals are server-defined and synchronized across all players to create shared progression milestones.

**Key Features:**
- **3 Timeframes:** Daily (24h), Weekly (7d), Seasonal (30d)
- **Auto-Reset:** Server-managed rotation and refresh
- **Tier-Based Rewards:** Higher tiers unlock better rewards
- **Progress Tracking:** Real-time sync via Supabase

### 14.2 Goal Types

| Type | Frequency | Examples | Rewards |
|------|-----------|----------|---------|
| **Daily** | Resets 00:00 UTC | "Kill 100 enemies", "Reach wave 10" | 100-500 scrap, 1-5 components |
| **Weekly** | Resets Monday 00:00 | "Complete 5 daily goals", "Reach wave 20" | 1000 scrap, rare item |
| **Seasonal** | Monthly rotation | "Reach wave 30", "Fuse 10 items" | Legendary item, premium currency |

### 14.3 Tier Participation

- **Free Tier:** 1 daily goal, 1 weekly goal
- **Premium Tier:** 3 daily goals, 2 weekly goals, 1 seasonal goal
- **Subscription Tier:** 5 daily goals, 3 weekly goals, 2 seasonal goals + 2x rewards

**Status:** Designed, implementation planned (Week 12+)

---

## 15. Special Events

**See:** [docs/game-design/systems/SPECIAL-EVENTS-SYSTEM.md](game-design/systems/SPECIAL-EVENTS-SYSTEM.md)

### 15.1 Overview

Special Events are server-activated seasonal or themed gameplay modifications that temporarily alter combat, rewards, and progression. Events create shared experiences across the player base and drive engagement through limited-time content.

**Key Features:**
- **Server-Controlled:** Events activated/deactivated via admin dashboard
- **Dynamic Modifiers:** Custom enemy types, loot tables, difficulty scaling
- **Event Catalog:** Halloween, Winter, Spring, Summer, Boss Rush, Horde Mode
- **Time-Limited Rewards:** Exclusive items and cosmetics

### 15.2 Event Types

| Event | Theme | Modifications | Rewards |
|-------|-------|--------------|---------|
| **Halloween Havoc** | Horror | Zombie enemies, fog effects | Exclusive "Cursed" weapons |
| **Winter Wasteland** | Holiday | Ice enemies, slow effects | Festive armor sets |
| **Boss Rush** | Challenge | Boss-only waves | Legendary blueprints |
| **Horde Mode** | Survival | 2x enemy density | 2x scrap multiplier |

### 15.3 Event Structure

**Activation:**
1. Admin triggers event in Supabase dashboard
2. Clients poll `/events/active` endpoint
3. Event config downloaded (enemy mods, loot tables)
4. UI displays event banner and timer

**Duration:** 3-14 days (configurable per event)

**Status:** Designed, implementation planned (Week 13+)

---

## 16. Trading Cards

**See:** [docs/game-design/systems/TRADING-CARDS-SYSTEM.md](game-design/systems/TRADING-CARDS-SYSTEM.md)

### 16.1 Overview

Trading Cards are shareable achievement snapshots that showcase player accomplishments. Integrated with the referral system, cards serve as social proof and viral marketing tools while celebrating player milestones.

**Key Features:**
- **Auto-Generated:** Cards created on milestone achievements
- **Beautiful Design:** Character portrait, stats, rarity border
- **Social Sharing:** Export to PNG, share on social media
- **Referral Integration:** Cards include referral codes for rewards

### 16.2 Card Types

| Rarity | Trigger | Example | Visual Style |
|--------|---------|---------|-------------|
| **Common** | Reach wave 5 | "First Victory" | Gray border |
| **Rare** | Reach wave 15 | "Wasteland Survivor" | Blue border, particle effects |
| **Epic** | Reach wave 25 | "Elite Scavenger" | Purple border, animated glow |
| **Legendary** | Reach wave 50 | "Legend of the Wastes" | Gold border, holographic effect |

### 16.3 Card Contents

Each card displays:
- Character portrait and name
- Achievement title and description
- Key stats (highest wave, total kills, death count)
- Rarity border and background art
- Shareable referral code (QR code + text)

### 16.4 Referral Flow

1. Player unlocks milestone → Card auto-generated
2. Player shares card on social media
3. New user sees card → Clicks referral link
4. New user signs up with referral code
5. Both players receive referral rewards (see 10.2)

**Status:** Designed, implementation planned (Week 14+)

---

## 17. Black Market

**See:** [docs/game-design/systems/BLACK-MARKET-SYSTEM.md](game-design/systems/BLACK-MARKET-SYSTEM.md)

### 17.1 Overview

The Black Market is a Premium-tier feature offering high-risk, high-reward gambling mechanics for acquiring rare items. Players use premium currency to purchase mystery boxes, mystery rerolls, or gamble on exclusive items with luck-based success rates.

**Key Features:**
- **Premium Currency Only:** No scrap accepted
- **Luck-Based Outcomes:** Player luck stat affects results
- **Exclusive Items:** Unique items unavailable elsewhere
- **Guaranteed Minimum:** Anti-frustration protection on failures

### 17.2 Black Market Services

| Service | Cost | Outcome | Luck Influence |
|---------|------|---------|----------------|
| **Mystery Box** | 50 premium | Random item (Common-Legendary) | +5% Legendary per 10 luck |
| **Mystery Reroll** | 100 premium | Reroll rarity (keep item type) | +10% upgrade chance per 10 luck |
| **Exclusive Gamble** | 200 premium | 50% legendary OR 50% scrap refund | Luck affects success rate |

### 17.3 Luck Formula

```gdscript
legendary_chance = base_chance + (player_luck / 10 * 0.05)
# Example: 50 luck → 5% base + 25% bonus = 30% legendary chance
```

### 17.4 Tier Access

- **Free Tier:** ❌ Cannot access Black Market
- **Premium Tier:** ✅ Full access, standard rates
- **Subscription Tier:** ✅ Full access + 10% discount on all services

**Status:** Designed, implementation planned (Week 15+)

---

## 18. Atomic Vending Machine

**See:** [docs/game-design/systems/ATOMIC-VENDING-MACHINE.md](game-design/systems/ATOMIC-VENDING-MACHINE.md)

### 18.1 Overview

The Atomic Vending Machine is a Subscription-exclusive weekly shop featuring personalized item recommendations based on the player's Playstyle Archetype. Using the Personalization System's AI-driven classification, the machine curates 6-12 items perfectly suited to each player's unique approach.

**Key Features:**
- **Subscription Exclusive:** Only available to active subscribers
- **Weekly Rotation:** Resets every Monday 00:00 UTC
- **Personalized Catalog:** Items matched to player archetype
- **Premium Currency:** All items cost premium currency
- **Guaranteed Value:** Items cost 20-30% less than Black Market

### 18.2 Archetype Item Mapping

| Archetype | Recommended Items | Example |
|-----------|------------------|---------|
| **Tank** | High HP armor, damage reduction | "Fortress Plating" (+50 HP, -20% damage taken) |
| **Glass Cannon** | High damage weapons, crit items | "Devastator Rifle" (+100 damage, -30 HP) |
| **Speedrunner** | Movement speed, wave skip items | "Quantum Boots" (+50% speed) |
| **Hoarder** | Luck items, scrap multipliers | "Lucky Coin" (+20 luck, +10% scrap) |
| **Balanced** | Versatile all-rounder items | "Adaptive Shield" (scales with stats) |

### 18.3 Pricing Structure

```gdscript
base_price = item_rarity_base_cost[rarity]
vending_price = base_price * 0.70  # 30% discount vs Black Market
```

**Example Prices:**
- Common: 35 premium (vs 50 Black Market)
- Rare: 140 premium (vs 200 Black Market)
- Legendary: 350 premium (vs 500 Black Market)

### 18.4 Weekly Refresh Logic

1. Every Monday 00:00 UTC, server generates catalog
2. Fetch player's current archetype from Personalization System
3. Query item database for archetype-tagged items
4. Select 6-12 items (rarity distribution: 50% Common, 30% Rare, 15% Epic, 5% Legendary)
5. Apply pricing discount and cache catalog for 7 days

**Status:** Designed, implementation planned (Week 15+)

---

## 19. Subscription Services

**See:** [docs/game-design/systems/SUBSCRIPTION-SERVICES.md](game-design/systems/SUBSCRIPTION-SERVICES.md)

### 19.1 Overview

The Subscription Tier ($2.99/month) unlocks premium quality-of-life features and exclusive services designed for dedicated players. Requires Premium tier purchase as prerequisite.

**Subscription Features:**
- **Quantum Banking:** Cross-character currency transfers (break 200k cap)
- **Quantum Storage:** Cross-character item transfers
- **Atomic Vending Machine:** Weekly personalized shop (see Section 18)
- **Hall of Fame:** Archive up to 200 retired characters
- **Expanded Slots:** 50 active characters + 200 archived

### 19.2 Quantum Banking

**Purpose:** Transfer scrap and premium currency between characters, overcoming per-character banking caps.

**Key Mechanics:**
- **Source Character:** Must have funds in bank account
- **Destination Character:** Receives instant transfer
- **No Fees:** Unlimited free transfers
- **Cap Override:** Quantum transfers bypass 200k total balance cap
- **Audit Trail:** All transfers logged in Supabase

**Use Case:** Funnel wealth to one "main" character for expensive purchases (legendary items, max-tier fusions).

### 19.3 Quantum Storage

**Purpose:** Transfer items (weapons, armor, trinkets) between characters.

**Key Mechanics:**
- **Source Character:** Must own item in inventory
- **Item Removed:** Instantly removed from source character
- **Destination Character:** Receives item in inventory
- **Durability Preserved:** No durability loss on transfer
- **No Restrictions:** Transfer any item type, any rarity

**Use Case:** Share high-tier weapons across multiple characters, optimize builds.

### 19.4 Hall of Fame

**Purpose:** Archive retired characters while preserving their legacy.

**Key Mechanics:**
- **Archive Capacity:** 200 characters (separate from 50 active slots)
- **Archive Action:** One-way move from active → archive
- **Read-Only:** Archived characters cannot be played
- **Trading Card Generation:** Auto-generate legendary trading card on archive
- **Leaderboard Entry:** Archived characters remain on global leaderboards

**Use Case:** Preserve legendary characters after reaching endgame, showcase achievements.

### 19.5 Tier Access

- **Free Tier:** ❌ None of these features available
- **Premium Tier:** ❌ Must upgrade to Subscription
- **Subscription Tier:** ✅ All features unlocked

**Status:** Designed, implementation planned (Week 16+)

---

## 20. Personalization System

**See:** [docs/game-design/systems/PERSONALIZATION-SYSTEM.md](game-design/systems/PERSONALIZATION-SYSTEM.md)

### 20.1 Overview

The Personalization System uses AI-driven behavioral analysis to classify players into 5 Playstyle Archetypes based on combat decisions, resource management, and meta-progression patterns. This classification powers personalized recommendations in the Atomic Vending Machine, Advisor System, and future features.

**Key Features:**
- **5 Archetypes:** Tank, Glass Cannon, Speedrunner, Hoarder, Balanced
- **Behavioral Tracking:** 20+ metrics logged during gameplay
- **Server-Side Classification:** Supabase Edge Function analyzes patterns
- **Dynamic Updates:** Archetype recalculated after every 5 runs
- **Privacy-First:** All data anonymized, no PII

### 20.2 Playstyle Archetypes

| Archetype | Characteristics | Sample Metrics | Item Recommendations |
|-----------|-----------------|----------------|---------------------|
| **Tank** | High HP focus, defensive play | HP > 200, armor items > 50% | Max HP, damage reduction, regen |
| **Glass Cannon** | Maximize damage, ignore defense | Damage > 500, HP < 100 | Crit chance, damage multipliers |
| **Speedrunner** | Fast clears, wave skipping | Avg wave time < 60s, speed items > 30% | Movement speed, wave skip tokens |
| **Hoarder** | Maximize scrap/item collection | Luck > 30, recycler usage > 10/run | Luck items, scrap multipliers |
| **Balanced** | No dominant pattern | No metric > 40% dominance | Versatile all-rounder items |

### 20.3 Classification Logic

**Tracked Metrics (20+):**
- Combat: Damage dealt, damage taken, kills per wave
- Items: Armor/weapon ratio, rarity distribution, fusion frequency
- Economy: Scrap earned, shop spending, recycler usage
- Meta: Average wave reached, death rate, playtime per session

**Classification Flow:**
1. Player completes run → Metrics logged to Supabase
2. After every 5 runs → Trigger classification Edge Function
3. Function analyzes last 50 runs (10-week rolling window)
4. Assigns archetype based on dominant patterns
5. Archetype stored in `user_profiles.archetype` column
6. UI displays archetype badge in hub

### 20.4 Tier Access

- **Free Tier:** ✅ Classification active, UI shows archetype badge
- **Premium Tier:** ✅ Classification + Advisor recommendations
- **Subscription Tier:** ✅ Classification + Atomic Vending Machine personalization

**Status:** Designed, implementation planned (Week 16+)

---

## 21. Advisor System

**See:** [docs/game-design/systems/ADVISOR-SYSTEM.md](game-design/systems/ADVISOR-SYSTEM.md)

### 21.1 Overview

The Advisor System provides AI-driven gameplay feedback and recommendations to help players improve their strategies. Using the Personalization System's archetype classification and behavioral data, the Advisor delivers contextual tips during gameplay and post-run analysis.

**Key Features:**
- **Real-Time Tips:** Contextual advice during shop phase, combat prep
- **Post-Run Analysis:** Detailed breakdown of performance
- **Archetype-Specific:** Recommendations tailored to playstyle
- **Skill Level Adaptive:** Beginner, intermediate, advanced advice tiers
- **Non-Intrusive:** Optional dismissible notifications

### 21.2 Advice Categories

| Category | Timing | Example | Trigger |
|----------|--------|---------|---------|
| **Build Optimization** | Shop phase | "You have high luck—consider Black Market gambling" | Player enters shop with luck > 30 |
| **Combat Strategy** | Pre-wave | "Focus on zigzag enemies first (they have less HP)" | Wave contains 50%+ zigzag enemies |
| **Economy Management** | Post-run | "You spent 80% of scrap on rerolls—try buying fewer items" | Reroll spending > 50% total scrap |
| **Progression Guidance** | Hub | "You've reached wave 15—unlock Premium for better weapons" | Wave 15+ with Free tier |

### 21.3 Post-Run Analysis

After each run, the Advisor generates a report:

**Report Sections:**
1. **Performance Summary:** Wave reached, kills, scrap earned
2. **Strengths:** Top 3 positive metrics (e.g., "High damage output")
3. **Improvement Areas:** Top 3 weak metrics (e.g., "Low survival time")
4. **Archetype Alignment:** How well run matched archetype (% score)
5. **Recommendations:** 3 actionable tips for next run

### 21.4 Skill Level Detection

**Beginner (< 10 runs):** Basic tips (weapon types, shop usage)
**Intermediate (10-50 runs):** Advanced tactics (fusion optimization, build synergies)
**Advanced (50+ runs):** Meta strategies (archetype min-maxing, economy optimization)

### 21.5 Tier Access

- **Free Tier:** ✅ Basic tips only (beginner level)
- **Premium Tier:** ✅ Full advice, post-run analysis
- **Subscription Tier:** ✅ Full advice + archetype optimization tips

**Status:** Designed, implementation planned (Week 17+)

---

## 22. Achievements

**See:** [docs/game-design/systems/ACHIEVEMENTS-SYSTEM.md](game-design/systems/ACHIEVEMENTS-SYSTEM.md)

### 22.1 Overview

The Achievements System tracks 120+ milestones across 7 categories, providing long-term goals and showcasing player accomplishments. Achievements span 4 difficulty tiers and offer tangible rewards (scrap, premium currency, exclusive items).

**Key Features:**
- **120+ Achievements:** Across combat, progression, economy, social, meta
- **4 Tiers:** Bronze (easy), Silver (medium), Gold (hard), Platinum (extreme)
- **Category Diversity:** Combat, Wave Mastery, Economy, Collection, Social, Character, Meta
- **Tangible Rewards:** Scrap, premium currency, exclusive items, titles

### 22.2 Achievement Categories

| Category | Count | Example Achievements |
|----------|-------|---------------------|
| **Combat** | 20 | "Kill 10,000 enemies", "Deal 1M damage in one run" |
| **Wave Mastery** | 15 | "Reach wave 10/20/30/40/50", "Complete wave 10 without taking damage" |
| **Economy** | 20 | "Earn 100k scrap", "Spend 50k on rerolls", "Own 100 items" |
| **Collection** | 25 | "Own all weapons", "Fuse item to Tier 10", "Own legendary of each type" |
| **Social** | 10 | "Refer 5 players", "Share 10 trading cards" |
| **Character** | 15 | "Reach level 50", "Own 10 characters", "Max out all base stats" |
| **Meta** | 15 | "Play 100 runs", "Die 50 times", "Survive 24 hours of combat" |

### 22.3 Achievement Tiers

| Tier | Difficulty | Reward Example | Color |
|------|-----------|----------------|-------|
| **Bronze** | Easy (80% completion rate) | 500 scrap | Bronze badge |
| **Silver** | Medium (40% completion rate) | 2000 scrap, 10 premium | Silver badge |
| **Gold** | Hard (10% completion rate) | 5000 scrap, 50 premium | Gold badge |
| **Platinum** | Extreme (1% completion rate) | Exclusive legendary item, 200 premium | Platinum badge + particle effects |

### 22.4 Reward Distribution

**Total Rewards Across All Achievements:**
- **Scrap:** ~150,000 total
- **Premium Currency:** ~2,000 total
- **Exclusive Items:** 10 legendary items (Platinum tier only)
- **Titles:** 30 cosmetic titles for profile display

### 22.5 Tier Access

- **Free Tier:** ✅ All achievements trackable, rewards claimable
- **Premium Tier:** ✅ Exclusive Premium category (10 achievements)
- **Subscription Tier:** ✅ Exclusive Subscription category (5 achievements)

**Status:** Designed, implementation planned (Week 17+)

---

## 23. Feature Request System

**See:** [docs/game-design/systems/FEATURE-REQUEST-SYSTEM.md](game-design/systems/FEATURE-REQUEST-SYSTEM.md)

### 23.1 Overview

The Feature Request System enables democratic player-driven development through voting on proposed features. Integrated with the monetization tiers, voting power scales with player investment, ensuring active community members shape the game's future.

**Key Features:**
- **Democratic Voting:** All tiers participate, votes weighted by tier
- **Submission Process:** Players submit ideas, admin curates to ballot
- **Monthly Cycles:** New voting period every 30 days
- **Transparent Results:** Public leaderboard shows vote counts
- **Guaranteed Implementation:** Top vote-getter implemented within 60 days

### 23.2 Voting Power by Tier

| Tier | Votes per Cycle | Vote Weight | Submission Limit |
|------|----------------|-------------|------------------|
| **Free** | 1 vote | 1x weight | 1 submission/month |
| **Premium** | 3 votes | 2x weight | 3 submissions/month |
| **Subscription** | 5 votes | 3x weight | 5 submissions/month |

**Weight Explanation:**
- Free tier vote = 1 point toward feature
- Premium tier vote = 2 points toward feature
- Subscription tier vote = 3 points toward feature

### 23.3 Submission & Curation Flow

1. **Player Submission:** Submit idea via in-game form (title, description, category)
2. **Admin Review:** Developer reviews for feasibility, clarity, duplication
3. **Ballot Addition:** Approved ideas added to current month's ballot
4. **Voting Period:** 30-day window for all players to vote
5. **Results Announcement:** Top 3 features announced, #1 prioritized
6. **Implementation:** Winning feature developed and shipped within 60 days

### 23.4 Feature Categories

| Category | Example Requests | Implementation Scope |
|----------|-----------------|---------------------|
| **Combat** | "Add boss enemies", "New weapon types" | Medium (2-4 weeks) |
| **Systems** | "Auction house", "Guild system" | Large (4-8 weeks) |
| **QoL** | "Auto-repair broken items", "Bulk item selling" | Small (1 week) |
| **Content** | "New character types", "Seasonal events" | Medium (2-4 weeks) |

### 23.5 Moderation & Anti-Abuse

- **Submission Caps:** Tier-based limits prevent spam
- **Admin Curation:** Developer reviews all submissions before ballot
- **Vote Throttling:** Cannot change vote after casting (prevents vote manipulation)
- **Duplicate Detection:** Similar ideas merged into single ballot item

**Status:** Designed, implementation planned (Week 18+)

---

## 24. Controller Support

**See:** [docs/game-design/systems/CONTROLLER-SUPPORT.md](game-design/systems/CONTROLLER-SUPPORT.md)

### 24.1 Overview

Controller Support is a FREE tier feature providing full gamepad compatibility for all gameplay modes. Leveraging Godot 4.5.1's SDL3 gamepad driver, the system offers console-like experiences on desktop with customizable button mappings and UI adaptations.

**Key Design Decisions:**
- **FREE Feature:** Not Premium-gated (aligns with market research on accessibility)
- **Full Navigation:** Hub, combat, menus all gamepad-navigable
- **Auto-Detection:** Seamless switching between keyboard/mouse and gamepad
- **Customizable:** Rebindable controls, sensitivity sliders, dead zone config

### 24.2 Supported Controllers

**Tier 1 (Guaranteed):**
- Xbox Series X|S Controller (Bluetooth, USB)
- PlayStation 5 DualSense (Bluetooth, USB)
- Nintendo Switch Pro Controller (Bluetooth, USB)
- Steam Deck built-in controls

**Tier 2 (Best Effort):**
- Xbox One Controller (wireless adapter required)
- PlayStation 4 DualShock 4
- Generic XInput controllers

### 24.3 Control Scheme

**Combat:**
- Left Stick: Character movement
- Right Stick: Aim direction (twin-stick shooter)
- Right Trigger (RT): Fire weapon (hold to auto-fire)
- Left Trigger (LT): Use consumable
- A Button: Dodge roll
- B Button: Return to hub (hold)
- Y Button: Open shop (between waves)
- D-Pad: Quick-select consumables

**Hub Navigation:**
- Left Stick: Cursor movement
- A Button: Select/Confirm
- B Button: Back/Cancel
- Start: Open settings
- Select: Open character menu

### 24.4 UI Adaptations

**When Gamepad Detected:**
- Show button prompts (Xbox/PS icons based on controller)
- Enable cursor snapping to interactive elements
- Display "Hold B to return" instead of "Press ESC"
- Enlarge UI elements for "10-foot experience" (living room gaming)

**Settings Menu:**
- **Sensitivity:** Left/Right stick sensitivity (1-10 scale)
- **Dead Zone:** Stick dead zone threshold (0-30% range)
- **Vibration:** Toggle haptic feedback on/off
- **Button Remapping:** Full button reassignment

### 24.5 Technical Implementation

**Godot 4.5.1 + SDL3:**
- Native SDL3 gamepad support (no plugins required)
- Input event system: `InputEventJoypadButton`, `InputEventJoypadMotion`
- Action remapping via `InputMap` singleton

**Vibration Support:**
- Damage taken → Short pulse (0.2s)
- Enemy killed → Light pulse (0.1s)
- Level up → Strong pulse (0.5s)

### 24.6 Tier Access

- **Free Tier:** ✅ Full controller support
- **Premium Tier:** ✅ Full controller support (no exclusive features)
- **Subscription Tier:** ✅ Full controller support (no exclusive features)

**Accessibility Rationale:** Controller support is not a premium feature—it's essential for inclusivity and platform parity (desktop vs mobile).

**Status:** Designed, implementation planned (Week 12 alongside Settings System)

---

## 25. Radioactivity System

**See:** [docs/game-design/systems/RADIOACTIVITY-SYSTEM.md](game-design/systems/RADIOACTIVITY-SYSTEM.md)

### 25.1 Overview

The Radioactivity System is a high-risk, high-reward mechanic where players deliberately irradiate items to boost stats at the cost of random negative effects. Radioactive items gain powerful bonuses but apply unpredictable debuffs, creating strategic tension in build optimization.

**Key Features:**
- **Irradiation Service:** Workshop tab to irradiate owned items
- **Dual Effects:** Stat bonuses (+20-50%) AND random debuffs
- **Stacking Radiation:** Multiple irradiated items compound effects
- **Luck Mitigation:** High luck reduces debuff severity
- **Permanent:** Irradiation cannot be reversed (irreversible risk)

### 25.2 Irradiation Mechanics

**Process:**
1. Player selects item in Workshop → "Irradiate" tab
2. Pay cost: 500 scrap + 10 workshop components (rarity-scaled)
3. Item gains "Radioactive" status (visual glow effect)
4. Roll stat bonus (20-50% increase to primary stat)
5. Roll debuff (from table of 12 debuffs)

**Stat Bonus Formula:**
```gdscript
bonus_multiplier = randf_range(1.20, 1.50)  # 20-50% boost
new_stat = base_stat * bonus_multiplier
```

### 25.3 Radioactive Debuffs

| Debuff | Effect | Severity |
|--------|--------|----------|
| **Stat Drain** | -10% to random secondary stat | Medium |
| **Glitch** | 5% chance weapon jams per shot | High |
| **Corrosion** | Item loses 5% max durability | Medium |
| **Instability** | Stats fluctuate ±10% randomly | High |
| **Contamination** | Damages nearby allies (minions) | Very High |
| **Decay** | -1% durability per wave | Low |

**Luck Mitigation:**
- Base debuff severity: 100%
- With 50 luck: Severity reduced to 75% (e.g., -10% stat drain → -7.5%)

### 25.4 Strategic Use Cases

**Glass Cannon Build:**
- Irradiate weapon for +50% damage
- Accept "Corrosion" debuff (who cares if you're dying fast anyway?)
- Stack multiple irradiated weapons for multiplicative bonuses

**Tank Build:**
- Avoid irradiation (debuffs hurt survivability)
- OR irradiate armor for +HP, hope for low-severity debuff

**Luck Build:**
- Irradiate ALL items (luck mitigates debuffs)
- Gamble on best-case scenario (high bonus, low debuff)

### 25.5 Recycler Integration

**Already Implemented:** RecyclerService grants radioactivity bonuses (Week 5)

**Radioactive Items in Recycler:**
- Base scrap yield: 1.0x (no bonus/penalty)
- Radioactive bonus: +0-50% scrap (scales with radiation level)
- Components yield: Unchanged

**Example:**
```gdscript
# RecyclerService.calculate_outcome()
if item.is_radioactive:
    scrap_bonus = randf_range(0.0, 0.50)  # 0-50% extra scrap
    total_scrap = base_scrap * (1.0 + scrap_bonus)
```

### 25.6 Tier Access

- **Free Tier:** ✅ Can irradiate items (Workshop tab available)
- **Premium Tier:** ✅ Can irradiate + 10% reduced debuff severity
- **Subscription Tier:** ✅ Can irradiate + 20% reduced debuff severity + preview debuff before confirming

**Status:** Partially implemented (RecyclerService integration complete), full Workshop UI planned (Week 9)

---

## 26. Technical Architecture

**See:** [docs/core-architecture/PATTERN-CATALOG.md](core-architecture/PATTERN-CATALOG.md)

### 26.1 Service Architecture

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

### 26.2 Data Flow

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

### 26.3 Persistence Strategy

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

### 26.4 Signal-Driven Architecture

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

### 26.5 Quality Enforcement

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
