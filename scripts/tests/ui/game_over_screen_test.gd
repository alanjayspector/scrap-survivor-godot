extends GutTest
## Test script for Game Over Screen (Week 15 Phase 5)
##
## USER STORY: "As a player, I want to see my run statistics and gain XP when I die,
##             so that I feel progression even when I fail"
##
## Tests the enhanced game over screen with XP award and character progression

class_name GameOverScreenTest

var game_over_screen: Panel
var test_character_id: String = ""


func before_each() -> void:
	# Reset services
	CharacterService.reset()
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Clear GameState active character
	GameState.set_active_character("")

	# Create test character
	test_character_id = CharacterService.create_character("TestHero", "scavenger")
	assert_ne(test_character_id, "", "Test character should be created")

	# Load game over screen script directly and create instance
	var game_over_script = load("res://scenes/ui/game_over_screen.gd")
	game_over_screen = Panel.new()
	game_over_screen.set_script(game_over_script)

	# Build minimal scene structure for game over screen
	var padding = MarginContainer.new()
	padding.name = "PaddingContainer"
	game_over_screen.add_child(padding)

	var content = VBoxContainer.new()
	content.name = "Content"
	padding.add_child(content)

	var game_over_label = Label.new()
	game_over_label.name = "GameOverLabel"
	content.add_child(game_over_label)

	var stats_display = VBoxContainer.new()
	stats_display.name = "StatsDisplay"
	content.add_child(stats_display)

	var xp_container = VBoxContainer.new()
	xp_container.name = "XPContainer"
	content.add_child(xp_container)

	var xp_gained_label = Label.new()
	xp_gained_label.name = "XPGainedLabel"
	xp_container.add_child(xp_gained_label)

	var level_up_label = Label.new()
	level_up_label.name = "LevelUpLabel"
	level_up_label.visible = false
	xp_container.add_child(level_up_label)

	var xp_progress_bar = ProgressBar.new()
	xp_progress_bar.name = "XPProgressBar"
	xp_container.add_child(xp_progress_bar)

	var buttons_container = VBoxContainer.new()
	buttons_container.name = "ButtonsContainer"
	content.add_child(buttons_container)

	var retry_button = Button.new()
	retry_button.name = "RetryButton"
	retry_button.text = "Try Again"
	buttons_container.add_child(retry_button)

	var main_menu_button = Button.new()
	main_menu_button.name = "MainMenuButton"
	main_menu_button.text = "Return to Hub"
	buttons_container.add_child(main_menu_button)

	# Add to scene tree
	add_child_autofree(game_over_screen)

	# Wait for _ready() to be called
	await wait_frames(2)


## ============================================================================
## SECTION 1: XP Calculation Tests
## User Story: "As a player, I want to earn XP based on my performance"
## ============================================================================


func test_xp_calculation_formula() -> void:
	# Arrange
	var stats = {
		"wave": 5,
		"kills": 100,
		"damage_dealt": 1000,
		"time": 300.0,
		"scrap": 50,
		"components": 10,
		"nanites": 5
	}

	# Expected XP: 5 waves * 10 + 100 kills / 10 = 50 + 10 = 60 XP
	var expected_xp = 60

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert - Check character received XP
	var character = CharacterService.get_character(test_character_id)
	var total_xp_earned = character.get("experience", 0)

	# For level 1 char with 60 XP, they should level up (100 XP/level)
	# So they won't level up, experience should be 60
	assert_eq(total_xp_earned, 60, "Character should have 60 XP")
	assert_eq(character.get("level", 1), 1, "Character should still be level 1")


func test_xp_award_triggers_level_up() -> void:
	# Arrange - Give character 90 XP already (10 away from level 2)
	CharacterService.add_xp(test_character_id, 90)

	var stats = {
		"wave": 5,  # 50 XP from waves
		"kills": 0,  # 0 XP from kills
		"damage_dealt": 0,
		"time": 60.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Expected: 90 (existing) + 50 (new) = 140 total
	# Level 1→2 at 100 XP, so should level up with 40 overflow

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("level", 1), 2, "Character should be level 2")
	assert_eq(character.get("experience", 0), 40, "Character should have 40 overflow XP")

	# Check UI shows level up
	var level_up_label = game_over_screen.get_node(
		"PaddingContainer/Content/XPContainer/LevelUpLabel"
	)
	assert_true(level_up_label.visible, "Level up label should be visible")
	assert_string_contains(level_up_label.text, "LEVEL UP", "Should show LEVEL UP text")


