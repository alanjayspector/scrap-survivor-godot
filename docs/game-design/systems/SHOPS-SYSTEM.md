# Shops System

**Status:** Core System - Tier-Gated Features
**Date:** 2025-01-09
**Purpose:** Define all shop types, inventory systems, and tier-based shopping experiences

---

## Overview

Scrap Survivor features **three distinct shop experiences** that scale with player tier:

1. **Standard Shop** (All tiers) - General marketplace with random inventory
2. **Black Market** (Premium+ only) - Curated high-tier items + fully-formed minions
3. **Atomic Vending Machine** (Subscription only) - Personalized items + minion patterns

**Shop Progression:**
```
Free tier: Standard Shop only
Premium tier: Standard Shop + Black Market
Subscription tier: Standard Shop + Black Market + Atomic Vending Machine
```

**Brotato comparison:**
- ✅ Standard Shop: Similar to Brotato shop (random items, limited slots)
- 🟢 Black Market: UNIQUE (premium curated shop with minions)
- 🟢 Atomic Vending Machine: UNIQUE (personalized subscription shop)

---

## 1. Standard Shop (All Tiers)

### What is the Standard Shop?

**The Standard Shop** is the baseline marketplace available to all players. It offers random items with tier-appropriate pricing and no minions.

**Access:** All tiers (Free, Premium, Subscription)

**Location:** Hub → Shop

---

### Inventory System

**Refresh mechanics:**
- **Automatic refresh**: Every 4 hours (server-validated)
- **Manual reroll**: Costs scrap (increases per reroll)
- **Inventory slots**: 6 items per refresh

**Item pool:**
- Weapons (all tiers)
- Armor pieces
- Trinkets
- Consumables
- No minions
- No minion patterns

**Pricing:**
```
Tier 1 items: 50-150 scrap
Tier 2 items: 200-500 scrap
Tier 3 items: 600-1,200 scrap
Tier 4 items: 1,500-3,000 scrap
```

---

### Reroll System

**Manual rerolls:**
- Cost increases per reroll: 50 → 100 → 200 → 400 → 800 scrap
- Resets every 4 hours (with automatic refresh)
- Premium/Subscription get discounted rerolls (see tier comparison)

```gdscript
# ShopService.gd
func calculate_reroll_cost(rerolls_today: int, player_tier: String) -> int:
    var base_cost = 50 * pow(2, rerolls_today)

    # Tier discounts
    match player_tier:
        "premium":
            return int(base_cost * 0.75)  # 25% discount
        "subscription":
            return int(base_cost * 0.50)  # 50% discount
        _:
            return base_cost

# Examples:
# Free tier: 50 → 100 → 200 → 400 → 800
# Premium tier: 37 → 75 → 150 → 300 → 600
# Subscription tier: 25 → 50 → 100 → 200 → 400
```

---

### Item Rarity Distribution

**Standard Shop uses weighted random selection:**

| Player Tier | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|------------|--------|--------|--------|--------|
| Free | 50% | 35% | 13% | 2% |
| Premium | 40% | 35% | 20% | 5% |
| Subscription | 30% | 30% | 30% | 10% |

**Why tier affects distribution:**
- Higher tiers see better items more often
- Creates incentive to upgrade
- Doesn't gate content (Free can still get T4 items, just rare)

---

### Standard Shop UI

```
[Standard Shop]

💰 Carried Scrap: 5,420
🏦 Banked Scrap: 42,850 [Withdraw →]

Next refresh: 2h 34m
Rerolls today: 2/∞ (next reroll: 200 scrap)

Available Items (6):
┌────────────────────────────────────┐
│ Tier 3 Energy Sword                │
│ +45 Melee Damage                   │
│ +15% Attack Speed                  │
│                                    │
│ Price: 850 scrap                   │
│ [Purchase]                         │
├────────────────────────────────────┤
│ Tier 2 Armor Vest                  │
│ +20 Armor                          │
│ +50 Max HP                         │
│                                    │
│ Price: 400 scrap                   │
│ [Purchase]                         │
└────────────────────────────────────┘

[Reroll Shop (200 scrap)]
```

---

## 2. Black Market (Premium Tier)

### What is the Black Market?

