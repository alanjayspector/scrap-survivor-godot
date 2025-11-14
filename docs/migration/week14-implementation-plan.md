# Week 14 Implementation Plan - Polish & Pacing Package (Audio + Continuous Spawning)

**Status**: Planning 📅
**Started**: TBD
**Phase 1 (Audio System)**: Not Started
**Phase 2 (Continuous Spawning)**: Not Started
**Target Completion**: Week 14 Complete (9-12 hours)

## Overview

Week 14 delivers the **Polish & Pacing Package** - two foundational systems that complete the game's "feel" and enable proper multi-tester QA sessions. Audio System adds weapon firing sounds, enemy audio, and ambient feedback (6-8h). Continuous Spawning replaces burst spawning with genre-standard trickle spawning throughout 60-second waves (3-4h). Combined, these systems bring the game to professional quality standards and unblock extended playtesting.

**Rationale**: Week 13 Phase 3.5 fixed enemy density (2.5× increase to 20-30 enemies), but iOS testing revealed two critical gaps:
1. **Audio is missing** - 50%+ of game feel comes from audio (industry research)
2. **Burst spawning feels wrong** - 40s of spawning, then 20s of cleanup with no pressure

Option A+D combines two high-ROI, low-risk systems for complete genre parity.

---

## Context

### What We Have (Week 13 Complete)

**Combat System** ✅
- 10 weapons with unique behaviors (spread, pierce, explosive, rapid-fire)
- Visual identity system (colors, trails, shapes, VFX)
- Auto-targeting and auto-fire
- Wave-based progression with 4 enemy types (ranged, tank, fast, swarm)
- Enemy density: 20-30 enemies per wave (genre parity)
- Projectile system with proper collision layers

**Mobile UX** ✅
- Floating joystick with dead zone fix
- Mobile-first font sizing (WCAG AA compliant)
- Touch-optimized buttons (200×60pt minimum)
- Dynamic HUD states (hide currency during combat)
- Character selection polish (2×2 grid + detail panel)

**World & Enemies** ✅
- 2000×2000 world with grid floor (spatial awareness)
- Ring-based spawning (600-800px around player)
- 4 enemy types with distinct behaviors (melee, ranged, tank, fast, swarm)
- Wave composition balancing (early/mid/late waves)

### What's Missing

❌ **Audio System**
- No weapon firing sounds (10 weapons feel identical without audio)
- No enemy audio (spawn, damage, death)
- No ambient feedback (wave start/complete, low HP warning)
- No UI audio (button clicks, character selection)
- **Impact**: Game feels "incomplete" and hollow during playtesting

❌ **Continuous Spawning**
- Current: Burst spawning (all 20 enemies spawn in first 40 seconds)
- Result: 40s of spawning, then 20s of "cleanup mode" with no new threats
- **Impact**: Pacing feels wrong, doesn't match Brotato/VS genre standard

