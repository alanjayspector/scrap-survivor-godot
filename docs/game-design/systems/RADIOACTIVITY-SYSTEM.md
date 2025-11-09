# Feature Roadmap: Radioactivity & Connected Systems

**Status:** 📋 Design Phase  
**Target Sprint:** Sprint 11-12 (After Weapons, Range, UI Polish)  
**Last Updated:** October 12, 2025  
**Dependencies:** Tier System (Sprint 8) ✅, Weapons System (Sprint 9-10), Range Attribute (Sprint 10), Character Instances ✅, Supabase Integration ✅

**⚠️ IMPORTANT:** This is NOT immediate priority work. Before implementing radioactivity, we need to complete:

- Weapons system improvements
- Range as a combat attribute
- UI polish on existing features

This document captures future design decisions for Sprint 11-12 and beyond.

---

## Overview

This document outlines a **suite of interconnected game mechanics** centered around the **Radioactivity** stat. These features are designed to add depth to the survival gameplay loop while providing meaningful tier differentiation.

**Core Systems:**

1. **Radioactivity** - A persistent stat that affects multiple game systems
2. **Urgent Care** - Scene for managing radioactivity with tier-based treatment options
3. **Advancement Hall** - Character progression system with Free tier limitations
4. **Idle Game** - Resource management system for temporarily removing assets from play

---

## Software Engineering Principles Applied

**Design Patterns:**

- **Service Layer Pattern** - TierService validates feature access
- **Strategy Pattern** - Different treatment options based on tier
- **Observer Pattern** - Radioactivity stat affects multiple systems
- **State Machine Pattern** - Idle game states (active → idle → recovered/failed)

**Game Design Principles:**

- **Risk/Reward Mechanics** - Higher radioactivity = higher risk + potential rewards
- **Tier Differentiation** - Each tier offers meaningful gameplay improvements
- **Emergent Complexity** - Simple radioactivity stat creates complex interactions
- **Player Agency** - Multiple paths to manage radioactivity

---

## 1. Radioactivity System

### Core Concept

**Radioactivity** is a persistent character stat that creates a **risk/reward dynamic**. It accumulates through gameplay (special enemy hits, events, looting radioactive items) and must be actively managed through the Urgent Care scene.

**Design Philosophy:** Radioactivity should feel like a **meaningful choice**, not a frustrating punishment. Higher radioactivity opens new gameplay possibilities (mob spawning variations, mutant power boosts) while requiring strategic management.

### Acquisition Methods

Players gain radioactivity through:

- **Combat:** Hit by special "radioactive" enemy variants
- **Events:** Random events that add radioactivity (with warning/choice)
- **Loot:** Picking up radioactive items (high-risk, high-reward)
- **Advancement:** Some advancement paths may trade radioactivity for power

### Effects by Tier

#### Radioactivity Thresholds (Updated per Alan's feedback)

**Threshold Ranges:**

- **Low:** 0-14 radioactivity (minimal effects)
- **Medium:** 15-29 radioactivity (moderate effects, combat penalties)
- **Large:** 30+ radioactivity (severe effects, high risk/reward)

**Scaling:** These thresholds scale with:

- Character level
- Wave progression
- Events
- Perks

As players advance, the same numerical radioactivity value will have progressively less severe effects, encouraging them to operate at higher radioactivity levels.

### Free Tier Effects

| System         | Effect                                                         | Threshold        |
| -------------- | -------------------------------------------------------------- | ---------------- |
| HP Regen       | Negative impact on regeneration rate                           | All levels       |
| Combat         | Player attacks miss                                            | Medium amounts   |
| Advancement    | Modifier for advancement feature                               | TBD (Sprint 10+) |
| Mob Aggression | Increased attack speed                                         | Medium amounts   |
| Mob Behavior   | Some mobs attack at range only                                 | Large amounts    |
| Mob Spawning   | **Progressively harder mobs** generated based on radioactivity | Continuous       |

**Software Note:** Mob spawning should use a **scaling algorithm** that considers both wave number AND radioactivity for difficulty calculation.

```typescript
// Pseudo-code for mob difficulty scaling
function calculateMobDifficulty(waveNumber: number, radioactivity: number): number {
  const baseWaveDifficulty = waveNumber * WAVE_DIFFICULTY_MULTIPLIER;
  const radioactivityModifier = radioactivity * RADIOACTIVITY_DIFFICULTY_MULTIPLIER;

  return baseWaveDifficulty + radioactivityModifier;
}
```

