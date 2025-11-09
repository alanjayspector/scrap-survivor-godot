# Scrap Survivor: Complete Godot 4 Migration Plan

**Status:** APPROVED
**Date Created:** 2025-01-08
**Timeline:** 12-16 weeks (3-4 months)
**Repository Strategy:** New separate repo (`scrap-survivor-godot`)
**Parallel Development:** Yes (continue React Native experiment)

---

## Executive Summary

This plan migrates Scrap Survivor from React+Phaser to Godot 4 while preserving all valuable assets, documentation, and development processes. The migration reuses 40-50% of existing code (configuration + business logic patterns) and 87% of documentation.

**Why Godot 4?**
- ✅ Native 60 FPS performance guaranteed (vs 30-45 FPS ceiling in React Native Game Engine)
- ✅ Smaller builds (15MB vs 50MB+)
- ✅ Solo developer-friendly (1-2 month learning curve for Python/C devs)
- ✅ No vendor lock-in (MIT license, open source)
- ✅ Future-proof (massive 2025 momentum after Unity pricing debacle)

**Evidence:** [See full research in M4-MAX-MIGRATION-REVIEW.md](../M4-MAX-MIGRATION-REVIEW.md)

---

## Table of Contents

1. [Phase 0: Repository & Environment Setup](#phase-0-repository--environment-setup-week-1)
2. [Phase 1: Game Configuration & Data Layer](#phase-1-game-configuration--data-layer-week-2-3)
3. [Phase 2: Core Services & Business Logic](#phase-2-core-services--business-logic-week-4-7)
4. [Phase 3: Game Systems & Mechanics](#phase-3-game-systems--mechanics-week-8-11)
5. [Phase 4: UI & Menus](#phase-4-ui--menus-week-12-13)
6. [Phase 5: Testing & Polish](#phase-5-testing--polish-week-14-15)
7. [Phase 6: Deployment Preparation](#phase-6-deployment-preparation-week-16)
8. [Parallel Development Workflow](#parallel-development-workflow)
9. [Migration Checklist](#migration-checklist)
10. [Evidence & Research](#evidence--research)

---

## Phase 0: Repository & Environment Setup (Week 1)

### 0.1 Create New Repository

**Action:**
```bash
cd ~/Developer
gh repo create scrap-survivor-godot --public --clone
cd scrap-survivor-godot
```

**Initial directory structure:**
```
scrap-survivor-godot/
├── project.godot          # Godot project file (created by editor)
├── .gitignore             # Godot-specific ignores
├── .system/               # Migrated enforcement system
│   ├── hooks/             # Git hooks (adapted for gdlint)
│   ├── validators/        # Pattern enforcement
│   └── git/               # Git autonomy system
├── docs/                  # Migrated documentation
│   ├── godot/             # Godot-specific docs
│   ├── core-architecture/ # Migrated architecture docs
│   ├── lessons-learned/   # All lessons (90% reusable)
│   └── migration/         # Migration tracking
├── assets/                # Game assets
│   ├── sprites/
│   ├── audio/
│   ├── icons/
│   └── fonts/
├── scripts/               # GDScript game code
│   ├── autoload/          # Singleton scripts
│   ├── services/          # Business logic
│   ├── entities/          # Game entities
│   ├── systems/           # Game systems
│   ├── ui/                # UI scripts
│   └── utils/             # Utilities
├── scenes/                # Godot scene files
│   ├── game/              # Game scenes
│   ├── ui/                # UI scenes
│   └── entities/          # Entity scenes
├── resources/             # Custom resources
│   ├── data/              # JSON configs
│   └── theme/             # UI themes
└── addons/                # Third-party addons
    └── supabase/          # Supabase addon
```

### 0.2 Install Godot 4.4+ and Tools

**Download Godot:**
1. Visit https://godotengine.org/download/
2. Download Godot 4.4 (latest stable) for macOS
3. Install to `/Applications/Godot.app`

**Install gdtoolkit (linter/formatter):**
```bash
pip3 install "gdtoolkit==4.*"

# Verify installation
gdlint --version  # Should show 4.x.x
gdformat --version
```

**VS Code setup:**
```bash
# Install Godot extension
code --install-extension geequlim.godot-tools
```

**Install Supabase addon:**
- Open Godot Editor
- AssetLib tab → Search "Supabase"
- Install `supabase-community/godot-engine.supabase`

### 0.3 Migrate .system/ Enforcement Layer

**Copy directory structure:**
```bash
# From scrap-survivor repo
cd ~/Developer/scrap-survivor
cp -r .system ~/Developer/scrap-survivor-godot/

cd ~/Developer/scrap-survivor-godot
```

**Adapt hooks for GDScript:**

**Update `.system/hooks/pre-commit`:**
```bash
#!/bin/bash
# Pre-commit hook for Godot project

# Run gdlint on all .gd files
gdlint scripts/ --config .gdlintrc

# Run gdformat check
gdformat --check scripts/

# Run pattern validators
.system/validators/check-patterns.sh

# Conventional commits check (keep as-is)
```

**Create `.gdlintrc`:**
```ini
[MASTER]
class-name=true
function-name=true
variable-names=true

[FORMAT]
max-line-length=100
indent-size=4
```

**Keep git autonomy system 100%:**
- `.system/git/` - No changes needed (language-agnostic)
- Git audit logging works as-is

**Evidence:** Analysis shows .system/ is 95% portable

### 0.4 Documentation Migration

**Create docs structure:**
```bash
mkdir -p docs/godot
mkdir -p docs/core-architecture
mkdir -p docs/lessons-learned
mkdir -p docs/migration
```

**Copy priority docs from scrap-survivor:**
```bash
cd ~/Developer/scrap-survivor

# Architecture (95% reusable)
cp docs/core-architecture/monetization-architecture.md \
   ~/Developer/scrap-survivor-godot/docs/core-architecture/

cp docs/core-architecture/PATTERN-CATALOG.md \
   ~/Developer/scrap-survivor-godot/docs/core-architecture/

# Lessons learned (90% reusable)
cp -r docs/lessons-learned/ \
   ~/Developer/scrap-survivor-godot/docs/

# Development guides
cp docs/development-guide/commit-guidelines.md \
   ~/Developer/scrap-survivor-godot/docs/development-guide/

# Game design docs
cp -r docs/features/ \
   ~/Developer/scrap-survivor-godot/docs/
```

**Create Godot-specific docs:**

**File:** `docs/godot/setup-guide.md`
```markdown
# Godot 4 Setup Guide

## Installation

1. Download Godot 4.4 from https://godotengine.org/download/
2. Install gdtoolkit: `pip3 install "gdtoolkit==4.*"`
3. Clone repository: `gh repo clone scrap-survivor-godot`
4. Open project in Godot Editor

## Editor Configuration

### Recommended Settings

- Editor > Editor Settings > Text Editor > Indent > Type: Tabs
- Editor > Editor Settings > Text Editor > Indent > Size: 4
- Editor > Editor Settings > Network > Remote Filesystem: Enable
```

**File:** `docs/godot/gdscript-conventions.md`
```markdown
# GDScript Coding Conventions

## Naming

- **Classes:** PascalCase (e.g., `WeaponSystem`)
- **Files:** snake_case (e.g., `weapon_system.gd`)
- **Functions:** snake_case (e.g., `calculate_damage`)
- **Variables:** snake_case (e.g., `current_health`)
- **Constants:** SCREAMING_SNAKE_CASE (e.g., `MAX_ENEMIES`)
- **Signals:** snake_case (e.g., `health_changed`)

## Documentation

Use doc comments for public APIs:

```gdscript
## Calculates damage after applying armor reduction.
##
## @param base_damage: Raw damage before armor
## @param armor_value: Target's armor stat
## @return: Final damage after reduction
func calculate_damage(base_damage: float, armor_value: float) -> float:
    return max(1, base_damage - armor_value * 0.5)
```

## Evidence

Based on official Godot style guide:
https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_styleguide.html
```

**File:** `docs/migration/asset-catalog.md`
- Copy content from the asset catalog analysis provided earlier

---

## Phase 1: Game Configuration & Data Layer (Week 2-3)

### 1.1 Port Game Configurations to JSON/Resources

**Week 2: JSON Migration**

**Extract weapons configuration:**

**Source:** `/packages/core/src/config/weapons.ts` (23 weapons)
**Target:** `resources/data/weapons.json`

**Conversion script (create in scrap-survivor repo):**

**File:** `scripts/export-configs.js`
```javascript
// Run from scrap-survivor repo root
const fs = require('fs');
const path = require('path');

// Import weapons config
const weapons = require('./packages/core/src/config/weapons.ts');

// Convert to JSON
const weaponsJson = Object.entries(weapons).map(([key, weapon]) => ({
  id: key,
  name: weapon.name,
  damage: weapon.damage,
  fire_rate: weapon.fireRate,
  projectile_speed: weapon.projectileSpeed,
  range: weapon.range,
  durability: weapon.durability,
  is_premium: weapon.tier === 'premium',
  fusion_tier: weapon.fuseTier || 1
}));

// Write to file
const outputPath = '../scrap-survivor-godot/resources/data/weapons.json';
fs.writeFileSync(
  outputPath,
  JSON.stringify(weaponsJson, null, 2)
);

console.log(`✅ Exported ${weaponsJson.length} weapons to ${outputPath}`);
```

**Run export:**
```bash
cd ~/Developer/scrap-survivor
node scripts/export-configs.js
```

**Repeat for:**
- items.json (30+ items from `packages/core/src/config/items.ts`)
- enemies.json (3 enemy types from `packages/core/src/types/enemies.ts`)
- character_types.json
- game_constants.json (from `packages/core/src/config/gameConstants.ts`)

**Evidence:** Config files are 95% portable per asset catalog

**Week 3: Custom Resources (Godot-native)**

**Why Resources over JSON?**
- Static typing in editor
- Performance (no runtime parsing)
- Editor integration (drag-drop, inspection)
- Godot-native data types (Vector2, Color)

**Evidence:** GDQuest recommends custom resources for game data

**Create WeaponResource:**

**File:** `scripts/resources/weapon_resource.gd`
```gdscript
class_name WeaponResource
extends Resource

@export var weapon_id: String
@export var weapon_name: String
@export var damage: float
@export var fire_rate: float
@export var projectile_speed: float
@export var range: float
@export var durability: int
@export var is_premium: bool
@export var fusion_tier: int
@export var sprite_path: String
```

**Create resources from JSON:**
- Right-click in Godot FileSystem → New Resource → WeaponResource
- Fill in data from weapons.json
- Save as `resources/weapons/rusty_pistol.tres`, etc.

**Create EnemyResource:**

**File:** `scripts/resources/enemy_resource.gd`
```gdscript
class_name EnemyResource
extends Resource

@export var enemy_id: String
@export var enemy_name: String
@export var base_health: float
@export var base_speed: float
@export var base_damage: float
@export var spawn_weight: float  # For wave spawning probability
@export var color: Color
@export var size: float
@export var sprite_path: String

# Wave scaling (from enemies.ts)
@export var health_per_wave: float = 0.25  # +25% per wave
@export var speed_per_wave: float = 0.05   # +5% per wave
@export var damage_per_wave: float = 0.10  # +10% per wave

func get_scaled_stats(wave: int) -> Dictionary:
	return {
		"health": base_health * (1 + health_per_wave * wave),
		"speed": base_speed * (1 + speed_per_wave * wave),
		"damage": base_damage * (1 + damage_per_wave * wave)
	}
```

**Repeat for ItemResource**

**Effort estimate:** 8-10 hours total

### 1.2 Create GDScript Type Classes

**From TypeScript types → GDScript classes**

**Enemy class (from `/packages/core/src/types/game.ts`):**

**File:** `scripts/entities/enemy.gd`
```gdscript
class_name Enemy
extends CharacterBody2D

@export var enemy_resource: EnemyResource

var entity_id: String
var current_health: float
var max_health: float
var current_speed: float
var damage: float
var is_alive: bool = true

signal died(enemy: Enemy)
signal health_changed(current: float, max: float)

func _ready():
	if enemy_resource:
		entity_id = enemy_resource.enemy_id
		# Stats will be set by wave system based on current wave

func initialize(wave: int):
	if not enemy_resource:
		push_error("Enemy missing resource")
		return

	var stats = enemy_resource.get_scaled_stats(wave)
	max_health = stats.health
	current_health = max_health
	current_speed = stats.speed
	damage = stats.damage

func take_damage(amount: float):
	current_health -= amount
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func die():
	is_alive = false
	died.emit(self)
	queue_free()
```

**Player class:**

**File:** `scripts/entities/player.gd`
```gdscript
class_name Player
extends CharacterBody2D

@export var move_speed: float = 200.0
@export var max_health: float = 100.0

var current_health: float
var equipped_weapon: WeaponResource
var position_2d: Vector2

signal health_changed(current: float, max: float)
signal died()

func _ready():
	current_health = max_health

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	velocity = input_vector.normalized() * move_speed
	move_and_slide()

func take_damage(amount: float):
	current_health -= amount
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()
```

**Projectile class:**

**File:** `scripts/entities/projectile.gd`
```gdscript
class_name Projectile
extends Area2D

var velocity: Vector2
var damage: float
var range: float
var distance_traveled: float = 0.0
var active: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if not active:
		return

	var movement = velocity * delta
	position += movement
	distance_traveled += movement.length()

	if distance_traveled >= range:
		deactivate()

func activate(start_pos: Vector2, direction: Vector2, weapon: WeaponResource):
	position = start_pos
	velocity = direction.normalized() * weapon.projectile_speed
	damage = weapon.damage
	range = weapon.range
	distance_traveled = 0.0
	active = true
	visible = true

func deactivate():
	active = false
	visible = false

func _on_body_entered(body: Node2D):
	if body is Enemy:
		body.take_damage(damage)
		deactivate()
```

**Effort estimate:** 4-6 hours for core entity types

---

## Phase 2: Core Services & Business Logic (Week 4-7)

### 2.1 Create Autoload Singletons (State Management)

**Replicate Zustand store pattern → Godot autoloads**

**GameState singleton (from `packages/core/src/store/gameStore.ts`):**

**File:** `scripts/autoload/game_state.gd`
```gdscript
extends Node

# Signals (equivalent to Zustand subscriptions)
signal user_changed(user: Dictionary)
signal character_changed(character: Dictionary)
signal gameplay_state_changed(is_active: bool)
signal wave_changed(wave: int)

# State variables
var current_user: Dictionary = {}
var current_character: Dictionary = {}
var is_gameplay_active: bool = false
var current_wave: int = 0
var score: int = 0
var game_time: float = 0.0

# Setters with signal emission
func set_current_user(user: Dictionary):
	current_user = user
	user_changed.emit(user)

func set_current_character(character: Dictionary):
	current_character = character
	character_changed.emit(character)

func set_gameplay_active(active: bool):
	is_gameplay_active = active
	gameplay_state_changed.emit(active)

func increment_wave():
	current_wave += 1
	wave_changed.emit(current_wave)

func reset_game_state():
	current_wave = 0
	score = 0
	game_time = 0.0
	is_gameplay_active = false
```

**Configure autoload:**
1. Open Project → Project Settings → Globals → Autoload
2. Add `scripts/autoload/game_state.gd` as `GameState`
3. Enable

**Repeat for other singletons:**
- `BankingService` (currency management)
- `TierService` (premium tier logic)
- `ErrorService` (error handling)

**Evidence:** Godot official docs recommend autoload for global state

### 2.2 Port Service Layer

**Week 4-5: Foundation Services**

**1. ErrorService**

**File:** `scripts/services/error_service.gd`
```gdscript
extends Node

signal error_occurred(error: Dictionary)

enum ErrorLevel {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

func log_error(message: String, level: ErrorLevel = ErrorLevel.ERROR, context: Dictionary = {}):
	var error_data = {
		"message": message,
		"level": ErrorLevel.keys()[level],
		"timestamp": Time.get_unix_time_from_system(),
		"context": context
	}

	match level:
		ErrorLevel.INFO:
			print_verbose("[INFO] ", message)
		ErrorLevel.WARNING:
			push_warning(message)
		ErrorLevel.ERROR:
			push_error(message)
		ErrorLevel.CRITICAL:
			printerr("[CRITICAL] ", message)

	error_occurred.emit(error_data)

	# TODO: Send to telemetry service

func log_info(message: String, context: Dictionary = {}):
	log_error(message, ErrorLevel.INFO, context)

func log_warning(message: String, context: Dictionary = {}):
	log_error(message, ErrorLevel.WARNING, context)
```

**2. stat_service (from TypeScript):**

**File:** `scripts/services/stat_service.gd`
```gdscript
extends Node

# Port from packages/core/src/services/statService.ts

func calculate_damage(base_damage: float, strength: float, weapon_bonus: float) -> float:
	# Same formula as TypeScript version
	return base_damage * (1 + strength / 100.0) + weapon_bonus

func calculate_health(base_health: float, vitality: float) -> float:
	return base_health + (vitality * 10.0)

func calculate_speed(base_speed: float, agility: float) -> float:
	return base_speed * (1 + agility / 100.0)

func apply_stat_modifiers(base_stats: Dictionary, modifiers: Array) -> Dictionary:
	var result = base_stats.duplicate(true)

	for modifier in modifiers:
		if modifier.has("stat") and modifier.has("value"):
			if result.has(modifier.stat):
				result[modifier.stat] += modifier.value

	return result
```

**Week 5-6: Business Logic Services**

**3. RecyclerService:**

**File:** `scripts/services/recycler_service.gd`
```gdscript
extends Node

# Port from packages/core/src/services/RecyclerService.ts

signal item_recycled(item_id: String, scrap_gained: int)

func recycle_item(item_id: String) -> Dictionary:
	# Load item data
	var item_data = _get_item_data(item_id)

	if not item_data:
		ErrorService.log_error("Item not found: " + item_id)
		return {"success": false, "error": "ITEM_NOT_FOUND"}

	# Calculate scrap value (same formula as TypeScript)
	var scrap_value = _calculate_scrap_value(item_data)

	# Grant scrap via BankingService
	var result = BankingService.add_currency("scrap", scrap_value)

	if result.success:
		item_recycled.emit(item_id, scrap_value)

	return {
		"success": result.success,
		"scrap_gained": scrap_value,
		"item_id": item_id
	}

func _calculate_scrap_value(item_data: Dictionary) -> int:
	# Port exact logic from TypeScript RecyclerService
	var base_value = item_data.get("base_value", 10)
	var rarity_multiplier = _get_rarity_multiplier(item_data.get("rarity", "common"))
	return int(base_value * rarity_multiplier)

func _get_rarity_multiplier(rarity: String) -> float:
	match rarity:
		"common": return 1.0
		"uncommon": return 1.5
		"rare": return 2.5
		"epic": return 5.0
		"legendary": return 10.0
		_: return 1.0

func _get_item_data(item_id: String) -> Dictionary:
	# Load from resources/data/items.json
	var file = FileAccess.open("res://resources/data/items.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.parse_string(json_text)
		file.close()

		for item in json:
			if item.id == item_id:
				return item

	return {}
```

**Week 6-7: Complex Services**

**4. HybridCharacterService (with Supabase):**

**File:** `scripts/services/character_service.gd`
```gdscript
extends Node

# Port from packages/core/src/services/HybridCharacterService.ts

signal character_created(character: Dictionary)
signal character_updated(character: Dictionary)
signal character_deleted(character_id: String)

var supabase: SupabaseClient

func _ready():
	supabase = get_node("/root/SupabaseClient")

func create_character(user_id: String, character_data: Dictionary) -> Dictionary:
	# Validate data
	if not _validate_character_data(character_data):
		return {"success": false, "error": "INVALID_DATA"}

	# Insert into Supabase
	var result = await supabase.database.from("characters").insert(character_data).execute()

	if result.error:
		ErrorService.log_error("Character creation failed", ErrorService.ErrorLevel.ERROR, {
			"user_id": user_id,
			"error": result.error
		})
		return {"success": false, "error": result.error}

	character_created.emit(result.data[0])
	return {"success": true, "character": result.data[0]}

func get_user_characters(user_id: String) -> Array:
	var result = await supabase.database.from("characters")\
		.select("*")\
		.eq("user_id", user_id)\
		.execute()

	if result.error:
		ErrorService.log_error("Failed to fetch characters", ErrorService.ErrorLevel.ERROR)
		return []

	return result.data

func update_character(character_id: String, updates: Dictionary) -> Dictionary:
	var result = await supabase.database.from("characters")\
		.update(updates)\
		.eq("id", character_id)\
		.execute()

	if result.error:
		return {"success": false, "error": result.error}

	character_updated.emit(result.data[0])
	return {"success": true, "character": result.data[0]}

func _validate_character_data(data: Dictionary) -> bool:
	# Port validation logic from TypeScript
	return data.has("name") and data.has("user_id")
```

### 2.3 Supabase Integration

**Configure Supabase client:**

**File:** `scripts/autoload/supabase_client.gd`
```gdscript
extends Node

var client: SupabaseClient

func _ready():
	# Load from environment or config
	var url = OS.get_environment("SUPABASE_URL")
	var key = OS.get_environment("SUPABASE_ANON_KEY")

	if url.is_empty() or key.is_empty():
		push_error("Supabase credentials not configured")
		return

	client = SupabaseClient.new()
	client.setup(url, key)
	add_child(client)

# Wrapper methods for type safety
func auth_sign_up(email: String, password: String):
	return await client.auth.sign_up(email, password)

func auth_sign_in(email: String, password: String):
	return await client.auth.sign_in_with_password(email, password)

func auth_sign_out():
	return await client.auth.sign_out()

func get_current_user():
	return client.auth.get_current_user()
```

**Add to Project Settings → Autoload:**
- Script: `scripts/autoload/supabase_client.gd`
- Name: `SupabaseClient`

**Environment variables (for development):**

**Create `.env` file (add to .gitignore):**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**Load in editor:**
```bash
# macOS: Add to ~/.zshrc or ~/.bashrc
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
```

**Evidence:** Official Supabase-Godot addon exists and is actively maintained

---

## Phase 3: Game Systems & Mechanics (Week 8-11)

### 3.1 Core Game Loop (Week 8)

**Create main game scene:**

**Scene structure:**
```
Wasteland (Node2D)
├── Player (CharacterBody2D) [scripts/entities/player.gd]
├── EnemyContainer (Node2D) - Holds all enemies
├── ProjectileContainer (Node2D) - Holds projectile pool
├── PickupContainer (Node2D) - Holds item pickups
├── Camera2D - Follows player
├── CanvasLayer (UI)
│   ├── HUD
│   │   ├── HealthBar
│   │   ├── WaveLabel
│   │   └── ScoreLabel
│   └── PauseMenu
└── WaveSystem (Node) [scripts/systems/wave_system.gd]
```

**Main controller:**

**File:** `scripts/game/wasteland.gd`
```gdscript
extends Node2D

@onready var player = $Player
@onready var wave_system = $WaveSystem
@onready var enemy_container = $EnemyContainer
@onready var projectile_pool = $ProjectileContainer/ProjectilePool

func _ready():
	# Connect signals
	player.died.connect(_on_player_died)
	wave_system.wave_complete.connect(_on_wave_complete)
	wave_system.enemy_spawned.connect(_on_enemy_spawned)

	# Start game
	GameState.reset_game_state()
	GameState.set_gameplay_active(true)
	wave_system.start_waves()

func _on_player_died():
	GameState.set_gameplay_active(false)
	# Show death screen
	get_tree().change_scene_to_file("res://scenes/ui/death_screen.tscn")

func _on_wave_complete(wave_number: int):
	GameState.increment_wave()
	# Show wave complete UI

func _on_enemy_spawned(enemy: Enemy):
	enemy_container.add_child(enemy)
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy):
	GameState.score += 10 * GameState.current_wave
	# Drop items, particles, etc.
```

### 3.2 Enemy System (Week 9)

**Wave spawner:**

**File:** `scripts/systems/wave_system.gd`
```gdscript
extends Node

signal wave_started(wave_number: int)
signal wave_complete(wave_number: int)
signal enemy_spawned(enemy: Enemy)

@export var spawn_interval: float = 2.0
@export var max_waves: int = 50

var current_wave: int = 0
var enemies_spawned: int = 0
var enemies_alive: int = 0
var wave_active: bool = false

# Enemy resources (loaded from res://resources/enemies/)
var enemy_templates: Array[EnemyResource] = []

func _ready():
	_load_enemy_templates()

func _load_enemy_templates():
	var dir = DirAccess.open("res://resources/enemies/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load("res://resources/enemies/" + file_name)
				if resource is EnemyResource:
					enemy_templates.append(resource)
			file_name = dir.get_next()

func start_waves():
	_start_wave(1)

func _start_wave(wave_number: int):
	current_wave = wave_number
	enemies_spawned = 0
	enemies_alive = 0
	wave_active = true

	wave_started.emit(wave_number)

	# Spawn enemies based on wave number
	var enemy_count = _calculate_enemy_count(wave_number)
	for i in enemy_count:
		await get_tree().create_timer(spawn_interval).timeout
		_spawn_enemy()

func _calculate_enemy_count(wave: int) -> int:
	# Same logic as TypeScript wave system
	return min(5 + wave * 2, 50)  # Cap at 50 enemies

func _spawn_enemy():
	# Weighted random selection (based on spawn_weight)
	var total_weight = 0.0
	for template in enemy_templates:
		total_weight += template.spawn_weight

	var rand_value = randf() * total_weight
	var cumulative = 0.0

	for template in enemy_templates:
		cumulative += template.spawn_weight
		if rand_value <= cumulative:
			_create_enemy(template)
			break

func _create_enemy(template: EnemyResource):
	var enemy_scene = load("res://scenes/entities/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.enemy_resource = template
	enemy.initialize(current_wave)

	# Random spawn position around player
	var spawn_pos = _get_random_spawn_position()
	enemy.position = spawn_pos

	enemies_spawned += 1
	enemies_alive += 1

	enemy.died.connect(_on_enemy_died)
	enemy_spawned.emit(enemy)

func _get_random_spawn_position() -> Vector2:
	# Spawn off-screen, around player
	var player_pos = get_tree().get_first_node_in_group("player").position
	var angle = randf() * TAU
	var distance = 600.0  # Just outside camera view
	return player_pos + Vector2(cos(angle), sin(angle)) * distance

func _on_enemy_died(enemy: Enemy):
	enemies_alive -= 1

	if enemies_alive == 0 and not wave_active:
		# Wave complete
		wave_complete.emit(current_wave)

		if current_wave < max_waves:
			await get_tree().create_timer(5.0).timeout  # 5s between waves
			_start_wave(current_wave + 1)
```

### 3.3 Weapon System (Week 10)

**Projectile pool:**

**File:** `scripts/systems/projectile_pool.gd`
```gdscript
class_name ProjectilePool
extends Node

const POOL_SIZE = 100

var pool: Array[Projectile] = []
var active_count: int = 0

func _ready():
	_initialize_pool()

func _initialize_pool():
	var projectile_scene = load("res://scenes/entities/projectile.tscn")

	for i in POOL_SIZE:
		var projectile = projectile_scene.instantiate()
		projectile.active = false
		projectile.visible = false
		pool.append(projectile)
		add_child(projectile)

func get_projectile() -> Projectile:
	for p in pool:
		if not p.active:
			active_count += 1
			return p

	# Pool exhausted (should not happen if POOL_SIZE is tuned)
	push_warning("Projectile pool exhausted!")
	return null

func return_projectile(projectile: Projectile):
	projectile.deactivate()
	active_count -= 1

func get_usage_percent() -> float:
	return (active_count / float(POOL_SIZE)) * 100.0
```

**Weapon system:**

**File:** `scripts/systems/weapon_system.gd`
```gdscript
extends Node

var projectile_pool: ProjectilePool

func _ready():
	projectile_pool = get_node("/root/Wasteland/ProjectileContainer/ProjectilePool")

func fire_weapon(weapon: WeaponResource, origin: Vector2, direction: Vector2):
	var projectile = projectile_pool.get_projectile()

	if projectile:
		projectile.activate(origin, direction, weapon)
	else:
		push_warning("Cannot fire - projectile pool full")
```

**Player weapon firing:**

**Update `scripts/entities/player.gd`:**
```gdscript
var weapon_system: Node
var last_fire_time: float = 0.0

func _ready():
	current_health = max_health
	weapon_system = get_node("/root/Wasteland/WeaponSystem")

	# Load default weapon
	equipped_weapon = load("res://resources/weapons/rusty_pistol.tres")

func _process(delta):
	_handle_weapon_fire()

func _handle_weapon_fire():
	if not equipped_weapon:
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var fire_cooldown = 1.0 / equipped_weapon.fire_rate

	if current_time - last_fire_time < fire_cooldown:
		return

	# Get aim direction (mouse or touch)
	var aim_direction = Vector2.ZERO

	if Input.is_action_pressed("fire"):  # Left click or touch
		aim_direction = (get_global_mouse_position() - global_position).normalized()

		weapon_system.fire_weapon(equipped_weapon, global_position, aim_direction)
		last_fire_time = current_time
```

### 3.4 Item/Pickup System (Week 11)

**Pickup entity:**

**File:** `scripts/entities/pickup.gd`
```gdscript
class_name Pickup
extends Area2D

@export var item_resource: ItemResource

signal collected(pickup: Pickup)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body is Player:
		# Apply item effect
		_apply_item_effect(body)
		collected.emit(self)
		queue_free()

func _apply_item_effect(player: Player):
	if not item_resource:
		return

	match item_resource.item_type:
		"health":
			player.current_health = min(player.max_health, player.current_health + item_resource.value)
		"scrap":
			BankingService.add_currency("scrap", item_resource.value)
		"powerup":
			# Apply temporary buff
			pass
```

**Drop system (when enemy dies):**

**File:** `scripts/systems/drop_system.gd`
```gdscript
extends Node

# Port drop logic from packages/core/src/config/drops.ts

func roll_drop(enemy_type: String, wave: int) -> Array:
	var drops = []

	# Load drop table
	var drop_table = _get_drop_table(enemy_type)

	for entry in drop_table:
		if randf() <= entry.chance:
			drops.append(entry.item_id)

	return drops

func _get_drop_table(enemy_type: String) -> Array:
	# Load from JSON or Resource
	return [
		{"item_id": "scrap_small", "chance": 0.5},
		{"item_id": "health_pack", "chance": 0.2},
	]

func spawn_pickup(item_id: String, position: Vector2):
	var pickup_scene = load("res://scenes/entities/pickup.tscn")
	var pickup = pickup_scene.instantiate()
	pickup.item_resource = load("res://resources/items/" + item_id + ".tres")
	pickup.position = position

	get_tree().current_scene.get_node("PickupContainer").add_child(pickup)
```

---

## Phase 4: UI & Menus (Week 12-13)

### 4.1 UI Theme Setup

**Port design tokens:**

**Create theme resource:**

**File:** `resources/theme/main_theme.tres`

1. Right-click in FileSystem → New Resource → Theme
2. In Inspector, configure:

**Colors (from designTokens.ts):**
- `bg_dark`: #0a0a0a
- `surface`: #1a1a1a
- `primary`: #10b981
- `danger`: #ef4444
- `text_primary`: #ffffff
- `text_secondary`: #9ca3af

**Fonts:**
- Default font: Import similar to your web font

**Styles:**
- Button styles (normal, hover, pressed, disabled)
- Panel styles
- Label styles

**Apply theme globally:**
- Project → Project Settings → GUI → Theme → Custom Theme
- Select `main_theme.tres`

### 4.2 Screen Implementation

**Main menu:**

**File:** `scenes/ui/main_menu.tscn`

**Scene structure:**
```
MainMenu (Control)
├── Background (ColorRect)
├── VBoxContainer
│   ├── Title (Label) - "Scrap Survivor"
│   ├── PlayButton (Button)
│   ├── SettingsButton (Button)
│   └── QuitButton (Button)
└── VersionLabel (Label)
```

**Script:** `scripts/ui/main_menu.gd`
```gdscript
extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")

func _on_settings_pressed():
	# Open settings modal
	pass

func _on_quit_pressed():
	get_tree().quit()
```

**Repeat for:**
- Character select screen
- Game HUD
- Pause menu
- Workshop UI
- Shop UI
- Settings screen

**Effort:** 8-10 hours

---

## Phase 5: Testing & Polish (Week 14-15)

### 5.1 Testing Setup

**Create test directory:**
```bash
mkdir -p scripts/tests
```

**Unit test example:**

**File:** `scripts/tests/test_stat_service.gd`
```gdscript
extends GutTest

# Using Godot Unit Testing (GUT) framework

var stat_service

func before_each():
	stat_service = StatService.new()

func test_calculate_damage():
	var result = stat_service.calculate_damage(100.0, 50.0, 10.0)
	assert_eq(result, 160.0, "Damage calculation should be correct")

func test_calculate_health():
	var result = stat_service.calculate_health(100.0, 10.0)
	assert_eq(result, 200.0, "Health calculation should be correct")
```

**Install GUT (Godot Unit Test):**
- AssetLib → Search "GUT"
- Install addon

**Run tests:**
```bash
# From command line
godot --path . --script addons/gut/gut_cmdln.gd -gdir=res://scripts/tests/
```

### 5.2 Performance Profiling

**In-game profiler:**

**File:** `scripts/debug/performance_monitor.gd`
```gdscript
extends CanvasLayer

@onready var fps_label = $Panel/VBoxContainer/FPS
@onready var entity_count_label = $Panel/VBoxContainer/EntityCount
@onready var memory_label = $Panel/VBoxContainer/Memory

func _process(delta):
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	var enemies = get_tree().get_nodes_in_group("enemies").size()
	var projectiles = get_tree().get_nodes_in_group("projectiles").size()
	entity_count_label.text = "Entities: %d (E:%d P:%d)" % [enemies + projectiles, enemies, projectiles]

	var mem_static = OS.get_static_memory_usage()
	memory_label.text = "Memory: %.1f MB" % (mem_static / 1024.0 / 1024.0)
```

**Enable in debug builds only:**
```gdscript
func _ready():
	if OS.is_debug_build():
		add_child(PerformanceMonitor.new())
```

**Use Godot's built-in profiler:**
- Debug → Profiler (while game running)
- Monitor FPS, frame time, memory

**Target:** 60 FPS sustained with 150+ entities

### 5.3 Mobile Export Testing

**iOS export (requires Mac M4 Max):**

1. Download iOS export templates in Godot
2. Project → Export → Add → iOS
3. Configure:
   - Bundle Identifier: `com.yourname.scrapsurvivor`
   - Provisioning Profile: Select your Apple Developer profile
   - Icons: Use assets from `assets/icons/`

4. Export and run on device:
```bash
# Export Xcode project
godot --export-debug "iOS" ~/Desktop/scrap-survivor-ios

# Open in Xcode
open ~/Desktop/scrap-survivor-ios/scrap-survivor.xcodeproj

# Build and run on connected iPhone
```

**Android export:**

1. Install Android SDK and templates
2. Project → Export → Add → Android
3. Configure:
   - Package Name: `com.yourname.scrapsurvivor`
   - Keystore: Create debug keystore
4. Export APK:
```bash
godot --export-debug "Android" ~/Desktop/scrap-survivor.apk

# Install on device
adb install ~/Desktop/scrap-survivor.apk
```

**Evidence:** Godot documentation shows one-click mobile export

---

## Phase 6: Deployment Preparation (Week 16)

### 6.1 Export Configuration

**iOS Production Settings:**
- Code Signing: Release profile
- Optimization: Speed (not size)
- Strip debug symbols: Yes
- Generate DSYM: Yes (for crash reports)

**Android Production Settings:**
- Build: Release APK or AAB (for Play Store)
- Minify: Yes
- ProGuard: Enable
- Target API: 34+ (current requirement)

### 6.2 Backend Finalization

**Test Supabase integration end-to-end:**
- [ ] User registration
- [ ] User login
- [ ] Character creation
- [ ] Character sync
- [ ] Banking operations (currency add/subtract)
- [ ] Shop purchases
- [ ] Error logging to Supabase

**Set up production environment:**
- Separate Supabase project for production
- Environment variable switching (dev vs prod)

---

## Parallel Development Workflow

### Repository Strategy

**Maintain two repositories:**

1. **scrap-survivor (existing):**
   - Continue React Native + Expo experiment
   - Keep all existing documentation
   - Preserve web build (React + Phaser)
   - Use as reference for business logic

2. **scrap-survivor-godot (new):**
   - Fresh Godot 4 project
   - Migrated docs + Godot-specific docs
   - Shared game design principles
   - Independent evolution

**Why separate repos?**
- Clean slate for Godot (no React/Phaser baggage)
- Independent version control
- Allows experiments in both paths
- Can merge knowledge back to each

### Development Cadence

**Weeks 1-3 (Phase 0-1):**
- **Godot:** Setup + config migration
- **React Native:** Continue current work
- **No conflict:** Different codebases

**Weeks 4-7 (Phase 2):**
- **Godot:** Service porting
- **React Native:** Can reference service progress
- **Synergy:** Business logic patterns validated in both

**Weeks 8+ (Phase 3):**
- **Godot:** Game systems implementation
- **React Native:** Game systems implementation
- **Decision point (Week 8):** Compare prototypes

**Week 8 Decision:**
- Run both games on iPhone
- Measure FPS with 150 entities
- Evaluate development velocity
- Choose primary path forward

---

## Migration Checklist

### Phase 0: Setup (Week 1)

- [ ] Create `scrap-survivor-godot` repository on GitHub
- [ ] Install Godot 4.4 on Mac M4 Max
- [ ] Install gdtoolkit: `pip3 install "gdtoolkit==4.*"`
- [ ] Install VS Code Godot extension
- [ ] Migrate .system/ directory
- [ ] Update git hooks for gdlint
- [ ] Configure .gdlintrc
- [ ] Copy priority documentation (architecture, lessons, patterns)
- [ ] Create Godot-specific docs (setup-guide.md, gdscript-conventions.md)
- [ ] Install Supabase addon from AssetLib
- [ ] Initial commit and push

### Phase 1: Data (Week 2-3)

- [ ] Create export script in scrap-survivor repo: `scripts/export-configs.js`
- [ ] Export weapons.ts → weapons.json (23 weapons)
- [ ] Export items.ts → items.json (30+ items)
- [ ] Export enemies.ts → enemies.json (3 enemy types)
- [ ] Export character_types.ts → character_types.json
- [ ] Export gameConstants.ts → game_constants.json
- [ ] Copy JSON files to scrap-survivor-godot/resources/data/
- [ ] Create WeaponResource class (scripts/resources/weapon_resource.gd)
- [ ] Create EnemyResource class (scripts/resources/enemy_resource.gd)
- [ ] Create ItemResource class (scripts/resources/item_resource.gd)
- [ ] Convert weapons.json → .tres resources (23 files)
- [ ] Convert enemies.json → .tres resources (3 files)
- [ ] Convert items.json → .tres resources (30+ files)
- [ ] Create Enemy entity class (scripts/entities/enemy.gd)
- [ ] Create Player entity class (scripts/entities/player.gd)
- [ ] Create Projectile entity class (scripts/entities/projectile.gd)
- [ ] Test: Load resources in editor, verify data integrity

### Phase 2: Services (Week 4-7)

- [ ] Create GameState autoload (scripts/autoload/game_state.gd)
- [ ] Configure GameState in Project Settings → Autoload
- [ ] Create ErrorService (scripts/services/error_service.gd)
- [ ] Create stat_service (scripts/services/stat_service.gd)
- [ ] Create Logger utility (scripts/utils/logger.gd)
- [ ] Configure SupabaseClient autoload (scripts/autoload/supabase_client.gd)
- [ ] Set up environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)
- [ ] Test Supabase connection
- [ ] Port RecyclerService (scripts/services/recycler_service.gd)
- [ ] Port ShopRerollService (scripts/services/shop_reroll_service.gd)
- [ ] Port BankingService (scripts/services/banking_service.gd)
- [ ] Port HybridCharacterService (scripts/services/character_service.gd)
- [ ] Port SyncService (scripts/services/sync_service.gd)
- [ ] Test: Create character via CharacterService
- [ ] Test: Banking operations (add/subtract currency)
- [ ] Test: Sync operations

### Phase 3: Game Systems (Week 8-11)

- [ ] Create wasteland scene (scenes/game/wasteland.tscn)
- [ ] Create wasteland controller script (scripts/game/wasteland.gd)
- [ ] Implement player movement (WASD/touch)
- [ ] Configure input map (Project Settings → Input Map)
- [ ] Create WaveSystem (scripts/systems/wave_system.gd)
- [ ] Implement enemy spawning logic
- [ ] Test: Spawn 10 enemies, verify scaling by wave
- [ ] Create ProjectilePool (scripts/systems/projectile_pool.gd)
- [ ] Create WeaponSystem (scripts/systems/weapon_system.gd)
- [ ] Implement weapon firing
- [ ] Test: Fire 100 projectiles, verify pooling
- [ ] Implement collision detection (projectile → enemy)
- [ ] Test: Hit enemy, verify damage calculation
- [ ] Create DropSystem (scripts/systems/drop_system.gd)
- [ ] Create Pickup entity (scripts/entities/pickup.gd)
- [ ] Implement item drops on enemy death
- [ ] Test: Kill enemy, collect pickup, verify currency increase
- [ ] Performance test: 150 entities at 60 FPS

### Phase 4: UI (Week 12-13)

- [ ] Create main_theme.tres (resources/theme/main_theme.tres)
- [ ] Configure colors from designTokens
- [ ] Configure fonts
- [ ] Create Button, Panel, Label styles
- [ ] Apply theme globally (Project Settings → GUI → Theme)
- [ ] Create MainMenu scene (scenes/ui/main_menu.tscn)
- [ ] Create MainMenu script (scripts/ui/main_menu.gd)
- [ ] Create CharacterSelect scene
- [ ] Create CharacterSelect script
- [ ] Create GameHUD scene (health bar, wave count, score)
- [ ] Create PauseMenu scene
- [ ] Create Workshop UI scene
- [ ] Create Shop UI scene
- [ ] Create Settings scene
- [ ] Test: Navigate all screens without crashes

### Phase 5: Testing (Week 14-15)

- [ ] Install GUT addon (Godot Unit Test)
- [ ] Create test directory (scripts/tests/)
- [ ] Write unit tests for stat_service
- [ ] Write unit tests for RecyclerService
- [ ] Write unit tests for BankingService
- [ ] Run all unit tests, verify pass
- [ ] Create performance monitor (scripts/debug/performance_monitor.gd)
- [ ] Enable profiler in debug build
- [ ] Profile 30-minute play session
- [ ] Verify no memory leaks
- [ ] Export iOS build
- [ ] Test on iPhone (TestFlight)
- [ ] Export Android APK
- [ ] Test on Android device
- [ ] Verify 60 FPS on both platforms

### Phase 6: Deploy (Week 16)

- [ ] Configure iOS release export template
- [ ] Set bundle ID, provisioning profile
- [ ] Add icons and splash screens
- [ ] Configure Android release export template
- [ ] Create release keystore
- [ ] Set package name
- [ ] Final QA pass (play through 10 waves)
- [ ] Export production builds
- [ ] Upload iOS to TestFlight
- [ ] Upload Android to Internal Testing
- [ ] Beta test with 5-10 users
- [ ] Fix critical bugs
- [ ] Prepare for public launch

---

## Evidence & Research

### Asset Portability Analysis

**Source:** Exploration agent analysis (completed 2025-01-08)

- **Code reusability:** 40-50%
  - Configuration: 95% (JSON conversion)
  - Services: 70-80% (business logic intact, adapt DB calls)
  - Types: 90% (direct translation to GDScript classes)
  - UI: 0% (complete rewrite in Godot Control nodes)

- **Documentation reusability:** 87%
  - Architecture docs: 90%
  - Pattern catalog: 100%
  - Lessons learned: 90%
  - Game design: 85%

**Evidence files:**
- [Asset Catalog](./asset-catalog.md)
- [M4 Max Migration Review](../M4-MAX-MIGRATION-REVIEW.md)

### Godot 4 Best Practices

**Sources:**
- Official Godot documentation (https://docs.godotengine.org/en/4.4/)
- GDQuest tutorials (https://www.gdquest.com/)
- Community project templates

**Key findings:**
1. **Project structure:** Scene-based organization, assets near scenes
2. **Naming:** snake_case for files/functions, PascalCase for classes
3. **State management:** Autoload singletons for global state
4. **Resources:** Prefer custom resources over JSON for game data
5. **Testing:** GUT framework for unit tests

**Evidence:**
- Godot official docs: Project organization best practices
- gdtoolkit: Official linting tool (4.5.0, released Oct 2025)

### Supabase Integration

**Source:** Supabase-Godot community addon

**Capabilities:**
- Authentication (sign up, sign in, OAuth)
- Database operations (insert, update, delete, query)
- Real-time subscriptions
- Storage (file uploads)

**Installation:** AssetLib → "Supabase" → Install

**Evidence:**
- GitHub: supabase-community/godot-engine.supabase
- Godot Asset Library: Supabase API (4.x)

### Mobile Export

**Source:** Godot official documentation

**iOS requirements:**
- macOS (M4 Max ✅)
- Xcode 15+
- Apple Developer account ($99/year)
- iOS export templates (bundled with Godot)

**Android requirements:**
- Android SDK (install via Godot)
- Java JDK
- Keystore for signing

**Build sizes:**
- Godot games: 10-20MB typical
- React Native: 50-80MB typical

**Evidence:**
- Godot docs: Exporting for iOS
- Godot docs: Exporting for Android
- Community reports: "hyper-casual games under 15MB"

### Performance Targets

**Source:** Industry benchmarks research (session-28)

**Mobile game standards (2025):**
- 60 FPS: Industry standard for action games
- 45 FPS: Acceptable fallback on mid-range devices
- 30 FPS: Minimum acceptable (not recommended for action)

**Memory targets:**
- Mid-range devices: 150-250MB game runtime
- Budget devices: 80-120MB

**Godot performance:**
- Native 2D rendering (no WebView overhead)
- 500+ entities possible at 60 FPS
- Built-in object pooling support

**Evidence:**
- React Native Game Engine: 100-150 entity ceiling for 60 FPS
- Godot 2D games: 500+ entities confirmed in production games

---

## Questions & Clarifications

**Q: Can I continue React Native experiment while doing Godot?**
**A:** Yes! Separate repos allow parallel development. Decision point at Week 8.

**Q: What if I get stuck learning GDScript?**
**A:** GDScript is Python-like, and you know Python. Estimated learning: 1-2 weeks for basics, 1 month for proficiency. Resources: GDQuest's "Learn GDScript From Zero" (free).

**Q: Will my Supabase database work with both projects?**
**A:** Yes. Same database, same schema, different clients. The Godot Supabase addon uses the same REST API.

**Q: Can I test on my iPhone before buying Apple Developer account?**
**A:** Limited. You can build to simulator, but need account ($99) for real device testing (required by Week 9).

**Q: What if Godot performance doesn't hit 60 FPS?**
**A:** Unlikely for 2D games at this complexity. If it happens, optimize or fall back to React Native with reduced expectations.

---

## Next Steps

**After plan approval:**

1. **Today:** Create `scrap-survivor-godot` repository
2. **This week:** Install Godot 4.4, complete Phase 0 setup
3. **Week 2:** Start config migration (weapons/items JSON export)
4. **Week 3:** Complete Phase 1, create resources
5. **Week 4:** Begin service porting

**Communication cadence:**
- End of each phase: Progress review
- Week 8: Prototype comparison and path decision
- Week 16: Launch preparation

---

**Prepared by:** Claude (Sonnet 4.5)
**Date:** 2025-01-08
**Status:** Ready for execution
