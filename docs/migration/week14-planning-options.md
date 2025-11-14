# Week 14 Planning Options

**Date**: 2025-01-14
**Status**: Planning Phase
**Context**: Week 13 Complete (Arena optimization + character selection + enemy variety)
**Current State**: 496/520 tests passing, core combat loop polished, ready for next major feature

---

## Executive Summary

Week 13 delivered significant combat depth improvements with 4 enemy types and strategic variety. Week 13 Phase 3.5 fixed enemy density (2.5x increase) based on iOS testing feedback. Week 14 has four high-ROI paths forward, each addressing different quality/content gaps:

**Option A+D: Polish & Pacing Package** (RECOMMENDED, 9-12 hours)
- **Audio System** (6-8h): Weapon + enemy sounds complete the "game feel" loop
- **Continuous Spawning** (3-4h): Constant pressure throughout wave (genre standard)
- Combined package delivers professional feel + proper pacing for manual QA

**Option A: Audio System Only** (High-ROI Polish, 6-8 hours)
- Weapon + enemy audio completes the "game feel" feedback loop
- 50%+ perceived quality improvement for minimal effort
- Audio is 50% of combat satisfaction (industry research)

**Option B: Boss Enemies** (Content Expansion, 8-12 hours)
- Mini-bosses every 5 waves create milestone moments
- Leverages existing combat systems
- High replayability value

**Option C: Meta Progression** (Long-term Engagement, 10-15 hours)
- Permanent upgrades between runs
- Critical for retention (players stop after 5-10 runs without meta)
- Foundation for monetization

**Option D: Continuous Spawning** (Pacing Fix, 3-4 hours)
- Replace burst spawning with continuous trickle (Brotato/VS standard)
- Maintains constant pressure throughout wave
- Critical for extended manual QA sessions

**Recommendation**: **Option A+D (Polish & Pacing Package)** for complete "feel" overhaul, enabling proper multi-tester QA sessions.

---

## Option A: Audio System (Recommended)

### Overview
Add weapon firing sounds, enemy sounds, and ambient audio to complete the combat feel loop.

**Effort**: 6-8 hours
**ROI**: Very High (50%+ perceived quality improvement)
**Risk**: Low (audio is isolated system)

### Rationale (Sr Mobile Game Designer)
> "Audio is 50% of game feel in action games. Right now we have great visual feedback (particles, screen shake, trails) but zero audio. Players subconsciously feel the combat is 'hollow'. Adding weapon sounds + enemy audio completes the feedback loop and makes combat feel **professional** vs **prototype**."

### Implementation Plan

#### Phase A1: Weapon Audio System (3-4 hours)

**Goal**: Each weapon has distinct firing sound that reinforces its identity.

**Weapon Sound Design**:
- **Pistol**: Sharp "pew" (precise, single-target feel)
- **Shotgun**: Deep "boom" with reverb (powerful, spread feel)
- **SMG**: Rapid "rat-tat-tat" (high fire rate feel)
- **Sniper**: Heavy "crack" with echo (long-range, impactful feel)
- **Rocket**: "whoosh" + delayed explosion (anticipation feel)
- **Flamethrower**: Continuous "whoosh" roar (DoT, area feel)
- **Minigun**: Accelerating "brrrt" (ramp-up feel)
- **Laser**: Sci-fi "bzzt" hum (precision, pierce feel)
- **Tesla**: Electric "zap" crackle (chain lightning feel)
- **Grenade Launcher**: "thunk" + delayed explosion (arc projectile feel)

**Implementation**:
```gdscript
# scripts/services/weapon_service.gd
func _play_weapon_audio(weapon_type: String) -> void:
    var audio_player = AudioStreamPlayer2D.new()
    audio_player.stream = load("res://assets/audio/weapons/%s.ogg" % weapon_type)
    audio_player.volume_db = _get_weapon_volume(weapon_type)
    audio_player.pitch_scale = randf_range(0.95, 1.05)  # Subtle variation
    audio_player.play()
    audio_player.finished.connect(audio_player.queue_free)
    add_child(audio_player)
```

**Audio Sourcing**:
- Kenney Audio Pack (CC0, 300+ sounds)
- freesound.org (CC-BY, curated weapon sounds)
- Budget: $0 (all free/CC0)

