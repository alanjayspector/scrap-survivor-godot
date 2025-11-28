# Week 9 Implementation Plan: Combat System Foundation

**Status**: 📋 Ready to Implement
**Approved**: 2025-01-10
**Est. Duration**: 5 days (12 hours dev time)
**Dependencies**: Week 8 Character System (✅ Complete - 313/313 tests passing)
**Foundation**: ✅ **Verified via Playable Demo** (see [DEMO-INSTRUCTIONS.md](../../DEMO-INSTRUCTIONS.md))

---

## ✅ Pre-Week 9 Verification Complete

Before beginning Week 9, the character system foundation was proven via:
- ✅ **313/313 tests passing** with 0 warnings
- ✅ **Playable demo** showing CharacterService integration
- ✅ **All 4 character types** functional with stats, auras, and movement
- ✅ **Comprehensive audit** confirming code quality (see [WEEK9-CODEBASE-AUDIT.md](../../WEEK9-CODEBASE-AUDIT.md))

**Known Limitation**: 95 resource tests still pending (require Godot Editor GUI, not headless CI).
These test weapon/enemy/item resource file loading and will be validated manually in editor.

---

## 📊 Executive Summary

Week 9 implements the core combat loop:
- **Weapon system** with melee + ranged types
- **Enemy spawning** with wave-based progression
- **Collision detection** (weapons vs enemies, auras vs enemies)
- **Damage calculation** with character stats integration
- **Drop system** for XP and currency

**Key Decision**: Combat will integrate all character stats (attack_speed, melee_damage, ranged_damage, resonance) and test the complete progression loop (kill → XP → level up → stronger → repeat).

---

## 🎯 Goals & Success Metrics

### Product Goals
1. **Complete combat loop** - Spawn enemies, deal damage, collect drops
2. **Validate stat system** - Attack speed, melee/ranged damage bonuses work
3. **Test aura mechanics** - Damage aura affects enemies, collect aura gets drops
4. **Verify progression** - Character levels up from combat

### Technical Goals
1. **Weapon service** - CRUD, firing, cooldowns, attack speed integration
2. **Enemy service** - Spawning, health, death, AI
3. **Combat service** - Damage calculation with stat modifiers
4. **Wave service** - Progressive difficulty scaling
5. **Drop system** - XP and currency with scavenging multiplier

### Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| All existing tests pass | 313/313 | GUT test suite |
| New weapon tests | 20+ passing | GUT test suite |
| New enemy tests | 15+ passing | GUT test suite |
| Combat integration tests | 10+ passing | GUT test suite |
| Manual QA (combat loop) | 60 FPS @ 50 enemies | Performance test |
| Drop system accuracy | 100% | Scavenging multiplier validation |

---

## 📋 Phase Breakdown

### **Phase 1: Weapon System** (Days 1-2, ~4 hours)

#### Weapon Data Structure
```gdscript
# scripts/services/weapon_service.gd
extends Node

enum WeaponType { MELEE, RANGED }

const WEAPON_DEFINITIONS = {
    "rusty_blade": {
        "display_name": "Rusty Blade",
        "type": WeaponType.MELEE,
        "base_damage": 15,
        "cooldown": 0.5,  # 2 attacks per second
        "range": 50,      # Melee range (pixels)
        "projectile": null,
        "tier_required": UserTier.FREE
    },
    "plasma_pistol": {
        "display_name": "Plasma Pistol",
        "type": WeaponType.RANGED,
        "base_damage": 10,
        "cooldown": 0.8,  # 1.25 attacks per second
        "range": 300,     # Projectile range
        "projectile": "plasma_bolt",
        "projectile_speed": 400,
        "tier_required": UserTier.FREE
    }
}
```

#### Weapon Service Methods
```gdscript
func equip_weapon(character_id: String, weapon_id: String) -> bool
func get_weapon_damage(weapon_id: String, character_stats: Dictionary) -> float
func get_weapon_cooldown(weapon_id: String, attack_speed: float) -> float
func can_fire_weapon(weapon_id: String) -> bool
func fire_weapon(weapon_id: String, position: Vector2, direction: Vector2) -> void
```

