# The Lab System

**Status:** Core System - All Tiers (tier-gated features)
**Date:** 2025-01-09
**Purpose:** Consolidated hub for radioactivity management, minion crafting, and stat manipulation

---

## Overview

**The Lab** is the central scene for **biology, genetics, mutations, and mad science**. It consolidates radioactivity management, minion crafting, and stat manipulation into one thematic location.

**Core Services:**
- 🧬 **Radioactivity Treatment** - Reduce radioactivity stat (all tiers)
- 🤖 **Minion Crafting** - Create robot/bio companions (Subscription via patterns)
- ⚡ **Afterburn Venting** - Emergency radioactivity purge (Premium/Subscription)
- 🧪 **Alchemic Crapshot** - Random stat manipulation (Premium/Subscription)
- 🔄 **MetaConvertor** - Convert stats (Subscription only)
- 💥 **Complete Purge** - Remove all radioactivity (Subscription only)
- ⚗️ **Mutation Chamber** - Idle Nanite generation (Subscription only)

**Note:** Fully-formed minions can be purchased at the Black Market scene (Premium tier) - see [SHOPS-SYSTEM.md](./SHOPS-SYSTEM.md)

**Brotato comparison:**
- 🟢 **UNIQUE TO SCRAP SURVIVOR** (Brotato has no Lab, minions, or radioactivity systems)

---

## Nanites Currency

### What Are Nanites?

**Nanites** are The Lab's specialized currency for bio/mech operations:
- ✅ Earned from **killing mutated/radioactive enemies**, **dismantling minions**, **Mutation Chamber** (Subscription idle)
- ✅ Used for **minion crafting**, **radioactivity treatments**, **Alchemic Crapshot**, **MetaConvertor**
- ✅ Stored in The Lab (NOT Workshop or Bank)
- ✅ **Thematic:** Microscopic robots that repair DNA, build synthetics, cleanse radiation

**Why Nanites work for everything:**
- ✅ **Biological minions:** Nanites repair DNA, cause mutations
- ✅ **Mechanical minions:** Nanites assemble robots, repair circuits
- ✅ **Radioactivity:** Nanites cleanse radiation from cells
- ✅ **Stat manipulation:** Nanites restructure biological/mechanical systems

---

### How to Earn Nanites

**Combat:**
- Normal enemies: 1-2 Nanites
- Radioactive enemies: 5-10 Nanites
- Boss enemies: 25-50 Nanites

**Dismantling Minions:**
- Tier 1 minion: 10-15 Nanites
- Tier 2 minion: 20-30 Nanites
- Tier 3 minion: 40-60 Nanites
- Tier 4 minion: 80-120 Nanites

**Mutation Chamber (Subscription Idle System):**
- Generates 5 Nanites per hour
- Max 8 hour session = 40 Nanites
- 2 sessions per day per character
- Total: 80 Nanites per day passive (Subscription only)

---

### Nanite Storage Limits by Tier

**Free Tier:**
- Max **50 Nanites**
- **CTA:** "Lab storage full (50/50)! Upgrade to Premium for 100 Nanite storage."

**Premium Tier:**
- Max **100 Nanites**
- **CTA:** "Lab storage 85/100. Upgrade to Subscription for unlimited Nanite storage."

**Subscription Tier:**
- **Unlimited Nanites**
- "Unlimited Lab storage active."

**Why storage limits:**
- ✅ **Natural friction** (players hit limits during normal play)
- ✅ **Clear value** ("I need more storage" = upgrade incentive)
- ✅ **Non-annoying CTA** (consequence of success, not arbitrary)

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
- ✅ **Convenient for minion crafting** (withdraw exactly what you need)
- ✅ **Clear financial status** (see banked + carried in one view)

```gdscript
# ATM withdrawal (TheLabScene.gd)
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
│ Nanites: 45 / 50                    │
│ Carried Scrap: 150                  │
│ Banked Scrap: 5,000 [Withdraw All]│
│   [Withdraw 100] [Withdraw 500]     │
│ Radioactivity: 25                   │
│ Biotech Skill: 50                   │
└────────────────────────────────────┘
```

---

## Biotech Skill

**Biotech** is The Lab's proficiency skill that affects all Lab operations:

### Radioactivity Treatment Cost Reduction

