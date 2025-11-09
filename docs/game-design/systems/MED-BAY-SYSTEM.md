# Med Bay System

**Status:** Core System - All Tiers (tier-gated features)
**Date:** 2025-01-09
**Purpose:** Radioactivity management, character treatment, and stat manipulation

---

## Overview

The **Med Bay** is the scene where players manage **radioactivity** and access advanced medical treatments. It provides tier-based services ranging from basic radioactivity reduction (Free tier) to stat conversion (Subscription tier).

**Core Services:**
- 🔬 **Radioactivity Treatment** - Reduce radioactivity stat (all tiers)
- ⚡ **Afterburn Venting** - Emergency radioactivity purge (Premium/Subscription)
- 🧪 **Alchemic Crapshot** - Random stat manipulation (Premium/Subscription)
- 🔄 **MetaConvertor** - Convert one stat to another (Subscription only)
- 💥 **Complete Purge** - Remove all radioactivity (Subscription only)

**Brotato comparison:**
- 🟢 **UNIQUE TO SCRAP SURVIVOR** (Brotato has no radioactivity or medical systems)
- 🟢 **Stat manipulation is unique** (Brotato has fixed character stats per run)

---

## Radioactivity Stat

### What is Radioactivity?

**Radioactivity** is a persistent character stat that creates a **risk/reward dynamic**:
- ✅ Accumulated through **combat** (radioactive enemies), **events**, and **looting radioactive items**
- ✅ Provides **XP bonuses** at moderate levels
- ✅ Causes **combat penalties** (HP regen loss, attack misses, mob aggression) at high levels
- ✅ Enables **Afterburn** emergency ability (Premium/Subscription)
- ✅ **Must be managed** via Med Bay treatments

**Radioactivity is NOT durability** - it's a strategic stat that players can choose to embrace (high-risk builds) or purge (safe builds).

---

### Radioactivity Effects by Tier

**All Tiers (Free, Premium, Subscription):**

| Radioactivity Level | Effects |
|-------------------|---------|
| 0-14 (Low) | Minimal effects, +5% XP gain |
| 15-29 (Medium) | +10% XP gain, -10% HP regen, occasional attack misses, mobs attack faster |
| 30-49 (High) | +15% XP gain, -25% HP regen, frequent attack misses, mobs use ranged attacks only |
| 50+ (Extreme) | +20% XP gain, -50% HP regen, high attack miss rate, **chance to lose random stat point on wave clear** |

**Additional Premium Tier Effects:**

| Feature | Effect |
|---------|--------|
| Mutant Power Boost | Small chance to gain +1 Mutant Power per wave at 30+ radioactivity |
| HP Regen Mitigation | Mutant Power reduces radioactivity's HP regen penalty (1 Mutant Power = +5% HP regen) |

**Additional Subscription Tier Effects:**

| Feature | Effect |
|---------|--------|
| Afterburn Venting | Manual emergency purge (see section below) |
| WeaponFusion | 2% of radioactivity stat adds to weapon damage (10 radioactivity = +0.2 damage multiplier) |

---

## Decontamination Skill

**Decontamination** is the Med Bay proficiency skill that affects:

### Treatment Cost Reduction

```gdscript
# Base treatment cost formula
func calculate_treatment_cost(tier: String, radioactivity_amount: int) -> int:
    var base_cost = match tier:
        "free": radioactivity_amount * 50    # Expensive for Free
        "premium": radioactivity_amount * 25 # Moderate for Premium
        "subscription": radioactivity_amount * 10 # Cheap for Subscription
        _: 0

    var decontamination = PlayerStats.get_skill("decontamination")
    var reduction = decontamination / 100.0  # 1% reduction per point
    return int(base_cost * (1.0 - reduction))

# Examples (reducing 10 radioactivity):
# Free, Decontamination 0: 500 scrap
# Free, Decontamination 50: 250 scrap
# Free, Decontamination 100: FREE treatment!

# Premium, Decontamination 0: 250 scrap
# Premium, Decontamination 100: FREE treatment!
```

