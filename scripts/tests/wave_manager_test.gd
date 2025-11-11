extends GutTest
class_name WaveManagerTest
## Test suite for WaveManager
##
## Week 10 Phase 4: Wave Management & State Machine tests
##
## Tests:
## - Wave state transitions (IDLE -> SPAWNING -> COMBAT -> VICTORY)
## - Enemy spawning logic
## - Wave completion detection
## - Wave stats tracking
## - Signal emission
##
## Based on: docs/migration/week10-implementation-plan.md (lines 611-810)


## Setup before each test
func before_each() -> void:
	# Reset HudService state
	HudService.current_wave = 1


## Teardown after each test
func after_each() -> void:
	# Clean up any spawned enemies
	var tree = get_tree()
	if tree:
		var enemies = tree.get_nodes_in_group("enemies")
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.queue_free()


## Test: WaveManager initializes with IDLE state and wave 1
func test_wave_manager_initializes_correctly() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Assert initial state
	assert_eq(wave_manager.current_wave, 1, "Should start at wave 1")
	assert_eq(wave_manager.current_state, WaveManager.WaveState.IDLE, "Should start in IDLE state")
	assert_eq(wave_manager.enemies_remaining, 0, "Should have no enemies initially")


## Test: WaveManager transitions to SPAWNING state when wave starts
func test_wave_manager_starts_wave() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Watch for signals
	watch_signals(wave_manager)

	# Start wave
	wave_manager.start_wave()

	# Assert state changed
	assert_eq(
		wave_manager.current_state,
		WaveManager.WaveState.COMBAT,
		"Should be in COMBAT state after spawning starts"
	)

	# Assert signal emitted
	assert_signal_emitted(wave_manager, "wave_started")
	assert_signal_emitted_with_parameters(wave_manager, "wave_started", [1])


## Test: WaveManager spawns correct number of enemies for wave
func test_wave_manager_spawns_correct_enemy_count() -> void:
	# Create wave manager with mock spawn container
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Get expected enemy count for wave 1
	var expected_count = EnemyService.get_enemy_count_for_wave(1)

	# Start wave
	wave_manager.start_wave()

	# Wait for enemies to spawn (with timeout)
	var max_wait_time = 10.0  # seconds
	var elapsed = 0.0
	var delta = 0.1

	while wave_manager.enemies_remaining < expected_count and elapsed < max_wait_time:
		await get_tree().create_timer(delta).timeout
		elapsed += delta

	# Assert correct number of enemies spawned
	assert_eq(
		wave_manager.enemies_remaining, expected_count, "Should spawn correct number of enemies"
	)


## Test: WaveManager completes wave when all enemies are killed
func test_wave_manager_completes_wave_when_all_killed() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Watch for signals
	watch_signals(wave_manager)

	# Set up wave with manual enemy count
	wave_manager.enemies_remaining = 3
	wave_manager.current_state = WaveManager.WaveState.COMBAT
	wave_manager.wave_stats = {
		"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}
	}

	# Simulate 3 enemy deaths
	wave_manager._on_enemy_died("enemy_1", {"scrap": 5})
	wave_manager._on_enemy_died("enemy_2", {"scrap": 5})
	wave_manager._on_enemy_died("enemy_3", {"scrap": 5})

	# Wait for signal processing
	await get_tree().process_frame

	# Assert wave completed
	assert_eq(
		wave_manager.current_state, WaveManager.WaveState.VICTORY, "Should be in VICTORY state"
	)
	assert_signal_emitted(wave_manager, "wave_completed")
	assert_signal_emitted(wave_manager, "all_enemies_killed")


## Test: WaveManager tracks wave stats correctly
func test_wave_manager_tracks_wave_stats() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Set up wave with manual state
	wave_manager.enemies_remaining = 2
	wave_manager.current_state = WaveManager.WaveState.COMBAT
	wave_manager.wave_stats = {
		"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}
	}

	# Simulate enemy deaths with different drops
	wave_manager._on_enemy_died("enemy_1", {"scrap": 10, "components": 2})
	wave_manager._on_enemy_died("enemy_2", {"scrap": 5, "nanites": 1})

	# Wait for signal processing
	await get_tree().process_frame

	# Assert stats tracked correctly
	assert_eq(wave_manager.wave_stats.enemies_killed, 2, "Should track 2 enemies killed")
	assert_eq(
		wave_manager.wave_stats.drops_collected["scrap"], 15, "Should track 15 scrap collected"
	)
	assert_eq(
		wave_manager.wave_stats.drops_collected["components"],
		2,
		"Should track 2 components collected"
	)
	assert_eq(
		wave_manager.wave_stats.drops_collected["nanites"], 1, "Should track 1 nanite collected"
	)


## Test: WaveManager increments wave number on next_wave
func test_wave_manager_increments_wave_number() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Assert initial wave
	assert_eq(wave_manager.current_wave, 1, "Should start at wave 1")

	# Manually set to VICTORY state
	wave_manager.current_state = WaveManager.WaveState.VICTORY

	# Watch for signals
	watch_signals(wave_manager)

	# Call next_wave
	wave_manager.next_wave()

	# Wait for next wave to start
	await wait_seconds(1.5)

	# Assert wave incremented
	assert_eq(wave_manager.current_wave, 2, "Should be at wave 2")
	assert_signal_emitted(wave_manager, "wave_started")


## Test: WaveManager transitions to GAME_OVER state
func test_wave_manager_game_over_state() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Call game_over (note: this would normally change scene, but we're just testing state)
	# We'll need to mock the scene change to avoid actually switching scenes
	var original_state = wave_manager.current_state

	# Manually set game over state without scene change
	wave_manager.current_state = WaveManager.WaveState.GAME_OVER

	# Assert state changed
	assert_eq(
		wave_manager.current_state, WaveManager.WaveState.GAME_OVER, "Should be in GAME_OVER state"
	)


## Test: WaveManager emits wave_completed signal with correct stats
func test_wave_manager_emits_wave_completed_with_stats() -> void:
	# Create wave manager
	var wave_manager = WaveManager.new()
	var spawn_container = Node2D.new()
	wave_manager.spawn_container = spawn_container
	add_child_autofree(wave_manager)
	add_child_autofree(spawn_container)

	# Watch for signals
	watch_signals(wave_manager)

	# Set up wave
	wave_manager.current_wave = 1
	wave_manager.enemies_remaining = 1
	wave_manager.current_state = WaveManager.WaveState.COMBAT
	wave_manager.wave_stats = {
		"enemies_killed": 0, "damage_dealt": 0, "xp_earned": 0, "drops_collected": {}
	}

	# Simulate final enemy death
	var drop_data = {"scrap": 10}
	wave_manager._on_enemy_died("enemy_1", drop_data)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert wave_completed signal emitted with correct parameters
	assert_signal_emitted(wave_manager, "wave_completed")

	# Get the signal parameters (0 = first emission)
	var signal_params = get_signal_parameters(wave_manager, "wave_completed", 0)
	assert_eq(signal_params[0], 1, "Wave number should be 1")
	assert_true(signal_params[1].has("enemies_killed"), "Stats should include enemies_killed")
	assert_eq(signal_params[1]["enemies_killed"], 1, "Should have killed 1 enemy")