**Success Criteria**:
- [x] Each weapon has distinct firing sound
- [ ] Volume balanced (no overpowering sounds)
- [ ] Pitch variation prevents repetition
- [ ] Audio doesn't overlap excessively (>5 simultaneous sources)

---

#### Phase A2: Enemy Audio (2-3 hours)

**Goal**: Enemies provide audio feedback for spawning, taking damage, and dying.

**Enemy Sound Design**:
- **Turret Drone**: Mechanical whir (charging), "pew" (firing)
- **Scrap Titan**: Heavy footsteps, metallic groan
- **Feral Runner**: High-pitched screech, rapid footsteps
- **Nano Swarm**: Buzzing/chittering (group sound)
- **All**: Impact sound on taking damage, death sound

**Implementation**:
```gdscript
# scripts/entities/enemy.gd
func take_damage(dmg: float) -> bool:
    # ... existing damage logic ...
    _play_damage_audio()

    if current_hp <= 0:
        _play_death_audio()
        die()
        return true

    return false

func _play_damage_audio() -> void:
    var audio = AudioStreamPlayer2D.new()
    audio.stream = load("res://assets/audio/enemies/%s_damage.ogg" % enemy_type)
    audio.volume_db = -10
    audio.play()
    audio.finished.connect(audio.queue_free)
    add_child(audio)
```

**Success Criteria**:
- [ ] Enemy spawns have audio cues
- [ ] Damage feedback is audible but not overwhelming
- [ ] Death sounds vary by enemy type
- [ ] Ranged enemy "charging" sound warns player

---

#### Phase A3: Ambient & UI Audio (1-2 hours)

**Goal**: Complete audio experience with ambient sounds and UI feedback.

**Ambient Sounds**:
- Wave start: Alarm/siren (tension builder)
- Wave complete: Victory chime
- Low HP warning: Heartbeat pulse (survival tension)

**UI Sounds**:
- Button tap: Soft click
- Character selection: Whoosh (card tap)
- Unlock/purchase: Success chime

**Implementation**:
```gdscript
# scripts/autoload/audio_manager.gd (NEW)
extends Node

var music_volume: float = 0.7
var sfx_volume: float = 0.8

func play_ui_sound(sound_name: String) -> void:
    var audio = AudioStreamPlayer.new()
    audio.stream = load("res://assets/audio/ui/%s.ogg" % sound_name)
    audio.volume_db = linear_to_db(sfx_volume)
    audio.play()
    audio.finished.connect(audio.queue_free)
    add_child(audio)

func play_ambient_sound(sound_name: String) -> void:
    var audio = AudioStreamPlayer.new()
    audio.stream = load("res://assets/audio/ambient/%s.ogg" % sound_name)
    audio.volume_db = linear_to_db(sfx_volume * 0.6)  # Quieter than SFX
    audio.play()
    audio.finished.connect(audio.queue_free)
    add_child(audio)
```

**Success Criteria**:
- [ ] UI interactions have audio feedback
- [ ] Wave transitions feel impactful with audio
- [ ] Low HP warning is noticeable but not annoying
- [ ] Audio settings persist (volume sliders in settings menu)

---

### Week 14 Option A - Success Metrics

| Metric | Target | Priority |
|--------|--------|----------|
| Weapon audio implemented | 10/10 weapons | Must Have |
| Enemy audio implemented | 7/7 types | Must Have |
| Ambient/UI audio | 5+ sounds | Should Have |
| Manual QA: "Combat feels professional" | Unanimous | Must Have |
| Performance: 60 FPS maintained | All devices | Must Have |

**Estimated Effort**: 6-8 hours
**Risk**: Low
**Dependencies**: Asset sourcing (Kenney Audio Pack, 1 hour)

---

## Option B: Boss Enemies & Milestone Moments

### Overview
Add mini-boss encounters every 5 waves (waves 5, 10, 15) with unique mechanics and high rewards.

**Effort**: 8-12 hours
**ROI**: High (replayability, milestone moments)
**Risk**: Medium (combat mechanics complexity)

### Rationale (Sr Product Manager)
> "Players need **milestone moments** to break up the wave loop monotony. Bosses every 5 waves create anticipation, challenge spikes, and reward satisfaction. Brotato's boss waves are the most memorable moments - players share screenshots, discuss strategies, and feel accomplishment."

### Implementation Plan

