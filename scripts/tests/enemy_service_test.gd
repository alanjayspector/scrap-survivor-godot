extends GutTest
## Test script for EnemyService using GUT framework
##
## USER STORY: "As a player, I want to fight increasingly difficult waves
## of enemies that scale in HP and numbers, so that the game remains
## challenging as I progress"
##
## Tests enemy spawning, damage, death, wave scaling, AI, and drop table
## generation.

class_name EnemyServiceTest


func before_each() -> void:
	# Reset service state before each test
	EnemyService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Enemy Type Tests
## User Story: "As a player, I want to encounter different enemy types"
## ============================================================================


func test_enemy_type_exists_returns_true_for_valid_type() -> void:
	# Arrange & Act
	var exists = EnemyService.enemy_type_exists("scrap_bot")

	# Assert
	assert_true(exists, "scrap_bot should exist")


func test_enemy_type_exists_returns_false_for_invalid_type() -> void:
	# Arrange & Act
	var exists = EnemyService.enemy_type_exists("invalid_enemy")

	# Assert
	assert_false(exists, "Invalid enemy type should return false")


func test_get_enemy_type_returns_valid_data() -> void:
	# Arrange & Act
	var enemy_type = EnemyService.get_enemy_type("mutant_rat")

	# Assert
	assert_eq(enemy_type.display_name, "Mutant Rat", "Should return correct display name")
	assert_eq(enemy_type.base_hp, 30, "Should have base HP 30")
	assert_eq(enemy_type.base_damage, 8, "Should have base damage 8")
	assert_eq(enemy_type.speed, 120, "Should have speed 120")
	assert_eq(enemy_type.xp_reward, 8, "Should reward 8 XP")


func test_get_enemy_type_returns_empty_for_invalid_type() -> void:
	# Arrange & Act
	var enemy_type = EnemyService.get_enemy_type("invalid_enemy")

	# Assert
	assert_true(enemy_type.is_empty(), "Should return empty dictionary for invalid type")


## ============================================================================
## SECTION 2: Enemy Spawning Tests
## User Story: "As a player, I want enemies to spawn during waves"
## ============================================================================


func test_spawn_enemy_returns_valid_id() -> void:
	# Arrange
	var enemy_type = "scrap_bot"
	var position = Vector2(100, 200)

	# Act
	var enemy_id = EnemyService.spawn_enemy(enemy_type, position)

	# Assert
	assert_ne(enemy_id, "", "Should return non-empty enemy ID")
	assert_true(enemy_id.begins_with("enemy_"), "Enemy ID should start with 'enemy_'")


func test_spawn_enemy_creates_valid_enemy() -> void:
	# Arrange
	var enemy_type = "scrap_bot"
	var position = Vector2(100, 200)

	# Act
	var enemy_id = EnemyService.spawn_enemy(enemy_type, position)
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	assert_eq(enemy.type, enemy_type, "Enemy should have correct type")
	assert_eq(enemy.position, position, "Enemy should have correct position")
	assert_almost_eq(enemy.max_hp, 50.0, 0.01, "Enemy should have 50 max HP")
	assert_almost_eq(enemy.current_hp, 50.0, 0.01, "Enemy should start at full HP")
	assert_eq(enemy.damage, 5, "Enemy should have 5 damage")
	assert_eq(enemy.speed, 80, "Enemy should have 80 speed")
	assert_true(enemy.alive, "Enemy should be alive")


func test_spawn_enemy_with_invalid_type_fails() -> void:
	# Arrange
	var enemy_type = "invalid_enemy"
	var position = Vector2(100, 200)

	# Act
	var enemy_id = EnemyService.spawn_enemy(enemy_type, position)

	# Assert
	assert_eq(enemy_id, "", "Should return empty string for invalid type")


func test_spawn_enemy_increments_id() -> void:
	# Arrange & Act
	var enemy1_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	var enemy2_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)

	# Assert
	assert_ne(enemy1_id, enemy2_id, "Each enemy should have unique ID")


## ============================================================================
## SECTION 3: Enemy Damage and Death Tests
## User Story: "As a player, I want to damage and kill enemies"
## ============================================================================


