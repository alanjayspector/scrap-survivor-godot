# Week 11 Implementation Plan - Combat Polish & Auto-Targeting

**Status**: Planning
**Started**: 2025-11-11
**Target Completion**: TBD

## Overview

Week 11 focuses on polishing the combat loop established in Week 10 by adding auto-targeting for weapons, implementing drop collection, and enhancing player progression. This week transforms the basic combat into a more engaging survivor-like experience.

## Context

### What We Have (Week 10 Complete)
- ✅ Basic combat loop functional
  - Player movement with WASD
  - Weapon firing in player's facing direction
  - Enemies spawn in waves, chase player, deal contact damage
  - Projectiles hit enemies and deal damage
  - Wave progression with "Next Wave" screen
  - Game over screen on death with retry/menu options
- ✅ Core systems integrated
  - WaveManager spawns enemies at scaled difficulty
  - HUD displays HP, XP, wave, currencies
  - DropSystem generates drops on enemy death
  - CharacterService tracks character stats
  - **WeaponService supports multiple equipped weapons**
    - Each weapon has independent cooldown timer
    - Each weapon has unique range, speed, damage
    - Player can equip multiple weapons simultaneously (Vampire Survivors style)

### What's Missing
- ❌ **Auto-targeting**: Weapons fire in facing direction, not at nearest enemy
- ❌ **Drop collection**: Drops spawn but aren't collectible pickups
- ❌ **XP progression**: XP awarded but no level-up or stat increases
- ❌ **Enemy kill tracking**: `total_kills` variable exists but never incremented
- ❌ **Wave completion logic**: Enemies die but wave doesn't detect completion

### Week 11 Goals
1. Implement auto-targeting system for weapons
2. Make drops collectible with visual pickups
3. Wire up XP progression with level-ups
4. Track kills and complete waves properly
5. Add camera smoothing and screen shake

---

## Phase 1: Auto-Targeting System

**Goal**: Weapons automatically target the nearest enemy within range instead of firing in facing direction. Each weapon independently targets based on its own range and fire rate.

**Important**: Players can equip **multiple weapons simultaneously** (like Vampire Survivors). Each weapon fires independently with its own cooldown, range, and targeting.

### Tasks

1. **Create TargetingService** (`scripts/services/targeting_service.gd`)
   - Singleton autoload service
   - `get_nearest_enemy(position: Vector2, max_range: float) -> Enemy`
     - Queries all enemies in "enemies" group
     - Filters by distance and alive status
     - Returns closest enemy or null
   - `get_enemies_in_radius(position: Vector2, radius: float) -> Array[Enemy]`
     - For future area weapons (shotgun spread, explosions)
   - Add tests in `scripts/tests/targeting_service_test.gd`

2. **Update Player weapon firing** (`scripts/entities/player.gd`)
   - In `_fire_weapon(weapon_id: String)`:
     - **Each weapon calls this independently** based on its own cooldown timer
     - Get weapon range from `WeaponService.get_weapon(weapon_id)`
     - Call `TargetingService.get_nearest_enemy(global_position, weapon_range)`
     - If enemy found: calculate direction to enemy
     - If no enemy: fire in current facing direction (fallback)
     - Emit `weapon_fired` with calculated direction
   - Keep facing direction logic for player sprite orientation
   - **Note**: Multiple weapons may fire at different targets simultaneously

3. **Update weapon definitions** (`scripts/services/weapon_service.gd`)
   - Ensure **all weapons** have `range` property
   - Balance ranges by weapon type:
     - `plasma_pistol`: 500px (medium range, medium speed)
     - Short-range weapons (future): 300px (fast fire rate)
     - Long-range weapons (future): 800px (slow fire rate)
     - Area weapons (future): 200px (no targeting, hits all in radius)
   - **Each weapon definition includes**:
     - `range: float` - auto-targeting detection radius
     - `cooldown: float` - time between shots
     - `projectile_speed: float` - how fast projectiles travel
     - `damage: float` - base damage per hit