#### Premium Tier Effects

Includes all **Free Tier Effects** plus:

| Feature             | Effect                                                               | Notes                      |
| ------------------- | -------------------------------------------------------------------- | -------------------------- |
| Mutant Power Boost  | Small chance to gain +1 mutant power                                 | Long-term benefit          |
| HP Regen Mitigation | Higher mutant power reduces radioactivity's negative HP regen impact | **Ratio must be balanced** |

**Design Consideration:** The ratio for HP regen mitigation should create a **positive feedback loop** - radioactivity helps mutant power, mutant power mitigates radioactivity penalty. This rewards Premium players for embracing the risk.

**See:** `MUTANT_POWER_STAT.md` for complete mutant power documentation.

#### Subscription Tier Effects

Includes all **Premium Tier Effects** plus:

| Feature             | Effect                                           | Frequency  | Notes                                         |
| ------------------- | ------------------------------------------------ | ---------- | --------------------------------------------- |
| Afterburn (Venting) | Zero out radioactivity at 15% HP                 | 1x per day | Kills nearby mobs based on radioactivity stat |
| WeaponFusion        | Small % of radioactivity increases weapon damage | Continuous | Encourages high-radioactivity playstyles      |

**Afterburn Mechanic Detail (Two Versions):**

**Premium Tier: Lesser Afterburn (Automatic)**

- **Trigger:** Character reaches 15% HP (automatic)
- **Effect:** Radioactivity stat reduced by 50%, kill [X] mobs on scene
- **Kill Count Formula:** `Math.ceil(radioactivityStat * 0.15)` (15% guardrail)
  - Example: 20 radioactivity × 15% = 3 mobs killed
  - Radioactivity reduced to 10
- **Cooldown:** 1x per 5 waves completed

**Subscription Tier: Greater Afterburn (Manual)**

- **Trigger:** Player activates manually (button press) when below 25% HP
- **Effect:** Radioactivity stat → 0, kill [Y] mobs on scene
- **Kill Count Formula:** `Math.ceil(radioactivityStat * 0.25)` (25% guardrail, scales with wave)
  - Example: 20 radioactivity × 25% = 5 mobs killed
  - Radioactivity reduced to 0
- **Strategic Element:** Player chooses WHEN to trigger (save for boss, emergency escape)
- **Cooldown:** 1x per 5 waves completed
- **Validation:** Checked by Supabase (server-side validation for security)

**Design Rationale:**

- Premium gets automatic safety net (less punishing)
- Subscription gets powerful strategic tool (more skill expression)
- Both scale with wave number for balance at all progression levels

**WeaponFusion Mechanic:**

- Small percentage of radioactivity adds to weapon damage
- Example: 10 radioactivity × 2% = +0.2 weapon damage multiplier
- Creates synergy with high-radioactivity builds

---

## 2. Urgent Care Scene

### Core Concept

The **Urgent Care** scene is where players manage their radioactivity stat by spending scrap resources. It's the primary **pressure release valve** for the radioactivity system.

**Scene Location:** Accessible from The Scrapyard (hub)

**Design Philosophy:** Urgent Care should feel like a **strategic resource decision**, not a mandatory tax. Different tiers offer different efficiency/risk tradeoffs.

### Treatment Options by Tier

#### Free Tier Treatment Options

All options reduce radioactivity by **-1 point**:

| Treatment       | Cost         | Target                  |
| --------------- | ------------ | ----------------------- |
| Reduce (Self)   | Medium scrap | Character radioactivity |
| Reduce (Item)   | Large scrap  | Item radioactivity      |
| Reduce (Weapon) | Large scrap  | Weapon radioactivity    |

**Design Note:** The -1 point reduction means Free tier players must make **many small decisions** about radioactivity management. This creates engagement without being punishing.

#### Premium Tier Treatment Options

All basic options reduce radioactivity by **-1 point**:

| Treatment             | Cost            | Target      | Notes                            |
| --------------------- | --------------- | ----------- | -------------------------------- |
| Reduce (Self)         | **Small scrap** | Character   | More efficient than Free         |
| Reduce (Item)         | Medium scrap    | Item        | More efficient than Free         |
| Reduce (Weapon)       | Medium scrap    | Weapon      | More efficient than Free         |
| Reduce (Minion)       | Large scrap     | Minion      | New option                       |
| **Alchemic Crapshot** | Large scrap     | Random stat | **Very risky, appears 1x/month** |

