# Character System (Godot Implementation)

**Status**: Week 17 Complete ✅, Week 18 Character Types Expansion 📋
**Last Updated**: 2025-11-27
**Implementation**: `scripts/services/character_service.gd`

---

## 1. System Overview

### 1.1 Purpose

The Character System manages player characters, including creation, selection, progression, and tier-based monetization. It provides the foundation for combat, inventory, progression, and aura systems.

**Core Features (Implemented)**:
- Character CRUD (create, read, update, delete)
- Active character tracking
- Tier-based slots (FREE=3, PREMIUM=10, SUBSCRIPTION=unlimited)
- Level progression (linear XP, auto-distribute stats)
- 6 perk hooks (create, level up, death)
- SaveManager integration

**Week 18 Expansion (Planned)**:
- 6 character types with unique mechanics
- Premium/Subscription character unlocks
- Try-before-buy conversion flow

---

### 1.2 Key User Stories

**Implemented**:
- ✅ As a FREE player, I want to create up to 3 characters
- ✅ As a PREMIUM player, I want to create up to 10 characters
- ✅ As a SUBSCRIPTION player, I want unlimited characters
- ✅ As a player, I want my characters to gain XP and level up
- ✅ As a player, I want my character data to persist between sessions
- ✅ As a developer, I want perk hooks to modify character creation/progression

**Week 18 (Planned)**:
- 📋 As a FREE player, I want to try PREMIUM characters for 1 run before buying
- 📋 As a player, I want different character types with unique stats and mechanics
- 📋 As a player, I want to see visual distinction between character types

---

### 1.3 Business Value

**Monetization Testing (Week 18)**:
- **Premium Characters (Tinkerer, Salvager)**: Validates Premium tier value ($2.99-$9.99 one-time)
- **Subscription Character (Overclocked)**: Validates Subscription tier value ($1.99-$4.99/month)
- **Try-before-buy**: Reduces purchase friction, increases conversion rate (8-18% expected)

**Retention Impact**:
- Character progression = long-term engagement
- Multiple character types = build diversity = replayability
- Tier-based slots = natural upgrade path (3 → 10 → unlimited)

---

## 2. Character Types (AUTHORITATIVE)

### 2.1 Character Type Definitions

| Type | Tier | Weapon Slots | Special Mechanic | Flavor |
|------|------|--------------|------------------|--------|
| **Scavenger** | Free | 6 | +10% Scrap drops, +15 pickup range | "Knows where the good junk is" |
| **Rustbucket** | Free | 4 | +30 Max HP, +5 Armor, -15% Speed | "More patches than original parts" |
| **Hotshot** | Free | 6 | +20% Damage, +10% Crit, -20 Max HP | "Burns bright, burns fast" |
| **Tinkerer** | Premium | 6 | +1 Stack limit (all rarities), -10% Damage | "Can always fit one more gadget" |
| **Salvager** | Premium | 5 | +50% Component yield, +25% Shop discount, -1 Weapon slot | "Sees value in everything" |
| **Overclocked** | Subscription | 6 | +25% Attack Speed, +15% Damage, takes 5% Max HP damage per wave | "Pushed past factory specs" |

---

### 2.2 Character Stat Modifiers (Detailed)

#### Free Tier Characters

**Scavenger** (Economy Focus)
```gdscript
{
    "weapon_slots": 6,
    "scrap_drop_bonus": 0.10,      # +10% scrap from all sources
    "pickup_range_bonus": 15,      # +15 units pickup range
}
```

**Rustbucket** (Tank/Survivability)
```gdscript
{
    "weapon_slots": 4,             # -2 weapon slots (tradeoff)
    "max_hp_bonus": 30,            # +30 Max HP
    "armor_bonus": 5,              # +5 Armor
    "speed_multiplier": 0.85,      # -15% movement speed
}
```

**Hotshot** (Glass Cannon)
```gdscript
{
    "weapon_slots": 6,
    "damage_multiplier": 1.20,     # +20% all damage
    "crit_chance_bonus": 0.10,     # +10% crit chance
    "max_hp_bonus": -20,           # -20 Max HP (penalty)
}
```

#### Premium Tier Characters

**Tinkerer** (Build Variety) - *Requires Premium*
```gdscript
{
    "weapon_slots": 6,
    "stack_limit_bonus": 1,        # +1 to all stack limits
    "damage_multiplier": 0.90,     # -10% damage (tradeoff)
}
```

