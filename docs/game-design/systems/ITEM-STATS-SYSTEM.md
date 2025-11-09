# Item Stats System

**Status:** Draft - Based on Brotato Comparison
**Date:** 2025-01-09
**Purpose:** Define item rarity tiers, stat bonuses, tags, and cross-reference to Brotato

---

## Overview

Items in Scrap Survivor are **auto-active** (no equip/unequip). All items in your inventory automatically apply their stat bonuses. This matches Brotato's system.

**Key Differences from Brotato:**
- 🟢 **Durability system** (Brotato has none) - see [Decision: Friction with Escape Hatches](../../RECOMMENDATIONS-SUMMARY.md)
- 🟢 **Storage Locker** (Brotato has none) - protect items from death penalties
- 🟢 **Radioactivity** (Brotato has none) - irradiate items for boosted stats

---

## Item Rarity Tiers

### Tier 1: Common (Gray)
**Characteristics:**
- Weak stat bonuses (+1 to +3 per stat)
- No drawbacks
- High drop rate (60% of drops)
- Low price (15-30 scrap)

**Brotato comparison:**
✅ Matches Brotato Tier 1
✅ ~60 items in this tier

**Example Tier 1 Items:**
```json
{
    "name": "Bandage",
    "tier": 1,
    "price": 20,
    "stats": {
        "hp_regen": 1
    },
    "tags": ["HP Regeneration"]
}

{
    "name": "Rusty Knife",
    "tier": 1,
    "price": 25,
    "stats": {
        "melee_damage": 2
    },
    "tags": ["Melee Damage"]
}

{
    "name": "Lucky Coin",
    "tier": 1,
    "price": 30,
    "stats": {
        "luck": 5
    },
    "tags": ["Luck"]
}
```

---

### Tier 2: Uncommon (Green)
**Characteristics:**
- Moderate stat bonuses (+3 to +8 per stat)
- Occasional minor drawbacks (-1 to -2 on one stat)
- Medium drop rate (30% of drops)
- Medium price (30-65 scrap)

**Brotato comparison:**
✅ Matches Brotato Tier 2
✅ ~55 items in this tier

**Example Tier 2 Items:**
```json
{
    "name": "Regeneration Potion",
    "tier": 2,
    "price": 45,
    "stats": {
        "hp_regen": 3,
        "max_hp": -5
    },
    "tags": ["HP Regeneration"],
    "drawback": "Small HP penalty"
}

{
    "name": "Sharpening Stone",
    "tier": 2,
    "price": 50,
    "stats": {
        "melee_damage": 5,
        "attack_speed": -3
    },
    "tags": ["Melee Damage"],
    "drawback": "Slower attacks"
}

{
    "name": "Incendiary Turret",
    "tier": 2,
    "price": 60,
    "stats": {
        "engineering": 4
    },
    "special": "Spawns turret, 8x5 (+33%) burning DMG",
    "tags": ["Structure", "Engineering"]
}
```

---

### Tier 3: Rare (Blue)
**Characteristics:**
- Strong stat bonuses (+8 to +15 per stat)
- Significant drawbacks (-3 to -6 on 1-2 stats)
- Low drop rate (8% of drops)
- High price (50-92 scrap)
- **Some 1-limit items** (can only buy once per run)

**Brotato comparison:**
✅ Matches Brotato Tier 3
✅ ~45 items in this tier

**Example Tier 3 Items:**
```json
{
    "name": "Glass Cannon",
    "tier": 3,
    "price": 75,
    "stats": {
        "damage": 25,  // +25% damage
        "armor": -3
    },
    "tags": ["Damage"],
    "drawback": "Fragile (-3 Armor)"
}

{
    "name": "Stone Skin",
    "tier": 3,
    "price": 70,
    "stats": {
        "max_hp_per_armor": 1,  // +1 Max HP per Armor point
        "attack_speed": -6
    },
    "tags": ["Max HP", "Armor"],
    "drawback": "Very slow attacks"
}

{
    "name": "Handcuffs",
    "tier": 3,
    "price": 80,
    "limit": 1,  // Can only buy once
    "stats": {
        "melee_damage": 8,
        "ranged_damage": 8,
        "elemental_damage": 8
    },
    "special": "Caps Max HP at current value",
    "tags": ["Damage", "Melee Damage", "Ranged Damage", "Elemental Damage"]
}

{
    "name": "Laser Turret",
    "tier": 3,
    "price": 85,
    "stats": {
        "engineering": 8
    },
    "special": "Spawns turret, 20 (+125%) piercing DMG",
    "tags": ["Structure", "Engineering"]
}
```