```gdscript
# Base treatment cost formula
func calculate_treatment_cost(tier: String, nanites_per_rad: int, radioactivity_amount: int) -> int:
    var base_cost = radioactivity_amount * nanites_per_rad

    var biotech = PlayerStats.get_skill("biotech")
    var reduction = biotech / 100.0  # 1% reduction per point
    return int(base_cost * (1.0 - reduction))

# Nanites per radioactivity point:
# Free: 5 Nanites per rad point
# Premium: 3 Nanites per rad point
# Subscription: 1 Nanite per rad point

# Examples (reducing 10 radioactivity):
# Free, Biotech 0: 50 Nanites
# Free, Biotech 50: 25 Nanites
# Free, Biotech 100: FREE treatment!
```

### Minion Crafting Cost Reduction

```gdscript
# Minion crafting cost reduction
func calculate_minion_craft_cost(base_nanites: int, biotech: int) -> int:
    var reduction = biotech / 100.0
    return int(base_nanites * (1.0 - reduction))

# Examples (personalized T4 minion, base 100 Nanites):
# Biotech 0: 100 Nanites
# Biotech 50: 50 Nanites
# Biotech 100: FREE crafting!
```

### Minion Stat Bonuses

```gdscript
# Personalized minion stat bonus formula
func calculate_minion_stat_bonus(character_luck: int, biotech: int) -> float:
    var base_bonus = 0.10  # 10% base
    var luck_bonus = character_luck / 100.0
    var biotech_bonus = biotech / 50.0  # 2% per Biotech point
    return base_bonus + luck_bonus + biotech_bonus

# Examples:
# Luck 0, Biotech 0: 10% bonus
# Luck 50, Biotech 50: 10% + 50% + 100% = 160% bonus
# Luck 100, Biotech 100: 10% + 100% + 200% = 310% bonus
```

### Afterburn Cooldown Reduction

```gdscript
# Biotech reduces Afterburn cooldown
func calculate_afterburn_cooldown_waves(biotech: int) -> int:
    var base_cooldown = 5  # 5 waves
    var reduction = biotech / 20  # Every 20 Biotech = -1 wave
    return max(3, base_cooldown - reduction)  # Min 3 waves

# Examples:
# Biotech 0: 5 waves cooldown
# Biotech 40: 3 waves cooldown (minimum)
```

### Alchemic Crapshot Success Rate

```gdscript
# Biotech improves Alchemic Crapshot success odds
func calculate_crapshot_positive_chance(base_chance: float, biotech: int) -> float:
    var biotech_bonus = biotech / 200.0  # 0.5% per point
    return min(0.75, base_chance + biotech_bonus)  # Max 75% positive chance

# Examples:
# Biotech 0: 50% positive chance
# Biotech 50: 75% positive chance (capped)
```

---

## Radioactivity System

### Radioactivity Effects by Tier

**All Tiers:**

| Radioactivity Level | Effects |
|-------------------|---------|
| 0-14 (Low) | +5% XP gain |
| 15-29 (Medium) | +10% XP gain, -10% HP regen, occasional attack misses |
| 30-49 (High) | +15% XP gain, -25% HP regen, frequent attack misses, mobs attack faster |
| 50+ (Extreme) | +20% XP gain, -50% HP regen, high miss rate, **chance to lose random stat on wave clear** |

**Premium Tier Additions:**
- **Mutant Power Boost:** Small chance to gain +1 Mutant Power per wave at 30+ radioactivity
- **HP Regen Mitigation:** Mutant Power reduces radioactivity's HP regen penalty

**Subscription Tier Additions:**
- **Afterburn Venting:** Manual emergency radioactivity purge
- **WeaponFusion:** 2% of radioactivity adds to weapon damage

---

### Radioactivity Treatment (All Tiers)

**Free Tier:**
- **Cost:** 5 Nanites per radioactivity point (affected by Biotech skill)
- **Effect:** Removes 1 radioactivity point per treatment (increased by Biotech)

**Premium Tier:**
- **Cost:** 3 Nanites per radioactivity point
- **Effect:** Removes 1 radioactivity point per treatment
- **Bonus:** Minion/item radioactivity treatment available

**Subscription Tier:**
- **Cost:** 1 Nanite per radioactivity point
- **Effect:** Removes random percentage (20-40% base + Biotech bonus)
- **Bonus:** Complete Purge available

---

## Minion Crafting System

### Minion Patterns (Blueprint Equivalent)

**Minion Patterns** are like blueprints but for companions:
- Drop from enemies/crates (consumable)
- Unlock in Pattern Library (costs scrap, permanent)
- Three crafting types: Generic (degrading), Evolving (Subscription), Personalized (unlimited)

