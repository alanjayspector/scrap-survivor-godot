extends GutTest
## Test script to verify enemy resources load correctly using GUT framework
##
## Tests loading, wave scaling, spawn weights, and drop chances.

class_name EnemyLoadingTest

# gdlint: disable=duplicated-load

# Preload the EnemyResource script to ensure class is registered in headless mode
const _ENEMY_RESOURCE_SCRIPT = preload("res://scripts/resources/enemy_resource.gd")

## RESOURCE TESTS TOGGLE
## Set to true to enable enemy resource tests when running in Godot Editor GUI
## These tests fail in headless CI due to Godot limitation with custom Resource loading
## See docs/godot-headless-resource-loading-guide.md for technical details
##
## To run tests in Godot Editor:
## 1. Change ENABLE_RESOURCE_TESTS to true
## 2. Open project in Godot Editor GUI
## 3. Run tests from GUT panel (bottom panel)
const ENABLE_RESOURCE_TESTS = false


func before_each() -> void:
	# Setup before each test
	pass


func after_each() -> void:
	# Cleanup
	pass


# Resource Loading Tests
func test_basic_enemy_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	assert_not_null(enemy, "Basic enemy resource should load")


func test_fast_enemy_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/fast.tres")
	assert_not_null(enemy, "Fast enemy resource should load")


func test_tank_enemy_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/tank.tres")
	assert_not_null(enemy, "Tank enemy resource should load")


func test_basic_enemy_has_valid_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	assert_gt(enemy.base_hp, 0, "Basic enemy should have positive HP")
	assert_gt(enemy.base_speed, 0, "Basic enemy should have positive speed")
	assert_gt(enemy.base_damage, 0, "Basic enemy should have positive damage")
	assert_gt(enemy.spawn_weight, 0, "Basic enemy should have positive spawn weight")


func test_fast_enemy_has_valid_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/fast.tres")
	assert_gt(enemy.base_hp, 0, "Fast enemy should have positive HP")
	assert_gt(enemy.base_speed, 0, "Fast enemy should have positive speed")
	assert_gt(enemy.base_damage, 0, "Fast enemy should have positive damage")
	assert_gt(enemy.spawn_weight, 0, "Fast enemy should have positive spawn weight")


func test_tank_enemy_has_valid_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/tank.tres")
	assert_gt(enemy.base_hp, 0, "Tank enemy should have positive HP")
	assert_gt(enemy.base_speed, 0, "Tank enemy should have positive speed")
	assert_gt(enemy.base_damage, 0, "Tank enemy should have positive damage")
	assert_gt(enemy.spawn_weight, 0, "Tank enemy should have positive spawn weight")


# Wave Scaling Tests
func test_wave_1_stats_equal_base_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var stats = enemy.get_scaled_stats(1)

	assert_eq(stats.hp, enemy.base_hp, "Wave 1 HP should equal base HP")
	assert_eq(stats.speed, enemy.base_speed, "Wave 1 speed should equal base speed")
	assert_eq(stats.damage, enemy.base_damage, "Wave 1 damage should equal base damage")
	assert_eq(stats.value, enemy.base_value, "Wave 1 value should equal base value")


func test_wave_5_hp_scales_correctly() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var stats = enemy.get_scaled_stats(5)
	var expected_hp = int(enemy.base_hp * (1.0 + (5 - 1) * 0.25))

	assert_eq(stats.hp, expected_hp, "Wave 5 HP should match formula: base * (1 + (wave-1) * 0.25)")


func test_wave_5_speed_scales_correctly() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var stats = enemy.get_scaled_stats(5)
	var expected_speed = int(enemy.base_speed * (1.0 + (5 - 1) * 0.05))

	assert_eq(
		stats.speed,
		expected_speed,
		"Wave 5 speed should match formula: base * (1 + (wave-1) * 0.05)"
	)


func test_wave_5_damage_scales_correctly() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var stats = enemy.get_scaled_stats(5)
	var expected_damage = int(enemy.base_damage * (1.0 + (5 - 1) * 0.10))

	assert_eq(
		stats.damage,
		expected_damage,
		"Wave 5 damage should match formula: base * (1 + (wave-1) * 0.10)"
	)


func test_wave_5_value_scales_correctly() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var stats = enemy.get_scaled_stats(5)
	var expected_value = int(enemy.base_value * (1.0 + (5 - 1) * 0.20))

	assert_eq(
		stats.value,
		expected_value,
		"Wave 5 value should match formula: base * (1 + (wave-1) * 0.20)"
	)


