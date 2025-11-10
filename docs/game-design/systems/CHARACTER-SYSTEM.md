# Character System (Godot Implementation)

**Status**: Week 6 Complete ✅, Week 7 Expansion 📋
**Last Updated**: 2025-01-09
**Implementation**: `scripts/services/character_service.gd`

---

## 1. System Overview

### 1.1 Purpose

The Character System manages player characters, including creation, selection, progression, and tier-based monetization. It provides the foundation for combat, inventory, progression, and aura systems.

**Week 6 Foundation (Complete)**:
- Character CRUD (create, read, update, delete)
- Active character tracking
- Tier-based slots (FREE=3, PREMIUM=10, SUBSCRIPTION=unlimited)
- Level progression (linear XP, auto-distribute stats)
- 6 perk hooks (create, level up, death)
- SaveManager integration

**Week 7 Expansion (In Progress)**:
- 14 character stats (8 base + 6 new including "Resonance")
- 3 character types (Scavenger, Tank, Commando)
- Aura system foundation
- Try-before-buy conversion flow

---

### 1.2 Key User Stories

**Week 6 (Implemented)**:
- ✅ As a FREE player, I want to create up to 3 characters
- ✅ As a PREMIUM player, I want to create up to 10 characters
- ✅ As a SUBSCRIPTION player, I want unlimited characters
- ✅ As a player, I want my characters to gain XP and level up
- ✅ As a player, I want my character data to persist between sessions
- ✅ As a developer, I want perk hooks to modify character creation/progression

**Week 7 (Planned)**:
- 📋 As a FREE player, I want to try PREMIUM characters for 1 run before buying
- 📋 As a player, I want different character types with unique stats and auras
- 📋 As a player, I want my character's aura to provide utility (collect, shield, damage)
- 📋 As a player, I want to see visual distinction between character types

**Week 8+ (Future)**:
- 📅 As a player, I want to customize my character's appearance
- 📅 As a player, I want to choose which stats to increase on level up
- 📅 As a player, I want to upgrade my character's aura via items/perks

---

### 1.3 Business Value

**Monetization Testing (Week 7)**:
- **Premium Character (Tank)**: Validates Premium tier value ($4.99 one-time)
- **Subscription Character (Commando)**: Validates Subscription tier value ($9.99/month)
- **Try-before-buy**: Reduces purchase friction, increases conversion rate (8-18% expected)

**Retention Impact**:
- Character progression = long-term engagement
- Multiple character types = build diversity = replayability
- Tier-based slots = natural upgrade path (3 → 10 → unlimited)

---

## 2. Implementation Architecture

### 2.1 Core Files

**Service Layer**:
- `scripts/services/character_service.gd` (474 lines) - Character CRUD, progression, tier gating
- `scripts/systems/save_manager.gd` (updated) - CharacterService integration
- `scripts/systems/aura_types.gd` (Week 7) - Aura type definitions
- `scripts/components/aura_visual.gd` (Week 7) - Aura visual stub

**Test Files**:
- `scripts/tests/character_service_test.gd` (662 lines, 43 tests) - Core functionality
- `scripts/tests/character_stats_expansion_test.gd` (Week 7, 25 tests) - New stats
- `scripts/tests/character_types_test.gd` (Week 7, 20 tests) - Character types
- `scripts/tests/aura_foundation_test.gd` (Week 7, 13 tests) - Aura system

---

### 2.2 Character Data Structure

```gdscript
{
    "id": "char_1",                    # Unique ID
    "name": "MyScavenger",             # Player-chosen name
    "character_type": "scavenger",     # Type: scavenger, tank, commando, mutant
    "level": 1,                        # Current level (1-20+)
    "experience": 0,                   # Current XP
    "stats": {                         # 14 total stats (Week 7)
        # Core survival (4)
        "max_hp": 100,
        "hp_regen": 0,
        "life_steal": 0.0,
        "armor": 0,

        # Offense (6)
        "damage": 10,
        "melee_damage": 0,
        "ranged_damage": 0,
        "attack_speed": 0.0,
        "crit_chance": 0.05,
        "resonance": 0,                # NEW: Drives aura power

        # Defense (1 additional)
        "dodge": 0.0,

        # Utility (3)
        "speed": 200,
        "luck": 0,
        "pickup_range": 100,
        "scavenging": 0                # NEW: Currency multiplier
    },
    "created_at": 1704835200,          # Unix timestamp
    "last_played": 1704835200,
    "death_count": 0,
    "total_kills": 0,
    "highest_wave": 0,
    "current_wave": 0,
    "aura": {                          # Week 7: Aura data
        "type": "collect",             # Aura type (collect, shield, damage, etc.)
        "enabled": true,
        "level": 1
    }
}
```

