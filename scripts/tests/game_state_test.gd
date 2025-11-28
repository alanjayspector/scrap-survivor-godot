extends GutTest
## Test script for GameState autoload using GUT framework
##
## USER STORY: "As a player, I want wave progression and score tracking"
##
## Tests wave management, score tracking, gameplay state, and character selection.

class_name GameStateTest


func before_each() -> void:
	# Reset game state before each test
	GameState.reset_game_state()

	# Week 15: Also reset Week 15-specific state
	GameState.active_character_id = ""
	GameState.current_run_active = false
	GameState.run_start_time = 0.0


func after_each() -> void:
	# Cleanup Week 15 state
	GameState.active_character_id = ""
	GameState.current_run_active = false
	GameState.run_start_time = 0.0


# Wave State Tests
func test_initial_wave_is_zero() -> void:
	assert_eq(GameState.current_wave, 0, "Initial wave should be 0")


func test_set_current_wave_updates_wave() -> void:
	GameState.set_current_wave(5)
	assert_eq(GameState.current_wave, 5, "Wave should be set to 5")


func test_set_current_wave_emits_signal() -> void:
	watch_signals(GameState)

	GameState.set_current_wave(5)

	assert_signal_emitted(GameState, "wave_changed", "wave_changed signal should emit")
	assert_signal_emit_count(GameState, "wave_changed", 1, "Signal should emit once")

	var signal_params = get_signal_parameters(GameState, "wave_changed", 0)
	assert_eq(signal_params[0], 5, "Signal should emit wave value 5")


func test_set_current_wave_no_signal_for_same_value() -> void:
	GameState.set_current_wave(5)
	watch_signals(GameState)

	GameState.set_current_wave(5)  # Same value

	assert_signal_not_emitted(GameState, "wave_changed", "No signal should emit for same value")


# Score State Tests
func test_initial_score_is_zero() -> void:
	assert_eq(GameState.score, 0, "Initial score should be 0")


func test_set_score_updates_score() -> void:
	GameState.set_score(1000)
	assert_eq(GameState.score, 1000, "Score should be set to 1000")


func test_set_score_updates_high_score() -> void:
	GameState.set_score(1000)
	assert_eq(GameState.high_score, 1000, "High score should update to 1000")


func test_set_score_emits_signal() -> void:
	watch_signals(GameState)

	GameState.set_score(1000)

	assert_signal_emitted(GameState, "score_changed", "score_changed signal should emit")
	assert_signal_emit_count(GameState, "score_changed", 1, "Signal should emit once")

	var signal_params = get_signal_parameters(GameState, "score_changed", 0)
	assert_eq(signal_params[0], 1000, "Signal should emit score value 1000")


func test_add_score_increases_score() -> void:
	GameState.set_score(1000)
	GameState.add_score(500)
	assert_eq(GameState.score, 1500, "Score should be 1500 after adding 500")


func test_add_score_updates_high_score() -> void:
	GameState.set_score(1000)
	GameState.add_score(500)
	assert_eq(GameState.high_score, 1500, "High score should update to 1500")


func test_add_score_emits_signal() -> void:
	GameState.set_score(1000)
	watch_signals(GameState)

	GameState.add_score(500)

	assert_signal_emitted(GameState, "score_changed", "score_changed signal should emit on add")

	var signal_params = get_signal_parameters(GameState, "score_changed", 0)
	assert_eq(signal_params[0], 1500, "Signal should emit new score 1500")


func test_high_score_does_not_decrease() -> void:
	GameState.set_score(1500)
	GameState.set_score(1200)  # Lower score

	assert_eq(GameState.high_score, 1500, "High score should remain at 1500")


# Gameplay State Tests
func test_initial_gameplay_state_is_inactive() -> void:
	assert_false(GameState.is_gameplay_active, "Initial gameplay state should be inactive")


