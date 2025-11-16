extends Node
## EnemyService - Enemy management with spawning, wave scaling, and AI
##
## Week 9 Phase 2: Enemy system with wave-based progression
##
## Responsibilities:
## - Enemy definitions (stats, behaviors, drop tables)
## - Enemy spawning with unique IDs
## - Enemy health and damage tracking
## - Enemy death and drop generation
## - Wave-based enemy scaling
## - Basic AI (movement toward player)
##
## Based on: docs/migration/week9-implementation-plan.md (lines 136-204)

## Enemy type definitions
const ENEMY_TYPES = {
	"scrap_bot":
	{
		"display_name": "Scrap Bot",
		"base_hp": 50,
		"base_damage": 3,  # Reduced from 5 for better balance
		"speed": 80,
		"xp_reward": 10,
		"drop_table":
		{
			"scrap": {"min": 1, "max": 3, "chance": 0.8},
			"components": {"min": 0, "max": 1, "chance": 0.2}
		}
	},
	"mutant_rat":
	{
		"display_name": "Mutant Rat",
		"base_hp": 30,
		"base_damage": 5,  # Reduced from 8 for better balance
		"speed": 120,  # Faster, lower HP
		"xp_reward": 8,
		"drop_table":
		{
			"scrap": {"min": 1, "max": 2, "chance": 0.6},
			"nanites": {"min": 1, "max": 1, "chance": 0.1}
		}
	},
	"rust_spider":
	{
		"display_name": "Rust Spider",
		"base_hp": 40,
		"base_damage": 4,  # Reduced from 6 for better balance
		"speed": 100,
		"xp_reward": 12,
		"drop_table":
		{
			"scrap": {"min": 2, "max": 4, "chance": 0.7},
			"components": {"min": 1, "max": 2, "chance": 0.3}
		}
	},
	# Week 13 Phase 3: Enemy Variety
	"turret_drone":
	{
		"display_name": "Turret Drone",
		"base_hp": 20,  # Lower HP than melee (ranged enemy)
		"base_damage": 8,  # Higher damage (ranged threat)
		"speed": 50,  # Slow movement (stationary shooter)
		"xp_reward": 15,  # Higher XP reward
		"behavior": "ranged",  # Stops at distance and shoots
		"ranged_attack_distance": 400,  # Stop at 400px from player
		"attack_cooldown": 2.0,  # Shoot every 2 seconds
		"projectile_speed": 300,  # Projectile velocity
		"drop_table":
		{
			"scrap": {"min": 2, "max": 3, "chance": 0.6},
			"components": {"min": 1, "max": 1, "chance": 0.3}
		}
	},
	"scrap_titan":
	{
		"display_name": "Scrap Titan",
		"base_hp": 120,  # 4x HP of baseline (tank)
		"base_damage": 15,  # High melee damage
		"speed": 60,  # Slow movement (0.6x baseline)
		"xp_reward": 30,  # 3x XP reward
		"behavior": "tank",  # High HP, slow, threatening
		"size_multiplier": 1.5,  # Larger sprite scale
		"drop_table":
		{
			"scrap": {"min": 3, "max": 5, "chance": 0.8},
			"components": {"min": 2, "max": 3, "chance": 0.4}
		}
	},
	"feral_runner":
	{
		"display_name": "Feral Runner",
		"base_hp": 15,  # 0.5x HP of baseline (glass cannon)
		"base_damage": 4,  # Low damage (dies quickly)
		"speed": 180,  # 1.8x speed (fast threat)
		"xp_reward": 8,  # Lower XP
		"behavior": "fast",  # Rushes player quickly
		"drop_table":
		{
			"scrap": {"min": 1, "max": 2, "chance": 0.3},
			"nanites": {"min": 1, "max": 1, "chance": 0.15}
		}
	},
	"nano_swarm":
	{
		"display_name": "Nano Swarm",
		"base_hp": 8,  # Very low HP
		"base_damage": 3,  # Low damage per unit
		"speed": 120,  # Medium speed
		"xp_reward": 5,  # Low XP per unit
		"behavior": "swarm",  # Spawns multiple at once
		"spawn_count": 5,  # Spawn 5 enemies at once
		"drop_table":
		{
			"scrap": {"min": 1, "max": 1, "chance": 0.2},
			"nanites": {"min": 1, "max": 2, "chance": 0.25}
		}
	}
}

