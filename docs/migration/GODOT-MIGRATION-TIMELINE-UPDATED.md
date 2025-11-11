# Scrap Survivor - Godot Migration Timeline (Updated)

**Last Updated**: 2025-01-11
**Status**: Week 12 Phase 1 Complete
**Current Progress**: Weapon variety system complete - 8 distinct weapons with unique behaviors (455/479 tests passing)

---

## 🎯 High-Level Timeline

| Phase | Duration | Status | Focus |
|-------|----------|--------|-------|
| **Week 1-2** | Complete | ✅ | Project setup, GDScript basics |
| **Week 3-4** | Complete | ✅ | Core services (Stat, Error, Banking) |
| **Week 5** | Complete | ✅ | Services (Recycler, ShopReroll, SaveSystem) |
| **Week 6** | Complete | ✅ | CharacterService + SaveManager integration |
| **Week 7** | Complete | ✅ | Character expansion (stats, types, auras) |
| **Week 8** | Complete | ✅ | Mutant character, aura visuals, UI |
| **Week 9** | Complete | ✅ | Combat services (Weapon, Enemy, Combat, Drop) |
| **Week 10** | Complete | ✅ | Combat scene integration (playable wave loop) |
| **Week 11** | Complete | ✅ | Combat polish, auto-targeting, XP progression, camera shake |
| **Week 12** | Phase 1 Complete | 🚧 | Weapon variety (8 weapons), pickup magnets (planned) |
| **Week 13+** | Planned | 📅 | Minions system, The Lab |
| **Week 14+** | Planned | 📅 | Perks, monetization, polish |

---

## ✅ Week 6: CharacterService Foundation (Complete)

### Delivered
- ✅ Character CRUD (create, read, update, delete)
- ✅ Active character tracking
- ✅ Tier-based slots (FREE=3, PREMIUM=10, SUBSCRIPTION=unlimited)
- ✅ Level progression (linear XP, auto-distribute stats)
- ✅ 6 perk hooks (character_create_pre/post, level_up_pre/post, death_pre/post)
- ✅ SaveManager integration (serialize/deserialize)
- ✅ 43 comprehensive tests (100% passing)

### Key Files
- `scripts/services/character_service.gd` (474 lines)
- `scripts/tests/character_service_test.gd` (662 lines)
- `scripts/systems/save_manager.gd` (updated with CharacterService)

### Test Results
```
Total Tests: 341
Passing: 246 (72%)
Failing: 0 (0%)
Pending: 95 (28% - resource tests for GUI/headless mode)
CharacterService: 43/43 passing
```

---

## ✅ Week 7: Character System Expansion (Complete)

**Focus**: Stat expansion, character types, tier monetization testing, aura foundation

**Duration**: 5 days (~10 hours dev time)

### Phase 1: Stat Expansion (Days 1-2, ~3 hours)

**Goal**: Add 6 new stats (8 → 14 total)

**New Stats**:
```gdscript
"hp_regen": 0           # HP per second
"life_steal": 0.0       # % damage → HP (0-90% cap)
"attack_speed": 0.0     # % cooldown reduction
"melee_damage": 0       # Bonus melee damage
"ranged_damage": 0      # Bonus ranged damage
"scavenging": 0         # % currency multiplier (scrap, components, nanites)
"resonance": 0          # Drives aura effectiveness (NEW CONCEPT)
```

**Deliverables**:
- Updated `character_service.gd` with new stat constants
- 25 new tests (`character_stats_expansion_test.gd`)
- All existing tests still passing (43/43)

---

### Phase 2: Character Type System (Days 3-4, ~4 hours)

**Goal**: Add 3 character types with tier gating

**Character Types**:

| Type | Tier | Stat Modifiers | Aura | Theme |
|------|------|----------------|------|-------|
| **Scavenger** | FREE | +5 Scavenging, +20 Pickup Range | Collect | Economy |
| **Tank** | PREMIUM | +20 Max HP, +3 Armor, -20 Speed | Shield | Survivability |
| **Commando** | SUBSCRIPTION | +5 Ranged Damage, +15% Attack Speed, -2 Armor | None | DPS |

**Features**:
- Tier-based character creation restrictions
- Stat modifiers applied on character creation
- Color palette differentiation (gray, olive, red)
- Aura type assignment per character

**Deliverables**:
- Updated `character_service.gd` with CHARACTER_TYPES constant
- Updated `create_character()` to accept `character_type` parameter
- 20 new tests (`character_types_test.gd`)
- Tier restriction validation tests

