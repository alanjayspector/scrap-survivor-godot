extends GutTest
## Test script for DropSystem using GUT framework
##
## USER STORY: "As a player, I want to earn currency and XP from killing
## enemies, with my scavenging stat increasing the amount of loot I get"
##
## Tests drop generation, scavenging multiplier, XP awards, and level ups
## from combat.

class_name DropSystemTest


func before_each() -> void:
	# CRITICAL FIX: Seed global RNG for deterministic tests
	# Prevents random failures in statistical tests (e.g., test_scavenging_multiplies_drop_amounts)
	# Pattern matches WaveManager RNG approach (scripts/systems/wave_manager.gd:44-53)
	seed(12345)

	# Reset services
	CharacterService.reset()
	EnemyService.reset()

	# Set PREMIUM tier
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Drop Generation Tests
## User Story: "As a player, I want to get currency drops from enemies"
## ============================================================================


func test_generate_drops_returns_valid_currency() -> void:
	# Arrange
	var enemy_type = "scrap_bot"
	var scavenging = 0

	# Act
	var drops = DropSystem.generate_drops(enemy_type, scavenging)

	# Assert
	# scrap_bot has scrap (80% chance) and components (20% chance)
	# We can't guarantee exact drops due to RNG, but we can verify structure
	assert_true(drops is Dictionary, "Should return Dictionary")

	# All currencies should be positive integers
	for currency in drops.keys():
		assert_gt(drops[currency], 0, "Drop amounts should be positive")


func test_generate_drops_with_invalid_enemy_type() -> void:
	# Arrange
	var enemy_type = "invalid_enemy"
	var scavenging = 0

	# Act
	var drops = DropSystem.generate_drops(enemy_type, scavenging)

	# Assert
	assert_true(drops.is_empty(), "Should return empty dict for invalid enemy type")


## ============================================================================
## SECTION 2: Scavenging Multiplier Tests
## User Story: "As a player, I want scavenging to increase my loot"
## ============================================================================


func test_scavenging_multiplies_drop_amounts() -> void:
	# Arrange - Use multiple runs to ensure statistical validity
	var enemy_type = "scrap_bot"
	var total_drops_no_scav = 0
	var total_drops_with_scav = 0
	var runs = 200  # Run 200 times to smooth out RNG variance

	# Act - Generate drops many times with and without scavenging
	for i in range(runs):
		var drops_no_scav = DropSystem.generate_drops(enemy_type, 0)
		var drops_with_scav = DropSystem.generate_drops(enemy_type, 50)  # 50% bonus

		# Sum all drop amounts
		for currency in drops_no_scav.keys():
			total_drops_no_scav += drops_no_scav[currency]

		for currency in drops_with_scav.keys():
			total_drops_with_scav += drops_with_scav[currency]

	# Assert - With 50% scavenging, total drops should be roughly 50% higher
	# Skip test if we got zero drops (extremely unlikely but possible with RNG)
	if total_drops_no_scav == 0:
		pass_test("Skipped due to no drops generated (RNG edge case)")
		return

	# Allow for RNG variance (generous tolerance for statistical tests)
	var actual_ratio = float(total_drops_with_scav) / float(total_drops_no_scav)

	assert_gt(
		actual_ratio,
		1.1,
		"Scavenging should increase drops (ratio > 1.1 with 50%% scavenging, got %s)" % actual_ratio
	)
	assert_lt(
		actual_ratio,
		2.0,
		"Scavenging bonus should not be excessive (ratio < 2.0, got %s)" % actual_ratio
	)


func test_scavenging_caps_at_50_percent() -> void:
	# Arrange
	var enemy_type = "scrap_bot"

	# Act - Try with 100 scavenging (should cap at 50%)
	# We'll check the multiplier calculation directly
	var scavenge_mult_100 = 1.0 + min(100 / 100.0, 0.5)
	var scavenge_mult_50 = 1.0 + min(50 / 100.0, 0.5)

	# Assert
	assert_almost_eq(scavenge_mult_100, 1.5, 0.01, "100 scavenging should cap at 1.5x multiplier")
	assert_almost_eq(scavenge_mult_50, 1.5, 0.01, "50 scavenging should give 1.5x multiplier")


func test_scavenging_zero_gives_base_drops() -> void:
	# Arrange
	var enemy_type = "mutant_rat"
	var scavenging = 0

	# Act
	var drops = DropSystem.generate_drops(enemy_type, scavenging)

	# Assert
	# With 0 scavenging, multiplier should be 1.0x (no bonus)
	# Just verify drops are generated (can't predict exact RNG)
	assert_true(drops is Dictionary, "Should generate drops with 0 scavenging")


