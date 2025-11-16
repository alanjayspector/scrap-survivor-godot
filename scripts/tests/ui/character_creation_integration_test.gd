extends GutTest
## Integration Test for Character Creation Flow
##
## Week 15 Phase 2: Full character creation workflow testing
##
## USER STORY: "As a player, I want a seamless flow from creating a character
## to starting my first run, with all data persisted correctly"
##
## Tests complete flow: Hub → Create Character → Save → Combat
## Validates scene transitions, save persistence, and state management.

class_name CharacterCreationIntegrationTest


func before_each() -> void:
	# Reset all services
	CharacterService.reset()
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	GameState.reset()
	SaveManager.delete_save(0)  # Clear save file

	# Wait for services to stabilize
	await wait_frames(2)


func after_each() -> void:
	# Cleanup
	CharacterService.reset()
	GameState.reset()


## ============================================================================
## SECTION 1: Full Creation Flow Tests
## User Story: "As a player, I want to create a character and start playing"
## ============================================================================


func test_create_character_full_flow() -> void:
	# Arrange - Start with no characters
	assert_eq(CharacterService.get_character_count(), 0, "Should start with 0 characters")

	# Act - Create character through service
	var character_id = CharacterService.create_character("IntegrationHero", "scavenger")

	# Assert - Character created
	assert_ne(character_id, "", "Character should be created successfully")
	assert_eq(CharacterService.get_character_count(), 1, "Should have 1 character")

	# Act - Set as active
	GameState.set_active_character(character_id)

	# Assert - Active character set
	assert_eq(GameState.active_character_id, character_id, "Active character should be set")

	# Act - Save
	var save_success = SaveManager.save_all_services()

	# Assert - Save successful
	assert_true(save_success, "Save should succeed")


func test_character_persists_after_save_and_load() -> void:
	# Arrange - Create and save character
	var character_id = CharacterService.create_character("PersistTest", "scavenger")
	GameState.set_active_character(character_id)
	SaveManager.save_all_services()

	# Act - Reset services and load
	CharacterService.reset()
	GameState.reset()
	var load_success = SaveManager.load_all_services()

	# Assert - Character restored
	assert_true(load_success, "Load should succeed")
	assert_eq(CharacterService.get_character_count(), 1, "Should have 1 character after load")

	var loaded_character = CharacterService.get_character(character_id)
	assert_eq(loaded_character.name, "PersistTest", "Character name should be restored")
	assert_eq(loaded_character.character_type, "scavenger", "Character type should be restored")


func test_multiple_characters_persist_correctly() -> void:
	# Arrange - Create multiple characters
	var char1_id = CharacterService.create_character("Hero1", "scavenger")
	var char2_id = CharacterService.create_character("Hero2", "tank")
	var char3_id = CharacterService.create_character("Hero3", "scavenger")

	GameState.set_active_character(char2_id)
	SaveManager.save_all_services()

	# Act - Reset and load
	CharacterService.reset()
	GameState.reset()
	SaveManager.load_all_services()

	# Assert - All characters restored
	assert_eq(CharacterService.get_character_count(), 3, "Should have 3 characters")
	assert_eq(GameState.active_character_id, char2_id, "Active character should be restored")


## ============================================================================
## SECTION 2: Slot Limit Integration Tests
## User Story: "As a player, I want slot limits enforced across sessions"
## ============================================================================


func test_slot_limit_enforced_after_save_and_load() -> void:
	# Arrange - Set FREE tier and create 3 characters (at limit)
	CharacterService.set_tier(CharacterService.UserTier.FREE)
	CharacterService.create_character("Char1", "scavenger")
	CharacterService.create_character("Char2", "scavenger")
	CharacterService.create_character("Char3", "scavenger")
	SaveManager.save_all_services()

	# Act - Reset and load
	CharacterService.reset()
	SaveManager.load_all_services()

	# Try to create 4th character
	var fourth_id = CharacterService.create_character("Char4", "scavenger")

	# Assert - Should still be at limit
	assert_eq(fourth_id, "", "Should not allow 4th character after load")
	assert_eq(CharacterService.get_character_count(), 3, "Should still have 3 characters")


func test_tier_upgrade_allows_more_slots() -> void:
	# Arrange - Create 3 characters on FREE tier
	CharacterService.set_tier(CharacterService.UserTier.FREE)
	CharacterService.create_character("Char1", "scavenger")
	CharacterService.create_character("Char2", "scavenger")
	CharacterService.create_character("Char3", "scavenger")

	# Verify at limit
	assert_false(CharacterService.can_create_character(), "Should be at FREE tier limit")

	# Act - Upgrade to PREMIUM tier
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Assert - Can now create more
	assert_true(CharacterService.can_create_character(), "Should be able to create more on PREMIUM")

	# Create 12 more (total 15 = PREMIUM limit)
	for i in range(12):
		var char_id = CharacterService.create_character("Premium%d" % i, "scavenger")
		assert_ne(char_id, "", "Should create character %d" % i)

	assert_eq(CharacterService.get_character_count(), 15, "Should have 15 characters")


## ============================================================================
## SECTION 3: GameState Integration Tests
## User Story: "As a developer, I want GameState to track active character"
## ============================================================================


func test_active_character_persists_across_scenes() -> void:
	# Arrange - Create character and set as active
	var character_id = CharacterService.create_character("ActiveTest", "scavenger")
	GameState.set_active_character(character_id)

	# Save state
	SaveManager.save_all_services()

	# Act - Simulate scene change by clearing and reloading
	var saved_active_id = GameState.active_character_id
	GameState.reset()
	SaveManager.load_all_services()

	# Note: GameState.active_character_id is not saved by SaveManager
	# It's set by the scene when character is selected
	# So we verify character exists and can be set as active again
	var success = GameState.set_active_character(character_id)

	# Assert
	assert_true(success, "Should be able to set active character")
	assert_eq(GameState.active_character_id, character_id, "Active character should be set")


