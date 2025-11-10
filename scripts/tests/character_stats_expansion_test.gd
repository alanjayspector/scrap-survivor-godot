extends GutTest
## Test script for CharacterService Stat Expansion (Week 7 Phase 1)
##
## USER STORY: "As a player, I want my character to have diverse stats like HP regen,
## life steal, attack speed, and resonance, so that I can build unique playstyles
## with different strategic advantages"
##
## Tests the 6 new stats added in Week 7:
## - hp_regen, life_steal, attack_speed (survival/combat)
## - melee_damage, ranged_damage (offense specialization)
## - scavenging (economy), resonance (aura power)

class_name CharacterStatsExpansionTest


func before_each() -> void:
	# Reset service state before each test
	CharacterService.reset()
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: New Stats Exist in DEFAULT_BASE_STATS
## User Story: "As a developer, I want all new stats defined in constants"
## ============================================================================


func test_hp_regen_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("hp_regen"), "hp_regen should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.hp_regen, 0, "hp_regen should default to 0")


func test_life_steal_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("life_steal"), "life_steal should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.life_steal, 0.0, "life_steal should default to 0.0")


func test_attack_speed_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("attack_speed"), "attack_speed should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.attack_speed, 0.0, "attack_speed should default to 0.0")


func test_melee_damage_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("melee_damage"), "melee_damage should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.melee_damage, 0, "melee_damage should default to 0")


func test_ranged_damage_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("ranged_damage"), "ranged_damage should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.ranged_damage, 0, "ranged_damage should default to 0")


func test_scavenging_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("scavenging"), "scavenging should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.scavenging, 0, "scavenging should default to 0")


func test_resonance_exists_in_default_stats() -> void:
	# Arrange & Act
	var stats = CharacterService.DEFAULT_BASE_STATS

	# Assert
	assert_true(stats.has("resonance"), "resonance should exist in DEFAULT_BASE_STATS")
	assert_eq(stats.resonance, 0, "resonance should default to 0")


## ============================================================================
## SECTION 2: New Stats Initialize Correctly in Characters
## User Story: "As a player, when I create a character, all stats should be initialized"
## ============================================================================


func test_new_character_has_hp_regen() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("hp_regen"), "New character should have hp_regen stat")
	assert_eq(character.stats.hp_regen, 0, "New character hp_regen should be 0")


func test_new_character_has_life_steal() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("life_steal"), "New character should have life_steal stat")
	assert_eq(character.stats.life_steal, 0.0, "New character life_steal should be 0.0")


func test_new_character_has_attack_speed() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("attack_speed"), "New character should have attack_speed stat")
	assert_eq(character.stats.attack_speed, 0.0, "New character attack_speed should be 0.0")


func test_new_character_has_melee_and_ranged_damage() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("melee_damage"), "New character should have melee_damage stat")
	assert_eq(character.stats.melee_damage, 0, "New character melee_damage should be 0")
	assert_true(
		character.stats.has("ranged_damage"), "New character should have ranged_damage stat"
	)
	assert_eq(character.stats.ranged_damage, 0, "New character ranged_damage should be 0")


func test_new_character_has_scavenging() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("scavenging"), "New character should have scavenging stat")
	assert_eq(
		character.stats.scavenging,
		5,
		"New character scavenging should be 5 (default scavenger type bonus)"
	)


func test_new_character_has_resonance() -> void:
	# Arrange & Act
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.stats.has("resonance"), "New character should have resonance stat")
	assert_eq(character.stats.resonance, 0, "New character resonance should be 0")


## ============================================================================
## SECTION 3: Stat Update and Modification
## User Story: "As a player, I want to modify stats through items/perks/level-ups"
## ============================================================================


func test_can_update_hp_regen_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"hp_regen": 5}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.hp_regen, 5, "hp_regen should be updated to 5")


func test_can_update_life_steal_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"life_steal": 0.20}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_almost_eq(character.stats.life_steal, 0.20, 0.01, "life_steal should be updated to 20%")


func test_can_update_attack_speed_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"attack_speed": 0.25}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_almost_eq(
		character.stats.attack_speed, 0.25, 0.01, "attack_speed should be updated to 25%"
	)


func test_can_update_melee_damage_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"melee_damage": 15}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.melee_damage, 15, "melee_damage should be updated to 15")


func test_can_update_ranged_damage_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"ranged_damage": 20}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.ranged_damage, 20, "ranged_damage should be updated to 20")


func test_can_update_scavenging_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"scavenging": 8}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.scavenging, 8, "scavenging should be updated to 8")


func test_can_update_resonance_stat() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act
	CharacterService.update_character(character_id, {"stats": {"resonance": 12}})

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.resonance, 12, "resonance should be updated to 12")


## ============================================================================
## SECTION 4: Level-Up Stat Gains
## User Story: "As a player, when I level up, scavenging should increase"
## ============================================================================


func test_scavenging_in_level_up_gains() -> void:
	# Arrange & Act
	var gains = CharacterService.LEVEL_UP_STAT_GAINS

	# Assert
	assert_true(gains.has("scavenging"), "LEVEL_UP_STAT_GAINS should include scavenging")
	assert_eq(gains.scavenging, 1, "scavenging should gain +1 per level")


func test_scavenging_increases_on_level_up() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")
	var character = CharacterService.get_character(character_id)
	var initial_scavenging = character.stats.scavenging  # Should be 0

	# Act - Add enough XP to level up (100 XP for level 2)
	CharacterService.add_experience(character_id, 100)

	# Assert
	character = CharacterService.get_character(character_id)
	assert_eq(character.level, 2, "Character should be level 2")
	assert_eq(character.stats.scavenging, initial_scavenging + 1, "scavenging should increase by 1")


func test_scavenging_increases_multiple_levels() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestCharacter")

	# Act - Level up 5 times (100 + 200 + 300 + 400 + 500 = 1500 XP)
	CharacterService.add_experience(character_id, 1500)

	# Assert
	var character = CharacterService.get_character(character_id)
	assert_eq(character.level, 6, "Character should be level 6 (1 + 5 levels)")
	assert_eq(
		character.stats.scavenging,
		10,
		"scavenging should be 10 (5 base from scavenger + 5 from levels)"
	)


## ============================================================================
## SECTION 5: SaveManager Integration
## User Story: "As a player, my new stats should persist through saves/loads"
## ============================================================================


func test_new_stats_persist_through_save_load() -> void:
	# Arrange - Create character with modified stats
	var character_id = CharacterService.create_character("TestCharacter")
	CharacterService.update_character(
		character_id,
		{
			"stats":
			{
				"hp_regen": 3,
				"life_steal": 0.15,
				"attack_speed": 0.20,
				"melee_damage": 10,
				"ranged_damage": 8,
				"scavenging": 5,
				"resonance": 7
			}
		}
	)

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert - All new stats should be restored
	var character = CharacterService.get_character(character_id)
	assert_eq(character.stats.hp_regen, 3, "hp_regen should persist")
	assert_almost_eq(character.stats.life_steal, 0.15, 0.01, "life_steal should persist")
	assert_almost_eq(character.stats.attack_speed, 0.20, 0.01, "attack_speed should persist")
	assert_eq(character.stats.melee_damage, 10, "melee_damage should persist")
	assert_eq(character.stats.ranged_damage, 8, "ranged_damage should persist")
	assert_eq(character.stats.scavenging, 5, "scavenging should persist")
	assert_eq(character.stats.resonance, 7, "resonance should persist")
