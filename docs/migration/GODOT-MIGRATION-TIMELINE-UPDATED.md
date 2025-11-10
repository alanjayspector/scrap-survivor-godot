# Scrap Survivor - Godot Migration Timeline (Updated)

**Last Updated**: 2025-01-09
**Status**: Week 6 Complete, Week 7 In Planning
**Current Progress**: CharacterService + SaveManager complete (43/43 tests passing)

---

## 🎯 High-Level Timeline

| Phase | Duration | Status | Focus |
|-------|----------|--------|-------|
| **Week 1-2** | Complete | ✅ | Project setup, GDScript basics |
| **Week 3-4** | Complete | ✅ | Core services (Stat, Error, Banking) |
| **Week 5** | Complete | ✅ | Services (Recycler, ShopReroll, SaveSystem) |
| **Week 6** | Complete | ✅ | CharacterService + SaveManager integration |
| **Week 7** | In Planning | 📋 | Character expansion (stats, types, auras) |
| **Week 8** | Planned | 📅 | Mutant character, aura visuals, UI |
| **Week 9-10** | Planned | 📅 | Combat system, weapons, enemies |
| **Week 11-12** | Planned | 📅 | Minions system, The Lab |
| **Week 13+** | Planned | 📅 | Perks, monetization, polish |

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

## 📋 Week 7: Character System Expansion (Current)

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
| New stat tests | 25/25 passing | 📋 Pending |
| Character type tests | 20/20 passing | 📋 Pending |
| Aura foundation tests | 13/13 passing | 📋 Pending |
| Total tests | 399 passing (341 existing + 58 new) | 📋 Pending |
| SaveManager integration | Character types persist | 📋 Pending |
| Manual QA | Tier restrictions work | 📋 Pending |

---

## 📅 Week 8: Mutant Character + Aura Visuals (Planned)

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

| Metric | Target |
|--------|--------|
| Mutant character tests | 15/15 passing |
| Aura visual tests | 10/10 passing |
| Character selection UI | Functional prototype |
| Conversion flow | 1 complete cycle (FREE → trial → upgrade CTA) |
| Analytics events | Firing correctly |

---

## 🎮 Week 9-10: Combat System (Planned)

### Core Combat Features
- Weapon system (melee + ranged)
- Enemy spawning (waves)
- Collision detection (weapons vs enemies)
- Aura collision detection (auras vs enemies)
- Damage calculation (base + melee_damage/ranged_damage + resonance)
- XP drops (enemy kill → character XP)
- Currency drops (scrap, components, nanites with scavenging multiplier)

### Combat Services
- `WeaponService` - Weapon management, firing, cooldowns
- `EnemyService` - Spawning, AI, health, death
- `CombatService` - Damage calculation, collision handling
- `WaveService` - Wave progression, difficulty scaling

---

## 🤖 Week 11-12: Minions + The Lab (Planned)

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

## 🎁 Week 13+: Perks + Monetization (Planned)

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

### In Progress (🚧)
- Character stat expansion (14 stats)
- Character type system (3 types + tier gating)
- Aura system foundation (data structures + visual stub)

### Planned (📅)
- Mutant character type
- Aura visual effects (particles)
- Character selection UI
- Conversion flow UI
- Combat system (weapons, enemies, damage)
- Minions system
- The Lab services
- Perks system
- Monetization testing

---

## 🎯 Key Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Week 6: CharacterService Complete | 2025-01-09 | ✅ Complete |
| Week 7: Character Expansion Complete | 2025-01-16 | 📋 In Planning |
| Week 8: Mutant + UI Complete | 2025-01-23 | 📅 Planned |
| Week 10: Combat Playable | 2025-02-06 | 📅 Planned |
| Week 12: The Lab Functional | 2025-02-20 | 📅 Planned |
| Week 14: Perks System Live | 2025-03-06 | 📅 Planned |
| Week 16: Alpha Release | 2025-03-20 | 📅 Planned |

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
- [week7-implementation-plan.md](./week7-implementation-plan.md) (current)
- [week6-days1-3-completion.md](./week6-days1-3-completion.md)

---

**Timeline Version**: 2.0
**Last Updated**: 2025-01-09
**Next Review**: After Week 7 completion (2025-01-16)