func test_set_gameplay_active_true_updates_state() -> void:
	GameState.set_gameplay_active(true)
	assert_true(GameState.is_gameplay_active, "Gameplay state should be active")


func test_set_gameplay_active_true_emits_signal() -> void:
	watch_signals(GameState)

	GameState.set_gameplay_active(true)

	assert_signal_emitted(
		GameState, "gameplay_state_changed", "gameplay_state_changed signal should emit"
	)

	var signal_params = get_signal_parameters(GameState, "gameplay_state_changed", 0)
	assert_true(signal_params[0], "Signal should emit true")


func test_set_gameplay_active_false_updates_state() -> void:
	GameState.set_gameplay_active(true)
	GameState.set_gameplay_active(false)

	assert_false(GameState.is_gameplay_active, "Gameplay state should be inactive")


func test_set_gameplay_active_false_emits_signal() -> void:
	GameState.set_gameplay_active(true)
	watch_signals(GameState)

	GameState.set_gameplay_active(false)

	assert_signal_emitted(
		GameState, "gameplay_state_changed", "gameplay_state_changed signal should emit"
	)

	var signal_params = get_signal_parameters(GameState, "gameplay_state_changed", 0)
	assert_false(signal_params[0], "Signal should emit false")


# Character State Tests
func test_initial_character_is_empty() -> void:
	assert_eq(GameState.current_character, "", "Initial character should be empty string")


func test_set_current_character_updates_character() -> void:
	GameState.set_current_character("scavenger")
	assert_eq(GameState.current_character, "scavenger", "Character should be set to scavenger")


func test_set_current_character_emits_signal() -> void:
	watch_signals(GameState)

	GameState.set_current_character("scavenger")

	assert_signal_emitted(GameState, "character_changed", "character_changed signal should emit")

	var signal_params = get_signal_parameters(GameState, "character_changed", 0)
	assert_eq(signal_params[0], "scavenger", "Signal should emit character 'scavenger'")


func test_set_current_character_no_signal_for_same_value() -> void:
	GameState.set_current_character("scavenger")
	watch_signals(GameState)

	GameState.set_current_character("scavenger")  # Same value

	assert_signal_not_emitted(
		GameState, "character_changed", "No signal should emit for same character"
	)


# Reset State Tests
func test_reset_clears_wave() -> void:
	GameState.set_current_wave(10)
	GameState.reset_game_state()

	assert_eq(GameState.current_wave, 0, "Wave should reset to 0")


func test_reset_clears_score() -> void:
	GameState.set_score(5000)
	GameState.reset_game_state()

	assert_eq(GameState.score, 0, "Score should reset to 0")


func test_reset_preserves_high_score() -> void:
	GameState.set_score(5000)
	GameState.reset_game_state()

	assert_eq(GameState.high_score, 5000, "High score should persist after reset")


func test_reset_deactivates_gameplay() -> void:
	GameState.set_gameplay_active(true)
	GameState.reset_game_state()

	assert_false(GameState.is_gameplay_active, "Gameplay should be inactive after reset")


func test_reset_clears_character() -> void:
	GameState.set_current_character("engineer")
	GameState.reset_game_state()

	assert_eq(GameState.current_character, "", "Character should be empty after reset")


func test_reset_unpauses_game() -> void:
	GameState.is_paused = true
	GameState.reset_game_state()

	assert_false(GameState.is_paused, "Pause should be false after reset")


func test_reset_full_state() -> void:
	# Set multiple values
	GameState.set_current_wave(10)
	GameState.set_score(5000)
	GameState.set_gameplay_active(true)
	GameState.set_current_character("engineer")
	GameState.is_paused = true

	# Reset all
	GameState.reset_game_state()

	# Verify all reset except high score
	assert_eq(GameState.current_wave, 0, "Wave should reset to 0")
	assert_eq(GameState.score, 0, "Score should reset to 0")
	assert_false(GameState.is_gameplay_active, "Gameplay should be inactive")
	assert_eq(GameState.current_character, "", "Character should be empty")
	assert_false(GameState.is_paused, "Pause should be false")
	assert_eq(GameState.high_score, 5000, "High score should persist")