**The Black Market** is the Premium tier's exclusive shop scene featuring curated high-tier items and **fully-formed minions for purchase**.

**Access:** Premium + Subscription tiers only

**Location:** Hub → Black Market (separate scene, not a Lab tab)

---

### Black Market Philosophy

**Instant Gratification:**
- Premium players can **buy fully-formed minions** outright (expensive but immediate)
- No crafting, no patterns, no waiting
- Pay premium prices for convenience

**Curated Selection:**
- Limited inventory (3-4 items per refresh)
- Higher rarity baseline (mostly T3-T4 items)
- Always includes 1-2 minions

---

### Black Market Inventory

**Refresh mechanics:**
- **Automatic refresh**: Every 8 hours (slower than Standard Shop)
- **Manual reroll**: 500 scrap base cost (expensive)
- **Inventory slots**: 3-4 items per refresh

**Item pool:**
- High-tier weapons (T3-T4 weighted)
- High-tier armor
- Premium trinkets
- **Fully-formed minions** (ready to use, no crafting)

**Pricing:**
```
Tier 3 items: 1,500-2,500 scrap
Tier 4 items: 3,000-5,000 scrap

Tier 1 minions: 500 scrap
Tier 2 minions: 1,000 scrap
Tier 3 minions: 2,000 scrap
Tier 4 minions: 4,000 scrap
```

---

### Minion Purchases (Black Market)

**What you get:**
- Fully-formed minion (ready to use immediately)
- Base stats (no personalization bonuses)
- Transferable via Quantum Storage (Subscription)
- NOT soul-bound

**Comparison to Lab crafting (Subscription):**

| Method | Cost | Time | Personalization | Transferable |
|--------|------|------|-----------------|--------------|
| Black Market | 500-4,000 scrap | Instant | No | Yes |
| Lab Generic | 50 scrap + 25 Nanites | Instant | No | Yes (degrading) |
| Lab Personalized | 400 scrap + 100 Nanites | Instant | Yes (+310% max) | No (soul-bound) |

**Why buy from Black Market:**
- ✅ Don't need to farm Nanites
- ✅ Instant acquisition (no Lab visit)
- ✅ Guaranteed stats (no pattern degradation)
- ❌ Expensive (8-10x Lab cost)
- ❌ No personalization bonuses

---

### Black Market UI

```
[Black Market]

💀 Premium Exclusive Shop 💀

💰 Carried Scrap: 5,420
🏦 Banked Scrap: 42,850 [Withdraw →]

Next refresh: 6h 12m
Rerolls: 500 scrap per reroll

Black Market Inventory (4):
┌────────────────────────────────────┐
│ Tier 4 Railgun                     │
│ +80 Ranged Damage                  │
│ +25% Crit Chance                   │
│                                    │
│ Price: 4,500 scrap                 │
│ [Purchase]                         │
├────────────────────────────────────┤
│ 🤖 Tier 3 Tank Minion              │
│ 300 HP, 25 Damage, 20 Armor        │
│ Taunt ability (draws enemy aggro)  │
│                                    │
│ Price: 2,000 scrap                 │
│ [Purchase Minion]                  │
├────────────────────────────────────┤
│ 🤖 Tier 2 DPS Minion               │
│ 150 HP, 45 Damage, 5 Armor         │
│ Burst Fire ability                 │
│                                    │
│ Price: 1,000 scrap                 │
│ [Purchase Minion]                  │
└────────────────────────────────────┘

⚠️ Black Market minions are fully-formed and ready for combat.
For personalized crafting, visit The Lab (Subscription).

[Reroll Black Market (500 scrap)]
```

---

## 3. Atomic Vending Machine (Subscription Tier)

### What is the Atomic Vending Machine?

**The Atomic Vending Machine** is the Subscription tier's ultra-exclusive shop featuring **personalized items tailored to your character** and **minion patterns** (not fully-formed minions).

**Access:** Subscription tier only

**Location:** Hub → Atomic Vending Machine (separate scene)

---

### Atomic Vending Machine Philosophy

**Personalization:**
- Items are **tailored to your active character's build**
- Stat bonuses match your playstyle (melee build → melee items)
- Higher stat rolls than Standard/Black Market
- Uses player data to curate inventory