---

### 2.3 Character Types (Week 7)

| Type | Tier | Stat Modifiers | Aura | Visual | Theme |
|------|------|----------------|------|--------|-------|
| **Scavenger** | FREE | +5 Scavenging<br>+20 Pickup Range | Collect | Gray | Economy |
| **Tank** | PREMIUM | +20 Max HP<br>+3 Armor<br>-20 Speed | Shield | Olive | Survivability |
| **Commando** | SUBSCRIPTION | +5 Ranged Damage<br>+15% Attack Speed<br>-2 Armor | None | Red | DPS |
| **Mutant** | SUBSCRIPTION | +10 Resonance<br>+5 Luck<br>+20 Pickup Range | Damage | Purple | Aura Specialist |

**Visual Differentiation** (Week 7):
- Simple color palette swaps (modulate sprite color)
- Week 8+: Add accessory overlays (backpack, helmet, bandana)

---

### 2.4 Service API

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

#### Save/Load

```gdscript
# Serialize (called by SaveManager)
var save_data = CharacterService.serialize()

# Deserialize (called by SaveManager)
CharacterService.deserialize(save_data)

# Reset (for testing)
CharacterService.reset()
```

---

### 2.5 Perk Hooks (Week 6)

All hooks implemented as signals with context dictionaries:

```gdscript
# Character Creation Hooks
signal character_create_pre(context: Dictionary)
# context = {
#     "character_type": String,
#     "base_stats": Dictionary,
#     "starting_items": Array,
#     "starting_currency": Dictionary,
#     "allow_create": bool
# }

signal character_create_post(context: Dictionary)
# context = {
#     "character_id": String,
#     "character_data": Dictionary,
#     "player_tier": UserTier
# }

# Level Up Hooks
signal character_level_up_pre(context: Dictionary)
# context = {
#     "character_id": String,
#     "old_level": int,
#     "new_level": int,
#     "stat_gains": Dictionary,
#     "allow_level_up": bool
# }

signal character_level_up_post(context: Dictionary)
# context = {
#     "character_id": String,
#     "new_level": int,
#     "total_stat_gains": Dictionary
# }

# Death Hooks
signal character_death_pre(context: Dictionary)
# context = {
#     "character_id": String,
#     "death_context": Dictionary,
#     "durability_loss_pct": float,
#     "allow_death": bool,
#     "resurrection_granted": bool
# }

signal character_death_post(context: Dictionary)
# context = {
#     "character_id": String,
#     "final_stats": Dictionary,
#     "death_count": int
# }
```

**Example Perk Usage**:
```gdscript
# Perk: "Tough Start" - +10 HP to new characters
func _ready():
    CharacterService.character_create_pre.connect(_on_character_create_pre)

func _on_character_create_pre(context: Dictionary):
    context.base_stats["max_hp"] += 10
    print("Tough Start perk: +10 HP bonus")
```

---

### 2.6 SaveManager Integration

```gdscript
# SaveManager automatically serializes CharacterService
SaveManager.save_all_services(0)  # Save to slot 0

# Serialized data structure:
{
    "version": 1,
    "characters": {
        "char_1": { ... },  # Character data
        "char_2": { ... }
    },
    "active_character_id": "char_1",
    "tier": UserTier.PREMIUM,
    "next_character_id": 3,
    "timestamp": 1704835200
}

# Load restores all character data
SaveManager.load_all_services(0)
```

---

## 3. Character Stats System (Week 7)

### 3.1 Stat Categories

See [CHARACTER-STATS-REFERENCE.md](../../core-architecture/CHARACTER-STATS-REFERENCE.md) for complete stat definitions.

**Summary**:
- **Core Survival**: max_hp, hp_regen, life_steal, armor (4 stats)
- **Offense**: damage, melee_damage, ranged_damage, attack_speed, crit_chance, resonance (6 stats)
- **Defense**: dodge (1 additional stat)
- **Utility**: speed, luck, pickup_range, scavenging (4 stats)

**Total**: 14 stats (8 base + 6 new)

---

### 3.2 Level-Up Stat Gains

```gdscript
# Auto-distributed per level (Week 7 design)
{
    "max_hp": +5,        # Survivability focus
    "damage": +2,        # Moderate DPS growth
    "armor": +1,         # Slow armor scaling (diminishing returns)
    "scavenging": +1     # Economy growth
}
```

