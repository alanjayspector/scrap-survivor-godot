# Advancement Hall System

**Status:** Draft - Based on Brotato Comparison
**Date:** 2025-01-09
**Purpose:** Character leveling and stat progression system

---

## Overview

The Advancement Hall is Scrap Survivor's character progression system. Players gain experience during runs and level up, choosing stat boosts that shape their build. This system is inspired by Brotato's leveling system while adding unique tier-based restrictions and radioactivity interactions.

---

## Core Mechanics

### Experience & Leveling

**XP Sources:**
- Wave completion (primary source)
- Enemy kills (minor source)
- Goal completion (bonus XP)
- Special events (seasonal XP multipliers)

**Leveling Progression:**
- **20 levels per run** (same as Brotato)
- Each level unlocks stat choice
- XP required increases per level (exponential curve)
- Character reaches max level ~wave 18-20 (normal difficulty)

**Level Curve (Draft):**
```
Level 1:  100 XP
Level 2:  150 XP
Level 3:  200 XP
Level 5:  300 XP
Level 10: 600 XP
Level 15: 900 XP
Level 20: 1200 XP
```

---

## Stat Selection

### Available Stats (Player Choice)

Each level, player chooses **+1 to ONE stat:**

| Stat | Effect | Tier Availability |
|------|--------|-------------------|
| **Max HP** | +1 Max HP | All tiers |
| **HP Regeneration** | +1 HP/sec | All tiers |
| **Damage** | +1% general damage | All tiers |
| **Melee Damage** | +1 Melee DMG | All tiers |
| **Ranged Damage** | +1 Ranged DMG | All tiers |
| **Elemental Damage** | +1 Elemental DMG | Premium+ |
| **Attack Speed** | +1% Attack Speed | All tiers |
| **Crit Chance** | +1% Crit Chance | Premium+ |
| **Engineering** | +1 Engineering | Premium+ |
| **Range** | +5 Range | All tiers |
| **Armor** | +1 Armor | All tiers |
| **Dodge** | +1% Dodge | Premium+ |
| **Speed** | +1% Movement Speed | All tiers |
| **Luck** | +1 Luck | All tiers |
| **Harvesting** | +1% Harvesting | All tiers |

**Free Tier Restrictions:**
- Limited to basic stats (HP, Damage, Melee, Ranged, Attack Speed, Range, Armor, Speed, Luck, Harvesting)
- Cannot level: Elemental Damage, Crit Chance, Engineering, Dodge

**Premium/Subscription:**
- Access to all stats
- No restrictions

---

## Advancement Hall Scene

### When It Appears

**Timing:**
- Between waves (after shop, before next wave)
- Only appears when player has unspent level
- Can skip (auto-apply random stat) if player doesn't choose

**UI Flow:**
```
Wave Complete
  ↓
XP Gained (level up notification)
  ↓
Shop Scene
  ↓
Advancement Hall (if level available)
  ↓
Next Wave
```

---

### UI Design (Godot Implementation)

**Layout:**
- **Center Panel:** Character portrait + current stats
- **Left Side:** Available stat choices (scrollable list)
- **Right Side:** Stat comparison (current vs. after upgrade)
- **Bottom:** "Confirm Choice" button + "Skip" button

**Stat Display Format:**
```
Max HP: 100 → 101 (+1)
Damage: 10 → 11 (+1)
Speed: 100% → 101% (+1%)
```

**Accessibility:**
- Controller support (d-pad navigation)
- Touch-friendly buttons (60x60px minimum)
- Clear visual feedback on selection

---

## Tier-Based Limitations

### Free Tier

**Advancement Limits:**
- **5 advancements per character per run**
- After 5 advancements, no more level-ups available
- Levels 6-20 grant XP but no stat choices

**Restriction Rationale:**
- Encourages Premium upgrade for full build potential
- Still allows meaningful progression
- Doesn't completely gate leveling

**Example Run (Free Tier):**
```
Level 1: +1 Max HP
Level 2: +1 Damage
Level 3: +1 Attack Speed
Level 4: +1 Armor
Level 5: +1 Luck
Levels 6-20: No more advancements
```

---

### Premium Tier

**Advancement Limits:**
- **15 advancements per character per run**
- Reaches level cap ~wave 15-18
- Access to advanced stats (Elemental, Crit, Engineering, Dodge)

**Value Proposition:**
- 3x more advancements than Free
- Build variety significantly increased
- Can complete full builds

---

### Subscription Tier

**Advancement Limits:**
- **20 advancements per character per run** (unlimited)
- Full leveling experience
- All 20 levels = 20 stat choices

**Value Proposition:**
- No restrictions
- Maximum build flexibility
- Late-game power scaling

---

## Radioactivity Interaction

### Radioactivity as Modifier

**Radioactivity Stat Effects on Advancement:**
- **0-20 Radioactivity:** No effect
- **21-40 Radioactivity:** +5% XP gain per level
- **41-60 Radioactivity:** +10% XP gain per level
- **61-80 Radioactivity:** +15% XP gain per level, BUT -1 random stat per 3 levels
- **81-100 Radioactivity:** +20% XP gain per level, BUT -1 random stat per 2 levels

**Trade-off:**
- High radioactivity = faster leveling
- BUT risk of stat loss
- Creates risk/reward decision

**Example (60 Radioactivity):**
```
Level 1: +1 Max HP
Level 2: +1 Damage
Level 3: +1 Attack Speed, -1 Luck (random)
Level 4: +1 Armor
Level 5: +1 Speed
Level 6: +1 HP Regen, -1 Range (random)
```

---

## Special Character Exceptions

### Character-Specific Advancement Rules

**Inspired by Brotato's unique characters:**