func test_damage_enemy_reduces_hp() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	var initial_hp = EnemyService.get_enemy(enemy_id).current_hp

	# Act
	var killed = EnemyService.damage_enemy(enemy_id, 20.0)
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	assert_false(killed, "Enemy should not be killed yet")
	assert_almost_eq(enemy.current_hp, initial_hp - 20.0, 0.01, "HP should be reduced by 20")
	assert_true(enemy.alive, "Enemy should still be alive")


func test_damage_enemy_returns_true_when_killed() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)

	# Act
	var killed = EnemyService.damage_enemy(enemy_id, 100.0)  # More than max HP
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	assert_true(killed, "Enemy should be killed")
	assert_almost_eq(enemy.current_hp, 0.0, 0.01, "HP should be 0")
	assert_false(enemy.alive, "Enemy should not be alive")


func test_damage_enemy_caps_hp_at_zero() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)

	# Act
	EnemyService.damage_enemy(enemy_id, 200.0)  # Massive overkill
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	assert_almost_eq(enemy.current_hp, 0.0, 0.01, "HP should not go negative")


func test_damage_enemy_with_invalid_id_returns_false() -> void:
	# Arrange & Act
	var killed = EnemyService.damage_enemy("invalid_enemy", 10.0)

	# Assert
	assert_false(killed, "Should return false for invalid enemy ID")


func test_damage_dead_enemy_fails() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	EnemyService.damage_enemy(enemy_id, 100.0)  # Kill it

	# Act
	var killed = EnemyService.damage_enemy(enemy_id, 10.0)  # Try to damage again

	# Assert
	assert_false(killed, "Should fail to damage dead enemy")


func test_kill_enemy_returns_drop_data() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2(50, 75))

	# Act
	var drop_data = EnemyService.kill_enemy(enemy_id)

	# Assert
	assert_eq(drop_data.enemy_id, enemy_id, "Should return enemy ID")
	assert_eq(drop_data.enemy_type, "scrap_bot", "Should return enemy type")
	assert_eq(drop_data.position, Vector2(50, 75), "Should return position")
	assert_eq(drop_data.xp_reward, 10, "Should return XP reward")
	assert_true(drop_data.has("drop_table"), "Should include drop table")


## ============================================================================
## SECTION 4: Enemy Tracking Tests
## User Story: "As a player, I want the game to track active enemies"
## ============================================================================


func test_get_living_enemies_returns_all_alive() -> void:
	# Arrange
	var enemy1 = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	var enemy2 = EnemyService.spawn_enemy("mutant_rat", Vector2.ZERO)

	# Act
	var living = EnemyService.get_living_enemies()

	# Assert
	assert_eq(living.size(), 2, "Should return 2 living enemies")
	assert_true(living.has(enemy1), "Should include enemy1")
	assert_true(living.has(enemy2), "Should include enemy2")


func test_get_living_enemies_excludes_dead() -> void:
	# Arrange
	var enemy1 = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	var enemy2 = EnemyService.spawn_enemy("mutant_rat", Vector2.ZERO)
	EnemyService.damage_enemy(enemy1, 100.0)  # Kill enemy1

	# Act
	var living = EnemyService.get_living_enemies()

	# Assert
	assert_eq(living.size(), 1, "Should return 1 living enemy")
	assert_false(living.has(enemy1), "Should not include dead enemy1")
	assert_true(living.has(enemy2), "Should include alive enemy2")


func test_get_enemy_count() -> void:
	# Arrange
	EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	EnemyService.spawn_enemy("mutant_rat", Vector2.ZERO)
	EnemyService.spawn_enemy("rust_spider", Vector2.ZERO)

	# Act
	var count = EnemyService.get_enemy_count()

	# Assert
	assert_eq(count, 3, "Should return 3 enemies")


func test_remove_enemy() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)

	# Act
	EnemyService.remove_enemy(enemy_id)
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	assert_true(enemy.is_empty(), "Enemy should be removed")


## ============================================================================
## SECTION 5: Wave Scaling Tests
## User Story: "As a player, I want waves to get progressively harder"
## ============================================================================


func test_wave_scaling_increases_enemy_count() -> void:
	# Arrange & Act
	var wave1_count = EnemyService.get_enemy_count_for_wave(1)
	var wave2_count = EnemyService.get_enemy_count_for_wave(2)
	var wave5_count = EnemyService.get_enemy_count_for_wave(5)

	# Assert
	assert_eq(wave1_count, 8, "Wave 1 should have 8 enemies (5 + 3)")
	assert_eq(wave2_count, 11, "Wave 2 should have 11 enemies (5 + 6)")
	assert_eq(wave5_count, 20, "Wave 5 should have 20 enemies (5 + 15)")