# Week 15: Active Character Tests
func test_week15_initial_active_character_is_empty() -> void:
	assert_eq(GameState.active_character_id, "", "Initial active_character_id should be empty")


func test_week15_set_active_character_updates_id() -> void:
	GameState.set_active_character("char_123")
	assert_eq(GameState.active_character_id, "char_123", "active_character_id should be set")


func test_week15_set_active_character_emits_signal() -> void:
	watch_signals(GameState)

	GameState.set_active_character("char_123")

	assert_signal_emitted(
		GameState, "character_activated", "character_activated signal should emit"
	)

	var signal_params = get_signal_parameters(GameState, "character_activated", 0)
	assert_eq(signal_params[0], "char_123", "Signal should emit character ID")


func test_week15_set_active_character_allows_empty_string() -> void:
	GameState.set_active_character("char_123")
	GameState.set_active_character("")

	assert_eq(GameState.active_character_id, "", "Should allow clearing active character")


# Week 15: Run Tracking Tests
func test_week15_initial_run_state_is_inactive() -> void:
	assert_false(GameState.current_run_active, "Initial run state should be inactive")
	assert_eq(GameState.run_start_time, 0.0, "Initial run start time should be 0")


func test_week15_start_run_activates_run() -> void:
	GameState.set_active_character("char_123")
	GameState.start_run()

	assert_true(GameState.current_run_active, "Run should be active after start_run()")


func test_week15_start_run_sets_start_time() -> void:
	GameState.set_active_character("char_123")

	var before_time = Time.get_ticks_msec() / 1000.0
	GameState.start_run()
	var after_time = Time.get_ticks_msec() / 1000.0

	assert_between(
		GameState.run_start_time,
		before_time,
		after_time,
		"run_start_time should be set to current time"
	)


func test_week15_start_run_resets_wave_to_zero() -> void:
	GameState.set_current_wave(10)
	GameState.set_active_character("char_123")
	GameState.start_run()

	assert_eq(GameState.current_wave, 0, "Wave should reset to 0 on run start")


func test_week15_start_run_emits_signal() -> void:
	GameState.set_active_character("char_123")
	watch_signals(GameState)

	GameState.start_run()

	assert_signal_emitted(GameState, "run_started", "run_started signal should emit")

	var signal_params = get_signal_parameters(GameState, "run_started", 0)
	assert_eq(signal_params[0], "char_123", "Signal should emit active character ID")


func test_week15_start_run_fails_without_active_character() -> void:
	# No character set
	GameState.start_run()

	# Run should not start
	assert_false(GameState.current_run_active, "Run should not start without active character")


func test_week15_end_run_deactivates_run() -> void:
	GameState.set_active_character("char_123")
	GameState.start_run()

	GameState.end_run({"wave": 5})

	assert_false(GameState.current_run_active, "Run should be inactive after end_run()")


func test_week15_end_run_adds_duration_to_stats() -> void:
	GameState.set_active_character("char_123")
	GameState.start_run()

	# Simulate some time passing
	await get_tree().create_timer(0.1).timeout

	var stats = {"wave": 5, "kills": 10}
	GameState.end_run(stats)

	assert_has(stats, "duration", "Stats should include duration")
	assert_gt(stats["duration"], 0.0, "Duration should be greater than 0")


func test_week15_end_run_adds_character_id_to_stats() -> void:
	GameState.set_active_character("char_123")
	GameState.start_run()

	var stats = {"wave": 5}
	GameState.end_run(stats)

	assert_has(stats, "character_id", "Stats should include character_id")
	assert_eq(stats["character_id"], "char_123", "Stats should have correct character ID")