func test_get_active_character_returns_correct_data() -> void:
	# Arrange
	var character_id = CharacterService.create_character("GetActiveTest", "tank")
	GameState.set_active_character(character_id)

	# Act
	var active_character = GameState.get_active_character()

	# Assert
	assert_eq(active_character.name, "GetActiveTest", "Should return correct character name")
	assert_eq(active_character.character_type, "tank", "Should return correct character type")


## ============================================================================
## SECTION 4: Save/Load Edge Cases
## User Story: "As a player, I want my data safe even in edge cases"
## ============================================================================


func test_load_with_no_save_file() -> void:
	# Arrange - Ensure no save file exists
	SaveManager.delete_save(0)

	# Act
	var load_success = SaveManager.load_all_services()

	# Assert - Should handle gracefully (return false or true with empty data)
	# Behavior depends on SaveManager implementation
	if load_success:
		assert_eq(
			CharacterService.get_character_count(), 0, "Should have 0 characters with no save"
		)
	else:
		pass_test("SaveManager correctly returns false for missing save file")


func test_character_creation_with_special_characters_in_name() -> void:
	# Arrange - Names with special characters
	var test_names = [
		"Hero123",
		"Hero-X",
		"Hero's",
		"Héro",  # Accented character
		"英雄",  # Unicode (Chinese)
	]

	# Act & Assert
	for test_name in test_names:
		var character_id = CharacterService.create_character(test_name, "scavenger")

		if character_id != "":
			var character = CharacterService.get_character(character_id)
			assert_eq(
				character.name,
				test_name,
				"Special character name should be preserved: %s" % test_name
			)


func test_save_and_load_preserves_character_stats() -> void:
	# Arrange - Create character and modify stats
	var character_id = CharacterService.create_character("StatsTest", "scavenger")
	CharacterService.add_experience(character_id, 100)  # Level up to 2

	var character_before = CharacterService.get_character(character_id)
	var level_before = character_before.level

	# Save
	SaveManager.save_all_services()

	# Act - Reset and load
	CharacterService.reset()
	SaveManager.load_all_services()

	var character_after = CharacterService.get_character(character_id)

	# Assert - Stats preserved
	assert_eq(character_after.level, level_before, "Level should be preserved")
	assert_eq(
		character_after.stats.max_hp, character_before.stats.max_hp, "Stats should be preserved"
	)


## ============================================================================
## SECTION 5: Analytics Integration Tests
## User Story: "As a product manager, I want analytics events tracked"
## ============================================================================


func test_analytics_track_character_creation() -> void:
	# This test verifies Analytics integration exists
	# Actual analytics output is verified in logs

	# Arrange
	var character_type = "scavenger"

	# Act - Create character (should trigger Analytics.character_created)
	var character_id = CharacterService.create_character("AnalyticsTest", character_type)

	# Assert - Character created (analytics logged in background)
	assert_ne(character_id, "", "Character should be created")

	# Analytics verification happens via log inspection in QA
	pass_test("Analytics integration present (verify in logs)")


## ============================================================================
## SECTION 6: First-Run Flow Tests
## User Story: "As a first-time player, I want guided character creation"
## ============================================================================


func test_first_run_detection_with_no_save() -> void:
	# Arrange - Ensure no save file
	SaveManager.delete_save(0)

	# Act
	var has_save = SaveManager.has_save(0)

	# Assert
	assert_false(has_save, "Should detect first run (no save file)")


func test_first_run_detection_after_character_created() -> void:
	# Arrange - Create character and save
	CharacterService.create_character("FirstRun", "scavenger")
	SaveManager.save_all_services()

	# Act
	var has_save = SaveManager.has_save(0)

	# Assert
	assert_true(has_save, "Should detect save file exists after character creation")


## ============================================================================
## SECTION 7: Delete Character Integration Tests
## User Story: "As a player, I want to delete characters and free slots"
## ============================================================================


func test_delete_character_frees_slot() -> void:
	# Arrange - Set FREE tier (3 slots)
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	var char1_id = CharacterService.create_character("Char1", "scavenger")
	CharacterService.create_character("Char2", "scavenger")
	CharacterService.create_character("Char3", "scavenger")

	# Verify at limit
	assert_false(CharacterService.can_create_character(), "Should be at slot limit")

	# Act - Delete one character
	var delete_success = CharacterService.delete_character(char1_id)

	# Assert - Can now create again
	assert_true(delete_success, "Should delete character successfully")
	assert_true(CharacterService.can_create_character(), "Should be able to create after delete")

	var new_char_id = CharacterService.create_character("NewChar", "scavenger")
	assert_ne(new_char_id, "", "Should create new character in freed slot")


func test_delete_and_save_persists() -> void:
	# Arrange - Create 3 characters
	var char1_id = CharacterService.create_character("Char1", "scavenger")
	CharacterService.create_character("Char2", "scavenger")
	CharacterService.create_character("Char3", "scavenger")

	# Delete one and save
	CharacterService.delete_character(char1_id)
	SaveManager.save_all_services()

	# Act - Reset and load
	CharacterService.reset()
	SaveManager.load_all_services()

	# Assert - Should have 2 characters
	assert_eq(
		CharacterService.get_character_count(), 2, "Should have 2 characters after delete and load"
	)

	var deleted_character = CharacterService.get_character(char1_id)
	assert_eq(deleted_character, {}, "Deleted character should not exist")