4. **Visual feedback** (optional, nice-to-have)
   - Add targeting reticle/indicator per weapon
   - Shows which enemy each weapon is currently targeting
   - Different colors for multiple simultaneous targets

5. **Reference Brotato combat mechanics** (`docs/brotato-reference.md`)
   - **Why**: Brotato is a key inspiration for our survivor-like combat
   - **Review sections**:
     - **Weapons** (lines 140-400): Weapon data structure, properties
       - `range`: Projectile travel distance (pixels)
       - `attack_speed`: Cooldown between shots
       - `damage`, `crit`, `knockback`, `lifesteal` properties
       - Weapon scaling with character stats
     - **Game Mechanics - Player Stats** (lines 543-568):
       - Attack Speed: Cooldown reduction %, minimum 0.75s cap
       - Range: Affects projectile travel distance
       - Multiple weapons fire independently with own cooldowns
     - **Wave System** (lines 518-542): Timing and difficulty scaling
   - **Key takeaways for implementation**:
     - Each weapon has independent range for targeting
     - Attack speed affects cooldown, not movement
     - Range stat can be modified by character/items (future)
     - Weapons auto-target in Brotato (no manual aiming)
   - **Divergences from Brotato**:
     - Brotato: Up to 6 weapons, we may differ
     - Brotato: Melee has auto-swing radius, we use projectiles for all
     - Brotato: Complex stat scaling system, we keep simpler for MVP

### Success Criteria
- [x] Each weapon independently targets nearest enemy within **its own range**
- [x] Multiple weapons can fire at different targets simultaneously
- [x] Weapon with 500px range targets enemies up to 500px away
- [x] Weapon with 300px range only targets enemies within 300px
- [x] Player sprite still faces movement direction (not weapon targets)
- [x] Projectiles travel toward targeted enemy position
- [x] Falls back to facing direction when no enemies in range for that weapon
- [x] Tests verify targeting logic for various ranges

### Dependencies
- Week 10 Phase 2 (Player, Enemy entities)
- Week 10 Phase 4 (Wave spawning)

### Testing
```gdscript
# scripts/tests/targeting_service_test.gd
- test_get_nearest_enemy_returns_closest()
- test_get_nearest_enemy_excludes_dead_enemies()
- test_get_nearest_enemy_filters_by_range()
- test_get_nearest_enemy_returns_null_when_none_in_range()

# Brotato reference validation
- Compare implemented ranges to Brotato weapon ranges (docs/brotato-reference.md)
- Verify attack speed/cooldown behavior matches Brotato mechanics
- Check auto-targeting feels similar to Brotato (no manual aiming)
- Confirm multiple weapons fire independently like Brotato

# Manual testing
- Create character, start wave
- **Single weapon (plasma_pistol)**:
  - Stand still: weapon fires at approaching enemies
  - Move in circles: weapon fires at enemies, player faces movement direction
  - Kill all enemies: weapon fires in facing direction as fallback
- **Multiple weapons** (when implemented):
  - Equip 2+ weapons with different ranges
  - Observe weapons targeting different enemies based on range
  - Fast weapon fires more frequently than slow weapon
  - Each weapon independently tracks cooldown and targets
```

---

## Phase 2: Drop Collection System

**Goal**: Enemy drops spawn as collectible pickups that player can walk over to collect.

### Tasks

1. **Create drop pickup scene** (`scenes/entities/drop_pickup.tscn`)
   - Root: Area2D with `class_name DropPickup`
   - CollisionShape2D (circle radius 8px for pickup range)
   - Sprite2D (use ColorRect for now, different colors per currency)
     - Scrap: Brown
     - Components: Blue
     - Nanites: Purple
   - Script: `scripts/entities/drop_pickup.gd`

2. **Implement DropPickup script** (`scripts/entities/drop_pickup.gd`)
   - Properties:
     - `currency_type: String` (scrap, components, nanites)
     - `amount: int`
     - `magnet_range: float = 80.0` (pickup range affected by player stat)
   - Signals:
     - `collected(currency_type: String, amount: int)`
   - Methods:
     - `setup(type: String, amt: int) -> void`
     - `_on_area_entered(area: Area2D) -> void` - detect player
     - `_on_body_entered(body: Node2D) -> void` - detect player (CharacterBody2D)
     - `collect() -> void` - play animation, emit signal, queue_free