---

### Phase 3: Aura System Foundation (Day 5, ~2 hours)

**Goal**: Create data structures + visual stub (full implementation Week 8)

**Aura Types**:
- **Damage**: Deals damage to nearby enemies
- **Knockback**: Pushes enemies away
- **Heal**: Heals nearby minions
- **Collect**: Auto-collects currency/items
- **Slow**: Slows enemy movement
- **Shield**: Grants temporary armor

**Implementation**:
- `scripts/systems/aura_types.gd` - Aura definitions
- `scripts/components/aura_visual.gd` - Simple ColorRect visual stub
- Aura data stored in character (type, enabled, level)
- 13 new tests (`aura_foundation_test.gd`)

**Visual Approach (Week 7)**:
- Simple ColorRect circles with color coding
- Pulsing animation via Tween
- Upgrade to GPUParticles2D in Week 8

---

### Week 7 Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| New stat tests | 25/25 passing | ✅ Complete |
| Character type tests | 20/20 passing | ✅ Complete |
| Aura foundation tests | 13/13 passing | ✅ Complete |
| Total tests | 313 passing (all tests) | ✅ Complete |
| SaveManager integration | Character types persist | ✅ Complete |
| Manual QA | Tier restrictions work | ✅ Complete |

---

## ✅ Week 8: Mutant Character + Aura Visuals (Complete)

### Phase 1: Mutant Character Type
**Goal**: Add 4th character type (Subscription-exclusive)

**Mutant Stats**:
- Tier: SUBSCRIPTION
- Stat Modifiers: +10 Resonance, +5 Luck, +20 Pickup Range
- Aura: Damage (scales with Resonance)
- Theme: Mutation specialist, high Resonance for powerful auras

---

### Phase 2: Aura Visual Upgrade
**Goal**: Replace ColorRect with GPUParticles2D

**Visual Features**:
- Particle effects per aura type (red for damage, green for heal, etc.)
- Radius visualization (matches pickup_range stat)
- Pulsing animation synchronized with aura cooldown
- Kenney Particle Pack integration (open-source assets)

---

### Phase 3: Character Selection UI
**Goal**: Create character selection screen with type preview

**UI Features**:
- Character type cards (visual distinction via color)
- Stat comparison table (Tank vs Scavenger)
- Locked character preview (PREMIUM/SUBSCRIPTION)
- "Try for 1 Run" button (free trial)
- "Unlock Forever" button (tier upgrade CTA)

---

### Phase 4: Conversion Flow
**Goal**: Implement try-before-buy monetization test

**Flow**:
1. FREE player taps locked Tank character
2. Show character preview modal (stats, visual, aura)
3. Player selects "Try for 1 Run" (free trial)
4. Play full run with Tank (no restrictions)
5. Post-run conversion screen (show stats improvement)
6. "Unlock Tank Forever" CTA (Premium upgrade)

**Analytics Events**:
- `tier_upgrade_viewed`
- `free_trial_started`
- `tier_upgrade_offered_post_trial`
- `tier_upgrade_completed`

---

### Week 8 Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Mutant character tests | 6+ passing | ✅ 6/6 passing |
| Aura visual tests | 8+ passing | ✅ 8/8 passing |
| Character selection UI | Functional prototype | ✅ Complete |
| Conversion flow | 1 complete cycle (FREE → trial → upgrade CTA) | ✅ Complete |
| Analytics events | 5+ events | ✅ 5 events |
| Total tests | 313+ passing | ✅ 313/313 passing |

**Completion Date**: 2025-01-10
**Documentation**: [week8-completion.md](./week8-completion.md)

---

## ✅ Week 9: Combat Services (Complete)

**Completion Date**: ~2025-10-15
**Test Results**: 393/411 tests passing
**Documentation**: [week9-implementation-plan.md](./week9-implementation-plan.md)

### Delivered Services
- ✅ `WeaponService` - Weapon management, firing, cooldowns
- ✅ `EnemyService` - Spawning, AI, health, death, wave scaling
- ✅ `CombatService` - Damage calculation (base + melee/ranged + resonance)
- ✅ `DropSystem` - XP awards, currency drops (scrap, components, nanites)

### Key Features
- Weapon cooldown management with attack speed scaling
- Enemy HP scaling per wave (10% per wave)
- Spawn rate progression (decreases with wave)
- Damage calculation with stat bonuses
- Aura damage scaling with resonance
- Currency drop generation with scavenging multiplier

---

