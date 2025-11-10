extends GutTest
## Test script for CharacterService using GUT framework
##
## USER STORY: "As a player, I want to create and manage multiple characters
## with different stats and progression, so that I can experiment with different
## playstyles and maintain multiple save files"
##
## Tests character CRUD, tier-based slots, level progression, SaveManager
## integration, and perk hooks.

class_name CharacterServiceTest


func before_each() -> void:
	# Reset service state before each test
	CharacterService.reset()

	# Set PREMIUM tier for most tests (allows 10 characters)
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Character Creation Tests
## User Story: "As a player, I want to create new characters with unique names"
## ============================================================================


func test_create_character_returns_valid_id() -> void:
	# Arrange
	var name = "TestWarrior"

	# Act
	var character_id = CharacterService.create_character(name)

	# Assert
	assert_ne(character_id, "", "Should return non-empty character ID")
	assert_true(character_id.begins_with("char_"), "Character ID should start with 'char_'")


func test_create_character_stores_correct_data() -> void:
	# Arrange
	var name = "TestScavenger"

	# Act
	var character_id = CharacterService.create_character(name)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.name, name, "Should store character name correctly")
	assert_eq(character.level, 1, "New character should be level 1")
	assert_eq(character.experience, 0, "New character should have 0 XP")
	assert_eq(character.death_count, 0, "New character should have 0 deaths")
	assert_eq(character.character_type, "scavenger", "Should have default character type")


func test_create_character_with_empty_name_fails() -> void:
	# Arrange
	var empty_name = ""

	# Act
	var character_id = CharacterService.create_character(empty_name)

	# Assert
	assert_eq(character_id, "", "Should fail with empty name")
	assert_eq(CharacterService.get_all_characters().size(), 0, "Should not create character")


func test_create_character_sets_default_stats() -> void:
	# Arrange
	var name = "TestCharacter"

	# Act
	var character_id = CharacterService.create_character(name)
	var character = CharacterService.get_character(character_id)

	# Assert - verify all default stats are present
	assert_true(character.has("stats"), "Character should have stats")
	assert_eq(character.stats.max_hp, 100, "Should have default max_hp")
	assert_eq(character.stats.damage, 10, "Should have default damage")
	assert_eq(character.stats.speed, 200, "Should have default speed")
	assert_eq(character.stats.armor, 0, "Should have default armor")


func test_first_character_becomes_active() -> void:
	# Arrange
	var name = "FirstCharacter"

	# Act
	var character_id = CharacterService.create_character(name)

	# Assert
	assert_eq(
		CharacterService.get_active_character_id(),
		character_id,
		"First character should become active"
	)


## ============================================================================
## SECTION 2: Character CRUD Tests
## User Story: "As a player, I want to view, update, and delete my characters"
## ============================================================================


func test_get_character_returns_correct_data() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestGet")

	# Act
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_ne(character, {}, "Should return character data")
	assert_eq(character.id, character_id, "Should have correct ID")


func test_get_nonexistent_character_returns_empty_dict() -> void:
	# Arrange - No setup needed

	# Act
	var character = CharacterService.get_character("invalid_id")

	# Assert
	assert_eq(character, {}, "Should return empty dictionary for nonexistent character")


func test_get_all_characters_returns_all_created() -> void:
	# Arrange
	CharacterService.create_character("Char1")
	CharacterService.create_character("Char2")
	CharacterService.create_character("Char3")

	# Act
	var all_characters = CharacterService.get_all_characters()

	# Assert
	assert_eq(all_characters.size(), 3, "Should return all 3 characters")


func test_update_character_modifies_data() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestUpdate")

	# Act
	var success = CharacterService.update_character(character_id, {"level": 5, "experience": 250})
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(success, "Update should succeed")
	assert_eq(character.level, 5, "Level should be updated")
	assert_eq(character.experience, 250, "Experience should be updated")


func test_update_nonexistent_character_fails() -> void:
	# Arrange - No setup needed

	# Act
	var success = CharacterService.update_character("invalid_id", {"level": 10})

	# Assert
	assert_false(success, "Update should fail for nonexistent character")


func test_delete_character_removes_from_storage() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestDelete")

	# Act
	var success = CharacterService.delete_character(character_id)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(success, "Delete should succeed")
	assert_eq(character, {}, "Character should no longer exist")


