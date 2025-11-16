extends Node
class_name WaveManager

## Manages wave-based combat loop with state machine
## Week 14 Phase 1.5: Wave audio (start/complete sounds)
## Week 14 Phase 2: Continuous spawning with 60s wave timer

enum WaveState { IDLE, SPAWNING, COMBAT, CLEANUP, VICTORY, GAME_OVER }

signal wave_started(wave: int)
signal wave_completed(wave: int, stats: Dictionary)
signal all_enemies_killed
signal enemy_died(enemy_id: String)

## Audio (Week 14 Phase 1.5 - iOS-compatible preload pattern)
const WAVE_START_SOUND: AudioStream = preload("res://assets/audio/ambient/wave_start.ogg")
const WAVE_COMPLETE_SOUND: AudioStream = preload("res://assets/audio/ambient/wave_complete.ogg")

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

## Continuous spawning (Week 14 Phase 2)
const WAVE_DURATION: float = 60.0  # 60 seconds per wave
const MAX_LIVING_ENEMIES: int = 35  # Cap to prevent overwhelming/performance issues
const SPAWN_INTERVAL_MIN: float = 2.5  # Minimum time between spawns (was 3.0)
const SPAWN_INTERVAL_MAX: float = 4.0  # Maximum time between spawns (was 5.0)
const SPAWN_COUNT_MIN: int = 1  # Minimum enemies per spawn tick
const SPAWN_COUNT_MAX: int = 3  # Maximum enemies per spawn tick

var spawn_timer: float = 0.0  # Countdown to next spawn
var wave_elapsed_time: float = 0.0  # Time elapsed in current wave


func _ready() -> void:
	# Add to group so HUD can connect to wave signals
	add_to_group("wave_manager")

	# Connect to drop collection signal to track collected drops (not generated)
	if DropSystem:
		DropSystem.drops_collected.connect(_on_drops_collected)