## Internal state
var enemies: Dictionary = {}  # enemy_id -> enemy_data
var _next_enemy_id: int = 1
var player_position: Vector2 = Vector2.ZERO

## Signals
signal enemy_spawned(enemy_id: String, enemy_type: String, position: Vector2)
signal enemy_damaged(enemy_id: String, damage: float, remaining_hp: float)
signal enemy_killed(enemy_id: String, enemy_type: String, position: Vector2)


## Initialize service
func _ready() -> void:
	GameLogger.info("EnemyService initialized", {"enemy_types": ENEMY_TYPES.size()})


## Check if enemy type exists
func enemy_type_exists(enemy_type: String) -> bool:
	return ENEMY_TYPES.has(enemy_type)


## Get enemy type definition
func get_enemy_type(enemy_type: String) -> Dictionary:
	if not enemy_type_exists(enemy_type):
		GameLogger.warning("Enemy type does not exist", {"enemy_type": enemy_type})
		return {}
	return ENEMY_TYPES[enemy_type]


## Spawn enemy at position
func spawn_enemy(enemy_type: String, position: Vector2, wave: int = 1) -> String:
	if not enemy_type_exists(enemy_type):
		GameLogger.warning("Cannot spawn enemy: invalid type", {"enemy_type": enemy_type})
		return ""

	var enemy_def = ENEMY_TYPES[enemy_type]

	# Generate enemy ID
	var enemy_id = "enemy_%d" % _next_enemy_id
	_next_enemy_id += 1

	# Apply wave scaling to HP
	var hp_multiplier = get_enemy_hp_multiplier(wave)
	var max_hp = enemy_def.base_hp * hp_multiplier

	# Create enemy data
	var enemy_data = {
		"id": enemy_id,
		"type": enemy_type,
		"position": position,
		"max_hp": max_hp,
		"current_hp": max_hp,
		"damage": enemy_def.base_damage,
		"speed": enemy_def.speed,
		"xp_reward": enemy_def.xp_reward,
		"wave": wave,
		"alive": true
	}

	# Store enemy
	enemies[enemy_id] = enemy_data

	# Emit signal
	enemy_spawned.emit(enemy_id, enemy_type, position)

	GameLogger.info(
		"Enemy spawned",
		{"enemy_id": enemy_id, "type": enemy_type, "position": position, "wave": wave, "hp": max_hp}
	)

	return enemy_id


## Get enemy data
func get_enemy(enemy_id: String) -> Dictionary:
	if not enemies.has(enemy_id):
		GameLogger.warning("Enemy does not exist", {"enemy_id": enemy_id})
		return {}
	return enemies[enemy_id]


## Get all living enemies
func get_living_enemies() -> Array:
	var living = []
	for enemy_id in enemies.keys():
		var enemy = enemies[enemy_id]
		if enemy.alive:
			living.append(enemy_id)
	return living


## Get enemy count
func get_enemy_count() -> int:
	return get_living_enemies().size()


## Damage enemy
## Returns true if enemy was killed
func damage_enemy(enemy_id: String, damage: float) -> bool:
	if not enemies.has(enemy_id):
		GameLogger.warning("Cannot damage enemy: does not exist", {"enemy_id": enemy_id})
		return false

	var enemy = enemies[enemy_id]

	if not enemy.alive:
		GameLogger.warning("Cannot damage enemy: already dead", {"enemy_id": enemy_id})
		return false

	# Apply damage
	enemy.current_hp -= damage

	# Check if killed
	if enemy.current_hp <= 0.0:
		enemy.current_hp = 0.0
		enemy.alive = false
		enemy_killed.emit(enemy_id, enemy.type, enemy.position)
		GameLogger.info("Enemy killed", {"enemy_id": enemy_id, "type": enemy.type})
		return true

	# Still alive
	enemy_damaged.emit(enemy_id, damage, enemy.current_hp)
	return false