**Minion Patterns vs Minions:**
- Sells **minion patterns** (blueprints), not fully-formed minions
- Patterns are used in The Lab for crafting
- Evolving patterns (stats improve with each craft)
- Premium quality patterns (better base stats)

---

### Atomic Vending Machine Inventory

**Refresh mechanics:**
- **Automatic refresh**: Every 24 hours (personalized curation takes time)
- **Manual reroll**: FREE (1 reroll per day, Subscription perk)
- **Inventory slots**: 2-3 items per refresh (highly curated)

**Item pool:**
- **Personalized weapons** (match character build)
- **Personalized armor** (match character stats)
- **Minion patterns** (evolving, not generic)
- NO consumables (quality over quantity)

**Pricing:**
```
Personalized T3 items: 2,000-3,500 scrap
Personalized T4 items: 4,500-7,000 scrap

Evolving Tier 1 pattern: 200 scrap
Evolving Tier 2 pattern: 400 scrap
Evolving Tier 3 pattern: 800 scrap
Evolving Tier 4 pattern: 1,500 scrap
```

---

### Personalized Items

**How personalization works:**

```gdscript
# AtomicVendingMachine.gd
func generate_personalized_inventory(character: Character) -> Array[Item]:
    var inventory = []

    # Analyze character build
    var primary_damage_type = get_primary_damage_type(character)  # Melee/Ranged/Elemental
    var primary_stats = get_highest_stats(character)  # e.g., Max HP, Armor, Damage

    # Generate personalized weapon
    var weapon = generate_weapon_for_build(primary_damage_type, character.luck)
    weapon.stats.damage *= 1.25  # +25% stat bonus vs Standard Shop
    inventory.append(weapon)

    # Generate personalized armor
    var armor = generate_armor_for_stats(primary_stats)
    armor.stats.armor *= 1.25  # +25% stat bonus
    inventory.append(armor)

    # Add evolving minion pattern
    var pattern = generate_evolving_pattern(character.tier)
    inventory.append(pattern)

    return inventory
```

**Examples:**

**Melee tank character (High Max HP + Armor):**
```
Atomic Vending Machine offers:
- Tier 4 Heavy Blade (+100 Melee Damage, +30 Armor)
- Tier 4 Tank Armor (+150 Max HP, +50 Armor)
- Evolving T3 Tank Minion Pattern
```

**Ranged glass cannon (High Ranged Damage + Attack Speed):**
```
Atomic Vending Machine offers:
- Tier 4 Sniper Rifle (+120 Ranged Damage, +35% Crit Chance)
- Tier 4 Speed Boots (+25% Attack Speed, +15% Dodge)
- Evolving T3 DPS Minion Pattern
```

---

### Minion Patterns (Atomic Vending Machine)

**What you get:**
- **Evolving minion pattern** (stats improve with each craft)
- Unlimited crafts (no degradation like generic patterns)
- Higher base stats than generic patterns
- Transferable via Quantum Storage

**Evolving pattern mechanics:**

```gdscript
# Evolving pattern progression
func craft_evolving_minion(pattern_id: String) -> Minion:
    var pattern = PatternLibrary.get_pattern(pattern_id)
    var crafts_used = PatternLibrary.get_evolving_crafts_used(character_id, pattern_id)

    # Stats improve with each craft (60% → 100% → 100%+bonuses)
    var stat_multiplier = 0.60 + (min(crafts_used, 4) * 0.10)  # Caps at 1.0

    # After 5 crafts, add random bonuses
    if crafts_used >= 5:
        stat_multiplier = 1.0 + randf_range(0.05, 0.20)  # +5% to +20% bonus

    var minion = MinionFactory.create_from_pattern(pattern, stat_multiplier)

    # Costs (same as generic)
    BankingService.spend_scrap(50)
    LabService.spend_nanites(25)

    PatternLibrary.increment_evolving_crafts(character_id, pattern_id)
    return minion

# Example progression:
# Craft 1: 60% stats (weak, learning the pattern)
# Craft 2: 70% stats
# Craft 3: 80% stats
# Craft 4: 90% stats
# Craft 5: 100% stats (baseline)
# Craft 6+: 105-120% stats (random bonuses)
```

