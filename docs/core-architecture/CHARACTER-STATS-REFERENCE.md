# Character Stats Reference

**Version**: 2.0 (Week 7 Expansion)
**Last Updated**: 2025-01-09
**Total Stats**: 14 (8 base + 6 new)

---

## Overview

This document defines all character stats in Scrap Survivor. Stats drive combat effectiveness, survivability, utility, and aura power.

**Design Philosophy**:
- Stats are **additive** (base + modifiers from items/perks/character type)
- Most stats have **no caps** (except dodge, life steal)
- Stats should feel **impactful** (+1 to a stat = noticeable gameplay change)
- **Resonance** is unique (drives aura system, not found in Brotato)

---

## 📊 Complete Stat List

### Core Survival Stats (4 stats)

| Stat | Default | Cap | Description | Source |
|------|---------|-----|-------------|--------|
| **max_hp** | 100 | None | Maximum health points | Base, items, perks |
| **hp_regen** | 0 | None | HP restored per second during waves | Items, perks, Tank type |
| **life_steal** | 0.0% | 90% | % of damage converted to HP | Items, perks |
| **armor** | 0 | None | Damage reduction (formula TBD) | Base, items, Tank type |

**Notes**:
- `hp_regen` applies **during combat** (not between waves)
- `life_steal` capped at 90% (prevents immortality, matches Brotato)
- `armor` formula: `damage_taken = base_damage * (1 - armor / (armor + 100))` (diminishing returns)

---

### Offense Stats (6 stats)

| Stat | Default | Cap | Description | Source |
|------|---------|-----|-------------|--------|
| **damage** | 10 | None | Base damage multiplier (affects all weapons) | Base, items, perks |
| **melee_damage** | 0 | None | Bonus damage for melee weapons only | Items, perks, Commando type |
| **ranged_damage** | 0 | None | Bonus damage for ranged weapons only | Items, perks, Commando type |
| **attack_speed** | 0.0% | None | % cooldown reduction for weapons | Items, perks, Commando type |
| **crit_chance** | 5% | 100% | % chance to deal critical hit | Base, items, perks |
| **resonance** | 0 | None | Aura effectiveness multiplier (NEW STAT) | Items, perks, Mutant type |

**Notes**:
- `damage` applies to **all weapons** (universal multiplier)
- `melee_damage` / `ranged_damage` are **additive with damage** (not multiplicative)
- `attack_speed` formula: `actual_cooldown = base_cooldown * (1 - attack_speed%)`
- `resonance` drives **aura power** (see AURA-SYSTEM.md for calculations)

**Example Damage Calculation**:
```gdscript
# Weapon: Sword (melee, 20 base damage)
# Character stats: damage=10, melee_damage=5, crit_chance=15%

var total_damage = 20 + 10 + 5  # = 35 damage
if randf() < 0.15:  # 15% crit chance
    total_damage *= 2.0  # Crit multiplier (x2 default)
# Final: 35 damage (70 on crit)
```

---

### Defense Stats (2 stats)

| Stat | Default | Cap | Description | Source |
|------|---------|-----|-------------|--------|
| **armor** | 0 | None | Damage reduction | Base, items, Tank type |
| **dodge** | 0.0% | 90% | % chance to avoid damage entirely | Base, items, perks |

**Notes**:
- `dodge` capped at 90% (prevents unkillable builds)
- Dodge is **binary** (0 damage on success, full damage on fail)
- Armor applies **after dodge fails**

---

### Utility Stats (4 stats)

| Stat | Default | Cap | Description | Source |
|------|---------|-----|-------------|--------|
| **speed** | 200 | None | Movement speed (pixels per second) | Base, items, Tank penalty |
| **luck** | 0 | None | Increases rare drops, crit chance, proc rates | Base, items, Scavenger type |
| **pickup_range** | 100 | None | Auto-collect radius (also affects aura radius) | Base, items, Scavenger type |
| **scavenging** | 0 | 50% | % multiplier for currency drops (scrap, components, nanites) | Base, items, Scavenger type |

**Notes**:
- `speed` is **literal pixels per second** (200 = default walk speed)
- `luck` affects:
  - Crit chance: +1% per 10 luck
  - Rare drops: +2% per 10 luck
  - Proc rates: +1% per 10 luck (for items with "chance to...")
- `pickup_range` **doubles as aura radius** (efficient stat synergy)
- `scavenging` capped at +50% bonus (prevents infinite economy exploits)