**Salvager** (Resource Efficiency) - *Requires Premium*
```gdscript
{
    "weapon_slots": 5,             # -1 weapon slot (tradeoff)
    "component_yield_bonus": 0.50, # +50% components from recycling
    "shop_discount": 0.25,         # 25% off all shop purchases
}
```

#### Subscription Tier Characters

**Overclocked** (High Risk/Reward) - *Requires Subscription*
```gdscript
{
    "weapon_slots": 6,
    "attack_speed_bonus": 0.25,    # +25% attack speed
    "damage_multiplier": 1.15,     # +15% damage
    "wave_hp_damage_pct": 0.05,    # Takes 5% Max HP damage per wave
}
```

---

### 2.3 Visual Differentiation

| Type | Color Palette | Theme | Visual Indicator |
|------|--------------|-------|------------------|
| Scavenger | Dusty Brown/Orange | Junkyard scavenger | Makeshift goggles, bag |
| Rustbucket | Rusty Orange/Red-Brown | Patched-up robot | Visible patches, dents |
| Hotshot | Flame Orange/Yellow | Fast & dangerous | Flames, sharp edges |
| Tinkerer | Teal/Copper | Gadget inventor | Tools, gears visible |
| Salvager | Green/Brass | Resource collector | Canisters, storage |
| Overclocked | Electric Blue/White | Overheating machine | Sparks, heat vents |

---

### 2.4 SQA Testing Matrix

| Test Case | Scavenger | Rustbucket | Hotshot | Tinkerer | Salvager | Overclocked |
|-----------|-----------|------------|---------|----------|----------|-------------|
| Create character | ✓ | ✓ | ✓ | Premium gate | Premium gate | Sub gate |
| Weapon slots correct | 6 | 4 | 6 | 6 | 5 | 6 |
| Bonus applies | Scrap +10% | HP +30 | Dmg +20% | Stack +1 | Yield +50% | AtkSpd +25% |
| Penalty applies | N/A | Speed -15% | HP -20 | Dmg -10% | Slots -1 | HP dmg/wave |
| Try-before-buy | N/A | N/A | N/A | ✓ | ✓ | ✓ |
| Save/Load preserves | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

---

## 3. Implementation Architecture

### 3.1 Core Files

**Service Layer**:
- `scripts/services/character_service.gd` - Character CRUD, progression, tier gating
- `scripts/systems/save_manager.gd` - CharacterService integration

**Test Files**:
- `scripts/tests/character_service_test.gd` - Core functionality tests
- `scripts/tests/character_types_test.gd` - Character type tests

---

### 3.2 Character Data Structure

```gdscript
{
    "id": "char_1",                    # Unique ID
    "name": "MyScavenger",             # Player-chosen name
    "character_type": "scavenger",     # Type: scavenger, rustbucket, hotshot, tinkerer, salvager, overclocked
    "level": 1,                        # Current level (1-20+)
    "experience": 0,                   # Current XP
    "stats": {
        # Core survival
        "max_hp": 100,
        "hp_regen": 0,
        "life_steal": 0.0,
        "armor": 0,
        
        # Offense
        "damage": 10,
        "melee_damage": 0,
        "ranged_damage": 0,
        "attack_speed": 0.0,
        "crit_chance": 0.05,
        
        # Defense
        "dodge": 0.0,
        
        # Utility
        "speed": 200,
        "luck": 0,
        "pickup_range": 100,
    },
    "created_at": 1704835200,          # Unix timestamp
    "last_played": 1704835200,
    "death_count": 0,
    "total_kills": 0,
    "highest_wave": 0,
    "current_wave": 0,
}
```

---

### 3.3 Service API

#### Character CRUD

```gdscript
# Create character (returns character_id or empty string on failure)
var character_id = CharacterService.create_character("MyName", "scavenger")

# Get character (returns dictionary or empty dict if not found)
var character = CharacterService.get_character(character_id)

# Get all characters
var all_characters = CharacterService.get_all_characters()  # Array[Dictionary]

# Update character
CharacterService.update_character(character_id, {
    "stats": {"max_hp": 120},
    "level": 5
})

# Delete character
CharacterService.delete_character(character_id)
```

#### Active Character