**Example: "Baby" Character**
- Instead of stat choice, gains **+1 weapon slot** per level
- Max: 24 weapon slots (vs 6 default)
- Trade-off: +30% XP required per level

**Example: "Apprentice" Character**
- Auto-levels: +2 Melee, +1 Ranged, +1 Elemental, +1 Engineering per level
- Trade-off: -2 Max HP per level

**Example: "Captain" Character**
- +100% stat gains per level (+2 to chosen stat instead of +1)
- Trade-off: +200% XP required

**Future Design:**
- Add 5-10 characters with unique advancement mechanics
- Increases build variety
- High skill ceiling

---

## Comparison to Brotato

### What We Match

✅ **20 levels per run** (same)
✅ **+1 stat choice per level** (same)
✅ **Player choice-driven** (same)
✅ **Character-specific exceptions** (same concept)

### What We Add

🟢 **Tier-based restrictions** (Free: 5, Premium: 15, Subscription: 20)
🟢 **Radioactivity interaction** (risk/reward modifier)
🟢 **Premium stats** (Elemental, Crit, Engineering, Dodge gated)

### What We Should Consider Adding

🟡 **Stat respec** (Brotato doesn't have this either, but could be Premium/Sub feature)
🟡 **Preset builds** (save stat progression for quick selection)

---

## Technical Implementation (Godot)

### Data Structure

```gdscript
# Character advancement state
class_name CharacterAdvancement
extends Resource

var current_level: int = 0
var current_xp: int = 0
var advancements_used: int = 0
var advancement_limit: int = 5  # Based on tier
var stat_choices: Array[String] = []  # History of choices
var radioactivity_penalties: Array[Dictionary] = []  # Track random stat losses

func can_level_up() -> bool:
    return advancements_used < advancement_limit

func apply_stat_choice(stat: String) -> void:
    advancements_used += 1
    stat_choices.append(stat)
    # Apply stat boost via signal
    stat_changed.emit(stat, 1)
```

### Signals

```gdscript
# AdvancementService.gd (autoload)
signal level_up_available(level: int)
signal stat_chosen(stat: String, value: int)
signal advancement_limit_reached(tier: String)
signal radioactivity_penalty_applied(stat: String, value: int)
```

### Perk Hooks

```gdscript
# Pre-hook: Modify XP gain
signal advancement_xp_gain_pre(context: Dictionary)
# context: { base_xp: 100, radioactivity: 50 }

# Post-hook: Modify stat choice
signal advancement_stat_choice_post(context: Dictionary)
# context: { stat: "damage", value: 1 }

# Event hook: Level up occurred
signal advancement_level_up_event(context: Dictionary)
# context: { level: 5, character_id: "abc123" }
```

**Perks Example:**
- "XP Boost" perk: +25% XP gain (modifies `advancement_xp_gain_pre`)
- "Double Stats" perk: +2 to chosen stat instead of +1 (modifies `advancement_stat_choice_post`)
- "Radioactivity Immunity" perk: No stat penalties from radioactivity

---

## Balancing Considerations

### XP Curve Tuning

**Goals:**
- Player reaches level 20 by wave 20 (normal difficulty)
- Player reaches level 15 by wave 20 (hard difficulty)
- Player reaches level 10 by wave 20 (Danger 5)

**Tuning Knobs:**
- Base XP per wave
- XP scaling per wave
- Enemy kill XP bonus
- Character-specific XP modifiers

---

### Tier Limitation Tuning

**Free Tier (5 advancements):**
- Should feel meaningful (can complete basic build)
- Should create upgrade desire (want more flexibility)
- Test target: 60% of Free players feel satisfied, 40% want Premium

**Premium Tier (15 advancements):**
- Should feel generous (can complete advanced builds)
- Should create Subscription desire (want perfect builds)
- Test target: 80% of Premium players feel satisfied, 20% want Subscription

**Subscription Tier (20 advancements):**
- Should feel unlimited (no restrictions)
- Test target: 95% of Subscription players feel satisfied

---

## Future Enhancements

### Post-Launch Features

**V1.1 (3 months):**
- Add 5 characters with unique advancement mechanics
- Add "Preset Builds" (save/load stat choices)
- Add advancement history (see past choices per character)

**V1.2 (6 months):**
- Add "Advancement Respec" (Premium/Subscription feature, 1/day)
- Add "Advancement Challenges" (daily goals like "Level up using only HP stats")
- Add advancement leaderboards (highest stats reached)

**V1.3 (12 months):**
- Add "Advancement Perks" (permanent modifiers, unlocked via achievements)
- Add "Advancement Synergies" (bonus for choosing related stats)
- Add advancement milestones (every 5 levels = bonus reward)

---

## Open Questions

**For Discussion:**
1. Should Free tier get 5 or 10 advancements?
2. Should radioactivity penalties be random or player-chosen?
3. Should we add stat respec as Premium/Subscription feature?
4. Should character-specific advancement exceptions be tier-gated?
5. Should we match Brotato's simplicity (20 levels, no restrictions) or differentiate with tier limits?

---

## Summary

The Advancement Hall provides:
- ✅ Clear, Brotato-inspired leveling (20 levels, +1 stat each)
- ✅ Tier-based monetization (5/15/20 advancement limits)
- ✅ Radioactivity risk/reward interaction
- ✅ Character-specific exceptions for variety
- ✅ Perk system integration (50+ hook points)

**Status:** Ready for implementation after tier experience discussion.

---

**References:**
- [BROTATO-COMPARISON.md](../../competitive-analysis/BROTATO-COMPARISON.md) - Leveling system comparison
- [RADIOACTIVITY-SYSTEM.md](./RADIOACTIVITY-SYSTEM.md) - Radioactivity stat mechanics
- [PERKS-ARCHITECTURE.md](../../core-architecture/PERKS-ARCHITECTURE.md) - Hook points