#### Phase B1: Boss Enemy Framework (3-4 hours)

**Goal**: Create boss enemy base class with health bar, unique mechanics, and spawn system.

**Boss Features**:
- Large health pool (10x normal enemy HP)
- Boss health bar (top of screen)
- Unique mechanics per boss
- Higher XP/drop rewards
- Wave cleared on boss death (no other enemies spawn)

**Implementation**:
```gdscript
# scripts/entities/boss_enemy.gd
class_name BossEnemy
extends Enemy

signal boss_defeated(boss_type: String, rewards: Dictionary)

var boss_type: String = ""
var phase: int = 1  # Bosses can have multi-phase mechanics

func setup_boss(type: String, wave: int) -> void:
    boss_type = type
    setup("boss_%s" % type, type, wave)

    # Bosses have 10x HP
    max_hp *= 10
    current_hp = max_hp

    # Show boss health bar
    _show_boss_health_bar()

func _show_boss_health_bar() -> void:
    var hud = get_tree().get_first_node_in_group("hud")
    if hud and hud.has_method("show_boss_health_bar"):
        hud.show_boss_health_bar(boss_type, max_hp)
```

**Success Criteria**:
- [ ] Boss health bar displays at top of screen
- [ ] Boss enemies have 10x HP
- [ ] Boss death triggers wave completion
- [ ] Boss spawns every 5 waves

---

#### Phase B2: Boss Types (4-6 hours)

**Goal**: Implement 2-3 unique boss types with distinct mechanics.

**Boss Type 1: "Scrap Colossus" (Tank Boss)**
- Wave 5, 15, 25
- Mechanic: Slow, massive HP, summons minions every 25% HP
- Strategy: Kill minions first, focus fire on boss
- Visual: 3x size, dark armored appearance

**Boss Type 2: "Turret Overmind" (Ranged Boss)**
- Wave 10, 20, 30
- Mechanic: Stationary, fires projectile barrage in spiral pattern
- Strategy: Dodge projectiles, attack during reload phase
- Visual: Large turret with rotating cannons

**Boss Type 3: "Feral Alpha" (Fast Boss)** (Nice to Have)
- Wave 15, 25, 35
- Mechanic: Fast movement, charges player in patterns, dodges attacks
- Strategy: Predict charge paths, use area weapons
- Visual: Large feral enemy with glowing eyes

**Implementation**:
```gdscript
# scripts/services/boss_service.gd (NEW)
extends Node

const BOSS_TYPES = {
    "scrap_colossus": {
        "base_hp": 500,
        "speed": 40,
        "damage": 20,
        "summon_threshold": 0.25,  # Summon at 75%, 50%, 25% HP
        "minion_count": 3,
        "xp_reward": 200
    },
    "turret_overmind": {
        "base_hp": 400,
        "speed": 0,  # Stationary
        "damage": 15,
        "projectile_pattern": "spiral",
        "projectiles_per_burst": 12,
        "attack_cooldown": 3.0,
        "xp_reward": 200
    }
}

func get_boss_for_wave(wave: int) -> String:
    match wave:
        5, 15, 25: return "scrap_colossus"
        10, 20, 30: return "turret_overmind"
        _: return ""
```

**Success Criteria**:
- [ ] Scrap Colossus spawns and summons minions at HP thresholds
- [ ] Turret Overmind fires spiral projectile patterns
- [ ] Bosses provide 10x XP compared to normal enemies
- [ ] Boss fights feel challenging but fair

---

#### Phase B3: Boss Rewards & Victory Screen (1-2 hours)

**Goal**: Boss victories feel rewarding with special loot and victory feedback.

**Boss Rewards**:
- 10x XP (instant level-up in early game)
- Guaranteed rare drop (components, nanites)
- Boss kill counter (tracked in stats)
- Special victory animation/screen

**Implementation**:
```gdscript
# scripts/systems/wave_manager.gd
func _on_boss_defeated(boss_type: String) -> void:
    # Award XP
    var xp = BossService.get_boss_xp_reward(boss_type)
    CharacterService.add_experience(xp)

    # Award special drops
    var drops = BossService.get_boss_drops(boss_type)
    DropSystem.spawn_drop_pickups(drops, boss.global_position)

    # Show victory screen
    _show_boss_victory_screen(boss_type, xp, drops)

    # Track boss kills
    StatsService.increment_boss_kills(boss_type)
```

