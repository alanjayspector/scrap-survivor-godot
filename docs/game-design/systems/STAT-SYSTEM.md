# Stat System

**Status:** Draft - Based on Brotato Comparison
**Date:** 2025-01-09
**Purpose:** Define all character stats, scaling, caps, and cross-reference to Brotato

---

## Overview

Scrap Survivor uses a stat-based progression system inspired by Brotato. Characters have 20+ stats that affect combat, survivability, economy, and progression. Stats are modified by:

- Character type (starting stats)
- Advancement Hall (level-up choices)
- Items (auto-active bonuses)
- Perks (server-injected modifiers)
- Weapon classes (stacking bonuses)

---

## Complete Stat List

### Combat Stats (9 stats)

#### 1. Max HP
**What it does:** Total health pool
**Base value:** 100
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Same base value (100)
✅ Same scaling (additive)

**Sources:**
- Advancement Hall: +1 per level spent on Max HP
- Items: Armor, shields, health trinkets
- Perks: "Tank" perk (+25 Max HP)
- Weapon classes: Primitive (+15 HP at tier 6)
- Character types: Bruiser (+20 Max HP base)

---

#### 2. HP Regeneration
**What it does:** HP restored per second during combat
**Base value:** 0
**Scaling:** Additive (+1 HP/sec per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Same base value (0)
✅ Active during waves (not between waves)

**Sources:**
- Advancement Hall: +1 HP Regen per level
- Items: Regeneration trinkets, medical items
- Perks: "Regeneration" perk (+5 HP Regen)
- Weapon classes: Medical (+5 HP Regen at tier 6)

**Special interactions:**
- Radioactivity: High radioactivity (80+) reduces HP Regen by 50%
- "Vampire" perk: Converts 10% of Life Steal to HP Regen

---

#### 3. Life Steal
**What it does:** % of damage converted to HP
**Base value:** 0%
**Scaling:** Additive (+1% per point)
**Hard cap:** 90% (matches Brotato)

**Brotato comparison:**
✅ Identical mechanic
✅ Same cap (90%)
✅ Same scaling

**Sources:**
- Items: Vampiric weapons, life steal trinkets
- Perks: "Bloodthirst" perk (+10% Life Steal)
- Weapon classes: Blade (+5% Life Steal at tier 6)

**Special interactions:**
- "Vampire" character: Gains +1% Life Steal per 3% missing HP
- "Sick" character: +25% Life Steal base, but takes 1 DMG/sec

---

#### 4. Damage (General)
**What it does:** Global damage multiplier (affects all damage types)
**Base value:** 0
**Scaling:** Percentage (+1% per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Affects all weapon types

**Sources:**
- Advancement Hall: +1% damage per level
- Items: Damage-boosting trinkets
- Perks: "Berserker" perk (+25% damage)

**Important:** This is a MULTIPLIER applied AFTER type-specific damage (Melee/Ranged/Elemental)

```gdscript
# Damage calculation order
final_damage = base_weapon_damage
final_damage *= (1 + melee_damage / 100)  # Type-specific
final_damage *= (1 + general_damage / 100)  # General multiplier
```

---

#### 5. Melee Damage
**What it does:** Damage bonus for melee weapons only
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Separate from Ranged/Elemental

**Sources:**
- Advancement Hall: +1 Melee DMG per level
- Items: Melee-focused items (tagged "Melee Damage")
- Perks: "Brawler" perk (+10 Melee DMG)
- Weapon classes: Heavy (+25% damage at tier 6)
- Character types: Bruiser (+15 Melee DMG base)

**Scaling formula:**
```gdscript
melee_weapon_damage = base_damage * (1 + melee_damage / 100)
```

---

#### 6. Ranged Damage
**What it does:** Damage bonus for ranged weapons only
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic

**Sources:**
- Advancement Hall: +1 Ranged DMG per level
- Items: Ranged-focused items (tagged "Ranged Damage")
- Perks: "Marksman" perk (+10 Ranged DMG)
- Weapon classes: Gun (+50 Range at tier 6, indirect boost)
- Character types: Ranger (+15 Ranged DMG base, can't equip melee)

---

#### 7. Elemental Damage
**What it does:** Damage bonus for elemental weapons (fire, lightning, poison)
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Affects burning, explosions, special effects

**Sources:**
- Advancement Hall: +1 Elemental DMG per level (Premium+ only)
- Items: Elemental-focused items (tagged "Elemental Damage")
- Perks: "Pyromancer" perk (+10 Elemental DMG)
- Weapon classes: Elemental (+5 Elemental DMG at tier 6)
- Character types: Mage (+10 Elemental DMG base, -100% Melee/Ranged)

**Tier restriction:**
- ❌ Free tier: Cannot level Elemental Damage in Advancement Hall
- ✅ Premium+: Full access

---

#### 8. Attack Speed
**What it does:** Reduces weapon cooldown (faster attacks)
**Base value:** 0%
**Scaling:** Percentage (+1% per point)
**Soft cap:** Weapon-dependent (minimum cooldown varies)

**Brotato comparison:**
✅ Similar mechanic
⚠️ Brotato has minimum 0.75s cooldown (Ball & Chain exception)
⚠️ We should match this

**Sources:**
- Advancement Hall: +1% Attack Speed per level
- Items: Attack speed trinkets, speed-boosting items
- Perks: "Rapid Fire" perk (+20% Attack Speed)
- Weapon classes: Precise (+15% Crit Chance at tier 6, indirect via crits)
- Character types: Speedster (+25% Attack Speed base)

**Cooldown formula:**
```gdscript
final_cooldown = base_cooldown / (1 + attack_speed / 100)
final_cooldown = max(final_cooldown, 0.15)  # Minimum 0.15s (matches Brotato's 0.75s / 5)
```

**Example:**
- Base cooldown: 1.0s
- Attack Speed: +100%
- Final cooldown: 1.0 / (1 + 1.0) = 0.5s

---

#### 9. Crit Chance
**What it does:** % chance to deal critical hit (multiplied damage)
**Base value:** 0%
**Scaling:** Additive (+1% per point)
**Hard cap:** 100% (guaranteed crits)

**Brotato comparison:**
✅ Identical mechanic
✅ Same cap (100%)
⚠️ Brotato has per-weapon crit multipliers (we should match)

**Sources:**
- Advancement Hall: +1% Crit Chance per level (Premium+ only)
- Items: Crit-focused items (tagged "Crit Chance")
- Perks: "Lucky Strike" perk (+15% Crit Chance)
- Weapon classes: Precise (+15% Crit Chance at tier 6)
- Character types: Hunter (+10% Crit Chance base)

**Tier restriction:**
- ❌ Free tier: Cannot level Crit Chance in Advancement Hall
- ✅ Premium+: Full access

**Crit multipliers (per weapon):**
```gdscript
# Weapon-specific crit damage
const WEAPON_CRIT_MULTIPLIERS = {
    "knife": 2.5,      # High crit (matches Brotato)
    "sword": 2.0,      # Standard crit
    "hammer": 1.5,     # Low crit (slow weapons)
    "pistol": 2.0,     # Standard ranged
    "sniper": 3.0      # High precision
}
```

---

### Utility Stats (7 stats)

#### 10. Engineering
**What it does:** Boosts structure/turret/minion effectiveness
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Similar mechanic (Brotato uses for turrets)
🟢 We extend it to minions (unique differentiator!)

**Sources:**
- Advancement Hall: +1 Engineering per level (Premium+ only)
- Items: Engineering-focused items
- Perks: "Technician" perk (+10 Engineering)
- Weapon classes: Tool (+5 Engineering at tier 6)
- Character types: Engineer (+10 Engineering base)

**Tier restriction:**
- ❌ Free tier: Cannot level Engineering in Advancement Hall
- ✅ Premium+: Full access (needed for Minions system)

**Engineering effects:**
```gdscript
# Minion scaling (our unique feature)
minion_damage = base_minion_damage * (1 + engineering / 100)
minion_attack_speed = base_attack_speed * (1 + engineering / 100)
minion_health = base_health * (1 + engineering / 50)  # 50% efficiency

# Structure scaling (if we add turrets like Brotato)
turret_damage = base_turret_damage * (1 + engineering / 100)
```

---

#### 11. Range
**What it does:** Increases projectile distance & melee reach
**Base value:** 0
**Scaling:** Additive (+5 per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Melee gets 50% effectiveness (matches Brotato)

**Sources:**
- Advancement Hall: +5 Range per level
- Items: Range-boosting items
- Perks: "Long Reach" perk (+50 Range)
- Weapon classes: Gun (+50 Range at tier 6)
- Character types: Ranger (+50 Range base)

**Range scaling:**
```gdscript
# Ranged weapons: Full effectiveness
ranged_range = base_range + range_stat

# Melee weapons: 50% effectiveness
melee_range = base_range + (range_stat * 0.5)
```

**Note:** Increasing range slightly reduces attack speed for melee (matches Brotato)

---

#### 12. Armor
**What it does:** Damage reduction (% of incoming damage blocked)
**Base value:** 0
**Scaling:** Diminishing returns (see formula)
**Soft cap:** ~90% damage reduction at 100 Armor

**Brotato comparison:**
✅ Similar mechanic
⚠️ Need to confirm Brotato's exact formula

**Sources:**
- Advancement Hall: +1 Armor per level
- Items: Armor items, shields
- Perks: "Fortified" perk (+10 Armor)
- Weapon classes: Blunt (+Armor, -Speed)
- Character types: Tank (+15 Armor base)

**Armor formula (diminishing returns):**
```gdscript
damage_reduction = armor / (armor + 100)

# Examples:
# 10 Armor = 9.1% reduction
# 25 Armor = 20% reduction
# 50 Armor = 33% reduction
# 100 Armor = 50% reduction
# 200 Armor = 66.7% reduction

final_damage = incoming_damage * (1 - damage_reduction)
```

**Why diminishing returns?**
- Prevents invincibility (can't reach 100% reduction)
- Balances armor vs. HP stacking
- Matches Brotato's approach

---

#### 13. Dodge
**What it does:** % chance to completely avoid incoming damage
**Base value:** 0%
**Scaling:** Additive (+1% per point)
**Hard cap:** 90% (matches Brotato Ghost character)

**Brotato comparison:**
✅ Identical mechanic
✅ Same cap (90% for Ghost, 70% for Cryptid, 20% for Sailor)

**Sources:**
- Advancement Hall: +1% Dodge per level (Premium+ only)
- Items: Dodge-focused items
- Perks: "Evasion" perk (+10% Dodge)
- Weapon classes: Unarmed (+15% Dodge at tier 6)
- Character types: Speedster (+20% Dodge base)

**Tier restriction:**
- ❌ Free tier: Cannot level Dodge in Advancement Hall
- ✅ Premium+: Full access

**Cap variations by character:**
```gdscript
# Character-specific dodge caps
const DODGE_CAPS = {
    "default": 0.60,      # 60% cap (most characters)
    "ghost": 0.90,        # 90% cap (Ghost character, -100 Armor)
    "cryptid": 0.70,      # 70% cap
    "sailor": 0.20        # 20% cap (cursed build)
}
```

**Dodge vs. Armor trade-off:**
- Dodge = binary (100% avoid or 0%)
- Armor = consistent reduction
- High dodge + low armor = risky but powerful
- Low dodge + high armor = consistent tanking

---

#### 14. Speed
**What it does:** Movement speed multiplier
**Base value:** 100%
**Scaling:** Percentage (+1% per point)
**Soft cap:** Character-dependent (usually 200-300%)

**Brotato comparison:**
✅ Identical mechanic
✅ Same base (100% = normal speed)

**Sources:**
- Advancement Hall: +1% Speed per level
- Items: Speed-boosting items (boots, trinkets)
- Perks: "Fleet Foot" perk (+25% Speed)
- Character types: Speedster (+30% Speed base)

**Speed interactions:**
```gdscript
# Speedy character (Brotato reference)
# +1 Melee DMG per 2% Speed
if character_type == "speedy":
    bonus_melee_damage = (speed - 100) / 2

# Soldier character (Brotato reference)
# Can't attack while moving
if character_type == "soldier" and is_moving:
    can_attack = false
```

---

#### 15. Luck
**What it does:** Increases drop rates, crit chance, shop quality
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited, but diminishing returns on some effects)

**Brotato comparison:**
✅ Identical mechanic
✅ Affects drops, crits, shop

**Sources:**
- Advancement Hall: +1 Luck per level
- Items: Luck-boosting items (four-leaf clover, lucky coin)
- Perks: "Fortune" perk (+25 Luck)
- Character types: Lucky (+100 Luck base)

**Luck effects:**
```gdscript
# Crate drop rate
base_crate_drop_rate = 0.05  # 5%
luck_bonus = luck * 0.001     # +0.1% per Luck point
final_crate_rate = base_crate_drop_rate + luck_bonus

# Example: 50 Luck = 5% + 5% = 10% crate drop rate

# Shop quality (higher tier items)
tier_4_chance = base_tier_4_chance * (1 + luck / 200)

# Example: 100 Luck = 50% more tier 4 items in shop
```

**Special interactions:**
- Black Market: Luck affects mystery box outcomes
- Radioactivity: Luck reduces negative radioactivity effects
- Critical hits: Luck adds +0.5% crit chance per 10 Luck

---

#### 16. Harvesting
**What it does:** Increases scrap/material drops from enemies
**Base value:** 0
**Scaling:** Percentage (+1% per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Same scaling

**Sources:**
- Advancement Hall: +1% Harvesting per level
- Items: Harvesting items (scrap magnet, collector's bag)
- Perks: "Scavenger" perk (+25% Harvesting)
- Weapon classes: Support (+25% Harvesting at tier 6)
- Character types: Farmer (+20% Harvesting base)

**Harvesting formula:**
```gdscript
material_drop = base_material_drop * (1 + harvesting / 100)

# Example:
# Base drop: 10 scrap
# Harvesting: +50%
# Final drop: 15 scrap
```

**Special interactions:**
- "Farmer" character: Harvesting increases by 3% at end of each wave
- "Saver" character: +1% Damage per 25 materials held

---

### Advanced Stats (4 stats)

#### 17. Knockback
**What it does:** Pushes enemies back on hit
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** Enemy-dependent (some enemies immune)

**Brotato comparison:**
✅ Identical mechanic
✅ Some enemies have knockback resistance

**Sources:**
- Weapons: Blunt weapons (+knockback)
- Items: Knockback trinkets
- Perks: "Shockwave" perk (+5 Knockback)

**Knockback formula:**
```gdscript
knockback_distance = knockback_stat * (1 - enemy_resistance)

# Enemy resistance examples:
# Baby Alien: 0% (full knockback)
# Bruiser: 50% (half knockback)
# Boss: 100% (immune)
```

**Not in Advancement Hall:** Can't level up directly, only via items/weapons

---

#### 18. XP Gain
**What it does:** Multiplier for experience earned
**Base value:** 100% (normal XP)
**Scaling:** Percentage (+1% per point)
**Soft cap:** None (unlimited)

**Brotato comparison:**
✅ Identical mechanic
✅ Character-specific modifiers

**Sources:**
- Items: XP-boosting items
- Perks: "Fast Learner" perk (+50% XP Gain)
- Character types:
  - Mutant: -66% XP required (inverse of XP Gain)
  - Baby: +130% XP required (slower leveling)
  - Captain: +200% XP required (+100% level stats to compensate)

**XP formula:**
```gdscript
earned_xp = base_xp * (1 + xp_gain / 100)

# Character modifiers applied AFTER XP Gain
if character_type == "mutant":
    xp_required_per_level *= 0.34  # -66% XP required
```

**Not in Advancement Hall:** Can't level up directly, only via items/perks

---

#### 19. Curse
**What it does:** Hidden stat, enables cursed builds (high risk/high reward)
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** None (unlimited, but negative effects scale)

**Brotato comparison:**
✅ Identical mechanic (DLC feature)
✅ Character-specific synergies

**Sources:**
- Items: Cursed items (Black Market)
- Character types:
  - Creature: Weapon DMG scales 35% with Curse
  - Sailor: +200% DMG with Naval weapons on cursed, +25 Curse base
- Radioactivity: High radioactivity adds Curse

**Curse effects:**
```gdscript
# Negative scaling (base)
enemy_spawn_rate *= (1 + curse * 0.01)  # +1% enemies per Curse
damage_taken *= (1 + curse * 0.005)     # +0.5% damage taken per Curse

# Positive scaling (character-specific)
if character_type == "creature":
    weapon_damage *= (1 + curse * 0.35)  # +35% damage per Curse
```

**Not in Advancement Hall:** Can't level up directly, only via items

---

#### 20. Radioactivity
**What it does:** Scrap Survivor unique stat - irradiate items for stat boosts at cost
**Base value:** 0
**Scaling:** Additive (+1 per point)
**Soft cap:** 100 (max radioactivity)

**Brotato comparison:**
🟢 UNIQUE TO SCRAP SURVIVOR (Brotato has no equivalent)

**Sources:**
- Radioactivity System: Irradiate items at Urgent Care
- Items: Radioactive items (tier-specific effects)
- Character interactions: Some characters may start with base radioactivity

**Radioactivity effects (see [RADIOACTIVITY-SYSTEM.md](./RADIOACTIVITY-SYSTEM.md)):**
```gdscript
# Advancement Hall interaction
if radioactivity >= 60:
    xp_gain_bonus = radioactivity * 0.15  # +15% XP at 60 Radioactivity
    random_stat_loss_chance = 0.33        # Lose 1 random stat every 3 levels

# HP Regen penalty
if radioactivity >= 80:
    hp_regen_multiplier = 0.5  # -50% HP Regen

# Curse interaction
if radioactivity >= 40:
    curse += (radioactivity - 40) / 10  # +1 Curse per 10 Radioactivity above 40
```

---

## Stat Categories by Tier Access

### Free Tier Stats (10 stats)
**Available in Advancement Hall:**
- Max HP
- HP Regeneration
- Damage (General)
- Melee Damage
- Ranged Damage
- Attack Speed
- Range
- Armor
- Speed
- Luck
- Harvesting

### Premium+ Stats (14 stats)
**All Free stats PLUS:**
- Elemental Damage
- Crit Chance
- Engineering
- Dodge

### Item/Perk Only Stats (4 stats)
**Cannot level in Advancement Hall:**
- Life Steal (items/perks only)
- Knockback (weapons only)
- XP Gain (items/perks only)
- Curse (items/characters only)

### Unique Stats (1 stat)
**Scrap Survivor only:**
- Radioactivity (Radioactivity System)

---

## Stat Caps Summary

| Stat | Soft Cap | Hard Cap | Notes |
|------|----------|----------|-------|
| Max HP | None | None | Unlimited scaling |
| HP Regeneration | None | None | Unlimited |
| Life Steal | None | 90% | Matches Brotato |
| Damage | None | None | Unlimited |
| Melee Damage | None | None | Unlimited |
| Ranged Damage | None | None | Unlimited |
| Elemental Damage | None | None | Unlimited |
| Attack Speed | Weapon-specific | 0.15s min cooldown | Matches Brotato's 0.75s |
| Crit Chance | None | 100% | Guaranteed crits |
| Engineering | None | None | Unlimited |
| Range | None | None | Unlimited |
| Armor | ~100 for 50% reduction | Asymptotic to 100% | Diminishing returns |
| Dodge | Character-specific | 20-90% | Ghost: 90%, Default: 60% |
| Speed | ~200-300% | Character-specific | Balance concern |
| Luck | None | None | Diminishing returns on effects |
| Harvesting | None | None | Unlimited |
| Knockback | Enemy-dependent | None | Some enemies immune |
| XP Gain | None | None | Unlimited |
| Curse | None | None | Unlimited (risk/reward) |
| Radioactivity | None | 100 | Design cap |

---

## Stat Priorities by Playstyle

### Tank Build
**Primary stats:**
1. Max HP (+20-30)
2. Armor (+15-25)
3. HP Regeneration (+5-10)

**Secondary stats:**
4. Life Steal (items)
5. Melee Damage (+10-15)

**Avoid:**
- Dodge (competes with Armor)
- Speed (tank doesn't kite)

---

### Glass Cannon Build
**Primary stats:**
1. Melee/Ranged Damage (+20-30)
2. Crit Chance (+30-50%)
3. Attack Speed (+30-50%)

**Secondary stats:**
4. Damage (+10-20%)
5. Life Steal (items, for sustain)

**Avoid:**
- Max HP (low HP = glass cannon)
- Armor (focus on killing fast)

---

### Speedster Build
**Primary stats:**
1. Speed (+50-100%)
2. Dodge (+30-60%)
3. Attack Speed (+30-50%)

**Secondary stats:**
4. Melee/Ranged Damage (+10-15)
5. Range (+25-50)

**Avoid:**
- Armor (Dodge instead)
- Max HP (rely on not getting hit)

---

### Minion Master Build (Premium+)
**Primary stats:**
1. Engineering (+20-40)
2. Max HP (+15-25, survive while minions fight)
3. Luck (+20-40, better minion drops)

**Secondary stats:**
4. HP Regeneration (+5-10)
5. Armor (+10-15)

**Avoid:**
- Personal damage stats (minions do damage)
- Attack Speed (minions attack, not you)

---

### Radioactive Build (High Risk)
**Primary stats:**
1. Radioactivity (+60-80, for XP boost)
2. Luck (+30-50, mitigate negative effects)
3. HP Regeneration (+10-15, counter damage over time)

**Secondary stats:**
4. Max HP (+20-30)
5. Curse (if Creature character, +35% DMG per Curse)

**Avoid:**
- Low Luck (negative radioactivity effects too punishing)

---

## Stat Scaling Formulas Reference

```gdscript
# Damage calculation (complete formula)
var base_damage = weapon.damage
var type_damage = 0

# Apply type-specific damage
if weapon.is_melee:
    type_damage = stats.melee_damage
elif weapon.is_ranged:
    type_damage = stats.ranged_damage
elif weapon.is_elemental:
    type_damage = stats.elemental_damage

var damage_after_type = base_damage * (1 + type_damage / 100.0)
var final_damage = damage_after_type * (1 + stats.general_damage / 100.0)

# Apply crit
if randf() < (stats.crit_chance / 100.0):
    final_damage *= weapon.crit_multiplier

# Armor reduction (enemy side)
var damage_reduction = enemy.armor / (enemy.armor + 100.0)
var damage_to_enemy = final_damage * (1 - damage_reduction)

# Dodge check (enemy side)
if randf() < (enemy.dodge / 100.0):
    damage_to_enemy = 0  # Complete dodge

# Life steal (player side)
var life_steal_amount = final_damage * min(stats.life_steal / 100.0, 0.9)
heal_player(life_steal_amount)
```

---

## Next Steps

1. **Create Item Stats System:**
   - Cross-reference to Brotato's 177 items
   - Define item rarity tiers
   - Define item tags

2. **Create Weapon Stats System:**
   - Cross-reference to Brotato's 83 weapons
   - Define weapon classes
   - Define stacking bonuses

3. **Update Advancement Hall:**
   - Integrate stat restrictions by tier
   - Add stat choice UI

4. **Update Character Types:**
   - Define starting stats per character
   - Add character-specific stat interactions

---

## References

- [BROTATO-COMPARISON.md](../../competitive-analysis/BROTATO-COMPARISON.md) - Full Brotato comparison
- [brotato-reference.md](../../brotato-reference.md) - Brotato data dictionary
- [ADVANCEMENT-HALL-SYSTEM.md](./ADVANCEMENT-HALL-SYSTEM.md) - Leveling system
- [RADIOACTIVITY-SYSTEM.md](./RADIOACTIVITY-SYSTEM.md) - Radioactivity stat details
- [PERKS-ARCHITECTURE.md](../../core-architecture/PERKS-ARCHITECTURE.md) - Perk system hooks