---

### Tier 4: Legendary (Purple/Gold)
**Characteristics:**
- Extremely powerful (+15 to +30 per stat, or unique effects)
- Major drawbacks or restrictions
- Very low drop rate (2% of drops)
- Very high price (90-130 scrap)
- **Mostly 1-limit items**

**Brotato comparison:**
✅ Matches Brotato Tier 4
✅ ~17 items in this tier

**Example Tier 4 Items:**
```json
{
    "name": "Spider",
    "tier": 4,
    "price": 110,
    "stats": {
        "damage": 12,          // +12% per weapon
        "attack_speed": 6,     // +6% per weapon
        "dodge": -3,
        "harvesting": -5
    },
    "special": "Bonuses scale per different weapon equipped",
    "tags": ["Damage", "Attack Speed"],
    "unlock": "Win a run with Gladiator"
}

{
    "name": "Cape",
    "tier": 4,
    "price": 120,
    "limit": 1,
    "stats": {
        "life_steal": 5,       // +5%
        "dodge": 20,           // +20%
        "damage": -2,
        "melee_damage": -2,
        "ranged_damage": -2,
        "elemental_damage": -2
    },
    "tags": ["Life Steal", "Dodge"],
    "drawback": "All damage types reduced"
}

{
    "name": "Regeneration Potion",
    "tier": 4,
    "price": 115,
    "limit": 1,
    "stats": {
        "hp_regen": 3
    },
    "special": "HP Regen doubled when below 50% HP",
    "tags": ["HP Regeneration"]
}

{
    "name": "Focus",
    "tier": 4,
    "price": 125,
    "limit": 1,
    "stats": {
        "damage": 30,
        "attack_speed_penalty_per_weapon": -3
    },
    "special": "-3% Attack Speed per weapon",
    "tags": ["Damage"],
    "unlock": "Win a run with One Armed",
    "synergy": "Best with 1-2 weapons (One Armed character)"
}

{
    "name": "Explosive Turret",
    "tier": 4,
    "price": 130,
    "stats": {
        "engineering": 12
    },
    "special": "Spawns turret, 25 (+150%) explosive DMG",
    "tags": ["Structure", "Engineering", "Explosive"]
}

{
    "name": "Axolotl",
    "tier": 4,
    "price": 110,
    "limit": 1,
    "stats": {},
    "special": "Swaps highest and lowest positive stat",
    "tags": ["Unique"],
    "example": "100 Melee DMG + 5 Luck → 5 Melee DMG + 100 Luck"
}
```

---

## Item Tags System

### What Are Item Tags?

**Purpose:**
- Categorize items by stat focus
- Characters with matching tags get **5% higher shop selection chance**
- Help players find build-relevant items

**Brotato comparison:**
✅ Identical mechanic (23 tags)
✅ Same 5% shop selection bonus

---

### Primary Stat Tags (15 tags)

Characters with these tags see more tagged items in shops:

