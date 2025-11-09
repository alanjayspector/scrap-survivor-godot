# Perks System: Hook Architecture & Implementation Guide

**Status:** CRITICAL - Foundation for all future systems
**Audience:** Developers implementing game services
**Version:** 1.0
**Last Updated:** November 9, 2025

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Hook Point Catalog](#2-hook-point-catalog)
3. [Implementation Patterns](#3-implementation-patterns)
4. [Service Integration Checklist](#4-service-integration-checklist)
5. [Hook Naming Conventions](#5-hook-naming-conventions)
6. [Context Structures](#6-context-structures)
7. [Testing Perk Hooks](#7-testing-perk-hooks)
8. [Migration Strategy](#8-migration-strategy)

---

## 1. Architecture Overview

### 1.1 What Are Perk Hooks?

Perk hooks are **signal-based injection points** that allow server-defined perks to modify game behavior without client code changes. Each hook represents a game event where perks can inject custom logic.

**Key Principles:**
- **Server-Authoritative:** All perk logic lives server-side (Supabase Edge Functions)
- **Signal-Driven:** Hooks emit signals that perks subscribe to
- **Context-Based:** Each hook receives a mutable context dictionary
- **FIFO Execution:** Perks execute in queue order (front-priority or back-priority)
- **Type-Safe:** All contexts use strongly-typed dictionaries

### 1.2 Hook Execution Flow

```gdscript
# Example: shop_purchase_pre hook
func purchase_item(item_id: String, character_id: String):
    var context = {
        "item_id": item_id,
        "character_id": character_id,
        "base_cost": get_item_cost(item_id),
        "final_cost": get_item_cost(item_id),  # Perks modify this
        "allow_purchase": true  # Perks can block
    }

    # Fire pre-hook (perks modify context)
    PerkService.fire_hook("shop_purchase_pre", context)

    # Check if purchase was blocked
    if not context.allow_purchase:
        return ERROR_PURCHASE_BLOCKED

    # Use modified cost
    if BankingService.subtract_currency(context.final_cost):
        InventoryService.add_item(item_id)

        # Fire post-hook (perks react to success)
        PerkService.fire_hook("shop_purchase_post", context)
        return OK
    else:
        return ERROR_INSUFFICIENT_FUNDS
```

### 1.3 Three Hook Types

| Type | Timing | Purpose | Example |
|------|--------|---------|---------|
| **Pre-Hook** | Before action | Modify inputs, validate | `shop_purchase_pre` (adjust cost) |
| **Post-Hook** | After action | React to results, grant bonuses | `enemy_death_post` (bonus scrap) |
| **Event-Hook** | During event | Trigger side effects | `wave_complete` (spawn loot) |

---

## 2. Hook Point Catalog

### 2.1 Character System Hooks (CharacterService)

#### `character_create_pre`
**Timing:** Before character creation
**Purpose:** Modify starting stats, grant bonus items
**Context:**
```gdscript
{
    "character_type": String,       # "scavenger", "soldier", etc
    "base_stats": Dictionary,       # { "max_hp": 100, "speed": 200, ... }
    "starting_items": Array,        # ["item_id_1", "item_id_2"]
    "starting_currency": Dictionary, # { "scrap": 0, "premium": 0 }
    "allow_create": bool            # Perks can block creation
}
```
**Example Perk:** "+10 HP to all new characters this week"

---

#### `character_create_post`
**Timing:** After character creation
**Purpose:** React to character creation, grant welcome bonuses
**Context:**
```gdscript
{
    "character_id": String,
    "character_data": Dictionary,  # Full character object
    "player_tier": int             # UserTier enum value
}
```
**Example Perk:** "Grant 500 scrap to new Subscription tier characters"

---

#### `character_level_up_pre`
**Timing:** Before level up
**Purpose:** Modify stat gains, add bonus points
**Context:**
```gdscript
{
    "character_id": String,
    "old_level": int,
    "new_level": int,
    "stat_gains": Dictionary,       # { "max_hp": 5, "damage": 2, ... }
    "allow_level_up": bool
}
```
**Example Perk:** "Double stat gains on level up (Premium tier)"

---

#### `character_level_up_post`
**Timing:** After level up
**Purpose:** Grant milestone rewards
**Context:**
```gdscript
{
    "character_id": String,
    "new_level": int,
    "total_stat_gains": Dictionary
}
```
**Example Perk:** "Grant legendary item every 10 levels"

---

#### `character_death_pre`
**Timing:** Before death processing
**Purpose:** Reduce penalties, grant resurrection
**Context:**
```gdscript
{
    "character_id": String,
    "death_context": Dictionary,    # { "killer_id": String, "damage": float }
    "durability_loss_pct": float,   # Default 0.10 (10%)
    "allow_death": bool,            # Perks can prevent death (revive)
    "resurrection_granted": bool    # Set to true to revive
}
```
**Example Perk:** "Referral reward: 1 free resurrection per run"

---

#### `character_death_post`
**Timing:** After death processing
**Purpose:** Grant XP bonuses, track stats
**Context:**
```gdscript
{
    "character_id": String,
    "final_stats": Dictionary,      # Wave reached, kills, etc
    "death_count": int
}
```
**Example Perk:** "+20% XP gain after first death (encourages retry)"

---

### 2.2 Combat System Hooks (CombatService)

#### `damage_dealt_pre`
**Timing:** Before damage application
**Purpose:** Modify outgoing damage, add effects
**Context:**
```gdscript
{
    "attacker_id": String,
    "target_id": String,
    "weapon_id": String,            # null if unarmed
    "base_damage": float,
    "final_damage": float,          # Perks modify this
    "damage_type": String,          # "physical", "fire", "poison", etc
    "is_crit": bool,
    "crit_multiplier": float        # Default 2.0, perks can modify
}
```
**Example Perk:** "+20% damage with ranged weapons"

---

#### `damage_dealt_post`
**Timing:** After damage applied
**Purpose:** Trigger on-hit effects (life steal, burn, etc)
**Context:**
```gdscript
{
    "attacker_id": String,
    "target_id": String,
    "actual_damage": float,         # Damage after defense
    "target_killed": bool
}
```
**Example Perk:** "10% life steal on all attacks"

---

#### `damage_received_pre`
**Timing:** Before damage received
**Purpose:** Reduce incoming damage, trigger shields
**Context:**
```gdscript
{
    "character_id": String,
    "attacker_id": String,
    "base_damage": float,
    "final_damage": float,          # Perks modify this
    "damage_type": String,
    "is_dodged": bool,              # Perks can set to true
    "shield_absorbed": float        # Amount absorbed by shield
}
```
**Example Perk:** "50% damage reduction from fire damage"

---

#### `damage_received_post`
**Timing:** After damage received
**Purpose:** Trigger counter-attacks, log damage
**Context:**
```gdscript
{
    "character_id": String,
    "actual_damage": float,
    "remaining_hp": float
}
```
**Example Perk:** "Reflect 10% of damage back to attacker"

---

#### `enemy_death_pre`
**Timing:** Before enemy death
**Purpose:** Modify drop rates, prevent death (rare)
**Context:**
```gdscript
{
    "enemy_id": String,
    "enemy_type": String,
    "killer_id": String,            # Character who got killing blow
    "base_scrap_drop": int,
    "final_scrap_drop": int,        # Perks modify this
    "item_drop_chance": float,      # 0.0-1.0, perks can boost
    "allow_death": bool
}
```
**Example Perk:** "2x scrap drops during Halloween event"

---

#### `enemy_death_post`
**Timing:** After enemy death
**Purpose:** Grant kill bonuses, trigger effects
**Context:**
```gdscript
{
    "enemy_id": String,
    "killer_id": String,
    "scrap_granted": int,
    "items_dropped": Array[String]
}
```
**Example Perk:** "+50 bonus scrap per kill (event perk)"

---

#### `wave_start_pre`
**Timing:** Before wave starts
**Purpose:** Modify wave difficulty, enemy count
**Context:**
```gdscript
{
    "wave_number": int,
    "enemy_count": int,             # Perks can modify
    "enemy_types": Array[String],   # Perks can add/remove
    "difficulty_multiplier": float, # Default 1.0
    "allow_wave_start": bool
}
```
**Example Perk:** "-20% enemy count for beginner players"

---

#### `wave_start_post`
**Timing:** After wave starts (enemies spawned)
**Purpose:** Grant wave buffs, trigger events
**Context:**
```gdscript
{
    "wave_number": int,
    "enemies_spawned": int
}
```
**Example Perk:** "Grant temp speed boost at wave start"

---

#### `wave_complete_pre`
**Timing:** Before wave completion
**Purpose:** Modify wave rewards
**Context:**
```gdscript
{
    "wave_number": int,
    "time_taken": float,            # Seconds to clear wave
    "base_scrap_reward": int,
    "final_scrap_reward": int,      # Perks modify this
    "base_xp_reward": int,
    "final_xp_reward": int          # Perks modify this
}
```
**Example Perk:** "+100% XP on wave completion (2x XP event)"

---

#### `wave_complete_post`
**Timing:** After wave completion
**Purpose:** Grant milestone rewards, spawn bonus loot
**Context:**
```gdscript
{
    "wave_number": int,
    "scrap_granted": int,
    "xp_granted": int
}
```
**Example Perk:** "Every 5th wave, spawn legendary item"

---

### 2.3 Economy System Hooks

#### `shop_purchase_pre` (ShopService)
**Timing:** Before item purchase
**Purpose:** Apply discounts, block purchases, grant freebies
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "item_rarity": String,
    "base_cost": int,
    "final_cost": int,              # Perks modify this
    "discount_pct": float,          # 0.0-1.0
    "allow_purchase": bool,
    "grant_free_copy": bool         # Perks can grant 2-for-1
}
```
**Example Perk:** "25% discount on all shop purchases (Premium tier)"

---

#### `shop_purchase_post` (ShopService)
**Timing:** After item purchase
**Purpose:** Grant bonus items, refund chance
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "cost_paid": int,
    "bonus_items": Array[String]    # Perks can add items here
}
```
**Example Perk:** "10% chance to get item for free (refund cost)"

---

#### `shop_reroll_pre` (ShopRerollService)
**Timing:** Before shop reroll
**Purpose:** Reduce reroll cost, grant free rerolls
**Context:**
```gdscript
{
    "character_id": String,
    "reroll_count": int,            # Times rerolled today
    "base_cost": int,
    "final_cost": int,              # Perks modify this (can be 0)
    "allow_reroll": bool
}
```
**Example Perk:** "First reroll each day is free (Subscription tier)"

---

#### `shop_reroll_post` (ShopRerollService)
**Timing:** After shop reroll
**Purpose:** Guarantee quality, track reroll count
**Context:**
```gdscript
{
    "character_id": String,
    "cost_paid": int,
    "new_inventory": Array[String]
}
```
**Example Perk:** "Every 3rd reroll guarantees 1 epic item"

---

#### `recycler_dismantle_pre` (RecyclerService)
**Timing:** Before item dismantling
**Purpose:** Increase yields, prevent dismantling valuable items
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "item_rarity": String,
    "is_radioactive": bool,
    "base_scrap": int,
    "final_scrap": int,             # Perks modify this
    "base_components": int,
    "final_components": int,        # Perks modify this
    "allow_dismantle": bool
}
```
**Example Perk:** "+50% scrap from recycling (event perk)"

---

#### `recycler_dismantle_post` (RecyclerService)
**Timing:** After item dismantling
**Purpose:** Grant bonus resources, trigger crafting unlocks
**Context:**
```gdscript
{
    "character_id": String,
    "scrap_granted": int,
    "components_granted": int,
    "bonus_items": Array[String]    # Perks can add blueprint drops
}
```
**Example Perk:** "5% chance to unlock random blueprint on dismantle"

---

#### `workshop_repair_pre` (WorkshopService)
**Timing:** Before item repair
**Purpose:** Reduce repair costs, speed up repairs
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "current_durability": float,
    "max_durability": float,
    "base_scrap_cost": int,
    "final_scrap_cost": int,        # Perks modify this
    "base_component_cost": int,
    "final_component_cost": int,    # Perks modify this
    "allow_repair": bool
}
```
**Example Perk:** "50% cheaper repairs (Subscription tier)"

---

#### `workshop_repair_post` (WorkshopService)
**Timing:** After item repair
**Purpose:** Grant bonus durability, perfect repair chance
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "durability_restored": float,
    "cost_paid": int
}
```
**Example Perk:** "10% chance repair restores to 110% max durability"

---

#### `workshop_fusion_pre` (WorkshopService)
**Timing:** Before item fusion
**Purpose:** Reduce costs, boost fusion tier gains
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,              # Base item being fused
    "fusion_tier": int,             # Current tier
    "new_fusion_tier": int,         # After fusion (usually +1)
    "tier_bonus": int,              # Perks can grant +2 or +3
    "base_cost": int,
    "final_cost": int,              # Perks modify this
    "allow_fusion": bool
}
```
**Example Perk:** "Fusion always grants +2 tiers instead of +1"

---

#### `workshop_fusion_post` (WorkshopService)
**Timing:** After item fusion
**Purpose:** Grant bonus stats, perfect fusion chance
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "new_fusion_tier": int,
    "stat_gains": Dictionary        # { "damage": 10, "crit": 5 }
}
```
**Example Perk:** "5% chance fusion grants double stat bonus"

---

#### `workshop_craft_pre` (WorkshopService)
**Timing:** Before item crafting
**Purpose:** Reduce costs, improve success rate
**Context:**
```gdscript
{
    "character_id": String,
    "blueprint_id": String,
    "base_success_chance": float,   # 0.0-1.0
    "final_success_chance": float,  # Perks modify this
    "base_cost": int,
    "final_cost": int,              # Perks modify this
    "allow_craft": bool
}
```
**Example Perk:** "+20% crafting success chance (Premium tier)"

---

#### `workshop_craft_post` (WorkshopService)
**Timing:** After crafting attempt
**Purpose:** Grant bonus on success, refund on failure
**Context:**
```gdscript
{
    "character_id": String,
    "blueprint_id": String,
    "success": bool,
    "item_granted": String,         # null if failed
    "cost_paid": int
}
```
**Example Perk:** "Failed crafts refund 50% of materials"

---

### 2.4 Progression System Hooks

#### `goal_complete_pre` (GoalsService)
**Timing:** Before goal completion
**Purpose:** Boost rewards, grant bonus completions
**Context:**
```gdscript
{
    "character_id": String,
    "goal_id": String,
    "goal_type": String,            # "daily", "weekly", "seasonal"
    "base_scrap_reward": int,
    "final_scrap_reward": int,      # Perks modify this
    "base_premium_reward": int,
    "final_premium_reward": int,    # Perks modify this
    "allow_complete": bool
}
```
**Example Perk:** "2x rewards on goal completion (Subscription tier)"

---

#### `goal_complete_post` (GoalsService)
**Timing:** After goal completion
**Purpose:** Grant streak bonuses, unlock achievements
**Context:**
```gdscript
{
    "character_id": String,
    "goal_id": String,
    "rewards_granted": Dictionary,
    "completion_streak": int        # Days in a row
}
```
**Example Perk:** "Every 7-day streak grants legendary item"

---

#### `achievement_unlock_pre` (AchievementsService)
**Timing:** Before achievement unlock
**Purpose:** Boost rewards, trigger special events
**Context:**
```gdscript
{
    "character_id": String,
    "achievement_id": String,
    "achievement_tier": String,     # "bronze", "silver", "gold", "platinum"
    "base_scrap_reward": int,
    "final_scrap_reward": int,      # Perks modify this
    "base_premium_reward": int,
    "final_premium_reward": int     # Perks modify this
}
```
**Example Perk:** "+50% achievement rewards (event perk)"

---

#### `achievement_unlock_post` (AchievementsService)
**Timing:** After achievement unlock
**Purpose:** Grant bonus items, track milestones
**Context:**
```gdscript
{
    "character_id": String,
    "achievement_id": String,
    "total_achievements": int,      # Lifetime total
    "rewards_granted": Dictionary
}
```
**Example Perk:** "Every 10 achievements unlocks exclusive cosmetic"

---

### 2.5 Banking & Currency Hooks

#### `currency_add_pre` (BankingService)
**Timing:** Before currency addition
**Purpose:** Grant bonus currency, apply multipliers
**Context:**
```gdscript
{
    "character_id": String,
    "currency_type": int,           # CurrencyType enum
    "base_amount": int,
    "final_amount": int,            # Perks modify this
    "source": String,               # "combat", "shop_sale", "goal", etc
    "multiplier": float             # Default 1.0
}
```
**Example Perk:** "2x scrap from combat (weekend event)"

---

#### `currency_add_post` (BankingService)
**Timing:** After currency addition
**Purpose:** Track earnings, trigger milestone rewards
**Context:**
```gdscript
{
    "character_id": String,
    "currency_type": int,
    "amount_granted": int,
    "new_balance": int
}
```
**Example Perk:** "Every 10k scrap earned grants 100 premium currency"

---

#### `currency_subtract_pre` (BankingService)
**Timing:** Before currency subtraction
**Purpose:** Apply discounts, prevent spending
**Context:**
```gdscript
{
    "character_id": String,
    "currency_type": int,
    "base_amount": int,
    "final_amount": int,            # Perks modify this (can reduce)
    "purpose": String,              # "shop_purchase", "repair", etc
    "allow_subtract": bool
}
```
**Example Perk:** "All purchases cost 10% less (Premium tier)"

---

#### `currency_subtract_post` (BankingService)
**Timing:** After currency subtraction
**Purpose:** Refund chance, track spending
**Context:**
```gdscript
{
    "character_id": String,
    "currency_type": int,
    "amount_spent": int,
    "new_balance": int
}
```
**Example Perk:** "5% chance to refund purchase after payment"

---

### 2.6 Minions System Hooks

#### `minion_spawn_pre` (MinionsService)
**Timing:** Before minion spawns in combat
**Purpose:** Boost minion stats, grant bonus minions
**Context:**
```gdscript
{
    "character_id": String,
    "minion_id": String,
    "minion_type": String,          # "tank", "dps", "support", etc
    "base_stats": Dictionary,       # { "hp": 100, "damage": 20 }
    "final_stats": Dictionary,      # Perks modify this
    "allow_spawn": bool
}
```
**Example Perk:** "+50% HP for all tank minions"

---

#### `minion_death_post` (MinionsService)
**Timing:** After minion dies in combat
**Purpose:** Grant revive, trigger vengeance effects
**Context:**
```gdscript
{
    "character_id": String,
    "minion_id": String,
    "killer_id": String,
    "resurrect_minion": bool        # Perks can set to true
}
```
**Example Perk:** "Minions resurrect once per wave with 50% HP"

---

### 2.7 Special Events Hooks

#### `event_start_post` (EventsService)
**Timing:** When special event activates
**Purpose:** Grant event bonuses, modify event rules
**Context:**
```gdscript
{
    "event_id": String,
    "event_type": String,           # "halloween", "boss_rush", etc
    "player_tier": int
}
```
**Example Perk:** "Double event rewards for Subscription tier"

---

#### `event_end_post` (EventsService)
**Timing:** When special event ends
**Purpose:** Grant completion rewards
**Context:**
```gdscript
{
    "event_id": String,
    "player_participation": Dictionary  # Stats during event
}
```
**Example Perk:** "Top 10% participants get exclusive cosmetic"

---

### 2.8 Radioactivity System Hooks

#### `radioactivity_irradiate_pre` (WorkshopService)
**Timing:** Before item irradiation
**Purpose:** Modify bonus/debuff ranges, reduce costs
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "base_bonus_range": Vector2,   # (0.20, 0.50) = 20-50% bonus
    "final_bonus_range": Vector2,  # Perks can increase max
    "debuff_severity": float,       # Default 1.0 (100%)
    "base_cost": int,
    "final_cost": int,              # Perks modify this
    "allow_irradiate": bool
}
```
**Example Perk:** "Subscription: Reduce debuff severity by 20%"

---

#### `radioactivity_irradiate_post` (WorkshopService)
**Timing:** After item irradiation
**Purpose:** Reroll debuff, grant perfect irradiation
**Context:**
```gdscript
{
    "character_id": String,
    "item_id": String,
    "bonus_granted": float,         # Actual bonus % rolled
    "debuff_applied": String,       # Which debuff was rolled
    "reroll_debuff": bool           # Perks can force reroll
}
```
**Example Perk:** "Premium: Preview debuff, 1 free reroll per irradiation"

---

## 3. Implementation Patterns

### 3.1 Adding Hooks to a Service

**Step-by-Step Guide:**

1. **Define Hook Signals** (at top of service class):
```gdscript
class_name ShopService
extends Node

# Hook signals
signal shop_purchase_pre(context: Dictionary)
signal shop_purchase_post(context: Dictionary)
```

2. **Create Context Before Action**:
```gdscript
func purchase_item(item_id: String, character_id: String) -> int:
    var context = {
        "character_id": character_id,
        "item_id": item_id,
        "item_rarity": get_item_rarity(item_id),
        "base_cost": get_item_cost(item_id),
        "final_cost": get_item_cost(item_id),
        "discount_pct": 0.0,
        "allow_purchase": true,
        "grant_free_copy": false
    }
```

3. **Fire Pre-Hook** (let perks modify context):
```gdscript
    # Fire pre-hook
    shop_purchase_pre.emit(context)

    # Perks may have modified context, check blocking conditions
    if not context.allow_purchase:
        return ERROR_PURCHASE_BLOCKED
```

4. **Use Modified Context**:
```gdscript
    # Use final_cost (potentially modified by perks)
    if not BankingService.subtract_currency(
        context.character_id,
        CurrencyType.SCRAP,
        context.final_cost
    ):
        return ERROR_INSUFFICIENT_FUNDS

    # Grant item
    InventoryService.add_item(context.character_id, item_id)

    # Check if perk granted free copy
    if context.grant_free_copy:
        InventoryService.add_item(context.character_id, item_id)
```

5. **Fire Post-Hook** (let perks react):
```gdscript
    # Update context with actual results
    context["cost_paid"] = context.final_cost
    context["bonus_items"] = []

    # Fire post-hook
    shop_purchase_post.emit(context)

    # Grant any bonus items perks added
    for bonus_item_id in context.bonus_items:
        InventoryService.add_item(context.character_id, bonus_item_id)

    return OK
```

### 3.2 Connecting Perks to Hooks

**PerksService Implementation:**

```gdscript
# services/PerksService.gd
class_name PerksService
extends Node

var active_perks: Array[Perk] = []

func _ready():
    # Connect to all service hooks
    _connect_hooks()

func _connect_hooks():
    # Shop hooks
    if ShopService:
        ShopService.shop_purchase_pre.connect(_on_shop_purchase_pre)
        ShopService.shop_purchase_post.connect(_on_shop_purchase_post)

    # Character hooks
    if CharacterService:
        CharacterService.character_create_pre.connect(_on_character_create_pre)
        CharacterService.character_death_pre.connect(_on_character_death_pre)

    # ... connect all other hooks

func _on_shop_purchase_pre(context: Dictionary):
    # Execute all perks listening to this hook
    for perk in active_perks:
        if "shop_purchase_pre" in perk.hook_points:
            _execute_perk(perk, "shop_purchase_pre", context)

func _execute_perk(perk: Perk, hook_name: String, context: Dictionary):
    # Apply perk logic based on config
    match hook_name:
        "shop_purchase_pre":
            if "discount_pct" in perk.config:
                var discount = perk.config.discount_pct
                context.final_cost *= (1.0 - discount)
                context.discount_pct += discount

            if "free_item_chance" in perk.config:
                var roll = randf()
                if roll < perk.config.free_item_chance:
                    context.grant_free_copy = true

        "character_death_pre":
            if "prevent_death_once" in perk.config and perk.config.prevent_death_once:
                context.allow_death = false
                context.resurrection_granted = true
                # Mark perk as used
                perk.config.prevent_death_once = false

        # ... handle all other hooks
```

---

## 4. Service Integration Checklist

Use this checklist when implementing a new service:

### CharacterService
- [ ] `character_create_pre` - Before character creation
- [ ] `character_create_post` - After character creation
- [ ] `character_level_up_pre` - Before level up
- [ ] `character_level_up_post` - After level up
- [ ] `character_death_pre` - Before death processing
- [ ] `character_death_post` - After death processing

### CombatService
- [ ] `damage_dealt_pre` - Before damage application
- [ ] `damage_dealt_post` - After damage applied
- [ ] `damage_received_pre` - Before damage received
- [ ] `damage_received_post` - After damage received
- [ ] `enemy_death_pre` - Before enemy death
- [ ] `enemy_death_post` - After enemy death
- [ ] `wave_start_pre` - Before wave starts
- [ ] `wave_start_post` - After wave starts
- [ ] `wave_complete_pre` - Before wave completion
- [ ] `wave_complete_post` - After wave completion

### ShopService
- [ ] `shop_purchase_pre` - Before item purchase
- [ ] `shop_purchase_post` - After item purchase

### ShopRerollService
- [ ] `shop_reroll_pre` - Before shop reroll
- [ ] `shop_reroll_post` - After shop reroll

### RecyclerService
- [ ] `recycler_dismantle_pre` - Before item dismantling
- [ ] `recycler_dismantle_post` - After item dismantling

### WorkshopService
- [ ] `workshop_repair_pre` - Before item repair
- [ ] `workshop_repair_post` - After item repair
- [ ] `workshop_fusion_pre` - Before item fusion
- [ ] `workshop_fusion_post` - After item fusion
- [ ] `workshop_craft_pre` - Before item crafting
- [ ] `workshop_craft_post` - After crafting attempt
- [ ] `radioactivity_irradiate_pre` - Before item irradiation
- [ ] `radioactivity_irradiate_post` - After item irradiation

### BankingService
- [ ] `currency_add_pre` - Before currency addition
- [ ] `currency_add_post` - After currency addition
- [ ] `currency_subtract_pre` - Before currency subtraction
- [ ] `currency_subtract_post` - After currency subtraction

### GoalsService
- [ ] `goal_complete_pre` - Before goal completion
- [ ] `goal_complete_post` - After goal completion

### AchievementsService
- [ ] `achievement_unlock_pre` - Before achievement unlock
- [ ] `achievement_unlock_post` - After achievement unlock

### MinionsService
- [ ] `minion_spawn_pre` - Before minion spawns
- [ ] `minion_death_post` - After minion dies

### EventsService
- [ ] `event_start_post` - When event activates
- [ ] `event_end_post` - When event ends

---

## 5. Hook Naming Conventions

### 5.1 Hook Name Pattern

```
{system}_{action}_{timing}
```

**Examples:**
- `shop_purchase_pre` - Shop system, purchase action, before timing
- `character_death_post` - Character system, death action, after timing
- `wave_complete_pre` - Combat system, wave complete action, before timing

### 5.2 Timing Suffixes

| Suffix | Meaning | Purpose |
|--------|---------|---------|
| `_pre` | Before action | Modify inputs, validate, block |
| `_post` | After action | React to results, grant bonuses |
| (no suffix) | Event notification | Trigger side effects |

### 5.3 Context Key Naming

**Standard Keys (Present in All Contexts):**
- `character_id: String` - Active character
- `allow_{action}: bool` - Whether action can proceed (for pre-hooks)

**Modifier Keys (Pre-Hooks):**
- `base_{property}: int/float` - Original value (read-only)
- `final_{property}: int/float` - Modified value (perks change this)

**Result Keys (Post-Hooks):**
- `{property}_granted: int/float` - Actual value after action
- `bonus_{property}: Array/int` - Additional rewards perks can add

---

## 6. Context Structures

### 6.1 Standard Context Template

```gdscript
# Pre-hook context template
var context_pre = {
    # Identifiers
    "character_id": String,

    # Base values (read-only)
    "base_value": int,

    # Final values (perks modify these)
    "final_value": int,

    # Control flow
    "allow_action": bool,

    # Additional data (action-specific)
    # ...
}

# Post-hook context template
var context_post = {
    # Identifiers
    "character_id": String,

    # Results
    "value_granted": int,
    "success": bool,

    # Bonuses (perks can add items here)
    "bonus_items": Array[String],
    "bonus_currency": int,

    # Additional data (action-specific)
    # ...
}
```

### 6.2 Context Validation

**Always validate context before using modified values:**

```gdscript
func purchase_item(item_id: String, character_id: String) -> int:
    var context = { ... }

    shop_purchase_pre.emit(context)

    # Validation checks
    assert(context.has("final_cost"), "Perk removed final_cost!")
    assert(context.final_cost >= 0, "Perk set negative cost!")
    assert(typeof(context.allow_purchase) == TYPE_BOOL, "allow_purchase must be bool!")

    if not context.allow_purchase:
        return ERROR_PURCHASE_BLOCKED

    # Safe to proceed
    ...
```

---

## 7. Testing Perk Hooks

### 7.1 Unit Test Template

```gdscript
# tests/services/shop_service_test.gd
extends GutTest

var shop_service: ShopService
var perk_service: PerksService

func before_each():
    shop_service = ShopService.new()
    perk_service = PerksService.new()
    add_child(shop_service)
    add_child(perk_service)

func test_shop_purchase_discount_perk():
    # Arrange: Create a discount perk
    var discount_perk = Perk.new()
    discount_perk.id = "test_discount"
    discount_perk.hook_points = ["shop_purchase_pre"]
    discount_perk.config = { "discount_pct": 0.25 }  # 25% off

    perk_service.apply_perk(discount_perk)

    # Act: Purchase item
    var result = shop_service.purchase_item("sword_001", "char_123")

    # Assert: Cost was reduced by 25%
    assert_eq(result, OK)
    var final_cost = shop_service.last_purchase_cost
    var expected_cost = shop_service.get_item_cost("sword_001") * 0.75
    assert_eq(final_cost, expected_cost)

func test_character_death_resurrection_perk():
    # Arrange: Create resurrection perk
    var revive_perk = Perk.new()
    revive_perk.id = "test_revive"
    revive_perk.hook_points = ["character_death_pre"]
    revive_perk.config = { "prevent_death_once": true }

    perk_service.apply_perk(revive_perk)

    # Act: Trigger character death
    var result = character_service.on_death("char_123")

    # Assert: Character was not killed
    assert_eq(result, DEATH_PREVENTED)
    assert_true(character_service.is_character_alive("char_123"))

    # Assert: Perk was consumed (one-time use)
    assert_false(revive_perk.config.prevent_death_once)
```

### 7.2 Integration Test Template

```gdscript
# tests/integration/perks_integration_test.gd
extends GutTest

func test_multiple_perks_stack_correctly():
    # Arrange: Create 3 damage boost perks
    var perk1 = create_damage_perk(0.10)  # +10%
    var perk2 = create_damage_perk(0.15)  # +15%
    var perk3 = create_damage_perk(0.05)  # +5%

    perk_service.apply_perk(perk1)
    perk_service.apply_perk(perk2)
    perk_service.apply_perk(perk3)

    # Act: Deal damage
    combat_service.deal_damage("char_123", "enemy_456", 100.0)

    # Assert: Total damage = 100 * 1.10 * 1.15 * 1.05 = 132.825
    var actual_damage = combat_service.last_damage_dealt
    assert_almost_eq(actual_damage, 132.825, 0.01)

func create_damage_perk(multiplier: float) -> Perk:
    var perk = Perk.new()
    perk.hook_points = ["damage_dealt_pre"]
    perk.config = { "damage_multiplier": 1.0 + multiplier }
    return perk
```

---

## 8. Migration Strategy

### 8.1 Phased Implementation

**Week 6-7: Foundation (CRITICAL)**
- [ ] Create PerksService skeleton
- [ ] Implement signal-based hook pattern in CharacterService
- [ ] Add 6 character hooks (create/level/death pre/post)
- [ ] Write unit tests for character hooks
- [ ] Document hook usage in CharacterService

**Week 8: Combat System**
- [ ] Add 10 combat hooks (damage/enemy/wave)
- [ ] Integrate with CombatService
- [ ] Create test perks for damage/defense
- [ ] Test perk stacking behavior

**Week 9-10: Economy Systems**
- [ ] Add shop/reroll hooks (4 hooks)
- [ ] Add recycler hooks (2 hooks)
- [ ] Add workshop hooks (8 hooks)
- [ ] Add banking hooks (4 hooks)
- [ ] Test economy perk interactions

**Week 11+: Advanced Systems**
- [ ] Add minions hooks (2 hooks)
- [ ] Add goals/achievements hooks (4 hooks)
- [ ] Add events hooks (2 hooks)
- [ ] Complete integration testing

### 8.2 Backwards Compatibility

**During migration, services must support both modes:**

```gdscript
func purchase_item(item_id: String, character_id: String) -> int:
    var cost = get_item_cost(item_id)

    # NEW: Hook-based (if PerksService exists)
    if PerksService:
        var context = {
            "final_cost": cost,
            "allow_purchase": true
        }
        shop_purchase_pre.emit(context)
        if not context.allow_purchase:
            return ERROR_BLOCKED
        cost = context.final_cost

    # OLD: Original logic (fallback)
    if not BankingService.subtract_currency(character_id, cost):
        return ERROR_INSUFFICIENT_FUNDS

    InventoryService.add_item(item_id)
    return OK
```

### 8.3 Rollout Checklist

Before deploying perks to production:

- [ ] All 50+ hooks implemented and tested
- [ ] PerksService sync with Supabase working
- [ ] Admin dashboard for creating/managing perks
- [ ] Test perks created for each hook type
- [ ] Performance testing (1000+ perks active)
- [ ] Server-side perk validation working
- [ ] Client-side perk deletion/expiration working
- [ ] Documentation complete for all hooks
- [ ] Developer onboarding guide written

---

## Appendix: Hook Quick Reference

**Total Hook Points:** 50+

**By System:**
- Character: 6 hooks
- Combat: 10 hooks
- Economy: 18 hooks (shop, recycler, workshop, banking)
- Progression: 4 hooks (goals, achievements)
- Minions: 2 hooks
- Events: 2 hooks
- Radioactivity: 2 hooks

**By Timing:**
- Pre-hooks: 26 (modify inputs)
- Post-hooks: 24 (react to results)

**Critical Path (Week 6-7):**
1. CharacterService: 6 hooks
2. PerksService: Hook execution engine
3. Unit tests for character hooks

**Next Priority (Week 8):**
- CombatService: 10 hooks (enables combat perks)

---

**Document Version:** 1.0
**Last Updated:** November 9, 2025
**Next Review:** After Week 8 Combat System implementation