3. **Update DropSystem** (`scripts/systems/drop_system.gd`)
   - Modify `spawn_drop_pickups()`:
     - Currently just generates drop data
     - Change to instantiate DropPickup scenes
     - Position at death location with random offset (spread drops)
     - Connect `collected` signal to `_on_drop_collected()`
   - Add `_on_drop_collected(currency: String, amount: int)`:
     - Call `BankingService.add_currency(currency, amount)`
     - Show floating text (future: "+5 Scrap")

4. **Update Player collision** (`scripts/entities/player.gd`)
   - Player is CharacterBody2D
   - Ensure collision layer/mask allows detection by drop Area2Ds
   - No code changes needed if layers correct

5. **Verify scene collision layers** (`scenes/entities/player.tscn`, `scenes/entities/drop_pickup.tscn`)
   - Player: Layer 1, Mask 3 (enemies on 2, drops on 3)
   - DropPickup: Layer 3, Mask 1 (detects player)

### Success Criteria
- [x] Drops spawn as visible pickups at enemy death locations
- [x] Player walks over pickup: currency added to BankingService
- [x] Pickup plays animation and disappears
- [x] HUD currency display updates immediately
- [x] Multiple drops (scrap + components) spawn from same enemy

### Dependencies
- Week 9 Phase 3 (DropSystem)
- Week 10 Phase 2 (Enemy death)

### Testing
```gdscript
# Manual testing (no unit tests for scene interaction)
- Kill enemy: see colored squares spawn at death position
- Walk over pickup: currency count increases in HUD
- Kill multiple enemies: drops don't overlap, slightly randomized positions
- Stand on spawn location: pickup collected immediately
```

---

## Phase 3: XP Progression & Leveling

**Goal**: Players gain XP from kills, level up, and see stat improvements.

### Tasks

1. **Track enemy kills** (`scenes/game/wasteland.gd`)
   - Connect to enemy `died` signal in WaveManager
   - Increment `total_kills` counter
   - Update WaveCompleteScreen to show kills per wave

2. **Wire XP on kill** (`scripts/systems/drop_system.gd`)
   - `award_xp_for_kill()` already implemented
   - Verify it's called in enemy death flow
   - Ensure XP goes to active character

3. **Add level-up detection** (`scripts/services/character_service.gd`)
   - Check if `level_up_character()` method exists
   - If not, implement:
     - Calculate XP needed: `100 + (level * 50)` (100, 150, 200, ...)
     - When XP exceeds threshold: increment level, reset XP
     - Grant stat points or auto-increase stats
   - Emit `character_leveled_up` signal

4. **Level-up visual feedback** (`scenes/game/wasteland.gd`)
   - Listen for `CharacterService.character_leveled_up`
   - Show temporary "LEVEL UP!" text overlay
   - Play sound effect (future)
   - Flash screen or particle effect

5. **Update HUD** (`scripts/autoload/hud_service.gd`)
   - XP bar already exists
   - Ensure it fills correctly: `value = (current_xp / xp_to_next) * 100`
   - Show level number next to XP bar

### Success Criteria
- [x] Killing enemies grants XP to player
- [x] XP bar in HUD fills correctly
- [x] Player levels up at XP threshold
- [x] "LEVEL UP!" indicator appears on level-up
- [x] Stats improve on level-up (HP, damage, etc.)
- [x] Level persists across waves

### Dependencies
- Week 9 Phase 2 (CharacterService)
- Week 9 Phase 3 (DropSystem XP rewards)
- Week 10 Phase 3 (HUD)

### Testing
```gdscript
# scripts/tests/character_service_test.gd (add new tests)
- test_add_experience_below_threshold_does_not_level_up()
- test_add_experience_at_threshold_levels_up()
- test_level_up_increases_stats()
- test_xp_threshold_scales_with_level()

# Manual testing
- Kill 2-3 enemies (20-30 XP)
- See XP bar fill
- Kill enough to reach 100 XP
- See "LEVEL UP!" text
- Check stats increased (TODO: need stat sheet UI)
```