#### Attack Speed Integration
```gdscript
# attack_speed stat reduces cooldown
# Example: attack_speed = 15 → 15% cooldown reduction
# Base cooldown: 0.8s → Actual cooldown: 0.8 * (1 - 0.15) = 0.68s

func get_weapon_cooldown(weapon_id: String, attack_speed: float) -> float:
    var weapon_def = WEAPON_DEFINITIONS[weapon_id]
    var base_cooldown = weapon_def.cooldown
    var reduction = clamp(attack_speed / 100.0, 0.0, 0.75)  # Cap at 75% reduction
    return base_cooldown * (1.0 - reduction)
```

#### Test Coverage
```gdscript
# scripts/tests/weapon_service_test.gd
- test_equip_weapon_success()
- test_equip_weapon_with_tier_restriction()
- test_get_weapon_damage_with_melee_bonus()
- test_get_weapon_damage_with_ranged_bonus()
- test_attack_speed_reduces_cooldown()
- test_attack_speed_caps_at_75_percent()
- test_can_fire_weapon_respects_cooldown()
- test_fire_melee_weapon_creates_hitbox()
- test_fire_ranged_weapon_creates_projectile()
# ... 11 more tests (20 total)
```

---

### **Phase 2: Enemy System** (Days 2-3, ~3 hours)

#### Enemy Data Structure
```gdscript
# scripts/services/enemy_service.gd
extends Node

const ENEMY_TYPES = {
    "scrap_bot": {
        "display_name": "Scrap Bot",
        "base_hp": 50,
        "base_damage": 5,
        "speed": 80,
        "xp_reward": 10,
        "drop_table": {
            "scrap": { "min": 1, "max": 3, "chance": 0.8 },
            "components": { "min": 0, "max": 1, "chance": 0.2 }
        }
    },
    "mutant_rat": {
        "display_name": "Mutant Rat",
        "base_hp": 30,
        "base_damage": 8,
        "speed": 120,  # Faster, lower HP
        "xp_reward": 8,
        "drop_table": {
            "scrap": { "min": 1, "max": 2, "chance": 0.6 },
            "nanites": { "min": 1, "max": 1, "chance": 0.1 }
        }
    }
}
```

#### Enemy Service Methods
```gdscript
func spawn_enemy(enemy_type: String, position: Vector2) -> String  # Returns enemy_id
func get_enemy(enemy_id: String) -> Dictionary
func damage_enemy(enemy_id: String, damage: float) -> bool  # Returns true if killed
func kill_enemy(enemy_id: String) -> Dictionary  # Returns drop data
func update_enemy_ai(delta: float) -> void  # Move enemies toward player
```

#### Wave Scaling
```gdscript
# scripts/services/wave_service.gd
func get_enemy_count_for_wave(wave: int) -> int:
    return 5 + (wave * 3)  # Wave 1 = 8 enemies, Wave 2 = 11, Wave 3 = 14

func get_enemy_hp_multiplier(wave: int) -> float:
    return 1.0 + (wave * 0.15)  # Wave 1 = 1.0x, Wave 2 = 1.15x, Wave 5 = 1.75x

func get_spawn_rate(wave: int) -> float:
    return max(2.0 - (wave * 0.1), 0.5)  # Faster spawns each wave (min 0.5s)
```

#### Test Coverage
```gdscript
# scripts/tests/enemy_service_test.gd
- test_spawn_enemy_creates_valid_enemy()
- test_damage_enemy_reduces_hp()
- test_damage_enemy_returns_true_when_killed()
- test_kill_enemy_generates_drops()
- test_enemy_ai_moves_toward_player()
- test_wave_scaling_increases_enemy_count()
- test_wave_scaling_increases_enemy_hp()
# ... 8 more tests (15 total)
```

---

### **Phase 3: Combat Integration** (Days 3-4, ~3 hours)