**Pattern Library Unlock Costs:**

| Pattern Tier | Unlock Cost |
|-------------|-------------|
| Tier 1 | FREE |
| Tier 2 | 50 scrap |
| Tier 3 | 100 scrap |
| Tier 4 | 200 scrap |

---

### Generic Minion Crafts (Degrading)

**5 crafts per pattern unlock, stats degrade with each craft:**
- Craft 1: 100% stats (50 scrap + 25 Nanites)
- Craft 2: 90% stats (50 scrap + 25 Nanites)
- Craft 3: 80% stats (50 scrap + 25 Nanites)
- Craft 4: 70% stats (50 scrap + 25 Nanites)
- Craft 5: 60% stats (50 scrap + 25 Nanites)
- **Pattern consumed after 5th craft**

```gdscript
# Generic minion crafting (degrading)
func craft_generic_minion(pattern_id: String) -> Minion:
    var pattern = PatternLibrary.get_pattern(pattern_id)
    var character_id = CurrentCharacter.id

    # Check crafts used
    var crafts_used = PatternLibrary.get_generic_crafts_used(character_id, pattern_id)
    if crafts_used >= 5:
        ToastService.show("Pattern exhausted. Use Personalization or buy new pattern.")
        return null

    # Calculate degradation
    var stat_multiplier = 1.0 - (crafts_used * 0.10)  # 100%, 90%, 80%, 70%, 60%

    # Costs
    if not BankingService.spend_scrap(50):
        return null
    if not LabService.spend_nanites(25):
        return null

    # Create minion
    var minion = MinionFactory.create_from_pattern(pattern, stat_multiplier)

    # Increment crafts
    PatternLibrary.increment_generic_crafts(character_id, pattern_id)

    MinionService.add_minion(minion)
    GameLogger.info("Generic minion crafted: %s (%.0f%% stats, %d/5 crafts)" % [minion.name, stat_multiplier * 100, crafts_used + 1])
    return minion
```

**Why degradation:**
- ✅ Creates **urgency** (craft early for best stats)
- ✅ Makes **personalization appealing** (always 100%+ stats)
- ✅ **Unique mechanic** (different from weapons)
- ✅ **Lore-friendly** (pattern degrades from use)

---

### Evolving Minion Patterns (Subscription Exclusive)

**From Atomic Vending Machine only:**
- **5 crafts, stats IMPROVE with each craft:**
  - Craft 1: 60% stats
  - Craft 2: 70% stats
  - Craft 3: 80% stats
  - Craft 4: 90% stats
  - Craft 5: 100% stats
- **Craft 6+:** 100% + random bonus (+5% to +20% random stat)
- **Pattern mastered** after X crafts (becomes regular pattern)

```gdscript
# Evolving pattern crafting (Subscription exclusive)
func craft_evolving_minion(pattern_id: String) -> Minion:
    var pattern = PatternLibrary.get_pattern(pattern_id)
    var character_id = CurrentCharacter.id

    # Verify Subscription tier
    if PlayerService.get_tier() != "subscription":
        return null

    # Check crafts used
    var crafts_used = PatternLibrary.get_evolving_crafts_used(character_id, pattern_id)

    # Calculate evolution (60% → 100% → 100%+bonuses)
    var stat_multiplier = 0.60 + (min(crafts_used, 4) * 0.10)  # Caps at 1.0

    # After 5 crafts, add random bonuses
    if crafts_used >= 5:
        stat_multiplier = 1.0 + (randf_range(0.05, 0.20))  # +5% to +20% bonus

    # Costs (same as generic)
    if not BankingService.spend_scrap(50):
        return null
    if not LabService.spend_nanites(25):
        return null

    # Create minion
    var minion = MinionFactory.create_from_pattern(pattern, stat_multiplier)

    # Increment crafts
    PatternLibrary.increment_evolving_crafts(character_id, pattern_id)

    MinionService.add_minion(minion)
    GameLogger.info("Evolving minion crafted: %s (%.0f%% stats, craft #%d)" % [minion.name, stat_multiplier * 100, crafts_used + 1])
    return minion
```

**Why evolving patterns are exciting:**
- ✅ **Progression** instead of degradation (feels good!)
- ✅ **Experimentation rewarded** (each craft gets better)
- ✅ **Subscription exclusive** (major value proposition)
- ✅ **Randomized bonuses** after mastery (exciting endgame)