---

## Phase 4: Wave Completion Logic

**Goal**: Detect when all enemies are dead, show wave complete screen, track stats.

### Tasks

1. **Track living enemies** (`scripts/systems/wave_manager.gd`)
   - Add `living_enemies: Array[Enemy]` to track active enemies
   - When spawning enemy: add to `living_enemies`
   - When enemy dies: remove from `living_enemies`
   - Check `living_enemies.is_empty()` after each death

2. **Detect wave completion** (`scripts/systems/wave_manager.gd`)
   - In `_on_enemy_died()`:
     - Remove enemy from `living_enemies`
     - If `living_enemies.is_empty()` and `state == COMBAT`:
       - Set state to COMPLETE
       - Calculate wave stats (kills, drops, time)
       - Emit `wave_completed` signal
       - Show WaveCompleteScreen

3. **Update WaveCompleteScreen** (`scenes/ui/wave_complete_screen.gd`)
   - Already shows stats in `show_stats(wave: int, stats: Dictionary)`
   - Ensure stats include:
     - `enemies_killed: int`
     - `drops_collected: Dictionary` (per currency)
     - `xp_earned: int`
     - `wave_time: float`

4. **Connect to Wasteland** (`scenes/game/wasteland.gd`)
   - Connect `WaveManager.wave_completed` signal
   - Increment kill counter throughout wave
   - Reset kill counter on next wave
   - Pass stats to WaveCompleteScreen

5. **Next wave flow**
   - WaveCompleteScreen already has "Next Wave" button
   - Button calls `wave_manager.next_wave()`
   - `next_wave()` increments wave number, respawns enemies

### Success Criteria
- [x] Last enemy death triggers wave completion
- [x] WaveCompleteScreen appears with accurate stats
- [x] "Next Wave" button starts next wave at increased difficulty
- [x] Wave number increments correctly
- [x] Stats reset between waves

### Dependencies
- Week 10 Phase 4 (WaveManager, WaveCompleteScreen)
- Phase 1 (Enemy kill tracking)

### Testing
```gdscript
# scripts/tests/wave_manager_test.gd (add new tests)
- test_wave_completes_when_all_enemies_dead()
- test_wave_completion_emits_signal_with_stats()
- test_next_wave_increments_wave_number()
- test_next_wave_increases_enemy_count()

# Manual testing
- Start wave 1 (8 enemies)
- Kill all 8 enemies
- See wave complete screen with stats
- Click "Next Wave"
- Wave 2 starts with 10 enemies (or scaled amount)
```

---

## Phase 5: Camera & Visual Polish

**Goal**: Add camera smoothing, screen shake, and visual juice to combat.

### Tasks

1. **Camera follow smoothing** (`scenes/game/wasteland.tscn`)
   - Camera2D already has `position_smoothing_enabled = true`
   - Tune `position_smoothing_speed` (currently 5.0)
   - Test different values (3.0 = slower, 10.0 = snappier)

2. **Screen shake on hit** (`scripts/entities/player.gd`)
   - Add `screen_shake(intensity: float, duration: float)` method
   - In `take_damage()`: call `screen_shake(5.0, 0.2)`
   - Use Tween to offset camera position randomly
   - Return camera to (0, 0) after duration

3. **Screen shake on enemy death** (`scripts/entities/enemy.gd`)
   - In `die()`: emit signal for screen shake
   - Wasteland listens and shakes camera slightly
   - Less intense than player hit (2.0 intensity)

4. **Projectile trails** (`scenes/entities/projectile.tscn`)
   - Add Line2D or GPUParticles2D as child
   - Trail follows projectile movement
   - Fades out when projectile deactivates

5. **Damage numbers** (optional, time permitting)
   - Create floating text scene
   - Spawn at enemy position on hit
   - Shows damage number, floats up, fades out
   - Different colors for critical hits (future)

