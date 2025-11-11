# Week 12 Implementation Plan - Weapon Variety & Pickup Magnets

**Status**: Phase 1 Complete ✅
**Started**: 2025-01-11
**Target Completion**: Phase 2-3 TBD

## Overview

Week 12 expands the combat variety established in Week 11 by adding multiple weapon types with distinct behaviors and implementing a quality-of-life pickup magnet system. This week transforms the combat from single-weapon gameplay into a diverse arsenal with smooth drop collection, significantly improving the survivor-like experience.

## Context

### What We Have (Week 11 Complete)
- ✅ Combat loop fully functional
  - Auto-targeting system targets nearest enemy within weapon range
  - Projectiles hit enemies and deal damage
  - Drops spawn as collectible pickups
  - XP progression with level-ups
  - Wave completion and progression
  - Screen shake and projectile trails for visual polish
- ✅ 4 weapons implemented
  - **Plasma Pistol** (FREE): 10 damage, 0.8s cooldown, 500px range, ranged
  - **Rusty Blade** (FREE): 15 damage, 0.5s cooldown, 50px range, melee
  - **Shock Rifle** (PREMIUM): 20 damage, 1.0s cooldown, 400px range, ranged
  - **Steel Sword** (PREMIUM): 25 damage, 0.6s cooldown, 60px range, melee
- ✅ Drop system functional
  - Drops spawn at enemy death location
  - Player walks over drops to collect
  - Currencies properly tracked (scrap, components, nanites)
  - Visual feedback with bobbing/pulsing animations

### What's Missing
- ❌ **Limited weapon variety**: Only 4 basic weapons, all single-target
- ❌ **No specialized weapon behaviors**: All weapons fire the same way (single projectile)
- ❌ **Manual drop collection**: Player must walk directly over drops
- ❌ **No pickup range stat**: All drops have fixed 80px detection range
- ❌ **No visual feedback for pickup range**: Player can't see magnet radius

### Week 12 Goals
1. Add 6+ new weapons with specialized behaviors (shotgun spread, piercing, area damage)
2. Implement pickup magnet system (drops fly toward player)
3. Add pickup_range stat to character system
4. Create visual indicator for pickup range
5. Balance weapon variety for engaging gameplay

---

## Phase 1: Weapon System Expansion

**Goal**: Add multiple weapon types with unique firing patterns and behaviors inspired by Brotato. Each weapon should feel distinct and encourage different playstyles.

**Important**: Reference [docs/brotato-reference.md](../brotato-reference.md) (lines 140-273) for weapon mechanics, classes, and design patterns that inspired this game.

### Tasks

1. **Add new weapon definitions** (`scripts/services/weapon_service.gd`)
   - Expand `WEAPON_DEFINITIONS` dictionary with 6+ new weapons
   - **Shotgun** (PREMIUM):
     - Multi-projectile spread (5 projectiles in cone)
     - Short range (300px), high damage per projectile (8 each)
     - Medium cooldown (1.2s)
     - Effective at close range, weak at distance
   - **Sniper Rifle** (PREMIUM):
     - Long range (800px), piercing (2 enemies)
     - High damage (35), slow cooldown (2.0s)
     - Rewards precision and positioning
   - **Flamethrower** (PREMIUM):
     - Continuous short-range cone (200px)
     - Low damage per tick (2), ultra-fast cooldown (0.1s)
     - Pierces infinite enemies in cone
     - High ammo consumption (future: ammo system)
   - **Laser Rifle** (PREMIUM):
     - Instant hit (no projectile travel)
     - Long range (600px), medium damage (18)
     - Medium cooldown (0.9s)
   - **Minigun** (SUBSCRIPTION):
     - Rapid fire (0.15s cooldown)
     - Low damage per shot (4), medium range (450px)
     - Spin-up mechanic (slower first 3 shots, then full speed)
   - **Rocket Launcher** (SUBSCRIPTION):
     - Explosive projectiles (50px splash radius)
     - High damage (40 direct, 20 splash)
     - Very slow cooldown (2.5s), long range (700px)
   - **All weapons include**:
     - `range: float` - auto-targeting radius
     - `cooldown: float` - time between shots
     - `projectile_speed: float` - how fast projectiles travel (or null for instant)
     - `damage: float` - base damage per hit
     - `special_behavior: String` - "spread", "pierce", "explosive", "cone", etc.
     - `projectiles_per_shot: int` - default 1, shotgun uses 5
     - `pierce_count: int` - default 0, sniper uses 2
     - `splash_radius: float` - default 0, rocket launcher uses 50

