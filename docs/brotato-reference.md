# Brotato Data Dictionary

**Version:** 1.1.10.9 (DLC Included)  
**Last Updated:** November 2025  
**Source:** [Brotato Wiki](https://brotato.wiki.spellsandguns.com/)

## Overview

This data dictionary provides comprehensive documentation of all game data from Brotato, a top-down arena shooter roguelite. The dictionary is organized for use with AI code assistants and includes complete entity definitions, relationships, and mechanics.

**Game Concept:** Players control a potato wielding up to 6 weapons simultaneously, fighting alien hordes across 20 waves. Build unique strategies using characters, weapons, items, and modifiers to survive and earn high scores.

---

## Table of Contents

1. [Quick Stats](#quick-stats)
2. [Characters](#characters)
3. [Weapons](#weapons)
4. [Items](#items)
5. [Enemies](#enemies)
6. [Game Mechanics](#game-mechanics)
7. [Data Structures](#data-structures)
8. [Relationships](#relationships)

---

## Quick Stats

| Metric | Count |
|--------|-------|
| **Characters** | 62 |
| **Weapons** | 83 (4 tiers each) |
| **Items** | 177 (4 rarity tiers) |
| **Regular Enemies** | 23 (Crash Zone) |
| **Elite Enemies** | 8 |
| **Boss Enemies** | 2 |
| **DLC Enemies** | 21 (The Abyss) |
| **Waves per Run** | 20 |
| **Weapon Classes** | 14 |
| **Item Tags** | 23 |
| **Character Item Tags** | 19 |

---

## Characters

### Character Data Structure

Each character has a unique identity with mechanical modifiers, starting equipment, and item tag affinity.

```json
{
  "name": "string (unique identifier)",
  "stats": "string (stat modifications)",
  "unlocked_by": "string (unlock condition)",
  "unlocks": "string (reward item name)",
  "item_tags": ["string (tag names)", "..."],
  "starting_weapons": ["weapon_name", "..."],
  "starting_items": ["item_name", "..."],
  "is_dlc": "boolean"
}
```

### Default Characters (5)

| Name | Key Stats | Starting Weapon | Item Tags |
|------|-----------|-----------------|-----------|
| Well Rounded | +5 Max HP, +5% Speed, +8 Harvesting | (Choice) | None |
| Brawler | +50% Unarmed Speed, +15% Dodge, -50 Range | Fist | Melee Damage |
| Crazy | +100 Precision Range, +25% Attack Speed, -30% Dodge | Knife | Crit Chance, Melee Damage |
| Ranger | +50 Range, 50% Ranged Mods increased, can't equip melee | Pistol | Ranged Damage, Range |
| Mage | 25% Elemental Mods increased, -100% Melee/Ranged Mods | Snake, Scared Sausage | Elemental Damage |

### Advanced Characters (57)

**Tier 1 Unlock (Kill/Collect/Reach Conditions):**
- **Chunky:** +25% Max HP mods, +1% DMG per 3 Max HP, -100% Life Steal
- **Old:** -25% Enemy Speed, +10 Harvesting, -10% Enemies
- **Lucky:** +100 Luck, +75% chance to deal 1 damage to random enemy on material pickup
- **Mutant:** -66% XP required, +50% Items Price
- **Generalist:** +2 Melee per 1 Ranged DMG, limited to 3 of each weapon type
- **Loud:** +30% Damage, +50% Enemies, -3 Harvesting
- **Multitasker:** +20% Damage, can hold 12 weapons, -5% DMG per weapon
- **Wildling:** +30% Life Steal with Primitive, can't equip tier 3+ weapons
- **Pacifist:** 0.65 material/XP per living enemy at wave end, -100% Damage
- **Gladiator:** +20% Attack Speed per different weapon, can't equip ranged
- **Saver:** +15 Harvesting, +1% DMG per 25 Materials, +50% Items Price
- **Sick:** +12 Max HP, +25% Life Steal, takes 1 DMG/sec
- **Farmer:** +20 Harvesting, Harvesting +3% at wave end
- **Ghost:** +10 DMG with Ethereal, +30% Dodge (capped 90%), -100 Armor
- **Speedy:** +30% Speed, +1 Melee per 2% Speed, -100 Armor standing still

**Tier 2+ Unlock (Specific Conditions):**
- **Entrepreneur:** -25% Items Price, +50% Harvesting mods, 25% more recycle materials
- **Engineer:** +10 Engineering, 25% Engineering mods increased, starts with Wrench
- **Explorer:** More trees, +10% Speed, +50% pickup range, +33% Map Size
- **Doctor:** +200% Attack Speed with Medical, +5 HP Regen, +100% HP Regen mods
- **Hunter:** +100 Range, +1% DMG per 10 Range, 25% Crit mods increased
- **Artificer:** +175% Explosion Damage, 4% explosion size per Elemental DMG
- **Arms Dealer:** -95% Weapons Price, +30 Harvesting, all weapons destroyed in shop
- **Streamer:** +3% materials/sec standing still, +40% DMG/Speed moving
- **Cyborg:** Starts with Minigun, 200% Ranged mods, half-wave Engineering conversion
- **Glutton:** +50 Luck, +1% Explosion DMG on consumable pickup at full HP
- **Jack:** +125% DMG vs bosses/elites, +200% material drops, -70% enemies
- **Lich:** +10 HP Regen, +10% Life Steal, 100% chance 10 DMG to random enemy on heal
- **Apprentice:** +2 Melee/+1 Ranged/+1 Elemental/+1 Engineering per level, -2 Max HP
- **Cryptid:** More trees, 12 material/XP per living tree at wave end, 70% Dodge cap
- **Fisherman:** +5 Max HP, +20 Harvesting, Bait always in shop at -100% price
- **Golem:** +20 Max HP, 33% Max HP/Armor mods, +40% Attack Speed at <50% HP
- **King:** +50 Luck, +25% DMG/Attack Speed per Tier IV weapon
- **Renegade:** +2 projectiles, pierce +1, +10% DMG per Tier I item, no melee
- **One Armed:** +200% Attack Speed, 100% Damage mods increased, 1 weapon only
- **Bull:** +20 Max HP, +15 HP Regen, +10 Armor, explodes on damage hit (no weapons)
- **Soldier:** +50% DMG/Attack Speed standing still, +10% Speed, can't attack moving
- **Masochist:** +5% DMG taken (wave), +10 Max HP, +20 HP Regen, +8 Armor
- **Knight:** +2 Melee per 1 Armor, +3 Armor, no ranged, tier 2+ only
- **Demon:** +50% Materials converted to Max HP (13 Mat = 1 HP), spend Max HP for items
- **Baby:** +12 Harvesting, gain weapon slot per level (max 24), +130% XP required
- **Vagabond:** Weapons contribute to all class bonuses, can't duplicate weapons
- **Technomage:** Starts with 2 turrets, 5% structure attack speed per Elemental
- **Vampire:** +2% DMG per 1% missing HP, +1% Life Steal per 3% missing HP
- **Sailor (DLC):** +200% DMG with Naval on cursed, +25 Curse, tier II+ only
- **Curious (DLC):** Starts with Spyglass, 2 extra loot aliens/wave, stronger on kill
- **Builder (DLC):** Starts with Builder's Turret, uncollected materials convert to structure stats
- **Captain (DLC):** +60% XP per free weapon slot, +100% level stats, +200% XP required
- **Creature (DLC):** Weapon DMG scales 35% with Curse, starts with cursed Fish Hook
- **Chef (DLC):** +35 Luck, +200% non-elemental DMG on burning, consumables explode
- **Druid (DLC):** +5 Max HP, +15 Luck, fruits drop more, 33% poisoned fruits
- **Dwarf (DLC):** +1 Engineering on 6+ direct hits, +1 Melee per 2 Engineering
- **Gangster (DLC):** Steal 1 item/shop, elites stronger on kill, can't lock items
- **Diver (DLC):** Starts with Harpoon Gun, 200% Crit DMG with Precise, 300% target DMG
- **Hiker (DLC):** 5 materials per 10 steps, +1 Max HP per 80 steps, 10% Speed mods
- **Buccaneer (DLC):** Pickups +100% value, material pickup resets weapon cooldowns
- **Ogre (DLC):** Double HP damage explodes, +10 Melee DMG, no ranged, -50% Attack Speed
- **Romantic (DLC):** 5% charm on <25% health hit, +50 Range melee, -3% DMG per 5 Curse

---

## Weapons

### Weapon Data Structure

```json
{
  "name": "string (unique identifier)",
  "type": "enum: Melee | Ranged",
  "classes": ["class_name", "..."],
  "damage": "integer or formula with scaling",
  "attack_speed": "string (seconds or cooldown)",
  "dps": "float (theoretical damage per second)",
  "crit": {
    "multiplier": "float (x1.5, x2, x2.5, etc)",
    "chance": "float (0-100%)"
  },
  "range": "integer (pixels)",
  "knockback": "integer (0+)",
  "lifesteal": "float (0-100%)",
  "scaling": {
    "melee_damage": "float (0-100%)",
    "ranged_damage": "float (0-100%)",
    "elemental_damage": "float (0-100%)",
    "armor": "float (0-100%)",
    "engineering": "float (0-100%)",
    "range": "float (0-100%)",
    "attack_speed": "float (0-100%)",
    "level": "float (0-100%)"
  },
  "special_effects": "string",
  "base_price": "integer (materials)",
  "min_tier": "integer (1-4)",
  "unlocked_by": "string or null",
  "is_dlc": "boolean"
}
```

### Melee Weapon Categories

#### **Class: Blade**
Focus: Life Steal bonuses (+5% at tier 6)  
Example Weapons: Sword, Chopper, Thunder Sword, Captain's Sword, Chainsaw, Excalibur

#### **Class: Blunt**
Focus: Armor & Knockback, -Speed penalty  
Example Weapons: Rock, Brick, Spiky Shield, Spoon, Hammer, War Hammer

#### **Class: Unarmed**
Focus: Dodge bonus (+15% Dodge at tier 6)  
Example Weapons: Fist, Claw, Hand, Flaming Brass Knuckles, Power Fist

#### **Class: Primitive**
Focus: Max HP bonus (+15 HP at tier 6)  
Example Weapons: Stick, Hatchet, Spear, Sharp Tooth, Cacti Club, Rock, Quarterstaff

#### **Class: Precise**
Focus: Crit Chance bonus (+15% Crit at tier 6)  
Example Weapons: Knife, Scissors, Lightning Shiv, Claw, Thief Dagger, Shuriken, Claw

#### **Class: Medieval**
Focus: Armor & Dodge (+3 Armor, 6% Dodge at tier 6)  
Example Weapons: Jousting Lance, Crossbow, Quarterstaff, Spiky Shield, Sword, Mace, Trident

#### **Class: Tool**
Focus: Engineering bonus (+5 Engineering at tier 6)  
Example Weapons: Wrench, Screwdriver, Chainsaw

#### **Class: Elemental**
Focus: Elemental Damage scaling (+5 Elemental at tier 6)  
Example Weapons: Plank, Torch, Wand, Thunder Sword, Taser, Lightning Shiv, Flaming Brass Knuckles

#### **Class: Ethereal**
Focus: Dodge (+30% Dodge at tier 6), -Armor penalty  
Example Weapons: Ghost Axe, Ghost Flint, Ghost Scepter, Scythe

#### **Class: Explosive**
Focus: Explosion Size (+25% at tier 6)  
Example Weapons: Plank, Power Fist, Plasma Sledge, DEX-troyer, Grenade Launcher, Rocket Launcher

#### **Class: Heavy**
Focus: Damage bonus (+25% at tier 6)  
Example Weapons: Cacti Club, Anchor, Hammer, Mace, Rocket Launcher, Obliterator, War Hammer

#### **Class: Support**
Focus: Harvesting bonus (+25% at tier 6)  
Example Weapons: Hand, Hiking Pole, Lute, Pruner, Sickle, Taser, Potato Thrower

#### **Class: Legendary**
Penalty: Max HP reduction (-100 Max HP at tier 6)  
Example Weapons: Chain Gun, DEX-troyer, Drill, Excalibur, Gatling Laser, Scythe

#### **Class: Medical**
Focus: HP Regeneration (+5 HP Regen at tier 6)  
Example Weapons: Medical Gun, Scissors, Circular Saw

### Ranged Weapon Categories

#### **Class: Gun**
Focus: Range bonus (+50 Range at tier 6)  
Example Weapons: Pistol, Revolver, SMG, Laser Gun, Double Barrel Shotgun, Sniper Gun, Minigun

#### Notable Ranged Weapons

- **Pistol (Default):** 12(100%) damage, 1.2s cooldown, 400 range, pierces 1
- **Revolver:** 15(100%) damage, 0.43s cooldown, 450 range, every 6th shot longer cooldown
- **SMG:** 3(50%) damage, 0.17s cooldown (fastest attack speed), 400 range, x1.5 crit
- **Laser Gun:** 40(400%) damage, 1.98s cooldown, 500 range, pierces 1
- **Crossbow:** 10(50%10%) damage, 1.13s cooldown, 350 range, pierces on crit
- **Flamethrower:** Deals burning damage, pierces 99 enemies, 1 damage each
- **Sniper Gun:** Spawns 5-8 projectiles on hit (unlock: Win with Hunter)
- **Nuclear Launcher:** Projectiles explode on hit (unlock: Win with Soldier)

### Melee vs Ranged Mechanics

**Melee Weapons:**
- Hit multiple enemies in area
- Two attack types: Thrust (straight line) and Sweep (wide curve)
- Range stat affects them at 50% effectiveness
- Increasing range slightly reduces attack speed

**Ranged Weapons:**
- Single target per projectile
- Can gain Bounce and Piercing for multi-hit
- If both Pierce and Bounce: pierce after bouncing finishes
- Explosive ranged weapons explode per bounce/pierce

### Weapon Upgrade System

- Same weapon + same tier = upgrade to next tier
- Max tier: 4 (Legendary)
- 4 tiers available for all weapons (minimum tier exceptions exist)
- Character-specific unlocks require winning runs with that character

---

## Items

### Item Data Structure

```json
{
  "name": "string (unique identifier)",
  "rarity_tier": "integer (1-4)",
  "effects": "string (stat modifications and special mechanics)",
  "base_price": "integer (materials to purchase)",
  "item_limit": "integer or null (purchase limit per run)",
  "unlocked_by": "string or null (character/condition)",
  "item_tags": ["tag_name", "..."],
  "scaling_stats": {
    "melee_damage": "boolean",
    "ranged_damage": "boolean",
    "elemental_damage": "boolean",
    "armor": "boolean",
    "engineering": "boolean",
    "range": "boolean",
    "luck": "boolean",
    "max_hp": "boolean"
  },
  "is_dlc": "boolean",
  "special_properties": {
    "has_passive": "boolean",
    "has_active": "boolean",
    "affects_enemies": "boolean",
    "affects_structures": "boolean"
  }
}
```

### Item Rarity Tiers

| Tier | Characteristics | Price Range | Count |
|------|-----------------|-------------|-------|
| **Tier 1** | Common, weak effects, high drop rate | 15-30 | ~60 |
| **Tier 2** | Uncommon, moderate effects | 30-65 | ~55 |
| **Tier 3** | Rare, strong effects, some 1-limit | 50-92 | ~45 |
| **Tier 4** | Legendary, powerful effects, mostly 1-limit | 90-130 | ~17 |

### Item Tag Categories

#### **Stat Tags (Primary)**
Characters with matching tags have 5% chance to find tagged items in shops/crates.

| Tag | Characters | Related Stats |
|-----|-----------|---------------|
| Max HP | Chunky, Golem, Lich, Masochist, Ogre, Pacifist | HP bonuses |
| HP Regeneration | Bull, Doctor, Lich, Masochist, Pacifist | Regen per second |
| Life Steal | Lich, Masochist, Sick, Vampire | DMG converted to HP |
| Damage | One Armed | General DMG increase |
| Melee Damage | Brawler, Crazy, Diver, Generalist, Gladiator, Glutton, Ogre | Melee DMG scaling |
| Ranged Damage | Cyborg, Generalist, Ranger | Ranged DMG scaling |
| Elemental Damage | Mage, Technomage | Burning/elemental |
| Attack Speed | None | Cooldown reduction |
| Crit Chance | Crazy, Diver, Hunter | Critical hit % |
| Engineering | Builder, Cyborg, Dwarf, Engineer, Technomage | Structure/turret |
| Range | Hunter, Ranger | Projectile distance |
| Armor | Bull, Golem, Knight, Masochist, Pacifist | Defense |
| Dodge | Cryptid, Ghost | Avoidance % |
| Speed | Explorer, Hiker, Speedy | Movement % |
| Luck | Chunky, Curious, Druid, Glutton, Lucky | RNG bonuses |
| Harvesting | Entrepreneur, Farmer | Material gain |

#### **Mechanic Tags (Secondary)**

| Tag | Characters | Effects |
|-----|-----------|---------|
| Consumable | Chunky, Druid, Explorer, Farmer, Glutton | Fruit/consumable bonuses |
| Economy | Entrepreneur | Shop discounts, recycling |
| Exploration | Cryptid, Explorer, Lucky | Tree spawning |
| Explosive | Artificer, Bull, Glutton, Ogre | Explosion size/damage |
| Less Enemies | Old | Spawn count reduction |
| Less Enemy Speed | Old | Enemy speed reduction |
| More Enemies | Loud | Spawn count increase |
| Pickup | Buccaneer, Lucky | Pickup range & attraction |
| Stand Still | Soldier | Bonuses while not moving |
| Structure | Cyborg, Dwarf, Engineer, Streamer, Technomage | Turrets & structures |
| XP Gain | Apprentice, Baby, Captain, Creature, Mutant | Experience modifiers |

### High-Impact Items (Tier 3+)

**Damage Focus:**
- **Glass Cannon (T3):** +25% DMG, -3 Armor
- **Spider (T4):** +12% DMG +6% Attack Speed per different weapon
- **Triangle of Power (T3):** +20% DMG, +1 Armor
- **Focus (T4):** +30% DMG, -3% Attack Speed per weapon (One Armed)

**Defense Focus:**
- **Cape (T4):** +5% Life Steal, +20% Dodge, -2 to damage stats
- **Stone Skin (T3):** +1 Max HP per Armor, -6% Attack Speed
- **Regeneration Potion (T4):** HP Regen doubled <50% HP, +3 HP Regen

**Synergy Items:**
- **Alloy (T3):** +3 to Melee/Ranged/Elemental/Engineering, +5% Crit
- **Frozen Heart (T3):** +8 Elemental DMG, weapon DMG scales 10% Elemental
- **Handcuffs (T3):** +8 to Melee/Ranged/Elemental, caps Max HP (1-limit)
- **Nail (T3):** +5 Engineering, weapon DMG scales 20% Engineering (1-limit)

**Transformation Items:**
- **Axolotl (T4):** Swaps highest and lowest positive stat (1-limit)
- **Mirror (DLC T3):** Duplicates next item (no limit overflow)

**Structure Items:**
- **Explosive Turret (T4):** Spawns turret, 25 (+150%) DMG
- **Laser Turret (T3):** Spawns turret, 20 (+125%) piercing DMG
- **Incendiary Turret (T2):** Spawns turret, 8x5 (+33%) burning DMG
- **Medical Turret (T2):** Spawns turret, heals 3 (+5%) HP

### Item Synergies with Characters

- **One Armed + Focus:** 30% more DMG, ideal for single weapon
- **Technomage + Engineering items:** Converts Ranged to Engineering mid-wave
- **Demon + Max HP items:** Currency conversion strategy
- **Pacifist + Consumable items:** Fruit-based builds
- **Builder + Structure items:** Structure scaling focus
- **Soldier + Stand Still items:** Stationary gameplay enhancement

---

## Enemies

### Enemy Data Structure

```json
{
  "name": "string",
  "zone": "enum: Crash Zone | The Abyss",
  "type": "enum: Regular | Elite | Boss",
  "behavior": "string (movement/attack pattern)",
  "base_health": "integer",
  "health_per_wave": "float (growth rate)",
  "speed": "integer or range (movement speed)",
  "speed_range": "tuple: (min, max) or null",
  "base_damage": "integer",
  "damage_per_wave": "float (growth rate)",
  "knockback_resistance": "float (0-1, 1 = immune)",
  "materials_dropped": "integer",
  "consumable_drop_rate": "float (0-100%)",
  "loot_crate_drop_rate": "float (0-100%)",
  "first_wave_spawn": "integer or conditional",
  "special_abilities": ["ability_name", "..."],
  "mutations": "object (elite/boss phase changes)",
  "danger_5_modifier": "float (stat multiplier)",
  "is_dlc": "boolean"
}
```

### Base Game Enemies (Crash Zone)

#### **Regular Enemies (Spawn Waves 1-20)**

| Name | HP | HP/Wave | Speed | DMG | Special | First Wave |
|------|----|---------| ------|-----|---------|------------|
| **Tree** | 10 | +5 | 0 | 0 | Drops fruit/crate | 1 |
| **Baby Alien** | 3 | +2 | 200-300 | 1 | Chases, touch DMG | 1 |
| **Chaser** | 1 | +1 | 380 | 1 | Spawns groups | 2 |
| **Spitter** | 8 | +1 | 200 | 1 | Runs away, projectiles | 4 |
| **Charger** | 4 | +2.5 | 400 | 1 | Charges with cooldown | 3 |
| **Bruiser** | 20 | +11 | 300 | 2 | Charges, melee | 8 |
| **Buffer** | 20 | +3 | 150 | 1 | Buffs other enemies +150% HP | 16 |
| **Fly** | 15 | +4 | 325-375 | 1 | Spawns projectiles on hit | D1: 4 |
| **Healer** | 10 | +8 | 400 | 1 | Heals nearby enemies | D1: 7 |
| **Looter** | 5 | +30 | 300-400 | 1 | Drops 8 materials + crate | 3 |
| **Helmet Alien** | 8 | +4 | 225-275 | 1 | Chases, armored | 13 |
| **Fin Alien** | 12 | +2 | 400 | 1 | Fast chaser | 15 |
| **Spawner** | 10 | +1 | 120 | 1 | Spawns 3 Junkies on death | 14 |
| **Junkie** | 5 | +5 | 350 | 1 | Fires near player | 14 |
| **Horned Bruiser** | 30 | +22 | 300 | 1 | Stronger charger | 13 |
| **Horned Charger** | 12 | +5 | 425 | 1 | Very fast charger | 18, D4: 5 |
| **Slasher Egg** | 5 | +3 | 0 | 1 | Spawns Slasher after 5s | D1: 7 |
| **Slasher** | 50 | +25 | 250-300 | 1 | Melee range slashes | D1: 4 |
| **Tentacle** | 100 | +20 | 175 | 1 | V-shape melee attacks | D3: 13 |
| **Pursuer** | 10 | +24 | 150â†’600 | 1 | Gets faster each second | 11 |
| **Lamprey** | 30 | +15 | 350 | 1 | Special spawn: Bait item | 26 |

**Wave 20 Bosses (Random spawn, one of two):**

| Name | HP | Speed | DMG | Mutations |
|------|----|----|-----|-----------|
| **Predator** | 29,250 | 300 | 30 (contact), 23 (proj) | Mutation at 50% HP / 45 sec: Charges more frequently |
| **Invoker** | 29,250 | 200/varies | 30 (contact), 23 (proj) | Creates projectile area every 2 seconds |

**Danger 5 Modifiers:**
- Boss health at Wave 20: 75% of base â†’ boosted to 104.5% (0.75 Ã— 1.4)
- Contact damage: 41, Projectile: 32
- Regular enemies: +40% HP across all waves

#### **Elite Enemies (Danger 2+ Only)**

Spawn at Elite Waves (Waves 11-18 typically). Drop legendary tier 4 items.

| Name | HP | HP/Wave | Speed | DMG | Health Reduction (W11-12) |
|------|----|---------| ------|-----|----------|
| **Rhino** | 750 | +750 | 250 | 1 | 75% |
| **Butcher** | 750 | +750 | 200 | 1 | 75% |
| **Monk** | 700 | +700 | 350 | 1 | 75% |
| **Croc** | 750 | +750 | 350 | 1 | 75% |
| **Colossus** | 750 | +750 | 300 | 1 | 75% |
| **Mantis** | 750 | +750 | 250 | 1 | 75% |
| **Mother** | 750 | +750 | 250 | 1 | 75% |
| **Gargoyle** | 750 | +750 | 350 | 1 | 75% |

**Elite Mechanics:**
- Mutations trigger at HP threshold OR time limit (whichever first)
- Drop 10 coins each
- All elites appear at waves 11+, spread across multiple waves on Danger 4-5

### DLC Enemies (The Abyss)

#### **Regular Enemies (The Abyss Zone)**

| Name | HP | HP/Wave | Speed | DMG | Armor | Special |
|------|----|---------| ------|-----|-------|---------|
| **Anemone** | 8 | +4 | 100 | 1 | 0.6 | Creates projectile circle |
| **Anglerfish** | 10 | +10 | 200 | 1 | 0.2 | Charges up to 3 times |
| **Blobfish** | 10 | +8 | 200 | 1 | 0.5 | Spawns 3 Lamprey + Sea Pig |
| **Clam** | 2 | +3 | 130 | 1 | 0.75 | Ranged attacker |
| **Colossal Squid** | 30 | +20 | 200 | 1 | 0.75 | Large attacker |
| **Dragonfish** | 100 | +50 | 300 | 1 | 0.9 | Shoots bullet lines |
| **Goblin Shark** | 12 | +10 | 275 | 1 | 0.7 | Charges to movement pred |
| **Lobster** | 1 | +5 | 250 | 1 | 0.5 | Takes -75% DMG |
| **Plankton** | 1 | +1 | 225 | 1 | 0.0 | Sometimes charges |
| **Pufferfish** | 5 | +2 | 175 | 1 | 0.7 | Explodes into projectiles |
| **Stargazer** | 30 | +15 | 100 | 1 | 0.5 | Buffs Iron Lung |
| **Viperfish** | 1 | +3 | 80 | 1 | 0.0 | Grows then chases |
| **Walrus** | 40 | +25 | 200 | 1 | 0.9 | Charges periodically |

#### **DLC Bosses (The Abyss Wave 20)**

| Name | HP | Speed | DMG |
|------|----|----|-----|
| **Dead Whale** | 31,625 | 200 | 30 (contact), 23 (proj) |
| **Eel** | 31,625 | 150 | 30 (contact), 23 (proj) |

**Danger 5 (DLC):** 33,206 HP

---

## Game Mechanics

### Wave System

**Standard Run:**
- 20 waves total
- Each wave lasts 20-90 seconds (increases with wave number)
- Wave 20: Boss battle lasts 90 seconds
- Endless Mode: Waves continue after 20, each 60 seconds

| Wave | Duration | Enemies | Special |
|------|----------|---------|---------|
| 1 | 20 sec | Low spawn | Introduction |
| 5 | 40 sec | Moderate | Early spike |
| 10 | Increases | Mixed | Pre-elite prep |
| 11-12 | Increases | Mixed | 1st Elite/Horde (D2+) |
| 14-15 | Increases | Mixed | 2nd Elite/Horde (D4-5) |
| 17-18 | Increases | Mixed | 3rd Elite/Horde guaranteed (D4-5) |
| 20 | 90 sec | Boss | Final challenge |

**Elite/Horde Waves:**
- Danger 0-1: None
- Danger 2-3: 1 total (40% Horde, 60% Elite)
- Danger 4-5: 3 total (spread across waves)
- 3rd challenging wave guaranteed Elite
- Horde = many small enemies, 35% less material drops

### Player Stats

**Base Stats (All start at 0 unless modified):**

| Stat | Effect | Scaling Cap |
|------|--------|-------------|
| **Max HP** | Health pool (default 100) | Increases with items |
| **HP Regeneration** | HP/second during waves | Unlimited |
| **Life Steal** | % of DMG converted to HP | Capped 90% (Ghost) |
| **Damage** | General DMG multiplier | Unlimited |
| **Melee Damage** | Bonus DMG for melee weapons | Scales weapon effects |
| **Ranged Damage** | Bonus DMG for ranged weapons | Scales weapon effects |
| **Elemental Damage** | Bonus burning/special DMG | Scales weapon effects |
| **Attack Speed** | Cooldown reduction % | Minimum 0.75s (Ball & Chain) |
| **Crit Chance** | % chance for x1.5-x2.5 DMG | Capped per weapon |
| **Crit Damage** | Multiplier on crit (x1.5-x2.5) | Weapon dependent |
| **Engineering** | Structure/turret scaling | Scales structure power |
| **Range** | Projectile travel distance | Melee 50% effect |
| **Armor** | DMG reduction % | Unlimited |
| **Dodge** | Avoidance % | Capped 90% (Ghost), 70% (Cryptid), 20% (Sailor) |
| **Speed** | Movement % | Capped per character |
| **Luck** | RNG bonus multiplier | Unlimited |
| **Harvesting** | % material gain increase | Unlimited |
| **Knockback** | Enemy pushback distance | Weapon dependent |
| **Curse** | Hidden stat (varies by character) | Negative scaling |
| **XP Gain** | % experience multiplier | Unlimited |

### Danger Levels

| Danger | Enemy Scaling | Elite Waves | Changes |
|--------|---------------|-----------|---------|
| **0** | Ã—1 (base) | None | Tutorial difficulty |
| **1** | Ã—1.1 | None | Early challenge |
| **2** | Ã—1.2 | 1 wave | Elites appear |
| **3** | Ã—1.3 | 1 wave | Harder elites |
| **4** | Ã—1.4 | 3 waves | Multi-wave elite challenge |
| **5** | Ã—1.4 +40% to enemy stats | 3 waves, 2 bosses | Maximum difficulty |

### Shop System

**Shop Mechanics:**
- Appears between waves
- Shows 3 items and 3 weapons (may be locked)
- 1 free reroll per shop (more with items)
- Item/weapon with matching character tag: 5% selection chance
- Can recycle items/weapons for materials (35% value recovery)

**Item Tags in Shop:**
- 5% chance item selected from character tag pool instead of all items
- Same item can be in multiple pools (increases selection likelihood)
- Reroll cost: 10 materials (modified by items)
- Lock/unlock cost: 5 materials

### Consumable System

**Fruits/Consumables:**
- Dropped by trees and some characters
- Heal player when picked up (varies by item mods)
- Can explode for damage (Glutton, Chef mechanics)
- Tier I items give bonuses on pickup

### Leveling System

**Experience and Levels:**
- Gained from wave completion
- 20 total levels per run
- Each level: Choose stat upgrade (+1 to selected stat)
- Exceptions:
  - Baby: Weapon slot instead of stat
  - Apprentice: +2 Melee, +1 Ranged/Elemental/Engineering, -2 Max HP
  - Captain: +100% stat gains

### Curse Mechanic

**Associated Characters:** Creature, Sailor, others (DLC)

- Hidden stat tracked per run
- Creature scales weapon DMG 35% with Curse
- Sailor: +200% DMG vs cursed enemies
- Fish Hook (item): Locked items become cursed (20% chance)
- Curse items available in shops

---

## Data Structures

### JSON Schema Examples

#### Character Data
```json
{
  "id": "gladiator",
  "name": "Gladiator",
  "description": "Warrior of the arena",
  "stats": {
    "base": {
      "max_hp": 0,
      "hp_regen": 0,
      "life_steal": 0,
      "damage": 0,
      "melee_damage": 5,
      "ranged_damage": 0,
      "elemental_damage": 0,
      "attack_speed": -40,
      "crit_chance": 0,
      "engineering": 0,
      "range": 0,
      "armor": 0,
      "dodge": 0,
      "speed": 0,
      "luck": -30,
      "harvesting": 0
    },
    "scaling": {
      "per_weapon_diversity": {
        "attack_speed": 20,
        "damage": 0
      }
    }
  },
  "mechanics": {
    "weapon_limit": 6,
    "ranged_allowed": false,
    "description": "+20% Attack Speed for every different weapon you have"
  },
  "starting_equipment": {
    "weapons": [],
    "items": []
  },
  "item_tags": ["Melee Damage"],
  "unlock_condition": "Kill 20000 enemies",
  "unlock_reward": "Spider",
  "is_dlc": false,
  "difficulty_tier": "intermediate"
}
```

#### Weapon Data
```json
{
  "id": "knife",
  "name": "Knife",
  "type": "melee",
  "classes": ["Precise", "Blade"],
  "damage": {
    "base": 6,
    "scaling": {
      "melee_damage": 0.80
    }
  },
  "attack_speed": 1.01,
  "dps": 5.9,
  "crit": {
    "multiplier": 2.5,
    "chance": 0.20
  },
  "range": 150,
  "knockback": 2,
  "lifesteal": 0,
  "special_effects": "None",
  "base_price": 15,
  "unlocked_by": "Default",
  "min_tier": 1,
  "tiers": {
    "1": {"damage": 6},
    "2": {"damage": 12},
    "3": {"damage": 18},
    "4": {"damage": 24}
  }
}
```

#### Item Data
```json
{
  "id": "spider",
  "name": "Spider",
  "rarity_tier": 4,
  "effects": {
    "damage": 0.12,
    "attack_speed": 0.06,
    "per_different_weapon": {
      "attack_speed": 0.06
    }
  },
  "penalties": {
    "dodge": -0.03,
    "harvesting": -5
  },
  "base_price": 110,
  "item_limit": null,
  "item_tags": ["Damage", "Attack Speed"],
  "unlocked_by": "Win a run with Gladiator",
  "special_properties": {
    "per_weapon_scaling": true,
    "conditional": false
  }
}
```

#### Enemy Data
```json
{
  "id": "tree",
  "name": "Tree",
  "zone": "Crash Zone",
  "type": "regular",
  "behavior": "Neutral, drops fruit or Crate on death as well as 3 Materials",
  "health": {
    "base": 10,
    "per_wave": 5
  },
  "speed": 0,
  "speed_range": null,
  "damage": {
    "base": 0,
    "per_wave": 0
  },
  "knockback_resistance": 1.0,
  "materials_dropped": 3,
  "consumable_drop_rate": 1.0,
  "loot_crate_drop_rate": 0.20,
  "first_wave_spawn": 1,
  "special_abilities": ["drops_consumable_or_crate"],
  "danger_scaling": null
}
```

---

## Relationships

### Character â†’ Item Tag Affinity

```
Character â†’ has many â†’ Item Tags
Item Tag â†’ attracts â†’ Items (5% selection chance in shop/crates)
```

**Example:** Gladiator has "Melee Damage" tag â†’ 5% chance shop selects from Melee Damage items

### Character â†’ Starting Equipment

```
Character â†’ starts with â†’ Weapons (1-2)
Character â†’ starts with â†’ Items (0-1)
```

**Examples:**
- Brawler: Fist (weapon)
- Mage: Snake + Scared Sausage (weapons)
- Engineer: Wrench (weapon)
- Cyborg: Minigun (weapon)

### Weapon â†’ Class Bonuses

```
Weapon âˆˆ Class â†’ provides stacking bonus per count
Class bonuses scale: 2 weapons = bonus1, 3 = bonus2, ... 6 = bonus6
```

**Example:** 6 Blade weapons â†’ +5 Melee Damage, +5% Life Steal

### Item â†’ Item Tags

```
Item has many â†’ Item Tags
Item Tag âŠ‚ Character Item Tags â†’ increases shop selection (5% chance)
```

### Enemy Wave Progression

```
Wave (1-20) â†’ contains â†’ Enemy Spawns
Wave â†’ has â†’ Duration (20-90 seconds)
Higher Wave â†’ Enemy Stats increase per wave formula
```

**Scaling Example:** Charger has 400 base speed, gains +0.85 damage per wave after wave 1

### Synergy Examples

#### Glass Cannon + Spider (Tier 4 Damage Build)
```
Glass Cannon: +25% DMG, -3 Armor
Spider: +12% DMG, +6% Attack Speed per weapon
Combined: High damage output, reduced survivability
Ideal Character: One Armed (single weapon focus)
```

#### Stone Skin + Armor Items (Tank Build)
```
Stone Skin: +1 Max HP per Armor
Heavy Armor Items: Various Armor bonuses
Combined: Exponential HP scaling
Ideal Character: Knight (+2 Melee per Armor, no ranged)
```

#### Structure Synergy
```
Engineer â†’ has â†’ Engineer tag â†’ attracts â†’ Structure items
Item: Explosive Turret, Laser Turret, etc.
Engineering scaling: Increases turret damage
Ideal Weapons: Tool class (Wrench, Screwdriver)
```

#### Curse Scaling
```
Creature: Weapon DMG scales 35% with Curse
Fish Hook Item: +1 Curse on pickup
Curse Items: Add Curse stat
Black Flag: +5 Curse, +10% Enemies
Combined: Curse builds viable for Creature/Sailor
```

---

## Summary

This data dictionary encompasses:
- **62 Characters** with unique mechanics and stat modifiers
- **83 Weapons** across 14 classes with tier-based scaling
- **177 Items** organized by 23 tags and 4 rarity tiers
- **54+ Enemy Types** with wave progression and difficulty scaling
- **Complex Synergy System** enabling diverse build strategies

The game emphasizes **build experimentation**, with interactions between character mechanics, weapon classes, item tags, and enemy variety creating emergent gameplay. Strategic depth comes from optimizing stat scaling, leveraging class bonuses, and building around character-specific mechanics.

---

## Document Metadata

| Property | Value |
|----------|-------|
| **Last Updated** | November 2025 |
| **Game Version** | 1.1.10.9 |
| **DLC Included** | Yes (Abyssal Terrors) |
| **Wiki Source** | https://brotato.wiki.spellsandguns.com/ |
| **Total Entities** | 378+ (Characters, Weapons, Items, Enemies) |
| **Relationships Mapped** | 47 major synergy categories |

---

**End of Data Dictionary**

*Note: This document is maintained for AI code assistant integration. Update frequency should align with game patch releases (typically monthly). Character/weapon balance changes require manual updates to stat values.*