---

### Personalized Minion Crafts (Unlimited)

**Unlimited crafts, always 100% base stats + bonuses:**
- **Cost:** 400 scrap + 100 Nanites (affected by Biotech)
- **Custom naming:** "Alan's Attack Drone"
- **Stat bonuses:** Based on Luck + Biotech (up to 310%)
- **Soul-bound:** Cannot transfer via Quantum Storage
- **Luck roll:** Chance for bonus ability (50% at 100 Luck)

```gdscript
# Personalized minion crafting
func personalize_minion(pattern_id: String, custom_name: String, color_tint: Color) -> Minion:
    var pattern = PatternLibrary.get_pattern(pattern_id)
    var character_id = CurrentCharacter.id

    # Calculate costs (affected by Biotech)
    var biotech = PlayerStats.get_skill("biotech")
    var nanite_cost = calculate_minion_craft_cost(100, biotech)
    var scrap_cost = 400

    # Verify costs
    if not BankingService.spend_scrap(scrap_cost):
        return null
    if not LabService.spend_nanites(nanite_cost):
        return null

    # Create personalized minion
    var minion = MinionFactory.create_from_pattern(pattern, 1.0)  # 100% base
    minion.name = custom_name
    minion.is_personalized = true
    minion.owner_character_id = character_id
    minion.soul_bound = true  # Cannot transfer

    # Calculate stat bonus (Luck + Biotech)
    var luck = CurrentCharacter.get_stat("luck")
    var bonus_multiplier = calculate_minion_stat_bonus(luck, biotech)
    apply_minion_stat_bonus(minion, bonus_multiplier)

    # Apply visual customization
    minion.color_tint = color_tint

    # Luck roll for bonus ability
    var luck_roll = randf()
    if luck_roll < (luck / 200.0):  # 50% chance at 100 Luck
        var bonus_ability = get_random_bonus_ability(pattern.tier)
        minion.add_ability(bonus_ability)
        GameLogger.info("Bonus ability proc: %s!" % bonus_ability.name)

    MinionService.add_minion(minion)
    GameLogger.info("Personalized minion created: %s (%.0f%% bonus)" % [custom_name, bonus_multiplier * 100])
    return minion
```

**Personalized Minion Examples:**

**Example 1: Low Luck, Low Biotech**
```
Character: Bruiser (Luck: 10, Biotech: 0)
Pattern: Tier 4 Attack Drone (Base: 50 Damage)

Stat Bonus: 10% + 0.10 + 0 = 20%
Final Damage: 50 * 1.20 = 60 Damage

Custom Name: "Bruiser's Bot"
Cost: 400 scrap + 100 Nanites
Bonus Ability Chance: 5% (no proc)
```

**Example 2: High Luck, High Biotech**
```
Character: Lucky (Luck: 100, Biotech: 100)
Pattern: Tier 4 Attack Drone (Base: 50 Damage)

Stat Bonus: 10% + 1.00 + 2.00 = 310%
Final Damage: 50 * 4.10 = 205 Damage

Custom Name: "Lucky's Legendary Laser Bot"
Cost: 400 scrap + 0 Nanites (100 Biotech = FREE Nanites!)
Bonus Ability Chance: 50% (procs: "Energy Shield" ability)
```

---

## Mutation Chamber (Subscription Idle System)

**The Mutation Chamber** is a Subscription-exclusive idle system that **generates Nanites passively**.

### How It Works

**Placement:**
- Activate Mutation Chamber from The Lab scene
- Select character to place in chamber
- Character enters idle state (cannot be used)

**Generation Rate:**
- 5 Nanites per hour
- Max 8 hour session = 40 Nanites
- 2 sessions per day per character
- **Total: 80 Nanites per day passive**

**Return Conditions:**
1. **Manual Cancel:** Player cancels early (no reward)
2. **Success:** Full session completes (40 Nanites)
3. **Failure:** Random event (partial reward, 10-20 Nanites)

### Implementation