**Level 20 Example** (Scavenger, no items):
- Max HP: 100 + (19*5) = 195 HP
- Damage: 10 + (19*2) = 48 damage
- Armor: 0 + (19*1) = 19 armor
- Scavenging: 5 (type) + (19*1) = 24 scavenging (+50% cap = 14 effective)

---

## 4. Aura System (Week 7 Foundation)

See [AURA-SYSTEM.md](./AURA-SYSTEM.md) for complete aura design.

### 4.1 Aura Types

| Aura | Effect | Scales With | Character |
|------|--------|-------------|-----------|
| **Damage** | Deals damage to enemies | Resonance | Mutant (Week 8) |
| **Knockback** | Pushes enemies away | Resonance | TBD (Week 9+) |
| **Heal** | Heals nearby minions | Resonance | TBD (Week 9+) |
| **Collect** | Auto-collects currency | Resonance | Scavenger ⭐ |
| **Slow** | Slows enemy movement | Resonance | TBD (Week 9+) |
| **Shield** | Grants temporary armor | Resonance | Tank ⭐ |

---

### 4.2 Aura Mechanics

**Radius Calculation**:
```gdscript
aura_radius = character.stats.pickup_range  # Dual-purpose stat
```

**Power Calculation**:
```gdscript
# Example: Damage Aura
aura_damage = 5 + (character.stats.resonance * 0.5)

# Scavenger with resonance=5:
# aura_damage = 5 + (5 * 0.5) = 7.5 damage per pulse
```

**Visuals (Week 7)**:
- Simple ColorRect circles with color coding
- Pulsing animation via Tween
- Week 8: Upgrade to GPUParticles2D

---

## 5. Tier-Based Monetization

### 5.1 Character Slot Limits

| Tier | Slot Limit | Price | Unlock |
|------|------------|-------|--------|
| **FREE** | 3 characters | Free | Default |
| **PREMIUM** | 10 characters | $4.99 one-time | In-app purchase |
| **SUBSCRIPTION** | Unlimited | $9.99/month | In-app subscription |

**Enforcement**:
```gdscript
func create_character(name: String, character_type: String) -> String:
    # Check slot limits
    if not can_create_character():
        # Show upgrade CTA
        return ""
    # ...
```

---

### 5.2 Character Type Gating

| Character Type | Required Tier | CTA Message |
|----------------|---------------|-------------|
| **Scavenger** | FREE | Always unlocked |
| **Tank** | PREMIUM | "Upgrade to Premium to unlock Tank" |
| **Commando** | SUBSCRIPTION | "Subscribe for exclusive Commando character" |
| **Mutant** | SUBSCRIPTION | "Mutant available to Subscribers only" |

**Enforcement**:
```gdscript
func create_character(name: String, character_type: String) -> String:
    var type_def = CHARACTER_TYPES[character_type]
    if type_def.tier_required > current_tier:
        # Show tier upgrade modal
        return ""
    # ...
```

---

### 5.3 Try-Before-Buy Flow (Week 7-8)

**Step 1**: FREE player taps locked Tank character
```
[Character Select Screen]
- Scavenger (unlocked)
- Tank (🔒 PREMIUM)  ← User taps
- Commando (🔒 SUBSCRIPTION)
```