**Why patterns instead of minions:**
- ✅ Cheaper than Black Market (200-1,500 vs 500-4,000)
- ✅ Evolving mechanics (gets better with use)
- ✅ Unlimited crafts (no 5-craft limit like generic)
- ❌ Requires Lab + Nanites to craft
- ❌ Takes time to reach full power

---

### Atomic Vending Machine UI

```
[Atomic Vending Machine]

⚛️ Subscription Exclusive - Personalized for You ⚛️

💰 Carried Scrap: 5,420
🏦 Banked Scrap: 42,850 [Withdraw →]

Next refresh: 18h 45m
Free reroll available: 1/1 per day

Personalized Inventory (3):
┌────────────────────────────────────┐
│ ⭐ Tier 4 Heavy Blade (FOR YOU)    │
│ +100 Melee Damage (+25% bonus)    │
│ +30 Armor                          │
│ Matches your tank build!           │
│                                    │
│ Price: 5,500 scrap                 │
│ [Purchase]                         │
├────────────────────────────────────┤
│ ⭐ Tier 4 Tank Armor (FOR YOU)     │
│ +150 Max HP (+25% bonus)           │
│ +50 Armor                          │
│ Perfect for your high-HP build!    │
│                                    │
│ Price: 4,800 scrap                 │
│ [Purchase]                         │
├────────────────────────────────────┤
│ 📜 Evolving T3 Tank Minion Pattern │
│ Starts at 60%, evolves to 120%+   │
│ Unlimited crafts, no degradation   │
│ Craft cost: 50 scrap + 25 Nanites  │
│                                    │
│ Price: 800 scrap                   │
│ [Purchase Pattern]                 │
└────────────────────────────────────┘

⚛️ Items personalized for [Character Name]
   Build detected: Melee Tank (Max HP + Armor focus)

[Free Daily Reroll Available]
```

---

## Tier Comparison

### Shop Access Matrix

| Feature | Free | Premium | Subscription |
|---------|------|---------|--------------|
| Standard Shop | ✅ | ✅ | ✅ |
| Black Market | ❌ | ✅ | ✅ |
| Atomic Vending Machine | ❌ | ❌ | ✅ |
| Reroll discount | 0% | 25% | 50% |
| Better drop rates | - | +Better | +Best |
| Personalized items | ❌ | ❌ | ✅ |
| Buy minions | ❌ | ✅ (fully-formed) | ✅ (patterns) |

---

### Shop Pricing Comparison

**Tier 4 Weapon acquisition costs:**

| Method | Cost | Notes |
|--------|------|-------|
| Standard Shop | 1,500-3,000 scrap | Random stats, Free tier access |
| Black Market | 3,000-5,000 scrap | High stats, Premium tier |
| Atomic Vending Machine | 4,500-7,000 scrap | **+25% personalized stats**, Subscription |
| Workshop (Personalized) | 200 scrap + 100 components | **Up to +310% stats**, Subscription, requires blueprint |

**Tier 3 Minion acquisition costs:**

| Method | Cost | Notes |
|--------|------|-------|
| Black Market | 2,000 scrap | Fully-formed, instant, Premium tier |
| Atomic Vending Machine (pattern) | 800 scrap | Evolving pattern, unlimited crafts, Subscription |
| Lab (generic craft) | 50 scrap + 25 Nanites | Degrading (5 crafts max), Subscription |
| Lab (personalized craft) | 400 scrap + 100 Nanites | **+310% max stats**, soul-bound, Subscription |

---

## Strategic Shop Usage

### For Free Players

**Standard Shop only:**
- Save scrap for T3-T4 items (patience required)
- Reroll sparingly (expensive, 50 → 100 → 200)
- Focus on blueprint drops from combat (free crafting alternative)

---

### For Premium Players

**Standard Shop + Black Market:**
- Use Standard Shop for consumables/budget items
- Use Black Market for high-tier weapons + **minions**
- Buy minions outright (instant gratification)
- 25% reroll discount helps churn inventory faster

**Black Market value proposition:**
- ✅ Instant minions (no Nanite farming)
- ✅ Curated high-tier items
- ❌ Expensive (10x Lab costs)
- ❌ No personalization

---

### For Subscription Players

