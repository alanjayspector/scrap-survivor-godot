# Week 14 Planning Options

**Date**: 2025-01-14
**Status**: Planning Phase
**Context**: Week 13 Complete (Arena optimization + character selection + enemy variety)
**Current State**: 496/520 tests passing, core combat loop polished, ready for next major feature

---

## Executive Summary

Week 13 delivered significant combat depth improvements with 4 enemy types and strategic variety. Week 14 has three high-ROI paths forward, each addressing different quality/content gaps:

**Option A: Audio System** (High-ROI Polish, 6-8 hours)
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

**Recommendation**: **Option A (Audio System)** for highest ROI, followed by Option B in Week 15.

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

## Recommendation Matrix

| Option | Effort | ROI | Risk | Priority |
|--------|--------|-----|------|----------|
| **A: Audio System** | 6-8h | Very High | Low | ⭐⭐⭐ Recommended |
| **B: Boss Enemies** | 8-12h | High | Medium | ⭐⭐ Week 15 candidate |
| **C: Meta Progression** | 10-15h | Very High | Medium | ⭐⭐ Week 15-16 |

---

## Team Consensus (Sr Roles)

**Sr Mobile Game Designer:**
> "**Option A (Audio)** is the obvious choice. We have great visuals (particles, trails, shake) but zero audio. Combat feels hollow. Audio is 50% of game feel - this is the highest ROI polish work we can do. 6-8 hours for 50% perceived quality improvement."

**Sr Product Manager:**
> "Audio first, meta progression second. Audio makes the game **shareable** (players will record clips). Meta progression makes it **sticky** (players return). Boss enemies are cool but don't drive retention like meta progression does. **Option A → Option C → Option B**."

**Sr Software Engineer:**
> "Option A is low-risk, high-reward. Audio system is isolated (no complex dependencies). Option C (meta progression) requires careful SaveSystem integration and economy balancing - more complex but necessary for retention. Option B (bosses) is fun but can wait."

**Sr Mobile UI/UX:**
> "Audio is **table stakes** for mobile games. Players expect weapon sounds, enemy feedback, UI clicks. Without audio, the game feels unfinished. Even with perfect visuals, zero audio makes it feel like a prototype."

**Sr Godot 4.5.1 Specialist:**
> "AudioStreamPlayer2D is straightforward in Godot 4. Asset sourcing (Kenney, freesound) is easy. Low technical risk. Boss enemies require more AI work (phase transitions, minion spawning). Meta progression requires careful SaveSystem integration. Audio is fastest win."

---

## Recommendation: Week 14 = Option A (Audio System)

### Why Option A?
1. **Highest ROI for effort** (6-8 hours for 50% quality boost)
2. **Low risk** (audio system is isolated, no complex dependencies)
3. **Completes combat feel loop** (visuals + audio = professional)
4. **Mobile expectations** (players expect audio in mobile games)
5. **Shareable content** (players record/share combat clips with audio)

### Week 15 Plan (Post-Audio)
- **Option C: Meta Progression** (retention driver, monetization foundation)
- OR **Option B: Boss Enemies** (content expansion, milestone moments)

### Week 16 Plan
- Implement whichever wasn't chosen in Week 15
- Polish pass (tutorials, onboarding, balance)

---

## Next Steps

1. **User Decision Required**: Choose Option A, B, or C for Week 14
2. **If Option A (Audio)**: Asset sourcing (Kenney Audio Pack, 1 hour)
3. **If Option B (Bosses)**: Design boss mechanics (2-3 boss types)
4. **If Option C (Meta)**: Economy design (upgrade costs, salvage conversion rates)

**Estimated Timeline**:
- Week 14: Audio System (6-8 hours) ✅ Recommended
- Week 15: Meta Progression (10-15 hours) or Boss Enemies (8-12 hours)
- Week 16: Remaining system + polish + playtesting

---

**Ready for Week 14 execution!** 🚀