| Tag | Stat Focus | Example Items | Characters |
|-----|------------|---------------|------------|
| **Max HP** | +Max HP | Health Amulet, Fortified Armor | Bruiser, Tank, Golem |
| **HP Regeneration** | +HP Regen | Bandage, Healing Trinket | Doctor, Paladin |
| **Life Steal** | +Life Steal% | Vampiric Ring, Blood Amulet | Vampire, Sick |
| **Damage** | +General DMG | Power Glove, Glass Cannon | One Armed, Berserker |
| **Melee Damage** | +Melee DMG | Sharpening Stone, Strength Potion | Brawler, Gladiator, Knight |
| **Ranged Damage** | +Ranged DMG | Scope, Ammo Belt | Ranger, Hunter, Sniper |
| **Elemental Damage** | +Elemental DMG | Flame Orb, Lightning Rod | Mage, Pyromancer |
| **Attack Speed** | +Attack Speed% | Adrenaline Shot, Caffeine | Speedster, Assassin |
| **Crit Chance** | +Crit Chance% | Lucky Blade, Critical Eye | Hunter, Assassin |
| **Engineering** | +Engineering | Wrench, Turret Parts | Engineer, Technomage, Builder |
| **Range** | +Range | Long Barrel, Telescope | Ranger, Hunter, Sniper |
| **Armor** | +Armor | Reinforced Plate, Shield | Tank, Knight, Paladin |
| **Dodge** | +Dodge% | Evasion Cloak, Feather Boots | Ghost, Speedster, Rogue |
| **Speed** | +Movement Speed | Speed Boots, Caffeine | Speedster, Scout, Runner |
| **Luck** | +Luck | Four-Leaf Clover, Lucky Coin | Lucky, Gambler, Scavenger |
| **Harvesting** | +Harvesting% | Scrap Magnet, Collector's Bag | Farmer, Saver, Entrepreneur |

---

### Secondary Mechanic Tags (8 tags)

These tags describe special mechanics:

| Tag | Mechanic | Example Items | Characters |
|-----|----------|---------------|------------|
| **Consumable** | Boosts fruit/consumable effects | Fruit Basket, Vitamin C | Druid, Glutton, Farmer |
| **Economy** | Shop discounts, recycling bonuses | Coupon, Recycler's Toolkit | Entrepreneur, Saver |
| **Exploration** | Tree spawning, map size | Explorer's Map, Compass | Explorer, Scout, Cryptid |
| **Explosive** | Explosion size/damage | Dynamite, Blast Radius | Artificer, Demolitionist, Glutton |
| **Pickup** | Pickup range, attraction | Magnet, Vacuum | Lucky, Buccaneer, Hoarder |
| **Stand Still** | Bonuses while not moving | Anchor, Meditation Stone | Soldier, Turret Master |
| **Structure** | Turret/minion bonuses | Turret Parts, Minion Collar | Engineer, Technomage, Builder |
| **XP Gain** | Experience multiplier | XP Boost, Study Guide | Baby, Captain, Apprentice |

---

### Shop Selection Bonus (5% Mechanic)

**How it works:**
```gdscript
# ShopService - Item selection
func select_shop_items(character: Character) -> Array[Item]:
    var shop_items = []

    for i in 3:  # 3 items per shop
        if randf() < 0.05 and character.item_tags.size() > 0:
            # 5% chance: Select from character's tagged items
            var tag = character.item_tags.pick_random()
            var tagged_items = get_items_by_tag(tag)
            shop_items.append(tagged_items.pick_random())
        else:
            # 95% chance: Select from all items (weighted by tier)
            shop_items.append(get_random_item_by_tier())

    return shop_items
```

**Example:**
- **Character:** Bruiser (tags: "Melee Damage", "Max HP")
- **Shop:** 3 items
- **Expected:**
  - Item 1: 5% chance Melee Damage item, 95% random
  - Item 2: 5% chance Max HP item, 95% random
  - Item 3: 5% chance Melee/HP item, 95% random

**Result:** ~10-15% better chance of seeing build-relevant items over 20 shops

---

## Item Limits (1-Limit System)

### What Are 1-Limit Items?

**Definition:** Items that can only be purchased **once per run**

