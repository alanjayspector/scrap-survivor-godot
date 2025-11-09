# Idle Systems (Subscription Tier)

**Status:** Draft - Subscription Exclusive Features
**Date:** 2025-01-09
**Purpose:** Offline progression systems for Subscription tier players

---

## Overview

Idle Systems allow Subscription tier players to earn resources and make progress while NOT actively playing the game. These systems answer the question: **"What happens to my characters while I'm offline?"**

**The three idle systems:**
1. **Murder Hobo** - Offline scrap accumulation
2. **Cultivation Pod** - Offline stat gain
3. **Minion Fabricator** - Clone minions (subscription minion patterns)

**Brotato comparison:**
🟢 **UNIQUE TO SCRAP SURVIVOR** (Brotato has no idle systems, no offline progression)

**Key Design Philosophy:**
- ✅ Convenience, not power (doesn't break balance)
- ✅ Time-saving for engaged players (earn while at work/sleep)
- ✅ Capped rates (can't infinitely farm)
- ✅ Must check in (claim rewards, not automatic)

---

## 1. Murder Hobo (Offline Scrap Accumulation)

### What is Murder Hobo?

**Concept:** While you're offline, your character "goes out scavenging" and earns scrap passively.

**Thematic flavor:**
> "Your character isn't just sitting idle - they're out in The Wasteland, scrapping junk, fighting weak enemies, and surviving. When you log back in, they've brought back their haul."

---

### How It Works

**Activation:**
- Subscription tier only
- Activate via Hub UI: "Send [Character Name] on Murder Hobo Run"
- Character selection: Pick which character goes scavenging

**Earning Rate:**
- **Base rate:** 10 scrap/hour (very slow, but adds up)
- **Character bonuses:** Harvesting stat affects rate
  - +1% Murder Hobo rate per 10 Harvesting
  - Example: 50 Harvesting = +5% rate = 10.5 scrap/hour

**Caps:**
- **Time cap:** 8 hours maximum (prevents infinite farming)
- **Scrap cap:** 80 scrap maximum per Murder Hobo session
- **Daily limit:** 2 Murder Hobo sessions per character per day

**Example:**
```
9 AM: Send Bruiser on Murder Hobo run
5 PM: Return to game (8 hours later)
Result: Earned 80 scrap (8 hours × 10 scrap/hour)

Optional: Send again for 2nd session (another 8 hours)
Total daily: 160 scrap per character
```

---

### Character Selection Strategy

**Which character to send:**
- High Harvesting character earns more (Farmer, Entrepreneur)
- Low-level characters can still contribute
- Rotate between characters (each has 2 sessions/day)

**Example with 3 characters:**
```
Character A (Farmer, 50 Harvesting): 84 scrap per 8 hours
Character B (Bruiser, 10 Harvesting): 81 scrap per 8 hours
Character C (Speedster, 0 Harvesting): 80 scrap per 8 hours

Total daily (3 characters × 2 sessions): ~490 scrap/day while offline
```

---

### UI Design

**Hub - Murder Hobo Station:**
```
[Murder Hobo Station]

Send a character on a scavenging run. They'll earn scrap while you're offline!

Select Character:
┌─────────────────────────────────────────┐
│ Bruiser (Level 15)                      │
│ Harvesting: 10 (+1% Murder Hobo rate)   │
│ Sessions today: 0/2                     │
│ Estimated: 81 scrap per 8 hours         │
│                                         │
│ [Send on Murder Hobo Run]               │
├─────────────────────────────────────────┤
│ Farmer (Level 20)                       │
│ Harvesting: 50 (+5% Murder Hobo rate)   │
│ Sessions today: 1/2                     │
│ Estimated: 84 scrap per 8 hours         │
│ Last session: +84 scrap (8 hours)       │
│                                         │
│ [Send on Murder Hobo Run]               │
└─────────────────────────────────────────┘
```

**Active Murder Hobo:**
```
[Hub - Character Status]

🏃 Farmer is on Murder Hobo run!
   Started: 9:00 AM
   Elapsed: 3 hours 45 minutes
   Estimated scrap: ~40 scrap so far

   [Claim Early] [Let Run Continue (max 8 hours)]
```

**Claim Rewards:**
```
[Murder Hobo Complete!]

Farmer returned from scavenging!

Scrap earned: 84 scrap
Time offline: 8 hours
Harvesting bonus: +4 scrap

[Claim Scrap] [Send Again (1/2 sessions remaining)]
```

---

### Balancing Considerations

**Why 10 scrap/hour?**
- Active play: ~200-400 scrap per 20-minute run
- Murder Hobo: ~80 scrap per 8 hours
- **Ratio:** Active play is ~15x more efficient
- Murder Hobo is **convenience**, not replacement for playing

**Daily caps prevent abuse:**
- 2 sessions per character = 160 scrap/day max per character
- 3 characters = 480 scrap/day max total
- Active player can earn this in 2-3 runs (40-60 minutes)

**This means:** Murder Hobo is a nice bonus for players who CAN'T play for 8 hours, not a farming exploit.

---

## 2. Cultivation Pod (Offline Stat Gain)

### What is Cultivation Pod?

**Concept:** While offline, your character "trains" in a stat of your choice, slowly increasing it.

**Thematic flavor:**
> "Place your character in a Cultivation Pod - a high-tech training chamber. They'll focus on improving ONE stat while you're away. When you return, they're stronger."

---

### How It Works

**Activation:**
- Subscription tier only
- Activate via Hub UI: "Place [Character Name] in Cultivation Pod"
- **Choose 1 stat to cultivate:** Max HP, Damage, Attack Speed, Armor, etc.

**Stat Gain Rate:**
- **Base rate:** +1 stat point per 4 hours
- **Maximum:** +2 stat points per 8 hours
- **Daily limit:** 1 Cultivation Pod session per character per day

**Example:**
```
9 AM: Place Bruiser in Cultivation Pod → Choose "Max HP"
5 PM: Return to game (8 hours later)
Result: Bruiser gains +2 Max HP permanently

Next day: Can cultivate again (choose same or different stat)
```

---

### Character Selection Strategy

**Which stat to cultivate:**
- **Tank build:** Max HP, Armor (survivability)
- **DPS build:** Damage, Attack Speed, Crit Chance (offense)
- **Economic build:** Harvesting, Luck (economy)

**Long-term planning:**
```
Week 1: Cultivate Max HP (+14 Max HP over 7 days)
Week 2: Cultivate Armor (+14 Armor over 7 days)
Result after 2 weeks: Significantly tankier character
```

---

### UI Design

**Hub - Cultivation Pod:**
```
[Cultivation Pod]

Place a character in the Cultivation Pod to train a stat while offline.
Gain +1 stat point per 4 hours (max +2 per session).

Select Character:
┌─────────────────────────────────────────┐
│ Bruiser (Level 15)                      │
│ Current Stats:                          │
│  Max HP: 150  Armor: 15  Damage: 10     │
│                                         │
│ Session today: 0/1                      │
│ Choose stat to cultivate:               │
│ ( ) Max HP  ( ) Armor  (•) Damage       │
│                                         │
│ [Start Cultivation (8 hours)]           │
└─────────────────────────────────────────┘
```

**Active Cultivation:**
```
[Hub - Character Status]

🧬 Bruiser is in Cultivation Pod!
   Stat: Damage
   Started: 9:00 AM
   Elapsed: 6 hours 30 minutes
   Progress: +1 Damage (will reach +2 at 8 hours)

   [Claim Early (+1 Damage)] [Let Run Continue]
```

**Claim Rewards:**
```
[Cultivation Complete!]

Bruiser completed training!

Stat gained: Damage +2
Total Damage: 12 → 14 (+2)

Your character is now permanently stronger!

[Claim] [Start New Cultivation (tomorrow)]
```

---

### Balancing Considerations

**Why +1 stat per 4 hours?**
- Advancement Hall: +1 stat per level (earn in ~1 wave = 2-5 minutes)
- Cultivation Pod: +1 stat per 4 hours
- **Ratio:** Active play is ~48-120x more efficient

**This means:** Cultivation Pod is **long-term passive growth**, not fast-track to power.

**Daily cap prevents abuse:**
- 1 session per character per day = +2 stat points max
- 3 characters = +6 stat points per day total
- Active player can earn +20 stat points in a single good run

**Expected usage:**
- Log in once per day
- Set Cultivation Pod before bed/work
- Claim +2 stat when return
- Adds up over weeks/months (casual player progression)

---

### Permanent Stat Tracking

**Stats gained via Cultivation Pod are permanent:**
```gdscript
# Character data structure
class_name Character
var base_stats: Dictionary = {
    "max_hp": 100,
    "damage": 0,
    "armor": 0
}
var cultivation_stats: Dictionary = {
    "max_hp": 0,   # +14 from 1 week of cultivation
    "damage": 0,   # +8 from 4 days
    "armor": 0
}

func get_total_stat(stat: String) -> int:
    return base_stats[stat] + advancement_stats[stat] + cultivation_stats[stat] + item_stats[stat]
```

---

## 3. Minion Fabricator (Clone Minions)

### What is Minion Fabricator?

**Concept:** Create copies of your existing minions using a blueprint system.

**Thematic flavor:**
> "You've found a powerful minion. The Minion Fabricator can scan and clone it - but each copy degrades the pattern slightly, and the process is expensive."

---

### How It Works

**Activation:**
- Subscription tier only
- Requires: 1 existing minion to clone
- Creates: Minion Pattern (blueprint)

**Fabrication Process:**
```
Step 1: Select minion to clone (must be in your roster)
Step 2: Pay fabrication cost (scrap + Workshop Components)
Step 3: Receive Minion Pattern (blueprint, consumable)
Step 4: Use pattern to craft cloned minion
```

**Fabrication Costs:**
| Minion Tier | Fabrication Cost | Pattern Uses | Degradation |
|-------------|------------------|--------------|-------------|
| Tier 1 | 200 scrap + 50 components | 3 uses | None |
| Tier 2 | 400 scrap + 100 components | 3 uses | -5% stats per use |
| Tier 3 | 800 scrap + 200 components | 2 uses | -10% stats per use |
| Tier 4 | 1,500 scrap + 400 components | 1 use | -20% stats (final clone) |

---

### Pattern Degradation

**How degradation works:**

**Example: Tier 2 Tank Minion (100 HP, 10 Damage base)**

```
Original minion: 100 HP, 10 Damage

Use Pattern 1st time:
Clone 1: 100 HP, 10 Damage (perfect copy)

Use Pattern 2nd time:
Clone 2: 95 HP, 9.5 Damage (-5% from original)

Use Pattern 3rd time:
Clone 3: 90 HP, 9 Damage (-10% from original)
Pattern destroyed after 3rd use
```

**Why degradation?**
- Prevents infinite minion cloning (balance)
- Makes original minions valuable (can't just spam copies)
- Creates strategic choice (clone early vs. clone perfect minion)

---

### Strategic Uses

**When to use Minion Fabricator:**

**1. Duplicate powerful minions:**
```
Found Tier 4 DPS minion (very rare!)
→ Clone it 1x (costs 1,500 scrap + 400 components)
→ Now have 2 Tier 4 DPS minions (strong duo)
```

**2. Build minion teams:**
```
Have: 1 Tank, 1 Healer, 1 DPS
Want: Full team synergy
→ Clone Tank (need 2 tanks for front line)
→ Clone DPS (need 2 DPS for damage)
Result: 2 Tanks, 1 Healer, 2 DPS (balanced team)
```

**3. Preserve rare minions:**
```
Found event-exclusive minion (only available during Halloween)
→ Clone it before event ends
→ Keep original + clones for future use
```

---

### UI Design

**Hub - Minion Fabricator:**
```
[Minion Fabricator]

Clone your existing minions. Each pattern has limited uses and degrades over time.

Select Minion to Clone:
┌─────────────────────────────────────────┐
│ Tank Minion (Tier 2, Level 10)          │
│ HP: 200  Damage: 15  Armor: 10          │
│                                         │
│ Fabrication Cost:                       │
│  - 400 scrap                            │
│  - 100 Workshop Components              │
│                                         │
│ Pattern Info:                           │
│  - 3 uses before destruction            │
│  - -5% stats per use (degradation)      │
│                                         │
│ [Create Minion Pattern]                 │
└─────────────────────────────────────────┘
```

**Pattern Created:**
```
[Minion Pattern Created!]

Tank Minion Pattern (Tier 2)
Uses remaining: 3/3

This pattern can craft:
Clone 1: 100% stats (200 HP, 15 Damage)
Clone 2: 95% stats (190 HP, 14 Damage)
Clone 3: 90% stats (180 HP, 13 Damage)

Pattern is stored in Workshop Quantum Storage.

[Craft Clone Now] [Store Pattern]
```

**Crafting from Pattern:**
```
[Craft Minion from Pattern]

Tank Minion Pattern (Tier 2)
Uses: 2/3 remaining

Crafting Clone #2:
Stats: 95% of original (190 HP, 14 Damage)

Materials Required:
- 200 scrap
- 50 Workshop Components

[Craft Minion] [Cancel]
```

---

### Balancing Considerations

**Why is cloning expensive?**
- Minions are powerful (AI companions in combat)
- Unlimited cloning = broken meta (all players run 3x same minion)
- High cost = strategic choice (worth cloning this minion?)

**Cost comparison:**
- Buy new minion: 300-800 scrap (random minion)
- Clone specific minion: 400-1,500 scrap (guaranteed minion)
- **Trade-off:** Cloning is more expensive, but targeted

**Pattern degradation:**
- Prevents infinite cloning
- Makes original minions valuable
- Creates decision: Clone now (perfect copy) vs. wait (maybe find better minion)

---

## Idle Systems Integration

### How All 3 Systems Work Together

**Daily Subscription Routine:**
```
Morning (before work):
1. Send Character A on Murder Hobo run (earn scrap while at work)
2. Place Character B in Cultivation Pod (train Armor stat)
3. Check Minion Fabricator (craft clone from yesterday's pattern)

Evening (after work):
1. Claim Murder Hobo scrap (~80 scrap)
2. Claim Cultivation Pod stat (+2 Armor)
3. Use scrap to start new Minion Pattern fabrication

Result: Passive progress while at work/school
```

---

### Subscription Value Calculation

**What subscriber earns per day (offline):**
- Murder Hobo: ~160 scrap (2 sessions per character)
- Cultivation Pod: +2 permanent stat
- Minion Fabricator: 1 minion clone (every 3-4 days)

**Compared to active play:**
- Active player: 200-400 scrap per run, +20 stats per run
- Idle systems: ~160 scrap per day, +2 stats per day
- **Ratio:** Active play is still 10-20x more efficient

**This means:** Idle systems are **time-saving convenience**, not **pay-to-win**.

---

## Technical Implementation

### Murder Hobo Backend

```gdscript
# MurderHoboService.gd
class_name MurderHoboService
extends Node

const BASE_SCRAP_PER_HOUR: int = 10
const MAX_HOURS: int = 8
const DAILY_SESSION_LIMIT: int = 2

func start_murder_hobo(character: Character) -> bool:
    if not is_subscription_active():
        return false

    if get_sessions_today(character) >= DAILY_SESSION_LIMIT:
        return false

    var start_time = Time.get_unix_time_from_system()
    save_murder_hobo_session(character.id, start_time)
    return true

func claim_murder_hobo(character: Character) -> int:
    var session = get_active_session(character)
    if not session:
        return 0

    var elapsed_hours = (Time.get_unix_time_from_system() - session.start_time) / 3600.0
    elapsed_hours = min(elapsed_hours, MAX_HOURS)

    var harvesting_bonus = character.get_stat("harvesting") / 10.0  # +1% per 10 Harvesting
    var scrap_rate = BASE_SCRAP_PER_HOUR * (1.0 + harvesting_bonus / 100.0)
    var total_scrap = int(scrap_rate * elapsed_hours)

    mark_session_claimed(character)
    return total_scrap
```

---

### Cultivation Pod Backend

```gdscript
# CultivationPodService.gd
class_name CultivationPodService
extends Node

const STAT_GAIN_PER_4_HOURS: int = 1
const MAX_STAT_GAIN: int = 2
const DAILY_SESSION_LIMIT: int = 1

func start_cultivation(character: Character, stat: String) -> bool:
    if not is_subscription_active():
        return false

    if get_sessions_today(character) >= DAILY_SESSION_LIMIT:
        return false

    var start_time = Time.get_unix_time_from_system()
    save_cultivation_session(character.id, start_time, stat)
    return true

func claim_cultivation(character: Character) -> Dictionary:
    var session = get_active_session(character)
    if not session:
        return {}

    var elapsed_hours = (Time.get_unix_time_from_system() - session.start_time) / 3600.0
    var stat_gain = int(min(elapsed_hours / 4.0, MAX_STAT_GAIN))

    character.add_cultivation_stat(session.stat, stat_gain)
    mark_session_claimed(character)

    return {
        "stat": session.stat,
        "gain": stat_gain
    }
```

---

### Minion Fabricator Backend

```gdscript
# MinionFabricatorService.gd
class_name MinionFabricatorService
extends Node

const FABRICATION_COSTS = {
    1: {"scrap": 200, "components": 50},
    2: {"scrap": 400, "components": 100},
    3: {"scrap": 800, "components": 200},
    4: {"scrap": 1500, "components": 400}
}

const PATTERN_USES = {1: 3, 2: 3, 3: 2, 4: 1}
const DEGRADATION = {1: 0.0, 2: 0.05, 3: 0.10, 4: 0.20}

func create_pattern(minion: Minion) -> MinionPattern:
    if not is_subscription_active():
        return null

    var cost = FABRICATION_COSTS[minion.tier]
    if not can_afford(cost.scrap, cost.components):
        return null

    deduct_resources(cost.scrap, cost.components)

    var pattern = MinionPattern.new()
    pattern.minion_template = minion.duplicate()
    pattern.uses_remaining = PATTERN_USES[minion.tier]
    pattern.degradation_rate = DEGRADATION[minion.tier]
    pattern.tier = minion.tier

    return pattern

func craft_from_pattern(pattern: MinionPattern) -> Minion:
    if pattern.uses_remaining <= 0:
        return null

    var use_number = PATTERN_USES[pattern.tier] - pattern.uses_remaining + 1
    var stat_multiplier = 1.0 - (pattern.degradation_rate * (use_number - 1))

    var cloned_minion = pattern.minion_template.duplicate()
    cloned_minion.apply_stat_multiplier(stat_multiplier)

    pattern.uses_remaining -= 1
    return cloned_minion
```

---

## Summary

**Idle Systems provide:**
- ✅ Offline progression (earn while not playing)
- ✅ Time-saving convenience (passive scrap, stats, minions)
- ✅ Subscription value justification ($2.99/month worth it)
- ✅ Not pay-to-win (active play still 10-20x more efficient)
- ✅ Daily engagement incentive (log in to claim rewards)

**Subscription tier value is now:**
- Quantum Banking/Storage (transfer resources between characters)
- **Murder Hobo** (offline scrap, ~160/day)
- **Cultivation Pod** (offline stats, +2/day)
- **Minion Fabricator** (clone minions)
- Atomic Vending Machine (personalized shop)
- Monthly Unique Perk (rotating powerful perk)
- Hall of Fame (archive characters)
- Unlimited advancement

**This is a STRONG $2.99/month value proposition for engaged players.**

---

## References

- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Other subscription features
- [SUBSCRIPTION-MONTHLY-PERKS.md](./SUBSCRIPTION-MONTHLY-PERKS.md) - Monthly perk system
- [MINIONS-SYSTEM.md](./MINIONS-SYSTEM.md) - Minion mechanics and types
- [BANKING-SYSTEM.md](./BANKING-SYSTEM.md) - Currency management
- [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) - Workshop Components