**Scavenging Formula**:
```gdscript
func apply_scavenging_bonus(base_amount: int, scavenging_stat: int) -> int:
    var multiplier = 1.0 + min(scavenging_stat * 0.05, 0.50)  # +5% per point, max +50%
    return int(base_amount * multiplier)

# Example: Kill enemy drops 10 scrap, character has scavenging=8
# Result: 10 * (1.0 + 0.40) = 14 scrap
```

---

## 🎭 Character Type Stat Modifiers

### Scavenger (FREE Tier)
```gdscript
{
    "scavenging": +5,        # +25% currency drops (5 * 5%)
    "pickup_range": +20      # 120 total (100 base + 20)
}
```
**Theme**: Economy specialist, efficient resource gatherer
**Aura**: Collect (auto-pickup currency/items)

---

### Tank (PREMIUM Tier)
```gdscript
{
    "max_hp": +20,           # 120 total HP
    "armor": +3,             # Damage reduction
    "speed": -20             # 180 total speed (penalty)
}
```
**Theme**: High survivability, slow tank
**Aura**: Shield (+2 armor bonus while in aura)

---

### Commando (SUBSCRIPTION Tier)
```gdscript
{
    "ranged_damage": +5,     # +5 bonus ranged damage
    "attack_speed": +15,     # +15% cooldown reduction
    "armor": -2              # Glass cannon penalty
}
```
**Theme**: High DPS, glass cannon
**Aura**: None (trade-off for raw damage)

---

### Mutant (SUBSCRIPTION Tier, Week 8)
```gdscript
{
    "resonance": +10,        # +10 aura power (massive boost)
    "luck": +5,              # +5% crit, +10% rare drops
    "pickup_range": +20      # Synergizes with aura radius
}
```
**Theme**: Mutation specialist, powerful auras
**Aura**: Damage (scales with resonance)

---

## 📈 Level-Up Stat Gains

### Auto-Distributed Per Level
```gdscript
const LEVEL_UP_STAT_GAINS = {
    "max_hp": 5,        # +5 HP per level
    "damage": 2,        # +2 damage per level
    "armor": 1,         # +1 armor per level
    "scavenging": 1     # +1 scavenging per level (economy growth)
}
```

**Rationale**:
- **max_hp** scales fastest (survivability priority for mobile)
- **damage** scales moderately (keep combat challenging)
- **armor** scales slowly (diminishing returns formula)
- **scavenging** scales to keep economy relevant (no +resonance to keep auras special)

**Level 20 Stats** (no items/perks):
```
Scavenger (base + 19 levels + type modifiers):
- Max HP: 100 + (19*5) + 0 = 195 HP
- Damage: 10 + (19*2) + 0 = 48 damage
- Armor: 0 + (19*1) + 0 = 19 armor
- Scavenging: 0 + (19*1) + 5 = 24 scavenging (+120% currency, capped at +50% = 14 effective)
```

---

## 🔄 Stat Synergies

### Resonance + Pickup Range
- `pickup_range` determines **aura radius**
- `resonance` determines **aura power**
- **Synergy**: High pickup range = large aura, high resonance = strong aura
- **Example**: Mutant with 120 pickup range + 15 resonance = 120px radius damage aura dealing 12.5 damage/sec

### Life Steal + Damage
- Life steal converts % of damage to HP
- Higher damage = more HP restored
- **Synergy**: Glass cannon with life steal = sustain through offense
- **Example**: 50 damage weapon + 20% life steal = 10 HP per hit

### Scavenging + Luck
- Scavenging multiplies currency drops
- Luck increases rare drop rates
- **Synergy**: More currency + better loot = economy snowball
- **Example**: 10 scavenging (50% bonus) + 20 luck (+4% rare drops) = 15 scrap + legendary item

### Attack Speed + Crit Chance
- Attack speed = more attacks per second
- Crit chance = % of attacks are crits
- **Synergy**: Fast attacks + high crit = consistent burst damage
- **Example**: 0.5s cooldown weapon + 30% crit = 2 attacks/sec, 0.6 crits/sec

---

## ⚖️ Balance Guidelines

### Stat Value Equivalencies
**1 stat point value** (for balancing items/perks):
- **1 Max HP** = 1 point
- **1 Damage** = 1.5 points (more impactful than HP)
- **1 Armor** = 2 points (diminishing returns = high value)
- **1% Attack Speed** = 1.5 points (affects all weapons)
- **1% Crit Chance** = 1 point
- **1 Resonance** = 2 points (unique utility)
- **1 Scavenging** = 1 point (economy focused)
- **1 Luck** = 0.5 points (affects multiple systems, hard to quantify)