**Standard Shop + Black Market + Atomic Vending Machine:**
- Use Standard Shop for consumables only
- Use Black Market if desperate for instant minion (expensive fallback)
- **Primary shop: Atomic Vending Machine** (personalized items + evolving patterns)
- Free daily reroll on Atomic Vending Machine
- 50% reroll discount on Standard/Black Market

**Atomic Vending Machine value proposition:**
- ✅ +25% stat bonus on items (vs Standard Shop)
- ✅ Build-matched items (no wasted purchases)
- ✅ Evolving patterns (unlimited, improving crafts)
- ✅ Cheaper than Black Market minions
- ✅ Free daily reroll

**Optimal Subscription strategy:**
1. Check Atomic Vending Machine daily (free reroll)
2. Buy personalized items + evolving patterns
3. Craft minions from patterns in The Lab (cheap + personalized)
4. Use Standard/Black Market only for emergency purchases

---

## Technical Implementation

### Shop Service Architecture

```gdscript
# ShopService.gd
extends Node

# Shop state management
var standard_shop_inventory: Array[Item] = []
var black_market_inventory: Array[Item] = []
var atomic_vending_inventory: Array[Item] = []

var last_standard_refresh: int = 0  # Unix timestamp
var last_black_market_refresh: int = 0
var last_atomic_refresh: int = 0

var rerolls_today: int = 0

# Standard Shop (All tiers)
func refresh_standard_shop() -> void:
    var current_time = Time.get_unix_time_from_system()

    # Check if 4 hours passed
    if current_time - last_standard_refresh < 14400:  # 4 hours in seconds
        return

    # Generate 6 random items
    standard_shop_inventory = []
    for i in range(6):
        var tier = get_weighted_random_tier(PlayerService.get_tier())
        var item = ItemFactory.create_random_item(tier)
        standard_shop_inventory.append(item)

    last_standard_refresh = current_time
    rerolls_today = 0
    GameLogger.info("Standard Shop refreshed")

func get_weighted_random_tier(player_tier: String) -> int:
    var rand = randf()
    match player_tier:
        "free":
            if rand < 0.50: return 1
            if rand < 0.85: return 2
            if rand < 0.98: return 3
            return 4
        "premium":
            if rand < 0.40: return 1
            if rand < 0.75: return 2
            if rand < 0.95: return 3
            return 4
        "subscription":
            if rand < 0.30: return 1
            if rand < 0.60: return 2
            if rand < 0.90: return 3
            return 4
    return 1

# Black Market (Premium+)
func refresh_black_market() -> void:
    if PlayerService.get_tier() == "free":
        return

    var current_time = Time.get_unix_time_from_system()

    # Check if 8 hours passed
    if current_time - last_black_market_refresh < 28800:  # 8 hours
        return

    # Generate 3-4 items (mostly T3-T4)
    black_market_inventory = []
    var item_count = randi() % 2 + 3  # 3 or 4 items

    for i in range(item_count):
        # 70% T3, 30% T4
        var tier = 3 if randf() < 0.70 else 4
        var item = ItemFactory.create_random_item(tier)
        black_market_inventory.append(item)

    # Add 1-2 minions
    var minion_count = randi() % 2 + 1  # 1 or 2 minions
    for i in range(minion_count):
        var minion_tier = randi() % 4 + 1  # T1-T4
        var minion = MinionFactory.create_random_minion(minion_tier)
        black_market_inventory.append(minion)

    last_black_market_refresh = current_time
    GameLogger.info("Black Market refreshed")

# Atomic Vending Machine (Subscription)
func refresh_atomic_vending_machine(character: Character) -> void:
    if PlayerService.get_tier() != "subscription":
        return

    var current_time = Time.get_unix_time_from_system()

    # Check if 24 hours passed
    if current_time - last_atomic_refresh < 86400:  # 24 hours
        return

    # Generate personalized inventory
    atomic_vending_inventory = []

    # Personalized weapon
    var weapon = generate_personalized_weapon(character)
    atomic_vending_inventory.append(weapon)

    # Personalized armor
    var armor = generate_personalized_armor(character)
    atomic_vending_inventory.append(armor)

    # Evolving minion pattern
    var pattern = generate_evolving_pattern(character)
    atomic_vending_inventory.append(pattern)

    last_atomic_refresh = current_time
    GameLogger.info("Atomic Vending Machine refreshed for %s" % character.name)

func generate_personalized_weapon(character: Character) -> Item:
    # Analyze character build
    var primary_damage = character.get_highest_damage_stat()  # Melee/Ranged/Elemental
    var tier = 4  # Always T4 for Atomic Vending Machine

    # Create weapon matching build
    var weapon = ItemFactory.create_weapon_for_damage_type(primary_damage, tier)

    # Apply +25% personalization bonus
    for stat in weapon.stats:
        if typeof(weapon.stats[stat]) in [TYPE_INT, TYPE_FLOAT]:
            weapon.stats[stat] = int(weapon.stats[stat] * 1.25)

    return weapon

func generate_evolving_pattern(character: Character) -> MinionPattern:
    var tier = randi() % 2 + 3  # T3 or T4
    var pattern = MinionPatternFactory.create_evolving_pattern(tier)
    return pattern
```