### Treatment Effectiveness Increase

```gdscript
# Decontamination increases radioactivity removed per treatment
func calculate_radioactivity_removed(base_removal: int, decontamination: int) -> int:
    var effectiveness_multiplier = 1.0 + (decontamination / 50.0)  # 2% per point
    return int(base_removal * effectiveness_multiplier)

# Examples (Free tier base removal = 1 point):
# Decontamination 0: 1 radioactivity removed
# Decontamination 50: 2 radioactivity removed
# Decontamination 100: 3 radioactivity removed
```

### Afterburn Cooldown Reduction (Subscription only)

```gdscript
# Decontamination reduces Afterburn cooldown
func calculate_afterburn_cooldown_waves(decontamination: int) -> int:
    var base_cooldown = 5  # 5 waves
    var reduction = decontamination / 20  # Every 20 Decontamination = -1 wave
    return max(3, base_cooldown - reduction)  # Min 3 wave cooldown

# Examples:
# Decontamination 0: 5 waves cooldown
# Decontamination 40: 3 waves cooldown (minimum)
# Decontamination 100: 3 waves cooldown (minimum)
```

---

## Radioactivity Treatment (All Tiers)

### Free Tier Treatment

**Cost:** 50 scrap per radioactivity point (affected by Decontamination skill)
**Effect:** Removes **1 radioactivity point** per treatment (increased by Decontamination)

```gdscript
# Free tier treatment
func treat_radioactivity_free(character_id: String) -> Result:
    var character = CharacterService.get_character(character_id)
    var decontamination = character.get_skill("decontamination")

    # Calculate cost
    var cost = calculate_treatment_cost("free", 1)

    if not BankingService.spend_scrap(cost):
        return Result.error("Insufficient scrap")

    # Calculate radioactivity removed
    var removed = calculate_radioactivity_removed(1, decontamination)

    # Apply reduction
    character.radioactivity = max(0, character.radioactivity - removed)

    GameLogger.info("Radioactivity reduced by %d points (cost: %d scrap)" % [removed, cost])
    return Result.success(character)
```

**Strategic Decision:**
- Free players must make **many small treatments** (1-3 points at a time)
- High Decontamination skill makes treatments FREE (100 skill = 100% cost reduction)
- Encourages investment in Decontamination skill for Free tier players

---

### Premium Tier Treatment

**Cost:** 25 scrap per radioactivity point (affected by Decontamination skill)
**Effect:** Removes **1 radioactivity point** per treatment (increased by Decontamination)

**Additional Options:**
- **Item/Weapon Radioactivity Treatment:** Reduce item/weapon radioactivity (medium scrap cost)
- **Minion Radioactivity Treatment:** Reduce minion radioactivity (large scrap cost)
- **Alchemic Crapshot:** High-risk stat manipulation (see section below)

**Why Premium is better:**
- ✅ **50% cheaper** treatments (25 scrap vs 50 scrap per point)
- ✅ **Mutant Power boost** from high radioactivity (risk/reward synergy)
- ✅ **HP regen mitigation** via Mutant Power
- ✅ **Alchemic Crapshot** access (1x per month)

---

### Subscription Tier Treatment

**Cost:** 10 scrap per radioactivity point (affected by Decontamination skill)
**Effect:** Removes **random percentage** of radioactivity (not fixed 1 point)

```gdscript
# Subscription tier treatment (percentage-based)
func treat_radioactivity_subscription(character_id: String) -> Result:
    var character = CharacterService.get_character(character_id)
    var decontamination = character.get_skill("decontamination")

    # Random percentage removal (20-40% base)
    var removal_percentage = randf_range(0.20, 0.40)

    # Decontamination increases max percentage
    removal_percentage += (decontamination / 200.0)  # +0.5% per point

    # Calculate radioactivity removed
    var removed = int(character.radioactivity * removal_percentage)
    removed = max(1, removed)  # Always remove at least 1

    # Calculate cost
    var cost = calculate_treatment_cost("subscription", removed)

    if not BankingService.spend_scrap(cost):
        return Result.error("Insufficient scrap")

    # Apply reduction
    character.radioactivity = max(0, character.radioactivity - removed)

    GameLogger.info("Radioactivity reduced by %d%% (%d points, cost: %d scrap)" % [removal_percentage * 100, removed, cost])
    return Result.success(character)
```