func start_wave() -> void:
	"""Start a new wave with continuous spawning (Week 14 Phase 2)

	Waves now use 60-second timer with continuous enemy spawning throughout.
	Enemies spawn 1-3 at a time every 3-5 seconds until wave timer expires.
	"""
	print("[WaveManager] ========================================")
	print("[WaveManager] WAVE ", current_wave, " STARTING")
	print("[WaveManager] ========================================")

	# Set state to COMBAT immediately (no SPAWNING state in continuous mode)
	current_state = WaveState.COMBAT
	living_enemies.clear()
	wave_start_time = Time.get_ticks_msec() / 1000.0
	wave_elapsed_time = 0.0
	wave_stats = {"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}}

	# Initialize spawn tracking
	enemies_spawned_this_wave = 0
	total_enemies_for_wave = EnemyService.get_enemy_count_for_wave(current_wave)

	# Initialize spawn timer (first spawn 1-2s into wave for immediate action)
	spawn_timer = randf_range(1.0, 2.0)

	print("[WaveManager] Wave Configuration:")
	print("[WaveManager]   Duration: ", WAVE_DURATION, "s")
	print("[WaveManager]   Total enemies planned: ", total_enemies_for_wave)
	print("[WaveManager]   Max living enemies: ", MAX_LIVING_ENEMIES)
	print("[WaveManager]   Spawn interval: ", SPAWN_INTERVAL_MIN, "-", SPAWN_INTERVAL_MAX, "s")
	print("[WaveManager]   Enemies per spawn: ", SPAWN_COUNT_MIN, "-", SPAWN_COUNT_MAX)
	print("[WaveManager]   First spawn in: ", spawn_timer, "s")
	print("[WaveManager]   State: COMBAT")

	# Update HUD
	HudService.update_wave(current_wave)
	HudService.update_wave_timer(WAVE_DURATION)  # Start countdown
	print("[WaveManager] HUD updated: wave number and timer initialized")

	# Emit wave started signal
	wave_started.emit(current_wave)
	print("[WaveManager] wave_started signal emitted")

	# Play wave start sound (Week 14 Phase 1.5)
	_play_sound(WAVE_START_SOUND, "wave_start", -3.0)

	print("[WaveManager] Continuous spawning active - enemies will spawn throughout wave duration")
	print("[WaveManager] ========================================")


func _process(delta: float) -> void:
	"""Continuous spawning and wave timer logic (Week 14 Phase 2)

	Runs every frame during COMBAT state:
	1. Updates wave timer and HUD
	2. Checks for wave timeout (60s)
	3. Spawns enemies continuously (1-3 every 3-5s)
	4. Throttles spawning when approaching max capacity (35 enemies)
	"""
	# Only process during COMBAT state
	if current_state != WaveState.COMBAT:
		return

	# Update wave elapsed time
	wave_elapsed_time += delta
	var time_remaining = WAVE_DURATION - wave_elapsed_time

	# Update HUD every frame with current time remaining
	HudService.update_wave_timer(time_remaining)

	# Check if wave timer expired (60 seconds)
	if wave_elapsed_time >= WAVE_DURATION:
		print("[WaveManager] ========================================")
		print("[WaveManager] WAVE TIMER EXPIRED (", WAVE_DURATION, "s)")
		print("[WaveManager]   Living enemies: ", living_enemies.size())
		print(
			"[WaveManager]   Enemies spawned: ",
			enemies_spawned_this_wave,
			"/",
			total_enemies_for_wave
		)
		print("[WaveManager]   Entering CLEANUP phase")
		print("[WaveManager] ========================================")
		_end_wave()
		return

	# Check if we've hit max living enemies (throttling) - Week 14 Phase 2.2
	if living_enemies.size() >= MAX_LIVING_ENEMIES:
		# Reset spawn timer when throttled to prevent burst spawning when enemies die
		if spawn_timer <= 0:
			spawn_timer = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)
			print(
				"[WaveManager:Throttle] Max capacity reached (",
				living_enemies.size(),
				"/",
				MAX_LIVING_ENEMIES,
				") - spawn delayed"
			)
		return

	# Countdown spawn timer
	spawn_timer -= delta

	# Check if it's time to spawn enemies
	if spawn_timer <= 0 and enemies_spawned_this_wave < total_enemies_for_wave:
		# Calculate how many enemies to spawn (1-3)
		var spawn_count = randi_range(SPAWN_COUNT_MIN, SPAWN_COUNT_MAX)

		# Don't exceed total planned enemies for wave
		spawn_count = mini(spawn_count, total_enemies_for_wave - enemies_spawned_this_wave)

		# Don't exceed max living capacity (additional check)
		var capacity_remaining = MAX_LIVING_ENEMIES - living_enemies.size()
		spawn_count = mini(spawn_count, capacity_remaining)

		if spawn_count > 0:
			print("[WaveManager:Spawn] Spawn tick triggered:")
			print(
				"[WaveManager:Spawn]   Time: ",
				snappedf(wave_elapsed_time, 0.1),
				"s / ",
				WAVE_DURATION,
				"s"
			)
			print("[WaveManager:Spawn]   Spawning: ", spawn_count, " enemies")
			print(
				"[WaveManager:Spawn]   Progress: ",
				enemies_spawned_this_wave,
				" -> ",
				enemies_spawned_this_wave + spawn_count,
				" / ",
				total_enemies_for_wave
			)
			print(
				"[WaveManager:Spawn]   Living: ", living_enemies.size(), " / ", MAX_LIVING_ENEMIES
			)

			# Spawn enemies
			for i in range(spawn_count):
				_spawn_single_enemy()

			print(
				"[WaveManager:Spawn] Spawn complete - ",
				enemies_spawned_this_wave,
				"/",
				total_enemies_for_wave,
				" total spawned"
			)

		# Reset spawn timer for next spawn (3-5 seconds)
		var next_spawn_delay = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)
		spawn_timer = next_spawn_delay
		print("[WaveManager:Spawn] Next spawn in ", snappedf(next_spawn_delay, 0.1), "s")


func _spawn_single_enemy() -> void:
	"""Spawn a single enemy (or swarm group) with wave-appropriate type selection

	Called by continuous spawning system in _process().
	Handles swarm enemies (spawn_count > 1) and tracks all spawned units.
	"""
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

		# Add to scene FIRST (data.tree must be initialized before setup - Week 14 Phase 1.7 bugfix)
		print("[WaveManager] Adding enemy to spawn_container: ", spawn_container)
		spawn_container.add_child(enemy)
		print("[WaveManager] Enemy added to scene")

		# Setup enemy (now that it's in the tree, audio can play)
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