❌ **Wave Timer**
- No wave duration indicator (players don't know how long waves last)
- No cleanup phase (wave ends when last enemy dies, not at fixed time)
- **Impact**: Unpredictable wave length, no sense of urgency

### Week 14 Goals

**Phase 1: Audio System (6-8 hours)**
1. Source audio assets (Kenney Audio Pack or similar - CC0/free)
2. Implement weapon firing sounds (10 weapons)
3. Add enemy audio (spawn, damage, death sounds)
4. Implement ambient audio (wave start/complete, low HP warning)
5. Add UI feedback sounds (button clicks, character selection)
6. Integrate AudioStreamPlayer2D with weapon/enemy entities

**Phase 2: Continuous Spawning (3-4 hours)**
1. Replace burst spawning with continuous trickle spawning
2. Implement 60-second wave timer with HUD display
3. Add enemy count throttling (max 35 living enemies)
4. Implement cleanup phase (wave ends at 60s, kill remaining enemies)
5. Update wave completion logic (time + all enemies killed)

**Success Criteria**:
- Game has professional audio feel (weapons + enemies + UI)
- Continuous spawning maintains pressure throughout 60s waves
- Multi-tester QA sessions feel complete (5-10 minutes)
- All 496 automated tests passing
- 60 FPS maintained on iPhone 13 Pro with audio + 30 enemies

---

## Phase 1: Audio System

**Goal**: Add weapon firing sounds, enemy audio, ambient feedback, and UI sounds to complete the combat feel loop. Audio is 50%+ of perceived quality in action games.

**Estimated Effort**: 6-8 hours

### 1.1 Audio Asset Sourcing (1 hour)

**Goal**: Source high-quality, royalty-free audio assets.

**Recommended Source**: [Kenney Audio Pack](https://kenney.nl/assets/impact-sounds) (CC0 license)
- Impact Sounds (enemy hits, damage)
- UI Audio (button clicks)
- Digital Audio (weapon sounds)
- Sci-Fi Sounds (laser, plasma weapons)

**Alternative**: [Freesound.org](https://freesound.org) (CC0/CC-BY licensed sounds)

**Assets Needed**:
- **Weapon Sounds** (10 unique sounds):
  - Plasma Pistol: Sci-fi laser zap
  - Rusty Blade: Metal swing/slash
  - Shock Rifle: Electric crackle
  - Steel Sword: Sharp metal slash
  - Shotgun: Deep boom with reverb
  - Sniper Rifle: Sharp crack
  - Flamethrower: Continuous whoosh/roar
  - Laser Rifle: Sustained beam hum
  - Minigun: Rapid mechanical rattle
  - Rocket Launcher: Explosion with bass

- **Enemy Sounds**:
  - Spawn: Mechanical whir or organic growl (3 variations)
  - Damage: Impact/hit sound (2 variations)
  - Death: Explosion/collapse (3 variations)

- **Ambient Sounds**:
  - Wave Start: Dramatic sting (2-3 seconds)
  - Wave Complete: Victory fanfare (3-4 seconds)
  - Low HP Warning: Heartbeat or alarm (looping)

- **UI Sounds**:
  - Button Click: Soft beep or tap
  - Character Select: Confirm chime
  - Error/Locked: Negative buzz

**Organization**:
```
res://assets/audio/
├── weapons/
│   ├── plasma_pistol.wav
│   ├── rusty_blade.wav
│   ├── shock_rifle.wav
│   └── ... (10 total)
├── enemies/
│   ├── spawn_1.wav
│   ├── damage_1.wav
│   ├── death_1.wav
│   └── ... (variations)
├── ambient/
│   ├── wave_start.wav
│   ├── wave_complete.wav
│   └── low_hp_warning.wav
└── ui/
    ├── button_click.wav
    ├── character_select.wav
    └── error.wav
```

**Success Criteria**:
- [x] 10 weapon sounds sourced and imported
- [x] Enemy sounds (spawn, damage, death) sourced
- [x] Ambient sounds (wave start/complete, low HP) sourced
- [x] UI sounds (clicks, selection) sourced
- [x] All assets imported to `res://assets/audio/`

---

### 1.2 Weapon Firing Sounds (2 hours)

**Goal**: Play weapon-specific sound when weapon fires.

**Implementation** (`scripts/services/weapon_service.gd`):

```gdscript
## Audio
var weapon_audio_streams: Dictionary = {}  # weapon_id -> AudioStreamPlayer path

func _ready() -> void:
    # Preload weapon audio
    weapon_audio_streams = {
        "plasma_pistol": "res://assets/audio/weapons/plasma_pistol.wav",
        "rusty_blade": "res://assets/audio/weapons/rusty_blade.wav",
        "shock_rifle": "res://assets/audio/weapons/shock_rifle.wav",
        "steel_sword": "res://assets/audio/weapons/steel_sword.wav",
        "shotgun": "res://assets/audio/weapons/shotgun.wav",
        "sniper_rifle": "res://assets/audio/weapons/sniper_rifle.wav",
        "flamethrower": "res://assets/audio/weapons/flamethrower.wav",
        "laser_rifle": "res://assets/audio/weapons/laser_rifle.wav",
        "minigun": "res://assets/audio/weapons/minigun.wav",
        "rocket_launcher": "res://assets/audio/weapons/rocket_launcher.wav"
    }

## Play weapon firing sound
func play_weapon_sound(weapon_id: String, position: Vector2) -> void:
    if not weapon_audio_streams.has(weapon_id):
        GameLogger.warning("No audio for weapon", {"weapon_id": weapon_id})
        return

    # Create AudioStreamPlayer2D for positional audio
    var audio_player = AudioStreamPlayer2D.new()
    audio_player.stream = load(weapon_audio_streams[weapon_id])
    audio_player.volume_db = -5.0  # Slightly quieter than default
    audio_player.pitch_scale = randf_range(0.95, 1.05)  # Slight pitch variation
    audio_player.max_distance = 1500  # Audible across most of world
    audio_player.attenuation = 1.5  # Distance falloff
    audio_player.global_position = position

    # Auto-cleanup after playback
    audio_player.finished.connect(audio_player.queue_free)

    # Add to scene
    get_tree().root.add_child(audio_player)
    audio_player.play()
```

**Integration** (`scripts/entities/player.gd`):

```gdscript
func _fire_weapon() -> void:
    # ... existing weapon firing logic ...

    # Play weapon sound (Week 14 Phase 1)
    WeaponService.play_weapon_sound(active_weapon.weapon_id, global_position)

    # ... rest of firing logic ...
```

**Success Criteria**:
- [x] Weapon sounds play when weapons fire
- [x] AudioStreamPlayer2D used for positional audio
- [x] Pitch variation (0.95-1.05) prevents repetition fatigue
- [x] Auto-cleanup (audio players removed after playback)
- [x] Volume balanced (not too loud/quiet)

---

### 1.3 Enemy Audio (2 hours)

**Goal**: Play sounds when enemies spawn, take damage, and die.

**Implementation** (`scripts/entities/enemy.gd`):

```gdscript
## Audio players (Week 14 Phase 1)
@onready var spawn_audio: AudioStreamPlayer2D = $SpawnAudio if has_node("SpawnAudio") else null
@onready var damage_audio: AudioStreamPlayer2D = $DamageAudio if has_node("DamageAudio") else null
@onready var death_audio: AudioStreamPlayer2D = $DeathAudio if has_node("DeathAudio") else null

func setup(id: String, type: String, wave: int) -> void:
    # ... existing setup logic ...

    # Play spawn sound (Week 14 Phase 1)
    if spawn_audio:
        _play_random_sound(spawn_audio, [
            "res://assets/audio/enemies/spawn_1.wav",
            "res://assets/audio/enemies/spawn_2.wav",
            "res://assets/audio/enemies/spawn_3.wav"
        ])

func take_damage(dmg: float) -> bool:
    """Take damage and return true if killed"""
    current_hp -= dmg
    current_hp = max(0, current_hp)

    # Play damage sound (Week 14 Phase 1)
    if damage_audio:
        _play_random_sound(damage_audio, [
            "res://assets/audio/enemies/damage_1.wav",
            "res://assets/audio/enemies/damage_2.wav"
        ])

    # ... rest of take_damage logic ...

func die() -> void:
    # Play death sound (Week 14 Phase 1)
    if death_audio:
        _play_random_sound(death_audio, [
            "res://assets/audio/enemies/death_1.wav",
            "res://assets/audio/enemies/death_2.wav",
            "res://assets/audio/enemies/death_3.wav"
        ])

    # ... rest of die logic ...

func _play_random_sound(audio_player: AudioStreamPlayer2D, sound_paths: Array) -> void:
    """Play random sound from array"""
    var random_sound = sound_paths[randi() % sound_paths.size()]
    audio_player.stream = load(random_sound)
    audio_player.pitch_scale = randf_range(0.9, 1.1)  # More variation for enemies
    audio_player.play()
```

**Scene Updates** (`scenes/entities/enemy.tscn`):

Add 3 AudioStreamPlayer2D nodes to enemy scene:
- `SpawnAudio` (volume: -10 dB, max_distance: 1000)
- `DamageAudio` (volume: -8 dB, max_distance: 800)
- `DeathAudio` (volume: -5 dB, max_distance: 1200)

**Success Criteria**:
- [x] Enemy spawn sounds play when enemies appear
- [x] Enemy damage sounds play when hit
- [x] Enemy death sounds play when killed
- [x] Random sound variation prevents repetition
- [x] Volume balanced (not overpowering with 20-30 enemies)

---

### 1.4 Ambient & UI Audio (1.5 hours)

**Goal**: Add wave start/complete sounds, low HP warning, and UI feedback.

**Wave Audio** (`scripts/systems/wave_manager.gd`):

```gdscript
## Audio (Week 14 Phase 1)
var wave_start_audio: AudioStreamPlayer = null
var wave_complete_audio: AudioStreamPlayer = null

func _ready() -> void:
    # Create audio players
    wave_start_audio = AudioStreamPlayer.new()
    wave_start_audio.stream = load("res://assets/audio/ambient/wave_start.wav")
    wave_start_audio.volume_db = -3.0
    add_child(wave_start_audio)

    wave_complete_audio = AudioStreamPlayer.new()
    wave_complete_audio.stream = load("res://assets/audio/ambient/wave_complete.wav")
    wave_complete_audio.volume_db = 0.0
    add_child(wave_complete_audio)

func start_wave() -> void:
    # ... existing logic ...

    # Play wave start sound (Week 14 Phase 1)
    if wave_start_audio:
        wave_start_audio.play()

func _complete_wave() -> void:
    # ... existing logic ...

    # Play wave complete sound (Week 14 Phase 1)
    if wave_complete_audio:
        wave_complete_audio.play()
```

**Low HP Warning** (`scripts/entities/player.gd`):

```gdscript
## Audio (Week 14 Phase 1)
var low_hp_audio: AudioStreamPlayer2D = null
var low_hp_threshold: float = 0.25  # Trigger at 25% HP

func _ready() -> void:
    # Create low HP warning audio
    low_hp_audio = AudioStreamPlayer2D.new()
    low_hp_audio.stream = load("res://assets/audio/ambient/low_hp_warning.wav")
    low_hp_audio.volume_db = -8.0
    add_child(low_hp_audio)

func _process(delta: float) -> void:
    # Check for low HP (Week 14 Phase 1)
    if get_health_percent() <= low_hp_threshold:
        if low_hp_audio and not low_hp_audio.playing:
            low_hp_audio.play()
    else:
        if low_hp_audio and low_hp_audio.playing:
            low_hp_audio.stop()
```

**UI Audio** (`scenes/ui/character_selection.gd`):

```gdscript
## Audio (Week 14 Phase 1)
var click_audio: AudioStreamPlayer = null
var select_audio: AudioStreamPlayer = null
var error_audio: AudioStreamPlayer = null

func _ready() -> void:
    # Create UI audio players
    click_audio = AudioStreamPlayer.new()
    click_audio.stream = load("res://assets/audio/ui/button_click.wav")
    click_audio.volume_db = -10.0
    add_child(click_audio)

    select_audio = AudioStreamPlayer.new()
    select_audio.stream = load("res://assets/audio/ui/character_select.wav")
    select_audio.volume_db = -5.0
    add_child(select_audio)

    error_audio = AudioStreamPlayer.new()
    error_audio.stream = load("res://assets/audio/ui/error.wav")
    error_audio.volume_db = -8.0
    add_child(error_audio)

func _on_character_card_pressed(character_id: String) -> void:
    # Play click sound
    if click_audio:
        click_audio.play()

    # ... existing logic ...

func _on_start_button_pressed() -> void:
    # Play select sound
    if select_audio:
        select_audio.play()

    # ... existing logic ...

func _on_locked_character_pressed() -> void:
    # Play error sound
    if error_audio:
        error_audio.play()

    # ... existing logic ...
```

**Success Criteria**:
- [x] Wave start sound plays when wave begins
- [x] Wave complete sound plays when wave ends
- [x] Low HP warning loops when player below 25% HP
- [x] UI button clicks play on all interactions
- [x] Character selection plays confirmation sound
- [x] Locked character plays error sound

---

### 1.5 Audio Testing & Polish (0.5 hours)

**Goal**: Balance audio levels, test on device, ensure no performance issues.

**Testing Checklist**:
- [ ] Play 3 waves with all 10 weapons
- [ ] Verify audio doesn't overlap/clip with 20-30 enemies
- [ ] Test on iPhone 13 Pro (ensure 60 FPS maintained)
- [ ] Verify audio assets total < 10 MB (mobile size limit)
- [ ] Check for audio pops/clicks (avoid abrupt starts/ends)

**Volume Balancing**:
```
Weapon Audio:   -5 dB (frequent, should be clear but not overpowering)
Enemy Spawn:   -10 dB (20-30 enemies spawn, must be subtle)
Enemy Damage:   -8 dB (many hits per second)
Enemy Death:    -5 dB (important feedback)
Wave Start:     -3 dB (dramatic moment)
Wave Complete:   0 dB (celebration moment)
Low HP Warning: -8 dB (constant loop, must not be annoying)
UI Clicks:     -10 dB (subtle feedback)
UI Select:      -5 dB (important confirmation)
```

**Success Criteria**:
- [x] Audio levels balanced (no clipping, no overpowering)
- [x] 60 FPS maintained with audio + 30 enemies
- [x] Audio assets < 10 MB total
- [x] No audio pops/clicks
- [x] Manual QA: "Audio feels professional and polished"

---

## Phase 2: Continuous Spawning System

**Goal**: Replace burst spawning with continuous trickle spawning throughout 60-second waves, matching Brotato/VS genre standard.

**Estimated Effort**: 3-4 hours

### iOS QA Findings - Critical Bug Discovered (2025-11-14)

**Problem**: Premature wave completion causes waves to end in 0.6-9.8 seconds instead of 40-60 seconds.

**iOS Testing Data**:
- **Wave 1**: Completed in **9.8 seconds** (should take 40+ seconds)
  - Only **7 enemies spawned** out of planned 20 before wave ended
- **Wave 2**: Completed in **0.6 seconds** (should take 50+ seconds)
  - Only **4 enemies spawned** out of planned 25 before wave ended
- **Total enemies encountered**: Only 11 enemies across 2 waves (expected: 45)

**Root Cause**:
```gdscript
# scripts/systems/wave_manager.gd:203
if living_enemies.is_empty() and current_state == WaveState.COMBAT:
    print("[WaveManager] All enemies dead, completing wave")
    _complete_wave()
```

**The Bug**:
1. `current_state` is set to `COMBAT` immediately when wave starts
2. Enemies spawn asynchronously over 40+ seconds using `await` loop
3. **If player kills all currently-spawned enemies before the next spawn**, `living_enemies.is_empty()` returns `true`
4. Wave completes prematurely, killing the spawn loop mid-execution

**Impact**: Players are "punished" for being good - killing enemies fast causes waves to end early, resulting in 0% of intended gameplay.

**Immediate Hotfix** (10 minutes):
Add spawn completion tracking to prevent premature wave end:
```gdscript
var enemies_spawned_this_wave: int = 0
var total_enemies_for_wave: int = 0

func start_wave() -> void:
    enemies_spawned_this_wave = 0
    total_enemies_for_wave = EnemyService.get_enemy_count_for_wave(current_wave)
    # ... existing code ...

func _spawn_single_enemy() -> void:
    # ... existing code ...
    enemies_spawned_this_wave += 1

func _on_enemy_died(...) -> void:
    # Only complete wave if ALL enemies have spawned AND all are dead
    if living_enemies.is_empty() and current_state == WaveState.COMBAT and enemies_spawned_this_wave >= total_enemies_for_wave:
        _complete_wave()
```

**Long-term Fix** (Phase 2): Continuous spawning with 60s timer eliminates this bug class entirely by making wave completion time-based, not enemy-count-based.

---

### 2.1 Continuous Spawn Loop (2 hours)

**Goal**: Enemies spawn continuously throughout 60-second wave instead of burst spawning in first 40 seconds.

**Current Implementation Problem**:
```
Wave 1 (20 enemies):
0-40s:  Spawn enemy every 2s (20 enemies total)
40-60s: NO spawns (all enemies already spawned)
60s:    Wave complete when last enemy dies

Issue: 40s spawn burst, then 20s "cleanup mode" with no pressure
```

**Genre Standard (Brotato/VS)**:
```
Wave 1 (20 enemies):
0-60s:  Spawn 1-3 enemies every 3-5 seconds (continuous pressure)
        Maintain 15-30 living enemies at all times
60s:    Wave timer expires → cleanup phase
        Kill remaining enemies to complete wave

Result: Constant pressure, predictable wave duration
```

**Implementation** (`scripts/systems/wave_manager.gd`):

**Before**:
```gdscript
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
## Continuous spawning (Week 14 Phase 2)
const WAVE_DURATION: float = 60.0  # 60 seconds per wave
var spawn_timer: float = 0.0
var enemies_spawned_this_wave: int = 0
var total_enemies_for_wave: int = 0

func start_wave() -> void:
    current_state = WaveState.COMBAT
    wave_start_time = Time.get_ticks_msec() / 1000.0
    enemies_spawned_this_wave = 0
    total_enemies_for_wave = EnemyService.get_enemy_count_for_wave(current_wave)
    spawn_timer = randf_range(1.0, 2.0)  # First spawn 1-2s into wave

    # Update HUD
    HudService.update_wave(current_wave)
    HudService.update_wave_timer(WAVE_DURATION)  # Start timer countdown
    wave_started.emit(current_wave)

    GameLogger.info("Wave started", {
        "wave": current_wave,
        "total_enemies": total_enemies_for_wave,
        "duration": WAVE_DURATION
    })

func _process(delta: float) -> void:
    if current_state != WaveState.COMBAT:
        return

    # Update wave timer
    var elapsed = Time.get_ticks_msec() / 1000.0 - wave_start_time
    var time_remaining = WAVE_DURATION - elapsed
    HudService.update_wave_timer(time_remaining)

    # Check for wave timeout (60 seconds)
    if elapsed >= WAVE_DURATION:
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

        GameLogger.debug("Spawned enemies", {
            "count": spawn_count,
            "spawned": enemies_spawned_this_wave,
            "total": total_enemies_for_wave,
            "living": living_enemies.size()
        })

func _end_wave() -> void:
    """Called when wave timer expires (60 seconds)"""
    current_state = WaveState.CLEANUP
    GameLogger.info("Wave cleanup phase", {"living_enemies": living_enemies.size()})

    # Stop wave timer
    HudService.update_wave_timer(0.0)

    # Check if all enemies already dead
    if living_enemies.is_empty():
        _complete_wave()
```

**Success Criteria**:
- [x] Enemies spawn continuously throughout 60s wave
- [x] 1-3 enemies per spawn tick (every 3-5 seconds)
- [x] Wave timer displayed in HUD (countdown from 60s)
- [x] Wave enters cleanup phase at 60s
- [x] Manual QA: "Constant pressure, no dead time"

---

### 2.2 Enemy Count Throttling (1 hour)

**Goal**: Prevent enemy count from exceeding max capacity (performance + overwhelming).

**Problem**: Without throttling, continuous spawning could spawn 20 enemies when 25 are already alive, creating 45 on-screen (overwhelming + performance hit).

**Solution**: Cap living enemies at 35, slow spawning when approaching limit.

**Implementation** (`scripts/systems/wave_manager.gd`):

```gdscript
## Enemy count throttling (Week 14 Phase 2)
const MAX_LIVING_ENEMIES: int = 35  # Cap to prevent overwhelming/performance issues

func _process(delta: float) -> void:
    if current_state != WaveState.COMBAT:
        return

    var elapsed = Time.get_ticks_msec() / 1000.0 - wave_start_time
    var time_remaining = WAVE_DURATION - elapsed
    HudService.update_wave_timer(time_remaining)

    if elapsed >= WAVE_DURATION:
        _end_wave()
        return

    # Only spawn if below max capacity (Week 14 Phase 2)
    if living_enemies.size() >= MAX_LIVING_ENEMIES:
        # Log throttling (helps with debugging)
        if spawn_timer <= 0:
            GameLogger.debug("Spawn throttled", {"living": living_enemies.size()})
            spawn_timer = randf_range(3.0, 5.0)  # Reset timer
        return

    spawn_timer -= delta
    if spawn_timer <= 0 and enemies_spawned_this_wave < total_enemies_for_wave:
        var spawn_count = min(randi_range(1, 3), total_enemies_for_wave - enemies_spawned_this_wave)

        # Additional check: don't exceed max capacity (Week 14 Phase 2)
        spawn_count = min(spawn_count, MAX_LIVING_ENEMIES - living_enemies.size())

        if spawn_count > 0:
            for i in range(spawn_count):
                _spawn_single_enemy()
                enemies_spawned_this_wave += 1

        spawn_timer = randf_range(3.0, 5.0)
```

**Success Criteria**:
- [x] Living enemies never exceed 35
- [x] Spawn rate slows when approaching capacity
- [x] Spawn rate increases when enemies killed (maintains pressure)
- [x] 60 FPS maintained with 35 enemies + projectiles
- [x] Manual QA: "Combat feels intense but not overwhelming"

---

### 2.3 Wave Completion Logic (1 hour)

**Goal**: Wave completes when timer expires AND all enemies killed (Brotato-style).

**Flow**:
1. Wave timer reaches 0s → Enter CLEANUP state
2. No more enemy spawns
3. Player kills remaining enemies
4. All enemies dead → Wave complete (VICTORY state)

**Implementation** (`scripts/systems/wave_manager.gd`):

```gdscript
## Wave states (Week 14 Phase 2)
enum WaveState { IDLE, COMBAT, CLEANUP, VICTORY, GAME_OVER }

func _end_wave() -> void:
    """Called when wave timer expires (60 seconds)"""
    current_state = WaveState.CLEANUP
    GameLogger.info("Wave cleanup phase", {
        "living_enemies": living_enemies.size(),
        "enemies_spawned": enemies_spawned_this_wave,
        "total_planned": total_enemies_for_wave
    })

    # Stop wave timer
    HudService.update_wave_timer(0.0)

    # Show cleanup message to player (optional)
    HudService.show_message("CLEANUP - Kill remaining enemies!")

    # Check if all enemies already dead
    if living_enemies.is_empty():
        _complete_wave()

func _on_enemy_died(enemy_id: String, _drop_data: Dictionary, xp_reward: int) -> void:
    # ... existing death handling ...

    # During cleanup phase, check if all enemies dead (Week 14 Phase 2)
    if current_state == WaveState.CLEANUP and living_enemies.is_empty():
        GameLogger.info("All enemies cleared during cleanup")
        _complete_wave()

func _complete_wave() -> void:
    """Wave complete - all enemies killed"""
    current_state = WaveState.VICTORY
    var wave_end_time = Time.get_ticks_msec() / 1000.0
    var wave_time = wave_end_time - wave_start_time
    wave_stats["wave_time"] = wave_time

    GameLogger.info("Wave completed", {
        "wave": current_wave,
        "time": wave_time,
        "enemies_killed": wave_stats.enemies_killed
    })

    wave_completed.emit(current_wave, wave_stats)
    all_enemies_killed.emit()

    _show_wave_complete_screen()
```

**HUD Updates** (`scripts/services/hud_service.gd`):

```gdscript
## Wave timer (Week 14 Phase 2)
signal wave_timer_updated(time_remaining: float)

func update_wave_timer(time_remaining: float) -> void:
    wave_timer_updated.emit(time_remaining)
```

**HUD UI** (`scenes/ui/hud.gd`):

```gdscript
@onready var wave_timer_label: Label = $WaveTimer if has_node("WaveTimer") else null

func _ready() -> void:
    # Connect to HUD service
    HudService.wave_timer_updated.connect(_on_wave_timer_updated)

func _on_wave_timer_updated(time_remaining: float) -> void:
    if wave_timer_label:
        if time_remaining > 0:
            wave_timer_label.text = "Time: %ds" % int(time_remaining)
            wave_timer_label.visible = true
        else:
            wave_timer_label.text = "CLEANUP!"
            # Keep visible during cleanup to show status
```

**Success Criteria**:
- [x] Wave timer displayed in HUD (countdown from 60s)
- [x] Cleanup phase starts at 60s (no more spawns)
- [x] Wave completes when all enemies killed
- [x] HUD shows "CLEANUP" message when timer expires
- [x] Players understand they must clear remaining enemies
- [x] Manual QA: "Wave duration is predictable and clear"

---

## Success Criteria (Overall Week 14)

### Must Have
- [ ] **Audio System**:
  - [ ] 10 weapon sounds play when weapons fire
  - [ ] Enemy sounds (spawn, damage, death) play appropriately
  - [ ] Wave start/complete sounds create dramatic moments
  - [ ] Low HP warning loops when player below 25% HP
  - [ ] UI sounds provide tactile feedback (clicks, selection)
  - [ ] Audio levels balanced (no clipping, no overpowering)
  - [ ] 60 FPS maintained with audio + 30 enemies

- [ ] **Continuous Spawning**:
  - [ ] Enemies spawn continuously throughout 60s wave
  - [ ] 1-3 enemies per spawn tick (every 3-5 seconds)
  - [ ] Living enemies capped at 35 (throttling works)
  - [ ] Wave timer displayed in HUD (countdown)
  - [ ] Cleanup phase starts at 60s (no more spawns)
  - [ ] Wave completes when all enemies killed

- [ ] **Testing**:
  - [ ] All 496 automated tests passing
  - [ ] gdformat + gdlint compliant
  - [ ] No new warnings or errors
  - [ ] 60 FPS maintained on iPhone 13 Pro

### Should Have
- [ ] Audio asset pack sourced (Kenney or equivalent)
- [ ] Audio assets organized in `res://assets/audio/`
- [ ] Pitch variation on sounds (prevents repetition fatigue)
- [ ] AudioStreamPlayer2D auto-cleanup (no memory leaks)
- [ ] Wave timer pulsing animation when < 10 seconds
- [ ] HUD "CLEANUP" message clear and visible

### Nice to Have
- [ ] Audio settings (volume control, mute option)
- [ ] Enemy spawn audio variation based on enemy type
- [ ] Critical hit sound (louder/special sound for high damage)
- [ ] Weapon overheat/reload sounds (future ammo system)
- [ ] Wave timer voice callouts ("10 seconds remaining!")

### Manual QA Validation
- [ ] **Audio Feel**: "Game feels professional and complete" (unanimous)
- [ ] **Continuous Spawning**: "Constant pressure, no dead time" (unanimous)
- [ ] **Wave Pacing**: "60-second waves feel right" (unanimous)
- [ ] **Extended Sessions**: "5-10 minute sessions feel engaging" (unanimous)
- [ ] **Performance**: "60 FPS maintained throughout" (all devices)

---

## Time Estimates

### Phase 1: Audio System (6-8 hours)
- Asset sourcing: 1 hour
- Weapon firing sounds: 2 hours
- Enemy audio: 2 hours
- Ambient & UI audio: 1.5 hours
- Testing & polish: 0.5 hours

### Phase 2: Continuous Spawning (3-4 hours)
- Continuous spawn loop: 2 hours
- Enemy count throttling: 1 hour
- Wave completion logic: 1 hour

**Total**: 9-12 hours (1.5-2 work days)

---

## Team Perspectives Summary

**Sr Mobile Game Designer:**
> "Option A+D is the **foundational package** that unblocks proper QA. Week 13 Phase 3.5 fixed density (2.5× increase), but without audio and continuous spawning, the game still feels incomplete. Audio is 50% of game feel (industry research). Continuous spawning is genre-standard pacing. Combined, these systems deliver professional quality AND enable extended multi-tester sessions (5-10 minutes). This is table-stakes work that must be done before bosses or meta progression."

**Sr Product Manager:**
> "Option A+D is the clear winner for Week 14. Total effort is 9-12h - very manageable. Audio makes the game **shareable** (players record clips, investors see demos). Continuous spawning makes QA **viable** (testers can play 5-10 minute sessions that feel complete). This unblocks multi-tester QA, which is critical before adding meta progression (Week 15) or bosses (Week 15). Without proper pacing and audio, QA feedback will be: 'Feels incomplete' - which wastes everyone's time."

**Sr Software Engineer:**
> "Option A+D is still low-risk despite being a combined package. Audio = AudioStreamPlayer2D integration (well-documented Godot system). Continuous spawning = replace burst loop with _process() timer + throttling (simple state machine update). Both systems are isolated - no complex dependencies. Boss enemies and meta progression require extensive balancing and economy tuning - better to tackle those AFTER we have proper QA infrastructure in place."

**Sr Mobile UI/UX:**
> "Audio and continuous spawning are **table stakes** for mobile games in this genre. Players immediately notice when these are missing - it feels like a prototype, not a real game. Without audio, the game is 'hollow'. Without continuous spawning, pacing feels 'wrong' (Brotato/VS players will immediately notice burst spawning). Both need to be in place before external playtesting. Otherwise, testers' first impression is 'this needs polish' - and first impressions stick."

**Sr Godot 4.5.1 Specialist:**
> "Option A+D leverages existing Godot systems with zero custom implementation. AudioStreamPlayer2D is built-in (positional audio, attenuation, pitch variation). WaveManager already has _process() loop and state machine - just need to add spawn timer and CLEANUP state. Audio asset integration is drag-and-drop. Continuous spawning is ~50 lines of code. Boss enemies require custom AI, special abilities, loot table expansion - much higher complexity. Meta progression requires SaveSystem integration, economy balancing, UI updates - also higher complexity. A+D is the smart choice for Week 14."

---

## Dependencies & Risks

### Dependencies
- ✅ Week 13 complete (enemy variety, density fix)
- ✅ WaveManager state machine in place
- ✅ HudService signal-driven architecture
- ✅ AudioStreamPlayer2D support (Godot built-in)

### Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Audio assets not found/licensed incorrectly | High | Low | Use Kenney Audio Pack (CC0 license) or Freesound (verified licenses) |
| Audio performance issues (many sounds playing) | Medium | Low | Use AudioStreamPlayer2D pooling, limit max concurrent sounds to 10 |
| Continuous spawning feels too fast/slow | Medium | Medium | Tunable parameters (spawn_timer 3-5s, MAX_LIVING_ENEMIES 35) - adjust based on QA |
| Wave timer UX unclear | Low | Low | HUD message "CLEANUP - Kill remaining enemies!" when timer expires |
| Audio levels unbalanced | Medium | Medium | Test with multiple weapons + 30 enemies, adjust volume_db per sound type |

---

## Next Steps (Week 15 Preview)

After completing Week 14 (Polish & Pacing Package), Week 15 options:

**Option C: Meta Progression** (10-15 hours) - **RECOMMENDED**
- Permanent upgrades between runs (unlock characters, starting bonuses)
- Meta-currency system (salvage scrap into meta-currency)
- Retention driver (players stop after 5-10 runs without meta)
- Foundation for monetization
- **Depends on**: Proper QA infrastructure (audio + pacing) to validate retention

**Option B: Boss Enemies** (8-12 hours) - Content Expansion
- Mini-bosses every 5 waves with unique mechanics
- Boss AI, special abilities, loot tables
- Milestone moments for replayability
- **Depends on**: Proper QA infrastructure to balance boss difficulty

**Recommendation** (Sr Product Manager):
> "Week 15 should be **Meta Progression**. Week 14 delivers professional feel + proper pacing, which enables extended QA sessions (5-10 minutes). Week 15 Meta Progression leverages this QA infrastructure to validate retention mechanics (do players want 'one more run'?). Boss enemies are great content, but without meta progression, players will stop after 5-10 runs regardless of bosses. Meta first, bosses second (Week 16)."

---

**Ready to implement Week 14!** 🚀