func test_wave_10_hp_greater_than_wave_1() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var wave1_stats = enemy.get_scaled_stats(1)
	var wave10_stats = enemy.get_scaled_stats(10)

	assert_gt(wave10_stats.hp, wave1_stats.hp, "Wave 10 HP should be greater than wave 1 HP")


func test_wave_20_hp_greater_than_wave_10() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var wave10_stats = enemy.get_scaled_stats(10)
	var wave20_stats = enemy.get_scaled_stats(20)

	assert_gt(wave20_stats.hp, wave10_stats.hp, "Wave 20 HP should be greater than wave 10 HP")


# Spawn Weight Tests
func test_spawn_weights_sum_to_100() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var basic: EnemyResource = load("res://resources/enemies/basic.tres")
	var fast: EnemyResource = load("res://resources/enemies/fast.tres")
	var tank: EnemyResource = load("res://resources/enemies/tank.tres")
	var total_weight = basic.spawn_weight + fast.spawn_weight + tank.spawn_weight

	assert_eq(total_weight, 100, "Spawn weights should sum to 100")


func test_basic_enemy_spawn_percentage() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var percentage = enemy.get_spawn_percentage()

	assert_gte(percentage, 0, "Spawn percentage should be >= 0")
	assert_lte(percentage, 100, "Spawn percentage should be <= 100")


func test_fast_enemy_spawn_percentage() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/fast.tres")
	var percentage = enemy.get_spawn_percentage()

	assert_gte(percentage, 0, "Spawn percentage should be >= 0")
	assert_lte(percentage, 100, "Spawn percentage should be <= 100")


func test_tank_enemy_spawn_percentage() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/tank.tres")
	var percentage = enemy.get_spawn_percentage()

	assert_gte(percentage, 0, "Spawn percentage should be >= 0")
	assert_lte(percentage, 100, "Spawn percentage should be <= 100")


# Drop Chance Tests
func test_basic_enemy_has_drop_chance() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	assert_gte(enemy.drop_chance, 0.0, "Drop chance should be >= 0")
	assert_lte(enemy.drop_chance, 1.0, "Drop chance should be <= 1")


func test_fast_enemy_has_drop_chance() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/fast.tres")
	assert_gte(enemy.drop_chance, 0.0, "Drop chance should be >= 0")
	assert_lte(enemy.drop_chance, 1.0, "Drop chance should be <= 1")


func test_tank_enemy_has_drop_chance() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/tank.tres")
	assert_gte(enemy.drop_chance, 0.0, "Drop chance should be >= 0")
	assert_lte(enemy.drop_chance, 1.0, "Drop chance should be <= 1")


func test_should_drop_item_is_probabilistic_basic() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/basic.tres")
	var drop_count = 0
	var trials = 1000

	for i in range(trials):
		if enemy.should_drop_item():
			drop_count += 1

	var actual_rate = float(drop_count) / float(trials)
	var expected_rate = enemy.drop_chance
	var diff = abs(actual_rate - expected_rate)

	# Allow 10% margin of error for probabilistic test
	assert_lt(
		diff,
		0.1,
		(
			"Drop rate should be within 10%% of expected (got %.1f%%, expected %.1f%%)"
			% [actual_rate * 100, expected_rate * 100]
		)
	)


func test_should_drop_item_is_probabilistic_fast() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/fast.tres")
	var drop_count = 0
	var trials = 1000

	for i in range(trials):
		if enemy.should_drop_item():
			drop_count += 1

	var actual_rate = float(drop_count) / float(trials)
	var expected_rate = enemy.drop_chance
	var diff = abs(actual_rate - expected_rate)

	# Allow 10% margin of error for probabilistic test
	assert_lt(
		diff,
		0.1,
		(
			"Drop rate should be within 10%% of expected (got %.1f%%, expected %.1f%%)"
			% [actual_rate * 100, expected_rate * 100]
		)
	)


func test_should_drop_item_is_probabilistic_tank() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy: EnemyResource = load("res://resources/enemies/tank.tres")
	var drop_count = 0
	var trials = 1000

	for i in range(trials):
		if enemy.should_drop_item():
			drop_count += 1

	var actual_rate = float(drop_count) / float(trials)
	var expected_rate = enemy.drop_chance
	var diff = abs(actual_rate - expected_rate)

	# Allow 10% margin of error for probabilistic test
	assert_lt(
		diff,
		0.1,
		(
			"Drop rate should be within 10%% of expected (got %.1f%%, expected %.1f%%)"
			% [actual_rate * 100, expected_rate * 100]
		)
	)