**Example Item Balance**:
```
Tier 2 Item (6-8 stat points):
"Rusty Shield"
+10 Max HP (10 points)
+2 Armor (4 points)
-2 Speed (penalty)
Total: 14 points - balanced for Tier 2
```

---

## 🧪 Testing Stat Changes

### Unit Test Template
```gdscript
func test_stat_modifier_applies() -> void:
    # Arrange
    var character_id = CharacterService.create_character("TestChar", "scavenger")
    var character = CharacterService.get_character(character_id)
    var base_scavenging = character.stats.scavenging  # Should be 5 (Scavenger type)

    # Act
    CharacterService.update_character(character_id, {
        "stats": {
            "scavenging": base_scavenging + 10  # Add +10 from item
        }
    })

    # Assert
    character = CharacterService.get_character(character_id)
    assert_eq(character.stats.scavenging, 15, "Should have 5 (base) + 10 (item)")
```

### Balance Testing Checklist
- [ ] Stat scales linearly (no exponential breakpoints)
- [ ] Stat is noticeable at +1 (player can feel difference)
- [ ] Stat doesn't trivialize content at +20 (still challenging)
- [ ] Stat synergizes with at least 1 other stat
- [ ] Stat has clear use case (not "nice to have")

---

## 🔗 Related Documentation

- [CHARACTER-SYSTEM.md](../game-design/systems/CHARACTER-SYSTEM.md) - Character architecture
- [AURA-SYSTEM.md](../game-design/systems/AURA-SYSTEM.md) - Resonance calculations
- [THE-LAB-SYSTEM.md](../game-design/systems/THE-LAB-SYSTEM.md) - Nanites currency (scavenging applies)
- [brotato-reference.md](../brotato-reference.md) - Brotato stat comparison
- [character_service.gd](../../scripts/services/character_service.gd) - Implementation

---

## 📊 Comparison: Scrap Survivor vs Brotato

| Stat | Scrap Survivor | Brotato | Notes |
|------|----------------|---------|-------|
| Max HP | ✅ | ✅ | Same |
| HP Regen | ✅ | ✅ | Same |
| Life Steal | ✅ | ✅ | Same (90% cap) |
| Damage | ✅ | ✅ | Same |
| Melee Damage | ✅ | ✅ | Same |
| Ranged Damage | ✅ | ✅ | Same |
| Elemental Damage | ❌ | ✅ | We use **Resonance** for auras instead |
| Attack Speed | ✅ | ✅ | Same |
| Crit Chance | ✅ | ✅ | Same |
| Crit Damage | ❌ | ✅ | Simplified (always x2 crit) |
| Engineering | ❌ | ✅ | We use **Biotech** (The Lab skill, not stat) |
| Range | ❌ | ✅ | We use **Pickup Range** (dual-purpose) |
| Armor | ✅ | ✅ | Same |
| Dodge | ✅ | ✅ | Same (90% cap) |
| Speed | ✅ | ✅ | Same |
| Luck | ✅ | ✅ | Same |
| Harvesting | ❌ | ✅ | We use **Scavenging** (thematic fit) |
| Knockback | ❌ | ✅ | Weapon-specific, not character stat |
| XP Gain | ❌ | ✅ | Could add later if needed |
| **Resonance** | ✅ | ❌ | **Unique to Scrap Survivor** |

**Key Differences**:
- ✅ **Resonance** replaces "Elemental Damage" (unique aura system)
- ✅ **Scavenging** replaces "Harvesting" (thematic, affects 3 currencies)
- ✅ **Pickup Range** doubles as aura radius (efficient design)
- ❌ No "Engineering" stat (we have Biotech skill in The Lab instead)
- ❌ No "Range" stat (pickup range is more versatile)

---

## ✅ Approval Status

**Approved By**: Alan (2025-01-09)
**Key Decisions**:
- ✅ 14 total stats (8 base + 6 new)
- ✅ "Resonance" for aura effectiveness
- ✅ "Scavenging" for economy (replaces Harvesting)
- ✅ "Pickup Range" dual-purpose (pickup + aura radius)
- ✅ Auto-distribute level-up stats (no player choice yet)

**Ready for Implementation**: 🚀 Yes

---

**Document Version**: 2.0
**Last Updated**: 2025-01-09
**Next Review**: After Week 7 implementation