func test_delete_active_character_clears_active_state() -> void:
	# Arrange
	var char1_id = CharacterService.create_character("Char1")
	var char2_id = CharacterService.create_character("Char2")
	CharacterService.set_active_character(char1_id)

	# Act
	CharacterService.delete_character(char1_id)

	# Assert - should auto-select remaining character
	assert_eq(
		CharacterService.get_active_character_id(),
		char2_id,
		"Should auto-select remaining character"
	)


func test_delete_only_character_clears_active() -> void:
	# Arrange
	var character_id = CharacterService.create_character("OnlyChar")

	# Act
	CharacterService.delete_character(character_id)

	# Assert
	assert_eq(
		CharacterService.get_active_character_id(),
		"",
		"Active should be empty when no characters exist"
	)


## ============================================================================
## SECTION 3: Active Character Tests
## User Story: "As a player, I want to switch between my characters"
## ============================================================================


func test_set_active_character_changes_active() -> void:
	# Arrange
	var char1_id = CharacterService.create_character("Char1")
	var char2_id = CharacterService.create_character("Char2")

	# Act
	var success = CharacterService.set_active_character(char2_id)

	# Assert
	assert_true(success, "Set active should succeed")
	assert_eq(
		CharacterService.get_active_character_id(), char2_id, "Active character should change"
	)


func test_set_active_nonexistent_character_fails() -> void:
	# Arrange - No setup needed

	# Act
	var success = CharacterService.set_active_character("invalid_id")

	# Assert
	assert_false(success, "Set active should fail for nonexistent character")
	assert_eq(
		CharacterService.get_active_character_id(), "", "Active character should remain empty"
	)


func test_get_active_character_returns_correct_data() -> void:
	# Arrange
	var char1_id = CharacterService.create_character("ActiveChar")
	CharacterService.set_active_character(char1_id)

	# Act
	var active_character = CharacterService.get_active_character()

	# Assert
	assert_ne(active_character, {}, "Should return character data")
	assert_eq(active_character.id, char1_id, "Should return correct character")


## ============================================================================
## SECTION 4: Tier-Based Slot Limits Tests
## User Story: "As a free player, I want to create up to 3 characters"
## User Story: "As a premium player, I want to create up to 10 characters"
## User Story: "As a subscription player, I want unlimited characters"
## ============================================================================


func test_free_tier_allows_3_characters() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act - Try to create 4 characters
	var char1 = CharacterService.create_character("Free1")
	var char2 = CharacterService.create_character("Free2")
	var char3 = CharacterService.create_character("Free3")
	var char4 = CharacterService.create_character("Free4")  # Should fail

	# Assert
	assert_ne(char1, "", "First character should succeed")
	assert_ne(char2, "", "Second character should succeed")
	assert_ne(char3, "", "Third character should succeed")
	assert_eq(char4, "", "Fourth character should fail (FREE tier limit)")
	assert_eq(CharacterService.get_all_characters().size(), 3, "Should have exactly 3 characters")


func test_premium_tier_allows_10_characters() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act - Create 10 characters
	for i in range(10):
		var char_id = CharacterService.create_character("Premium%d" % i)
		assert_ne(char_id, "", "Character %d should succeed" % i)

	# Try to create 11th character
	var char11 = CharacterService.create_character("Premium11")

	# Assert
	assert_eq(char11, "", "11th character should fail (PREMIUM tier limit)")
	assert_eq(CharacterService.get_all_characters().size(), 10, "Should have exactly 10 characters")


func test_subscription_tier_allows_unlimited_characters() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act - Create 15 characters (more than PREMIUM limit)
	for i in range(15):
		var char_id = CharacterService.create_character("Sub%d" % i)
		assert_ne(char_id, "", "Character %d should succeed (SUBSCRIPTION = unlimited)" % i)

	# Assert
	assert_eq(CharacterService.get_all_characters().size(), 15, "Should have 15 characters")


func test_can_create_character_respects_tier_limits() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act & Assert - Check availability at each step
	assert_true(CharacterService.can_create_character(), "Should allow first character")
	CharacterService.create_character("Char1")

	assert_true(CharacterService.can_create_character(), "Should allow second character")
	CharacterService.create_character("Char2")

	assert_true(CharacterService.can_create_character(), "Should allow third character")
	CharacterService.create_character("Char3")

	assert_false(
		CharacterService.can_create_character(), "Should block fourth character (FREE tier)"
	)


func test_get_available_slots_returns_correct_count() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act & Assert
	assert_eq(CharacterService.get_available_slots(), 3, "FREE tier should have 3 slots available")

	CharacterService.create_character("Char1")
	assert_eq(CharacterService.get_available_slots(), 2, "Should have 2 slots remaining")

	CharacterService.create_character("Char2")
	assert_eq(CharacterService.get_available_slots(), 1, "Should have 1 slot remaining")

	CharacterService.create_character("Char3")
	assert_eq(CharacterService.get_available_slots(), 0, "Should have 0 slots remaining")