func test_week15_end_run_emits_signal() -> void:
	GameState.set_active_character("char_123")
	GameState.start_run()

	watch_signals(GameState)

	var stats = {"wave": 5, "kills": 10}
	GameState.end_run(stats)

	assert_signal_emitted(GameState, "run_ended", "run_ended signal should emit")

	var signal_params = get_signal_parameters(GameState, "run_ended", 0)
	assert_has(signal_params[0], "duration", "Signal stats should include duration")
	assert_has(signal_params[0], "character_id", "Signal stats should include character_id")
	assert_eq(signal_params[0]["wave"], 5, "Signal stats should include original data")


func test_week15_end_run_without_active_run_shows_warning() -> void:
	# Call end_run without starting a run
	var stats = {"wave": 5}
	GameState.end_run(stats)

	# Should log warning but not crash
	# Stats should NOT be modified (early return)
	assert_false(stats.has("duration"), "Stats should not be modified without active run")
	assert_false(stats.has("character_id"), "Stats should not have character_id without active run")
	pass_test("end_run() handles no active run gracefully")


func test_week15_get_active_character_returns_empty_when_no_character() -> void:
	var character = GameState.get_active_character()

	assert_eq(character, {}, "Should return empty dict when no active character")


func test_week15_get_active_character_returns_character_data() -> void:
	# Create a test character in CharacterService
	var char_id = CharacterService.create_character("TestChar", "scavenger")
	assert_ne(char_id, "", "Character creation should succeed")

	# Set as active
	GameState.set_active_character(char_id)

	# Get character data
	var character = GameState.get_active_character()

	assert_not_null(character, "Should return character data")
	assert_eq(character.get("id"), char_id, "Should return correct character")
	assert_eq(character.get("name"), "TestChar", "Should have character name")
	assert_eq(character.get("character_type"), "scavenger", "Should have character type")


func test_week15_full_run_flow() -> void:
	# Create character (Week 18: updated to new character type)
	var char_id = CharacterService.create_character("RunTestChar", "scavenger")
	assert_ne(char_id, "", "Character creation should succeed")

	# Set active and start run
	GameState.set_active_character(char_id)

	watch_signals(GameState)
	GameState.start_run()

	assert_signal_emitted(GameState, "run_started", "Should emit run_started")
	assert_true(GameState.current_run_active, "Run should be active")

	# Simulate gameplay
	GameState.set_current_wave(5)

	# End run
	var stats = {"wave": 5, "kills": 50, "damage": 1000}
	GameState.end_run(stats)

	assert_signal_emitted(GameState, "run_ended", "Should emit run_ended")
	assert_false(GameState.current_run_active, "Run should be inactive")
	assert_has(stats, "duration", "Stats should have duration")
	assert_has(stats, "character_id", "Stats should have character_id")
	assert_eq(stats["character_id"], char_id, "Stats should reference correct character")


# Week 15: Expert Panel Recommended Tests
func test_week15_expert_start_run_called_twice_reinitializes() -> void:
	"""Expert recommendation: Test double start_run() call behavior"""
	GameState.set_active_character("char_123")
	GameState.start_run()

	var first_start_time = GameState.run_start_time

	# Wait a bit
	await get_tree().create_timer(0.05).timeout

	# Start again without ending
	watch_signals(GameState)
	GameState.start_run()

	# Should re-emit signal and update start time
	assert_signal_emitted(GameState, "run_started", "Should emit run_started on second start")
	assert_gt(
		GameState.run_start_time, first_start_time, "Start time should be updated on re-start"
	)
	assert_eq(GameState.current_wave, 0, "Wave should reset to 0 on re-start")