## ✅ Week 10: Combat Scene Integration (Complete)

**Status**: All Phases Complete (4/4)
**Test Results**: 427/451 tests passing (8 new wave manager tests)
**Documentation**: [week10-implementation-plan.md](./week10-implementation-plan.md)
**Completed**: 2025-01-10

### ✅ Phase 1: Scene Architecture (Complete - commit bf616ba)
**Features**:
- Player entity (CharacterBody2D) with character stats integration
- Enemy entity (CharacterBody2D) with wave scaling
- Scene structure with containers for entities, projectiles, drops

### ✅ Phase 2: Input & Camera Systems (Complete - commit bf616ba)
**Features**:
- Input configuration (WASD movement keys)
- Camera controller with smooth follow and boundaries
- Screen shake system for combat feedback

### ✅ Phase 3: HUD Implementation (Complete - commit ab0957e)
**Features**:
- `HudService` autoload - Signal-driven HUD updates
- HP bar with damage flash animation
- XP bar with level-up popup
- Wave counter with transition animation
- Currency display (scrap, components, nanites)

**Test Coverage**: 11/11 HUD tests passing

**Artifacts**:
- `scripts/autoload/hud_service.gd` - Central HUD service
- `scenes/ui/hud.gd` - HUD UI controller
- `scenes/ui/hud.tscn` - HUD scene
- `scripts/tests/hud_service_test.gd` - HUD tests

**Learnings** (captured in validator improvements):
- Field name consistency: "experience" not "xp"
- Autoload naming: "HudService" not "HUDService" (PascalCase)
- Memory management: `.free()` not `.queue_free()` in tests

### ✅ Phase 4: Wave Management & State Machine (Complete - commit 404d756)
**Features**:
- WaveManager with full state machine (IDLE, SPAWNING, COMBAT, VICTORY, GAME_OVER)
- Gradual enemy spawning over time (not all at once)
- Random off-screen spawn positions at viewport edges
- Wave completion detection when all enemies killed
- Wave stats tracking (enemies killed, drops collected)
- Victory screen with stat summary and next wave button
- Integrated with Wasteland scene via GameController node

**Test Coverage**: 8/8 wave manager tests passing

**Artifacts**:
- `scripts/systems/wave_manager.gd` - Wave state machine
- `scenes/ui/wave_complete_screen.gd` - Victory screen controller
- `scenes/ui/wave_complete_screen.tscn` - Victory screen scene
- `scripts/tests/wave_manager_test.gd` - Wave manager tests

**Validator Improvements**:
- Enhanced `test_method_validator.py` to recognize `.new()` as built-in for all GDScript classes
- Evidence-based comments citing docs/godot-reference.md and docs/godot-testing-research.md
- Clarified autoload vs regular node instantiation patterns

---

## ✅ Week 11: Combat Polish & Auto-Targeting (Complete)

**Goal**: Polish the combat loop established in Week 10 by adding auto-targeting for weapons, implementing drop collection, enhancing player progression, and expanding the currency system.

**Status**: All 6 Phases Complete

### Phase 1: Auto-Targeting System ✅
- `TargetingService` - Finds nearest enemy within weapon range
- Player weapons automatically target closest enemy
- Each weapon independently targets based on its own range and fire rate
- Multiple weapons can fire at different targets simultaneously
- Fallback to facing direction if no enemy in range

### Phase 2: Drop Collection System ✅
- Drop pickups spawn as visible Area2D nodes at enemy death locations
- Player collision with drops triggers collection
- Currency added to BankingService on pickup
- Pickup plays animation and disappears
- HUD currency display updates immediately

### Phase 3: XP Progression & Leveling ✅
- Enemy kills tracked across waves
- XP awarded on kill via DropSystem
- Level-up detection with dynamic thresholds (100 + level * 50)
- "LEVEL UP!" visual feedback on level-up
- XP bar in HUD fills correctly with level display
- Stats improve on level-up (HP, damage, etc.)

### Phase 4: Currency System Expansion ✅
- Expanded BankingService to support COMPONENTS and NANITES currencies
- Removed temporary SCRAP mapping for components/nanites
- Fixed HUD/wave screen currency count discrepancies
- Updated serialization to preserve all 4 currencies
- Added balance caps for new currencies by tier

### Phase 5: Wave Completion & Game Over ✅
- Tracked living enemies in WaveManager
- Wave completion detection when all enemies dead
- WaveCompleteScreen shows accurate stats (kills, time)
- "Next Wave" button increments difficulty
- Game over screen on player death with retry/main menu
- Game pauses on death (no loot collection exploit)

