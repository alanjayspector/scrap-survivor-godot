# Personalization System

**Version:** 1.0
**Date:** January 9, 2025
**Status:** Comprehensive Design Document
**Godot Version:** 4.5.1

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Design Philosophy](#2-design-philosophy)
3. [Data Collection](#3-data-collection)
4. [Playstyle Classification](#4-playstyle-classification)
5. [Character Type Preferences](#5-character-type-preferences)
6. [Weapon & Item Preferences](#6-weapon--item-preferences)
7. [Behavioral Analysis](#7-behavioral-analysis)
8. [Personalization Profile](#8-personalization-profile)
9. [Recommendation Engine](#9-recommendation-engine)
10. [Integration with Other Systems](#10-integration-with-other-systems)
11. [Privacy & Data Handling](#11-privacy--data-handling)
12. [Technical Implementation](#12-technical-implementation)
13. [Analytics & Insights](#13-analytics--insights)
14. [Implementation Strategy](#14-implementation-strategy)
15. [Balancing Considerations](#15-balancing-considerations)
16. [Open Questions & Future Enhancements](#16-open-questions--future-enhancements)
17. [Summary](#17-summary)

---

## 1. System Overview

### 1.1 What is the Personalization System?

The **Personalization System** is an intelligent analytics and recommendation engine that learns each player's unique playstyle, preferences, and behavior to deliver tailored content and suggestions.

**Core Purpose:** Make every player feel like the game understands them and adapts to their preferences.

### 1.2 Key Functions

**Data Collection:**
- Track combat behavior (aggressive vs cautious)
- Monitor character type usage
- Record weapon and item preferences
- Analyze death patterns and learning curves

**Playstyle Classification:**
- Classify players into archetypes (Tank, Glass Cannon, Ranged DPS, Melee DPS, Balanced)
- Adjust classification as player evolves
- Handle multi-playstyle users

**Personalized Recommendations:**
- Generate Atomic Vending Machine items tailored to playstyle
- Power Advisor System suggestions
- Customize event rewards
- Suggest character builds

### 1.3 Systems Powered by Personalization

**Direct Integrations:**
- **Atomic Vending Machine** - Generates personalized Epic/Legendary items
- **Advisor System** - Provides tailored build suggestions and tips
- **Special Events** - Adjusts event difficulty and rewards
- **Achievement System** - Suggests next achievements to pursue
- **Shop System** - Highlights items matching playstyle

**Indirect Influence:**
- Tutorial pacing (adapt to learning speed)
- UI customization (show relevant info first)
- Difficulty scaling (challenge without frustration)

### 1.4 User Experience

**Player Perspective:**
- "The Vending Machine always has weapons I like!"
- "The Advisor suggested this build and it's perfect for me"
- "The game feels like it knows how I play"

**Design Goal:** Personalization should feel **magical** (it just works) not creepy (tracking)

---

## 2. Design Philosophy

### 2.1 Design Principles

**1. Passive Collection**
- No surveys or manual input required
- System learns from natural gameplay
- Players don't need to think about it

**2. Transparent and Beneficial**
- Personalization improves experience (not manipulates)
- User can see their profile and understand it
- Can reset/adjust preferences if desired

**3. Adaptive and Evolving**
- Profile updates as player evolves
- Handles multiple playstyles per user
- Doesn't pigeonhole players into one archetype

**4. Privacy-Respecting**
- Only track gameplay data (no personal info)
- Data stays on user's account
- Can opt-out (personalization disabled, random recommendations)

### 2.2 Ethical Considerations

**What We Track:**
- ✅ Combat statistics (damage dealt, damage taken, kills, deaths)
- ✅ Character usage (which types played most)
- ✅ Weapon preferences (which weapons equipped/used most)
- ✅ Item preferences (which items purchased/kept)
- ✅ Playtime patterns (session length, frequency)

**What We DON'T Track:**
- ❌ Personal information (name, email, location)
- ❌ Device identifiers beyond game account
- ❌ Behavior outside the game
- ❌ Social connections or friends list
- ❌ Purchase behavior for targeting (no dark patterns)

**Recommendation:** Include privacy notice in settings explaining data usage

---

## 3. Data Collection

### 3.1 Combat Statistics

**Tracked Metrics:**

```gdscript
class CombatSession:
    var session_id: String
    var character_id: String
    var wave_start: int
    var wave_end: int
    var duration_seconds: int

    # Combat metrics
    var total_damage_dealt: int
    var total_damage_taken: int
    var total_kills: int
    var deaths: int

    # Behavior metrics
    var avg_distance_to_enemies: float  # Playstyle indicator
    var movement_speed_avg: float
    var time_spent_moving_vs_stationary: float
    var shots_fired: int
    var shots_hit: int
    var accuracy: float

    # Resource management
    var scrap_earned: int
    var items_purchased: int
    var shop_visits: int

    # Survival metrics
    var lowest_hp_reached: int
    var healing_items_used: int
    var defensive_items_used: int
```

**Collection Point:**

```gdscript
# services/PersonalizationService.gd
func record_combat_session(session: CombatSession):
    # Store session data
    await SupabaseService.insert("combat_sessions", session.to_dict())

    # Update running statistics
    update_personalization_profile(session)

# Called when wave completes or character dies
func _on_combat_session_end():
    var session = build_combat_session()
    await PersonalizationService.record_combat_session(session)
```

### 3.2 Character Usage Tracking

**Metrics:**

```gdscript
class CharacterUsageStats:
    var character_id: String
    var character_type: String  # Scavenger, Brute, Engineer

    # Usage frequency
    var total_sessions: int
    var total_playtime_seconds: int
    var last_played_at: String

    # Performance
    var highest_wave_reached: int
    var total_waves_completed: int
    var survival_rate: float  # % of runs where reached wave 10+

    # Preference indicator
    var usage_rank: int  # 1 = most played, 2 = second most, etc.
```

**Analysis:**

```gdscript
func get_favorite_character_type() -> String:
    var usage_stats = get_all_character_usage_stats()

    # Sort by total playtime
    usage_stats.sort_custom(func(a, b): return a.total_playtime_seconds > b.total_playtime_seconds)

    if usage_stats.is_empty():
        return "balanced"  # Default for new users

    return usage_stats[0].character_type
```

### 3.3 Weapon & Item Tracking

**Metrics:**

```gdscript
class EquipmentUsageStats:
    var item_id: String
    var item_type: String  # weapon, armor, consumable
    var item_category: String  # ranged, melee, heavy, etc.

    # Usage
    var times_equipped: int
    var total_time_equipped_seconds: int
    var waves_used: int

    # Performance (weapons only)
    var total_damage_dealt: int
    var total_kills: int

    # Preference signals
    var times_purchased_from_shop: int
    var times_kept_vs_sold: int
```

**Preference Calculation:**

```gdscript
func get_preferred_weapon_type() -> String:
    var weapon_stats = get_weapon_usage_stats()

    # Weight by usage time and purchase frequency
    for stat in weapon_stats:
        stat.preference_score = (stat.total_time_equipped_seconds * 0.5) + (stat.times_purchased_from_shop * 1000)

    weapon_stats.sort_custom(func(a, b): return a.preference_score > b.preference_score)

    if weapon_stats.is_empty():
        return "balanced"

    return weapon_stats[0].item_category  # e.g., "ranged", "melee", "heavy"
```

### 3.4 Behavioral Signals

**Advanced Metrics:**

```gdscript
class BehavioralSignals:
    # Aggression vs Caution
    var avg_distance_to_enemies: float  # Far = cautious/ranged, Close = aggressive/melee
    var damage_dealt_vs_taken_ratio: float  # High = glass cannon, Low = tank

    # Movement patterns
    var movement_intensity: float  # 0-1, high = dodging constantly, low = stationary
    var time_spent_retreating_vs_advancing: float

    # Decision-making
    var shop_visit_frequency: float  # Visits per wave
    var avg_time_in_shop: float
    var impulsive_purchases: int  # Purchases within 5 seconds of entering shop

    # Risk-taking
    var times_engaged_boss_early: int  # Attacked boss before clearing mobs
    var times_used_last_healing_item_early: int  # Used last heal above 50% HP
```

**Interpretation:**

```gdscript
func calculate_aggression_score() -> float:
    var signals = get_behavioral_signals()

    # Close distance + high damage dealt = aggressive
    var distance_score = 1.0 - (signals.avg_distance_to_enemies / 100.0)  # Normalize to 0-1
    var combat_score = clamp(signals.damage_dealt_vs_taken_ratio / 2.0, 0, 1)

    return (distance_score + combat_score) / 2.0

func calculate_caution_score() -> float:
    return 1.0 - calculate_aggression_score()
```

---

## 4. Playstyle Classification

### 4.1 Playstyle Archetypes

**Five Primary Archetypes:**

```gdscript
enum Playstyle {
    TANK,           # High HP/armor, low damage, close range
    GLASS_CANNON,   # Low HP, very high damage, any range
    RANGED_DPS,     # Medium HP, medium-high damage, far range
    MELEE_DPS,      # Medium HP, high damage, close range
    BALANCED        # Medium everything, adaptable
}
```

**Archetype Characteristics:**

| Archetype | HP Priority | Damage Priority | Preferred Range | Playstyle |
|-----------|-------------|-----------------|-----------------|-----------|
| **Tank** | Very High | Low | Close (melee) | Absorb damage, survive long |
| **Glass Cannon** | Low | Very High | Any | Max damage, avoid hits |
| **Ranged DPS** | Medium | High | Far (ranged) | Kite enemies, safe distance |
| **Melee DPS** | Medium-High | High | Close (melee) | Aggressive, in-your-face combat |
| **Balanced** | Medium | Medium | Medium | Adaptable, no extremes |

### 4.2 Classification Algorithm

**Multi-Factor Analysis:**

```gdscript
# services/PlaystyleClassifier.gd
class_name PlaystyleClassifier
extends Node

func classify_playstyle(profile: PersonalizationProfile) -> Playstyle:
    # Gather signals
    var signals = profile.behavioral_signals
    var stats = profile.combat_stats

    # Calculate archetype scores (0-100)
    var scores = {
        Playstyle.TANK: calculate_tank_score(signals, stats),
        Playstyle.GLASS_CANNON: calculate_glass_cannon_score(signals, stats),
        Playstyle.RANGED_DPS: calculate_ranged_dps_score(signals, stats),
        Playstyle.MELEE_DPS: calculate_melee_dps_score(signals, stats),
        Playstyle.BALANCED: calculate_balanced_score(signals, stats)
    }

    # Return highest score
    var max_score = 0
    var best_archetype = Playstyle.BALANCED

    for archetype in scores:
        if scores[archetype] > max_score:
            max_score = scores[archetype]
            best_archetype = archetype

    return best_archetype

func calculate_tank_score(signals: BehavioralSignals, stats: CombatStats) -> int:
    var score = 0

    # High HP/armor priority
    if stats.avg_hp_stat > 150:
        score += 30
    if stats.avg_armor_stat > 50:
        score += 20

    # Low damage output
    if stats.avg_damage_stat < 30:
        score += 10

    # Close range combat
    if signals.avg_distance_to_enemies < 5:
        score += 20

    # Survives long (low death rate)
    if stats.death_rate < 0.1:  # Less than 1 death per 10 waves
        score += 20

    return score

func calculate_glass_cannon_score(signals: BehavioralSignals, stats: CombatStats) -> int:
    var score = 0

    # Very high damage
    if stats.avg_damage_stat > 80:
        score += 40

    # Low HP
    if stats.avg_hp_stat < 80:
        score += 20

    # High damage:HP ratio
    if stats.avg_damage_stat / stats.avg_hp_stat > 1.0:
        score += 20

    # High accuracy (needs precision to survive)
    if signals.accuracy > 0.7:
        score += 20

    return score

func calculate_ranged_dps_score(signals: BehavioralSignals, stats: CombatStats) -> int:
    var score = 0

    # Far from enemies
    if signals.avg_distance_to_enemies > 10:
        score += 40

    # High ranged weapon usage
    if profile.preferred_weapon_category == "ranged":
        score += 30

    # Medium-high damage
    if stats.avg_damage_stat > 50 and stats.avg_damage_stat < 80:
        score += 20

    # Kiting behavior (retreats often)
    if signals.time_spent_retreating_vs_advancing > 1.5:
        score += 10

    return score

func calculate_melee_dps_score(signals: BehavioralSignals, stats: CombatStats) -> int:
    var score = 0

    # Close to enemies
    if signals.avg_distance_to_enemies < 5:
        score += 30

    # High melee weapon usage
    if profile.preferred_weapon_category == "melee":
        score += 30

    # High damage
    if stats.avg_damage_stat > 60:
        score += 20

    # Aggressive (high damage dealt)
    if signals.damage_dealt_vs_taken_ratio > 1.2:
        score += 20

    return score

func calculate_balanced_score(signals: BehavioralSignals, stats: CombatStats) -> int:
    var score = 30  # Base score (default archetype)

    # No extremes (all stats medium)
    var stat_variance = calculate_stat_variance(stats)
    if stat_variance < 0.3:  # Low variance = balanced
        score += 40

    # Uses variety of weapons
    if profile.weapon_variety_score > 0.5:
        score += 30

    return score
```

### 4.3 Classification Confidence

**Confidence Level:**

```gdscript
func get_classification_confidence(scores: Dictionary) -> float:
    # High confidence: One score much higher than others
    # Low confidence: Multiple scores close together

    var sorted_scores = scores.values()
    sorted_scores.sort()
    sorted_scores.reverse()  # Descending

    var top_score = sorted_scores[0]
    var second_score = sorted_scores[1]

    var confidence = (top_score - second_score) / 100.0
    return clamp(confidence, 0.0, 1.0)
```

**Handling Low Confidence:**
- If confidence < 0.3, classify as "Balanced" (user is experimenting)
- If confidence < 0.5, show secondary archetype ("Primary: Ranged DPS, Secondary: Glass Cannon")

### 4.4 Adaptive Classification

**Problem:** Player changes playstyle over time

**Solution:** Weighted recency (recent data weighs more)

```gdscript
func update_classification_with_recency_bias():
    # Get sessions from last 30 days
    var recent_sessions = get_combat_sessions(days: 30)
    var old_sessions = get_combat_sessions(days: 90, exclude_recent: 30)

    # Weight recent data more heavily
    var recent_weight = 0.7
    var old_weight = 0.3

    var recent_archetype = classify_from_sessions(recent_sessions)
    var old_archetype = classify_from_sessions(old_sessions)

    # Blend scores
    var blended_score = (recent_archetype.score * recent_weight) + (old_archetype.score * old_weight)

    return determine_archetype_from_score(blended_score)
```

---

## 5. Character Type Preferences

### 5.1 Character Usage Analysis

**Track which character types user plays most:**

```gdscript
class CharacterTypePreference:
    var character_type: String  # Scavenger, Brute, Engineer
    var total_playtime_hours: float
    var total_sessions: int
    var preference_rank: int  # 1 = favorite, 2 = second, etc.
    var win_rate: float  # % of sessions reaching wave 10+
```

**Calculate Favorite:**

```gdscript
func get_favorite_character_type() -> String:
    var preferences = get_character_type_preferences()

    # Sort by playtime (primary) and win rate (secondary)
    preferences.sort_custom(func(a, b):
        if abs(a.total_playtime_hours - b.total_playtime_hours) < 1.0:
            # Similar playtime, use win rate as tiebreaker
            return a.win_rate > b.win_rate
        return a.total_playtime_hours > b.total_playtime_hours
    )

    if preferences.is_empty():
        return "Scavenger"  # Default

    return preferences[0].character_type
```

### 5.2 Character Build Preferences

**Track stat allocation patterns:**

```gdscript
class BuildPreference:
    var stat_priorities: Dictionary  # {"hp": 0.3, "damage": 0.4, "speed": 0.2, "armor": 0.1}
    var avg_hp_investment_percent: float
    var avg_damage_investment_percent: float
    var avg_speed_investment_percent: float

func analyze_build_preferences(characters: Array[Character]) -> BuildPreference:
    var preference = BuildPreference.new()
    var total_stat_points = 0
    var stat_totals = {"hp": 0, "damage": 0, "speed": 0, "armor": 0, "luck": 0}

    for character in characters:
        total_stat_points += character.total_stat_points_allocated
        stat_totals.hp += character.stats.max_hp
        stat_totals.damage += character.stats.damage
        stat_totals.speed += character.stats.speed
        # ... etc

    # Calculate percentages
    for stat in stat_totals:
        preference.stat_priorities[stat] = stat_totals[stat] / float(total_stat_points)

    return preference
```

---

## 6. Weapon & Item Preferences

### 6.1 Weapon Category Tracking

**Categories:**
- **Ranged:** Pistols, rifles, snipers
- **Melee:** Swords, axes, hammers
- **Heavy:** Rocket launchers, grenade launchers
- **Energy:** Laser guns, plasma weapons
- **Explosive:** Grenades, mines

**Usage Analysis:**

```gdscript
func get_preferred_weapon_category() -> String:
    var weapon_usage = get_weapon_usage_by_category()

    # Weight by: time equipped (50%) + kills (30%) + purchases (20%)
    for category in weapon_usage:
        var usage = weapon_usage[category]
        usage.preference_score = (
            (usage.time_equipped_seconds / 3600.0) * 0.5 +
            (usage.total_kills / 1000.0) * 0.3 +
            (usage.times_purchased * 10) * 0.2
        )

    # Sort by preference score
    var sorted = weapon_usage.values()
    sorted.sort_custom(func(a, b): return a.preference_score > b.preference_score)

    return sorted[0].category
```

### 6.2 Item Type Preferences

**Track which item types user values:**

```gdscript
class ItemTypePreference:
    var item_type: String  # "armor", "health_boost", "damage_boost", "speed_boost"
    var times_purchased: int
    var times_equipped: int
    var times_sold: int
    var net_preference_score: float  # (purchased + equipped - sold)

func get_top_item_preferences(count: int = 3) -> Array[String]:
    var preferences = get_item_type_preferences()

    # Calculate net preference
    for pref in preferences:
        pref.net_preference_score = (pref.times_purchased * 2) + pref.times_equipped - (pref.times_sold * 0.5)

    # Sort descending
    preferences.sort_custom(func(a, b): return a.net_preference_score > b.net_preference_score)

    # Return top N
    return preferences.slice(0, count).map(func(p): return p.item_type)
```

### 6.3 Rarity Tolerance

**Does user prefer quality over quantity?**

```gdscript
func calculate_rarity_tolerance() -> String:
    var purchases = get_all_shop_purchases()

    # Count purchases by rarity
    var rarity_counts = {
        "common": 0,
        "uncommon": 0,
        "rare": 0,
        "epic": 0,
        "legendary": 0
    }

    for purchase in purchases:
        rarity_counts[purchase.item_rarity] += 1

    var total = purchases.size()

    # Classify tolerance
    if rarity_counts.legendary / float(total) > 0.3:
        return "legendary_focused"  # Saves scrap for legendaries
    elif rarity_counts.epic / float(total) > 0.4:
        return "quality_focused"  # Buys epic+
    elif rarity_counts.rare / float(total) > 0.4:
        return "balanced"  # Mix of rare/epic
    else:
        return "quantity_focused"  # Buys lots of common/uncommon
```

---

## 7. Behavioral Analysis

### 7.1 Session Patterns

**When and how user plays:**

```gdscript
class SessionPattern:
    var avg_session_length_minutes: float
    var sessions_per_week: float
    var preferred_play_times: Array[int]  # Hours of day (0-23)
    var weekend_vs_weekday_ratio: float

func analyze_session_patterns() -> SessionPattern:
    var sessions = get_all_sessions(days: 30)
    var pattern = SessionPattern.new()

    # Average session length
    var total_duration = 0
    for session in sessions:
        total_duration += session.duration_seconds
    pattern.avg_session_length_minutes = (total_duration / sessions.size()) / 60.0

    # Sessions per week
    pattern.sessions_per_week = sessions.size() / 4.0  # 30 days = ~4 weeks

    # Preferred play times
    var hour_counts = {}
    for session in sessions:
        var hour = Time.get_datetime_dict_from_unix_time(session.started_at).hour
        hour_counts[hour] = hour_counts.get(hour, 0) + 1

    # Top 3 hours
    var sorted_hours = hour_counts.keys()
    sorted_hours.sort_custom(func(a, b): return hour_counts[a] > hour_counts[b])
    pattern.preferred_play_times = sorted_hours.slice(0, 3)

    return pattern
```

**Usage:**
- Short sessions (< 15 min) → Focus on quick events, vending machine
- Long sessions (> 60 min) → Suggest long-form content, events
- Weekend player → Send notifications on Fridays

### 7.2 Skill Progression

**Track learning curve:**

```gdscript
class SkillProgression:
    var waves_completed_first_week: int
    var waves_completed_recent_week: int
    var improvement_rate: float
    var skill_level: String  # "beginner", "intermediate", "advanced", "expert"

func calculate_skill_level() -> String:
    var progression = get_skill_progression()

    # Improvement rate: (recent - first) / first
    progression.improvement_rate = (progression.waves_completed_recent_week - progression.waves_completed_first_week) / float(progression.waves_completed_first_week)

    # Skill level based on current performance
    if progression.waves_completed_recent_week >= 40:
        return "expert"
    elif progression.waves_completed_recent_week >= 25:
        return "advanced"
    elif progression.waves_completed_recent_week >= 15:
        return "intermediate"
    else:
        return "beginner"
```

**Usage:**
- Beginner → Simple advisor tips, basic builds
- Advanced → Complex builds, optimization tips
- Expert → Meta strategies, challenge runs

### 7.3 Economic Behavior

**How user spends scrap:**

```gdscript
class EconomicBehavior:
    var avg_scrap_balance: int
    var spending_pattern: String  # "hoarder", "balanced", "spender"
    var shop_visit_frequency: float  # Visits per wave
    var impulse_purchase_rate: float  # % purchases within 5 sec of shop entry

func classify_spending_pattern() -> String:
    var behavior = get_economic_behavior()

    # High balance + low spending = hoarder
    if behavior.avg_scrap_balance > 50000 and behavior.shop_visit_frequency < 0.3:
        return "hoarder"

    # Low balance + high spending = spender
    if behavior.avg_scrap_balance < 10000 and behavior.shop_visit_frequency > 0.8:
        return "spender"

    return "balanced"
```

**Usage:**
- Hoarder → Suggest high-value items, show "worth the scrap" messaging
- Spender → Suggest budget builds, warn about expensive purchases

---

## 8. Personalization Profile

### 8.1 Profile Structure

**Complete personalization profile for each user:**

```gdscript
class PersonalizationProfile:
    var user_id: String
    var updated_at: String

    # Playstyle classification
    var primary_playstyle: Playstyle
    var secondary_playstyle: Playstyle  # If close scores
    var classification_confidence: float

    # Character preferences
    var favorite_character_type: String
    var character_type_preferences: Array[CharacterTypePreference]

    # Weapon & item preferences
    var preferred_weapon_category: String
    var weapon_category_usage: Dictionary
    var top_item_types: Array[String]
    var rarity_tolerance: String

    # Behavioral signals
    var aggression_score: float
    var caution_score: float
    var skill_level: String
    var spending_pattern: String

    # Session patterns
    var avg_session_length_minutes: float
    var sessions_per_week: float
    var preferred_play_times: Array[int]

    # Engagement metrics
    var total_playtime_hours: float
    var total_waves_completed: int
    var lifetime_value: float  # For subscription/IAP users

func create_profile_from_data() -> PersonalizationProfile:
    var profile = PersonalizationProfile.new()
    profile.user_id = UserService.get_current_user_id()

    # Run classification
    profile.primary_playstyle = PlaystyleClassifier.classify_playstyle(profile)

    # Gather preferences
    profile.favorite_character_type = get_favorite_character_type()
    profile.preferred_weapon_category = get_preferred_weapon_category()
    profile.top_item_types = get_top_item_preferences(3)

    # Calculate behavioral scores
    profile.aggression_score = calculate_aggression_score()
    profile.caution_score = calculate_caution_score()
    profile.skill_level = calculate_skill_level()

    # Session analysis
    var session_pattern = analyze_session_patterns()
    profile.avg_session_length_minutes = session_pattern.avg_session_length_minutes
    profile.sessions_per_week = session_pattern.sessions_per_week

    profile.updated_at = Time.get_datetime_string_from_system()

    return profile
```

### 8.2 Profile Display (User-Facing)

**Show profile to user in settings:**

```gdscript
# scenes/PersonalizationProfileView.gd
extends Control

func display_profile(profile: PersonalizationProfile):
    # Playstyle
    playstyle_label.text = "Your Playstyle: %s" % playstyle_to_string(profile.primary_playstyle)
    playstyle_description.text = get_playstyle_description(profile.primary_playstyle)

    # Preferences
    favorite_character_label.text = "Favorite Character: %s" % profile.favorite_character_type
    preferred_weapon_label.text = "Preferred Weapons: %s" % profile.preferred_weapon_category

    # Stats
    skill_level_label.text = "Skill Level: %s" % profile.skill_level.capitalize()
    playtime_label.text = "Total Playtime: %d hours" % int(profile.total_playtime_hours)

    # Show insights
    show_personalization_insights(profile)

func show_personalization_insights(profile: PersonalizationProfile):
    # Generate interesting insights
    var insights = []

    if profile.aggression_score > 0.7:
        insights.append("You play aggressively, favoring offense over defense")

    if profile.rarity_tolerance == "legendary_focused":
        insights.append("You prefer quality over quantity, saving for legendary items")

    if profile.skill_level == "expert":
        insights.append("You're an expert player, consistently reaching wave 40+")

    for insight in insights:
        add_insight_card(insight)
```

### 8.3 Profile Reset

**Allow user to reset profile (start fresh):**

```gdscript
func reset_personalization_profile():
    var confirmed = await show_confirmation_dialog(
        "Reset Personalization Profile?",
        "This will clear your playstyle classification and preferences. The system will learn your preferences again from future gameplay."
    )

    if not confirmed:
        return

    # Clear profile data
    var user_id = UserService.get_current_user_id()
    await SupabaseService.delete("personalization_profiles", user_id)

    # Create fresh profile
    var new_profile = PersonalizationProfile.new()
    new_profile.user_id = user_id
    new_profile.primary_playstyle = Playstyle.BALANCED  # Default
    await SupabaseService.insert("personalization_profiles", new_profile.to_dict())

    show_notification("Personalization profile reset")
```

---

## 9. Recommendation Engine

### 9.1 Item Recommendation Algorithm

**Generate personalized item recommendations:**

```gdscript
# services/RecommendationEngine.gd
class_name RecommendationEngine
extends Node

func recommend_items(profile: PersonalizationProfile, count: int = 3, rarity: String = "epic") -> Array[Item]:
    var recommendations: Array[Item] = []

    # Generate item pool based on preferences
    var weapon = recommend_weapon(profile, rarity)
    recommendations.append(weapon)

    var armor = recommend_armor(profile, rarity)
    recommendations.append(armor)

    var utility = recommend_utility_item(profile, rarity)
    recommendations.append(utility)

    return recommendations

func recommend_weapon(profile: PersonalizationProfile, rarity: String) -> Weapon:
    # Match weapon to playstyle and preferred category

    var weapon_category = profile.preferred_weapon_category

    # Override based on playstyle if no strong preference
    if profile.classification_confidence < 0.5:
        match profile.primary_playstyle:
            Playstyle.TANK:
                weapon_category = "heavy"
            Playstyle.GLASS_CANNON:
                weapon_category = "ranged" if randf() < 0.6 else "energy"
            Playstyle.RANGED_DPS:
                weapon_category = "ranged"
            Playstyle.MELEE_DPS:
                weapon_category = "melee"
            Playstyle.BALANCED:
                weapon_category = ["ranged", "melee", "energy"].pick_random()

    # Generate weapon from category
    return WeaponGenerator.generate(weapon_category, rarity)

func recommend_armor(profile: PersonalizationProfile, rarity: String) -> Item:
    # Match armor to playstyle

    match profile.primary_playstyle:
        Playstyle.TANK:
            # Heavy armor (+HP, +armor)
            return ArmorGenerator.generate("heavy", rarity)
        Playstyle.GLASS_CANNON:
            # Light armor (+speed, +crit)
            return ArmorGenerator.generate("light", rarity)
        Playstyle.RANGED_DPS:
            # Medium armor (balanced)
            return ArmorGenerator.generate("medium", rarity)
        Playstyle.MELEE_DPS:
            # Medium-heavy armor (+HP, +speed)
            return ArmorGenerator.generate("medium_heavy", rarity)
        Playstyle.BALANCED:
            # Any armor
            return ArmorGenerator.generate_random(rarity)

func recommend_utility_item(profile: PersonalizationProfile, rarity: String) -> Item:
    # Recommend based on weak stats (shore up weaknesses)

    var build_pref = profile.build_preferences

    # Find lowest stat priority
    var sorted_stats = build_pref.stat_priorities.keys()
    sorted_stats.sort_custom(func(a, b): return build_pref.stat_priorities[a] < build_pref.stat_priorities[b])

    var weakest_stat = sorted_stats[0]

    # Generate item that boosts weakest stat
    match weakest_stat:
        "hp":
            return ConsumableGenerator.generate("health_boost", rarity)
        "damage":
            return ConsumableGenerator.generate("damage_boost", rarity)
        "speed":
            return ConsumableGenerator.generate("speed_boost", rarity)
        _:
            return ConsumableGenerator.generate_random(rarity)
```

### 9.2 Build Recommendations

**Suggest complete character builds:**

```gdscript
func recommend_build(profile: PersonalizationProfile) -> CharacterBuild:
    var build = CharacterBuild.new()

    # Recommended stat allocation
    match profile.primary_playstyle:
        Playstyle.TANK:
            build.stat_allocation = {"hp": 40, "armor": 30, "damage": 20, "speed": 10}
        Playstyle.GLASS_CANNON:
            build.stat_allocation = {"damage": 50, "crit_chance": 30, "hp": 10, "speed": 10}
        Playstyle.RANGED_DPS:
            build.stat_allocation = {"damage": 35, "speed": 25, "hp": 25, "armor": 15}
        Playstyle.MELEE_DPS:
            build.stat_allocation = {"damage": 40, "hp": 30, "speed": 20, "armor": 10}
        Playstyle.BALANCED:
            build.stat_allocation = {"hp": 25, "damage": 25, "speed": 25, "armor": 25}

    # Recommended weapons (3 slots)
    build.weapons = [
        recommend_weapon(profile, "epic"),
        recommend_weapon(profile, "rare"),
        recommend_weapon(profile, "uncommon")
    ]

    # Recommended items
    build.items = recommend_items(profile, count: 8, rarity: "rare")

    # Recommended perks
    build.perks = recommend_perks(profile)

    return build
```

### 9.3 Next Steps Recommendations

**What should user do next?**

```gdscript
func recommend_next_steps(profile: PersonalizationProfile) -> Array[String]:
    var recommendations: Array[String] = []

    # Based on skill level
    match profile.skill_level:
        "beginner":
            recommendations.append("Try reaching Wave 10 for your first milestone")
            recommendations.append("Experiment with different weapons to find your favorite")
        "intermediate":
            recommendations.append("Challenge yourself to reach Wave 20")
            recommendations.append("Try a new character type: %s" % suggest_new_character_type(profile))
        "advanced":
            recommendations.append("Aim for Wave 30+ for rare loot drops")
            recommendations.append("Optimize your build for %s playstyle" % playstyle_to_string(profile.primary_playstyle))
        "expert":
            recommendations.append("Can you reach Wave 50?")
            recommendations.append("Try a challenge run with only Common items")

    # Based on engagement
    if profile.sessions_per_week < 2:
        recommendations.append("Check back weekly for Vending Machine refreshes")

    # Based on economic behavior
    if profile.spending_pattern == "hoarder" and profile.avg_scrap_balance > 100000:
        recommendations.append("You have %d scrap! Treat yourself to a legendary item" % profile.avg_scrap_balance)

    return recommendations
```

---

## 10. Integration with Other Systems

### 10.1 Atomic Vending Machine

**Primary use case for personalization:**

```gdscript
# services/VendingMachineService.gd
func generate_weekly_items(user_id: String) -> Array[Item]:
    # Get personalization profile
    var profile = PersonalizationService.get_profile(user_id)

    # Use recommendation engine
    var items = RecommendationEngine.recommend_items(profile, count: 3, rarity: "epic")

    # Ensure variety (no duplicate types)
    items = ensure_variety(items)

    return items
```

**See:** [ATOMIC-VENDING-MACHINE.md](ATOMIC-VENDING-MACHINE.md) Section 7 for full integration

### 10.2 Advisor System

**Provide tailored advice:**

```gdscript
# services/AdvisorService.gd
func get_personalized_advice(context: String) -> String:
    var profile = PersonalizationService.get_profile()

    match context:
        "build_suggestion":
            var build = RecommendationEngine.recommend_build(profile)
            return "Based on your %s playstyle, try this build: %s" % [profile.primary_playstyle, build.to_string()]

        "wave_strategy":
            if profile.skill_level == "beginner":
                return "Focus on surviving first. Damage comes later."
            else:
                return "At your skill level, push for high waves by balancing offense and defense"

        "shop_advice":
            if profile.spending_pattern == "hoarder":
                return "You're saving well! Consider investing in a legendary item"
            else:
                return "Budget wisely. Prioritize weapons that match your %s style" % profile.preferred_weapon_category
```

**See:** ADVISOR-SYSTEM.md (to be created) for full details

### 10.3 Event Customization

**Adjust events based on skill level:**

```gdscript
# services/EventsService.gd
func adjust_event_difficulty(event: SpecialEvent, profile: PersonalizationProfile) -> SpecialEvent:
    # Scale difficulty based on skill level

    match profile.skill_level:
        "beginner":
            event.enemy_hp_multiplier *= 0.8  # 20% easier
            event.currency_drop_multiplier *= 1.2  # 20% more currency
        "expert":
            event.enemy_hp_multiplier *= 1.2  # 20% harder
            event.loot_drop_multiplier *= 1.3  # 30% better loot (reward difficulty)

    return event
```

### 10.4 Shop Highlighting

**Show relevant items first:**

```gdscript
# scenes/ShopScene.gd
func display_shop_items(items: Array[Item]):
    var profile = PersonalizationService.get_profile()

    # Sort items by relevance
    items.sort_custom(func(a, b):
        return calculate_item_relevance(a, profile) > calculate_item_relevance(b, profile)
    )

    # Display sorted items
    for item in items:
        var card = create_item_card(item)
        if is_highly_relevant(item, profile):
            card.add_highlight("Recommended for you!")
        item_grid.add_child(card)

func calculate_item_relevance(item: Item, profile: PersonalizationProfile) -> float:
    var relevance = 0.0

    # Match weapon category
    if item.type == "weapon" and item.category == profile.preferred_weapon_category:
        relevance += 1.0

    # Match playstyle
    if matches_playstyle(item, profile.primary_playstyle):
        relevance += 0.5

    # Match top item types
    if item.item_type in profile.top_item_types:
        relevance += 0.3

    return relevance
```

---

## 11. Privacy & Data Handling

### 11.1 Data Collection Notice

**Inform users in privacy policy:**

```
Personalization Data Collection

Scrap Survivor collects gameplay data to personalize your experience:
  - Combat statistics (damage, kills, deaths)
  - Character and weapon usage
  - Shop purchases and item preferences
  - Session duration and frequency

This data is used to:
  - Generate personalized item recommendations (Vending Machine)
  - Provide tailored build suggestions (Advisor System)
  - Adjust difficulty and rewards to match your skill level

Your data:
  - Is stored securely on your game account
  - Is NOT shared with third parties
  - Does NOT include personal information
  - Can be viewed and reset in Settings > Personalization

You can opt-out of personalization at any time. If you opt-out, you'll receive random recommendations instead of personalized ones.
```

### 11.2 Opt-Out System

**Allow users to disable personalization:**

```gdscript
# services/PersonalizationService.gd
var personalization_enabled = true  # Default: enabled

func disable_personalization():
    personalization_enabled = false

    # Store preference
    LocalStorage.set("personalization_enabled", false)

    # Clear cached profile (but preserve data for re-enable)
    cached_profile = null

    show_notification("Personalization disabled. You'll receive random recommendations.")

func enable_personalization():
    personalization_enabled = true
    LocalStorage.set("personalization_enabled", true)
    show_notification("Personalization enabled. Recommendations will be tailored to you.")

func get_profile() -> PersonalizationProfile:
    if not personalization_enabled:
        # Return generic profile
        return PersonalizationProfile.new_generic()

    # Return real profile
    return get_or_create_profile()
```

### 11.3 Data Export

**Allow users to export their data (GDPR compliance):**

```gdscript
func export_personalization_data() -> Dictionary:
    var profile = get_profile()

    var export = {
        "profile_created_at": profile.created_at,
        "playstyle": playstyle_to_string(profile.primary_playstyle),
        "favorite_character": profile.favorite_character_type,
        "preferred_weapon": profile.preferred_weapon_category,
        "skill_level": profile.skill_level,
        "total_playtime_hours": profile.total_playtime_hours,
        "total_waves_completed": profile.total_waves_completed,

        "combat_sessions": get_all_combat_sessions(),
        "weapon_usage": get_weapon_usage_stats(),
        "item_purchases": get_all_shop_purchases()
    }

    return export

func export_as_json_file():
    var export_data = export_personalization_data()
    var json = JSON.stringify(export_data, "\t")

    var file_path = "user://personalization_export_%s.json" % Time.get_datetime_string_from_system()
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    file.store_string(json)
    file.close()

    show_notification("Data exported to: %s" % file_path)
```

### 11.4 Data Deletion

**Allow users to delete their data:**

```gdscript
func delete_all_personalization_data():
    var confirmed = await show_confirmation_dialog(
        "Delete All Personalization Data?",
        "This will permanently delete:\n- Your playstyle profile\n- All combat session history\n- Weapon and item usage stats\n\nThis action cannot be undone."
    )

    if not confirmed:
        return

    var user_id = UserService.get_current_user_id()

    # Delete from database
    await SupabaseService.delete("personalization_profiles", user_id)
    await SupabaseService.delete_where("combat_sessions", "user_id", user_id)
    await SupabaseService.delete_where("weapon_usage_stats", "user_id", user_id)
    await SupabaseService.delete_where("item_purchases", "user_id", user_id)

    # Clear local cache
    cached_profile = null

    show_notification("All personalization data deleted")
```

---

## 12. Technical Implementation

### 12.1 Database Schema

```sql
-- Personalization profiles
CREATE TABLE personalization_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL UNIQUE,

  -- Classification
  primary_playstyle VARCHAR(20) NOT NULL,  -- 'tank', 'glass_cannon', 'ranged_dps', 'melee_dps', 'balanced'
  secondary_playstyle VARCHAR(20),
  classification_confidence FLOAT DEFAULT 0.0,

  -- Preferences
  favorite_character_type VARCHAR(50),
  preferred_weapon_category VARCHAR(50),
  top_item_types JSONB,  -- Array of item types
  rarity_tolerance VARCHAR(20),

  -- Behavioral scores
  aggression_score FLOAT DEFAULT 0.5,
  caution_score FLOAT DEFAULT 0.5,
  skill_level VARCHAR(20) DEFAULT 'beginner',
  spending_pattern VARCHAR(20) DEFAULT 'balanced',

  -- Session patterns
  avg_session_length_minutes FLOAT,
  sessions_per_week FLOAT,
  preferred_play_times INT[],  -- Array of hours (0-23)

  -- Engagement
  total_playtime_hours FLOAT DEFAULT 0.0,
  total_waves_completed INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_personalization_user_id ON personalization_profiles(user_id);

-- Combat sessions (raw data for analysis)
CREATE TABLE combat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  character_id UUID REFERENCES characters(id) NOT NULL,

  wave_start INT NOT NULL,
  wave_end INT NOT NULL,
  duration_seconds INT NOT NULL,

  -- Combat metrics
  total_damage_dealt INT DEFAULT 0,
  total_damage_taken INT DEFAULT 0,
  total_kills INT DEFAULT 0,
  deaths INT DEFAULT 0,

  -- Behavior metrics
  avg_distance_to_enemies FLOAT,
  accuracy FLOAT,
  shots_fired INT,
  shots_hit INT,

  -- Resource metrics
  scrap_earned INT DEFAULT 0,
  items_purchased INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_combat_sessions_user_id ON combat_sessions(user_id);
CREATE INDEX idx_combat_sessions_created_at ON combat_sessions(created_at);

-- Weapon usage stats
CREATE TABLE weapon_usage_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  weapon_id VARCHAR(100) NOT NULL,
  weapon_category VARCHAR(50) NOT NULL,

  times_equipped INT DEFAULT 0,
  total_time_equipped_seconds INT DEFAULT 0,
  total_damage_dealt INT DEFAULT 0,
  total_kills INT DEFAULT 0,
  times_purchased INT DEFAULT 0,

  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, weapon_id)
);

CREATE INDEX idx_weapon_usage_user_id ON weapon_usage_stats(user_id);

-- Item usage stats (similar structure)
CREATE TABLE item_usage_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  item_id VARCHAR(100) NOT NULL,
  item_type VARCHAR(50) NOT NULL,

  times_equipped INT DEFAULT 0,
  times_purchased INT DEFAULT 0,
  times_sold INT DEFAULT 0,

  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, item_id)
);

CREATE INDEX idx_item_usage_user_id ON item_usage_stats(user_id);
```

### 12.2 Profile Update Trigger

**Auto-update profile after each session:**

```gdscript
# Called when combat session ends
func _on_combat_session_end():
    var session = build_combat_session()

    # Save session
    await PersonalizationService.record_combat_session(session)

    # Trigger profile update
    await PersonalizationService.update_profile()

# services/PersonalizationService.gd
func update_profile():
    var user_id = UserService.get_current_user_id()

    # Fetch or create profile
    var profile = await get_or_create_profile(user_id)

    # Recalculate classification
    profile.primary_playstyle = PlaystyleClassifier.classify_playstyle(profile)

    # Update preferences
    profile.favorite_character_type = get_favorite_character_type()
    profile.preferred_weapon_category = get_preferred_weapon_category()

    # Recalculate behavioral scores
    profile.aggression_score = calculate_aggression_score()
    profile.skill_level = calculate_skill_level()

    profile.updated_at = Time.get_datetime_string_from_system()

    # Save to database
    await SupabaseService.upsert("personalization_profiles", profile.to_dict())

    # Update cache
    cached_profile = profile
```

### 12.3 Caching Strategy

**Cache profile to avoid repeated database calls:**

```gdscript
var cached_profile: PersonalizationProfile = null
var cache_ttl_seconds = 300  # 5 minutes
var last_cache_time = 0

func get_profile() -> PersonalizationProfile:
    var now = Time.get_unix_time_from_system()

    # Check if cache is fresh
    if cached_profile and (now - last_cache_time) < cache_ttl_seconds:
        return cached_profile

    # Cache miss or stale: fetch from database
    var user_id = UserService.get_current_user_id()
    var response = await SupabaseService.query("personalization_profiles")
        .eq("user_id", user_id)
        .limit(1)
        .execute()

    if response.data.is_empty():
        # Create new profile
        cached_profile = await create_new_profile(user_id)
    else:
        # Parse existing profile
        cached_profile = PersonalizationProfile.from_dict(response.data[0])

    last_cache_time = now
    return cached_profile

func invalidate_cache():
    cached_profile = null
    last_cache_time = 0
```

---

## 13. Analytics & Insights

### 13.1 Admin Analytics Dashboard

**Track personalization system health:**

```sql
-- Playstyle distribution
SELECT
  primary_playstyle,
  COUNT(*) as user_count,
  ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM personalization_profiles) * 100, 2) as percentage
FROM personalization_profiles
GROUP BY primary_playstyle
ORDER BY user_count DESC;

-- Average classification confidence
SELECT AVG(classification_confidence) as avg_confidence
FROM personalization_profiles;

-- Skill level distribution
SELECT
  skill_level,
  COUNT(*) as user_count
FROM personalization_profiles
GROUP BY skill_level
ORDER BY FIELD(skill_level, 'beginner', 'intermediate', 'advanced', 'expert');

-- Engagement metrics by playstyle
SELECT
  primary_playstyle,
  AVG(total_playtime_hours) as avg_playtime,
  AVG(sessions_per_week) as avg_sessions_per_week
FROM personalization_profiles
GROUP BY primary_playstyle;
```

### 13.2 Recommendation Accuracy Tracking

**Measure how often users accept recommendations:**

```gdscript
func track_recommendation_acceptance(item: Item, accepted: bool):
    await SupabaseService.insert("recommendation_tracking", {
        "user_id": UserService.get_current_user_id(),
        "item_id": item.id,
        "item_category": item.category,
        "recommended_for_playstyle": get_profile().primary_playstyle,
        "accepted": accepted,
        "timestamp": Time.get_datetime_string_from_system()
    })

# Analyze acceptance rate
SELECT
  recommended_for_playstyle,
  COUNT(*) as total_recommendations,
  SUM(CASE WHEN accepted THEN 1 ELSE 0 END) as accepted_count,
  ROUND(SUM(CASE WHEN accepted THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) as acceptance_rate
FROM recommendation_tracking
GROUP BY recommended_for_playstyle;
```

**Target Acceptance Rate:** 60-70% (users accept most recommendations)

### 13.3 A/B Testing Framework

**Test different recommendation algorithms:**

```gdscript
# Assign users to test groups
func get_recommendation_algorithm_variant() -> String:
    var user_id = UserService.get_current_user_id()
    var hash = user_id.hash()

    # 50/50 split
    if hash % 2 == 0:
        return "algorithm_v1"  # Original algorithm
    else:
        return "algorithm_v2"  # New algorithm

func recommend_items(profile: PersonalizationProfile, count: int) -> Array[Item]:
    var variant = get_recommendation_algorithm_variant()

    match variant:
        "algorithm_v1":
            return recommend_items_v1(profile, count)
        "algorithm_v2":
            return recommend_items_v2(profile, count)
```

**Compare Results:**

```sql
-- Acceptance rate by algorithm variant
SELECT
  algorithm_variant,
  AVG(CASE WHEN accepted THEN 1.0 ELSE 0.0 END) as acceptance_rate
FROM recommendation_tracking
GROUP BY algorithm_variant;
```

---

## 14. Implementation Strategy

### 14.1 Phase 1: Data Collection (Week 8) - 12 hours

**Goal:** Start tracking gameplay data

**Tasks:**
1. **Database Schema (2h)**
   - Create personalization_profiles table
   - Create combat_sessions table
   - Create weapon_usage_stats and item_usage_stats tables

2. **Session Tracking (6h)**
   - Implement CombatSession data collection
   - Track damage dealt/taken, kills, deaths
   - Track behavioral metrics (distance, accuracy)
   - Save sessions to database after each wave

3. **Weapon & Item Tracking (4h)**
   - Track weapon equip/unequip events
   - Track shop purchases
   - Update usage stats incrementally

**Deliverables:**
- ✅ All gameplay data being tracked
- ✅ Data flowing into database

### 14.2 Phase 2: Classification System (Week 9) - 16 hours

**Goal:** Build playstyle classification

**Tasks:**
1. **PlaystyleClassifier (8h)**
   - Implement 5 archetype scoring functions
   - Calculate confidence levels
   - Test classification with sample data

2. **PersonalizationProfile (4h)**
   - Implement profile structure
   - Create profile generation from raw data
   - Profile caching

3. **Preference Analysis (4h)**
   - Favorite character type calculation
   - Preferred weapon category
   - Top item types
   - Behavioral scores

**Deliverables:**
- ✅ Users classified into playstyle archetypes
- ✅ Profiles generated and cached

### 14.3 Phase 3: Recommendation Engine (Week 10) - 16 hours

**Goal:** Generate personalized recommendations

**Tasks:**
1. **Item Recommendation (8h)**
   - Implement weapon recommendation logic
   - Implement armor recommendation logic
   - Implement utility item recommendation
   - Ensure variety in recommendations

2. **Build Recommendation (4h)**
   - Generate complete character builds
   - Stat allocation suggestions
   - Weapon/item/perk suggestions

3. **Next Steps Recommendation (4h)**
   - Skill-based suggestions
   - Engagement-based suggestions
   - Economic behavior suggestions

**Deliverables:**
- ✅ Recommendation engine functional
- ✅ Generates personalized items and builds

### 14.4 Phase 4: System Integration (Week 11) - 8 hours

**Goal:** Integrate with Vending Machine and Advisor

**Tasks:**
1. **Vending Machine Integration (4h)**
   - Connect RecommendationEngine to VendingMachineService
   - Test personalized item generation

2. **Advisor Integration (4h)**
   - Provide personalized advice based on profile
   - Context-specific suggestions

**Deliverables:**
- ✅ Vending Machine uses personalization
- ✅ Advisor provides tailored advice

### 14.5 Phase 5: UI & Polish (Week 12) - 12 hours

**Goal:** User-facing profile and settings

**Tasks:**
1. **Profile View (6h)**
   - Create PersonalizationProfileView scene
   - Display playstyle, preferences, stats
   - Show personalized insights

2. **Settings Integration (4h)**
   - Opt-out toggle
   - Profile reset button
   - Data export feature

3. **Privacy Implementation (2h)**
   - Add privacy notice
   - Implement data deletion

**Deliverables:**
- ✅ Users can view their profile
- ✅ Opt-out and data controls functional

**Total Implementation Time:** ~64 hours (~8 days of focused work)

---

## 15. Balancing Considerations

### 15.1 Classification Accuracy

**Problem:** Ensure classifications feel accurate to users

**Solution:**
- **Validation:** Manually review 100 random profiles, check if classifications match expected
- **User Feedback:** Add "Is this accurate?" prompt in profile view
- **Confidence Threshold:** If confidence < 50%, classify as "Balanced"

**Target Accuracy:** 70%+ users agree with their classification

### 15.2 Recommendation Relevance

**Problem:** Recommendations must feel useful

**Solution:**
- **Acceptance Tracking:** Measure % of recommendations accepted
- **A/B Testing:** Test different recommendation algorithms
- **Manual Tuning:** Adjust weights based on user feedback

**Target Acceptance Rate:** 60-70%

### 15.3 Pigeonholing Prevention

**Problem:** Don't lock users into one playstyle forever

**Solution:**
- **Recency Weighting:** Recent sessions weight more heavily
- **Multi-Playstyle Support:** Show secondary archetype if close
- **Variety Injection:** Occasionally recommend items outside primary category (10-20% of time)

**Example:**
- User is 70% Tank, 30% Melee DPS
- Vending Machine: 2 tank items, 1 melee DPS item

### 15.4 Cold Start Problem

**Problem:** New users have no data to personalize from

**Solution:**
- **Default to Balanced:** New users classified as "Balanced"
- **Quick Learning:** After 5-10 sessions, have enough data to classify
- **Tutorial Analysis:** Learn from tutorial performance (did they focus on offense or defense?)

---

## 16. Open Questions & Future Enhancements

### 16.1 Open Questions

**Q1: Should personalization affect event difficulty?**
- Option A: Yes, scale events to skill level (expert players get harder events)
- Option B: No, keep events fixed difficulty
- **Recommendation:** Option A (more engaging)

**Q2: Should personalization affect shop prices?**
- Option A: Yes, discount preferred items (e.g., ranged weapons 10% off for Ranged DPS players)
- Option B: No, keep prices fixed
- **Recommendation:** Option B (dynamic pricing feels manipulative)

**Q3: How often should profile update?**
- Option A: After every session (real-time)
- Option B: Daily batch update
- **Recommendation:** Option A (more responsive)

**Q4: Should personalization track social behavior (friend invites, referrals)?**
- Option A: Yes, track social engagement
- Option B: No, only track gameplay
- **Recommendation:** Option B (privacy-friendly)

**Q5: Should users be able to manually set their playstyle?**
- Option A: Yes, manual override option
- Option B: No, fully automatic
- **Recommendation:** Option A (user control increases trust)

### 16.2 Future Enhancements (Post-Launch)

**Enhancement 1: Multi-Playstyle Profiles**
- Support users who play multiple styles
- Generate recommendations for each style
- "Which character are you playing today?"

**Enhancement 2: Sentiment Analysis**
- Track which items make users happy (kept long-term)
- Track which items disappoint (sold immediately)
- Use sentiment to improve recommendations

**Enhancement 3: Social Recommendations**
- "Players like you also enjoy..."
- Collaborative filtering based on similar profiles

**Enhancement 4: Seasonal Playstyle Shifts**
- Detect when user changes playstyle (e.g., Tank → Glass Cannon)
- Trigger "Playstyle Evolved!" notification
- Offer free respec or build reset

**Enhancement 5: Personalized Events**
- Generate custom mini-events for user
- "Tank Challenge: Survive 10 waves with only armor items"
- Rewards tailored to playstyle

**Enhancement 6: Advisor AI**
- Use AI (LLM) to generate natural language advice
- "Based on your aggressive playstyle, I'd suggest..."
- More conversational and adaptive

---

## 17. Summary

### 17.1 What Personalization System Provides

The Personalization System delivers:

1. **Playstyle Understanding**
   - Classifies users into 5 archetypes (Tank, Glass Cannon, Ranged DPS, Melee DPS, Balanced)
   - Tracks preferences (character types, weapons, items)
   - Analyzes behavioral patterns (aggression, caution, skill level)

2. **Tailored Recommendations**
   - Atomic Vending Machine generates personalized items
   - Advisor System provides relevant advice
   - Shop highlights useful items
   - Build suggestions match playstyle

3. **Enhanced Experience**
   - Game feels like it "knows" the player
   - Reduces RNG frustration (relevant drops)
   - Increases engagement (sees preferred content)
   - Improves retention (feels personal)

4. **Privacy-Respecting**
   - Only gameplay data tracked
   - User can view, reset, or opt-out
   - GDPR compliant (data export/deletion)
   - No manipulation or dark patterns

### 17.2 Key Features Recap

- ✅ **Playstyle Classification:** 5 archetypes with confidence scoring
- ✅ **Preference Tracking:** Characters, weapons, items, economic behavior
- ✅ **Behavioral Analysis:** Aggression, skill level, session patterns
- ✅ **Recommendation Engine:** Personalized items, builds, next steps
- ✅ **System Integration:** Powers Vending Machine, Advisor, Events
- ✅ **User Controls:** Profile view, opt-out, data export/deletion
- ✅ **Analytics:** Track classification distribution, recommendation acceptance

### 17.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 8 (12h) | Data collection tracking all gameplay |
| Phase 2 | Week 9 (16h) | Classification system functional |
| Phase 3 | Week 10 (16h) | Recommendation engine generating items |
| Phase 4 | Week 11 (8h) | Integration with Vending Machine & Advisor |
| Phase 5 | Week 12 (12h) | UI, settings, privacy controls |

**Total:** ~64 hours (~8 days of focused work)

### 17.4 Success Metrics

Track these KPIs to measure personalization success:

- **Classification Confidence:** % of users with confidence > 50%
  - Target: >70% of users confidently classified
- **Recommendation Acceptance Rate:** % of recommended items purchased
  - Target: 60-70% acceptance rate
- **User Agreement:** % of users who agree with their classification
  - Target: >70% agreement (via survey)
- **Engagement Impact:** Difference in retention between personalized vs non-personalized
  - Target: +10% retention for personalized users
- **Vending Machine Usage:** % of subscribers using Vending Machine
  - Target: >80% (personalization drives usage)

### 17.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ User accounts and character system
- ✅ Combat system with tracking points
- ✅ Shop system with purchase tracking
- ✅ Database access (Supabase)

**Next Steps:**
1. Review this document with team
2. Validate privacy approach (legal review if needed)
3. Begin Phase 1 implementation (Week 8)
4. Set up analytics dashboard for monitoring
5. Plan A/B tests for recommendation algorithms

**Status:** Ready for Week 8+ implementation (can start immediately after core systems are functional).

---

*End of Personalization System Documentation*