func test_wave_scaling_increases_enemy_hp() -> void:
	# Arrange & Act
	var wave1_mult = EnemyService.get_enemy_hp_multiplier(1)
	var wave2_mult = EnemyService.get_enemy_hp_multiplier(2)
	var wave5_mult = EnemyService.get_enemy_hp_multiplier(5)

	# Assert
	assert_almost_eq(wave1_mult, 1.0, 0.01, "Wave 1 should have 1.0x HP multiplier")
	assert_almost_eq(wave2_mult, 1.15, 0.01, "Wave 2 should have 1.15x HP multiplier")
	assert_almost_eq(wave5_mult, 1.60, 0.01, "Wave 5 should have 1.60x HP multiplier")


func test_spawn_enemy_applies_wave_scaling() -> void:
	# Arrange & Act
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO, 3)  # Wave 3
	var enemy = EnemyService.get_enemy(enemy_id)

	# Assert
	# Base HP: 50, Wave 3 multiplier: 1.0 + (2 * 0.15) = 1.30
	# 50 * 1.30 = 65
	assert_almost_eq(enemy.max_hp, 65.0, 0.01, "Wave 3 enemy should have 1.30x HP")


func test_get_spawn_rate_decreases_with_wave() -> void:
	# Arrange & Act
	var wave1_rate = EnemyService.get_spawn_rate(1)
	var wave5_rate = EnemyService.get_spawn_rate(5)
	var wave20_rate = EnemyService.get_spawn_rate(20)

	# Assert
	assert_almost_eq(wave1_rate, 2.0, 0.01, "Wave 1 should spawn every 2.0s")
	assert_almost_eq(wave5_rate, 1.6, 0.01, "Wave 5 should spawn every 1.6s")
	assert_almost_eq(wave20_rate, 0.5, 0.01, "Wave 20 should cap at 0.5s (minimum)")


## ============================================================================
## SECTION 6: Enemy AI Tests
## User Story: "As a player, I want enemies to chase me"
## ============================================================================


func test_update_enemy_ai_moves_toward_player() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2(0, 0))
	EnemyService.set_player_position(Vector2(100, 0))
	var initial_position = EnemyService.get_enemy(enemy_id).position

	# Act
	EnemyService.update_enemy_ai(enemy_id, 1.0)  # 1 second
	var new_position = EnemyService.get_enemy(enemy_id).position

	# Assert
	# Speed is 80, so in 1 second should move 80 pixels toward player
	assert_gt(new_position.x, initial_position.x, "Enemy should move toward player (right)")
	assert_almost_eq(new_position.x, 80.0, 1.0, "Enemy should move ~80 pixels in 1 second")


func test_get_enemies_in_radius() -> void:
	# Arrange
	var enemy1 = EnemyService.spawn_enemy("scrap_bot", Vector2(50, 0))
	var enemy2 = EnemyService.spawn_enemy("mutant_rat", Vector2(150, 0))
	var enemy3 = EnemyService.spawn_enemy("rust_spider", Vector2(300, 0))

	# Act
	var in_radius = EnemyService.get_enemies_in_radius(Vector2(0, 0), 100.0)

	# Assert
	assert_eq(in_radius.size(), 1, "Should find 1 enemy within 100 radius")
	assert_true(in_radius.has(enemy1), "Should include enemy at 50 distance")
	assert_false(in_radius.has(enemy2), "Should not include enemy at 150 distance")


func test_get_enemies_in_radius_excludes_dead() -> void:
	# Arrange
	var enemy1 = EnemyService.spawn_enemy("scrap_bot", Vector2(50, 0))
	var enemy2 = EnemyService.spawn_enemy("mutant_rat", Vector2(60, 0))
	EnemyService.damage_enemy(enemy1, 100.0)  # Kill enemy1

	# Act
	var in_radius = EnemyService.get_enemies_in_radius(Vector2(0, 0), 100.0)

	# Assert
	assert_eq(in_radius.size(), 1, "Should only find living enemies")
	assert_false(in_radius.has(enemy1), "Should not include dead enemy")
	assert_true(in_radius.has(enemy2), "Should include alive enemy")