### Phase 6: Camera & Visual Polish ✅
- Camera shake on player damage (5.0 intensity, 0.2s)
- Camera shake on enemy death (2.0 intensity, 0.1s)
- Projectile visual trails with Line2D
- Smooth camera offset with decay
- Level-up visual feedback ("LEVEL UP!" yellow text)

**See**: [docs/migration/week11-implementation-plan.md](week11-implementation-plan.md)

---

## 🚧 Week 12: Weapon Variety & Pickup Magnets (Phase 1 Complete)

**Goal**: Expand combat variety with 6+ new weapon types featuring unique firing patterns (spread, pierce, explosive) and implement quality-of-life pickup magnet system.

**Status**: Phase 1 Complete (Weapon Variety System)

### Phase 1: Weapon Variety System ✅
**Delivered** (2025-01-11):
- 6 new weapons with unique behaviors added (8 total weapons)
- Wasteland-themed weapon naming (Fallout/Mad Max inspired)
- DPS balanced across weapon categories:
  - Fast weapons (40-50 DPS): Scorcher, Shredder
  - Medium weapons (25-35 DPS): Plasma Pistol, Beam Gun, Arc Blaster
  - Slow weapons (20-30 DPS): Dead Eye, Boom Tube

**New Weapons**:
1. **Scattergun** (shotgun) - 5-projectile spread, 40° cone, 8 dmg/pellet, 1.2s cooldown
2. **Dead Eye** (sniper) - Pierce 2 enemies, 50 dmg, 800px range, 2.0s cooldown
3. **Boom Tube** (rocket) - 60 direct + 30 splash (50px radius), 2.5s cooldown
4. **Scorcher** (flamethrower) - 0.1s cooldown, 99 pierce, 30° cone, 40 DPS
5. **Shredder** (minigun) - 0.15s rapid fire, spin-up mechanic (2x first 3 shots), 46.7 DPS
6. **Beam Gun** (laser) - 2000 projectile speed (instant-hit feel), 600px range, 30 DPS

**Technical Implementation**:
- Extended `weapon_service.gd` with 6 new weapon definitions
- Added weapon properties: `special_behavior`, `projectiles_per_shot`, `pierce_count`, `splash_damage`, `splash_radius`
- Implemented `projectile.gd` splash damage system with `_explode()` and physics queries
- Added spread/cone projectile spawning in `wasteland.gd` (`_spawn_spread_projectiles`)
- Implemented Shredder spin-up mechanic in `player.gd` with `consecutive_shots` tracking
- Debug hotkeys (1-8) for manual QA weapon switching during gameplay

**Testing**:
- All 455 tests passing (24 skipped tests unrelated)
- Manual QA enabled with number key hotkeys for instant weapon switching

### Phase 2: Pickup Magnet System (Planned)
- Drops fly toward player when within pickup_range
- `pickup_range` stat integration into CharacterService
- Visual indicator for pickup range radius
- Magnetized drop visual feedback (glow, trail)
- Default range: 80px, scalable with stat

### Phase 3: Stat Integration (Planned)
- Wire pickup_range into character stat system
- HUD display for pickup_range value
- Save/load persistence for pickup_range stat

**See**: [docs/migration/week12-implementation-plan.md](week12-implementation-plan.md)

---

## 🤖 Week 13+: Minions + The Lab (Planned)

### Minions System
- Minion types (biological, mechanical, hybrid)
- Minion AI (follow character, attack enemies)
- Minion crafting (The Lab)
- Minion fusion/upgrading
- Nanites currency integration

### The Lab Services
- `LabService` - Nanites management, storage limits
- `MinionCraftingService` - Minion creation, degradation
- `RadioactivityService` - Radioactivity stat, treatments
- `MutationChamberService` - Idle nanite generation (Subscription)

---

## 🎁 Week 14+: Perks + Monetization (Planned)

### Perks System
- `PerksService` - Perk registration, activation
- Perk hooks integration (consume character hooks)
- Perk UI (browse, purchase, activate)
- Example perks:
  - "+10 HP to new characters" (character_create_post)
  - "Double stat gains on level up" (character_level_up_pre)
  - "50% chance to resurrect" (character_death_pre)

### Monetization Testing
- A/B test conversion flows
- Analytics dashboard (conversion rates)
- Tier value proposition validation
- Premium/Subscription feature utilization tracking

---

## 📊 Overall Progress Tracking