---

## Balancing Considerations

### Standard Shop Balance

**Why 4-hour refresh:**
- Encourages multiple daily check-ins
- Not too fast (prevents inventory spam)
- Not too slow (players have options)

**Why escalating reroll costs:**
- Prevents excessive rerolling (maintains scarcity)
- Creates strategic decision (reroll or save scrap?)
- Resets every 4 hours (fresh start)

---

### Black Market Balance

**Why 8-hour refresh:**
- Slower than Standard Shop (premium curated experience)
- Encourages patience (don't impulse buy)
- Rare inventory = higher value perception

**Why minions cost 2-4k scrap:**
- 10x more expensive than Lab crafting (500 scrap vs 50 scrap + 25 Nanites)
- **Trade-off:** Instant gratification vs long-term value
- Premium players don't have access to Lab crafting (fair pricing)

---

### Atomic Vending Machine Balance

**Why 24-hour refresh:**
- Personalization takes time (thematic)
- Daily ritual (log in once per day)
- Free reroll available (Subscription perk)

**Why personalized items cost more:**
- +25% stat bonus = +30% price
- Build-matched = guaranteed value (no wasted purchases)
- Subscription-exclusive = premium pricing justified

**Why patterns instead of minions:**
- Differentiates from Black Market (Premium buys minions, Subscription crafts)
- Encourages Lab engagement (use Nanites, level Biotech skill)
- Long-term value (evolving patterns > one-time minion)

---

## Analytics Tracking

### Key Metrics

**Standard Shop:**
- Shop refresh rate (% players checking shop daily)
- Reroll frequency (average rerolls per day)
- Purchase rate by tier (T1/T2/T3/T4 distribution)
- Average scrap spent per day

**Black Market:**
- Unlock rate (% Premium players visiting Black Market)
- Minion purchase rate (% purchases that are minions vs items)
- Price sensitivity (purchase rate by price tier)
- Comparison to Lab crafting (Premium players who upgrade to Subscription)

**Atomic Vending Machine:**
- Daily check-in rate (% Subscription players visiting daily)
- Free reroll usage (% using free daily reroll)
- Personalization satisfaction (do players buy personalized items more often?)
- Pattern vs item purchase ratio

---

## Summary

The Shops System provides:
- ✅ **Three distinct shopping experiences** (Standard, Black Market, Atomic Vending Machine)
- ✅ **Tier differentiation** (each tier has unique shop access)
- ✅ **Strategic depth** (rerolls, refresh timers, pricing trade-offs)
- ✅ **Minion acquisition paths** (Black Market instant, Atomic patterns, Lab crafting)
- ✅ **Personalization** (Atomic Vending Machine tailored to character build)
- ✅ **Clear CTAs** (Black Market for Premium, Atomic for Subscription)

**Shops are a core monetization driver** and provide compelling reasons to upgrade tiers beyond just content access.

---

## References

- [THE-LAB-SYSTEM.md](./THE-LAB-SYSTEM.md) - Minion crafting, pattern system, Nanites
- [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) - Blueprint crafting, personalization
- [BANKING-SYSTEM.md](./BANKING-SYSTEM.md) - Scrap management
- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Atomic Vending Machine, Quantum Storage