**Success Criteria**:
- [ ] Boss death spawns 5+ pickups (visual feedback)
- [ ] Victory screen shows XP/drops earned
- [ ] Boss kill counter increments
- [ ] Players feel rewarded for boss victories

---

### Week 14 Option B - Success Metrics

| Metric | Target | Priority |
|--------|--------|----------|
| Boss types implemented | 2-3 types | Must Have |
| Boss health bar | Functional | Must Have |
| Boss unique mechanics | Distinct per type | Must Have |
| Manual QA: "Boss fights feel rewarding" | Positive | Must Have |
| Performance: 60 FPS during boss fight | All devices | Must Have |

**Estimated Effort**: 8-12 hours
**Risk**: Medium (multi-phase mechanics can be complex)
**Dependencies**: Boss health bar UI (HUD modification)

---

## Option C: Meta Progression System

### Overview
Add permanent upgrades that persist between runs, creating long-term progression and retention.

**Effort**: 10-15 hours
**ROI**: Very High (retention, monetization foundation)
**Risk**: Medium (economy balancing required)

### Rationale (Sr Product Manager)
> "Players stop after 5-10 runs if there's no meta progression. They hit a skill ceiling and feel 'done'. Meta progression creates the '**one more run**' loop: earn currency → unlock upgrade → try new build → earn more currency. Retention increases from 3 runs to 30+ runs. This is **critical** for monetization (players don't pay if they stop playing)."

### Implementation Plan

#### Phase C1: Persistent Currency System (2-3 hours)

**Goal**: Add meta currency (distinct from in-run scrap) that persists between runs.

**Meta Currencies**:
- **"Salvage"**: Earned from completed runs, used for meta upgrades
- Conversion: 10% of scrap earned → Salvage (incentivizes long runs)
- Stored in BankingService, persists via SaveSystem

**Implementation**:
```gdscript
# scripts/services/banking_service.gd
const CURRENCY_TYPES = {
    # ... existing currencies ...
    "salvage": {
        "display_name": "Salvage",
        "icon": "res://assets/icons/salvage.png",
        "caps": {
            "FREE": 10000,
            "PREMIUM": 50000,
            "SUBSCRIPTION": -1  # Unlimited
        }
    }
}

func convert_scrap_to_salvage(scrap_amount: int) -> int:
    var salvage = floor(scrap_amount * 0.1)  # 10% conversion
    add_currency("salvage", salvage)
    return salvage
```

**Success Criteria**:
- [ ] Salvage currency added to banking system
- [ ] Run completion converts 10% scrap → salvage
- [ ] Salvage persists between runs
- [ ] Salvage displayed in hub/shop UI

---

#### Phase C2: Meta Upgrade System (4-6 hours)

**Goal**: Create permanent upgrade system with tiers and unlock progression.

**Meta Upgrade Categories**:
1. **Combat Upgrades**:
   - "+5% damage" (5 tiers, 100/200/400/800/1600 salvage)
   - "+5% attack speed" (5 tiers)
   - "+10 max HP" (5 tiers)

2. **Economy Upgrades**:
   - "+10% scrap gain" (3 tiers, 500/1000/2000 salvage)
   - "+1 reroll per shop" (3 tiers)
   - "+5% drop chance" (3 tiers)

3. **Progression Upgrades**:
   - "Start with 50 HP" (1 tier, 1000 salvage)
   - "Start at level 2" (1 tier, 2000 salvage)
   - "First weapon free" (1 tier, 1500 salvage)

**Implementation**:
```gdscript
# scripts/services/meta_progression_service.gd (NEW)
extends Node

const META_UPGRADES = {
    "damage_boost_1": {
        "display_name": "+5% Damage I",
        "description": "Deal 5% more damage with all weapons",
        "cost": 100,
        "tier": 1,
        "effect": {"damage_multiplier": 1.05},
        "requires": []
    },
    "damage_boost_2": {
        "display_name": "+5% Damage II",
        "description": "Deal 10% more damage with all weapons",
        "cost": 200,
        "tier": 2,
        "effect": {"damage_multiplier": 1.10},
        "requires": ["damage_boost_1"]
    },
    # ... 20-30 total upgrades
}

var unlocked_upgrades: Array[String] = []

func purchase_upgrade(upgrade_id: String) -> bool:
    var upgrade = META_UPGRADES[upgrade_id]

    # Check cost
    if not BankingService.can_afford("salvage", upgrade.cost):
        return false

    # Check requirements
    for required_id in upgrade.requires:
        if required_id not in unlocked_upgrades:
            return false

    # Purchase
    BankingService.remove_currency("salvage", upgrade.cost)
    unlocked_upgrades.append(upgrade_id)
    _apply_upgrade_effects(upgrade)

    meta_upgrade_purchased.emit(upgrade_id)
    return true
```