**Alchemic Crapshot Detail:**

- **Effect:** Randomly add/reduce points of a random stat
- **Ultra Rare:** "Very, very long shot" of increasing/decreasing a stat by a **random percentage**
- **Availability:** 1x per month (stored in user_accounts table)
- **Influenced By:** Luck stat (increases chance of positive outcome)
- **Radioactivity Interaction:** Current radioactivity randomly impacts result

**Implementation Note:** This is a **high-risk, high-reward** mechanic that creates memorable moments. Should have excellent UI feedback (animations, anticipation, reveal).

#### Subscription Tier Treatment Options

| Treatment             | Cost            | Target          | Notes                               |
| --------------------- | --------------- | --------------- | ----------------------------------- |
| Self Reduction        | Small scrap     | Character       | **Random percentage** instead of -1 |
| Item/Weapon Reduction | Medium scrap    | Item/Weapon     | **Smaller percentage range**        |
| Alchemic Crapshot     | Large scrap     | Random stat     | Available every **2 weeks**         |
| **MetaConvertor**     | Variable        | Character stats | Convert one stat to another         |
| **Complete Purge**    | Auto-calculated | All targets     | Purge radioactivity completely      |

**MetaConvertor Detail:**

- **Effect:** Convert one character stat to another using a **punishing ratio**
- **Example:** Take 3 HP → Gain 1 Damage
- **Ratio:** Random but influenced by perks and luck stat
- **Radioactivity Impact:** High radioactivity makes ratios worse (more chaos)
- **Mutant Power Impact:** Mutant power stabilizes ratios (less chaos)
- **Restrictions:**
  - **CANNOT convert TO mutant power** (can only gain mutant power through exposure/items)
  - Harvesting stat may be renamed/removed (doesn't fit game type well)
- **Design Note:** This is a **power player tool** - allows minmaxing builds but at high cost

**Alternative Name Suggestions:**

- Stat Alchemist
- Bio-Reforger
- Transmutation Chamber
- Wasteland Exchanger

**Complete Purge Detail:**

- **Effect:** Remove radioactivity completely from self, items, weapons, minions
- **Cost:** Auto-deducted/calculated based on total radioactivity across all sources
- **Behavior:** Deducts resources until exhausted (won't leave player stranded)
- **Use Case:** Emergency reset button for players who over-invested in radioactivity

---

## 3. Advancement Hall Limitation

### Core Concept

The **Advancement Hall** is a character progression system (details TBD in future sprints). Free tier players have a **hard cap** on advancement opportunities per character.

### Free Tier Limitation

| Tier         | Advancement Opportunities        |
| ------------ | -------------------------------- |
| Free         | **5 advancements per character** |
| Premium      | TBD (likely higher)              |
| Subscription | TBD (likely unlimited)           |

**Design Rationale:**

- Creates a **strategic decision point** for Free tier players
- Encourages thoughtful progression choices (can't experiment freely)
- Provides clear **upgrade incentive** (Premium/Subscription remove the cap)

**Implementation Note:**

- Store advancement count in `character_instances` table (`advancements_used: number`)
- TierService validates advancement attempts before execution
- UI should show "X/5 advancements remaining" for Free tier

**Future Design Consideration:** Radioactivity will serve as a **modifier for advancement** (exact mechanic TBD). This creates synergy between the systems.

---

## 4. Idle Game System

### Core Concept

The **Idle Game** mechanic allows players to temporarily **remove items, minions, or characters from active play** in exchange for potential rewards. This creates a **resource management meta-game**.

**Design Philosophy:** Idling should be a **strategic decision**, not a passive income generator. There should be **meaningful risk** (failure states) and **opportunity cost** (can't use the asset while idling).

### Idle Mechanics

#### Placement

When an item, minion, or character is placed in an "idler":

- **Status:** Taken **out of play** (cannot be used)
- **Duration:** TBD (likely hours/days based on asset rarity)
- **Visibility:** Should be clearly marked in UI as "Idling"

#### Return Conditions

An idling asset can return to play under **three conditions**:

| Condition         | Description                          | Outcome                         |
| ----------------- | ------------------------------------ | ------------------------------- |
| **Player Cancel** | Player manually cancels idling       | Asset returns, no reward        |
| **Failure**       | Bad luck or random event             | Asset returns, possible penalty |
| **Success**       | Idle duration completes successfully | Asset returns, reward granted   |

**Software Engineering Note:** This is a classic **State Machine Pattern**:

```
Active → Idling → [Success | Failure | Cancelled] → Active
```

#### Failure States

**Design Consideration:** Failures should be **interesting**, not purely punishing.

Possible failure effects:

- Asset returns with temporary debuff
- Partial reward (less than success)
- Asset takes durability damage (if applicable)
- Asset gains radioactivity (ties into main mechanic)

**Influenced By:**

- Player's luck stat
- Character's current radioactivity (higher = higher risk)
- Perks and events

#### Success Rewards

**Design Consideration:** Rewards should scale with **risk and rarity**:

- Higher rarity assets = bigger rewards
- Higher radioactivity assets = riskier but potentially bigger rewards
- Longer idle durations = better rewards

Possible rewards:

- Scrap currency
- Rare items
- Stat boosts
- Advancement opportunities
- Reduced radioactivity

---

## Implementation Roadmap

### Phase 1: Core Radioactivity Stat (Sprint 9)

**Tasks:**

- Add `radioactivity: number` to `character_instances` table
- Add `radioactivity: number` to items and weapons schemas
- Implement base HP regen penalty for Free tier
- Create UI indicators for radioactivity levels
- Add radioactivity gain from combat (special enemies)

**Dependencies:**

- Character system ✅ Complete
- Combat system ✅ Complete
- Database schema access ✅ Complete

**Estimated Time:** 2-3 days

### Phase 2: Urgent Care Scene (Sprint 9-10)

**Tasks:**

- Create `UrgentCareScene` extending `BaseScene`
- Implement treatment UI with tier-based options
- Integrate TierService for feature gating
- Add scrap deduction logic
- Create Alchemic Crapshot minigame
- Implement MetaConvertor (Subscription)
- Implement Complete Purge (Subscription)

**Dependencies:**

- Radioactivity stat ✅ (from Phase 1)
- TierService ✅ Complete
- Scrap currency system ✅ Complete

**Estimated Time:** 1 week

### Phase 3: Advanced Radioactivity Effects (Sprint 10-11)

**Tasks:**

- Combat miss mechanic (Medium radioactivity)
- Mob aggression scaling (Medium radioactivity)
- Mob range behavior (Large radioactivity)
- Mob spawning difficulty modifier
- Afterburn mechanic (Subscription)
- WeaponFusion damage boost (Subscription)
- Mutant Power boost (Premium)
- HP regen mitigation (Premium)

**Dependencies:**

- Radioactivity stat ✅ (from Phase 1)
- Urgent Care scene ✅ (from Phase 2)
- Enemy system ✅ Complete

**Estimated Time:** 1.5 weeks

### Phase 4: Advancement Hall (Sprint 11-12)

**Tasks:**

- Design advancement mechanic details
- Create `AdvancementHallScene` extending `BaseScene`
- Implement Free tier limitation (5 advancements)
- Add advancement tracking to `character_instances`
- Integrate radioactivity as advancement modifier

**Dependencies:**

- Radioactivity stat ✅ (from Phase 1)
- TierService ✅ Complete
- Character progression design 🔴 (needs design)

**Estimated Time:** 1 week (after design complete)

### Phase 5: Idle Game System (Sprint 12-13)

**Tasks:**

- Design idle game economy (durations, rewards, failure rates)
- Create `IdlerService` for state management
- Add idle state tracking to database
- Implement success/failure/cancel logic
- Create idle management UI
- Integrate luck stat and radioactivity influence

**Dependencies:**

- Radioactivity stat ✅ (from Phase 1)
- Item/weapon/minion systems ✅ (items/weapons complete, minions TBD)
- Timer/scheduling system 🔴 (needs implementation)

**Estimated Time:** 1.5 weeks (after design complete)

---

## Design Questions & Refinement Topics

### Questions for Discussion

1. **Radioactivity Thresholds:** What exact values define "medium" and "large" radioactivity?
   - Suggestion: Medium = 10-20, Large = 20+
   - Should scale with character level?

2. **Scrap Costs:** What are "small", "medium", and "large" scrap amounts?
   - Suggestion: Small = 10-50, Medium = 50-150, Large = 150-500
   - Should scale with player progression?

3. **Mutant Power Mechanic:** How does mutant power work as a stat?
   - Is this a new stat we need to add to character instances?
   - What does mutant power affect besides HP regen mitigation?

4. **Alchemic Crapshot Odds:** What's the actual probability distribution?
   - Base chance for stat change: 50%?
   - Chance for percentage change: 1%? 5%?
   - How much does luck stat improve odds?

5. **Idle Game Economy:** What's the risk/reward balance?
   - Success rate baseline: 70%? 80%?
   - How much does luck/radioactivity shift the odds?
   - What's the reward scaling formula?

6. **Advancement Hall Design:** What exactly is advancement?
   - Is this like skill trees? Permanent stat boosts?
   - How does radioactivity modify it?
   - What's the progression curve?

7. **Afterburn Frequency:** Is 1x per day too restrictive?
   - Alternative: 1x per X waves completed?
   - Should Premium get more frequent usage?

8. **WeaponFusion Scaling:** What's the damage percentage?
   - Example: 2% per radioactivity point?
   - Should it have diminishing returns?

### Technical Considerations

1. **Server-Side Validation:** Which actions need Supabase validation?
   - Afterburn cooldown ✅ (security critical)
   - Alchemic Crapshot availability ✅ (prevents exploit)
   - Advancement count ✅ (tier enforcement)
   - Idle game state ✅ (prevents cheating)

2. **Performance:** Will radioactivity checks impact game loop?
   - Suggestion: Cache radioactivity value per frame
   - Only recalculate on stat change events

3. **UI Feedback:** How do we communicate radioactivity effects?
   - Visual indicator (radiation symbol with color gradient)
   - Tooltip on hover showing all active effects
   - Warning messages at threshold transitions

4. **Database Schema:** New tables needed?
   - `idle_game_state` table for tracking idling assets
   - `advancement_progress` table for tracking advancements
   - Add columns to existing tables vs. new tables?

---

## Open Design Questions

**Prioritized by Implementation Order:**

### High Priority (Sprint 9)

- [ ] Define exact radioactivity threshold values (medium, large)
- [ ] Define scrap cost values (small, medium, large)
- [ ] Design mutant power stat (if new stat needed)
- [ ] Determine HP regen penalty formula

### Medium Priority (Sprint 10)

- [ ] Design Alchemic Crapshot probability distribution
- [ ] Define Afterburn mob kill formula (guardrail boundary value)
- [ ] Define WeaponFusion damage scaling percentage
- [ ] Design mob spawning difficulty algorithm

### Low Priority (Sprint 11-12)

- [ ] Complete Advancement Hall mechanic design
- [ ] Complete Idle Game economy design (durations, rewards, odds)
- [ ] Define radioactivity's role in advancement
- [ ] Define failure state effects for idle game

---

## Success Metrics

How do we know these systems are working well?

### Player Engagement Metrics

- **Urgent Care Visit Rate:** How often do players use Urgent Care?
  - Target: 60%+ of players visit at least once per play session
- **Radioactivity Tolerance:** What radioactivity levels do players maintain?
  - Target: Free tier averages 5-10, Premium 10-15, Subscription 15-20
- **Alchemic Crapshot Usage:** How many Premium players use it monthly?
  - Target: 40%+ of Premium players try it at least once

### Monetization Metrics

- **Tier Upgrade Rate:** Does radioactivity drive upgrades?
  - Track: % of Free players who upgrade after experiencing high radioactivity
- **Feature Usage by Tier:** Are tier-specific features compelling?
  - Track: Afterburn usage, MetaConvertor usage, Complete Purge usage

### Balance Metrics

- **Death Rate by Radioactivity:** Is high radioactivity too punishing?
  - Target: Death rate should scale linearly with radioactivity (no cliff)
- **Advancement Limitation Impact:** Do Free players hit the 5-advancement cap?
  - Target: 70%+ of active Free players hit cap (shows value)

---

## Related Documentation

- `MONETIZATION_ARCHITECTURE.md` - Tier system implementation
- `CURRENT_SPRINT.md` - Current development status
- `PROJECT_STATUS.md` - Overall project roadmap
- `ARCHITECTURE.md` - Technical architecture patterns

---

**Document Status:** 📋 Draft for Refinement  
**Next Steps:** Brainstorm session to refine mechanics, answer design questions, prioritize implementation