```gdscript
# Mutation Chamber activation
func activate_mutation_chamber(character_id: String) -> Result:
    # Verify Subscription tier
    if PlayerService.get_tier() != "subscription":
        return Result.error("Mutation Chamber requires Subscription")

    # Check daily sessions (max 2)
    var sessions_today = MutationChamber.get_sessions_today(character_id)
    if sessions_today >= 2:
        return Result.error("Daily limit reached (2 sessions)")

    # Check character availability
    var character = CharacterService.get_character(character_id)
    if character.is_idle or character.is_in_run:
        return Result.error("Character is busy")

    # Activate chamber
    var start_time = Time.get_unix_time_from_system()
    MutationChamber.start_session(character_id, start_time)
    character.is_idle = true
    character.idle_type = "mutation_chamber"

    GameLogger.info("Mutation Chamber activated for %s (session %d/2)" % [character.name, sessions_today + 1])
    return Result.success()

# Check session completion
func check_mutation_chamber_completion(character_id: String) -> Dictionary:
    var session = MutationChamber.get_active_session(character_id)
    if not session:
        return {}

    var current_time = Time.get_unix_time_from_system()
    var elapsed_hours = (current_time - session.start_time) / 3600.0

    # Cap at 8 hours
    elapsed_hours = min(elapsed_hours, 8.0)

    # Calculate Nanites generated
    var nanites_generated = int(elapsed_hours * 5)  # 5 per hour

    return {
        "elapsed_hours": elapsed_hours,
        "nanites_generated": nanites_generated,
        "is_complete": elapsed_hours >= 8.0
    }

# Collect Nanites
func collect_mutation_chamber_nanites(character_id: String) -> int:
    var completion = check_mutation_chamber_completion(character_id)

    if not completion.is_complete:
        ToastService.show("Session incomplete (%.1f/8.0 hours)" % completion.elapsed_hours)
        return 0

    # Award Nanites
    var nanites = completion.nanites_generated
    LabService.add_nanites(nanites)

    # End session
    MutationChamber.end_session(character_id)
    var character = CharacterService.get_character(character_id)
    character.is_idle = false

    GameLogger.info("Mutation Chamber complete: +%d Nanites" % nanites)
    return nanites
```