#### Damage Calculation
```gdscript
# scripts/services/combat_service.gd
extends Node

func calculate_damage(weapon_id: String, character_stats: Dictionary) -> float:
    var weapon = WeaponService.WEAPON_DEFINITIONS[weapon_id]
    var base_damage = weapon.base_damage
    var character_damage = character_stats.damage

    # Apply weapon type bonus
    var bonus_damage = 0.0
    if weapon.type == WeaponService.WeaponType.MELEE:
        bonus_damage = character_stats.melee_damage
    elif weapon.type == WeaponService.WeaponType.RANGED:
        bonus_damage = character_stats.ranged_damage

    # Total damage = (base weapon + character damage + type bonus)
    return base_damage + character_damage + bonus_damage

func apply_damage_to_enemy(enemy_id: String, damage: float) -> Dictionary:
    # Returns { "killed": bool, "remaining_hp": float }
    var enemy = EnemyService.get_enemy(enemy_id)
    var killed = EnemyService.damage_enemy(enemy_id, damage)

    if killed:
        var drops = EnemyService.kill_enemy(enemy_id)
        return { "killed": true, "drops": drops }

    return { "killed": false, "remaining_hp": enemy.current_hp }
```

#### Aura Damage Integration
```gdscript
func calculate_aura_damage(character_stats: Dictionary) -> float:
    var resonance = character_stats.resonance
    return AuraTypes.calculate_aura_power("damage", resonance)

func apply_aura_damage_to_nearby_enemies(character_pos: Vector2, aura_radius: float, damage: float) -> Array:
    # Find enemies within aura radius
    var enemies_in_range = EnemyService.get_enemies_in_radius(character_pos, aura_radius)
    var damaged_enemies = []

    for enemy_id in enemies_in_range:
        var result = apply_damage_to_enemy(enemy_id, damage)
        damaged_enemies.append({ "enemy_id": enemy_id, "result": result })

    return damaged_enemies
```

#### Collision Detection
```gdscript
# scripts/components/weapon_hitbox.gd
extends Area2D

signal enemy_hit(enemy_id: String)

var damage: float = 10.0
var hit_enemies: Array = []  # Track to prevent multi-hit

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("enemies"):
        var enemy_id = area.get_meta("enemy_id")

        # Prevent multi-hit from same weapon swing
        if enemy_id in hit_enemies:
            return

        hit_enemies.append(enemy_id)
        enemy_hit.emit(enemy_id)
```

#### Test Coverage
```gdscript
# scripts/tests/combat_service_test.gd
- test_calculate_damage_includes_character_stats()
- test_calculate_damage_adds_melee_bonus()
- test_calculate_damage_adds_ranged_bonus()
- test_apply_damage_to_enemy_reduces_hp()
- test_apply_damage_to_enemy_returns_drops_when_killed()
- test_calculate_aura_damage_scales_with_resonance()
- test_apply_aura_damage_to_nearby_enemies()
- test_weapon_hitbox_prevents_multi_hit()
# ... 2 more tests (10 total)
```

---

### **Phase 4: Drop System** (Day 4-5, ~2 hours)

#### Drop Generation
```gdscript
# scripts/services/drop_system.gd
extends Node

func generate_drops(enemy_type: String, character_scavenging: int) -> Dictionary:
    var enemy_def = EnemyService.ENEMY_TYPES[enemy_type]
    var drops = {}

    # Calculate scavenging multiplier (cap at +50%)
    var scavenge_mult = 1.0 + min(character_scavenging / 100.0, 0.5)

    # Roll each drop in the drop table
    for currency in enemy_def.drop_table.keys():
        var drop_def = enemy_def.drop_table[currency]

        # Check if drop occurs (chance)
        if randf() <= drop_def.chance:
            var amount = randi_range(drop_def.min, drop_def.max)
            var final_amount = int(amount * scavenge_mult)
            drops[currency] = final_amount

    return drops

func spawn_drop_pickups(drops: Dictionary, position: Vector2) -> void:
    # Create visual pickups at enemy death location
    for currency in drops.keys():
        var amount = drops[currency]
        _create_pickup(currency, amount, position)
```

#### Auto-Collect Aura Integration
```gdscript
func collect_drops_in_aura(character_pos: Vector2, aura_radius: float, character_id: String) -> Dictionary:
    var pickups_in_range = get_pickups_in_radius(character_pos, aura_radius)
    var collected = {}

    for pickup in pickups_in_range:
        var currency = pickup.currency_type
        var amount = pickup.amount

        # Add to character's currency
        if not collected.has(currency):
            collected[currency] = 0
        collected[currency] += amount

        # Remove pickup from world
        pickup.queue_free()

    return collected
```

