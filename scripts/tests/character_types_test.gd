extends GutTest
## Test script for CharacterService character types using GUT framework
##
## USER STORY: "As a player, I want to unlock and play different character types
## with unique abilities and stat modifiers, so that I can experiment with
## different playstyles based on my subscription tier"
##
## Week 7 Phase 2: Tests character type system with tier restrictions,
## stat modifiers, and aura integration

class_name CharacterTypesTest


func before_each() -> void:
	# Reset service state before each test
	CharacterService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Character Type Stat Modifier Tests
## User Story: "As a player, I want each character type to have unique stats"
## ============================================================================


func test_scavenger_has_correct_stat_modifiers() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("TestScavenger", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.stats.scavenging, 5, "Scavenger should have +5 scavenging")
	assert_eq(
		character.stats.pickup_range, 120, "Scavenger should have 120 pickup range (100 + 20)"
	)


func test_tank_has_correct_stat_modifiers() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("TestTank", "tank")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.stats.max_hp, 120, "Tank should have 120 HP (100 + 20)")
	assert_eq(character.stats.armor, 3, "Tank should have 3 armor (0 + 3)")
	assert_eq(character.stats.speed, 180, "Tank should have 180 speed (200 - 20)")


func test_commando_has_correct_stat_modifiers() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var character_id = CharacterService.create_character("TestCommando", "commando")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.stats.ranged_damage, 5, "Commando should have +5 ranged damage")
	assert_eq(character.stats.attack_speed, 15, "Commando should have +15% attack speed")
	assert_eq(character.stats.armor, -2, "Commando should have -2 armor (0 - 2)")


func test_character_type_stored_correctly() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var tank_id = CharacterService.create_character("TankTest", "tank")
	var tank = CharacterService.get_character(tank_id)

	# Assert
	assert_eq(tank.character_type, "tank", "Character type should be stored correctly")


## ============================================================================
## SECTION 2: Tier Restriction Tests
## User Story: "As a player, I can only create character types my tier allows"
## ============================================================================


func test_free_tier_can_create_scavenger() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("FreeScavenger", "scavenger")

	# Assert
	assert_ne(character_id, "", "FREE tier should be able to create scavenger")


func test_free_tier_cannot_create_tank() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("FreeTank", "tank")

	# Assert
	assert_eq(character_id, "", "FREE tier should NOT be able to create tank")


func test_free_tier_cannot_create_commando() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("FreeCommando", "commando")

	# Assert
	assert_eq(character_id, "", "FREE tier should NOT be able to create commando")


func test_premium_tier_can_create_scavenger() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("PremiumScavenger", "scavenger")

	# Assert
	assert_ne(character_id, "", "PREMIUM tier should be able to create scavenger")


func test_premium_tier_can_create_tank() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("PremiumTank", "tank")

	# Assert
	assert_ne(character_id, "", "PREMIUM tier should be able to create tank")


func test_premium_tier_cannot_create_commando() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("PremiumCommando", "commando")

	# Assert
	assert_eq(character_id, "", "PREMIUM tier should NOT be able to create commando")


func test_subscription_tier_can_create_all_types() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var scavenger_id = CharacterService.create_character("SubScavenger", "scavenger")
	var tank_id = CharacterService.create_character("SubTank", "tank")
	var commando_id = CharacterService.create_character("SubCommando", "commando")

	# Assert
	assert_ne(scavenger_id, "", "SUBSCRIPTION tier should create scavenger")
	assert_ne(tank_id, "", "SUBSCRIPTION tier should create tank")
	assert_ne(commando_id, "", "SUBSCRIPTION tier should create commando")


## ============================================================================
## SECTION 3: Aura System Integration Tests
## User Story: "As a player, each character type should have a unique aura"
## ============================================================================


func test_scavenger_has_collect_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("AuraScavenger", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.has("aura"), "Character should have aura data")
	assert_eq(character.aura.type, "collect", "Scavenger should have collect aura")
	assert_eq(character.aura.enabled, true, "Aura should be enabled by default")
	assert_eq(character.aura.level, 1, "Aura should start at level 1")


func test_tank_has_shield_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("AuraTank", "tank")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, "shield", "Tank should have shield aura")


func test_commando_has_no_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var character_id = CharacterService.create_character("AuraCommando", "commando")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, null, "Commando should have no aura (null)")


## ============================================================================
## SECTION 4: SaveManager Integration & Edge Cases
## User Story: "As a player, my character types should persist after save/load"
## ============================================================================


func test_character_type_persists_after_save_load() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	var tank_id = CharacterService.create_character("PersistTank", "tank")
	var commando_id = CharacterService.create_character("PersistCommando", "commando")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert
	var tank = CharacterService.get_character(tank_id)
	var commando = CharacterService.get_character(commando_id)

	assert_eq(tank.character_type, "tank", "Tank type should persist")
	assert_eq(commando.character_type, "commando", "Commando type should persist")
	assert_eq(tank.stats.armor, 3, "Tank stat modifiers should persist")
	assert_eq(commando.stats.ranged_damage, 5, "Commando stat modifiers should persist")


func test_aura_type_persists_after_save_load() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	var scavenger_id = CharacterService.create_character("AuraSave", "scavenger")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert
	var character = CharacterService.get_character(scavenger_id)
	assert_eq(character.aura.type, "collect", "Aura type should persist")
	assert_eq(character.aura.level, 1, "Aura level should persist")


func test_invalid_character_type_fails() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var character_id = CharacterService.create_character("InvalidType", "nonexistent_type")

	# Assert
	assert_eq(character_id, "", "Should fail with invalid character type")


func test_multiple_characters_with_different_types() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var scavenger_id = CharacterService.create_character("Multi1", "scavenger")
	var tank_id = CharacterService.create_character("Multi2", "tank")
	var commando_id = CharacterService.create_character("Multi3", "commando")

	# Assert
	var all_chars = CharacterService.get_all_characters()
	assert_eq(all_chars.size(), 3, "Should have 3 characters")

	var scavenger = CharacterService.get_character(scavenger_id)
	var tank = CharacterService.get_character(tank_id)
	var commando = CharacterService.get_character(commando_id)

	assert_eq(scavenger.stats.scavenging, 5, "Scavenger should have unique stats")
	assert_eq(tank.stats.max_hp, 120, "Tank should have unique stats")
	assert_eq(commando.stats.ranged_damage, 5, "Commando should have unique stats")


func test_character_type_defaults_to_scavenger() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act - Create character without specifying type (uses default parameter)
	var character_id = CharacterService.create_character("DefaultType")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.character_type, "scavenger", "Should default to scavenger")
	assert_eq(character.stats.scavenging, 5, "Should have scavenger stat modifiers")