## ============================================================================
## SECTION 5: Level Progression Tests
## User Story: "As a player, I want to gain experience and level up my character"
## ============================================================================


func test_add_experience_increases_xp() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestXP")

	# Act
	var leveled_up = CharacterService.add_experience(character_id, 50)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_false(leveled_up, "Should not level up with 50 XP")
	assert_eq(character.experience, 50, "XP should increase to 50")
	assert_eq(character.level, 1, "Level should remain 1")


func test_level_up_at_100_xp() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestLevelUp")

	# Act
	var leveled_up = CharacterService.add_experience(character_id, 100)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(leveled_up, "Should level up at 100 XP")
	assert_eq(character.level, 2, "Should be level 2")
	assert_eq(character.experience, 0, "XP should reset to 0")


func test_level_up_increases_stats() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestStats")
	var original_character = CharacterService.get_character(character_id)
	var original_hp = original_character.stats.max_hp
	var original_damage = original_character.stats.damage
	var original_armor = original_character.stats.armor

	# Act
	CharacterService.add_experience(character_id, 100)
	var character = CharacterService.get_character(character_id)

	# Assert - verify stat gains
	assert_eq(character.stats.max_hp, original_hp + 5, "Max HP should increase by 5")
	assert_eq(character.stats.damage, original_damage + 2, "Damage should increase by 2")
	assert_eq(character.stats.armor, original_armor + 1, "Armor should increase by 1")


func test_multiple_level_ups_from_single_xp_gain() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestMulti")

	# Act - Add enough XP for 2 level ups (Level 1→2 = 100 XP, Level 2→3 = 200 XP)
	CharacterService.add_experience(character_id, 300)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.level, 3, "Should reach level 3")
	assert_eq(character.experience, 0, "XP should be 0")


func test_add_zero_or_negative_xp_does_nothing() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestNegative")

	# Act
	var result1 = CharacterService.add_experience(character_id, 0)
	var result2 = CharacterService.add_experience(character_id, -50)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_false(result1, "Should return false for 0 XP")
	assert_false(result2, "Should return false for negative XP")
	assert_eq(character.experience, 0, "XP should remain 0")


## ============================================================================
## SECTION 6: Character Death Tests
## User Story: "As a player, I want death to have consequences (death count)"
## ============================================================================


func test_character_death_increments_death_count() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestDeath")

	# Act
	var resurrected = CharacterService.on_character_death(character_id)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_false(resurrected, "Should not be resurrected by default")
	assert_eq(character.death_count, 1, "Death count should increment")


func test_multiple_deaths_increment_count() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestMultiDeath")

	# Act
	CharacterService.on_character_death(character_id)
	CharacterService.on_character_death(character_id)
	CharacterService.on_character_death(character_id)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.death_count, 3, "Death count should be 3")


## ============================================================================
## SECTION 7: Perk Hook Tests
## User Story: "As a developer, I want perk hooks to fire at correct times"
## ============================================================================


func test_character_create_pre_hook_fires() -> void:
	# Arrange
	watch_signals(CharacterService)

	# Act
	CharacterService.create_character("TestPreHook")

	# Assert
	assert_signal_emitted(
		CharacterService, "character_create_pre", "character_create_pre should fire before creation"
	)


func test_character_create_post_hook_fires() -> void:
	# Arrange
	watch_signals(CharacterService)

	# Act
	CharacterService.create_character("TestPostHook")

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_create_post",
		"character_create_post should fire after creation"
	)


func test_character_level_up_pre_hook_fires() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestLevelPreHook")
	watch_signals(CharacterService)

	# Act
	CharacterService.add_experience(character_id, 100)

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_level_up_pre",
		"character_level_up_pre should fire before level up"
	)


func test_character_level_up_post_hook_fires() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestLevelPostHook")
	watch_signals(CharacterService)

	# Act
	CharacterService.add_experience(character_id, 100)

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_level_up_post",
		"character_level_up_post should fire after level up"
	)


func test_character_death_pre_hook_fires() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestDeathPreHook")
	watch_signals(CharacterService)

	# Act
	CharacterService.on_character_death(character_id)

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_death_pre",
		"character_death_pre should fire before death processing"
	)


