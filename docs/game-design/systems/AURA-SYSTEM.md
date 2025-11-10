# Aura System Design

**Status**: 🚧 Foundation (Week 7), Full Implementation (Week 8)
**Last Updated**: 2025-01-09
**Unique Feature**: Not in Brotato - differentiates Scrap Survivor

---

## Overview

**Auras** are passive AOE (Area of Effect) abilities that pulse around the character. They provide utility beyond direct damage - from auto-collecting currency to healing minions to knocking back enemies.

**Design Philosophy**:
- Auras are **character-defining** (each type has unique aura)
- Auras scale with **Resonance** stat (not damage)
- Auras use **Pickup Range** for radius (efficient stat synergy)
- Auras are **versatile** (not just damage - heal, collect, slow, shield, etc.)

**Inspiration**: Auras = post-apocalyptic "mutations" (not magic), fits sci-fi theme

---

## 🎯 Core Aura Types

### 1. Damage Aura
**Effect**: Deals damage to nearby enemies per pulse
**Character**: Mutant (Week 8)
**Scaling**: `5 + (resonance * 0.5)` damage per pulse
**Cooldown**: 1.0 seconds

**Example**:
```
Mutant with resonance=10:
- Damage per pulse: 5 + (10 * 0.5) = 10 damage
- Pulses per second: 1
- DPS contribution: 10 DPS (at 100px radius)
```