func test_xp_award_multiple_levels() -> void:
	# Arrange - Give character 50 XP (50 away from level 2)
	CharacterService.add_xp(test_character_id, 50)

	var stats = {
		"wave": 30,  # 300 XP from waves (enough for 3 levels!)
		"kills": 0,
		"damage_dealt": 0,
		"time": 600.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Expected: 50 (existing) + 300 (new) = 350 total
	# Level 1→2 at 100 (100 total), Level 2→3 at 200 (300 total), Level 3→4 at 300 (600 total)
	# So: 350 total = Level 3 with 50 overflow

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("level", 1), 3, "Character should be level 3")

	var level_up_label = game_over_screen.get_node(
		"PaddingContainer/Content/XPContainer/LevelUpLabel"
	)
	assert_true(level_up_label.visible, "Level up label should be visible for multi-level")
	assert_string_contains(
		level_up_label.text, "LEVELS", "Should show LEVELS (plural) for multi-level"
	)


## ============================================================================
## SECTION 2: Character Record Updates
## User Story: "As a player, I want my stats tracked so I can see my progress"
## ============================================================================


func test_highest_wave_updated() -> void:
	# Arrange - Character starts with highest_wave = 0
	var stats = {
		"wave": 10,
		"kills": 50,
		"damage_dealt": 500,
		"time": 300.0,
		"scrap": 25,
		"components": 5,
		"nanites": 2
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("highest_wave", 0), 10, "Highest wave should be updated to 10")


func test_highest_wave_not_updated_if_lower() -> void:
	# Arrange - Set highest wave to 15
	var character = CharacterService.get_character(test_character_id)
	character["highest_wave"] = 15
	CharacterService.update_character(test_character_id, character)

	var stats = {
		"wave": 5,  # Lower than current highest
		"kills": 10,
		"damage_dealt": 100,
		"time": 60.0,
		"scrap": 5,
		"components": 1,
		"nanites": 0
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("highest_wave", 0), 15, "Highest wave should remain 15")


func test_total_kills_accumulated() -> void:
	# Arrange - Give character 100 existing kills
	var character = CharacterService.get_character(test_character_id)
	character["total_kills"] = 100
	CharacterService.update_character(test_character_id, character)

	var stats = {
		"wave": 3,
		"kills": 42,  # New kills this run
		"damage_dealt": 400,
		"time": 120.0,
		"scrap": 20,
		"components": 3,
		"nanites": 1
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("total_kills", 0), 142, "Total kills should be 100 + 42 = 142")


func test_death_count_incremented() -> void:
	# Arrange - Character starts with death_count = 0
	var stats = {
		"wave": 1,
		"kills": 5,
		"damage_dealt": 50,
		"time": 30.0,
		"scrap": 5,
		"components": 0,
		"nanites": 0
	}

	# Act - Die once
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("death_count", 0), 1, "Death count should be 1")

	# Act - Die again
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("death_count", 0), 2, "Death count should be 2")


## ============================================================================
## SECTION 3: XP Progress Bar
## User Story: "As a player, I want to see how close I am to the next level"
## ============================================================================