**Success Criteria**:
- [ ] 20-30 meta upgrades defined
- [ ] Upgrades have tier progression (I → II → III)
- [ ] Unlock requirements prevent sequence breaking
- [ ] Upgrade effects apply on run start
- [ ] UI shows locked/unlocked state

---

#### Phase C3: Meta Progression UI (3-5 hours)

**Goal**: Create upgrade tree UI (similar to skill trees in RPGs).

**UI Features**:
- Grid layout showing all upgrades
- Visual connections between tiers (unlock paths)
- Salvage balance display
- Purchase button with cost
- Locked state for unavailable upgrades

**Implementation**:
```gdscript
# scripts/ui/meta_progression_screen.gd (NEW)
extends Control

@onready var upgrade_grid = $UpgradeGrid
@onready var salvage_label = $SalvageLabel

func _ready() -> void:
    _populate_upgrade_grid()
    _update_salvage_display()

func _populate_upgrade_grid() -> void:
    for upgrade_id in MetaProgressionService.META_UPGRADES:
        var upgrade_card = _create_upgrade_card(upgrade_id)
        upgrade_grid.add_child(upgrade_card)

func _create_upgrade_card(upgrade_id: String) -> Control:
    var upgrade = MetaProgressionService.META_UPGRADES[upgrade_id]
    var card = PanelContainer.new()

    # Locked/unlocked state
    var is_locked = upgrade_id not in MetaProgressionService.unlocked_upgrades
    card.modulate = Color.GRAY if is_locked else Color.WHITE

    # Display: name, description, cost, purchase button
    # ... UI layout code ...

    return card
```

**Success Criteria**:
- [ ] Upgrade tree UI accessible from hub
- [ ] Salvage balance visible
- [ ] Locked upgrades clearly indicated
- [ ] Purchase button functional
- [ ] Tooltip shows upgrade effects

---

#### Phase C4: First-Run Experience (1-2 hours)

**Goal**: Players understand meta progression from first run.

**Tutorial Flow**:
1. First run completion: "You earned 50 Salvage!"
2. Meta progression screen tutorial: "Spend Salvage on permanent upgrades"
3. Highlight first upgrade: "+5 Max HP" (cheap starter upgrade)
4. After purchase: "This upgrade applies to ALL future runs!"

**Implementation**:
```gdscript
# scripts/systems/tutorial_system.gd
func show_meta_progression_tutorial() -> void:
    if SaveManager.get_flag("meta_tutorial_seen"):
        return

    # Show modal explaining meta progression
    var tutorial = _create_tutorial_modal(
        "Permanent Upgrades",
        "Salvage earned from runs can be spent on permanent upgrades that make you stronger!",
        "res://assets/ui/meta_progression_tutorial.png"
    )
    tutorial.show()

    SaveManager.set_flag("meta_tutorial_seen", true)
```

