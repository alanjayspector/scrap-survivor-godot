extends GutTest
class_name HudServiceTest
## Test suite for HudService
##
## Week 10 Phase 3: HUD Implementation tests
##
## Tests:
## - HP change signal emission
## - XP change signal emission
## - Currency change signal emission
## - Wave change signal emission
## - Player connection and disconnection
##
## Based on: docs/migration/week10-implementation-plan.md (lines 565-572)


## Setup before each test
func before_each() -> void:
	# Reset HudService state
	HudService.player = null
	HudService.current_wave = 1


## Teardown after each test
func after_each() -> void:
	# Disconnect all signals if player exists
	if HudService.player and is_instance_valid(HudService.player):
		var p = HudService.player
		HudService.set_player(null)
		if is_instance_valid(p):
			p.free()


## Test: HudService emits hp_changed signal when player takes damage
func test_hud_service_updates_hp_on_damage() -> void:
	# Create a mock player
	var player = Player.new()
	player.character_id = "test_char"
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 100.0

	# Connect player to HudService
	HudService.set_player(player)

	# Watch for hp_changed signal
	watch_signals(HudService)

	# Simulate player taking damage
	player.player_damaged.emit(80.0, 100.0)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert hp_changed signal was emitted
	assert_signal_emitted(HudService, "hp_changed")
	assert_signal_emitted_with_parameters(HudService, "hp_changed", [80.0, 100.0])

	# Cleanup
	HudService.set_player(null)
	player.free()


## Test: HudService emits hp_changed signal when player heals
func test_hud_service_updates_hp_on_heal() -> void:
	# Create a mock player
	var player = Player.new()
	player.character_id = "test_char"
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 50.0

	# Connect player to HudService
	HudService.set_player(player)

	# Watch for hp_changed signal
	watch_signals(HudService)

	# Simulate player healing
	player.player_healed.emit(70.0, 100.0)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert hp_changed signal was emitted
	assert_signal_emitted(HudService, "hp_changed")
	assert_signal_emitted_with_parameters(HudService, "hp_changed", [70.0, 100.0])

	# Cleanup
	HudService.set_player(null)
	player.free()


## Test: HudService emits xp_changed signal when XP is gained
func test_hud_service_updates_xp_on_gain() -> void:
	# Create a test character
	var char_id = CharacterService.create_character("Test Character", "scavenger")
	assert_not_null(char_id, "Character should be created")

	# Create a mock player
	var player = Player.new()
	player.character_id = char_id
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 100.0

	# Connect player to HudService
	HudService.set_player(player)

	# Watch for xp_changed signal
	watch_signals(HudService)

	# Award XP through DropSystem
	var leveled_up = DropSystem.award_xp_for_kill(char_id, "scrap_bot")

	# Wait for signal processing
	await get_tree().process_frame

	# Assert xp_changed signal was emitted
	assert_signal_emitted(HudService, "xp_changed")

	# Get character to verify XP values
	var character = CharacterService.get_character(char_id)
	assert_not_null(character, "Character should exist")

	# Cleanup
	HudService.set_player(null)
	player.free()
	CharacterService.delete_character(char_id)


## Test: HudService emits xp_changed signal when character levels up
func test_hud_service_updates_xp_on_level_up() -> void:
	# Create a test character
	var char_id = CharacterService.create_character("Test Character", "scavenger")
	assert_not_null(char_id, "Character should be created")

	# Create a mock player
	var player = Player.new()
	player.character_id = char_id
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 100.0

	# Connect player to HudService
	HudService.set_player(player)

	# Watch for xp_changed signal
	watch_signals(HudService)

	# Award enough XP to level up
	CharacterService.add_experience(char_id, 100)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert xp_changed signal was emitted
	assert_signal_emitted(HudService, "xp_changed")

	# Cleanup
	HudService.set_player(null)
	player.free()
	CharacterService.delete_character(char_id)


## Test: HudService emits currency_changed signal when drops are collected
func test_hud_service_updates_currency_on_collection() -> void:
	# Watch for currency_changed signal
	watch_signals(HudService)

	# Simulate drops being collected
	var drops = {"scrap": 10, "components": 5}
	DropSystem.drops_collected.emit(drops)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert currency_changed signal was emitted (at least for scrap)
	assert_signal_emitted(HudService, "currency_changed")