**Why Subscription is best:**
- ✅ **80% cheaper** than Free tier (10 scrap vs 50 scrap per point)
- ✅ **Percentage-based removal** (scales with high radioactivity)
- ✅ **Afterburn emergency ability** (see section below)
- ✅ **WeaponFusion damage boost** (2% per radioactivity point)
- ✅ **MetaConvertor stat conversion** (see section below)
- ✅ **Complete Purge** (nuclear option)

---

## Afterburn Venting (Premium/Subscription)

### What is Afterburn?

**Afterburn** is a **tier-exclusive emergency ability** that vents radioactivity explosively to kill nearby enemies.

**Two versions:**
1. **Lesser Afterburn** (Premium): Automatic, 50% reduction
2. **Greater Afterburn** (Subscription): Manual, 100% reduction

---

### Lesser Afterburn (Premium Tier)

**Trigger:** Automatic when character reaches **15% HP**

**Effect:**
- Radioactivity reduced by **50%**
- Kills nearby enemies based on formula: `Math.ceil(radioactivity * 0.15)`
- Example: 20 radioactivity = 3 enemies killed, radioactivity reduced to 10

**Cooldown:** 5 waves completed (affected by Decontamination skill)

**Implementation:**

```gdscript
# Premium Lesser Afterburn (automatic)
func check_lesser_afterburn_trigger(character: Character) -> void:
    if character.hp_percentage <= 0.15 and can_use_afterburn(character):
        trigger_lesser_afterburn(character)

func trigger_lesser_afterburn(character: Character) -> void:
    var radioactivity_before = character.radioactivity

    # Kill enemies (15% of radioactivity stat)
    var enemies_killed = int(ceil(radioactivity_before * 0.15))
    kill_nearest_enemies(character, enemies_killed)

    # Reduce radioactivity by 50%
    character.radioactivity = int(radioactivity_before * 0.5)

    # Set cooldown
    set_afterburn_cooldown(character, calculate_afterburn_cooldown_waves(character.get_skill("decontamination")))

    # Visual effects
    play_afterburn_explosion_effect(character.position, enemies_killed)

    GameLogger.info("Lesser Afterburn triggered: %d enemies killed, radioactivity %d → %d" % [enemies_killed, radioactivity_before, character.radioactivity])
```