**Success Criteria**:
- [ ] First-run tutorial explains meta progression
- [ ] Tutorial highlights first affordable upgrade
- [ ] Players understand salvage is permanent
- [ ] Tutorial dismissible (won't show again)

---

### Week 14 Option C - Success Metrics

| Metric | Target | Priority |
|--------|--------|----------|
| Meta upgrades implemented | 20-30 upgrades | Must Have |
| Salvage currency functional | Persist between runs | Must Have |
| Upgrade tree UI | Intuitive, clear | Must Have |
| Tutorial integration | First-run onboarding | Should Have |
| Manual QA: "One more run" loop | Positive feedback | Must Have |

**Estimated Effort**: 10-15 hours
**Risk**: Medium (economy balancing, UI complexity)
**Dependencies**: SaveSystem (meta progression persistence)

---

## Option D: Continuous Spawning System

### Overview
Replace burst spawning with continuous trickle spawning to maintain constant pressure throughout waves, matching genre standards (Vampire Survivors, Brotato).

**Effort**: 3-4 hours
**ROI**: High (genre parity, enables proper QA)
**Risk**: Low (isolated system, existing spawn logic)

### Rationale (Sr Mobile Game Designer)
> "Week 13 Phase 3.5 fixed enemy density (8 → 20 enemies), but spawning is still burst-based (all 20 spawn in first 40 seconds, then nothing). Vampire Survivors and Brotato use **continuous spawning** throughout the wave to maintain constant pressure. This is foundational to the genre feel and critical for extended QA sessions with multiple testers."

### Current Implementation Problem

**Current Spawn Pattern (Wave 1)**:
```
0-40s:  Enemy spawns every 2s (20 enemies)
40-60s: NO spawns (all enemies already spawned)
60s:    Wave complete
```

**Issue**: 40-second spawn burst, then 20 seconds of "cleanup mode" with no new threats.

**Genre Standard (Brotato/VS)**:
```
0-60s: Continuous spawning (enemies trickle in throughout wave)
       - Spawn rate: 1-3 enemies every 3-5 seconds
       - Maintains 15-30 living enemies at all times
60s:   Wave complete (kill remaining enemies)
```

### Implementation Plan

#### Phase D1: Continuous Spawn Loop (2 hours)

**Goal**: Replace burst spawning with continuous trickle spawning throughout wave.

**Before**:
```gdscript
# scripts/systems/wave_manager.gd
func start_wave() -> void:
    current_state = WaveState.SPAWNING
    var enemy_count = EnemyService.get_enemy_count_for_wave(current_wave)
    _spawn_wave_enemies(enemy_count)  # Spawns all at once
    current_state = WaveState.COMBAT

func _spawn_wave_enemies(count: int) -> void:
    enemies_remaining = count
    var spawn_rate = EnemyService.get_spawn_rate(current_wave)

    for i in range(count):
        await get_tree().create_timer(spawn_rate).timeout
        _spawn_single_enemy()
```

**After**:
```gdscript
# scripts/systems/wave_manager.gd
var wave_duration: float = 60.0  # 60 seconds per wave
var spawn_timer: float = 0.0
var enemies_spawned_this_wave: int = 0
var total_enemies_for_wave: int = 0

func start_wave() -> void:
    current_state = WaveState.COMBAT
    wave_start_time = Time.get_ticks_msec() / 1000.0
    enemies_spawned_this_wave = 0
    total_enemies_for_wave = EnemyService.get_enemy_count_for_wave(current_wave)
    spawn_timer = 0.0

func _process(delta: float) -> void:
    if current_state != WaveState.COMBAT:
        return

    # Check for wave timeout (60 seconds)
    var elapsed = Time.get_ticks_msec() / 1000.0 - wave_start_time
    if elapsed >= wave_duration:
        _end_wave()
        return

    # Continuous spawning logic
    spawn_timer -= delta
    if spawn_timer <= 0 and enemies_spawned_this_wave < total_enemies_for_wave:
        # Spawn 1-3 enemies per tick
        var spawn_count = min(randi_range(1, 3), total_enemies_for_wave - enemies_spawned_this_wave)
        for i in range(spawn_count):
            _spawn_single_enemy()
            enemies_spawned_this_wave += 1

        # Reset spawn timer (3-5 seconds between spawns)
        spawn_timer = randf_range(3.0, 5.0)

func _end_wave() -> void:
    # Wave ends at 60s - all remaining enemies must be killed
    current_state = WaveState.CLEANUP
    # Wait for all living enemies to be killed before wave complete
```

**Success Criteria**:
- [x] Enemies spawn throughout 60-second wave
- [x] 1-3 enemies per spawn tick (every 3-5 seconds)
- [x] Maintains 15-30 living enemies at all times
- [x] Wave ends at 60s (cleanup mode: kill remaining)

---

#### Phase D2: Enemy Count Throttling (1 hour)

**Goal**: Prevent enemy count from exceeding max capacity (performance + overwhelming).

**Implementation**:
```gdscript
# scripts/systems/wave_manager.gd
const MAX_LIVING_ENEMIES: int = 35  # Cap at 35 to prevent overwhelming

func _process(delta: float) -> void:
    if current_state != WaveState.COMBAT:
        return

    var elapsed = Time.get_ticks_msec() / 1000.0 - wave_start_time
    if elapsed >= wave_duration:
        _end_wave()
        return

    # Only spawn if below max capacity
    if living_enemies.size() >= MAX_LIVING_ENEMIES:
        return

    spawn_timer -= delta
    if spawn_timer <= 0 and enemies_spawned_this_wave < total_enemies_for_wave:
        var spawn_count = min(randi_range(1, 3), total_enemies_for_wave - enemies_spawned_this_wave)

        # Additional check: don't exceed max capacity
        spawn_count = min(spawn_count, MAX_LIVING_ENEMIES - living_enemies.size())

        for i in range(spawn_count):
            _spawn_single_enemy()
            enemies_spawned_this_wave += 1

        spawn_timer = randf_range(3.0, 5.0)
```

**Success Criteria**:
- [x] Living enemies never exceed 35
- [x] Spawn rate slows when approaching capacity
- [x] Spawn rate increases when enemies are killed (maintains pressure)

---

#### Phase D3: Wave Completion Logic (1 hour)

**Goal**: Wave completes when time expires AND all enemies killed (Brotato-style).

**Implementation**:
```gdscript
# scripts/systems/wave_manager.gd
enum WaveState { IDLE, COMBAT, CLEANUP, VICTORY, GAME_OVER }

func _end_wave() -> void:
    """Called when wave timer expires (60 seconds)"""
    current_state = WaveState.CLEANUP
    GameLogger.info("Wave cleanup phase", {"living_enemies": living_enemies.size()})

    # Check if all enemies already dead
    if living_enemies.is_empty():
        _complete_wave()

func _on_enemy_died(enemy_id: String, _drop_data: Dictionary, xp_reward: int) -> void:
    # ... existing death handling ...

    # During cleanup phase, check if all enemies dead
    if current_state == WaveState.CLEANUP and living_enemies.is_empty():
        _complete_wave()

func _complete_wave() -> void:
    """Wave complete - all enemies killed"""
    current_state = WaveState.VICTORY
    var wave_end_time = Time.get_ticks_msec() / 1000.0
    var wave_time = wave_end_time - wave_start_time
    wave_stats["wave_time"] = wave_time

    wave_completed.emit(current_wave, wave_stats)
    all_enemies_killed.emit()

    _show_wave_complete_screen()
```

**Success Criteria**:
- [x] Wave timer displayed in HUD (60 seconds countdown)
- [x] Cleanup phase starts at 60s (no more spawns)
- [x] Wave completes when all enemies killed
- [x] Players understand they must clear remaining enemies

---

### Week 14 Option D - Success Metrics

| Metric | Target | Priority |
|--------|--------|----------|
| Continuous spawning implemented | Throughout 60s wave | Must Have |
| Enemy count throttling | Max 35 living | Must Have |
| Wave completion logic | Time + all killed | Must Have |
| Manual QA: "Constant pressure" | Unanimous feedback | Must Have |
| Performance: 60 FPS maintained | All devices | Must Have |

**Estimated Effort**: 3-4 hours
**Risk**: Low (isolated system, existing spawn logic)
**Dependencies**: Wave Manager, Enemy Service

### Why Combine with Audio (Option A+D)?

**Synergy**:
1. **Audio provides feedback for continuous spawning**: Enemy spawn sounds signal new threats
2. **Continuous spawning justifies weapon audio polish**: More frequent combat = more audio events
3. **Combined package = complete "feel" overhaul**: Professional audio + proper pacing

**QA Benefits**:
- Continuous spawning enables extended playtesting (5-10 minute sessions feel right)
- Audio makes QA sessions more engaging for testers
- Combined package delivers "shippable quality" feel

**Total Effort**: 9-12 hours (6-8h audio + 3-4h spawning)
**Total ROI**: Very High (complete genre parity on feel + pacing)

---

## Recommendation Matrix

| Option | Effort | ROI | Risk | Priority |
|--------|--------|-----|------|----------|
| **A+D: Polish & Pacing Package** | 9-12h | Very High | Low | ⭐⭐⭐⭐ **RECOMMENDED** |
| **A: Audio System** | 6-8h | Very High | Low | ⭐⭐⭐ Good standalone |
| **D: Continuous Spawning** | 3-4h | High | Low | ⭐⭐⭐ Good standalone |
| **B: Boss Enemies** | 8-12h | High | Medium | ⭐⭐ Week 15 candidate |
| **C: Meta Progression** | 10-15h | Very High | Medium | ⭐⭐ Week 15-16 |

---

## Team Consensus (Sr Roles)

**Sr Mobile Game Designer:**
> "**Option A+D (Polish & Pacing Package)** is the clear winner. Week 13 Phase 3.5 fixed density (2.5x increase), but iOS testing revealed we need continuous spawning for proper genre feel. Combining audio + continuous spawning delivers complete professional feel AND enables extended QA sessions with multiple testers. This is foundational work that unblocks proper playtesting."

**Sr Product Manager:**
> "Option A+D combines two high-ROI systems for one cohesive deliverable. Audio makes the game **shareable** (players record clips). Continuous spawning makes QA **viable** (5-10 minute sessions feel right). Total effort is 9-12h - still very manageable for Week 14. **This unblocks multi-tester QA**, which is critical before adding meta progression or bosses."

**Sr Software Engineer:**
> "Option A+D is still low-risk (both systems are isolated). Audio = AudioStreamPlayer2D. Continuous spawning = replace burst loop with _process() timer. No complex dependencies. Option C (meta progression) and Option B (bosses) both require extensive balancing - better to do after we have proper QA infrastructure in place."

**Sr Mobile UI/UX:**
> "Audio is **table stakes** for mobile games. Continuous spawning is **table stakes** for the genre. Both need to be in place before we can do meaningful QA sessions with external testers. Without these, testers will immediately notice the game feels 'incomplete' - which wastes their time and ours."

**Sr Godot 4.5.1 Specialist:**
> "Option A+D is straightforward. AudioStreamPlayer2D + asset sourcing (6-8h). WaveManager _process() loop + spawn timer (3-4h). Both leverage existing Godot systems. Boss enemies and meta progression are larger scope - better to tackle after we have polished pacing foundation."

---

## Recommendation: Week 14 = Option A+D (Polish & Pacing Package)

### Why Option A+D?
1. **Highest combined ROI** (9-12 hours for complete "feel" overhaul)
2. **Low risk** (both systems isolated, no complex dependencies)
3. **Completes genre parity** (audio + continuous spawning = industry standard)
4. **Enables multi-tester QA** (5-10 minute sessions feel complete, not hollow)
5. **Synergistic systems** (audio provides feedback for spawn events)
6. **Unblocks future work** (can't properly QA bosses/meta without proper pacing)

### What Gets Delivered?
**Audio System (6-8h)**:
- Weapon firing sounds (10 weapons)
- Enemy audio (spawn, damage, death)
- Ambient audio (wave start/complete, low HP warning)
- UI audio (button clicks, character selection)

**Continuous Spawning (3-4h)**:
- 60-second wave timer with trickle spawning
- Enemy count throttling (max 35 living)
- Cleanup phase (kill remaining enemies to complete wave)
- Constant pressure throughout wave (genre standard)

### Week 15 Plan (Post-Polish Package)
- **Option C: Meta Progression** (10-15h) - retention driver, monetization foundation
- OR **Option B: Boss Enemies** (8-12h) - content expansion, milestone moments
- Proper QA infrastructure now in place for testing either system

### Week 16 Plan
- Implement whichever wasn't chosen in Week 15
- Polish pass (tutorials, onboarding, balance tuning)
- External playtesting with polished build

---

## Next Steps

1. **User Decision Required**: Finalize Week 14 scope (Option A+D recommended)
2. **If Option A+D**:
   - Asset sourcing (Kenney Audio Pack, 1 hour)
   - WaveManager refactor planning (identify test coverage gaps)
   - HUD updates (wave timer display)
3. **If Option B (Bosses)**: Design boss mechanics (2-3 boss types)
4. **If Option C (Meta)**: Economy design (upgrade costs, salvage conversion rates)

**Estimated Timeline**:
- Week 14: Polish & Pacing Package (9-12 hours) ⭐⭐⭐⭐ **RECOMMENDED**
- Week 15: Meta Progression (10-15 hours) OR Boss Enemies (8-12 hours)
- Week 16: Remaining system + polish + extended playtesting

---

**Ready for Week 14 execution!** 🚀