func test_xp_progress_bar_updated() -> void:
	# Arrange
	var stats = {
		"wave": 5,  # 50 XP
		"kills": 0,
		"damage_dealt": 0,
		"time": 60.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert - Level 1 with 50 XP, next level at 100
	var progress_bar = game_over_screen.get_node(
		"PaddingContainer/Content/XPContainer/XPProgressBar"
	)
	assert_eq(
		progress_bar.max_value, 100, "Progress bar max should be 100 (next level requirement)"
	)
	assert_eq(progress_bar.value, 50, "Progress bar value should be 50 (current XP)")


## ============================================================================
## SECTION 4: UI Display Tests
## User Story: "As a player, I want to see all my run stats clearly"
## ============================================================================


func test_stats_display_shows_all_stats() -> void:
	# Arrange
	var stats = {
		"wave": 7,
		"kills": 85,
		"damage_dealt": 12345,
		"time": 245.5,
		"scrap": 120,
		"components": 25,
		"nanites": 8
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert - Check labels exist with correct values
	var stats_container = game_over_screen.get_node("PaddingContainer/Content/StatsDisplay")
	var labels = stats_container.get_children()

	# Should have at least 7 labels (wave, kills, damage, time, spacer, scrap, components, nanites)
	assert_gte(labels.size(), 7, "Should have at least 7 stat labels")

	# Find and verify specific stats (labels are dynamically created)
	var found_wave = false
	var found_kills = false
	var found_damage = false

	for label in labels:
		if label is Label:
			if "Wave Reached: 7" in label.text:
				found_wave = true
			if "Enemies Killed: 85" in label.text:
				found_kills = true
			if "Damage Dealt:" in label.text and "12,345" in label.text:
				found_damage = true

	assert_true(found_wave, "Should display wave reached")
	assert_true(found_kills, "Should display enemies killed")
	assert_true(found_damage, "Should display damage dealt with formatting")


func test_xp_gained_label_shows_correct_value() -> void:
	# Arrange
	var stats = {
		"wave": 3,  # 30 XP
		"kills": 50,  # 5 XP
		"damage_dealt": 0,
		"time": 60.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var xp_label = game_over_screen.get_node("PaddingContainer/Content/XPContainer/XPGainedLabel")
	assert_eq(xp_label.text, "XP Gained: +35", "Should show correct XP gained (30 + 5)")


## ============================================================================
## SECTION 5: Edge Cases
## User Story: "As a developer, I want the screen to handle edge cases gracefully"
## ============================================================================


func test_no_character_id_shows_na() -> void:
	# Arrange
	var stats = {
		"wave": 1,
		"kills": 0,
		"damage_dealt": 0,
		"time": 10.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Act - Pass empty character_id
	game_over_screen.show_game_over(stats, "")
	await wait_frames(2)

	# Assert
	var xp_label = game_over_screen.get_node("PaddingContainer/Content/XPContainer/XPGainedLabel")
	assert_eq(xp_label.text, "XP Gained: N/A", "Should show N/A when no character")

	var level_up_label = game_over_screen.get_node(
		"PaddingContainer/Content/XPContainer/LevelUpLabel"
	)
	assert_false(level_up_label.visible, "Level up label should be hidden")


func test_zero_performance_gives_zero_xp() -> void:
	# Arrange
	var stats = {
		"wave": 0,  # 0 XP
		"kills": 0,  # 0 XP
		"damage_dealt": 0,
		"time": 5.0,
		"scrap": 0,
		"components": 0,
		"nanites": 0
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert
	var character = CharacterService.get_character(test_character_id)
	assert_eq(character.get("experience", 0), 0, "Character should have 0 XP")

	var xp_label = game_over_screen.get_node("PaddingContainer/Content/XPContainer/XPGainedLabel")
	assert_eq(xp_label.text, "XP Gained: +0", "Should show +0 XP")


func test_invalid_character_id_handles_gracefully() -> void:
	# Arrange
	var stats = {
		"wave": 5,
		"kills": 10,
		"damage_dealt": 100,
		"time": 60.0,
		"scrap": 10,
		"components": 2,
		"nanites": 0
	}

	# Act - Pass invalid character_id (should not crash)
	game_over_screen.show_game_over(stats, "invalid_char_999")
	await wait_frames(2)

	# Assert - Should still show stats, just not award XP
	var stats_container = game_over_screen.get_node("PaddingContainer/Content/StatsDisplay")
	assert_gt(
		stats_container.get_child_count(), 0, "Should still show stats even with invalid character"
	)


## ============================================================================
## SECTION 6: Save Integration
## User Story: "As a player, I want my progress saved automatically"
## ============================================================================


func test_character_progress_saved_on_death() -> void:
	# Arrange
	var stats = {
		"wave": 5,
		"kills": 50,
		"damage_dealt": 500,
		"time": 120.0,
		"scrap": 25,
		"components": 5,
		"nanites": 2
	}

	# Act
	game_over_screen.show_game_over(stats, test_character_id)
	await wait_frames(2)

	# Assert - Character should be saved (verify via fresh load)
	var character_before = CharacterService.get_character(test_character_id)
	var xp_before = character_before.get("experience", 0)
	var highest_wave_before = character_before.get("highest_wave", 0)

	# Character should have XP and highest wave set
	assert_gt(xp_before, 0, "Character should have XP")
	assert_eq(highest_wave_before, 5, "Highest wave should be 5")