**Why Lesser Afterburn is good:**
- ✅ **Automatic safety net** (triggers when low HP)
- ✅ **Emergency clear** (kills nearby enemies for breathing room)
- ✅ **Halves radioactivity** (mitigates penalties)
- ✅ **No manual activation** (can't forget to use it)

---

### Greater Afterburn (Subscription Tier)

**Trigger:** **Manual activation** when character is below **25% HP** (player presses button)

**Effect:**
- Radioactivity reduced to **0** (complete purge)
- Kills nearby enemies based on formula: `Math.ceil(radioactivity * 0.25 * wave_multiplier)`
- Example (Wave 10): 20 radioactivity × 25% × 1.5 (wave 10 multiplier) = 7-8 enemies killed

**Cooldown:** 5 waves completed (affected by Decontamination skill, min 3 waves)

**Implementation:**

```gdscript
# Subscription Greater Afterburn (manual)
func can_activate_greater_afterburn(character: Character) -> bool:
    if character.hp_percentage > 0.25:
        return false  # Must be below 25% HP

    if not can_use_afterburn(character):
        return false  # Cooldown active

    return true

func activate_greater_afterburn(character: Character) -> Result:
    if not can_activate_greater_afterburn(character):
        return Result.error("Cannot activate Afterburn (HP too high or on cooldown)")

    var radioactivity_before = character.radioactivity

    # Kill enemies (25% of radioactivity stat, scaled by wave)
    var wave_number = GameState.current_wave
    var wave_multiplier = 1.0 + (wave_number / 20.0)  # Scales with wave progression
    var enemies_killed = int(ceil(radioactivity_before * 0.25 * wave_multiplier))
    kill_nearest_enemies(character, enemies_killed)

    # Reduce radioactivity to 0
    character.radioactivity = 0

    # Set cooldown
    set_afterburn_cooldown(character, calculate_afterburn_cooldown_waves(character.get_skill("decontamination")))

    # Server-side cooldown validation (security)
    await validate_afterburn_cooldown_server(character.id)

    # Visual effects
    play_greater_afterburn_explosion_effect(character.position, enemies_killed)

    GameLogger.info("Greater Afterburn activated: %d enemies killed, radioactivity %d → 0" % [enemies_killed, radioactivity_before])
    return Result.success(character)
```

**Why Greater Afterburn is powerful:**
- ✅ **Manual control** (save for boss waves, emergencies)
- ✅ **100% radioactivity purge** (complete reset)
- ✅ **Scales with wave progression** (more enemies killed at later waves)
- ✅ **Strategic depth** (when to activate? save it? use now?)
- ✅ **Server-validated cooldown** (prevents exploits)

**Balancing:**
- Requires **skill expression** (player must choose when to activate)
- **Trade-off:** Using early for safety vs saving for boss wave
- **Risk:** If player dies before using, wasted opportunity

---

## Alchemic Crapshot (Premium/Subscription)

### High-Risk Stat Manipulation

**Alchemic Crapshot** is a **gambling minigame** that randomly modifies character stats.

**Availability:**
- **Premium:** 1x per month
- **Subscription:** 1x per 2 weeks

**Cost:** Large scrap amount (500-1000 scrap, based on player tier)

**Effect:** Randomly add/reduce points of a random stat

### How Alchemic Crapshot Works

```gdscript
# Alchemic Crapshot minigame
func activate_alchemic_crapshot(character: Character) -> Result:
    # Check availability (server-validated)
    if not can_use_alchemic_crapshot(character):
        return Result.error("Alchemic Crapshot not available (check cooldown)")

    # Deduct cost
    var cost = get_alchemic_crapshot_cost(character.tier)
    if not BankingService.spend_scrap(cost):
        return Result.error("Insufficient scrap")

    # Luck influences outcome
    var luck = character.get_stat("luck")
    var luck_bonus = luck / 100.0  # 1% better odds per luck point

    # Radioactivity chaos factor
    var radioactivity_chaos = character.radioactivity / 50.0  # Higher radioactivity = more chaos

    # Roll for outcome
    var outcome_roll = randf()

    var result = {}
    if outcome_roll < (0.05 + luck_bonus):
        # Ultra rare: Percentage change (5% base, improved by luck)
        result = apply_percentage_stat_change(character, radioactivity_chaos)
    elif outcome_roll < (0.50 + luck_bonus):
        # Common: Positive stat change (50% base, improved by luck)
        result = apply_positive_stat_change(character, radioactivity_chaos)
    else:
        # Failure: Negative stat change
        result = apply_negative_stat_change(character, radioactivity_chaos)

    # Set cooldown
    set_alchemic_crapshot_cooldown(character)

    GameLogger.info("Alchemic Crapshot result: %s" % result.description)
    return Result.success(result)

func apply_percentage_stat_change(character: Character, chaos: float) -> Dictionary:
    # Ultra rare: +/- percentage of a random stat
    var stat_name = get_random_stat()
    var current_value = character.get_stat(stat_name)

    # Chaos increases range (-50% to +50% base, chaos adds variance)
    var percentage = randf_range(-0.50 - chaos, 0.50 + chaos)
    var change = int(current_value * percentage)

    character.modify_stat(stat_name, change)

    return {
        "type": "percentage",
        "stat": stat_name,
        "change": change,
        "description": "%s %s by %d%% (%+d)" % [stat_name, "increased" if change > 0 else "decreased", abs(percentage * 100), change]
    }

func apply_positive_stat_change(character: Character, chaos: float) -> Dictionary:
    var stat_name = get_random_stat()

    # Positive change (1-5 points, chaos adds variance)
    var change = int(randf_range(1, 5 + chaos))

    character.modify_stat(stat_name, change)

    return {
        "type": "positive",
        "stat": stat_name,
        "change": change,
        "description": "%s increased by %d" % [stat_name, change]
    }

func apply_negative_stat_change(character: Character, chaos: float) -> Dictionary:
    var stat_name = get_random_stat()

    # Negative change (-1 to -5 points, chaos increases loss)
    var change = -int(randf_range(1, 5 + chaos))

    character.modify_stat(stat_name, change)

    return {
        "type": "negative",
        "stat": stat_name,
        "change": change,
        "description": "%s decreased by %d" % [stat_name, abs(change)]
    }
```

**Why Alchemic Crapshot is exciting:**
- ✅ **High stakes gambling** (risk big scrap for stat gains)
- ✅ **Luck stat matters** (improves odds)
- ✅ **Radioactivity influences chaos** (high radioactivity = wilder results)
- ✅ **Ultra rare jackpot** (percentage stat changes = massive gains)
- ✅ **Memorable moments** (players will talk about crazy results)

---

## MetaConvertor (Subscription Only)

### Stat Conversion System

**MetaConvertor** allows Subscription players to **convert one stat to another** using a **punishing ratio**.

**Example:** Take 3 HP → Gain 1 Damage

**Cost:** Variable scrap cost based on stats involved

**Restrictions:**
- ❌ **CANNOT convert TO Mutant Power** (Mutant Power can only be gained through radioactivity exposure/items)
- ✅ Can convert FROM any stat
- ✅ Can convert TO any stat (except Mutant Power)

### How MetaConvertor Works

```gdscript
# MetaConvertor stat conversion
func convert_stat(character: Character, from_stat: String, to_stat: String, amount: int) -> Result:
    # Verify Subscription tier
    if character.tier != "subscription":
        return Result.error("MetaConvertor requires Subscription")

    # Verify restrictions
    if to_stat == "mutant_power":
        return Result.error("Cannot convert TO Mutant Power")

    # Calculate conversion ratio (punishing, influenced by luck and radioactivity)
    var ratio = calculate_conversion_ratio(character, from_stat, to_stat)

    # Calculate cost
    var from_amount = amount * ratio
    var cost = calculate_conversion_cost(from_amount, from_stat)

    # Verify sufficient stat
    if character.get_stat(from_stat) < from_amount:
        return Result.error("Insufficient %s (need %d)" % [from_stat, from_amount])

    # Verify sufficient scrap
    if not BankingService.spend_scrap(cost):
        return Result.error("Insufficient scrap (%d required)" % cost)

    # Execute conversion
    character.modify_stat(from_stat, -from_amount)
    character.modify_stat(to_stat, amount)

    GameLogger.info("MetaConvertor: -%d %s → +%d %s (ratio: %d:1, cost: %d scrap)" % [from_amount, from_stat, amount, to_stat, ratio, cost])
    return Result.success(character)

func calculate_conversion_ratio(character: Character, from_stat: String, to_stat: String) -> int:
    # Base ratio: 3:1 (take 3, gain 1)
    var base_ratio = 3

    # Luck improves ratio (100 luck = 2:1 ratio)
    var luck = character.get_stat("luck")
    var luck_bonus = luck / 100.0  # -1 ratio per 100 luck
    base_ratio -= int(luck_bonus)

    # Radioactivity worsens ratio (high radioactivity = more chaos)
    var radioactivity_penalty = character.radioactivity / 50  # +1 ratio per 50 radioactivity
    base_ratio += radioactivity_penalty

    # Mutant Power stabilizes ratio
    var mutant_power = character.get_stat("mutant_power")
    var mutant_power_bonus = mutant_power / 10  # -1 ratio per 10 mutant power
    base_ratio -= mutant_power_bonus

    # Clamp ratio (min 2:1, max 5:1)
    return clamp(base_ratio, 2, 5)
```

**MetaConvertor Examples:**

| Character Stats | From Stat | To Stat | Amount | Conversion Ratio | From Amount | Result |
|----------------|-----------|---------|--------|------------------|-------------|--------|
| Luck 0, Rad 0, MP 0 | HP | Damage | 1 | 3:1 | -3 HP | +1 Damage |
| Luck 100, Rad 0, MP 0 | HP | Damage | 1 | 2:1 | -2 HP | +1 Damage |
| Luck 0, Rad 50, MP 0 | HP | Damage | 1 | 4:1 | -4 HP | +1 Damage |
| Luck 50, Rad 0, MP 20 | HP | Damage | 1 | 2:1 | -2 HP | +1 Damage |

**Why MetaConvertor is powerful:**
- ✅ **Minmax builds** (sacrifice unused stats for build-critical stats)
- ✅ **Endgame optimization** (fine-tune character for perfect build)
- ✅ **Luck/Mutant Power synergy** (improves conversion ratios)
- ✅ **Radioactivity counter-synergy** (high radioactivity worsens ratios)
- ✅ **Subscription exclusive** (major value proposition)

---

## Complete Purge (Subscription Only)

### Nuclear Option for Radioactivity

**Complete Purge** removes **all radioactivity** from character, items, weapons, and minions.

**Cost:** Auto-calculated based on total radioactivity across all sources

**Behavior:**
- Deducts scrap until balance exhausted (won't leave player with debt)
- Removes radioactivity from ALL sources (character, items, weapons, minions)
- Emergency reset button for players who over-invested in radioactivity

**Implementation:**

```gdscript
# Complete Purge (subscription only)
func complete_purge(character: Character) -> Result:
    # Verify Subscription tier
    if character.tier != "subscription":
        return Result.error("Complete Purge requires Subscription")

    # Calculate total radioactivity
    var total_radioactivity = 0
    total_radioactivity += character.radioactivity

    # Add item/weapon radioactivity
    for item in character.inventory:
        total_radioactivity += item.radioactivity

    # Add minion radioactivity
    for minion in character.minions:
        total_radioactivity += minion.radioactivity

    # Calculate cost (10 scrap per radioactivity point, scaled by Decontamination)
    var decontamination = character.get_skill("decontamination")
    var base_cost = total_radioactivity * 10
    var cost = calculate_treatment_cost("subscription", base_cost)

    # Cap cost at available scrap (won't leave player broke)
    var available_scrap = BankingService.get_total_scrap(character.id)
    var final_cost = min(cost, available_scrap)

    # Deduct scrap
    BankingService.spend_scrap(final_cost)

    # Remove ALL radioactivity
    character.radioactivity = 0
    for item in character.inventory:
        item.radioactivity = 0
    for minion in character.minions:
        minion.radioactivity = 0

    GameLogger.info("Complete Purge: Removed %d total radioactivity (cost: %d scrap)" % [total_radioactivity, final_cost])
    return Result.success(character)
```

**Why Complete Purge exists:**
- ✅ **Emergency reset** (when radioactivity gets out of control)
- ✅ **Build pivot** (switch from high-radioactivity to safe build)
- ✅ **New player friendly** (won't trap players in radioactivity spiral)
- ✅ **Subscription exclusive** (major convenience feature)

---

## Med Bay Scene Layout

### Scene Structure

```
MedBayScene
├── Header
│   └── "Med Bay - [Character Name]"
├── Navigation Tabs
│   ├── Radioactivity Treatment
│   ├── Afterburn (Premium/Subscription only)
│   ├── Alchemic Crapshot (Premium/Subscription only)
│   ├── MetaConvertor (Subscription only)
│   └── Complete Purge (Subscription only)
├── Character Stats Display (Top-right)
│   ├── Radioactivity: [amount]
│   ├── Decontamination Skill: [level]
│   ├── Mutant Power: [amount] (Premium+)
│   └── Afterburn Cooldown: [waves remaining]
└── Active Tab Content
```

---

### Radioactivity Treatment Tab

```
[Radioactivity Treatment]

Current Radioactivity: 35 (High)

Effects:
- +15% XP Gain
- -25% HP Regeneration
- Frequent attack misses
- Mobs use ranged attacks only

Treatment Options:
┌────────────────────────────────────┐
│ Reduce Radioactivity                │
│                                     │
│ Cost: 175 scrap (35 radioactivity) │
│   (Decontamination 50: -50% cost)  │
│                                     │
│ Removal: 2 points per treatment    │
│   (Decontamination 50: +100%)      │
│                                     │
│ [Treat Once (-2 rad)]              │
│ [Treat All (17 treatments)]        │
└────────────────────────────────────┘

💡 Tip: Invest in Decontamination skill for cheaper, more effective treatments!
```

---

### Afterburn Tab (Premium/Subscription)

```
[Afterburn Venting]

💎 Subscription Feature

Current Radioactivity: 35

Greater Afterburn (Manual):
┌────────────────────────────────────┐
│ Trigger: Below 25% HP               │
│ Effect: Radioactivity → 0          │
│ Enemies Killed: ~13 (35 rad × 25% ×│
│   1.5 wave multiplier)              │
│                                     │
│ Cooldown: 3 waves (Decontamination │
│   60: -2 waves)                     │
│                                     │
│ Status: READY ✓                    │
│                                     │
│ [Activate Afterburn]                │
│   (Requires <25% HP during combat)  │
└────────────────────────────────────┘

Lesser Afterburn (Premium - Automatic):
- Triggers automatically at 15% HP
- Radioactivity reduced by 50%
- Cooldown: 3 waves
```

---

### Alchemic Crapshot Tab (Premium/Subscription)

```
[Alchemic Crapshot]

🎲 High-Risk Stat Manipulation

Cost: 500 scrap
Availability: 1x per 2 weeks (Subscription)

Your Stats:
- Luck: 75 (+25% better odds)
- Radioactivity: 35 (+70% chaos)

Possible Outcomes:
┌────────────────────────────────────┐
│ 🟢 Ultra Rare (30% chance):        │
│    +/- percentage of random stat   │
│    Example: +50% Damage, -25% HP   │
│                                     │
│ 🟡 Positive (50% chance):          │
│    +1 to +5 random stat            │
│                                     │
│ 🔴 Negative (20% chance):          │
│    -1 to -5 random stat            │
└────────────────────────────────────┘

⚠️ Warning: This is gambling! Results are random!

[Roll Alchemic Crapshot]
```

---

### MetaConvertor Tab (Subscription Only)

```
[MetaConvertor]

💎 Subscription Feature

Convert one stat to another:

From Stat: [HP ▼]
  Current: 150

To Stat: [Damage ▼]
  Current: 25

Amount to Gain: [_____]

Conversion Ratio: 2:1
  (Luck 75: -1 ratio)
  (Mutant Power 20: -1 ratio)

Example:
  +1 Damage costs -2 HP

Scrap Cost: 100

[Convert Stats]

⚠️ Note: Cannot convert TO Mutant Power
```

---

### Complete Purge Tab (Subscription Only)

```
[Complete Purge]

💎 Subscription Feature

Remove ALL radioactivity:

Total Radioactivity:
- Character: 35
- Items: 15 (3 items)
- Weapons: 10 (2 weapons)
- Minions: 5 (1 minion)
────────────────
Total: 65 radioactivity

Cost: 325 scrap
  (65 radioactivity × 10 scrap, -50% Decontamination)

⚠️ Warning: This will remove ALL radioactivity from ALL sources!

[Execute Complete Purge]
```

---

## Balancing Considerations

### Radioactivity Risk/Reward

**Problem:** Radioactivity should feel strategic, not punishing

**Solution:** XP bonuses at all levels
- Low (0-14): +5% XP
- Medium (15-29): +10% XP
- High (30-49): +15% XP
- Extreme (50+): +20% XP

**Result:** Players can choose high-radioactivity builds for faster leveling

---

### Afterburn Power Budget

**Lesser Afterburn (Premium):**
- Kills ~3 enemies at 20 radioactivity
- Halves radioactivity (20 → 10)
- 5 wave cooldown (reduced by Decontamination)
- **Conclusion:** Safety net, not overpowered

**Greater Afterburn (Subscription):**
- Kills ~7-8 enemies at 20 radioactivity (Wave 10)
- Completely purges radioactivity (20 → 0)
- Requires manual activation below 25% HP
- **Conclusion:** Powerful strategic tool, requires skill

**Balance:**
- ✅ **Subscription gets more control** (manual trigger)
- ✅ **Scales with wave** (stays relevant in late game)
- ✅ **Server-validated cooldown** (prevents exploits)

---

### Decontamination Skill Scaling

**At 100 Decontamination:**
- Treatment costs: **FREE** (100% reduction)
- Radioactivity removed: **3x** (3 points per treatment)
- Afterburn cooldown: **3 waves** (minimum)

**Power Budget:**
- Requires **heavy skill investment** (100 points in Decontamination)
- **Opportunity cost:** Not investing in combat stats
- **Endgame payoff:** FREE radioactivity management

---

## Analytics Tracking

### Key Metrics

**Radioactivity engagement:**
- Average radioactivity level per tier (Free/Premium/Subscription)
- % of players using Med Bay per week
- Most common radioactivity level (is 15-29 optimal?)

**Afterburn usage:**
- % of Premium players triggering Lesser Afterburn
- % of Subscription players using Greater Afterburn
- Average Afterburn cooldown duration (Decontamination impact)

**Alchemic Crapshot:**
- % of Premium/Subscription players using per month
- Average luck stat of users (does high luck correlate with usage?)
- Outcome distribution (are odds balanced?)

**MetaConvertor:**
- % of Subscription players using per month
- Most common stat conversions (HP → Damage? Speed → Melee?)
- Average conversion ratios (does luck/mutant power matter?)

**Conversion:**
- Free → Premium conversion driven by Afterburn FOMO
- Premium → Subscription conversion driven by Greater Afterburn + MetaConvertor

---

## Open Questions

**For discussion:**
1. Should radioactivity decay over time (passive reduction)?
   - **Recommendation:** No, forces engagement with Med Bay

2. Should Alchemic Crapshot guarantee positive outcome for Subscription?
   - **Recommendation:** No, gambling should have risk

3. Should MetaConvertor have a maximum usage per month?
   - **Recommendation:** Yes, 5x per month (prevents abuse)

4. Should Complete Purge remove Mutant Power as well?
   - **Recommendation:** No, Mutant Power is a reward stat

---

## Summary

The Med Bay System provides:
- ✅ **Radioactivity management** (strategic stat with risk/reward)
- ✅ **Decontamination skill** (reduces costs, increases effectiveness)
- ✅ **Afterburn emergency ability** (Premium/Subscription exclusive)
- ✅ **Stat manipulation** (Alchemic Crapshot, MetaConvertor)
- ✅ **Tier differentiation** (Free = expensive, Premium = moderate, Subscription = powerful tools)

**Med Bay is a unique system** that creates strategic depth through radioactivity management and provides compelling Premium/Subscription features.

---

## References

- [STAT-SYSTEM.md](./STAT-SYSTEM.md) - Decontamination skill, Radioactivity stat, Mutant Power
- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Afterburn, MetaConvertor tier features
- [TIER-EXPERIENCE.md](./TIER-EXPERIENCE.md) - Free/Premium/Subscription value propositions