## Kill enemy and return drop table
func kill_enemy(enemy_id: String) -> Dictionary:
	if not enemies.has(enemy_id):
		GameLogger.warning("Cannot kill enemy: does not exist", {"enemy_id": enemy_id})
		return {}

	var enemy = enemies[enemy_id]
	var enemy_def = ENEMY_TYPES[enemy.type]

	# Mark as dead
	enemy.alive = false
	enemy.current_hp = 0.0

	# Return drop table for drop system to process
	return {
		"enemy_id": enemy_id,
		"enemy_type": enemy.type,
		"position": enemy.position,
		"xp_reward": enemy_def.xp_reward,
		"drop_table": enemy_def.drop_table
	}


## Remove enemy from tracking (cleanup)
func remove_enemy(enemy_id: String) -> void:
	if enemies.has(enemy_id):
		enemies.erase(enemy_id)
		GameLogger.info("Enemy removed", {"enemy_id": enemy_id})


## Reset all enemies (useful for testing and new wave)
func reset() -> void:
	enemies.clear()
	_next_enemy_id = 1
	GameLogger.info("EnemyService reset")


## Update player position (for AI)
func set_player_position(position: Vector2) -> void:
	player_position = position


## Update enemy AI - move toward player
func update_enemy_ai(enemy_id: String, delta: float) -> void:
	if not enemies.has(enemy_id):
		return

	var enemy = enemies[enemy_id]

	if not enemy.alive:
		return

	# Calculate direction to player
	var direction = (player_position - enemy.position).normalized()

	# Move enemy
	var movement = direction * enemy.speed * delta
	enemy.position += movement


## Get enemies in radius (for collision/aura detection)
func get_enemies_in_radius(center: Vector2, radius: float) -> Array:
	var in_radius = []

	for enemy_id in enemies.keys():
		var enemy = enemies[enemy_id]

		if not enemy.alive:
			continue

		var distance = center.distance_to(enemy.position)
		if distance <= radius:
			in_radius.append(enemy_id)

	return in_radius


## ============================================================================
## Wave Scaling Functions
## ============================================================================


## Get enemy count for wave
func get_enemy_count_for_wave(wave: int) -> int:
	# Week 14 Phase 2.5b: Strengthened fix - closer to genre baseline (was 35 + wave*8)
	# Spawn rate: 2.0-3.5s intervals = ~22 spawns/60s × 2 avg enemies = 44-51 spawnable
	# Player kill rate: 0.4/sec = 24 kills/60s, maintains 25-35 living enemies
	# Vampire Survivors: 60-80 enemies, Brotato: 40-50, Our Wave 1: 51 (genre parity)
	return 45 + (wave * 6)  # Wave 1 = 51, Wave 2 = 57, Wave 3 = 63, Wave 4 = 69


## Get enemy HP multiplier for wave
func get_enemy_hp_multiplier(wave: int) -> float:
	return 1.0 + ((wave - 1) * 0.15)  # Wave 1 = 1.0x, Wave 2 = 1.15x, Wave 5 = 1.60x


## Get spawn rate for wave (time between spawns)
func get_spawn_rate(wave: int) -> float:
	return max(2.0 - ((wave - 1) * 0.1), 0.5)  # Faster spawns each wave (min 0.5s)


## Serialize service state to dictionary
func serialize() -> Dictionary:
	return {
		"enemies": enemies, "_next_enemy_id": _next_enemy_id, "player_position": player_position
	}


## Restore service state from dictionary
func deserialize(data: Dictionary) -> void:
	if data.has("enemies"):
		enemies = data.enemies
	if data.has("_next_enemy_id"):
		_next_enemy_id = data._next_enemy_id
	if data.has("player_position"):
		player_position = data.player_position
	GameLogger.info("EnemyService deserialized", {"enemy_count": enemies.size()})
