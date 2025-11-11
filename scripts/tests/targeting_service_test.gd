extends GutTest
## Test script for TargetingService using GUT framework
##
## USER STORY: "As a player, I want my weapons to automatically target
## the nearest enemy within range, so that I can focus on movement and
## positioning during combat"
##
## Tests auto-targeting, range filtering, enemy prioritization, and
## dead enemy exclusion.

class_name TargetingServiceTest

var test_enemies: Array[Enemy] = []


func before_each() -> void:
	# Clear any existing test enemies
	_cleanup_test_enemies()
	test_enemies.clear()


func after_each() -> void:
	# Cleanup test enemies
	_cleanup_test_enemies()
	test_enemies.clear()


func _cleanup_test_enemies() -> void:
	"""Remove all test enemies from scene"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy:
			enemy.queue_free()


func _create_test_enemy(position: Vector2, id: String, is_alive: bool = true) -> Enemy:
	"""Create a test enemy at specified position"""
	var enemy_scene = load("res://scenes/entities/enemy.tscn")
	var enemy = enemy_scene.instantiate()

	# Add to scene tree first so it can be found by group
	add_child_autofree(enemy)

	# Setup enemy
	enemy.setup(id, "scrap_bot", 1)
	enemy.global_position = position

	# Set dead if needed
	if not is_alive:
		enemy.current_hp = 0

	test_enemies.append(enemy)

	# Wait for enemy to be fully added to scene tree
	await get_tree().process_frame

	return enemy


## ============================================================================
## SECTION 1: Basic Targeting Tests
## User Story: "As a player, I want to find the nearest enemy"
## ============================================================================


func test_get_nearest_enemy_returns_closest() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var enemy1 = await _create_test_enemy(Vector2(100, 0), "enemy1")
	var enemy2 = await _create_test_enemy(Vector2(200, 0), "enemy2")
	var enemy3 = await _create_test_enemy(Vector2(50, 0), "enemy3")

	# Act
	var nearest = TargetingService.get_nearest_enemy(player_pos, 500.0)

	# Assert
	assert_not_null(nearest, "Should find nearest enemy")
	assert_eq(nearest.enemy_id, "enemy3", "Should return closest enemy (50 pixels away)")


func test_get_nearest_enemy_excludes_dead_enemies() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var dead_enemy = await _create_test_enemy(Vector2(50, 0), "dead", false)
	var alive_enemy = await _create_test_enemy(Vector2(100, 0), "alive", true)

	# Act
	var nearest = TargetingService.get_nearest_enemy(player_pos, 500.0)

	# Assert
	assert_not_null(nearest, "Should find alive enemy")
	assert_eq(nearest.enemy_id, "alive", "Should skip dead enemy and return alive one")


func test_get_nearest_enemy_filters_by_range() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var close_enemy = await _create_test_enemy(Vector2(100, 0), "close")
	var far_enemy = await _create_test_enemy(Vector2(600, 0), "far")

	# Act - use 200px range
	var nearest = TargetingService.get_nearest_enemy(player_pos, 200.0)

	# Assert
	assert_not_null(nearest, "Should find enemy within range")
	assert_eq(nearest.enemy_id, "close", "Should return enemy within 200px range")


func test_get_nearest_enemy_returns_null_when_none_in_range() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var far_enemy = await _create_test_enemy(Vector2(1000, 0), "far")

	# Act - use 100px range
	var nearest = TargetingService.get_nearest_enemy(player_pos, 100.0)

	# Assert
	assert_null(nearest, "Should return null when no enemies within range")


func test_get_nearest_enemy_returns_null_when_no_enemies_exist() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	# No enemies created

	# Act
	var nearest = TargetingService.get_nearest_enemy(player_pos, 500.0)

	# Assert
	assert_null(nearest, "Should return null when no enemies exist")


## ============================================================================
## SECTION 2: Area Targeting Tests
## User Story: "As a player with area weapons, I want to hit all enemies in radius"
## ============================================================================


func test_get_enemies_in_radius_returns_all_in_range() -> void:
	# Arrange
	var center_pos = Vector2(0, 0)
	var enemy1 = await _create_test_enemy(Vector2(50, 0), "enemy1")
	var enemy2 = await _create_test_enemy(Vector2(75, 75), "enemy2")
	var enemy3 = await _create_test_enemy(Vector2(200, 0), "enemy3")

	# Act - 150px radius
	var enemies = TargetingService.get_enemies_in_radius(center_pos, 150.0)

	# Assert
	assert_eq(enemies.size(), 2, "Should find 2 enemies within 150px radius")
	# Note: enemy3 at 200px is outside range


func test_get_enemies_in_radius_excludes_dead_enemies() -> void:
	# Arrange
	var center_pos = Vector2(0, 0)
	var alive_enemy = await _create_test_enemy(Vector2(50, 0), "alive", true)
	var dead_enemy = await _create_test_enemy(Vector2(75, 0), "dead", false)

	# Act
	var enemies = TargetingService.get_enemies_in_radius(center_pos, 150.0)

	# Assert
	assert_eq(enemies.size(), 1, "Should find only alive enemy")
	assert_eq(enemies[0].enemy_id, "alive", "Should exclude dead enemy")


func test_get_enemies_in_radius_returns_empty_when_none_in_range() -> void:
	# Arrange
	var center_pos = Vector2(0, 0)
	var far_enemy = await _create_test_enemy(Vector2(500, 0), "far")

	# Act - 100px radius
	var enemies = TargetingService.get_enemies_in_radius(center_pos, 100.0)

	# Assert
	assert_eq(enemies.size(), 0, "Should return empty array when no enemies in range")


## ============================================================================
## SECTION 3: Utility Functions Tests
## User Story: "As a developer, I need utility functions for enemy queries"
## ============================================================================


func test_get_all_enemies_returns_all_living_enemies() -> void:
	# Arrange
	var enemy1 = await _create_test_enemy(Vector2(100, 0), "enemy1", true)
	var enemy2 = await _create_test_enemy(Vector2(200, 0), "enemy2", true)
	var dead_enemy = await _create_test_enemy(Vector2(300, 0), "dead", false)

	# Act
	var enemies = TargetingService.get_all_enemies()

	# Assert
	assert_eq(enemies.size(), 2, "Should return only living enemies")


func test_get_enemy_count_returns_correct_count() -> void:
	# Arrange
	var enemy1 = await _create_test_enemy(Vector2(100, 0), "enemy1")
	var enemy2 = await _create_test_enemy(Vector2(200, 0), "enemy2")
	var enemy3 = await _create_test_enemy(Vector2(300, 0), "enemy3")

	# Act
	var count = TargetingService.get_enemy_count()

	# Assert
	assert_eq(count, 3, "Should return correct count of living enemies")


func test_has_enemies_in_range_returns_true_when_enemy_in_range() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var close_enemy = await _create_test_enemy(Vector2(100, 0), "close")

	# Act
	var has_enemies = TargetingService.has_enemies_in_range(player_pos, 200.0)

	# Assert
	assert_true(has_enemies, "Should return true when enemy within range")


func test_has_enemies_in_range_returns_false_when_no_enemy_in_range() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var far_enemy = await _create_test_enemy(Vector2(500, 0), "far")

	# Act
	var has_enemies = TargetingService.has_enemies_in_range(player_pos, 100.0)

	# Assert
	assert_false(has_enemies, "Should return false when no enemies within range")


## ============================================================================
## SECTION 4: Range Validation Tests
## User Story: "As a player, different weapons should have different ranges"
## ============================================================================


func test_plasma_pistol_range_targets_enemies_within_500px() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var close_enemy = await _create_test_enemy(Vector2(400, 0), "close")
	var far_enemy = await _create_test_enemy(Vector2(600, 0), "far")

	# Act - plasma pistol range (500px)
	var target = TargetingService.get_nearest_enemy(player_pos, 500.0)

	# Assert
	assert_not_null(target, "Should find enemy within 500px")
	assert_eq(target.enemy_id, "close", "Should target enemy at 400px, not 600px")


func test_melee_weapon_range_only_targets_very_close_enemies() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var very_close_enemy = await _create_test_enemy(Vector2(40, 0), "very_close")
	var medium_distance_enemy = await _create_test_enemy(Vector2(100, 0), "medium")

	# Act - melee range (50px)
	var target = TargetingService.get_nearest_enemy(player_pos, 50.0)

	# Assert
	assert_not_null(target, "Should find enemy within melee range")
	assert_eq(target.enemy_id, "very_close", "Should only target enemy within 50px")


func test_long_range_weapon_targets_distant_enemies() -> void:
	# Arrange
	var player_pos = Vector2(0, 0)
	var close_enemy = await _create_test_enemy(Vector2(200, 0), "close")
	var far_enemy = await _create_test_enemy(Vector2(700, 0), "far")

	# Act - long range weapon (800px)
	var target = TargetingService.get_nearest_enemy(player_pos, 800.0)

	# Assert
	assert_not_null(target, "Should find enemy within long range")
	assert_eq(target.enemy_id, "close", "Should target nearest enemy (200px)")