### Completed Systems (✅)
- Project setup & GDScript basics
- ErrorService (error handling)
- StatService (stat calculations)
- BankingService (scrap + premium currency)
- RecyclerService (item dismantling)
- ShopRerollService (shop rerolls)
- SaveSystem (file I/O, corruption recovery)
- SaveManager (service coordination, auto-save)
- CharacterService (CRUD, slots, progression, perks)
- Character stat expansion (14 stats)
- Character type system (4 types: Scavenger, Tank, Commando, Mutant)
- Aura system foundation (data structures + visual particles)
- Character selection UI
- Conversion flow UI
- WeaponService (weapon management, firing, cooldowns)
- EnemyService (spawning, AI, health, wave scaling)
- CombatService (damage calculation, stat bonuses)
- DropSystem (XP awards, currency drops)
- Player/Enemy entities (scene architecture)
- Input & Camera systems
- HudService (signal-driven HUD updates)
- WaveManager (state machine, spawning, completion)
- Wave completion flow (victory screen, stat tracking)
- TargetingService (auto-targeting, nearest enemy detection)
- Drop collection system (Area2D pickups, BankingService integration)
- XP progression & leveling (dynamic thresholds, stat improvements)
- Currency system expansion (4 currencies: scrap, gems, components, nanites)
- Game over system (pause on death, retry/main menu)
- Camera & visual polish (screen shake, projectile trails, level-up feedback)
- Weapon variety system (8 weapons with unique behaviors)
  - Spread patterns (Scattergun)
  - Piercing (Dead Eye, Scorcher)
  - Explosive (Boom Tube with splash damage)
  - Spin-up mechanic (Shredder)

### In Progress (🚧)
- Pickup magnet system (Phase 2 of Week 12)
- Pickup range stat integration (Phase 3 of Week 12)

### Planned (📅)
- Minions system
- The Lab services
- Perks system
- Monetization testing

---

## 🎯 Key Milestones

| Milestone | Target Date | Actual Date | Status |
|-----------|-------------|-------------|--------|
| Week 6: CharacterService Complete | 2025-01-09 | 2025-01-09 | ✅ Complete |
| Week 7: Character Expansion Complete | 2025-01-16 | ~2025-01-16 | ✅ Complete |
| Week 8: Mutant + UI Complete | 2025-01-23 | 2025-01-10 | ✅ Complete |
| Week 9: Combat Services Complete | ~2025-10-01 | ~2025-10-15 | ✅ Complete |
| Week 10 Phase 3: HUD Implementation | ~2025-11-01 | 2025-11-10 | ✅ Complete |
| Week 10 Phase 4: Wave Management | ~2025-11-10 | 2025-11-10 | ✅ Complete |
| Week 10: Combat Fully Playable | 2025-11-15 | 2025-11-10 | ✅ Complete (QA Pending) |
| Week 12: The Lab Functional | 2025-12-01 | - | 📅 Planned |
| Week 14: Perks System Live | 2025-12-15 | - | 📅 Planned |
| Week 16: Alpha Release | 2026-01-01 | - | 📅 Planned |

---

## 🔗 Key Documentation

### Architecture
- [godot-service-architecture.md](../godot-service-architecture.md)
- [PERKS-ARCHITECTURE.md](../core-architecture/PERKS-ARCHITECTURE.md)
- [DATA-MODEL.md](../core-architecture/DATA-MODEL.md)

### System Design
- [CHARACTER-SYSTEM.md](../game-design/systems/CHARACTER-SYSTEM.md)
- [THE-LAB-SYSTEM.md](../game-design/systems/THE-LAB-SYSTEM.md)
- [MINIONS-SYSTEM.md](../game-design/systems/MINIONS-SYSTEM.md)

### Testing
- [test-file-template.md](../test-file-template.md)
- [godot-testing-research.md](../godot-testing-research.md)
- [gut-migration-phase3-status.md](../gut-migration-phase3-status.md)

### Week Plans
- [week10-implementation-plan.md](./week10-implementation-plan.md) (current)
- [week9-implementation-plan.md](./week9-implementation-plan.md)
- [week8-completion.md](./week8-completion.md)
- [week7-implementation-plan.md](./week7-implementation-plan.md)
- [week6-days1-3-completion.md](./week6-days1-3-completion.md)

---

**Timeline Version**: 3.3
**Last Updated**: 2025-01-11 (updated after Week 12 Phase 1 completion)
**Next Review**: After Week 12 Phase 2 completion (pickup magnets)