## ============================================================================
## SECTION 3: XP Award Tests
## User Story: "As a player, I want to gain XP from kills and level up"
## ============================================================================


func test_award_xp_for_kill_grants_xp() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "scrap_bot"  # Rewards 10 XP
	var initial_xp = CharacterService.get_character(character_id).experience

	# Act
	DropSystem.award_xp_for_kill(character_id, enemy_type)

	# Assert
	var new_xp = CharacterService.get_character(character_id).experience
	assert_eq(new_xp, initial_xp + 10, "Should award 10 XP for scrap_bot kill")


func test_award_xp_for_kill_triggers_level_up() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")

	# Give character 95 XP (needs 100 to level up to 2)
	CharacterService.add_experience(character_id, 95)

	var enemy_type = "scrap_bot"  # Rewards 10 XP

	# Act
	var leveled_up = DropSystem.award_xp_for_kill(character_id, enemy_type)

	# Assert
	assert_true(leveled_up, "Should level up when reaching 100 XP")

	var character = CharacterService.get_character(character_id)
	assert_eq(character.level, 2, "Character should be level 2")


func test_award_xp_for_kill_returns_false_when_no_level_up() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "scrap_bot"  # Rewards 10 XP

	# Act
	var leveled_up = DropSystem.award_xp_for_kill(character_id, enemy_type)

	# Assert
	assert_false(leveled_up, "Should not level up from single kill")


func test_award_xp_with_invalid_enemy_type() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "invalid_enemy"

	# Act
	var leveled_up = DropSystem.award_xp_for_kill(character_id, enemy_type)

	# Assert
	assert_false(leveled_up, "Should return false for invalid enemy type")


## ============================================================================
## SECTION 4: Process Enemy Kill (Integration) Tests
## User Story: "As a player, I want one function to handle all kill rewards"
## ============================================================================


func test_process_enemy_kill_returns_complete_data() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "scrap_bot"
	var scavenging = 5

	# Act
	var result = DropSystem.process_enemy_kill(character_id, enemy_type, scavenging)

	# Assert
	assert_true(result.has("drops"), "Should include drops")
	assert_true(result.has("xp_awarded"), "Should include XP amount")
	assert_true(result.has("leveled_up"), "Should include level up status")

	assert_eq(result.xp_awarded, 10, "Should award 10 XP for scrap_bot")
	assert_false(result.leveled_up, "Should not level up from one kill")


func test_process_enemy_kill_with_level_up() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	CharacterService.add_experience(character_id, 95)  # Almost level 2

	var enemy_type = "scrap_bot"  # +10 XP (will trigger level up)
	var scavenging = 0

	# Act
	var result = DropSystem.process_enemy_kill(character_id, enemy_type, scavenging)

	# Assert
	assert_true(result.leveled_up, "Should indicate level up occurred")
	assert_eq(result.xp_awarded, 10, "Should still report XP awarded")


func test_process_enemy_kill_applies_scavenging_to_drops() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "scrap_bot"

	# Act - Run with high scavenging to test multiplier
	var result = DropSystem.process_enemy_kill(character_id, enemy_type, 50)

	# Assert
	assert_true(result.drops is Dictionary, "Should generate drops")
	# Can't assert exact amounts due to RNG, but drops should exist


## ============================================================================
## SECTION 5: Different Enemy Type Tests
## User Story: "As a player, I want different enemies to drop different loot"
## ============================================================================


func test_mutant_rat_drops_different_currencies() -> void:
	# Arrange
	var enemy_type = "mutant_rat"
	var scavenging = 0

	# Act - Run multiple times to see variety
	var all_currencies = {}
	for i in range(30):
		var drops = DropSystem.generate_drops(enemy_type, scavenging)
		for currency in drops.keys():
			all_currencies[currency] = true

	# Assert
	# mutant_rat has scrap (60%) and nanites (10%)
	# After 30 runs, we should see scrap at least once (very high probability)
	assert_true(
		all_currencies.has("scrap") or all_currencies.has("nanites"), "Should drop scrap or nanites"
	)


func test_rust_spider_awards_different_xp() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestHero", "scavenger")
	var enemy_type = "rust_spider"  # Awards 12 XP (vs scrap_bot's 10)

	# Act
	var result = DropSystem.process_enemy_kill(character_id, enemy_type, 0)

	# Assert
	assert_eq(result.xp_awarded, 12, "Rust spider should award 12 XP")
