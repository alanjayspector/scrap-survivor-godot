# Advisor System

## Table of Contents
1. [System Overview](#system-overview)
2. [Design Philosophy](#design-philosophy)
3. [Integration with Personalization System](#integration-with-personalization-system)
4. [Advice Categories](#advice-categories)
5. [Context-Aware Triggers](#context-aware-triggers)
6. [Advice Delivery Methods](#advice-delivery-methods)
7. [Tier-Specific Features](#tier-specific-features)
8. [UI Implementation](#ui-implementation)
9. [Advice Database & Content Management](#advice-database--content-management)
10. [Technical Architecture](#technical-architecture)
11. [Implementation Strategy](#implementation-strategy)
12. [Balancing Considerations](#balancing-considerations)
13. [Open Questions & Future Enhancements](#open-questions--future-enhancements)
14. [Summary](#summary)

---

## System Overview

The **Advisor System** provides contextual, personalized guidance to players based on their playstyle, current game state, and progression. Unlike generic tutorials or static tips, the Advisor System analyzes player behavior through the Personalization System and delivers tailored advice at critical decision points.

### Core Concepts

- **Contextual Intelligence**: Advice triggered by specific game states (low HP, ineffective build, resource mismanagement)
- **Playstyle Adaptation**: Recommendations match player's classified playstyle (Tank, Glass Cannon, etc.)
- **Progressive Disclosure**: New players receive more guidance, veterans receive advanced optimization tips
- **Non-Intrusive Design**: Advice available on-demand, minimally intrusive during gameplay
- **Tier-Based Depth**: Free tier gets basic tips, Premium gets build suggestions, Subscription gets advanced strategies

### Value Proposition

**For Players**:
- Faster learning curve for new players
- Build optimization suggestions for intermediate players
- Advanced strategy insights for veterans
- Reduces frustration from poor decisions
- Increases engagement through personalized guidance

**For Business**:
- Improved retention through better player experience
- Reduces support burden (fewer "how do I..." questions)
- Drives upgrades through feature differentiation
- Increases session length via engagement
- Creates opportunities for content marketing (sharing build advice)

### Key Features

1. **Smart Triggers**: Contextual advice based on 20+ game state conditions
2. **Build Advisor**: Suggests weapons/items that synergize with current loadout
3. **Economy Coach**: Helps players optimize scrap spending and resource management
4. **Death Analysis**: Post-death insights explaining what went wrong
5. **Progression Guidance**: Next steps recommendations based on account state
6. **Community Integration**: Surface popular builds and strategies from player data

---

## Design Philosophy

The Advisor System must walk a fine line between helpful and annoying. Our design philosophy ensures advice enhances rather than interrupts the player experience.

### Core Principles

#### 1. Helpful, Not Intrusive

**Problem**: Players hate being interrupted during intense gameplay.

**Solution**:
- Never show advice during combat unless player is paused
- Use subtle visual cues (pulsing icon) instead of popups
- Make all advice opt-in accessible from menu
- Respect player dismissals (don't repeat ignored advice)

**Implementation**:
```gdscript
# Only show advice when safe
func can_show_advice() -> bool:
    if GameStateService.is_in_combat():
        return false
    if GameStateService.is_player_paused():
        return true
    if GameStateService.is_in_safe_zone():
        return true
    return false
```

#### 2. Contextual, Not Generic

**Problem**: Generic "tips and tricks" feel useless and annoying.

**Solution**:
- Analyze current game state before generating advice
- Reference specific player stats, items, and recent events
- Provide actionable recommendations, not vague suggestions
- Show why advice is relevant right now

**Example**:
```
❌ Bad: "Try using different weapons!"
✅ Good: "Your Minigun deals 45 DPS but you have 200% melee damage.
         Consider switching to Chainsaw (estimated 120 DPS with your build)."
```

#### 3. Progressive, Not Overwhelming

**Problem**: New players overwhelmed by complexity, veterans bored by basics.

**Solution**:
- Track player skill level (beginner → intermediate → expert → master)
- Show basic advice to new players, advanced optimization to veterans
- Unlock new advice categories as player progresses
- Never show the same advice twice unless circumstances change significantly

**Skill Progression**:
```gdscript
enum SkillLevel {
    BEGINNER,     # < 10 runs, basic survival tips
    INTERMEDIATE, # 10-50 runs, build synergies
    EXPERT,       # 50-200 runs, advanced optimization
    MASTER        # 200+ runs, meta strategies
}
```

#### 4. Personalized, Not One-Size-Fits-All

**Problem**: Players have different playstyles and preferences.

**Solution**:
- Use Personalization System to classify playstyle
- Recommend builds matching player's preferred archetype
- Adapt advice tone based on player behavior (aggressive vs cautious)
- Learn from player responses (what advice they follow vs ignore)

**Personalization Integration**:
```gdscript
func get_build_advice(profile: PersonalizationProfile) -> String:
    match profile.primary_playstyle:
        Playstyle.TANK:
            return "Your HP is high but armor is low. Grab Body Armor for +50% effective HP."
        Playstyle.GLASS_CANNON:
            return "Consider Lifesteal Ring to compensate for low max HP."
        Playstyle.RANGED_DPS:
            return "Backpack increases range by 20% - great for your playstyle."
```

#### 5. Data-Driven, Not Arbitrary

**Problem**: Bad advice erodes player trust.

**Solution**:
- Base recommendations on actual player data and success rates
- A/B test advice effectiveness (do players who follow advice perform better?)
- Surface meta strategies discovered by top players
- Update advice dynamically as game balance changes

**Validation Process**:
- Track advice acceptance rate (% of players who follow suggestions)
- Measure outcome improvement (DPS increase, survival time, etc.)
- Disable low-performing advice automatically
- Promote high-performing advice more frequently

---

## Integration with Personalization System

The Advisor System is a primary consumer of the Personalization System, using playstyle classification and behavioral data to generate tailored advice.

### Data Flow

```
PersonalizationProfile (playstyle, preferences, stats)
    ↓
AdvisorService.analyze_context(profile, game_state)
    ↓
RecommendationEngine.generate_advice(analysis)
    ↓
AdvisorUI.display_advice(advice, priority)
```

### Personalization Inputs

The Advisor System uses these Personalization Profile fields:

#### 1. Playstyle Classification
```gdscript
var profile = PersonalizationService.get_profile()
var playstyle = profile.primary_playstyle  # TANK, GLASS_CANNON, etc.
var confidence = profile.classification_confidence  # 0.0-1.0

# High confidence = specific advice, low confidence = broader suggestions
if confidence > 0.7:
    advice = get_archetype_specific_advice(playstyle)
else:
    advice = get_general_advice_with_multiple_options()
```

#### 2. Character Type Preferences
```gdscript
# If player always picks Speedy McSpeed, suggest items that benefit speed
if profile.favorite_character_type == "Speedy McSpeed":
    recommend_items([
        "Rocket Boots (+50% speed)",
        "Energy Drink (+20% speed, +10% attack speed)",
        "Momentum Gauntlets (damage scales with speed)"
    ])
```

#### 3. Weapon & Item Preferences
```gdscript
# Recommend weapons player historically enjoys
var top_weapons = profile.top_weapon_types  # ["melee", "explosive"]

if "melee" in top_weapons and current_build_lacks_melee():
    advice = "You usually perform well with melee weapons. Try Chainsaw?"
```

#### 4. Behavioral Patterns
```gdscript
# Aggressive players get damage advice, cautious players get survival advice
if profile.aggression_score > 0.7:
    focus_on_damage_optimization()
elif profile.caution_score > 0.7:
    focus_on_survival_optimization()
```

#### 5. Skill Level
```gdscript
# Beginners: "Pick up items during combat"
# Experts: "Your DPS could increase 15% by swapping Pistol for SMG"
match profile.skill_level:
    SkillLevel.BEGINNER:
        show_basic_survival_tips()
    SkillLevel.EXPERT:
        show_advanced_optimization()
```

### Example: Context-Aware Build Advice

```gdscript
func generate_build_advice() -> Advice:
    var profile = PersonalizationService.get_profile()
    var character = GameStateService.get_current_character()
    var inventory = GameStateService.get_inventory()

    # Analyze current build effectiveness
    var analysis = BuildAnalyzer.analyze(character, inventory, profile)

    if analysis.effective_dps < analysis.potential_dps * 0.7:
        # Build is significantly suboptimal
        var best_swap = RecommendationEngine.get_best_weapon_swap(
            current_weapons = inventory.weapons,
            available_weapons = ShopService.get_current_shop_items(),
            playstyle = profile.primary_playstyle,
            stat_bonuses = character.get_stat_bonuses()
        )

        return Advice.new(
            category = AdviceCategory.BUILD_OPTIMIZATION,
            priority = Priority.HIGH,
            title = "Build Optimization Available",
            message = "Swapping %s for %s would increase DPS by %d%%" % [
                best_swap.current_weapon.name,
                best_swap.suggested_weapon.name,
                best_swap.improvement_percent
            ],
            action = "View Recommendation",
            data = best_swap
        )

    return null  # Build is already optimized
```

---

## Advice Categories

The Advisor System provides guidance across 8 core categories, each with tier-specific depth and personalization.

### 1. Build Optimization

**Purpose**: Help players create effective weapon/item combinations.

**Free Tier**:
- Basic synergy detection ("Minigun works well with +attack speed items")
- Simple stat calculations ("Your current DPS: 45")
- Item rarity explanations

**Premium Tier**:
- Detailed build analysis with DPS calculations
- Weapon swap recommendations with exact improvement percentages
- Item synergy scores (e.g., "This build has 85% synergy")

**Subscription Tier**:
- Meta builds from top 10% of players
- Personalized builds generated from your playstyle
- Build simulator (test builds before committing resources)

**Example Advice**:
```
🎯 Build Optimization Opportunity

Your current loadout:
  • Pistol (15 DPS)
  • Minigun (30 DPS)
  • +120% melee damage from items

Problem: You have 120% melee damage but no melee weapons!

Suggestion: Replace Pistol with Chainsaw
  • Current total DPS: 45
  • Potential DPS with Chainsaw: 98 (+118%)

💎 Premium: See 3 more optimized builds for your playstyle
```

**Triggers**:
- Stat bonuses don't match weapon types
- DPS significantly below potential
- After picking up items that create new synergies
- When shop offers items that complete strong builds

---

### 2. Combat Strategy

**Purpose**: Teach players effective tactics for surviving and dealing damage.

**Free Tier**:
- Basic kiting techniques
- When to engage vs when to retreat
- Enemy priority targeting

**Premium Tier**:
- Advanced positioning strategies
- Wave-specific tactics (boss waves, swarm waves)
- Risk/reward analysis for aggressive plays

**Subscription Tier**:
- Playstyle-specific strategies (Tank: front-line tactics, Glass Cannon: hit-and-run)
- Enemy pattern recognition and counter-strategies
- Frame-perfect optimization tips

**Example Advice**:
```
⚔️ Combat Strategy: Kiting

You're taking damage from all sides. Try this:

1. Keep moving in circles around enemy groups
2. Fire while moving (don't stop to shoot)
3. Create distance when HP drops below 50%

Your survival time increases 40% when using kiting.

💎 Premium: Learn advanced kiting patterns for your playstyle
```

**Triggers**:
- Player frequently dies to avoidable damage
- Player stands still too much during combat
- Player engages enemies inefficiently
- Player reaches milestone waves (10, 20, 30)

---

### 3. Economy Management

**Purpose**: Help players optimize scrap spending and resource allocation.

**Free Tier**:
- Basic spending priorities (weapons → items → character slots)
- Warning when about to make expensive mistake
- Scrap income optimization basics

**Premium Tier**:
- Detailed economy analysis (income rate, spending efficiency)
- ROI calculations for purchases
- Long-term resource planning

**Subscription Tier**:
- Quantum Banking optimization (when to transfer resources)
- Investment strategies (when to save vs spend)
- Character portfolio optimization

**Example Advice**:
```
💰 Economy Alert: Inefficient Spending

You just spent 500 scrap on Body Armor (+10 armor).

Analysis:
  • Your playstyle (Glass Cannon) doesn't benefit much from armor
  • Better purchase: Damage Ring (+15% damage, 300 scrap)
  • Estimated value lost: 200 scrap

Tip: Focus spending on damage items for your playstyle.

💎 Premium: Get personalized shopping list for every run
```

**Triggers**:
- Player about to purchase item with negative ROI
- Player hoarding scrap inefficiently
- Player spending scrap on items that don't match playstyle
- After major purchases (to reinforce good/bad decisions)

---

### 4. Death Analysis

**Purpose**: Help players understand why they died and how to improve.

**Free Tier**:
- Basic death cause (killed by X enemy type)
- Simple improvement suggestion

**Premium Tier**:
- Detailed death replay analysis
- Timeline of events leading to death
- Specific tactical errors identified

**Subscription Tier**:
- Side-by-side comparison with successful runs
- Personalized improvement plan based on recurring death patterns
- Access to top player replays of same wave/character

**Example Advice**:
```
💀 Death Analysis: Wave 15

Cause of Death: Overwhelmed by Swarm

What Happened:
  1. [12:34] HP dropped to 30% from boss damage
  2. [12:41] Didn't heal immediately
  3. [12:45] Swarm spawned while HP still low
  4. [12:47] Death

What to Do Differently:
  ✓ Heal immediately when HP < 50% during boss waves
  ✓ Position near health drops before swarm waves
  ✓ Consider buying Health Regeneration item (you rarely use healing)

Your success rate on wave 15: 60% (below average 75%)

💎 Premium: Watch how top players survive wave 15 with similar builds
```

**Triggers**:
- After every death (automatic)
- Player can review past deaths in Advisor menu

---

### 5. Progression Guidance

**Purpose**: Help players understand next steps and long-term goals.

**Free Tier**:
- Current tier status and benefits
- Basic unlock paths (characters, perks)
- Referral program explanation

**Premium Tier**:
- Personalized unlock priority recommendations
- Progression efficiency analysis
- Time-to-goal estimates

**Subscription Tier**:
- Long-term character portfolio strategy
- Perk tree optimization for playstyle
- Event timing and planning

**Example Advice**:
```
🎯 Next Steps: Progression Path

Your Account Status:
  • Level: 42 (Premium Tier)
  • Perks Unlocked: 12 / 50
  • Characters: 3 / 10
  • Total Runs: 78

Recommended Next Steps:
  1. Unlock "Scrap Magnet" perk (increases income by 20%)
     - Cost: 5,000 scrap
     - ROI: ~15 runs to break even
     - Priority: HIGH (best perk for your playstyle)

  2. Unlock "Tank Thompson" character
     - You enjoy Tank playstyle but only have Glass Cannon characters
     - Cost: 8,000 scrap
     - Priority: MEDIUM

  3. Participate in Winter Event (starts in 3 days)
     - Exclusive items benefit your preferred weapons
     - Priority: HIGH

⭐ Subscription: Get week-by-week progression roadmap
```

**Triggers**:
- After completing major milestones
- When player has sufficient resources for important unlocks
- When events are approaching
- After player seems directionless (many short sessions with no progress)

---

### 6. Social & Community

**Purpose**: Connect players with community resources and social features.

**Free Tier**:
- Referral program reminders
- Trading card sharing prompts
- Community event notifications

**Premium Tier**:
- Friend leaderboard positioning
- Build sharing with comparison stats
- Community meta reports

**Subscription Tier**:
- Exclusive community features
- Top player build access
- Event team formation assistance

**Example Advice**:
```
👥 Community Insight: Popular Builds

This week's meta (from 10,000+ runs):

Top 3 Builds:
  1. "Speed Demon" (28% play rate, 72% success rate)
     - Speedy McSpeed + Rocket Boots + Energy Drink
     - Avg survival: Wave 25

  2. "Tank & Spank" (22% play rate, 68% success rate)
     - Tank Thompson + Body Armor + Lifesteal
     - Avg survival: Wave 23

  3. "Glass Cannon" (18% play rate, 65% success rate)  ← Your style!
     - Gunner Greta + Damage Ring + Critical Hit
     - Avg survival: Wave 24

Your best run: Wave 22 (top 40% of Glass Cannon players)

💎 Premium: Copy exact item builds from top players
```

**Triggers**:
- Weekly meta report release
- After player achieves personal best
- When player's build matches trending builds
- After extended play sessions (social sharing opportunity)

---

### 7. Character-Specific Tips

**Purpose**: Teach players how to maximize each character's unique strengths.

**Free Tier**:
- Basic character ability explanations
- Simple strategy for each character
- Character unlock recommendations

**Premium Tier**:
- Advanced character synergies
- Character + item combo guides
- Playstyle-to-character matching

**Subscription Tier**:
- Mastery guides for each character
- Character meta analysis
- Personalized character recommendations

**Example Advice**:
```
🦾 Character Tip: Speedy McSpeed

Character Ability: +30% movement speed

Synergies to Exploit:
  ✓ Momentum-based damage items (damage scales with speed)
  ✓ Kiting strategies (outrun enemies while dealing damage)
  ✓ Item collection efficiency (cover more ground)

Items to Prioritize:
  1. Momentum Gauntlets (+50% damage at max speed)
  2. Rocket Boots (+50% additional speed)
  3. Wind Runner (+20% projectile speed)

Items to Avoid:
  ✗ Stationary turrets (you're always moving)
  ✗ Melee weapons (you want range to leverage speed)

Your Speed Stat: 185% (Good! Keep building into this)

💎 Premium: See full character mastery guide with video examples
```

**Triggers**:
- When player selects new character
- After first death with new character
- When player struggles with character (below average performance)
- When player discovers effective strategy (positive reinforcement)

---

### 8. Event & Seasonal Content

**Purpose**: Help players maximize event participation and rewards.

**Free Tier**:
- Event announcements
- Basic event rules and rewards
- Event currency explanations

**Premium Tier**:
- Event strategy guides
- Reward optimization advice
- Event leaderboard positioning

**Subscription Tier**:
- Exclusive event content access
- Event currency rollover management
- Personalized event roadmaps

**Example Advice**:
```
🎃 Event Alert: Halloween Harvest

Event Period: Oct 15 - Oct 31 (12 days remaining)

Your Progress:
  • Pumpkin Coins: 2,450 / 5,000 needed for top rewards
  • Daily login streak: 3 days
  • Event runs completed: 8

Optimization Tips:
  1. Complete daily login for remaining 12 days = 1,200 coins
  2. Complete 5 more event runs = 1,500 coins
  3. Total achievable: 5,150 coins ✓ Enough for top rewards!

Reward Priority:
  1. Jack-O-Lantern Pet (3,000 coins) - LIMITED TIME
  2. Event Character Skin (1,500 coins)
  3. Candy Weapon Pack (500 coins)

⭐ Subscription Bonus: Event currency rolls over to next event!

⏰ Don't miss out! 12 days remaining.
```

**Triggers**:
- Event start (major notification)
- Daily during active events
- When player close to milestone rewards
- When event about to end (last chance reminder)
- After event ends (summary + rollover for subscribers)

---

## Context-Aware Triggers

The Advisor System monitors 20+ game state conditions to deliver advice at the most relevant moments. Triggers are prioritized to avoid overwhelming players with too many notifications.

### Trigger Architecture

```gdscript
# services/AdvisorTriggerService.gd
class_name AdvisorTriggerService
extends Node

signal advice_triggered(advice: Advice)

# Trigger conditions checked every frame or on specific events
var trigger_checks = [
    SuboptimalBuildTrigger.new(),
    LowHealthNoHealingTrigger.new(),
    IneffectiveDamageTrigger.new(),
    ResourceWasteTrigger.new(),
    DeathAnalysisTrigger.new(),
    MilestoneReachedTrigger.new(),
    EventStartTrigger.new(),
    # ... 13 more triggers
]

func _ready():
    # Connect to game events
    GameStateService.wave_completed.connect(_on_wave_completed)
    GameStateService.character_died.connect(_on_character_died)
    GameStateService.item_purchased.connect(_on_item_purchased)
    ShopService.shop_opened.connect(_on_shop_opened)
    EventService.event_started.connect(_on_event_started)

func _process(_delta):
    # Check frame-based triggers (throttled to avoid performance issues)
    if should_check_triggers():
        check_continuous_triggers()

func check_continuous_triggers():
    for trigger in trigger_checks:
        if trigger.should_trigger():
            var advice = trigger.generate_advice()
            if should_show_advice(advice):
                emit_signal("advice_triggered", advice)
```

### Core Triggers

#### 1. Suboptimal Build Trigger

**Condition**: Player's current build is significantly weaker than potential.

**Logic**:
```gdscript
func should_trigger() -> bool:
    var current_dps = BuildAnalyzer.calculate_current_dps()
    var potential_dps = BuildAnalyzer.calculate_potential_dps()

    # Trigger if player could improve DPS by 30%+
    return potential_dps > current_dps * 1.3
```

**Frequency**: Once per shop visit (don't spam)

**Priority**: HIGH (directly impacts player success)

---

#### 2. Low Health No Healing Trigger

**Condition**: Player below 50% HP for 10+ seconds without healing.

**Logic**:
```gdscript
var low_health_timer = 0.0

func _process(delta):
    var player = GameStateService.get_player()

    if player.hp_percent < 0.5:
        low_health_timer += delta
        if low_health_timer > 10.0 and not recently_showed_healing_advice():
            trigger_healing_advice()
    else:
        low_health_timer = 0.0
```

**Frequency**: Max once per 60 seconds

**Priority**: CRITICAL (player about to die)

---

#### 3. Ineffective Damage Trigger

**Condition**: Player DPS significantly below wave difficulty.

**Logic**:
```gdscript
func should_trigger() -> bool:
    var current_wave = GameStateService.get_current_wave()
    var player_dps = BuildAnalyzer.calculate_current_dps()
    var recommended_dps = BalanceConfig.get_recommended_dps(current_wave)

    # Trigger if player has 30% less DPS than recommended
    return player_dps < recommended_dps * 0.7
```

**Frequency**: Once per wave

**Priority**: HIGH (player likely to fail without intervention)

---

#### 4. Resource Waste Trigger

**Condition**: Player about to make expensive mistake.

**Logic**:
```gdscript
func _on_item_about_to_purchase(item: Item, cost: int):
    var profile = PersonalizationService.get_profile()
    var roi = RecommendationEngine.calculate_roi(item, profile)

    if roi < 0.5:  # Item worth less than 50% of cost for this player
        show_warning_advice(item, roi)
```

**Frequency**: Pre-purchase only (blocking)

**Priority**: MEDIUM (prevents mistakes but not life-threatening)

---

#### 5. Death Analysis Trigger

**Condition**: Player character dies.

**Logic**:
```gdscript
func _on_character_died(death_data: Dictionary):
    # Always trigger after death
    var analysis = DeathAnalyzer.analyze(death_data)
    show_death_analysis(analysis)
```

**Frequency**: After every death (automatic)

**Priority**: HIGH (learning opportunity)

---

#### 6. Milestone Reached Trigger

**Condition**: Player reaches significant milestone.

**Logic**:
```gdscript
func _on_wave_completed(wave: int):
    if wave in [10, 20, 30, 40, 50]:
        show_milestone_advice(wave)

    # Personal best
    if wave > PlayerStats.get_personal_best():
        show_personal_best_advice(wave)
```

**Frequency**: Natural milestones only

**Priority**: LOW (celebratory, not urgent)

---

#### 7. Event Start Trigger

**Condition**: New event begins while player online.

**Logic**:
```gdscript
func _on_event_started(event: Event):
    show_event_introduction(event)
```

**Frequency**: Event start only

**Priority**: MEDIUM (time-sensitive but not urgent)

---

#### 8. Stat Mismatch Trigger

**Condition**: Player has stat bonuses that don't match equipped weapons.

**Logic**:
```gdscript
func should_trigger() -> bool:
    var stats = GameStateService.get_character_stats()
    var weapons = GameStateService.get_equipped_weapons()

    # Example: +200% melee damage but no melee weapons
    if stats.melee_damage_bonus > 1.5:
        var has_melee = weapons.any(func(w): return w.type == WeaponType.MELEE)
        if not has_melee:
            return true

    return false
```

**Frequency**: Once per shop visit

**Priority**: HIGH (easy fix, big impact)

---

#### 9. Shop Opened Trigger

**Condition**: Player opens shop.

**Logic**:
```gdscript
func _on_shop_opened():
    var profile = PersonalizationService.get_profile()
    var shop_items = ShopService.get_current_items()
    var recommendations = RecommendationEngine.rank_shop_items(shop_items, profile)

    # Highlight top 3 items for this player
    show_shopping_advice(recommendations.slice(0, 3))
```

**Frequency**: Once per shop opening

**Priority**: MEDIUM (helpful but not critical)

---

#### 10. First Time Experience Trigger

**Condition**: Player encounters new feature/character/item for first time.

**Logic**:
```gdscript
func _on_new_item_acquired(item: Item):
    if not PlayerProgress.has_seen_item(item.id):
        show_item_introduction(item)
        PlayerProgress.mark_item_seen(item.id)
```

**Frequency**: Once per unique item/feature

**Priority**: LOW (educational)

---

### Trigger Priority System

When multiple triggers activate simultaneously, priority determines which advice to show:

```gdscript
enum Priority {
    CRITICAL,  # Show immediately, block gameplay if needed (low HP warning)
    HIGH,      # Show at next safe opportunity (build optimization)
    MEDIUM,    # Queue for next break (economy tips)
    LOW        # Available in advisor menu only (fun facts)
}

func should_show_advice(advice: Advice) -> bool:
    match advice.priority:
        Priority.CRITICAL:
            return true  # Always show
        Priority.HIGH:
            return not is_high_intensity_moment()
        Priority.MEDIUM:
            return is_safe_moment() and advice_queue.size() < 3
        Priority.LOW:
            return false  # Never auto-show, menu only
```

### Trigger Cooldowns

To avoid overwhelming players, each trigger has cooldown periods:

```gdscript
var trigger_cooldowns = {
    "build_optimization": 300,      # 5 minutes
    "healing_reminder": 60,         # 1 minute
    "damage_warning": 120,          # 2 minutes
    "economy_tip": 600,             # 10 minutes
    "strategy_suggestion": 180,     # 3 minutes
}

func recently_showed_advice(trigger_type: String) -> bool:
    var last_shown = advice_history.get(trigger_type, 0)
    var now = Time.get_unix_time_from_system()
    return now - last_shown < trigger_cooldowns[trigger_type]
```

---

## Advice Delivery Methods

The Advisor System uses multiple UI patterns to deliver advice without disrupting gameplay.

### 1. Pulsing Advisor Icon

**Use Case**: Non-urgent advice available for review.

**Implementation**:
```gdscript
# UI/AdvisorIcon.gd
extends TextureButton

@onready var pulse_animation = $PulseAnimation

func show_advice_available():
    pulse_animation.play("pulse")
    tooltip_text = "New advice available! Click to view."

func _on_pressed():
    AdvisorUI.open_advice_panel()
    pulse_animation.stop()
```

**Visual**:
```
   ┌────────────────────┐
   │  Game HUD          │
   │                [💡] ← Pulsing advisor icon (top-right)
   └────────────────────┘
```

**Pros**:
- Non-intrusive
- Player controls when to view
- Works during combat

**Cons**:
- Easy to miss
- Requires player action

**Best For**: Low/medium priority advice, continuous availability

---

### 2. Tooltip Overlays

**Use Case**: Contextual advice when hovering over items/stats.

**Implementation**:
```gdscript
# UI/ItemTooltip.gd
extends Control

func show_for_item(item: Item):
    var profile = PersonalizationService.get_profile()
    var advice = AdvisorService.get_item_advice(item, profile)

    $ItemName.text = item.name
    $ItemStats.text = item.get_stats_text()

    if advice:
        $AdvisorInsight.text = "💡 " + advice
        $AdvisorInsight.show()
```

**Visual**:
```
┌─────────────────────────────────┐
│ Damage Ring                     │
│ +15% Damage                     │
│ Cost: 300 scrap                 │
│                                 │
│ 💡 Great for your Glass Cannon │
│    playstyle! Expected DPS      │
│    increase: 22%                │
└─────────────────────────────────┘
```

**Pros**:
- Contextual and relevant
- Doesn't interrupt gameplay
- Teaches while player browses

**Cons**:
- Only visible when hovering
- Easy to miss if player doesn't hover

**Best For**: Item recommendations, build synergies, stat explanations

---

### 3. Post-Wave Summary

**Use Case**: Advice delivered during natural break between waves.

**Implementation**:
```gdscript
# UI/WaveSummary.gd
extends Control

func show_wave_summary(wave: int):
    $WaveNumber.text = "Wave %d Complete!" % wave
    $Stats.text = get_wave_stats()

    var advice = AdvisorService.get_post_wave_advice()
    if advice:
        $AdvisorAdvice.text = advice.message
        $AdvisorAdvice.show()
```

**Visual**:
```
┌────────────────────────────────────┐
│     WAVE 10 COMPLETE!              │
│                                    │
│  Kills: 124    Scrap: 450          │
│  Damage Dealt: 12,450              │
│                                    │
│  💡 Advisor Tip:                   │
│  Wave 10 is a boss wave. Consider │
│  buying armor before wave 11.      │
│                                    │
│  [Continue] [View Builds]          │
└────────────────────────────────────┘
```

**Pros**:
- Perfect timing (player already paused)
- High visibility
- Natural integration

**Cons**:
- Can delay wave progression
- Player might skip quickly

**Best For**: Wave-specific strategies, milestone celebrations, progression guidance

---

### 4. Death Screen Analysis

**Use Case**: Post-death learning opportunity.

**Implementation**:
```gdscript
# UI/DeathScreen.gd
extends Control

func show_death_analysis(death_data: Dictionary):
    var analysis = DeathAnalyzer.analyze(death_data)

    $DeathCause.text = "Killed by: %s" % analysis.primary_cause
    $Timeline.populate(analysis.event_timeline)
    $Advice.text = analysis.improvement_suggestions

    if UserService.is_premium_or_higher():
        $DeathReplayButton.show()
```

**Visual**:
```
┌──────────────────────────────────────┐
│           YOU DIED                   │
│      Wave 15 - Killed by Swarm       │
│                                      │
│  💀 What Happened:                   │
│  1. HP dropped to 30% (boss damage)  │
│  2. Didn't heal immediately          │
│  3. Swarm spawned while HP low       │
│  4. Overwhelmed                      │
│                                      │
│  💡 What to Do Better:               │
│  ✓ Heal when HP < 50% during bosses  │
│  ✓ Position near health drops        │
│  ✓ Consider Health Regen item        │
│                                      │
│  [Retry] [View Build Analysis]       │
│                                      │
│  💎 Premium: Watch death replay       │
└──────────────────────────────────────┘
```

**Pros**:
- Player is receptive to learning
- Full attention (no gameplay distraction)
- Clear cause-and-effect

**Cons**:
- Can feel like salt in wound
- Player might be frustrated

**Best For**: Learning from mistakes, death pattern analysis, tactical improvements

---

### 5. In-Game Notifications

**Use Case**: Critical or time-sensitive advice.

**Implementation**:
```gdscript
# UI/NotificationManager.gd
extends Control

func show_notification(advice: Advice):
    var notif = NOTIFICATION_SCENE.instantiate()
    notif.set_advice(advice)
    notif.position = Vector2(get_viewport_rect().size.x - 320, 100)
    add_child(notif)

    # Auto-dismiss after 5 seconds
    await get_tree().create_timer(5.0).timeout
    notif.fade_out()
```

**Visual**:
```
                      ┌───────────────────────┐
                      │ ⚠️ Low Health Warning │
                      │                       │
                      │ You're at 25% HP!     │
                      │ Enemies nearby.       │
                      │                       │
                      │ [×] Heal Now          │
                      └───────────────────────┘
```

**Pros**:
- High visibility
- Can't be missed
- Works during gameplay

**Cons**:
- Interrupts gameplay flow
- Can be annoying if overused

**Best For**: Critical warnings (low HP), event alerts, milestone notifications

---

### 6. Advisor Panel (Menu)

**Use Case**: On-demand advice browsing.

**Implementation**:
```gdscript
# UI/AdvisorPanel.gd
extends Panel

@onready var category_tabs = $CategoryTabs
@onready var advice_list = $AdviceList

func _ready():
    populate_categories()
    load_available_advice()

func populate_categories():
    category_tabs.add_tab("All")
    category_tabs.add_tab("Build")
    category_tabs.add_tab("Combat")
    category_tabs.add_tab("Economy")
    category_tabs.add_tab("Strategy")

func load_available_advice():
    var all_advice = AdvisorService.get_all_available_advice()
    for advice in all_advice:
        add_advice_item(advice)
```

**Visual**:
```
┌─────────────────────────────────────────┐
│  📚 Advisor Hub                         │
├─────────────────────────────────────────┤
│  [All] [Build] [Combat] [Economy] [...]  │
├─────────────────────────────────────────┤
│                                         │
│  💡 Build Optimization Available        │
│     Improve your DPS by 35%...          │
│     [View Details]                      │
│                                         │
│  ⚔️ Wave 15 Strategy                    │
│     Boss wave incoming...               │
│     [View Details]                      │
│                                         │
│  💰 Recommended Purchases               │
│     Top 3 items for your playstyle...   │
│     [View Details]                      │
│                                         │
│  📊 Your Statistics                     │
│     Success rate: 65% | Avg wave: 18    │
│     [View Full Stats]                   │
│                                         │
└─────────────────────────────────────────┘
```

**Pros**:
- Never interrupts gameplay
- Player browses at own pace
- Can show history of past advice

**Cons**:
- Requires player to seek out
- Low engagement rate

**Best For**: Low priority tips, historical advice review, detailed guides

---

### 7. Loading Screen Tips

**Use Case**: Show advice during loading/transition screens.

**Implementation**:
```gdscript
# UI/LoadingScreen.gd
extends Control

func show_loading_tip():
    var tips = AdvisorService.get_loading_tips()
    var random_tip = tips[randi() % tips.size()]
    $TipLabel.text = "💡 Tip: " + random_tip
```

**Visual**:
```
┌──────────────────────────────────┐
│                                  │
│       LOADING...                 │
│      [████████░░] 80%            │
│                                  │
│  💡 Tip: Melee weapons benefit   │
│     from +melee damage items     │
│     but not +attack speed.       │
│                                  │
└──────────────────────────────────┘
```

**Pros**:
- Utilizes dead time
- No gameplay interruption
- Can be educational

**Cons**:
- Easy to miss (players look away)
- Loading screens may be too fast

**Best For**: General tips, fun facts, community highlights

---

### Delivery Priority Rules

```gdscript
func choose_delivery_method(advice: Advice) -> DeliveryMethod:
    match advice.priority:
        Priority.CRITICAL:
            return DeliveryMethod.IN_GAME_NOTIFICATION  # Show immediately

        Priority.HIGH:
            if GameStateService.is_in_shop():
                return DeliveryMethod.TOOLTIP_OVERLAY
            elif GameStateService.is_between_waves():
                return DeliveryMethod.POST_WAVE_SUMMARY
            else:
                return DeliveryMethod.PULSING_ICON

        Priority.MEDIUM:
            if GameStateService.is_character_dead():
                return DeliveryMethod.DEATH_SCREEN
            else:
                return DeliveryMethod.PULSING_ICON

        Priority.LOW:
            return DeliveryMethod.ADVISOR_PANEL_ONLY
```

---

## Tier-Specific Features

The Advisor System provides increasing value across Free, Premium, and Subscription tiers.

### Free Tier

**Philosophy**: Provide helpful guidance without overwhelming new players.

**Features**:
- ✅ Basic build synergy detection
- ✅ Simple combat tips (kiting, targeting priority)
- ✅ Death cause identification
- ✅ Loading screen tips
- ✅ Item stat explanations
- ✅ Character ability descriptions
- ✅ Event notifications
- ✅ Milestone celebrations

**Limitations**:
- ❌ No personalized advice (generic tips only)
- ❌ No DPS calculations or build optimization
- ❌ No death replay or detailed analysis
- ❌ No meta build access
- ❌ Limited to 5 advice items per session

**Example Free Advice**:
```
💡 Tip: Melee Weapons

Melee weapons deal damage at close range.
Pair with +melee damage items for best results.

Try: Chainsaw + Damage Ring
```

**Business Logic**: Free tier gets enough value to understand the game, but hits limits that encourage upgrades.

---

### Premium Tier ($9.99)

**Philosophy**: Provide detailed optimization tools for engaged players.

**Features**:
- ✅ All Free features
- ✅ Personalized build recommendations (uses Personalization System)
- ✅ Detailed DPS calculations and comparisons
- ✅ Death timeline analysis (what happened and when)
- ✅ Weapon/item swap suggestions with improvement percentages
- ✅ Economy ROI calculations
- ✅ Wave-specific strategy guides
- ✅ Friend leaderboard positioning advice
- ✅ Build synergy scoring
- ✅ Access to community meta reports

**Limitations**:
- ❌ No access to top player builds
- ❌ No build simulator
- ❌ No advanced death replay features
- ❌ Limited to 20 advice items per session

**Example Premium Advice**:
```
🎯 Build Optimization: +118% DPS Possible

Current Loadout:
  • Pistol (15 DPS)
  • Minigun (30 DPS)
  • +120% melee damage from items

Problem: You have melee damage bonuses but no melee weapons!

Recommended Change:
  Replace Pistol with Chainsaw
  • Current total DPS: 45
  • With Chainsaw: 98 DPS
  • Improvement: +118%
  • Cost: 400 scrap
  • ROI: Pays for itself in ~2 waves

Your Playstyle: Glass Cannon
This change matches your aggressive play pattern.

[View Alternative Builds] [Simulate Build]
```

**Business Logic**: Premium players get professional-grade tools to optimize gameplay, but community/meta features reserved for subscribers.

---

### Subscription Tier ($4.99/month)

**Philosophy**: Provide cutting-edge insights and exclusive community access.

**Features**:
- ✅ All Premium features
- ✅ Access to top 10% player builds (meta database)
- ✅ Build simulator (test before buying)
- ✅ Advanced death replay with side-by-side comparisons
- ✅ Personalized weekly meta reports
- ✅ Event optimization roadmaps
- ✅ Character portfolio analysis
- ✅ Long-term progression planning
- ✅ Quantum Banking optimization advice
- ✅ Playstyle mastery guides
- ✅ Unlimited advice items per session

**Example Subscription Advice**:
```
👑 Meta Build: "Speed Tank" (Top 10% Players)

This week's most successful build for Tank playstyle:

Build Components:
  • Character: Tank Thompson
  • Weapons: Chainsaw + Flamethrower
  • Items: Body Armor, Lifesteal Ring, Rocket Boots
  • Stats: 250 HP, 150% melee damage, 80 armor

Performance Stats (from 1,245 runs):
  • Avg Survival: Wave 32
  • Success Rate: 78%
  • Avg Scrap Earned: 4,200

Why It Works:
  ✓ High HP + armor = extreme survivability
  ✓ Lifesteal compensates for aggressive playstyle
  ✓ Rocket Boots add mobility tanks usually lack
  ✓ Melee damage scales both weapons

Your Build Similarity: 60%
  You have: Chainsaw, Body Armor
  You need: Flamethrower, Lifesteal Ring, Rocket Boots

[Copy Build] [Simulate Build] [Watch Top Player Replay]

This build matches your preferred playstyle (85% match).
Estimated improvement over current build: +40% survival.
```

**Business Logic**: Subscribers get cutting-edge insights that create competitive advantage and justify recurring payment.

---

### Feature Comparison Table

| Feature | Free | Premium | Subscription |
|---------|------|---------|--------------|
| Basic tips & tutorials | ✅ | ✅ | ✅ |
| Item stat explanations | ✅ | ✅ | ✅ |
| Event notifications | ✅ | ✅ | ✅ |
| Death cause identification | ✅ | ✅ | ✅ |
| Personalized advice | ❌ | ✅ | ✅ |
| DPS calculations | ❌ | ✅ | ✅ |
| Build optimization suggestions | ❌ | ✅ | ✅ |
| Death timeline analysis | ❌ | ✅ | ✅ |
| Economy ROI calculations | ❌ | ✅ | ✅ |
| Wave strategy guides | ❌ | ✅ | ✅ |
| Community meta reports | ❌ | ✅ | ✅ |
| Top player build access | ❌ | ❌ | ✅ |
| Build simulator | ❌ | ❌ | ✅ |
| Advanced death replay | ❌ | ❌ | ✅ |
| Event optimization roadmaps | ❌ | ❌ | ✅ |
| Long-term progression planning | ❌ | ❌ | ✅ |
| Advice items per session | 5 | 20 | Unlimited |

---

## UI Implementation

Detailed UI specifications for all Advisor System interfaces.

### Advisor Icon (HUD)

**Location**: Top-right corner of game HUD

**States**:
1. **Inactive**: Gray icon, no animation
2. **Active**: Blue icon, pulsing animation
3. **Critical**: Red icon, rapid pulsing + exclamation mark

**Implementation**:
```gdscript
# UI/AdvisorIcon.gd
extends TextureButton

enum State { INACTIVE, ACTIVE, CRITICAL }

@export var inactive_texture: Texture2D
@export var active_texture: Texture2D
@export var critical_texture: Texture2D

var current_state = State.INACTIVE
var advice_count = 0

func _ready():
    AdvisorService.advice_triggered.connect(_on_advice_triggered)
    pressed.connect(_on_pressed)

func _on_advice_triggered(advice: Advice):
    advice_count += 1

    if advice.priority == Priority.CRITICAL:
        set_state(State.CRITICAL)
    elif current_state != State.CRITICAL:
        set_state(State.ACTIVE)

    update_tooltip()

func set_state(new_state: State):
    current_state = new_state

    match new_state:
        State.INACTIVE:
            texture_normal = inactive_texture
            $PulseAnimation.stop()
        State.ACTIVE:
            texture_normal = active_texture
            $PulseAnimation.play("pulse_slow")
        State.CRITICAL:
            texture_normal = critical_texture
            $PulseAnimation.play("pulse_fast")

func update_tooltip():
    if advice_count == 0:
        tooltip_text = "Advisor (no new advice)"
    else:
        tooltip_text = "Advisor (%d new tip%s)" % [
            advice_count,
            "s" if advice_count > 1 else ""
        ]

func _on_pressed():
    AdvisorUI.open_advice_panel()
    advice_count = 0
    set_state(State.INACTIVE)
    update_tooltip()
```

---

### Advisor Panel (Full Screen)

**Layout**:
```
┌────────────────────────────────────────────────────────────┐
│  📚 Advisor Hub                                      [×]    │
├──────────────────────────┬─────────────────────────────────┤
│                          │                                 │
│  CATEGORIES              │  ADVICE CONTENT                 │
│                          │                                 │
│  ▶ All Advice (3)        │  💡 Build Optimization          │
│  ▶ Build (1)             │     Available                   │
│  ▶ Combat (1)            │                                 │
│  ▶ Economy (1)           │  Your DPS could improve by 35%  │
│  ▶ Strategy (0)          │  by swapping Pistol for         │
│  ▶ Progression (0)       │  Chainsaw...                    │
│  ▶ Social (0)            │                                 │
│  ▶ Events (0)            │  [View Detailed Analysis]       │
│                          │  [Dismiss]                      │
│  ─────────────────       │                                 │
│                          │  ─────────────────────────      │
│  STATISTICS              │                                 │
│                          │  ⚔️ Wave 15 Strategy            │
│  Success Rate: 65%       │                                 │
│  Avg Wave: 18            │  Boss wave incoming. Consider   │
│  Total Runs: 78          │  these preparations...          │
│  Current Streak: 3       │                                 │
│                          │  [View Strategy Guide]          │
│  [View Full Stats]       │  [Dismiss]                      │
│                          │                                 │
└──────────────────────────┴─────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/AdvisorPanel.gd
extends Panel

@onready var category_tree = $HSplit/LeftPanel/CategoryTree
@onready var advice_container = $HSplit/RightPanel/AdviceContainer
@onready var stats_panel = $HSplit/LeftPanel/StatsPanel

func _ready():
    populate_categories()
    load_advice()
    update_statistics()

func populate_categories():
    category_tree.clear()
    var root = category_tree.create_item()

    var categories = [
        { "name": "All Advice", "count": get_total_advice_count() },
        { "name": "Build", "count": get_advice_count(AdviceCategory.BUILD) },
        { "name": "Combat", "count": get_advice_count(AdviceCategory.COMBAT) },
        { "name": "Economy", "count": get_advice_count(AdviceCategory.ECONOMY) },
        { "name": "Strategy", "count": get_advice_count(AdviceCategory.STRATEGY) },
        { "name": "Progression", "count": get_advice_count(AdviceCategory.PROGRESSION) },
        { "name": "Social", "count": get_advice_count(AdviceCategory.SOCIAL) },
        { "name": "Events", "count": get_advice_count(AdviceCategory.EVENTS) },
    ]

    for cat in categories:
        var item = category_tree.create_item(root)
        item.set_text(0, "%s (%d)" % [cat.name, cat.count])
        item.set_metadata(0, cat.name)

func load_advice(category: String = "All"):
    # Clear existing advice cards
    for child in advice_container.get_children():
        child.queue_free()

    var advice_list = AdvisorService.get_advice_by_category(category)

    for advice in advice_list:
        var card = ADVICE_CARD_SCENE.instantiate()
        card.set_advice(advice)
        advice_container.add_child(card)

func update_statistics():
    var stats = PlayerStats.get_stats()
    $HSplit/LeftPanel/StatsPanel/SuccessRate.text = "Success Rate: %.1f%%" % (stats.success_rate * 100)
    $HSplit/LeftPanel/StatsPanel/AvgWave.text = "Avg Wave: %d" % stats.avg_wave
    $HSplit/LeftPanel/StatsPanel/TotalRuns.text = "Total Runs: %d" % stats.total_runs
    $HSplit/LeftPanel/StatsPanel/CurrentStreak.text = "Current Streak: %d" % stats.current_streak
```

---

### Advice Card Component

**Visual**:
```
┌─────────────────────────────────────────┐
│ 💡 Build Optimization Available         │
│                                         │
│ Your DPS could improve by 35% by        │
│ swapping Pistol for Chainsaw.           │
│                                         │
│ Current DPS: 45                         │
│ Potential DPS: 61                       │
│                                         │
│ [View Details] [Dismiss]                │
│                                         │
│ Priority: HIGH | Category: Build        │
└─────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/AdviceCard.gd
extends PanelContainer

@onready var icon = $VBox/Header/Icon
@onready var title = $VBox/Header/Title
@onready var message = $VBox/Message
@onready var details_button = $VBox/Actions/DetailsButton
@onready var dismiss_button = $VBox/Actions/DismissButton
@onready var metadata_label = $VBox/Metadata

var advice: Advice

func set_advice(new_advice: Advice):
    advice = new_advice

    icon.texture = get_icon_for_category(advice.category)
    title.text = advice.title
    message.text = advice.message

    metadata_label.text = "Priority: %s | Category: %s" % [
        Priority.keys()[advice.priority],
        AdviceCategory.keys()[advice.category]
    ]

    details_button.pressed.connect(_on_details_pressed)
    dismiss_button.pressed.connect(_on_dismiss_pressed)

func _on_details_pressed():
    AdvisorDetailView.show_advice(advice)

func _on_dismiss_pressed():
    AdvisorService.dismiss_advice(advice.id)
    queue_free()
```

---

### Item Tooltip with Advisor Insight

**Visual**:
```
┌─────────────────────────────────────────┐
│ [Icon] Damage Ring                      │
│                                         │
│ STATS                                   │
│ • +15% Damage                           │
│ • +5% Critical Hit Chance               │
│                                         │
│ Cost: 300 scrap                         │
│ Rarity: Uncommon                        │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                         │
│ 💡 ADVISOR INSIGHT                      │
│                                         │
│ Perfect for your Glass Cannon           │
│ playstyle!                              │
│                                         │
│ Expected DPS increase: 22%              │
│ ROI: Pays for itself in 3 waves         │
│                                         │
│ Synergizes with: Critical Strike Perk  │
│                                         │
│ 💎 Premium: See full build path         │
└─────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/ItemTooltip.gd
extends PanelContainer

@onready var item_name = $VBox/Header/ItemName
@onready var stats_container = $VBox/Stats
@onready var cost_label = $VBox/Cost
@onready var advisor_section = $VBox/AdvisorSection

func show_for_item(item: Item):
    # Basic item info
    item_name.text = item.name
    populate_stats(item)
    cost_label.text = "Cost: %d scrap" % item.cost

    # Advisor insight (if available)
    var profile = PersonalizationService.get_profile()
    var advice = AdvisorService.get_item_advice(item, profile)

    if advice:
        advisor_section.show()
        $VBox/AdvisorSection/Message.text = advice.message

        if advice.has_premium_content and not UserService.is_premium_or_higher():
            $VBox/AdvisorSection/PremiumUpsell.show()
    else:
        advisor_section.hide()
```

---

### Death Screen with Analysis

**Visual**:
```
┌──────────────────────────────────────────────────┐
│                  YOU DIED                        │
│         Wave 15 - Killed by Swarm                │
│                                                  │
├──────────────────────────────────────────────────┤
│                                                  │
│  💀 WHAT HAPPENED                                │
│                                                  │
│  Timeline:                                       │
│  [12:34] HP dropped to 30% (boss damage)         │
│  [12:41] Didn't heal for 7 seconds               │
│  [12:45] Swarm spawned while HP still low        │
│  [12:47] Death                                   │
│                                                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                  │
│  💡 HOW TO IMPROVE                               │
│                                                  │
│  ✓ Heal immediately when HP < 50% during bosses  │
│  ✓ Position near health drops before swarms      │
│  ✓ Consider buying Health Regeneration item      │
│                                                  │
│  Your wave 15 success rate: 60%                  │
│  Average player success: 75%                     │
│                                                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                  │
│  [Retry Run] [View Build Analysis]               │
│                                                  │
│  💎 Premium: Watch death replay & see top        │
│     player strategies for wave 15                │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/DeathScreen.gd
extends Control

@onready var death_summary = $VBox/DeathSummary
@onready var timeline_container = $VBox/Timeline
@onready var advice_container = $VBox/Advice
@onready var stats_comparison = $VBox/StatsComparison
@onready var premium_upsell = $VBox/PremiumUpsell

func show_death_analysis(death_data: Dictionary):
    var analysis = DeathAnalyzer.analyze(death_data)

    # Death summary
    death_summary.text = "Wave %d - Killed by %s" % [
        death_data.wave,
        death_data.killer_name
    ]

    # Timeline
    populate_timeline(analysis.event_timeline)

    # Improvement advice
    populate_advice(analysis.improvement_suggestions)

    # Stats comparison
    var personal_success = PlayerStats.get_wave_success_rate(death_data.wave)
    var average_success = GlobalStats.get_wave_success_rate(death_data.wave)
    stats_comparison.text = "Your wave %d success rate: %.0f%%\nAverage player success: %.0f%%" % [
        death_data.wave,
        personal_success * 100,
        average_success * 100
    ]

    # Premium upsell
    if not UserService.is_premium_or_higher():
        premium_upsell.show()

func populate_timeline(events: Array):
    for event in events:
        var entry = Label.new()
        entry.text = "[%s] %s" % [
            format_time(event.timestamp),
            event.description
        ]
        timeline_container.add_child(entry)

func populate_advice(suggestions: Array):
    for suggestion in suggestions:
        var entry = Label.new()
        entry.text = "✓ " + suggestion
        advice_container.add_child(entry)
```

---

### In-Game Notification

**Visual**:
```
                ┌───────────────────────┐
                │ ⚠️ Low Health Warning │
                │                       │
                │ You're at 25% HP!     │
                │ Enemies nearby.       │
                │                       │
                │ Heal now? [Yes] [×]   │
                └───────────────────────┘
```

**Implementation**:
```gdscript
# UI/AdvisorNotification.gd
extends PanelContainer

@onready var icon = $HBox/Icon
@onready var title = $HBox/VBox/Title
@onready var message = $HBox/VBox/Message
@onready var action_button = $HBox/VBox/Actions/ActionButton
@onready var dismiss_button = $HBox/VBox/Actions/DismissButton

var advice: Advice

func set_advice(new_advice: Advice):
    advice = new_advice

    icon.texture = get_icon_for_priority(advice.priority)
    title.text = advice.title
    message.text = advice.message

    if advice.action:
        action_button.text = advice.action
        action_button.pressed.connect(_on_action_pressed)
        action_button.show()
    else:
        action_button.hide()

    dismiss_button.pressed.connect(_on_dismiss_pressed)

    # Auto-dismiss after 5 seconds for non-critical advice
    if advice.priority != Priority.CRITICAL:
        await get_tree().create_timer(5.0).timeout
        fade_out()

func _on_action_pressed():
    AdvisorService.execute_advice_action(advice)
    fade_out()

func _on_dismiss_pressed():
    AdvisorService.dismiss_advice(advice.id)
    fade_out()

func fade_out():
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.3)
    await tween.finished
    queue_free()
```

---

## Advice Database & Content Management

The Advisor System requires a comprehensive database of advice content that can be updated independently of game code.

### Database Schema

```sql
-- Advice templates (written by developers/designers)
CREATE TABLE advice_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category VARCHAR(50) NOT NULL,  -- 'build', 'combat', 'economy', etc.
  trigger_type VARCHAR(50) NOT NULL,
  priority VARCHAR(20) NOT NULL,  -- 'critical', 'high', 'medium', 'low'

  -- Content (supports variables like {item_name}, {dps_increase})
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  action_text TEXT,

  -- Conditions for showing this advice
  min_tier VARCHAR(20) DEFAULT 'free',  -- 'free', 'premium', 'subscription'
  min_skill_level VARCHAR(20) DEFAULT 'beginner',
  max_skill_level VARCHAR(20),
  playstyle_filter VARCHAR(20)[],  -- null = show to all playstyles

  -- Effectiveness tracking
  times_shown INT DEFAULT 0,
  times_followed INT DEFAULT 0,
  times_dismissed INT DEFAULT 0,
  avg_outcome_improvement FLOAT DEFAULT 0.0,

  -- Content management
  enabled BOOLEAN DEFAULT true,
  version INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Player-specific advice history
CREATE TABLE user_advice_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  advice_template_id UUID REFERENCES advice_templates(id),

  -- Event details
  shown_at TIMESTAMPTZ DEFAULT NOW(),
  dismissed_at TIMESTAMPTZ,
  followed_at TIMESTAMPTZ,

  -- Context when advice was shown
  character_id UUID,
  wave INT,
  game_state JSONB,

  -- Outcome tracking
  outcome_measured BOOLEAN DEFAULT false,
  outcome_improvement FLOAT,  -- e.g., DPS increase, survival time increase

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Dynamic advice (generated on-the-fly)
CREATE TABLE dynamic_advice (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  category VARCHAR(50) NOT NULL,
  priority VARCHAR(20) NOT NULL,

  -- Generated content
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  action_data JSONB,

  -- Context
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  shown BOOLEAN DEFAULT false,
  dismissed BOOLEAN DEFAULT false
);

-- Meta builds (for Subscription tier)
CREATE TABLE meta_builds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,

  -- Build details
  character_type VARCHAR(50) NOT NULL,
  weapons JSONB NOT NULL,  -- Array of weapon IDs
  items JSONB NOT NULL,    -- Array of item IDs
  playstyle VARCHAR(20) NOT NULL,

  -- Performance metrics (from real player data)
  times_attempted INT DEFAULT 0,
  success_rate FLOAT DEFAULT 0.0,
  avg_wave_reached FLOAT DEFAULT 0.0,
  avg_scrap_earned FLOAT DEFAULT 0.0,

  -- Metadata
  created_by VARCHAR(20) DEFAULT 'community',  -- 'community', 'developer', 'ai'
  tier_requirement VARCHAR(20) DEFAULT 'subscription',
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Content Management

**Developer Tools**:

```gdscript
# tools/AdvisorContentEditor.gd
@tool
extends EditorPlugin

# In-editor tool for creating/testing advice templates
func _enter_tree():
    add_custom_type("AdviceTemplate", "Resource", preload("advice_template.gd"), icon)

func create_advice_template():
    var template = AdviceTemplate.new()
    template.category = AdviceCategory.BUILD
    template.trigger_type = "suboptimal_build"
    template.priority = Priority.HIGH
    template.title = "Build Optimization Available"
    template.message = "Your DPS could improve by {dps_increase}% by swapping {current_weapon} for {suggested_weapon}."
    template.min_tier = "premium"

    ResourceSaver.save(template, "res://data/advice/build_optimization_001.tres")
```

**Dynamic Content Generation**:

```gdscript
# services/AdviceGenerator.gd
class_name AdviceGenerator
extends Node

func generate_build_advice(profile: PersonalizationProfile) -> Advice:
    var character = GameStateService.get_current_character()
    var inventory = GameStateService.get_inventory()

    var analysis = BuildAnalyzer.analyze(character, inventory, profile)

    if analysis.improvement_available:
        return Advice.new({
            "category": AdviceCategory.BUILD,
            "priority": Priority.HIGH,
            "title": "Build Optimization Available",
            "message": "Your DPS could improve by %d%% by swapping %s for %s." % [
                analysis.dps_improvement_percent,
                analysis.current_weapon.name,
                analysis.suggested_weapon.name
            ],
            "action": "View Details",
            "data": analysis
        })

    return null
```

**A/B Testing Framework**:

```gdscript
# services/AdviceABTest.gd
class_name AdviceABTest
extends Node

func select_advice_variant(user_id: UUID, advice_type: String) -> AdviceTemplate:
    # Assign users to A/B test groups deterministically
    var group = hash(str(user_id) + advice_type) % 2

    match advice_type:
        "build_optimization":
            if group == 0:
                return load("res://data/advice/build_opt_variant_a.tres")
            else:
                return load("res://data/advice/build_opt_variant_b.tres")

    return null

func track_outcome(user_id: UUID, advice_id: UUID, followed: bool, improvement: float):
    SupabaseService.insert("advice_outcomes", {
        "user_id": user_id,
        "advice_id": advice_id,
        "followed": followed,
        "improvement": improvement,
        "timestamp": Time.get_unix_time_from_system()
    })
```

---

## Technical Architecture

### Service Layer

```gdscript
# services/AdvisorService.gd
class_name AdvisorService
extends Node

signal advice_triggered(advice: Advice)
signal advice_followed(advice: Advice)
signal advice_dismissed(advice: Advice)

var active_advice: Array[Advice] = []
var advice_history: Array[Advice] = []
var trigger_service: AdvisorTriggerService
var generator: AdviceGenerator

func _ready():
    trigger_service = AdvisorTriggerService.new()
    generator = AdviceGenerator.new()

    trigger_service.advice_triggered.connect(_on_advice_triggered)

func _on_advice_triggered(advice: Advice):
    # Check if we should show this advice
    if not should_show_advice(advice):
        return

    # Add to active advice queue
    active_advice.append(advice)
    emit_signal("advice_triggered", advice)

    # Track in database
    track_advice_shown(advice)

func should_show_advice(advice: Advice) -> bool:
    # Check tier requirements
    var user_tier = UserService.get_user_tier()
    if advice.min_tier > user_tier:
        return false

    # Check cooldowns
    if recently_showed_similar_advice(advice):
        return false

    # Check advice limit for tier
    var limit = get_advice_limit_for_tier(user_tier)
    if active_advice.size() >= limit:
        return false

    return true

func get_all_available_advice() -> Array[Advice]:
    return active_advice.duplicate()

func get_advice_by_category(category: AdviceCategory) -> Array[Advice]:
    return active_advice.filter(func(a): return a.category == category)

func dismiss_advice(advice_id: String):
    var advice = active_advice.filter(func(a): return a.id == advice_id).front()
    if advice:
        active_advice.erase(advice)
        advice_history.append(advice)
        emit_signal("advice_dismissed", advice)
        track_advice_dismissed(advice)

func follow_advice(advice: Advice):
    emit_signal("advice_followed", advice)
    track_advice_followed(advice)

func execute_advice_action(advice: Advice):
    # Execute the suggested action
    match advice.category:
        AdviceCategory.BUILD:
            open_build_analyzer(advice.data)
        AdviceCategory.COMBAT:
            open_strategy_guide(advice.data)
        AdviceCategory.ECONOMY:
            open_shop_with_recommendations(advice.data)

# Analytics
func track_advice_shown(advice: Advice):
    SupabaseService.insert("user_advice_history", {
        "user_id": UserService.get_current_user_id(),
        "advice_template_id": advice.template_id,
        "shown_at": Time.get_unix_time_from_system(),
        "game_state": GameStateService.serialize_state()
    })

func track_advice_followed(advice: Advice):
    SupabaseService.update("user_advice_history", {
        "followed_at": Time.get_unix_time_from_system()
    }, "advice_id = '%s'" % advice.id)

func track_advice_dismissed(advice: Advice):
    SupabaseService.update("user_advice_history", {
        "dismissed_at": Time.get_unix_time_from_system()
    }, "advice_id = '%s'" % advice.id)
```

### Data Models

```gdscript
# models/Advice.gd
class_name Advice
extends Resource

@export var id: String
@export var template_id: String
@export var category: AdviceCategory
@export var priority: Priority
@export var title: String
@export var message: String
@export var action: String
@export var data: Dictionary
@export var min_tier: UserTier
@export var has_premium_content: bool
@export var created_at: float

func _init(properties: Dictionary = {}):
    id = properties.get("id", UUID.v4())
    template_id = properties.get("template_id", "")
    category = properties.get("category", AdviceCategory.GENERAL)
    priority = properties.get("priority", Priority.MEDIUM)
    title = properties.get("title", "")
    message = properties.get("message", "")
    action = properties.get("action", "")
    data = properties.get("data", {})
    min_tier = properties.get("min_tier", UserTier.FREE)
    has_premium_content = properties.get("has_premium_content", false)
    created_at = Time.get_unix_time_from_system()

enum AdviceCategory {
    BUILD,
    COMBAT,
    ECONOMY,
    STRATEGY,
    PROGRESSION,
    SOCIAL,
    CHARACTER,
    EVENT,
    GENERAL
}

enum Priority {
    CRITICAL,  # Must show immediately
    HIGH,      # Show at next opportunity
    MEDIUM,    # Queue for later
    LOW        # Menu only
}
```

### Build Analyzer

```gdscript
# services/BuildAnalyzer.gd
class_name BuildAnalyzer
extends Node

func analyze(character: Character, inventory: Inventory, profile: PersonalizationProfile) -> BuildAnalysis:
    var analysis = BuildAnalysis.new()

    # Calculate current DPS
    analysis.current_dps = calculate_dps(character, inventory.weapons, inventory.items)

    # Find optimal weapon loadout
    var optimal_weapons = find_optimal_weapons(character, inventory.items, profile)
    analysis.potential_dps = calculate_dps(character, optimal_weapons, inventory.items)

    # Calculate improvement
    analysis.dps_improvement_percent = ((analysis.potential_dps - analysis.current_dps) / analysis.current_dps) * 100

    # Identify specific recommendations
    if analysis.dps_improvement_percent > 30:
        analysis.improvement_available = true
        analysis.recommended_changes = generate_recommendations(
            current_weapons = inventory.weapons,
            optimal_weapons = optimal_weapons
        )

    return analysis

func calculate_dps(character: Character, weapons: Array[Weapon], items: Array[Item]) -> float:
    var total_dps = 0.0

    for weapon in weapons:
        var base_dps = weapon.damage * weapon.fire_rate

        # Apply stat bonuses from items
        var damage_multiplier = 1.0
        var attack_speed_multiplier = 1.0

        for item in items:
            if weapon.type == WeaponType.MELEE:
                damage_multiplier += item.melee_damage_bonus
            elif weapon.type == WeaponType.RANGED:
                damage_multiplier += item.ranged_damage_bonus

            attack_speed_multiplier += item.attack_speed_bonus

        var effective_dps = base_dps * damage_multiplier * attack_speed_multiplier
        total_dps += effective_dps

    return total_dps

func find_optimal_weapons(character: Character, items: Array[Item], profile: PersonalizationProfile) -> Array[Weapon]:
    var available_weapons = ItemDatabase.get_all_weapons()
    var item_stat_bonuses = calculate_stat_bonuses(items)

    var best_combination = []
    var best_dps = 0.0

    # Brute force check all weapon combinations (could be optimized)
    for weapon1 in available_weapons:
        for weapon2 in available_weapons:
            if weapon1 == weapon2:
                continue

            var combination = [weapon1, weapon2]
            var dps = calculate_dps(character, combination, items)

            if dps > best_dps:
                best_dps = dps
                best_combination = combination

    return best_combination
```

---

## Implementation Strategy

### Phase 1: Core Infrastructure (Week 11 Day 1-3) - 3 days

**Goal**: Build foundational systems.

**Tasks**:
1. Create AdvisorService with basic advice queueing
2. Implement Advice data model and priority system
3. Build AdvisorTriggerService with 5 core triggers:
   - Suboptimal build
   - Low health
   - Death analysis
   - Shop opened
   - Event start
4. Create simple advice templates in JSON
5. Implement basic UI: advisor icon + advice panel

**Deliverables**:
- AdvisorService (150 lines)
- AdvisorTriggerService (200 lines)
- Advice model (80 lines)
- AdvisorIcon UI (100 lines)
- AdvisorPanel UI (150 lines)
- 10 advice templates

**Testing**:
- Trigger advice manually, verify queueing works
- Test priority system (critical shows immediately, low waits)
- Verify UI displays advice correctly

---

### Phase 2: Personalization Integration (Week 11 Day 4-5) - 2 days

**Goal**: Connect Advisor to Personalization System.

**Tasks**:
1. Integrate PersonalizationService into advice generation
2. Implement playstyle-specific advice templates
3. Build BuildAnalyzer service
4. Create DPS calculation system
5. Add personalized build recommendations

**Deliverables**:
- BuildAnalyzer (250 lines)
- 20 playstyle-specific advice templates
- Integration layer (100 lines)

**Testing**:
- Create test profiles for each playstyle
- Verify Tank gets tank advice, Glass Cannon gets damage advice
- Test build analysis accuracy (manual DPS verification)

---

### Phase 3: Advice Categories & Content (Week 12 Day 1-3) - 3 days

**Goal**: Implement all 8 advice categories with rich content.

**Tasks**:
1. Create advice generators for each category:
   - Build Optimization ✓ (from Phase 2)
   - Combat Strategy
   - Economy Management
   - Death Analysis
   - Progression Guidance
   - Social & Community
   - Character-Specific
   - Event & Seasonal
2. Write 100+ advice templates (20 per category)
3. Implement context-aware triggers for each category
4. Build DeathAnalyzer service

**Deliverables**:
- 8 advice generator modules (1,200 lines total)
- 100+ advice templates
- DeathAnalyzer (300 lines)

**Testing**:
- Trigger each advice category manually
- Verify advice relevance (does it match game state?)
- Test death analysis with various death scenarios

---

### Phase 4: Advanced UI & Delivery (Week 12 Day 4-5) - 2 days

**Goal**: Implement all advice delivery methods.

**Tasks**:
1. Build tooltip overlay system with advisor insights
2. Create post-wave summary with advice section
3. Implement death screen with analysis
4. Add in-game notifications for critical advice
5. Build comprehensive advice panel with categories
6. Implement loading screen tips

**Deliverables**:
- ItemTooltip with advisor section (150 lines)
- WaveSummary with advice (100 lines)
- DeathScreen with analysis (200 lines)
- AdvisorNotification component (120 lines)
- Enhanced AdvisorPanel (300 lines)
- LoadingTips system (80 lines)

**Testing**:
- Test each delivery method in appropriate context
- Verify advice doesn't interrupt critical gameplay
- Test readability and clarity of UI

---

### Phase 5: Tier Differentiation (Week 13 Day 1-2) - 2 days

**Goal**: Implement tier-specific features and upsells.

**Tasks**:
1. Add tier checking to advice visibility
2. Implement advice limits per tier (Free: 5, Premium: 20, Subscription: unlimited)
3. Create premium upsell UI components
4. Build meta builds database for Subscription tier
5. Add "Premium Feature" tags throughout UI

**Deliverables**:
- Tier gating logic (100 lines)
- PremiumUpsell UI component (80 lines)
- MetaBuilds database & UI (200 lines)
- Tier comparison table in advisor panel

**Testing**:
- Test with Free, Premium, Subscription accounts
- Verify upsells show at appropriate times
- Confirm advice limits enforced correctly

---

### Phase 6: Database & Analytics (Week 13 Day 3-4) - 2 days

**Goal**: Implement persistence and effectiveness tracking.

**Tasks**:
1. Create Supabase tables (advice_templates, user_advice_history, meta_builds)
2. Implement advice tracking (shown, followed, dismissed)
3. Build outcome measurement system
4. Create analytics dashboard for developers
5. Implement A/B testing framework

**Deliverables**:
- Supabase migration scripts
- AdviceAnalytics service (200 lines)
- Developer dashboard (web interface)
- A/B testing framework (150 lines)

**Testing**:
- Verify advice history saves to database
- Test outcome tracking (does it measure DPS improvement?)
- Validate A/B test group assignment (50/50 split?)

---

### Phase 7: Content Creation & Polish (Week 13 Day 5) - 1 day

**Goal**: Create comprehensive advice content and polish UX.

**Tasks**:
1. Write 200+ total advice templates covering all scenarios
2. Record meta builds from simulated player data
3. Polish UI animations and transitions
4. Add sound effects for advice notifications
5. Implement advice cooldowns and anti-spam measures
6. Final QA pass

**Deliverables**:
- 200+ advice templates
- 20+ meta builds
- Polished UI with animations
- Sound effects
- Anti-spam system (50 lines)

**Testing**:
- Full playthrough with advisor active
- Verify advice feels helpful not annoying
- Test with multiple players for feedback

---

### Timeline Summary

| Phase | Duration | Effort | Dependencies |
|-------|----------|--------|--------------|
| 1. Core Infrastructure | 3 days | 8 hours/day | None |
| 2. Personalization Integration | 2 days | 8 hours/day | PersonalizationService |
| 3. Advice Categories & Content | 3 days | 8 hours/day | Phase 1-2 |
| 4. Advanced UI & Delivery | 2 days | 8 hours/day | Phase 1-3 |
| 5. Tier Differentiation | 2 days | 6 hours/day | UserService, SubscriptionService |
| 6. Database & Analytics | 2 days | 6 hours/day | SupabaseService |
| 7. Content & Polish | 1 day | 8 hours/day | All previous |
| **Total** | **15 days** | **~100 hours** | - |

---

## Balancing Considerations

### Helpfulness vs Annoyance

**Problem**: Too much advice feels like nagging, too little feels unhelpful.

**Solution**:
1. **Adaptive Frequency**: Show less advice to experienced players
   ```gdscript
   func get_advice_frequency_multiplier(skill_level: SkillLevel) -> float:
       match skill_level:
           SkillLevel.BEGINNER: return 1.0      # Normal frequency
           SkillLevel.INTERMEDIATE: return 0.6  # 40% less
           SkillLevel.EXPERT: return 0.3        # 70% less
           SkillLevel.MASTER: return 0.1        # 90% less
   ```

2. **Respect Dismissals**: If player dismisses advice type multiple times, stop showing it
   ```gdscript
   func should_respect_user_preference(advice_type: String) -> bool:
       var dismiss_count = get_dismiss_count(advice_type)
       return dismiss_count < 3  # Stop after 3 dismissals
   ```

3. **Cooldown Periods**: Never show same advice type within 5 minutes
   ```gdscript
   var ADVICE_COOLDOWNS = {
       "build_optimization": 300,  # 5 min
       "combat_strategy": 180,     # 3 min
       "economy_tip": 600,         # 10 min
   }
   ```

**Metrics to Track**:
- Advice dismissal rate (target: < 30%)
- Advice acceptance rate (target: > 40%)
- Player feedback on annoyance (survey)

---

### Accuracy & Trust

**Problem**: Bad advice erodes player trust.

**Solution**:
1. **Conservative Recommendations**: Only suggest changes that improve outcome by 20%+
2. **Validate Calculations**: Unit test DPS calculations against known values
3. **A/B Test Advice**: Measure if advice actually helps
   ```gdscript
   func measure_advice_effectiveness(advice: Advice):
       # Compare outcomes: players who followed vs didn't follow
       var followed_outcomes = get_outcomes_where_followed(advice.template_id)
       var ignored_outcomes = get_outcomes_where_ignored(advice.template_id)

       var improvement = (followed_outcomes.avg_success - ignored_outcomes.avg_success)

       # Disable advice if it doesn't help
       if improvement < 0.05:  # Less than 5% improvement
           disable_advice_template(advice.template_id)
   ```

4. **Expert Review**: Have experienced players review advice content
5. **Update with Balance Changes**: When game balance changes, audit affected advice

**Metrics to Track**:
- Advice accuracy rate (% of time advice improves outcome)
- Player trust score (survey: "Do you trust advisor recommendations?")
- Advice revision frequency (how often we update/disable templates)

---

### Free vs Paid Value

**Problem**: Free tier needs value, but not so much that Premium/Subscription feels unnecessary.

**Solution**:
1. **Free = Reactive, Paid = Proactive**
   - Free: "You died because X" (after the fact)
   - Premium: "You're about to die unless Y" (predictive)

2. **Free = Generic, Paid = Personalized**
   - Free: "Melee weapons benefit from +melee damage"
   - Premium: "Given your Tank playstyle, Chainsaw + Body Armor = 35% more survival"

3. **Free = Simple, Paid = Complex**
   - Free: "Current DPS: 45"
   - Premium: "Current DPS: 45 | Potential: 61 | Gap analysis: missing melee synergy"

4. **Advice Limits**
   - Free: 5 active advice items (enough to get value, but limited)
   - Premium: 20 active advice items (generous for single player)
   - Subscription: Unlimited (completionists get full access)

**A/B Test**: Test if Free tier advice limits drive Premium upgrades

---

### Advisor Tone & Personality

**Problem**: Generic robotic advice feels soulless.

**Solution**:
1. **Consistent Voice**: Advisor is helpful mentor, not condescending teacher
2. **Positive Framing**:
   - ❌ "You're doing it wrong"
   - ✅ "Here's how to improve"
3. **Encouraging**: Celebrate successes, gentle on failures
4. **Contextual Humor**: Light jokes when appropriate (not during death screen)

**Example Advice Variants**:
```
// Generic (avoid)
"Increase DPS by equipping better weapons."

// Good (specific + encouraging)
"Your DPS could jump from 45 to 61 by swapping Pistol for Chainsaw.
That's a 35% boost - huge upgrade!"

// Great (specific + personalized + motivating)
"You're doing great with that Tank build! To push even further,
try swapping Pistol for Chainsaw. With your +120% melee damage,
Chainsaw would deal 53 DPS compared to Pistol's 15.
That's wave 25+ territory right there!"
```

---

### Performance Impact

**Problem**: Advice system runs every frame, could cause lag.

**Solution**:
1. **Throttle Checks**: Check triggers at 1 Hz, not 60 Hz
   ```gdscript
   var check_timer = 0.0
   func _process(delta):
       check_timer += delta
       if check_timer > 1.0:  # Check once per second
           check_continuous_triggers()
           check_timer = 0.0
   ```

2. **Lazy Evaluation**: Only analyze when needed (shop opened, wave ended)
3. **Cache Calculations**: Cache DPS calculations, invalidate when inventory changes
4. **Async Analysis**: Run expensive analyses (death replay) in background thread

**Performance Targets**:
- Trigger checking: < 1ms per frame
- Advice generation: < 5ms (imperceptible to player)
- Total overhead: < 1% CPU usage

---

## Open Questions & Future Enhancements

### Open Questions

1. **How much advice is too much?**
   - Need to A/B test advice frequency
   - Track player surveys: "Is advisor helpful or annoying?"
   - Consider per-player settings (advice frequency slider)

2. **Should we have an Advisor character/mascot?**
   - Pro: More personality, memorable
   - Con: Could feel cheesy, requires art assets
   - Alternative: Abstract "AI assistant" aesthetic

3. **How to handle players who ignore all advice?**
   - Reduce frequency automatically?
   - Ask "Is advisor helpful?" after 10 dismissals?
   - Offer "disable advisor" option?

4. **Should Subscription tier get AI-generated advice?**
   - Use Claude API to generate custom advice based on playstyle?
   - Pro: Extremely personalized, cutting-edge feature
   - Con: API costs, quality control concerns
   - Potential: "Ask Advisor" chat feature for Subscribers

5. **How to prevent advice from spoiling exploration?**
   - Some players want to discover synergies themselves
   - Option: "Discovery Mode" (disable proactive advice, keep reactive only)
   - Track player preference: experimental vs optimal

6. **Should we show advice from other players?**
   - "Player X used this strategy successfully on Wave 20"
   - Community-driven tips
   - Risk: Low-quality or outdated advice

7. **How to handle rapid balance changes?**
   - Advice becomes outdated when we nerf/buff items
   - Need automated system to flag potentially outdated advice
   - Solution: Version advice templates, auto-disable old versions

---

### Future Enhancements

#### 1. Voice-Activated Advisor (Post-MVP)

**Concept**: Player asks questions via voice, advisor responds.

**Implementation**:
```gdscript
# Would require voice recognition API
func _on_voice_input(text: String):
    var response = await query_advisor_ai(text)
    speak_response(response)
```

**Use Cases**:
- "How do I beat Wave 20?"
- "What's the best weapon for my build?"
- "Why did I die?"

**Tier**: Subscription exclusive

---

#### 2. Replay Analysis with ML (Post-MVP)

**Concept**: Record gameplay, analyze with ML to find tactical errors.

**Implementation**:
- Record player inputs + game state every frame
- Run ML model to identify suboptimal decisions
- Generate advice: "At 12:34, you could have kited left to avoid damage"

**Tier**: Subscription exclusive

---

#### 3. Community Wisdom Database (Post-MVP)

**Concept**: Aggregate advice from top players automatically.

**Implementation**:
- Analyze top 10% player behaviors
- Extract common patterns (e.g., "95% of successful Wave 30 runs use Body Armor")
- Surface as advice: "Top players recommend Body Armor for Wave 30"

**Tier**: Premium and above

---

#### 4. Adaptive Difficulty Balancing (Post-MVP)

**Concept**: Advisor suggests difficulty adjustments based on performance.

**Implementation**:
```gdscript
func analyze_struggle_pattern():
    if player_dying_repeatedly_on_same_wave():
        suggest_difficulty_reduction()
    elif player_breezing_through():
        suggest_difficulty_increase()
```

**Note**: This may conflict with roguelike philosophy (player should adapt, not game)

---

#### 5. "Advisor Pro" AI Chat (Post-MVP)

**Concept**: Subscribers get Claude-powered chat for custom advice.

**Implementation**:
- Integrate Claude API
- Send player context (stats, inventory, playstyle profile)
- Allow free-form questions
- Cache common questions to reduce API costs

**Example**:
```
Player: "I keep dying on Wave 15, what should I do?"

Advisor Pro: "I see you're playing Glass Cannon with high damage
but low HP. Wave 15 is a swarm wave with many small enemies.
I recommend:
1. Pick up AoE weapon (Flamethrower or Shotgun)
2. Stay mobile - kite enemies in circles
3. Consider buying 1-2 HP items for survivability
4. Save healing items for when enemies spawn

Your current build is optimized for boss waves, not swarms.
For this wave specifically, consider temporarily equipping
Shotgun instead of Sniper Rifle."
```

**Tier**: Subscription exclusive, 10 questions/day limit

---

#### 6. Build Templates & Import (Post-MVP)

**Concept**: Players can save/share/import builds.

**Implementation**:
```gdscript
func export_build() -> String:
    var build = {
        "character": character.type,
        "weapons": inventory.weapons.map(func(w): return w.id),
        "items": inventory.items.map(func(i): return i.id),
        "perks": character.active_perks.map(func(p): return p.id)
    }
    return JSON.stringify(build)

func import_build(build_code: String):
    var build = JSON.parse(build_code)
    AdvisorUI.show_build_comparison(build)
```

**Use Cases**:
- Share builds on social media (builds = trading cards for min-maxers)
- Import meta builds from community
- Advisor can suggest "Import top player build"

**Tier**: Premium and above

---

#### 7. Seasonal Advisor Events (Post-MVP)

**Concept**: Special advisor content during events.

**Examples**:
- Halloween: "The pumpkin boss is weak to fire damage - try Flamethrower!"
- Winter: "Ice weapons slow enemies - perfect for kiting strategies"
- Spring: "Flower event currency can be spent on exclusive items - prioritize these!"

**Implementation**: Event-specific advice templates that activate during events

**Tier**: All tiers (Free gets basic, Subscription gets detailed)

---

#### 8. "Lessons Learned" Journal (Post-MVP)

**Concept**: Advisor maintains a journal of key learnings for player.

**Implementation**:
- After each death, log key lesson ("Remember: heal before swarm waves")
- Player can review past lessons
- Lessons organized by category, searchable

**UI**:
```
┌─────────────────────────────────────┐
│  📖 Lessons Learned                 │
├─────────────────────────────────────┤
│                                     │
│  Combat (12 lessons)                │
│  • Heal before swarm waves          │
│  • Kite in circles for survivability│
│  • Prioritize ranged enemies first  │
│                                     │
│  Build (8 lessons)                  │
│  • Match weapons to stat bonuses    │
│  • AoE weapons excel in swarm waves │
│  • Lifesteal compensates for low HP │
│                                     │
│  Economy (5 lessons)                │
│  • Buy weapons first, items second  │
│  • Save 500 scrap for emergencies   │
│                                     │
└─────────────────────────────────────┘
```

**Tier**: Premium and above

---

## Summary

The **Advisor System** provides contextual, personalized guidance to players based on their playstyle, current game state, and progression level. It transforms raw data from the Personalization System into actionable advice delivered through multiple UI channels.

### Key Features

1. **8 Advice Categories**: Build, Combat, Economy, Death Analysis, Progression, Social, Character-Specific, Events
2. **20+ Context-Aware Triggers**: Advice appears at relevant moments (low HP, suboptimal build, shop opened)
3. **7 Delivery Methods**: Pulsing icon, tooltips, post-wave summary, death screen, notifications, advisor panel, loading tips
4. **Tier Differentiation**: Free (basic tips), Premium (personalized optimization), Subscription (meta builds & AI insights)
5. **Personalization Integration**: Uses playstyle classification to tailor advice
6. **Analytics & A/B Testing**: Track advice effectiveness, disable low-performing templates

### Technical Architecture

- **AdvisorService**: Central service managing advice queue and delivery
- **AdvisorTriggerService**: Monitors game state for 20+ trigger conditions
- **BuildAnalyzer**: Calculates optimal builds and DPS improvements
- **DeathAnalyzer**: Analyzes death timelines and generates improvement suggestions
- **AdviceGenerator**: Creates dynamic advice from templates + game state

### Implementation Timeline

- **Phase 1-2** (5 days): Core infrastructure + personalization integration
- **Phase 3-4** (5 days): All advice categories + advanced UI
- **Phase 5-7** (5 days): Tier features + database + content/polish
- **Total**: ~15 days / ~100 hours

### Success Metrics

- **Engagement**: 60%+ of players view advisor advice weekly
- **Acceptance Rate**: 40%+ of advice followed (not dismissed)
- **Retention**: Players using advisor have 15%+ higher retention
- **Upgrades**: Advisor contributes to 10%+ of Premium/Subscription conversions
- **Trust**: 70%+ of players find advice helpful (survey)

### Business Value

The Advisor System provides clear value across all tiers while creating strong upgrade incentives:
- **Free**: Enough guidance to learn the game, but hits limits
- **Premium**: Professional optimization tools justify $9.99 purchase
- **Subscription**: Cutting-edge meta insights justify $4.99/month

By combining personalization, contextual intelligence, and thoughtful UX, the Advisor System becomes a trusted companion that enhances player experience while driving monetization.
