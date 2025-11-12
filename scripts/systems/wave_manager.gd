extends Node
class_name WaveManager

## Manages wave-based combat loop with state machine

enum WaveState { IDLE, SPAWNING, COMBAT, VICTORY, GAME_OVER }

signal wave_started(wave: int)
signal wave_completed(wave: int, stats: Dictionary)
signal all_enemies_killed
signal enemy_died(enemy_id: String)

@export var spawn_container: Node2D  # Enemies node
var current_wave: int = 1
var current_state: WaveState = WaveState.IDLE
var enemies_remaining: int = 0  # Kept for backward compatibility with existing tests
var living_enemies: Dictionary = {}  # enemy_id -> Enemy reference for accurate tracking
var wave_start_time: float = 0.0
var wave_stats: Dictionary = {}


func _ready() -> void:
	# Connect to drop collection signal to track collected drops (not generated)
	if DropSystem:
		DropSystem.drops_collected.connect(_on_drops_collected)


func start_wave() -> void:
	print("[WaveManager] start_wave() called for wave ", current_wave)
	current_state = WaveState.SPAWNING
	living_enemies.clear()
	wave_start_time = Time.get_ticks_msec() / 1000.0
	wave_stats = {"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}}
	print("[WaveManager] State set to SPAWNING, wave start time: ", wave_start_time)

	# Update HUD
	print("[WaveManager] Updating HUD...")
	HudService.update_wave(current_wave)
	print("[WaveManager] Emitting wave_started signal")
	wave_started.emit(current_wave)

	# Spawn enemies
	print("[WaveManager] Getting enemy count for wave ", current_wave)
	var enemy_count = EnemyService.get_enemy_count_for_wave(current_wave)
	print("[WaveManager] Will spawn ", enemy_count, " enemies")
	_spawn_wave_enemies(enemy_count)

	current_state = WaveState.COMBAT
	print("[WaveManager] State set to COMBAT")


func _spawn_wave_enemies(count: int) -> void:
	print("[WaveManager] _spawn_wave_enemies() called with count: ", count)
	enemies_remaining = count

	# Get spawn rate for this wave
	var spawn_rate = EnemyService.get_spawn_rate(current_wave)
	print("[WaveManager] Spawn rate: ", spawn_rate, " seconds")

	# Spawn enemies over time (not all at once)
	print("[WaveManager] Starting enemy spawn loop...")
	for i in range(count):
		print("[WaveManager] Spawning enemy ", i + 1, "/", count)
		await get_tree().create_timer(spawn_rate).timeout
		_spawn_single_enemy()
	print("[WaveManager] All enemies spawned")


func _spawn_single_enemy() -> void:
	print("[WaveManager] _spawn_single_enemy() called")

	# Load enemy scene
	const ENEMY_SCENE = preload("res://scenes/entities/enemy.tscn")
	var enemy = ENEMY_SCENE.instantiate()
	print("[WaveManager] Enemy instance created: ", enemy)

	# Random enemy type
	var enemy_types = ["scrap_bot", "mutant_rat", "rust_spider"]
	var random_type = enemy_types[randi() % enemy_types.size()]
	print("[WaveManager] Random enemy type: ", random_type)

	# Generate unique enemy ID
	var enemy_id = "enemy_%d_%d" % [current_wave, randi()]
	print("[WaveManager] Enemy ID: ", enemy_id)

	# Setup enemy
	print("[WaveManager] Calling enemy.setup()...")
	enemy.setup(enemy_id, random_type, current_wave)
	print("[WaveManager] Enemy setup complete")

	# Connect death and damage signals
	enemy.died.connect(_on_enemy_died)
	enemy.damaged.connect(_on_enemy_damaged)
	print("[WaveManager] Death and damage signals connected")

	# Random spawn position (off-screen)
	var spawn_pos = _get_random_spawn_position()
	enemy.global_position = spawn_pos
	print("[WaveManager] Enemy positioned at: ", spawn_pos)

	# Add to scene
	print("[WaveManager] Adding enemy to spawn_container: ", spawn_container)
	spawn_container.add_child(enemy)
	print("[WaveManager] Enemy added to scene")

	# Track in living_enemies for wave completion detection
	living_enemies[enemy_id] = enemy
	print("[WaveManager] Enemy tracked in living_enemies. Total living: ", living_enemies.size())


func _get_random_spawn_position() -> Vector2:
	# Spawn at edge of viewport (off-screen)
	var viewport_size = get_viewport().get_visible_rect().size
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		return Vector2.ZERO  # Fallback if no player

	var player_pos = player.global_position

	# Random edge (0=top, 1=right, 2=bottom, 3=left)
	var edge = randi() % 4
	var margin = 100  # pixels off-screen

	match edge:
		0:  # Top
			return (
				player_pos
				+ Vector2(
					randf_range(-viewport_size.x / 2, viewport_size.x / 2),
					-viewport_size.y / 2 - margin
				)
			)
		1:  # Right
			return (
				player_pos
				+ Vector2(
					viewport_size.x / 2 + margin,
					randf_range(-viewport_size.y / 2, viewport_size.y / 2)
				)
			)
		2:  # Bottom
			return (
				player_pos
				+ Vector2(
					randf_range(-viewport_size.x / 2, viewport_size.x / 2),
					viewport_size.y / 2 + margin
				)
			)
		3:  # Left
			return (
				player_pos
				+ Vector2(
					-viewport_size.x / 2 - margin,
					randf_range(-viewport_size.y / 2, viewport_size.y / 2)
				)
			)

	return player_pos  # Fallback


func _on_enemy_died(enemy_id: String, _drop_data: Dictionary, xp_reward: int) -> void:
	print("[WaveManager] _on_enemy_died called for enemy: ", enemy_id)

	# Update wave stats
	wave_stats.enemies_killed += 1
	wave_stats.xp_earned += xp_reward

	# Emit enemy died signal for visual feedback (screen shake, etc.)
	enemy_died.emit(enemy_id)

	# Note: Drop tracking moved to _on_drops_collected() to track actually collected drops

	# Remove from living_enemies tracking
	if living_enemies.has(enemy_id):
		living_enemies.erase(enemy_id)
		print("[WaveManager] Enemy removed from living_enemies. Remaining: ", living_enemies.size())
	else:
		print("[WaveManager] WARNING: Enemy ", enemy_id, " not found in living_enemies")

	# Decrement remaining count (kept for backward compatibility)
	enemies_remaining -= 1

	# Check if wave is complete (all enemies dead)
	if living_enemies.is_empty() and current_state == WaveState.COMBAT:
		print("[WaveManager] All enemies dead, completing wave")
		_complete_wave()
	elif enemies_remaining <= 0 and living_enemies.size() > 0:
		# Safety check: counter vs actual living enemies mismatch
		print(
			"[WaveManager] WARNING: enemies_remaining is 0 but ",
			living_enemies.size(),
			" enemies still living"
		)


## Handler for enemy taking damage
func _on_enemy_damaged(damage: float) -> void:
	"""Track total damage dealt to enemies"""
	wave_stats.damage_dealt += int(damage)


## Handler for drops actually collected by player
func _on_drops_collected(drops: Dictionary) -> void:
	for currency in drops.keys():
		if not wave_stats.drops_collected.has(currency):
			wave_stats.drops_collected[currency] = 0
		wave_stats.drops_collected[currency] += drops[currency]


func _complete_wave() -> void:
	print("[WaveManager] _complete_wave() called")
	current_state = WaveState.VICTORY

	# Calculate wave completion time
	var wave_end_time = Time.get_ticks_msec() / 1000.0
	var wave_time = wave_end_time - wave_start_time
	wave_stats["wave_time"] = wave_time
	print("[WaveManager] Wave completed in ", wave_time, " seconds")

	# Emit wave completion
	print("[WaveManager] Emitting wave_completed signal with stats: ", wave_stats)
	wave_completed.emit(current_wave, wave_stats)
	all_enemies_killed.emit()

	# Show wave complete screen
	_show_wave_complete_screen()


func _show_wave_complete_screen() -> void:
	# Access wave complete UI
	var wave_complete_screen = get_tree().get_first_node_in_group("wave_complete_screen")
	if wave_complete_screen:
		wave_complete_screen.show_stats(current_wave, wave_stats)
		wave_complete_screen.show()


func next_wave() -> void:
	current_wave += 1
	current_state = WaveState.IDLE

	# Prepare for next wave
	await get_tree().create_timer(1.0).timeout
	start_wave()


func game_over() -> void:
	current_state = WaveState.GAME_OVER
	# Navigate to game over screen
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