```gdscript
# Set active character
CharacterService.set_active_character(character_id)

# Get active character ID
var active_id = CharacterService.get_active_character_id()  # String

# Get active character data
var active_char = CharacterService.get_active_character()  # Dictionary
```

#### Progression

```gdscript
# Add XP (returns true if leveled up)
var leveled_up = CharacterService.add_experience(character_id, 100)

# Handle death (returns true if resurrected by perk)
var resurrected = CharacterService.on_character_death(character_id, death_context)
```

#### Tier & Slots

```gdscript
# Set user tier
CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

# Check if can create more characters
var can_create = CharacterService.can_create_character()  # bool

# Get available slots
var slots_remaining = CharacterService.get_available_slots()  # int

# Get slot limit for current tier
var limit = CharacterService.get_character_slot_limit()  # int (3, 10, or -1)
```

---

### 3.4 Perk Hooks

All hooks implemented as signals with context dictionaries:

```gdscript
# Character Creation Hooks
signal character_create_pre(context: Dictionary)
signal character_create_post(context: Dictionary)

# Level Up Hooks
signal character_level_up_pre(context: Dictionary)
signal character_level_up_post(context: Dictionary)

# Death Hooks
signal character_death_pre(context: Dictionary)
signal character_death_post(context: Dictionary)
```

---

## 4. Tier-Based Monetization

### 4.1 Character Slot Limits

| Tier | Slot Limit | Price | Unlock |
|------|------------|-------|--------|
| **FREE** | 3 characters | Free | Default |
| **PREMIUM** | 10 characters | $2.99-$9.99 one-time | In-app purchase |
| **SUBSCRIPTION** | Unlimited | $1.99-$4.99/month | In-app subscription |

---

### 4.2 Character Type Gating

| Character Type | Required Tier | CTA Message |
|----------------|---------------|-------------|
| **Scavenger** | FREE | Always unlocked |
| **Rustbucket** | FREE | Always unlocked |
| **Hotshot** | FREE | Always unlocked |
| **Tinkerer** | PREMIUM | "Upgrade to Premium to unlock Tinkerer" |
| **Salvager** | PREMIUM | "Upgrade to Premium to unlock Salvager" |
| **Overclocked** | SUBSCRIPTION | "Subscribe to unlock Overclocked" |

---

### 4.3 Try-Before-Buy Flow (Week 18)

**Step 1**: FREE player taps locked Tinkerer character
**Step 2**: Show character preview modal with stats and trial option
**Step 3**: Player tries character for 1 run (no restrictions)
**Step 4**: Post-run conversion screen with performance comparison

**Expected Conversion Rate**: 10-18% (industry average with trial: 12%)

---

## 5. Testing Strategy

### 5.1 Character Type Validation

Each character type must pass:
1. Creation test (tier gating enforced)
2. Stat modifier application
3. Special mechanic functionality
4. Save/Load persistence
5. Visual indicator display
6. Try-before-buy flow (Premium/Subscription only)

---

## 6. Future Enhancements

### Week 18
- Implement 6 character types with all mechanics
- Character selection UI with type details
- Try-before-buy conversion flow

### Week 19+
- Player-choice level-up UI
- Character appearance customization
- Starting equipment per character type

### Future (Week 22+)
- Advanced character types
- Character-specific perks
- Minions system (deferred)

---

## 7. Related Documentation

**Architecture**:
- [INVENTORY-SYSTEM.md](./INVENTORY-SYSTEM.md) - Death penalties, component yields
- [ITEM-STATS-SYSTEM.md](./ITEM-STATS-SYSTEM.md) - Stack limits

**Tier Experiences**:
- [premium-tier.md](../../tier-experiences/premium-tier.md) - Premium features
- [subscription-tier.md](../../tier-experiences/subscription-tier.md) - Subscription features

---

## 8. Approval Status

**Week 17**: ✅ Complete
- CharacterService implemented
- SaveManager integrated
- UI foundation complete

**Week 18**: 📋 Approved, Ready to Implement
- 6 character types (Scavenger, Rustbucket, Hotshot, Tinkerer, Salvager, Overclocked)
- Character type mechanics
- Try-before-buy conversion flow

---

**Document Version**: 3.0 (Week 18 Character Types Update)
**Previous Version**: 2.0 (Week 7 types - SUPERSEDED)
**Last Updated**: 2025-11-27
**Next Review**: After Week 18 completion
