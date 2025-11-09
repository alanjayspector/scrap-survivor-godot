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
3. **Mutation Chamber** - Offline Nanite generation (The Lab currency)

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

## 3. Mutation Chamber (Offline Nanite Generation)

### What is Mutation Chamber?

**Concept:** While offline, your character undergoes mutations in The Lab's chamber, generating Nanites passively.

**Thematic flavor:**
> "Place your character in the Mutation Chamber - a controlled mutation environment. Their cells mutate and generate Nanites (microscopic bio-machines) while you're away. When you return, harvest the Nanites for Lab operations."

---

### How It Works

**Activation:**
- Subscription tier only
- Activate via The Lab UI: "Place [Character Name] in Mutation Chamber"
- Character becomes idle (can't run or use other idle systems)

**Nanite Generation Rate:**
- **Base rate:** 5 Nanites per hour
- **Maximum:** 40 Nanites per 8-hour session
- **Daily limit:** 2 Mutation Chamber sessions per character per day

**Example:**
```
9 AM: Place Bruiser in Mutation Chamber
5 PM: Return to game (8 hours later)
Result: Earned 40 Nanites (8 hours × 5 Nanites/hour)

Optional: Send again for 2nd session (another 8 hours)
Total daily: 80 Nanites per character
```

---

### Character Selection Strategy

**Which character to send:**
- Any character can use Mutation Chamber (no stat bonuses)
- Low-level characters contribute equally (democratic)
- Rotate between characters (each has 2 sessions/day)

**Example with 3 characters:**
```
Character A (Bruiser): 40 Nanites per 8 hours
Character B (Farmer): 40 Nanites per 8 hours
Character C (Speedster): 40 Nanites per 8 hours

Total daily (3 characters × 2 sessions): 240 Nanites/day while offline
```

---

### Strategic Uses

**What can you do with 80 Nanites/day:**

**1. Radioactivity treatment:**
```
50 Radioactivity = 25 Nanites to treat (Full Treatment, Biotech 0)
→ 80 Nanites/day = Treat 160 Radioactivity daily (passive safety net)
```

**2. Minion crafting:**
```
Generic minion craft = 25 Nanites + 50 scrap
→ 80 Nanites/day = Craft 3 generic minions daily
```

**3. Alchemic Crapshot:**
```
1 Alchemic Crapshot = 20 Nanites
→ 80 Nanites/day = 4 random stat manipulations daily
```

**4. Save for personalized minion:**
```
Personalized minion = 100 Nanites + 400 scrap
→ 80 Nanites/day = 1.25 days to save enough
```

---

### UI Design

**The Lab - Mutation Chamber Tab:**
```
[Mutation Chamber]

💎 Subscription Feature

Place a character in the Mutation Chamber to generate Nanites while offline.
Earn 5 Nanites per hour (max 40 per 8-hour session).

Select Character:
┌─────────────────────────────────────────┐
│ Bruiser (Level 15)                      │
│ Sessions today: 0/2                     │
│ Estimated: 40 Nanites per 8 hours       │
│                                         │
│ [Activate Mutation Chamber]             │
├─────────────────────────────────────────┤
│ Farmer (Level 20)                       │
│ Sessions today: 1/2                     │
│ Last session: +40 Nanites (8 hours)     │
│                                         │
│ [Activate Mutation Chamber]             │
└─────────────────────────────────────────┘
```

**Active Mutation Chamber:**
```
[The Lab - Character Status]

⚗️ Bruiser is in Mutation Chamber!
   Started: 9:00 AM
   Elapsed: 3 hours 45 minutes
   Nanites generated: ~19 so far

   [Claim Early] [Let Run Continue (max 8 hours)]
```

**Claim Rewards:**
```
[Mutation Chamber Complete!]

Bruiser completed mutation cycle!

Nanites generated: 40 Nanites
Time in chamber: 8 hours
Lab storage: 45/50 Nanites

[Claim Nanites] [Start New Session (1/2 remaining)]
```

---

### Balancing Considerations

**Why 5 Nanites/hour?**
- Nanites cost: Minion craft = 25 Nanites, Radioactivity treatment = 0.5 Nanites/rad
- Mutation Chamber: 40 Nanites per 8 hours = 1.6 minion crafts worth
- Active play: Kill 10 radioactive enemies = 50-100 Nanites (10 minutes)
- **Ratio:** Active play is ~24-48x more efficient
- Mutation Chamber is **convenience**, not replacement for playing

**Daily caps prevent abuse:**
- 2 sessions per character = 80 Nanites/day max per character
- 3 characters = 240 Nanites/day max total
- Active player can earn this in 2-3 radioactive wave runs (30-45 minutes)

**Storage limits create tension:**
- Free tier: 50 Nanites max (fills in 1.25 sessions)
- Premium tier: 100 Nanites max (fills in 2.5 sessions)
- Subscription tier: Unlimited (no waste)

**This means:** Mutation Chamber is passive income for Subscription tier, but active play is still king.

---

### Server-Side Validation

**Preventing exploits:**

```gdscript
# MutationChamberService.gd (server-validated)
func activate_mutation_chamber(character_id: String) -> Result:
    # Verify Subscription tier (server-side check)
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

    # Activate chamber (record start time server-side)
    var start_time = Time.get_unix_time_from_system()
    MutationChamber.start_session(character_id, start_time)
    character.is_idle = true
    character.idle_type = "mutation_chamber"

    GameLogger.info("Mutation Chamber activated for %s (session %d/2)" % [character.name, sessions_today + 1])
    return Result.success()

func claim_nanites(character_id: String) -> int:
    var session = MutationChamber.get_active_session(character_id)
    if not session:
        return 0

    # Calculate elapsed time (server-side, can't cheat)
    var elapsed_hours = (Time.get_unix_time_from_system() - session.start_time) / 3600.0
    elapsed_hours = min(elapsed_hours, 8.0)  # Cap at 8 hours

    # Calculate Nanites (5 per hour)
    var nanites_earned = int(5 * elapsed_hours)

    # Check storage limits
    var current_nanites = LabService.get_nanites_balance()
    var nanites_limit = LabService.get_nanites_limit()
    if current_nanites + nanites_earned > nanites_limit:
        var overflow = (current_nanites + nanites_earned) - nanites_limit
        ToastService.show("Lab storage full! Lost %d Nanites. Upgrade for more storage!" % overflow)
        nanites_earned = max(0, nanites_limit - current_nanites)

    # Award Nanites
    LabService.add_nanites(nanites_earned)
    MutationChamber.mark_session_claimed(character_id)

    # Release character
    var character = CharacterService.get_character(character_id)
    character.is_idle = false
    character.idle_type = ""

    GameLogger.info("Mutation Chamber complete: %s earned %d Nanites" % [character.name, nanites_earned])
    return nanites_earned
```

---

## Idle Systems Integration

### How All 3 Systems Work Together

**Daily Subscription Routine:**
```
Morning (before work):
1. Send Character A on Murder Hobo run (earn scrap while at work)
2. Place Character B in Cultivation Pod (train Armor stat)
3. Place Character C in Mutation Chamber (earn Nanites while at work)

Evening (after work):
1. Claim Murder Hobo scrap (~80 scrap)
2. Claim Cultivation Pod stat (+2 Armor)
3. Claim Mutation Chamber Nanites (~40 Nanites)
4. Use scrap + Nanites to craft minions or treat radioactivity

Result: Passive progress while at work/school
```

---

### Subscription Value Calculation

**What subscriber earns per day (offline):**
- Murder Hobo: ~160 scrap (2 sessions per character)
- Cultivation Pod: +2 permanent stat
- Mutation Chamber: ~80 Nanites (2 sessions per character)

**Compared to active play:**
- Active player: 200-400 scrap per run, +20 stats per run, 50-100 Nanites per radioactive wave
- Idle systems: ~160 scrap per day, +2 stats per day, ~80 Nanites per day
- **Ratio:** Active play is still 10-20x more efficient

**This means:** Idle systems are **time-saving convenience**, not **pay-to-win**.

---

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

### Mutation Chamber Backend

**See detailed implementation in [THE-LAB-SYSTEM.md](./THE-LAB-SYSTEM.md) Mutation Chamber section.**

**Summary:**
- Server-validated sessions (prevents time cheating)
- 5 Nanites per hour (40 Nanites per 8-hour session)
- 2 sessions per day per character
- Storage limits enforced (Free: 50, Premium: 100, Subscription: unlimited)
- Nanites added to Lab storage, not carried

---

## Summary

**Idle Systems provide:**
- ✅ Offline progression (earn while not playing)
- ✅ Time-saving convenience (passive scrap, stats, Nanites)
- ✅ Subscription value justification ($2.99/month worth it)
- ✅ Not pay-to-win (active play still 10-20x more efficient)
- ✅ Daily engagement incentive (log in to claim rewards)

**Subscription tier value is now:**
- Quantum Banking/Storage (transfer resources between characters)
- **Murder Hobo** (offline scrap, ~160/day)
- **Cultivation Pod** (offline stats, +2/day)
- **Mutation Chamber** (offline Nanites, ~80/day)
- Atomic Vending Machine (personalized shop)
- Monthly Unique Perk (rotating powerful perk)
- Hall of Fame (archive characters)
- Unlimited advancement
- Unlimited Workshop Components/Nanites storage
- Minion crafting via Pattern Library

**This is a STRONG $2.99/month value proposition for engaged players.**

---

## References

- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Other subscription features
- [SUBSCRIPTION-MONTHLY-PERKS.md](./SUBSCRIPTION-MONTHLY-PERKS.md) - Monthly perk system
- [THE-LAB-SYSTEM.md](./THE-LAB-SYSTEM.md) - Mutation Chamber, minion crafting, Nanites
- [BANKING-SYSTEM.md](./BANKING-SYSTEM.md) - Currency management
- [WORKSHOP-SYSTEM.md](./WORKSHOP-SYSTEM.md) - Workshop Components
- [STAT-SYSTEM.md](./STAT-SYSTEM.md) - Biotech skill, Harvesting stat