func test_character_death_post_hook_fires() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestDeathPostHook")
	watch_signals(CharacterService)

	# Act
	CharacterService.on_character_death(character_id)

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_death_post",
		"character_death_post should fire after death processing"
	)


## ============================================================================
## SECTION 8: SaveManager Integration Tests
## User Story: "As a player, I want my characters to persist between sessions"
## ============================================================================


func test_serialize_returns_valid_data() -> void:
	# Arrange
	CharacterService.create_character("SaveChar1")
	CharacterService.create_character("SaveChar2")

	# Act
	var data = CharacterService.serialize()

	# Assert
	assert_eq(data.version, 1, "Should have version 1")
	assert_true(data.has("characters"), "Should have characters key")
	assert_eq(data.characters.size(), 2, "Should serialize both characters")
	assert_true(data.has("active_character_id"), "Should have active_character_id key")


func test_deserialize_restores_characters() -> void:
	# Arrange
	var char1_id = CharacterService.create_character("Char1")
	var char2_id = CharacterService.create_character("Char2")
	CharacterService.set_active_character(char2_id)

	var saved_data = CharacterService.serialize()

	# Reset service
	CharacterService.reset()

	# Act
	CharacterService.deserialize(saved_data)

	# Assert
	assert_eq(CharacterService.get_all_characters().size(), 2, "Should restore 2 characters")
	assert_eq(
		CharacterService.get_active_character_id(), char2_id, "Should restore active character"
	)


func test_deserialize_restores_character_stats() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestDeserialize")
	CharacterService.add_experience(character_id, 150)  # Level up
	CharacterService.update_character(character_id, {"death_count": 3})

	var saved_data = CharacterService.serialize()

	# Reset service
	CharacterService.reset()

	# Act
	CharacterService.deserialize(saved_data)
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.level, 2, "Should restore level")
	assert_eq(character.experience, 50, "Should restore XP")
	assert_eq(character.death_count, 3, "Should restore death count")


func test_full_save_load_cycle_with_save_manager() -> void:
	# Arrange
	var char_id = CharacterService.create_character("FullSaveTest")
	CharacterService.add_experience(char_id, 200)

	# Act - Save all services
	var save_success = SaveManager.save_all_services(0)
	assert_true(save_success, "Save should succeed")

	# Reset service
	CharacterService.reset()
	assert_eq(
		CharacterService.get_all_characters().size(), 0, "Characters should be cleared after reset"
	)

	# Load all services
	var load_success = SaveManager.load_all_services(0)
	assert_true(load_success, "Load should succeed")

	# Assert - Verify character was restored
	var character = CharacterService.get_character(char_id)
	assert_ne(character, {}, "Character should be restored")
	assert_eq(character.level, 2, "Level should be restored")


## ============================================================================
## SECTION 9: Signal Tests
## User Story: "As a UI developer, I want to be notified of character changes"
## ============================================================================


func test_character_created_signal_fires() -> void:
	# Arrange
	watch_signals(CharacterService)

	# Act
	CharacterService.create_character("SignalTest")

	# Assert
	assert_signal_emitted(
		CharacterService, "character_created", "character_created signal should fire"
	)


func test_character_deleted_signal_fires() -> void:
	# Arrange
	var character_id = CharacterService.create_character("DeleteSignalTest")
	watch_signals(CharacterService)

	# Act
	CharacterService.delete_character(character_id)

	# Assert
	assert_signal_emitted(
		CharacterService, "character_deleted", "character_deleted signal should fire"
	)


func test_active_character_changed_signal_fires() -> void:
	# Arrange
	var char1_id = CharacterService.create_character("Char1")
	var char2_id = CharacterService.create_character("Char2")
	watch_signals(CharacterService)

	# Act
	CharacterService.set_active_character(char2_id)

	# Assert
	assert_signal_emitted(
		CharacterService, "active_character_changed", "active_character_changed signal should fire"
	)


func test_character_stats_changed_signal_fires_on_update() -> void:
	# Arrange
	var character_id = CharacterService.create_character("StatsTest")
	watch_signals(CharacterService)

	# Act
	CharacterService.update_character(character_id, {"level": 5})

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_stats_changed",
		"character_stats_changed signal should fire on update"
	)


func test_character_stats_changed_signal_fires_on_level_up() -> void:
	# Arrange
	var character_id = CharacterService.create_character("LevelTest")
	watch_signals(CharacterService)

	# Act
	CharacterService.add_experience(character_id, 100)

	# Assert
	assert_signal_emitted(
		CharacterService,
		"character_stats_changed",
		"character_stats_changed signal should fire on level up"
	)
