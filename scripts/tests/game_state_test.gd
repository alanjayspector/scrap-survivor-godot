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


func after_each() -> void:
	# Cleanup
	pass


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
