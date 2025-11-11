extends Node
class_name WaveManager

## Manages wave-based combat loop with state machine

enum WaveState { IDLE, SPAWNING, COMBAT, VICTORY, GAME_OVER }

signal wave_started(wave: int)
signal wave_completed(wave: int, stats: Dictionary)
signal all_enemies_killed

@export var spawn_container: Node2D  # Enemies node
var current_wave: int = 1
var current_state: WaveState = WaveState.IDLE
var enemies_remaining: int = 0
var wave_stats: Dictionary = {}


func _ready() -> void:
	# Connect to enemy death signals handled per-enemy in setup()
	pass


func start_wave() -> void:
	current_state = WaveState.SPAWNING
	wave_stats = {"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}}

	# Update HUD
	HudService.update_wave(current_wave)
	wave_started.emit(current_wave)

	# Spawn enemies
	var enemy_count = EnemyService.get_enemy_count_for_wave(current_wave)
	_spawn_wave_enemies(enemy_count)

	current_state = WaveState.COMBAT


func _spawn_wave_enemies(count: int) -> void:
	enemies_remaining = count

	# Get spawn rate for this wave
	var spawn_rate = EnemyService.get_spawn_rate(current_wave)

	# Spawn enemies over time (not all at once)
	for i in range(count):
		await get_tree().create_timer(spawn_rate).timeout
		_spawn_single_enemy()


func _spawn_single_enemy() -> void:
	# Load enemy scene
	const ENEMY_SCENE = preload("res://scenes/entities/enemy.tscn")
	var enemy = ENEMY_SCENE.instantiate()

	# Random enemy type
	var enemy_types = ["scrap_bot", "mutant_rat", "rust_spider"]
	var random_type = enemy_types[randi() % enemy_types.size()]

	# Generate unique enemy ID
	var enemy_id = "enemy_%d_%d" % [current_wave, randi()]

	# Setup enemy
	enemy.setup(enemy_id, random_type, current_wave)

	# Connect death signal
	enemy.died.connect(_on_enemy_died)

	# Random spawn position (off-screen)
	var spawn_pos = _get_random_spawn_position()
	enemy.global_position = spawn_pos

	# Add to scene
	spawn_container.add_child(enemy)


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


func _on_enemy_died(_enemy_id: String, drop_data: Dictionary) -> void:
	# Update wave stats
	wave_stats.enemies_killed += 1

	for currency in drop_data.keys():
		if not wave_stats.drops_collected.has(currency):
			wave_stats.drops_collected[currency] = 0
		wave_stats.drops_collected[currency] += drop_data[currency]

	# Decrement remaining count
	enemies_remaining -= 1

	if enemies_remaining <= 0:
		_complete_wave()


func _complete_wave() -> void:
	current_state = WaveState.VICTORY

	# Emit wave completion
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