### Success Criteria
- [x] Camera smoothly follows player without jitter
- [x] Taking damage shakes screen noticeably
- [x] Killing enemy causes small screen shake
- [x] Projectiles have visible trails
- [x] (Optional) Damage numbers appear on hit

### Dependencies
- Week 10 Phase 1 (Camera setup)
- Week 10 Phase 2 (Player, Enemy, Projectile)

### Testing
```gdscript
# Manual testing only (visual polish)
- Move player rapidly: camera follows smoothly
- Get hit by enemy: screen shakes
- Kill multiple enemies quickly: subtle shake per death
- Fire weapon: see projectile trails
- Hit enemy: see damage number float up
```

---

## Success Criteria (Overall Week 11)

### Must Have
- [x] Weapons auto-target nearest enemy within range
- [x] Drops spawn as collectible pickups
- [x] Player gains XP and levels up
- [x] Waves complete when all enemies dead
- [x] Wave stats tracked accurately

### Should Have
- [x] Camera smoothing tuned
- [x] Screen shake on player hit
- [x] Projectile visual trails

### Nice to Have
- [ ] Screen shake on enemy death
- [ ] Damage numbers on hit
- [ ] Targeting reticle visual

---

## Testing Strategy

### Unit Tests
- TargetingService: All targeting logic
- CharacterService: Level-up calculations
- WaveManager: Wave completion detection

### Integration Tests
- Auto-targeting: Weapon fires at enemies
- Drop collection: Pickup → BankingService → HUD
- XP flow: Kill → XP → Level-up → Stats

### Manual Testing
- Play through 3 waves
- Verify auto-targeting feels good
- Collect drops, see currency increase
- Level up at least once
- Check wave complete stats accuracy

---

## Migration Notes

### Breaking Changes
None expected. All changes are additive.

### Godot 4.x Considerations
- Area2D collision detection for pickups
- Tween API for screen shake (changed from Godot 3)
- GPUParticles2D for projectile trails (changed from CPUParticles)

### Performance
- TargetingService queries all enemies: O(n) per weapon fire
  - Wave 1: 8 enemies, negligible
  - Wave 10: ~50 enemies, still < 1ms
  - Consider spatial partitioning if > 100 enemies
- Drop pickups: Up to ~20 active at once, Area2D efficient

---

## Rollback Plan

If Week 11 blocked:
1. Revert to Week 10 (commit: `26b372c`)
2. Basic combat still functional
3. Can iterate on polish later

---

## Dependencies

### Code Dependencies
- `CharacterService`: Level-up logic
- `WeaponService`: Weapon ranges for targeting
- `BankingService`: Currency from pickups
- `DropSystem`: Spawn drop entities

### Asset Dependencies
- Drop pickup sprites (can use ColorRect placeholders)
- Screen shake requires no assets
- Projectile trail particles (built-in)

---

## Timeline Estimate

**Phase 1 (Auto-Targeting)**: 2-3 hours
- TargetingService: 1 hour
- Player weapon updates: 30 min
- Testing: 30-60 min

**Phase 2 (Drop Collection)**: 2-3 hours
- DropPickup scene/script: 1 hour
- DropSystem updates: 30 min
- Testing: 30-60 min

**Phase 3 (XP Progression)**: 1-2 hours
- Kill tracking: 15 min
- Level-up logic: 30 min
- Visual feedback: 30 min
- Testing: 30 min

**Phase 4 (Wave Completion)**: 1-2 hours
- Enemy tracking: 30 min
- Completion detection: 30 min
- Stats calculation: 30 min
- Testing: 30 min

**Phase 5 (Visual Polish)**: 1-2 hours
- Screen shake: 30 min
- Projectile trails: 30 min
- Tuning: 30 min

**Total**: 7-12 hours (1-2 work days)

---

## Next Steps (Week 12 Preview)

Potential Week 12 focus areas:
- Multiple weapon types (shotgun, laser, etc.)
- Weapon unlocks and upgrades
- More enemy types with varied behaviors
- Pickup magnets (auto-collect drops)
- Pause menu
- Settings/options menu
- Sound effects and music
- Save/load progress between sessions
