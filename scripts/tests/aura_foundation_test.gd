extends GutTest
## Test script for Aura System Foundation using GUT framework
##
## USER STORY: "As a player, I want each character type to have a unique aura
## that provides passive gameplay benefits, so that I can experience different
## playstyles with visual feedback"
##
## Week 7 Phase 3: Tests aura data structures, calculations, and persistence

class_name AuraFoundationTest


func before_each() -> void:
	# Reset service state before each test
	CharacterService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Aura Data Storage Tests
## User Story: "As a player, I want my character's aura data to be saved"
## ============================================================================


func test_aura_data_stored_in_character() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("TestChar", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.has("aura"), "Character should have aura data")
	assert_true(character.aura.has("type"), "Aura should have type field")
	assert_true(character.aura.has("enabled"), "Aura should have enabled field")
	assert_true(character.aura.has("level"), "Aura should have level field")


func test_aura_type_matches_character_type() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var scavenger_id = CharacterService.create_character("Scav", "scavenger")
	var scavenger = CharacterService.get_character(scavenger_id)

	# Assert
	assert_eq(scavenger.aura.type, "collect", "Scavenger should have collect aura")


func test_scavenger_has_collect_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("Scavenger", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, "collect", "Scavenger should have collect aura type")
	assert_true(character.aura.enabled, "Aura should be enabled by default")
	assert_eq(character.aura.level, 1, "Aura should start at level 1")


func test_tank_has_shield_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("Tank", "tank")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, "shield", "Tank should have shield aura type")
	assert_true(character.aura.enabled, "Aura should be enabled by default")


func test_commando_has_no_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var character_id = CharacterService.create_character("Commando", "commando")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_null(character.aura.type, "Commando should have null aura type")


## ============================================================================
## SECTION 2: Aura Calculation Tests
## User Story: "As a player, I want resonance stat to increase my aura power"
## ============================================================================


func test_calculate_aura_power_with_resonance() -> void:
	# Act & Assert - Damage aura: base 5 + (resonance * 0.5)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", 0), 5.0, 0.01, "Damage with 0 resonance"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", 10),
		10.0,
		0.01,
		"Damage with 10 resonance (5 + 10*0.5)"
	)

	# Shield aura: base 2 + (resonance * 0.2)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", 0), 2.0, 0.01, "Shield with 0 resonance"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", 10),
		4.0,
		0.01,
		"Shield with 10 resonance (2 + 10*0.2)"
	)


func test_calculate_aura_power_for_all_types() -> void:
	# Arrange
	var resonance = 20

	# Act & Assert - Test all aura types
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", resonance), 15.0, 0.01, "Damage: 5 + 20*0.5"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("knockback", resonance), 90.0, 0.01, "Knockback: 50 + 20*2.0"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("heal", resonance), 9.0, 0.01, "Heal: 3 + 20*0.3"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("collect", resonance), 2.0, 0.01, "Collect: 20*0.10"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("slow", resonance), 50.0, 0.01, "Slow: 30 + 20*1.0"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", resonance), 6.0, 0.01, "Shield: 2 + 20*0.2"
	)


func test_calculate_aura_radius_from_pickup_range() -> void:
	# Act & Assert
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(100), 100.0, 0.01, "Radius matches pickup_range"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(150), 150.0, 0.01, "Radius scales with pickup_range"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(200), 200.0, 0.01, "Radius = pickup_range * 1.0"
	)


func test_invalid_aura_type_returns_zero() -> void:
	# Act
	var power = AuraTypes.calculate_aura_power("invalid_type", 10)

	# Assert
	assert_eq(power, 0.0, "Invalid aura type should return 0 power")


## ============================================================================
## SECTION 3: Aura Persistence Tests
## User Story: "As a player, I want my character's aura to persist after save/load"
## ============================================================================


func test_aura_persists_after_save_load() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	var character_id = CharacterService.create_character("PersistTest", "tank")

	# Verify aura before save
	var character_before = CharacterService.get_character(character_id)
	assert_eq(character_before.aura.type, "shield", "Tank should have shield aura")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert - Verify aura after load
	var character_after = CharacterService.get_character(character_id)
	assert_eq(character_after.aura.type, "shield", "Aura type should persist after save/load")
	assert_true(character_after.aura.enabled, "Aura enabled state should persist")
	assert_eq(character_after.aura.level, 1, "Aura level should persist")


func test_multiple_characters_with_different_auras_persist() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	var scav_id = CharacterService.create_character("Scavenger", "scavenger")
	var tank_id = CharacterService.create_character("Tank", "tank")
	var cmd_id = CharacterService.create_character("Commando", "commando")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert - All aura types should persist correctly
	var scav = CharacterService.get_character(scav_id)
	var tank = CharacterService.get_character(tank_id)
	var cmd = CharacterService.get_character(cmd_id)

	assert_eq(scav.aura.type, "collect", "Scavenger aura should persist")
	assert_eq(tank.aura.type, "shield", "Tank aura should persist")
	assert_null(cmd.aura.type, "Commando null aura should persist")


## ============================================================================
## SECTION 4: Aura Type Definitions Tests
## User Story: "As a developer, I want all aura types to have proper definitions"
## ============================================================================


func test_all_aura_types_have_required_fields() -> void:
	# Arrange
	var required_fields = [
		"display_name",
		"description",
		"effect",
		"base_value",
		"scaling_stat",
		"radius_stat",
		"cooldown",
		"color"
	]

	# Act & Assert - Check each aura type
	for aura_key in AuraTypes.AURA_TYPES.keys():
		var aura_def = AuraTypes.AURA_TYPES[aura_key]

		for field in required_fields:
			assert_true(
				aura_def.has(field), "Aura type '%s' should have field '%s'" % [aura_key, field]
			)