2. **Implement special weapon behaviors** (`scripts/entities/player.gd` and `scenes/game/wasteland.gd`)
   - **Spread pattern (Shotgun)**:
     - Calculate cone spread (-20° to +20° from direction)
     - Spawn N projectiles with spread angles
     - Each projectile independent
   - **Piercing (Sniper, Flamethrower)**:
     - Projectile continues after hit (up to pierce_count)
     - Track enemies_hit array to prevent double-hitting same enemy
     - Implemented in [projectile.gd:157-179](../../scripts/entities/projectile.gd#L157-L179)
   - **Explosive (Rocket Launcher)**:
     - On projectile hit/timeout: query all enemies in splash_radius
     - Deal splash_damage to all enemies in radius
     - Visual explosion effect (scale up ColorRect, fade out)
   - **Cone pattern (Flamethrower)**:
     - Query all enemies in cone (angle + range)
     - Deal damage to all enemies in cone per tick
     - Visual flame particles

3. **Update projectile system** (`scripts/entities/projectile.gd`)
   - Add `splash_damage: float` property for explosive weapons
   - Add `splash_radius: float` property
   - Implement `_explode()` method:
     - Get all enemies in splash_radius
     - Deal splash_damage to each
     - Play explosion visual
   - Existing pierce system already supports multi-hit (lines 157-179)

4. **Balance weapon stats** (iterative tuning)
   - **DPS targets**:
     - Fast weapons (Minigun, Flamethrower): 40-50 DPS
     - Medium weapons (Plasma Pistol, Laser): 25-35 DPS
     - Slow weapons (Sniper, Rocket): 20-30 DPS (burst damage)
     - Shotgun: 33 DPS (5x8 / 1.2s) at close range, ~15 DPS at distance
   - **Range categories**:
     - Short: 200-300px (Flamethrower, Shotgun)
     - Medium: 400-500px (Plasma Pistol, Minigun)
     - Long: 600-800px (Laser, Sniper, Rocket)
   - **Cooldown feel**:
     - Ultra-fast: 0.1-0.15s (Flamethrower, Minigun)
     - Fast: 0.5-0.8s (Rusty Blade, Plasma Pistol)
     - Medium: 0.9-1.2s (Laser, Shotgun)
     - Slow: 1.5-2.5s (Sniper, Rocket)

5. **Reference Brotato weapon mechanics** ([docs/brotato-reference.md](../brotato-reference.md#weapons))
   - **Why**: Brotato is the key inspiration for our weapon variety
   - **Review sections**:
     - **Weapon Data Structure** (lines 144-175): Properties and scaling
       - `damage`, `attack_speed`, `range`, `crit`, `knockback`
       - Weapon classes and tier gating
     - **Notable Ranged Weapons** (lines 241-251): Specific examples
       - Pistol: 12 damage, 1.2s, 400 range, pierce 1 (matches our Plasma Pistol!)
       - SMG: 3 damage, 0.17s (fastest attack speed)
       - Flamethrower: Burning damage, pierce 99
       - Sniper: Spawns 5-8 projectiles on hit (unique mechanic)
       - Nuclear Launcher: Projectiles explode on hit
     - **Melee vs Ranged Mechanics** (lines 252-264):
       - Melee: Hit multiple in area, Thrust/Sweep types
       - Ranged: Single target, can gain Bounce and Piercing
       - Explosive ranged explode per bounce/pierce
   - **Key takeaways for implementation**:
     - Attack speed is weapon-specific (we have this as cooldown)
     - Piercing is a property, not a stat (we implement in projectile.gd)
     - Explosive weapons should affect multiple enemies (splash damage)
     - Range affects auto-targeting (already implemented in Phase 1)
   - **Divergences from Brotato**:
     - Brotato: Weapons have item-like stat bonuses (we separate weapons and items)
     - Brotato: Melee auto-swings in radius (we use targeting service)
     - Brotato: Complex bounce mechanics (we defer to future weeks)

### Success Criteria
- [x] 6+ new weapons with unique behaviors implemented ✅
- [x] Shotgun fires 5-projectile spread pattern ✅ (Scattergun)
- [x] Sniper pierces through 2 enemies ✅ (Dead Eye)
- [x] Rocket Launcher explodes on impact with splash damage ✅ (Boom Tube)
- [x] Flamethrower damages all enemies in cone ✅ (Scorcher with 99 pierce)
- [x] Minigun has spin-up mechanic (slow first shots, then rapid) ✅ (Shredder)
- [x] All weapons balanced for fun and viable gameplay ✅ (DPS targets met)
- [x] Weapon variety encourages different playstyles ✅ (8 distinct weapons)
- [x] Tests verify weapon behaviors ✅ (All 455 tests passing)

### Implementation Notes (Phase 1 Complete - 2025-01-11)
**Weapons Added:**
1. **Scattergun** (shotgun) - 5-projectile spread, 40° cone, 8 dmg/pellet
2. **Dead Eye** (sniper) - Pierce 2 enemies, 50 dmg, 800px range
3. **Boom Tube** (rocket) - 60 direct + 30 splash (50px radius)
4. **Scorcher** (flamethrower) - 0.1s cooldown, 99 pierce, 30° cone
5. **Shredder** (minigun) - 0.15s rapid fire, 2x cooldown first 3 shots
6. **Beam Gun** (laser) - 2000 projectile speed (instant-hit feel), 600px range

**Technical Implementation:**
- Extended `weapon_service.gd` with 6 new weapon definitions
- Added `special_behavior`, `projectiles_per_shot`, `pierce_count`, `splash_damage`, `splash_radius` to all weapons
- Implemented `projectile.gd` splash damage system with `_explode()` method
- Added spread/cone projectile spawning in `wasteland.gd`
- Implemented Shredder spin-up mechanic in `player.gd` with `consecutive_shots` tracking
- Weapon names updated to wasteland theme (Fallout/Mad Max inspired)
- Debug hotkeys (1-8) added for manual QA weapon switching

**Commits:**
- `76cf8b7` - docs: add Week 12 implementation plan
- `63be01b` - docs: mark Week 11 Phase 6 complete
- `0af64ba` - feat: implement Week 11 Phase 6 Camera & Visual Polish
- `9b29966` - refactor: fix code quality warnings
- `e7623fa` - feat: pause game on player death (Week 11 Phase 5)
- `b0c8ff5` - feat: add debug weapon switching hotkeys for manual QA

### Dependencies
- Week 11 Phase 1 (Auto-targeting system)
- Week 11 Phase 2 (Drop collection system)
- [scripts/services/weapon_service.gd](../../scripts/services/weapon_service.gd)
- [scripts/entities/projectile.gd](../../scripts/entities/projectile.gd)

### Testing
```gdscript
# scripts/tests/weapon_variety_test.gd
- test_shotgun_fires_multiple_projectiles()
- test_sniper_pierces_multiple_enemies()
- test_rocket_launcher_explodes_on_impact()
- test_flamethrower_damages_enemies_in_cone()
- test_minigun_spin_up_mechanic()
- test_weapon_dps_targets()

# Brotato reference validation
- Compare weapon DPS to Brotato weapon DPS ([brotato-reference.md:241-251](../brotato-reference.md#L241-L251))
- Verify attack speed/cooldown feels similar (Pistol: 1.2s baseline)
- Check piercing mechanics match Brotato (projectile continues after hit)
- Confirm range values are balanced (400-800px for ranged)

# Manual testing
- Equip each weapon and test feel
- Verify shotgun spread feels powerful at close range
- Confirm sniper rewards precision with high damage
- Test rocket launcher splash damage radius (visible feedback)
- Ensure flamethrower feels continuous and high-DPS
- Check minigun spin-up is noticeable but not frustrating
```

---

## Phase 2: Pickup Magnet System

**Goal**: Drops automatically fly toward the player when within pickup range, significantly improving quality of life and combat flow. This is a core feature of survivor-like games (Vampire Survivors, Brotato) that makes combat feel smooth and rewarding.

**Important**: Reference [docs/game-design/systems/STAT-SYSTEM.md](../game-design/systems/STAT-SYSTEM.md) for stat system architecture. Pickup range should be added as a new utility stat (Stat #21).

### Tasks

1. **Add pickup_range stat** (`scripts/services/stat_service.gd` or character stats)
   - Add `pickup_range: float` to character stats
   - Default value: 80.0 (matches current drop detection range)
   - Scaling: +10 per stat point (additive)
   - Soft cap: None (unlimited, but diminishing returns visually)
   - **Stat sources** (for future phases):
     - Advancement Hall: +10 pickup_range per level
     - Items: Magnet items, scavenger gear
     - Perks: "Scavenger" perk (+50 pickup_range)
     - Character types: Scavenger (+30 pickup_range base)
   - **Add to [docs/game-design/systems/STAT-SYSTEM.md](../game-design/systems/STAT-SYSTEM.md)** as Stat #21:
     ```markdown
     #### 21. Pickup Range
     **What it does:** Radius for automatic drop magnetism
     **Base value:** 80
     **Scaling:** Additive (+10 per point)
     **Soft cap:** None (unlimited)

     **Brotato comparison:**
     ⚠️ Brotato does not have pickup range stat (manual collection)
     🟢 UNIQUE TO SCRAP SURVIVOR - Major QoL improvement!

     **Sources:**
     - Advancement Hall: +10 Pickup Range per level
     - Items: Magnet items, scavenger gear
     - Perks: "Scavenger" perk (+50 Pickup Range)
     - Character types: Scavenger (+30 Pickup Range base)
     ```

2. **Implement magnet behavior** (`scripts/entities/drop_pickup.gd`)
   - Add `_physics_process(delta: float)` method
   - Check if player within magnet_range
     - Get player position: `get_tree().get_first_node_in_group("player")`
     - Calculate distance: `global_position.distance_to(player.global_position)`
     - If distance <= magnet_range:
       - Calculate direction to player
       - Move toward player at magnet_speed (200 px/s base)
       - Accelerate as gets closer (1 + (1 - distance/magnet_range) * 2)
   - Existing collection happens on body_entered (already implemented)

3. **Update drop pickup properties** (`scripts/entities/drop_pickup.gd`)
   - Change `magnet_range` to be player-stat-based (query from player)
   - Add `magnet_speed: float = 200.0` - how fast drops fly toward player
   - Add `is_magnetized: bool = false` - tracking state for visual feedback
   - Update magnet_range from player stats:
     ```gdscript
     func _physics_process(delta: float) -> void:
         var player = get_tree().get_first_node_in_group("player")
         if not player:
             return

         # Get player's pickup_range stat
         var player_pickup_range = player.get_stat("pickup_range")
         if player_pickup_range <= 0:
             player_pickup_range = magnet_range  # Fallback to default

         var distance = global_position.distance_to(player.global_position)

         if distance <= player_pickup_range:
             # Fly toward player
             is_magnetized = true
             var direction = (player.global_position - global_position).normalized()
             var speed_multiplier = 1.0 + (1.0 - distance / player_pickup_range) * 2.0
             var velocity = direction * magnet_speed * speed_multiplier
             global_position += velocity * delta
         else:
             is_magnetized = false
     ```

4. **Add visual feedback for pickup range** (`scenes/entities/player.tscn` or runtime spawn)
   - Create `PickupRangeIndicator` as Line2D circle
   - Parent to player, draw circle at pickup_range radius
   - Visual properties:
     - Line width: 2.0
     - Color: Color(0.5, 1.0, 0.5, 0.3) - semi-transparent green
     - Z-index: -1 (below player and enemies)
   - Update radius when pickup_range stat changes
   - Toggle visibility with debug key (optional: 'P' key)

5. **Add magnetized visual feedback** (`scripts/entities/drop_pickup.gd`)
   - When `is_magnetized = true`:
     - Add trail effect (Line2D following drop position)
     - Pulse scale faster (breathing effect intensifies)
     - Add glow effect (modulate color brighter)
   - Example:
     ```gdscript
     func _update_magnetized_visual() -> void:
         if is_magnetized:
             # Brighter color
             modulate = Color(1.2, 1.2, 1.2, 1.0)
             # Faster pulsing (handled in existing tween)
         else:
             modulate = Color(1.0, 1.0, 1.0, 1.0)
     ```

6. **Balance magnet parameters**
   - Default pickup_range: 80px (matches current detection)
   - Magnet speed: 200 px/s base (should feel snappy)
   - Acceleration multiplier: 1-3x (faster as closer)
   - Drop collection feels satisfying without being too "vacuum-like"
   - Test with varying player movement speeds
   - Ensure drops don't overshoot player or jitter

### Success Criteria
- [ ] Drops fly toward player when within pickup_range
- [ ] pickup_range stat integrated into character system
- [ ] Visual indicator shows pickup range radius
- [ ] Magnetized drops have visual feedback (glow, trail)
- [ ] Magnet speed feels snappy and satisfying
- [ ] Collection still requires drops to reach player (not instant teleport)
- [ ] Performance remains smooth with 20+ active drops

### Dependencies
- Week 11 Phase 2 (Drop collection system)
- Week 11 Phase 3 (Character stats and progression)
- [scripts/entities/drop_pickup.gd](../../scripts/entities/drop_pickup.gd)
- [scripts/entities/player.gd](../../scripts/entities/player.gd)

### Testing
```gdscript
# Manual testing (visual system, hard to unit test)
- Stand still with default pickup_range (80px)
- See drops within 80px fly toward player
- Drops outside 80px remain stationary until player approaches
- Move toward drops: magnetism activates as they enter range
- Collect multiple drops simultaneously (stress test)
- Verify visual indicator shows correct radius
- Toggle pickup range indicator on/off (debug key)
- Test with increased pickup_range stat (simulate stat boost)
```

---

## Phase 3: Character Stats Integration

**Goal**: Wire pickup_range stat into the character stat system so it can be leveled up, modified by items, and displayed in the HUD.

### Tasks

1. **Add pickup_range to CharacterService** (`scripts/services/character_service.gd`)
   - Add `pickup_range: int = 80` to base character stats
   - Default value matches drop_pickup.gd's magnet_range
   - Ensure stat persists across saves/loads
   - Add to stat modification methods

2. **Update Player stat queries** (`scripts/entities/player.gd`)
   - Implement `get_stat("pickup_range")` query
   - Return value from character stats
   - Cache value for performance (update on stat change signal)

3. **Add pickup_range to HUD display** (optional, future phase)
   - Show pickup_range value in character stats panel
   - Visual indicator updates dynamically with stat changes

### Success Criteria
- [ ] pickup_range stat stored in character data
- [ ] Player can query pickup_range stat
- [ ] Stat persists across save/load
- [ ] Stat modifies magnet behavior in real-time

### Dependencies
- Week 9 Phase 2 (CharacterService)
- Phase 2 (Pickup magnet system)

### Testing
```gdscript
# scripts/tests/character_service_test.gd (add new tests)
- test_character_has_pickup_range_stat()
- test_pickup_range_defaults_to_80()
- test_modify_pickup_range_stat()
- test_pickup_range_persists_on_save_load()

# Manual testing
- Create character, check default pickup_range (80)
- Modify pickup_range via CharacterService
- Verify magnet behavior changes (larger/smaller radius)
- Save game, reload, verify pickup_range persists
```

---

## Success Criteria (Overall Week 12)

### Must Have
- [ ] 6+ new weapons with unique behaviors (shotgun, sniper, rocket, flamethrower, minigun, laser)
- [ ] Shotgun fires spread pattern (5 projectiles)
- [ ] Sniper pierces enemies (2 pierce count)
- [ ] Rocket explodes with splash damage (50px radius)
- [ ] Pickup magnet system functional (drops fly toward player)
- [ ] pickup_range stat integrated into character system
- [ ] Visual indicator for pickup range

### Should Have
- [ ] Flamethrower continuous cone damage
- [ ] Minigun spin-up mechanic (slower first shots)
- [ ] Magnetized drops have visual feedback (glow, trail)
- [ ] Weapon variety balanced for fun gameplay
- [ ] All weapons feel distinct and viable

### Nice to Have
- [ ] Laser rifle instant-hit mechanic (no projectile)
- [ ] Pickup range indicator toggle (debug key)
- [ ] Weapon unlock progression system (defer to Week 13)
- [ ] Advanced projectile physics (bounce, ricochet - defer to future)

---

## Testing Strategy

### Running Tests

**Automated Tests (GUT Framework)**:
```bash
# Run all tests via proper test runner (ALWAYS use this)
python3 .system/validators/godot_test_runner.py

# This runner handles:
# - Scanning project to register custom classes
# - Running GUT tests in headless mode with autoload services
# - Caching results for fast verification when Godot is open
```

**Location**: Test runner is at `.system/validators/godot_test_runner.py`

**DO NOT** run tests directly via godot CLI or test_runner.gd - use the Python runner above.

### Unit Tests
- WeaponService: Weapon definitions, special behaviors
- Projectile: Piercing, explosion mechanics
- DropPickup: Magnet behavior, range calculations

### Integration Tests
- Weapon variety: Each weapon fires correctly with unique behavior
- Pickup magnets: Drops fly toward player within range
- Stat integration: pickup_range stat modifies magnet behavior

### Manual Testing
- Play through 3 waves with each weapon type
- Verify shotgun spread feels powerful
- Confirm sniper piercing works correctly
- Test rocket launcher splash damage visually
- Check flamethrower continuous damage
- Verify pickup magnets feel smooth and satisfying
- Test with varying pickup_range values

---

## Migration Notes

### Breaking Changes
None expected. All changes are additive.

### Godot 4.x Considerations
- Area2D queries for enemies in splash radius (rocket launcher)
- Physics queries for cone detection (flamethrower)
- Line2D for pickup range indicator
- Tween API for magnetized drop effects

### Performance
- **Weapon variety**:
  - Shotgun: 5 projectiles per shot (5x projectile count)
  - Flamethrower: Query enemies in cone every frame (optimize with spatial partitioning if > 50 enemies)
  - Rocket launcher: Query enemies in splash radius on explosion (one-time cost)
- **Pickup magnets**:
  - `_physics_process` on all active drops (up to ~20)
  - Distance calculation per drop per frame
  - Negligible performance impact (< 1ms total)
  - Use spatial partitioning if > 100 active drops (unlikely)

**Optimization Strategy**:
- Cache player reference (don't query tree every frame)
- Use squared distance for comparisons (avoid sqrt)
- Cull drops outside viewport (don't process physics)

---

## Rollback Plan

If Week 12 blocked:
1. Revert to Week 11 (commit: `63be01b`)
2. Combat still functional with 4 weapons
3. Manual drop collection still works
4. Can iterate on weapon variety separately from magnets

---

## Dependencies

### Code Dependencies
- `WeaponService`: Weapon definitions and firing logic
- `Projectile`: Projectile physics, piercing, explosion
- `DropPickup`: Magnet behavior, player tracking
- `CharacterService`: pickup_range stat storage
- `Player`: Stat queries, pickup_range getter

### Asset Dependencies
- Weapon sprites (can use ColorRect placeholders)
- Explosion effect (can use scale-up ColorRect)
- Flame particles (can use Line2D or simple sprite)
- Pickup range indicator (Line2D circle, built-in)

---

## Documentation Dependencies

**Must Read Before Implementation**:
1. [docs/brotato-reference.md](../brotato-reference.md) - Weapon mechanics, design patterns (lines 140-273)
2. [docs/game-design/systems/STAT-SYSTEM.md](../game-design/systems/STAT-SYSTEM.md) - Stat system architecture
3. [docs/GAME-DESIGN.md](../GAME-DESIGN.md) - General game design reference
4. [docs/migration/week11-implementation-plan.md](week11-implementation-plan.md) - Context from previous week

**Reference During Implementation**:
- [docs/godot-community-research.md](../godot-community-research.md) - Best practices
- [docs/godot-performance-patterns.md](../godot-performance-patterns.md) - Optimization patterns
- [docs/godot-testing-research.md](../godot-testing-research.md) - Testing patterns

---

## Timeline Estimate

**Phase 1 (Weapon Variety)**: 3-4 hours
- Weapon definitions: 1 hour
- Special behaviors (spread, pierce, explosive): 1.5 hours
- Balance tuning: 1 hour
- Testing: 30 min

**Phase 2 (Pickup Magnets)**: 2-3 hours
- Magnet behavior: 1 hour
- Visual feedback: 30 min
- Pickup range indicator: 30 min
- Balance tuning: 30 min
- Testing: 30 min

**Phase 3 (Stat Integration)**: 1-2 hours
- CharacterService integration: 30 min
- Player stat queries: 30 min
- Testing: 30 min

**Total**: 6-9 hours (1-1.5 work days)

---

## Next Steps (Week 13 Preview)

Potential Week 13 focus areas:
- **Weapon unlocks and progression**: Unlock new weapons as you level up
- **Weapon upgrades**: Increase damage, fire rate, add modifiers
- **More enemy types**: Ranged enemies, tanks, fast enemies, bosses
- **Item system expansion**: Items that modify weapons and stats
- **Wave difficulty scaling**: Increase challenge over time
- **Advanced combat mechanics**: Dodge roll, shields, consumables
- **Save/load progress**: Persist unlocks and progression between sessions

**Recommendation**: Weapon unlocks would be a natural next step, building on the weapon variety from Week 12!
