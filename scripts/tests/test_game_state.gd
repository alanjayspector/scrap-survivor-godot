extends Node
## Test script for GameState autoload


func _ready() -> void:
	print("=== GameState Test ===")
	print()

	test_wave_changes()
	test_score_changes()
	test_gameplay_state()
	test_character_changes()
	test_reset_state()

	print()
	print("=== GameState Tests Complete ===")


func test_wave_changes() -> void:
	print("--- Testing Wave Changes ---")

	# Connect signal (use array wrapper for lambda capture)
	var wave_received = [0]
	GameState.wave_changed.connect(func(w): wave_received[0] = w)

	# Test initial state
	assert(GameState.current_wave == 0, "Initial wave should be 0")
	print("✓ Initial wave: 0")

	# Test setter
	GameState.set_current_wave(5)
	assert(GameState.current_wave == 5, "Wave should be 5")
	assert(wave_received[0] == 5, "Signal should emit 5")
	print("✓ Set wave to 5")

	# Test no duplicate signals
	wave_received[0] = 0
	GameState.set_current_wave(5)  # Same value
	assert(wave_received[0] == 0, "No signal for same value")
	print("✓ No signal for same wave value")


func test_score_changes() -> void:
	print("--- Testing Score Changes ---")

	# Connect signal (use array wrapper for lambda capture)
	var score_received = [0]
	GameState.score_changed.connect(func(s): score_received[0] = s)

	# Test initial state
	assert(GameState.score == 0, "Initial score should be 0")
	print("✓ Initial score: 0")

	# Test setter
	GameState.set_score(1000)
	assert(GameState.score == 1000, "Score should be 1000")
	assert(score_received[0] == 1000, "Signal should emit 1000")
	assert(GameState.high_score == 1000, "High score should update")
	print("✓ Set score to 1000")

	# Test add_score
	GameState.add_score(500)
	assert(GameState.score == 1500, "Score should be 1500")
	assert(score_received[0] == 1500, "Signal should emit 1500")
	assert(GameState.high_score == 1500, "High score should update")
	print("✓ Added 500 score")

	# Test high score tracking
	GameState.set_score(1200)  # Lower than current 1500
	assert(GameState.high_score == 1500, "High score shouldn't decrease")
	print("✓ High score preserved at 1500")


func test_gameplay_state() -> void:
	print("--- Testing Gameplay State ---")

	# Connect signal (use array wrapper for lambda capture)
	var state_received = [false]
	GameState.gameplay_state_changed.connect(func(s): state_received[0] = s)

	# Test initial state
	assert(!GameState.is_gameplay_active, "Initial state should be inactive")
	print("✓ Initial state: inactive")

	# Test activation
	GameState.set_gameplay_active(true)
	assert(GameState.is_gameplay_active, "Should be active")
	assert(state_received[0], "Signal should emit true")
	print("✓ Set gameplay active")

	# Test deactivation
	GameState.set_gameplay_active(false)
	assert(!GameState.is_gameplay_active, "Should be inactive")
	assert(!state_received[0], "Signal should emit false")
	print("✓ Set gameplay inactive")


func test_character_changes() -> void:
	print("--- Testing Character Changes ---")

	# Connect signal (use array wrapper for lambda capture)
	var char_received = [""]
	GameState.character_changed.connect(func(c): char_received[0] = c)

	# Test initial state
	assert(GameState.current_character == "", "Initial character should be empty")
	print("✓ Initial character: empty")

	# Test setter
	GameState.set_current_character("scavenger")
	assert(GameState.current_character == "scavenger", "Character should be scavenger")
	assert(char_received[0] == "scavenger", "Signal should emit scavenger")
	print("✓ Set character to scavenger")

	# Test no duplicate signals
	char_received[0] = ""
	GameState.set_current_character("scavenger")  # Same value
	assert(char_received[0] == "", "No signal for same character")
	print("✓ No signal for same character")


func test_reset_state() -> void:
	print("--- Testing State Reset ---")

	# Set some values
	GameState.set_current_wave(10)
	GameState.set_score(5000)
	GameState.set_gameplay_active(true)
	GameState.set_current_character("engineer")
	GameState.is_paused = true

	# Reset
	GameState.reset_game_state()

	# Verify reset
	assert(GameState.current_wave == 0, "Wave should reset to 0")
	assert(GameState.score == 0, "Score should reset to 0")
	assert(!GameState.is_gameplay_active, "Gameplay should be inactive")
	assert(GameState.current_character == "", "Character should be empty")
	assert(!GameState.is_paused, "Pause should be false")
	assert(GameState.high_score == 5000, "High score should persist")
	print("✓ All states reset except high score")