#### XP Award System
```gdscript
func award_xp_for_kill(character_id: String, enemy_type: String) -> bool:
    var enemy_def = EnemyService.ENEMY_TYPES[enemy_type]
    var xp_reward = enemy_def.xp_reward

    # Award XP to character (may trigger level up)
    var leveled_up = CharacterService.add_experience(character_id, xp_reward)

    if leveled_up:
        GameLogger.info("Character leveled up from kill", {
            "character_id": character_id,
            "enemy_type": enemy_type
        })

    return leveled_up
```

#### Test Coverage
```gdscript
# scripts/tests/drop_system_test.gd
- test_generate_drops_returns_valid_currency()
- test_scavenging_multiplies_drop_amounts()
- test_scavenging_caps_at_50_percent()
- test_spawn_drop_pickups_creates_visual_nodes()
- test_collect_drops_in_aura_removes_pickups()
- test_award_xp_for_kill_grants_xp()
- test_award_xp_for_kill_triggers_level_up()
# ... 3 more tests (10 total)
```

---

## 🧪 Testing Strategy

### Test File Organization
```
scripts/tests/
├── character_service_test.gd           (✅ Existing - 43 tests)
├── character_types_test.gd             (✅ Existing - 20 tests)
├── aura_foundation_test.gd             (✅ Existing - 20 tests)
├── weapon_service_test.gd              (🆕 Week 9 - 20 tests)
├── enemy_service_test.gd               (🆕 Week 9 - 15 tests)
├── combat_service_test.gd              (🆕 Week 9 - 10 tests)
└── drop_system_test.gd                 (🆕 Week 9 - 10 tests)

Total Week 9: 368 tests (313 existing + 55 new)
```

### Test Execution
```bash
# Run all tests
python3 .system/validators/godot_test_runner.py

# Expected output:
# Tests: 368
# Passing: 368
# Failing: 0
```

### Manual QA Checklist
- [ ] Equip weapon and attack enemy (health decreases)
- [ ] Kill enemy and see drop spawn
- [ ] Character levels up from XP (stats increase)
- [ ] Attack speed stat reduces weapon cooldown (visible in combat)
- [ ] Melee/ranged damage bonuses apply (higher damage numbers)
- [ ] Scavenging stat increases currency drops (more scrap/components)
- [ ] Mutant's damage aura kills nearby enemies
- [ ] Scavenger's collect aura auto-collects drops
- [ ] Performance: 60 FPS with 50 enemies + 100 projectiles

---

## 📈 Timeline & Dependencies

### Week 8 (✅ Complete)
- Character system with 4 types
- Aura visuals with GPUParticles2D
- Character selection UI
- Conversion flow

### Week 9 (Current Plan)
- **Day 1-2**: Weapon system (4 hours)
- **Day 2-3**: Enemy system (3 hours)
- **Day 3-4**: Combat integration (3 hours)
- **Day 4-5**: Drop system (2 hours)

**Total**: ~12 hours across 5 days

### Week 10 (Next Steps)
- Scene integration (player, enemies, projectiles in Wasteland scene)
- Input handling (mouse aiming, auto-fire)
- Camera follow system
- HUD (HP bar, wave counter, XP bar)
- Wave completion screen

---

## 🔗 Related Documentation

### Architecture
- [godot-service-architecture.md](../godot-service-architecture.md)
- [CHARACTER-SYSTEM.md](../game-design/systems/CHARACTER-SYSTEM.md)

### Previous Weeks
- [week8-completion.md](./week8-completion.md)
- [week7-implementation-plan.md](./week7-implementation-plan.md)

---

## ✅ Approval Status

**Approved By**: Alan (2025-01-10)
**Approved Decisions**:
- ✅ Attack speed reduces cooldown (cap 75%)
- ✅ Melee/ranged damage bonuses are additive
- ✅ Scavenging multiplies currency drops (cap +50%)
- ✅ Aura damage uses resonance stat
- ✅ Wave scaling: +3 enemies, +15% HP per wave

**Ready to Implement**: 🚀 Yes

---

**Document Version**: 1.0
**Last Updated**: 2025-01-10
**Next Review**: After Week 9 Day 3 (combat integration complete)