**Balance Notes**:
- Should be **15-20% of total DPS** at level 10
- Should NOT trivialize combat (damage aura alone can't carry)
- Scales with resonance (requires stat investment)

---

### 2. Knockback Aura
**Effect**: Pushes enemies away from character
**Character**: TBD (Week 9+, possibly "Controller" type)
**Scaling**: `50 + (resonance * 2)` knockback force
**Cooldown**: 0.5 seconds

**Example**:
```
Character with resonance=8:
- Knockback force: 50 + (8 * 2) = 66 force
- Pulses per second: 2
- Effect: Keeps melee enemies at bay
```

**Balance Notes**:
- Should create **defensive space**, not infinite kiting
- Strong enemies (bosses, elites) have knockback resistance
- Synergizes with ranged builds (keep enemies at range)

---

### 3. Heal Aura
**Effect**: Heals nearby minions (NOT player, to prevent OP sustain)
**Character**: TBD (Week 9+, possibly "Healer" type)
**Scaling**: `3 + (resonance * 0.3)` HP per pulse
**Cooldown**: 2.0 seconds

**Example**:
```
Character with resonance=12:
- HP per pulse: 3 + (12 * 0.3) = 6.6 HP
- Pulses per second: 0.5
- Minion sustain: 3.3 HP/sec per minion in radius
```

**Balance Notes**:
- Only heals **minions** (not player character)
- Incentivizes minion-focused builds
- Synergizes with The Lab (minion crafting)

---

### 4. Collection Aura ⭐ (Scavenger Default)
**Effect**: Auto-collects currency (scrap, components, nanites) and items
**Character**: Scavenger (FREE tier)
**Scaling**: Collection speed = `resonance * 10%` faster
**Cooldown**: 0.1 seconds (checks frequently)

**Example**:
```
Scavenger with resonance=5:
- Pickup speed: 1.0 + (5 * 0.10) = 1.5x faster
- Effect: Currency flies to you 50% faster
```

**Balance Notes**:
- **Quality of life** aura (not combat power)
- Always useful (currency always drops)
- Synergizes with scavenging stat (more currency = more to collect)

---

### 5. Slow Aura
**Effect**: Slows enemy movement speed
**Character**: TBD (Week 9+, possibly "Controller" type)
**Scaling**: `30% + (resonance * 1%)` slow
**Cooldown**: 0.5 seconds

**Example**:
```
Character with resonance=15:
- Slow amount: 30% + (15 * 1%) = 45% slow
- Effect: Enemies move at 55% speed while in aura
```

**Balance Notes**:
- Should NOT stack with other slow sources (cap at 70% slow)
- Synergizes with kiting builds
- Strong against fast enemies (chasers, chargers)

---

### 6. Shield Aura ⭐ (Tank Default)
**Effect**: Grants temporary armor bonus while in radius (player + minions)
**Character**: Tank (PREMIUM tier)
**Scaling**: `2 + (resonance * 0.2)` armor bonus
**Cooldown**: 0.0 (always active, no pulse)

**Example**:
```
Tank with resonance=10:
- Armor bonus: 2 + (10 * 0.2) = 4 armor
- Effect: +4 armor while standing in aura
```

**Balance Notes**:
- Aura **follows character** (not static field)
- Only active while **standing still** or moving slowly (< 50 speed)
- Encourages defensive playstyle (tank and spank)

---

## 📐 Aura Mechanics

### Radius Calculation
```gdscript
func calculate_aura_radius(pickup_range: int) -> float:
    # Aura radius = pickup_range * 1.0 (same size)
    return float(pickup_range)

# Example:
# Character with pickup_range=120 → aura radius=120px
# Character with pickup_range+40 item → aura radius=160px
```

**Design Rationale**:
- Pickup range is **dual-purpose** (pickup + aura radius)
- Players invest in pickup range → both benefits (efficient)
- Synergy with Scavenger (+20 pickup range type bonus)

---

### Power Calculation
```gdscript
# File: scripts/systems/aura_types.gd

func calculate_aura_power(aura_type: String, resonance: int) -> float:
    match aura_type:
        "damage":
            return 5 + (resonance * 0.5)
        "knockback":
            return 50 + (resonance * 2.0)
        "heal":
            return 3 + (resonance * 0.3)
        "collect":
            return 1.0 + (resonance * 0.10)  # Speed multiplier
        "slow":
            return 30 + (resonance * 1.0)    # % slow
        "shield":
            return 2 + (resonance * 0.2)     # Armor bonus
        _:
            return 0.0
```

**Scaling Principles**:
- **Damage**: Moderate scaling (0.5 per resonance) - shouldn't dominate DPS
- **Knockback**: High scaling (2.0 per resonance) - utility focused
- **Heal**: Low scaling (0.3 per resonance) - minion sustain, not OP healing
- **Collect**: % scaling (10% per resonance) - quality of life
- **Slow**: Moderate scaling (1% per resonance) - caps at 70% total
- **Shield**: Low scaling (0.2 per resonance) - armor has diminishing returns

---

## 🎨 Visual Design (Week 7 vs Week 8)

### Week 7: Simple Prototype
**Approach**: ColorRect circles with color coding

```gdscript
# scripts/components/aura_visual.gd

extends Node2D

var aura_type: String = "collect"
var radius: float = 100.0
var color: Color = Color(1, 1, 0, 0.3)  # Yellow, semi-transparent

func _ready() -> void:
    var circle = ColorRect.new()
    circle.color = color
    circle.size = Vector2(radius * 2, radius * 2)
    circle.position = -Vector2(radius, radius)
    add_child(circle)

    # Pulsing animation
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(circle, "modulate:a", 0.5, 1.0)
    tween.tween_property(circle, "modulate:a", 0.2, 1.0)
```

**Color Scheme**:
- Damage: Red (`Color(1, 0, 0, 0.3)`)
- Knockback: Orange (`Color(1, 0.5, 0, 0.3)`)
- Heal: Green (`Color(0, 1, 0, 0.3)`)
- Collect: Yellow (`Color(1, 1, 0, 0.3)`)
- Slow: Blue (`Color(0, 0.5, 1, 0.3)`)
- Shield: Cyan (`Color(0, 1, 1, 0.3)`)

---

### Week 8: Particle Upgrade
**Approach**: GPUParticles2D with gradients

```gdscript
# scripts/components/aura_particles.gd (Week 8)

extends GPUParticles2D

func _ready() -> void:
    amount = 32
    lifetime = 1.5
    emitting = true

    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = radius

    # Color gradient
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(0, 1, 0, 1))  # Start: bright
    gradient.add_point(1.0, Color(0, 1, 0, 0))  # End: fade out

    material.color_ramp = GradientTexture1D.new()
    material.color_ramp.gradient = gradient

    process_material = material
```

**Asset Recommendation**: Kenney Particle Pack (free, CC0 license)

---

## 🔧 Implementation Timeline

### Week 7: Foundation
- ✅ Data structures (aura type, radius, power)
- ✅ Aura type definitions (`aura_types.gd`)
- ✅ Simple visual stub (ColorRect circles)
- ✅ Character data integration (aura field in character)
- ✅ 13 foundation tests (data persistence, calculations)

### Week 8: Full Implementation
- ⏳ Collision detection (aura radius vs enemies/minions)
- ⏳ Effect application (damage, knockback, heal, etc.)
- ⏳ Particle visual upgrade (GPUParticles2D)
- ⏳ Mutant character with damage aura
- ⏳ 25 integration tests (aura vs enemies)

### Week 9+: Advanced Features
- ⏳ Aura upgrades via items/perks
- ⏳ Multi-aura characters (combine 2 auras)
- ⏳ Aura visual customization (cosmetics)
- ⏳ Aura sound effects

---

## 🎮 Gameplay Examples

### Example 1: Scavenger Economy Build
```
Character: Scavenger (FREE)
Stats: scavenging=15, pickup_range=140, resonance=5
Aura: Collection (140px radius, 1.5x speed)

Gameplay:
- Kill enemies → currency drops
- Collection aura auto-vacuums currency
- Scavenging=15 → +75% currency (capped at +50% = 14 effective)
- Result: 10 scrap drop → 15 scrap collected automatically

Strategy: Maximize scrap income, buy better items
```

---

### Example 2: Tank Survivability Build
```
Character: Tank (PREMIUM)
Stats: max_hp=140, armor=8, resonance=3, pickup_range=100
Aura: Shield (100px radius, +2.6 armor bonus)

Gameplay:
- Stand still in combat (shield aura activates)
- Armor=8 + Shield=2.6 = 10.6 total armor
- Formula: damage_taken = base * (1 - 10.6 / 110.6) = 0.904 = 90.4% damage taken
- Result: 100 damage hit → 90 damage taken (10 damage blocked)

Strategy: Facetank enemies, rely on armor + HP pool
```

---

### Example 3: Mutant Damage Build (Week 8)
```
Character: Mutant (SUBSCRIPTION)
Stats: damage=20, resonance=20, pickup_range=140
Aura: Damage (140px radius, 15 DPS)

Gameplay:
- Damage aura: 5 + (20 * 0.5) = 15 damage/pulse, 1 pulse/sec = 15 DPS
- Weapon DPS: ~80 DPS (typical Level 10)
- Total DPS: 80 + 15 = 95 DPS (aura = 15.8% of total)
- Result: Aura kills weak enemies passively, player focuses on big threats

Strategy: High resonance investment, aura handles trash mobs
```

---

## ⚖️ Balance Guidelines

### Aura Power Budget (Level 10)
| Aura Type | Power Budget | Example |
|-----------|--------------|---------|
| **Damage** | 15-20% of total DPS | 15 aura DPS / 95 total DPS = 15.8% |
| **Knockback** | Keep 3+ enemies at bay | 70 force, enough to push back 3 chasers |
| **Heal** | 30-50% of minion max HP/sec | 4 HP/sec on 10 max HP minion = 40%/sec |
| **Collect** | 2x pickup speed | 1.5x at resonance=5, 2.0x at resonance=10 |
| **Slow** | 40-50% slow cap | 45% slow at resonance=15 |
| **Shield** | +3-5 armor bonus | +4 armor at resonance=10 |

### Resonance Investment Strategy
**Low Resonance (0-5)**: Aura is **noticeable** but not build-defining
- Damage: 5-7.5 damage/pulse (quality of life)
- Collect: 1.0-1.5x speed (convenient)

**Medium Resonance (6-15)**: Aura is **impactful**, worth building around
- Damage: 8-12.5 damage/pulse (clears weak enemies)
- Shield: +3.2-5 armor (significant survivability)

**High Resonance (16+)**: Aura is **build-defining**, core strategy
- Damage: 13+ damage/pulse (AOE specialist)
- Slow: 46%+ slow (crowd control master)

---

## 🧪 Testing Strategy

### Unit Tests (Week 7)
```gdscript
# scripts/tests/aura_foundation_test.gd

func test_calculate_aura_power_damage() -> void:
    var power = AuraTypes.calculate_aura_power("damage", 10)
    assert_eq(power, 10.0, "Should be 5 + (10 * 0.5)")

func test_calculate_aura_radius_from_pickup_range() -> void:
    var radius = AuraTypes.calculate_aura_radius(120)
    assert_eq(radius, 120.0, "Radius should match pickup range")

func test_aura_data_persists_in_character() -> void:
    var char_id = CharacterService.create_character("Test", "scavenger")
    var character = CharacterService.get_character(char_id)
    assert_eq(character.aura.type, "collect", "Scavenger should have collect aura")
```

### Integration Tests (Week 8)
```gdscript
# scripts/tests/aura_integration_test.gd

func test_damage_aura_hurts_enemies() -> void:
    # Spawn character with damage aura
    var character = spawn_character_with_aura("damage", 10)

    # Spawn enemy in aura radius
    var enemy = spawn_enemy_at_position(character.position + Vector2(50, 0))

    # Wait for 1 aura pulse (1 second)
    await get_tree().create_timer(1.0).timeout

    # Assert enemy took damage
    assert_lt(enemy.hp, enemy.max_hp, "Enemy should have taken aura damage")
```

---

## 🔗 Related Documentation

- [CHARACTER-STATS-REFERENCE.md](../../core-architecture/CHARACTER-STATS-REFERENCE.md) - Resonance stat definition
- [CHARACTER-SYSTEM.md](./CHARACTER-SYSTEM.md) - Character architecture
- [THE-LAB-SYSTEM.md](./THE-LAB-SYSTEM.md) - Minions (heal aura targets)
- [week7-implementation-plan.md](../../migration/week7-implementation-plan.md) - Implementation timeline
- [character_service.gd](../../../scripts/services/character_service.gd) - Character data storage

---

## ✅ Approval Status

**Approved By**: Alan (2025-01-09)
**Key Decisions**:
- ✅ Auras are **utility-driven**, not pure damage
- ✅ **Resonance** stat drives aura power
- ✅ **Pickup Range** determines aura radius (dual-purpose)
- ✅ Week 7: Simple ColorRect visuals (prototype)
- ✅ Week 8: GPUParticles2D upgrade
- ✅ 6 aura types (damage, knockback, heal, collect, slow, shield)

**Ready for Implementation**: 🚀 Yes (Week 7 foundation)

---

**Document Version**: 1.0
**Last Updated**: 2025-01-09
**Next Review**: After Week 8 full implementation