func test_week15_expert_very_long_run_duration() -> void:
	"""Expert recommendation: Test very long run durations (no overflow)"""
	GameState.set_active_character("char_123")

	# Manually set start time to simulate very long run (1 hour ago)
	GameState.current_run_active = true
	GameState.run_start_time = (Time.get_ticks_msec() / 1000.0) - 3600.0  # 1 hour ago

	var stats = {"wave": 100, "kills": 10000}
	GameState.end_run(stats)

	assert_has(stats, "duration", "Stats should have duration")
	assert_between(stats["duration"], 3599.0, 3601.0, "Duration should be ~3600 seconds (1 hour)")
	assert_typeof(stats["duration"], TYPE_FLOAT, "Duration should be float (no overflow)")


func test_week15_expert_invalid_character_id_allowed() -> void:
	"""Expert recommendation: Test invalid character ID handling"""
	# GameState doesn't validate character IDs (that's CharacterService's job)
	# It should accept any string
	GameState.set_active_character("invalid_char_id_999")

	assert_eq(GameState.active_character_id, "invalid_char_id_999", "Should accept any string")

	# get_active_character() will return empty dict for invalid ID
	var character = GameState.get_active_character()
	assert_eq(character, {}, "Should return empty dict for invalid character ID")


func test_week15_expert_end_run_with_null_stats() -> void:
	"""Expert recommendation: Test end_run() with null/missing stats"""
	GameState.set_active_character("char_123")
	GameState.start_run()

	# Pass empty dict (not null, as GDScript doesn't allow null for Dictionary)
	var stats = {}
	GameState.end_run(stats)

	# Should still populate duration and character_id
	assert_has(stats, "duration", "Should add duration even to empty stats")
	assert_has(stats, "character_id", "Should add character_id even to empty stats")
	assert_false(GameState.current_run_active, "Run should be inactive")


func test_week15_expert_concurrent_runs_same_character() -> void:
	"""Expert recommendation: Test rapid start→end→start cycles"""
	GameState.set_active_character("char_123")

	# Run 1
	GameState.start_run()
	assert_true(GameState.current_run_active, "Run 1 should be active")
	GameState.end_run({"wave": 5})
	assert_false(GameState.current_run_active, "Run 1 should end")

	# Run 2 (immediate restart)
	GameState.start_run()
	assert_true(GameState.current_run_active, "Run 2 should be active")
	GameState.end_run({"wave": 10})
	assert_false(GameState.current_run_active, "Run 2 should end")

	# Run 3
	GameState.start_run()
	assert_true(GameState.current_run_active, "Run 3 should be active")

	# System should handle rapid cycles without issues
	pass_test("Rapid run cycles handled without errors")


func test_week15_expert_concurrent_runs_different_characters() -> void:
	"""Expert recommendation: Test switching characters mid-run"""
	GameState.set_active_character("char_A")
	GameState.start_run()

	# Switch character mid-run (shouldn't happen in normal gameplay, but test edge case)
	GameState.set_active_character("char_B")

	# Active character changed but run is still active
	assert_true(GameState.current_run_active, "Run should still be active")
	assert_eq(GameState.active_character_id, "char_B", "Active character should be char_B")

	# End run - should use current active_character_id
	var stats = {"wave": 5}
	GameState.end_run(stats)

	assert_eq(
		stats["character_id"], "char_B", "Stats should reference current active character (char_B)"
	)


func test_week15_expert_end_run_preserves_original_stats() -> void:
	"""Test that end_run() doesn't overwrite existing fields"""
	GameState.set_active_character("char_123")
	GameState.start_run()

	var stats = {"wave": 10, "kills": 100, "duration": 999.0, "character_id": "fake_id"}

	GameState.end_run(stats)

	# Should overwrite duration and character_id (they get calculated)
	assert_ne(stats["duration"], 999.0, "Duration should be overwritten with actual duration")
	assert_eq(
		stats["character_id"],
		"char_123",
		"character_id should be overwritten with active character"
	)

	# Should preserve other fields
	assert_eq(stats["wave"], 10, "Should preserve wave")
	assert_eq(stats["kills"], 100, "Should preserve kills")