func _end_wave() -> void:
	"""Called when wave timer expires (Week 14 Phase 2.3)

	Transitions to CLEANUP state:
	- No more enemy spawns
	- HUD shows "CLEANUP" message
	- Wave completes when all remaining enemies killed
	"""
	current_state = WaveState.CLEANUP

	print("[WaveManager:Cleanup] ========================================")
	print("[WaveManager:Cleanup] ENTERING CLEANUP PHASE")
	print("[WaveManager:Cleanup]   Living enemies: ", living_enemies.size())
	print(
		"[WaveManager:Cleanup]   Enemies spawned: ",
		enemies_spawned_this_wave,
		"/",
		total_enemies_for_wave
	)
	print("[WaveManager:Cleanup]   Wave stats:")
	print("[WaveManager:Cleanup]     Killed: ", wave_stats.enemies_killed)
	print("[WaveManager:Cleanup]     Damage: ", wave_stats.damage_dealt)
	print("[WaveManager:Cleanup]     XP: ", wave_stats.xp_earned)
	print("[WaveManager:Cleanup] ========================================")

	# Update HUD to show cleanup state
	HudService.update_wave_timer(0.0)  # Timer shows 0 or "CLEANUP"
	print("[WaveManager:Cleanup] HUD updated: timer stopped")

	# Check if all enemies already dead (wave complete immediately)
	if living_enemies.is_empty():
		print("[WaveManager:Cleanup] All enemies already eliminated - wave complete!")
		_complete_wave()
	else:
		print(
			"[WaveManager:Cleanup] ",
			living_enemies.size(),
			" enemies remaining - waiting for elimination"
		)


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
		print(
			"[WaveManager:Death] Enemy eliminated: ",
			enemy_id,
			" | Living: ",
			living_enemies.size(),
			" | Killed: ",
			wave_stats.enemies_killed,
			"/",
			total_enemies_for_wave
		)
	else:
		print("[WaveManager:Death] WARNING: Enemy ", enemy_id, " not found in living_enemies")

	# Decrement remaining count (kept for backward compatibility with tests)
	enemies_remaining -= 1

	# Wave completion logic (Week 14 Phase 2.3)
	# COMBAT state: Wave continues until timer expires (continuous spawning active)
	# CLEANUP state: Wave completes when all enemies eliminated
	if living_enemies.is_empty() and current_state == WaveState.CLEANUP:
		print("[WaveManager:Death] ========================================")
		print("[WaveManager:Death] ALL ENEMIES ELIMINATED DURING CLEANUP")
		print("[WaveManager:Death]   Total killed: ", wave_stats.enemies_killed)
		print("[WaveManager:Death]   Total spawned: ", enemies_spawned_this_wave)
		print("[WaveManager:Death]   Wave completing...")
		print("[WaveManager:Death] ========================================")
		_complete_wave()
	elif living_enemies.is_empty() and current_state == WaveState.COMBAT:
		# All enemies dead during COMBAT phase - continuous spawning will spawn more
		print(
			"[WaveManager:Death] All current enemies dead (COMBAT phase) - continuous spawning active"
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

	# Play wave complete sound (Week 14 Phase 1.5)
	_play_sound(WAVE_COMPLETE_SOUND, "wave_complete", 0.0)

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


func _play_sound(sound: AudioStream, sound_name: String, volume_db: float) -> void:
	"""Play ambient sound with diagnostic logging (Week 14 Phase 1.5)

	Args:
		sound: Preloaded AudioStream resource
		sound_name: Sound name for logging ("wave_start", "wave_complete")
		volume_db: Volume in decibels (-3.0 to 0.0 typical for ambient sounds)

	iOS-compatible pattern: Uses preload() and programmatic AudioStreamPlayer
	"""
	if not sound:
		print("[WaveManager:Audio] ERROR: No sound provided for ", sound_name)
		return

	# Create AudioStreamPlayer for non-positional audio
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound
	audio_player.volume_db = volume_db

	# Auto-cleanup after playback
	audio_player.finished.connect(audio_player.queue_free)

	# Add to scene tree
	add_child(audio_player)
	audio_player.play()

	# Diagnostic logging
	print(
		"[WaveManager:Audio] Playing ",
		sound_name,
		" sound (wave: ",
		current_wave,
		", volume: ",
		volume_db,
		" dB)"
	)