**Why 1-limit?**
- Prevents overpowered stacking (e.g., 6x Glass Cannon = broken)
- Creates build diversity (can't just stack one item)
- Balances high-power items

**Brotato comparison:**
✅ Identical mechanic
✅ Mostly Tier 3-4 items

---

### 1-Limit Item Examples

**Tier 3 (1-Limit):**
- Handcuffs (+8 to all damage types, caps Max HP)
- Nail (+5 Engineering, weapons scale 20% with Engineering)
- Frozen Heart (+8 Elemental DMG, weapons scale 10% with Elemental)

**Tier 4 (1-Limit):**
- Focus (+30% Damage, -3% Attack Speed per weapon) - Best for 1-2 weapons
- Cape (+5% Life Steal, +20% Dodge, -2 to all damage types)
- Regeneration Potion (+3 HP Regen, doubled below 50% HP)
- Axolotl (swaps highest/lowest stat)

**Implementation:**
```gdscript
# Item tracking per run
var purchased_items: Dictionary = {}  # item_name → count

func can_purchase_item(item: Item) -> bool:
    if item.limit == null:
        return true  # No limit

    var count = purchased_items.get(item.name, 0)
    return count < item.limit

func purchase_item(item: Item):
    if not can_purchase_item(item):
        return false

    purchased_items[item.name] = purchased_items.get(item.name, 0) + 1
    # Add item to inventory...
    return true
```

---

## Item Synergies

### Synergy Categories

#### 1. Stat Multiplication Synergies

**Example:** Stone Skin + Armor Items
```
Stone Skin: +1 Max HP per Armor point
Heavy Armor: +15 Armor
Result: +15 Max HP (exponential HP scaling)

Ideal Build:
- Stone Skin (Tier 3)
- 5x Armor items (+50 Armor total)
- Result: +50 Max HP from Stone Skin alone
- Character: Knight (+2 Melee per Armor)
```

---

#### 2. Weapon Scaling Synergies

**Example:** Focus + One Armed Character
```
Focus: +30% Damage, -3% Attack Speed per weapon
One Armed: Can only hold 1 weapon, +200% Attack Speed

Result:
- 1 weapon = -3% Attack Speed (negligible with +200% base)
- +30% Damage (full benefit, no downside)

Ideal Build:
- Focus (Tier 4)
- One Armed character
- High-damage single weapon
```

---

#### 3. Engineering Synergies

**Example:** Nail + Engineering Items + Technomage
```
Nail: +5 Engineering, weapons scale 20% with Engineering
Engineering Items: +20 Engineering total
Technomage: Starts with 2 turrets, 5% structure attack speed per Elemental

Result:
- 25 Engineering total
- Weapons gain +5 damage (20% of 25 Engineering)
- Turrets gain +125% attack speed (5% × 25)

Ideal Build:
- Nail (Tier 3)
- 3-4 Engineering items
- Technomage character
- Tool weapons (Wrench, Screwdriver)
```

---

#### 4. Curse Synergies (High Risk)

**Example:** Creature + Curse Items
```
Creature: Weapon DMG scales 35% with Curse
Fish Hook: +1 Curse on pickup
Black Flag: +5 Curse, +10% Enemies

Result:
- 10 Curse total
- +3.5 damage per weapon (35% of 10 Curse)
- BUT: +10% enemies, +5% damage taken

Ideal Build:
- Creature character
- Curse items (Fish Hook, Black Flag, Cursed Amulet)
- High Luck (mitigate negative effects)
```

---

#### 5. Glass Cannon Synergies

**Example:** Glass Cannon + Spider + Crit Items
```
Glass Cannon: +25% Damage, -3 Armor
Spider: +12% Damage + 6% Attack Speed per weapon
Crit Items: +30% Crit Chance

Result:
- 6 weapons = +72% Damage, +36% Attack Speed
- +25% Damage from Glass Cannon
- High crit chance = massive burst
- BUT: -3 Armor = very fragile

Ideal Build:
- Glass Cannon (Tier 3)
- Spider (Tier 4)
- 6 different weapons
- Crit-focused items
- Dodge items (avoid damage, can't tank)
```

---

## Item Pricing by Tier

### Base Prices

| Tier | Price Range | Average | Drop Rate |
|------|-------------|---------|-----------|
| Tier 1 (Common) | 15-30 scrap | 22 scrap | 60% |
| Tier 2 (Uncommon) | 30-65 scrap | 47 scrap | 30% |
| Tier 3 (Rare) | 50-92 scrap | 71 scrap | 8% |
| Tier 4 (Legendary) | 90-130 scrap | 110 scrap | 2% |

**Brotato comparison:**
✅ Similar pricing structure
✅ Same drop rate distribution

---

### Price Modifiers

**Character modifiers:**
- Entrepreneur: -25% prices (Tier 1 = 11-23 scrap)
- Mutant: +50% prices (Tier 1 = 23-45 scrap)
- Arms Dealer: -95% weapon prices (weapons only)

**Tier modifiers:**
- Free tier: Standard prices
- Premium tier: Black Market access (gambling prices)
- Subscription tier: 10% discount on all Black Market purchases

**Shop reroll cost:**
- Standard: 10 scrap per reroll
- Items can reduce reroll cost (Reroll Token: -5 scrap)

---

## Item Drops vs. Shop

### Drop System (During Waves)

**Drop sources:**
- Enemy kills: 5% chance per enemy
- Crates: 20% chance from trees (Luck increases)
- Boss kills: Guaranteed Tier 3-4 drop
- Elite enemies: 50% chance Tier 3-4 drop

**Drop tier weights:**
```gdscript
const DROP_WEIGHTS = {
    1: 0.60,  # 60% Tier 1
    2: 0.30,  # 30% Tier 2
    3: 0.08,  # 8% Tier 3
    4: 0.02   # 2% Tier 4
}

# Luck modifies Tier 3-4 chances
func get_drop_tier(luck: int) -> int:
    var tier_4_chance = 0.02 + (luck * 0.0002)  # +0.02% per Luck
    var tier_3_chance = 0.08 + (luck * 0.0005)  # +0.05% per Luck

    var roll = randf()
    if roll < tier_4_chance:
        return 4
    elif roll < tier_4_chance + tier_3_chance:
        return 3
    elif roll < 0.40:
        return 2
    else:
        return 1
```

---

### Shop System (Between Waves)

**Shop inventory:**
- 3 items per shop
- 5% chance of character-tagged item
- Tier weights same as drops
- Reroll cost: 10 scrap

**Shop guarantees:**
- Wave 5: At least 1 Tier 2 item
- Wave 10: At least 1 Tier 3 item
- Wave 15: At least 1 Tier 3 item
- Wave 20: At least 1 Tier 4 item (boss shop)

**Lock system:**
- Cost: 5 scrap per item locked
- Locked items persist through rerolls
- Use case: Found Tier 4 item but not enough scrap → lock it, farm more scrap next wave

---

## Item Content Target

### Launch Target (Wave 1)

**Based on Brotato comparison:**

| Tier | Brotato | Our Target | % of Brotato |
|------|---------|------------|--------------|
| Tier 1 | ~60 | 40 | 67% |
| Tier 2 | ~55 | 35 | 64% |
| Tier 3 | ~45 | 20 | 44% |
| Tier 4 | ~17 | 10 | 59% |
| **Total** | **177** | **105** | **59%** |

**Rationale:**
- 105 items at launch = 59% of Brotato's 177
- Enough variety for build diversity
- Achievable for solo dev in 3 months
- Can add 20-30 items per major update

---

### Post-Launch Roadmap

**6 months:**
- Target: 130-150 items (73-85% of Brotato)
- Add 5-10 items per month

**12 months:**
- Target: 170-200 items (96-113% of Brotato)
- Potentially exceed Brotato's count with unique items

**Unique items (Scrap Survivor only):**
- Radioactivity-boosting items
- Minion-specific items (Brotato has structure items, not minion items)
- Durability-reduction items (Premium/Subscription perks)

---

## Special Item Categories

### Structure Items (Brotato Equivalent: Turrets)

**Our equivalent: Minion-Boosting Items**

**Examples:**
```json
{
    "name": "Minion Collar",
    "tier": 2,
    "price": 50,
    "stats": {
        "engineering": 5
    },
    "special": "Active minions gain +10% attack speed",
    "tags": ["Engineering", "Structure"]
}

{
    "name": "Minion Training Manual",
    "tier": 3,
    "price": 75,
    "stats": {
        "engineering": 8
    },
    "special": "Active minions gain +1 level",
    "tags": ["Engineering", "Structure"]
}
```

---

### Radioactive Items (Unique to Scrap Survivor)

**Examples:**
```json
{
    "name": "Uranium Core",
    "tier": 3,
    "price": 80,
    "stats": {
        "damage": 20,
        "radioactivity": 25
    },
    "special": "High damage, but adds radioactivity",
    "tags": ["Damage"]
}

{
    "name": "Geiger Counter",
    "tier": 2,
    "price": 45,
    "stats": {
        "radioactivity": -10
    },
    "special": "Reduces radioactivity by 10",
    "tags": ["Utility"]
}
```

---

### Cursed Items (Brotato DLC Feature)

**Examples:**
```json
{
    "name": "Fish Hook",
    "tier": 2,
    "price": 40,
    "stats": {
        "curse": 1
    },
    "special": "Locked shop items become cursed (20% chance)",
    "tags": ["Curse"]
}

{
    "name": "Cursed Amulet",
    "tier": 3,
    "price": 70,
    "stats": {
        "curse": 5,
        "damage": 15
    },
    "special": "+5 Curse, +15% Damage",
    "tags": ["Curse", "Damage"]
}
```

---

## Item Storage Locker Integration

### How Storage Affects Items

**Items in Inventory:**
- ✅ Auto-active (stats applied)
- ⚠️ Lose durability on death (10%/5%/2% by tier)
- ⚠️ Cost scrap to repair

**Items in Storage Locker:**
- ❌ Not active (stats NOT applied)
- ✅ Protected from durability loss
- ✅ Can't be accidentally recycled
- 💰 Cost 10 scrap to store, 10 scrap to retrieve

**Strategic Trade-off:**
```
Keep Tier 4 item equipped:
  - Active stats (+30% damage)
  - Risk: Lose 10% durability on death (100 scrap repair)

Store Tier 4 item:
  - No stats
  - Protected from death
  - Cost: 20 scrap total (store + retrieve later)
```

**When to store:**
- Found item that doesn't fit current build (save for next character)
- Protecting valuable Tier 4 items from death penalties
- Experimenting with builds (swap items in/out)

---

## Workshop Components & Items

### What Are Workshop Components?

**Definition:** Secondary currency earned by recycling items

**Sources:**
- Recycle Tier 1 item: 5 components
- Recycle Tier 2 item: 10 components
- Recycle Tier 3 item: 20 components
- Recycle Tier 4 item: 40 components

**Uses:**
- Repair items (1 component = 10% durability)
- Craft items (varies by blueprint)

**Banking:**
- Can be banked (protected from death)
- Free: 500 components max
- Premium: 2,000 components max
- Subscription: Unlimited

---

## Next Steps

1. **Create 105 Item Definitions:**
   - 40 Tier 1 items
   - 35 Tier 2 items
   - 20 Tier 3 items
   - 10 Tier 4 items

2. **Define Item Tags per Character:**
   - Update character definitions with 1-3 tags
   - Implement 5% shop selection bonus

3. **Implement Storage Locker:**
   - See Workshop System update

4. **Create Item Synergy Guide:**
   - Document powerful combos
   - Create build guides

---

## References

- [STAT-SYSTEM.md](./STAT-SYSTEM.md) - Complete stat definitions
- [BROTATO-COMPARISON.md](../../competitive-analysis/BROTATO-COMPARISON.md) - Brotato's 177 items
- [brotato-reference.md](../../brotato-reference.md) - Item data dictionary
- [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) - Workshop services (Recycler, Storage Locker)
- [INVENTORY-SYSTEM.md](./INVENTORY-SYSTEM.md) - Auto-active inventory mechanics