**Step 2**: Show character preview modal
```
┌─────────────────────────────┐
│ 🛡️ TANK CHARACTER           │
│ [Olive-colored sprite]      │
│                             │
│ Stats: +20 HP, +3 Armor     │
│ Aura: Shield                │
│                             │
│ ┌─────────────────────────┐ │
│ │ 🎮 Try for 1 Run       │ │ ← Free trial
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 🔓 Unlock Forever       │ │
│ │ (Premium - $4.99)       │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**Step 3**: Player tries Tank for 1 run (no restrictions)

**Step 4**: Post-run conversion screen
```
┌─────────────────────────────┐
│ 🎉 Run Complete!            │
│                             │
│ Tank survivability:         │
│ Wave 15 reached (+3 vs avg) │
│ Damage taken: 450           │
│ (Tank's armor saved you!)   │
│                             │
│ ┌─────────────────────────┐ │
│ │ 🔓 Unlock Tank Forever  │ │
│ │ Only $4.99              │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**Expected Conversion Rate**: 10-18% (industry average with trial: 12%)

---

## 6. Testing Strategy

### 6.1 Test Coverage (Week 6 Complete)

**Current Tests**: 43/43 passing (100%)
```
scripts/tests/character_service_test.gd (662 lines)
├── Character Creation (5 tests)
├── Character CRUD (9 tests)
├── Active Character (3 tests)
├── Tier-Based Slots (5 tests)
├── Level Progression (6 tests)
├── Character Death (2 tests)
├── Perk Hooks (6 tests)
├── SaveManager Integration (4 tests)
└── Service Signals (4 tests)
```

---

### 6.2 Week 7 Test Plan

**New Tests**: 58 tests (25 + 20 + 13)

```
character_stats_expansion_test.gd (25 tests)
- New stat defaults
- HP regen healing
- Life steal mechanics
- Attack speed cooldown reduction
- Melee/Ranged damage bonuses
- Scavenging currency multiplier
- Resonance aura power

character_types_test.gd (20 tests)
- Character type stat modifiers
- Tier restrictions (FREE cannot create PREMIUM)
- Type persistence after save/load
- Aura type assignment per character

aura_foundation_test.gd (13 tests)
- Aura data in character
- Aura power calculation
- Aura radius calculation
- Aura visual stub creation
```

**Total Week 7**: 101 tests (43 existing + 58 new)

---

## 7. Performance Considerations

### 7.1 Character Storage

**Approach**: In-memory Dictionary + SaveSystem persistence
- **Pros**: Fast lookups (O(1) by ID), simple serialization
- **Cons**: No reactive updates (use signals instead)

**Future Optimization** (if 1000+ characters):
- Database (SQLite) for large character collections
- Pagination for character select screen

---

### 7.2 Stat Calculations

**Current**: Stats stored as Dictionary, no caching
**Future** (Week 9+): Cache computed stats (with items/perks)

```gdscript
# Week 9+ optimization
var _stat_cache = {}

func get_computed_stats(character_id: String) -> Dictionary:
    if _stat_cache.has(character_id):
        return _stat_cache[character_id]

    var character = get_character(character_id)
    var computed = _compute_stats_with_items(character)
    _stat_cache[character_id] = computed
    return computed

func _invalidate_stat_cache(character_id: String):
    _stat_cache.erase(character_id)
```

---

## 8. Future Enhancements

### Week 8
- ✅ Mutant character type
- ✅ Aura visual upgrade (particles)
- ✅ Character selection UI
- ✅ Conversion flow implementation

### Week 9-10
- Player-choice level-up UI ("Choose stat to increase")
- Character appearance customization
- Starting equipment per character type
- Aura upgrade system (via items/perks)

### Week 11+
- Advanced character types (10+ types)
- Character-specific perks
- Character achievements/milestones
- Character leaderboards

---

## 9. Related Documentation

**Architecture**:
- [CHARACTER-STATS-REFERENCE.md](../../core-architecture/CHARACTER-STATS-REFERENCE.md) - Stat definitions
- [AURA-SYSTEM.md](./AURA-SYSTEM.md) - Aura mechanics
- [PERKS-ARCHITECTURE.md](../../core-architecture/PERKS-ARCHITECTURE.md) - Perk hooks
- [THE-LAB-SYSTEM.md](./THE-LAB-SYSTEM.md) - Nanites currency (scavenging affects)

**Implementation**:
- [character_service.gd](../../../scripts/services/character_service.gd) - Service code
- [character_service_test.gd](../../../scripts/tests/character_service_test.gd) - Test suite
- [week7-implementation-plan.md](../../migration/week7-implementation-plan.md) - Week 7 plan
- [GODOT-MIGRATION-TIMELINE-UPDATED.md](../../migration/GODOT-MIGRATION-TIMELINE-UPDATED.md) - Timeline

**Reference**:
- [brotato-reference.md](../../brotato-reference.md) - Brotato comparison

---

## 10. Approval Status

**Week 6**: ✅ Complete (2025-01-09)
- 43/43 tests passing
- CharacterService implemented
- SaveManager integrated

**Week 7**: 📋 Approved, Ready to Implement (2025-01-09)
- 14 stats expansion (including Resonance)
- 3 character types (Scavenger, Tank, Commando)
- Aura system foundation
- Try-before-buy conversion flow

**Week 8**: 📅 Planned
- Mutant character
- Aura visual upgrade
- Character selection UI

---

**Document Version**: 2.0 (Godot Rewrite)
**Previous Version**: 1.0 (React Native - archived)
**Last Updated**: 2025-01-09
**Next Review**: After Week 7 completion (2025-01-16)