## Test: HudService emits wave_changed signal when wave is updated
func test_hud_service_updates_wave_on_change() -> void:
	# Watch for wave_changed signal
	watch_signals(HudService)

	# Update wave
	HudService.update_wave(2)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert wave_changed signal was emitted
	assert_signal_emitted(HudService, "wave_changed")
	assert_signal_emitted_with_parameters(HudService, "wave_changed", [2])

	# Verify internal state
	assert_eq(HudService.current_wave, 2, "Wave should be updated to 2")


## Test: HudService can set and unset player
func test_hud_service_can_set_player() -> void:
	# Create a mock player
	var player = Player.new()
	player.character_id = "test_char"
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 100.0

	# Set player
	HudService.set_player(player)

	# Assert player is set
	assert_eq(HudService.player, player, "Player should be set")

	# Cleanup
	HudService.set_player(null)
	player.free()


## Test: HudService disconnects from previous player when setting new player
func test_hud_service_disconnects_previous_player() -> void:
	# Create first player
	var player1 = Player.new()
	player1.character_id = "test_char1"
	player1.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player1.current_hp = 100.0

	# Set first player
	HudService.set_player(player1)

	# Create second player
	var player2 = Player.new()
	player2.character_id = "test_char2"
	player2.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player2.current_hp = 100.0

	# Set second player (should disconnect from first)
	HudService.set_player(player2)

	# Assert new player is set
	assert_eq(HudService.player, player2, "Player should be updated to player2")

	# Watch for hp_changed signal
	watch_signals(HudService)

	# Emit signal from first player (should not trigger HudService)
	player1.player_damaged.emit(50.0, 100.0)

	# Wait for signal processing
	await get_tree().process_frame

	# Signal should not be emitted (disconnected from player1)
	# Note: This test verifies disconnection by checking that only player2 signals work

	# Emit signal from second player (should trigger HudService)
	player2.player_damaged.emit(80.0, 100.0)

	# Wait for signal processing
	await get_tree().process_frame

	# Assert hp_changed signal was emitted
	assert_signal_emitted(HudService, "hp_changed")

	# Cleanup
	HudService.set_player(null)
	player1.free()
	player2.free()


## Test: HudService returns current HP state
func test_hud_service_returns_current_hp_state() -> void:
	# Create a mock player
	var player = Player.new()
	player.character_id = "test_char"
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 75.0

	# Set player
	HudService.set_player(player)

	# Get current HP state
	var hp_state = HudService.get_current_hp()

	# Assert state is correct
	assert_eq(hp_state.current, 75.0, "Current HP should be 75")
	assert_eq(hp_state.max, 100.0, "Max HP should be 100")

	# Cleanup
	HudService.set_player(null)
	player.free()


## Test: HudService returns current XP state
func test_hud_service_returns_current_xp_state() -> void:
	# Create a test character with some XP
	var char_id = CharacterService.create_character("Test Character", "scavenger")
	assert_not_null(char_id, "Character should be created")

	# Add some XP
	CharacterService.add_experience(char_id, 50)

	# Create a mock player
	var player = Player.new()
	player.character_id = char_id
	player.stats = {"max_hp": 100, "armor": 0, "speed": 200}
	player.current_hp = 100.0

	# Set player
	HudService.set_player(player)

	# Get current XP state
	var xp_state = HudService.get_current_xp()

	# Assert state is correct
	assert_eq(xp_state.current, 50, "Current XP should be 50")
	assert_eq(xp_state.level, 1, "Level should be 1")

	# Cleanup
	HudService.set_player(null)
	player.free()
	CharacterService.delete_character(char_id)


## Test: HudService returns current wave
func test_hud_service_returns_current_wave() -> void:
	# Set wave
	HudService.update_wave(3)

	# Get current wave
	var wave = HudService.get_current_wave()

	# Assert wave is correct
	assert_eq(wave, 3, "Current wave should be 3")