**Why Mutation Chamber is valuable:**
- ✅ **Passive Nanite income** (80/day without combat)
- ✅ **Reduces grind** (don't need to farm radioactive enemies constantly)
- ✅ **Subscription exclusive** (major value proposition)
- ✅ **Thematic** (mutating character generates nano-bio samples)

---

## Quantum Storage Transfer Rules

**Minion transfers via Quantum Storage (Subscription only):**

**✅ Can Transfer:**
- **Black Market minions** (purchased from Black Market scene, see [SHOPS-SYSTEM.md](./SHOPS-SYSTEM.md))
- **Generic crafted minions** (degrading stats, 1x per day per minion)
- **Evolving crafted minions** (Subscription patterns, 1x per day per minion)

**❌ Cannot Transfer:**
- **Personalized minions** (soul-bound to character)

**Why this works:**
- ✅ Expensive Black Market purchases feel valuable (can share)
- ✅ Generic/evolving minions have limited utility (not exploitable)
- ✅ Personalized minions are unlimited but soul-bound (must invest per character)
- ✅ Consistent with weapon transfer system (personalized = soul-bound)

```gdscript
# Minion transfer via Quantum Storage
func transfer_minion(minion: Minion, from_character_id: String, to_character_id: String) -> bool:
    # Verify Subscription tier
    if PlayerService.get_tier() != "subscription":
        ToastService.show("Quantum Storage requires Subscription")
        return false

    # Check if personalized (soul-bound)
    if minion.is_personalized:
        ToastService.show("Personalized minions are soul-bound (cannot transfer)")
        return false

    # Check transfer cooldown (1x per day per minion)
    var last_transfer = minion.get_meta("last_transfer_time", 0)
    var current_time = Time.get_unix_time_from_system()
    var hours_since_transfer = (current_time - last_transfer) / 3600.0

    if hours_since_transfer < 24:
        var hours_remaining = 24 - hours_since_transfer
        ToastService.show("Transfer cooldown: %.1f hours remaining" % hours_remaining)
        return false

    # Perform transfer
    MinionService.remove_minion_from_character(from_character_id, minion)
    MinionService.add_minion_to_character(to_character_id, minion)
    minion.set_meta("last_transfer_time", current_time)

    GameLogger.info("Minion transferred: %s (%s → %s)" % [minion.name, from_character_id, to_character_id])
    return true
```

---

## Afterburn System (Premium/Subscription)

### Lesser Afterburn (Premium - Automatic)

**Trigger:** Automatic at 15% HP
**Effect:**
- Radioactivity reduced by 50%
- Kills nearby enemies: `ceil(radioactivity * 0.15)`
- Example: 20 rad = 3 enemies, rad → 10

**Cooldown:** 5 waves (reduced by Biotech to min 3 waves)

### Greater Afterburn (Subscription - Manual)

**Trigger:** Manual activation below 25% HP
**Effect:**
- Radioactivity → 0 (complete purge)
- Kills nearby enemies: `ceil(radioactivity * 0.25 * wave_multiplier)`
- Example (Wave 10): 20 rad × 25% × 1.5 = 7-8 enemies

**Cooldown:** 5 waves (reduced by Biotech to min 3 waves)

---

## Alchemic Crapshot (Premium/Subscription)

**High-risk random stat manipulation:**

**Availability:**
- Premium: 1x per month
- Subscription: 1x per 2 weeks

**Cost:** 250 Nanites + 500 scrap

**Outcomes:**
- **Ultra Rare (5% + Luck/200):** Percentage stat change (-50% to +50%)
- **Positive (50% + Biotech/200):** +1 to +5 random stat
- **Negative (remainder):** -1 to -5 random stat

**Influenced by:**
- Luck (improves odds)
- Biotech (improves success rate)
- Radioactivity (increases chaos/variance)

---

## MetaConvertor (Subscription Only)

**Convert one stat to another using punishing ratio:**

**Example:** 3 HP → 1 Damage (3:1 ratio)

**Cost:** Variable scrap based on stats involved

**Conversion Ratio Formula:**
```gdscript
func calculate_conversion_ratio(character: Character, from_stat: String, to_stat: String) -> int:
    var base_ratio = 3  # 3:1 base

    # Luck improves ratio
    var luck_bonus = character.get_stat("luck") / 100  # -1 per 100 luck
    base_ratio -= int(luck_bonus)

    # Radioactivity worsens ratio
    var rad_penalty = character.radioactivity / 50  # +1 per 50 rad
    base_ratio += rad_penalty

    # Mutant Power stabilizes ratio
    var mp_bonus = character.get_stat("mutant_power") / 10  # -1 per 10 MP
    base_ratio -= mp_bonus

    # Clamp (min 2:1, max 5:1)
    return clamp(base_ratio, 2, 5)
```

**Restrictions:**
- ❌ Cannot convert TO Mutant Power
- ✅ Can convert FROM any stat
- ✅ Can convert TO any stat except Mutant Power

---

## Complete Purge (Subscription Only)

**Remove ALL radioactivity** from character, items, weapons, minions:

**Cost:** Auto-calculated (1 Nanite per radioactivity point across all sources, affected by Biotech)

**Behavior:**
- Deducts Nanites until balance exhausted (won't leave player broke)
- Removes radioactivity from ALL sources
- Emergency reset button

---

## The Lab Scene Layout

```
TheLabScene
├── Header
│   └── "The Lab - [Character Name]"
├── Navigation Tabs
│   ├── Radioactivity
│   ├── Minion Crafting (Subscription)
│   ├── Mutation Chamber (Subscription)
│   ├── Alchemic Crapshot (Premium+)
│   ├── MetaConvertor (Subscription)
│   └── Afterburn (Premium+)
├── Resources Display (Top-right)
│   ├── Nanites: [amount]/[limit]
│   ├── Carried Scrap: [amount]
│   ├── Banked Scrap: [amount] [Withdraw →]
│   ├── Radioactivity: [amount]
│   └── Biotech Skill: [level]
└── Active Tab Content
```

---

## Summary

The Lab provides:
- ✅ **Consolidated bio/genetics hub** (radioactivity + minions + stat manipulation)
- ✅ **Nanites currency** (thematic, works for all services)
- ✅ **Biotech skill** (affects all Lab operations)
- ✅ **Minion crafting** (degrading, evolving, personalized patterns via Subscription)
- ✅ **Mutation Chamber** (Subscription passive Nanites generation)
- ✅ **Clear tier differentiation** (Free = radioactivity only, Premium = stat manipulation, Subscription = minion crafting + idle)

**The Lab is a unique system** that provides strategic depth through risk/reward mechanics and compelling Premium/Subscription features.

---

## References

- [STAT-SYSTEM.md](./STAT-SYSTEM.md) - Biotech skill definition, Radioactivity stat
- [IDLE-SYSTEMS.md](./IDLE-SYSTEMS.md) - Mutation Chamber idle system
- [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) - Comparison with weapon personalization
- [MUTANT-POWER-DISCUSSION.md](../MUTANT-POWER-DISCUSSION.md) - Mutant Power stat design notes
