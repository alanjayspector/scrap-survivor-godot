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

## Spawn tracking (hotfix for premature wave completion - 2025-11-14)
var enemies_spawned_this_wave: int = 0
var total_enemies_for_wave: int = 0


func _ready() -> void:
	# Add to group so HUD can connect to wave signals
	add_to_group("wave_manager")

	# Connect to drop collection signal to track collected drops (not generated)
	if DropSystem:
		DropSystem.drops_collected.connect(_on_drops_collected)


func start_wave() -> void:
	print("[WaveManager] start_wave() called for wave ", current_wave)
	current_state = WaveState.SPAWNING
	living_enemies.clear()
	wave_start_time = Time.get_ticks_msec() / 1000.0
	wave_stats = {"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}}

	# Initialize spawn tracking (hotfix for premature wave completion - 2025-11-14)
	enemies_spawned_this_wave = 0
	total_enemies_for_wave = EnemyService.get_enemy_count_for_wave(current_wave)
	print("[WaveManager] Total enemies planned for wave: ", total_enemies_for_wave)

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
	# Note: We track "selections" (i) vs "actual enemies spawned" (counter)
	# Swarm enemies spawn multiple units per selection
	print("[WaveManager] Starting enemy spawn loop...")
	var i = 0
	while enemies_spawned_this_wave < total_enemies_for_wave:
		i += 1
		print(
			"[WaveManager] Spawn selection ",
			i,
			" (",
			enemies_spawned_this_wave,
			"/",
			total_enemies_for_wave,
			" spawned)"
		)
		await get_tree().create_timer(spawn_rate).timeout

		# Bug #4 fix: Stop spawning if player died (2025-11-14)
		var player = get_tree().get_first_node_in_group("player") as Player
		if not player or not player.is_alive():
			print("[WaveManager] Player dead, stopping spawn loop")
			break

		_spawn_single_enemy()

		# Safety check: prevent infinite loop
		if i > count * 2:
			print("[WaveManager] WARNING: Spawn loop safety limit reached!")
			break
	print(
		"[WaveManager] All enemies spawned: ",
		enemies_spawned_this_wave,
		"/",
		total_enemies_for_wave
	)


func _spawn_single_enemy() -> void:
	print("[WaveManager] _spawn_single_enemy() called")

	# Load enemy scene
	const ENEMY_SCENE = preload("res://scenes/entities/enemy.tscn")

	# Wave-based enemy composition (Week 13 Phase 3)
	# Early waves favor melee, mid waves introduce variety, late waves emphasize threats
	var enemy_pool = []

	if current_wave <= 3:
		# Early waves: mostly melee enemies (easier)
		enemy_pool = [
			"scrap_bot", "scrap_bot", "mutant_rat", "mutant_rat", "rust_spider", "feral_runner"
		]
	elif current_wave <= 6:
		# Mid waves: introduce ranged and tanks (strategic variety)
		enemy_pool = [
			"scrap_bot",
			"mutant_rat",
			"rust_spider",
			"turret_drone",
			"turret_drone",
			"scrap_titan",
			"feral_runner",
			"nano_swarm"
		]
	else:
		# Late waves: all enemy types with emphasis on threats
		enemy_pool = [
			"scrap_bot",
			"turret_drone",
			"turret_drone",
			"turret_drone",
			"scrap_titan",
			"scrap_titan",
			"feral_runner",
			"nano_swarm",
			"nano_swarm"
		]

	var random_type = enemy_pool[randi() % enemy_pool.size()]
	print("[WaveManager] Random enemy type: ", random_type, " (wave ", current_wave, ")")

	# Check if this enemy type spawns multiple units (swarm behavior) - Week 13 Phase 3
	var type_def = EnemyService.get_enemy_type(random_type)
	var spawn_count = type_def.get("spawn_count", 1)

	# Cap spawn count to not exceed wave total (Bug #2 fix - 2025-11-14)
	var remaining = total_enemies_for_wave - enemies_spawned_this_wave
	spawn_count = mini(spawn_count, remaining)
	print("[WaveManager] Spawn count (capped): ", spawn_count, " (remaining: ", remaining, ")")

	# Spawn multiple enemies for swarm types
	for i in range(spawn_count):
		var enemy = ENEMY_SCENE.instantiate()
		print("[WaveManager] Enemy instance created: ", enemy, " (", i + 1, "/", spawn_count, ")")

		# Generate unique enemy ID
		var enemy_id = "enemy_%d_%d_%d" % [current_wave, randi(), i]
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

		# For swarm spawns, add slight position variation
		if spawn_count > 1:
			spawn_pos += Vector2(randf_range(-50, 50), randf_range(-50, 50))

		enemy.global_position = spawn_pos
		print("[WaveManager] Enemy positioned at: ", spawn_pos)

		# Add to scene
		print("[WaveManager] Adding enemy to spawn_container: ", spawn_container)
		spawn_container.add_child(enemy)
		print("[WaveManager] Enemy added to scene")

		# Track in living_enemies for wave completion detection
		living_enemies[enemy_id] = enemy
		print(
			"[WaveManager] Enemy tracked in living_enemies. Total living: ", living_enemies.size()
		)

	# Increment spawn counter (hotfix for premature wave completion - 2025-11-14)
	enemies_spawned_this_wave += spawn_count
	print(
		"[WaveManager] Enemies spawned this wave: ",
		enemies_spawned_this_wave,
		"/",
		total_enemies_for_wave
	)


func _get_random_spawn_position() -> Vector2:
	# Week 13 Phase 3.5: Spawn in ring around player (600-800px) for tighter density
	# Previous: Viewport edge spawning (too sparse in 2000×2000 world)
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		return Vector2.ZERO  # Fallback if no player

	var player_pos = player.global_position

	# Spawn in ring around player (just off-screen at ~600-800px)
	# Viewport is ~1152×648 on mobile, so 600-800px is just beyond visible edge
	var spawn_distance = randf_range(600, 800)
	var spawn_angle = randf() * TAU  # Random angle (0 to 2π)
	var offset = Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance

	return player_pos + offset


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

	# Check if wave is complete (hotfix: ALL enemies must spawn before wave can complete - 2025-11-14)
	if (
		living_enemies.is_empty()
		and current_state == WaveState.COMBAT
		and enemies_spawned_this_wave >= total_enemies_for_wave
	):
		print(
			"[WaveManager] All enemies dead AND all enemies spawned (",
			enemies_spawned_this_wave,
			"/",
			total_enemies_for_wave,
			"), completing wave"
		)
		_complete_wave()
	elif living_enemies.is_empty() and enemies_spawned_this_wave < total_enemies_for_wave:
		# Hotfix: Prevent premature wave completion while enemies still spawning
		print(
			"[WaveManager] All current enemies dead, but still spawning (",
			enemies_spawned_this_wave,
			"/",
			total_enemies_for_wave,
			") - wave continues"
		)
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

	# Bug #5 fix: Clean up living enemies to prevent memory leak (2025-11-14)
	_cleanup_enemies()

	# Navigate to game over screen
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")


func _cleanup_enemies() -> void:
	"""Free all living enemies to prevent memory leaks"""
	print("[WaveManager] Cleaning up ", living_enemies.size(), " living enemies")
	for enemy_id in living_enemies.keys():
		var enemy = living_enemies[enemy_id]
		if enemy and is_instance_valid(enemy):
			enemy.queue_free()
	living_enemies.clear()
	print("[WaveManager] Cleanup complete")
