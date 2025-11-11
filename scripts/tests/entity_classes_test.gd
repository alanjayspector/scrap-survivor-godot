extends GutTest
## Test script for entity classes (Player, Enemy, Projectile) using GUT framework
##
## USER STORY: "As a developer, I want entity data structures"
##
## Tests entity initialization, stats, combat mechanics, and resource integration.
## Updated for Week 10: Player now integrates with CharacterService

class_name EntityClassesTest

# gdlint: disable=duplicated-load

# Preload resource scripts to ensure classes are registered in headless mode
const _WEAPON_RESOURCE_SCRIPT = preload("res://scripts/resources/weapon_resource.gd")
const _ENEMY_RESOURCE_SCRIPT = preload("res://scripts/resources/enemy_resource.gd")
const _ITEM_RESOURCE_SCRIPT = preload("res://scripts/resources/item_resource.gd")

## RESOURCE TESTS TOGGLE
## Set to true to enable resource tests when running in Godot Editor GUI
## These tests fail in headless CI due to Godot limitation with custom Resource loading
## See docs/godot-headless-resource-loading-guide.md for technical details
##
## To run tests in Godot Editor:
## 1. Change ENABLE_RESOURCE_TESTS to true
## 2. Open project in Godot Editor GUI
## 3. Run tests from GUT panel (bottom panel)
const ENABLE_RESOURCE_TESTS = false

var test_character_id: String = ""


func before_each() -> void:
	# Create test character for Player tests (returns generated ID)
	test_character_id = CharacterService.create_character("TestChar", "scavenger")
	CharacterService.set_active_character(test_character_id)


func after_each() -> void:
	# Cleanup test character
	CharacterService.delete_character(test_character_id)


# Player Entity Tests (Updated for CharacterService integration)
func test_player_initial_max_health_is_100() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)  # Wait for stats to load

	assert_eq(player.stats.get("max_hp", 0), 100, "Player should start with 100 max health")


func test_player_initial_current_health_is_100() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	assert_eq(player.current_hp, 100.0, "Player should start at full health")


func test_player_base_speed_is_200() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	assert_eq(player.stats.get("speed", 0), 200, "Player should have 200 base speed")


func test_player_takes_damage_correctly() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	player.take_damage(30.0)

	assert_almost_eq(player.current_hp, 70.0, 1.0, "Player should have ~70 health after 30 damage")


func test_player_heals_correctly() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	player.take_damage(30.0)
	player.heal(20.0)

	assert_almost_eq(player.current_hp, 90.0, 1.0, "Player should have ~90 health after healing")


func test_player_applies_health_item_modifiers() -> void:
	pending("Disabled - CharacterService handles stat modifiers, not Player directly")


func test_player_applies_speed_item_modifiers() -> void:
	pending("Disabled - CharacterService handles stat modifiers, not Player directly")


func test_player_equips_weapon() -> void:
	pending("Disabled - WeaponService integration tested in scene_integration_test.gd")


func test_player_invulnerability_blocks_damage() -> void:
	pending("Disabled - Week 10 Player doesn't have invulnerability (simplified)")


# Enemy Entity Tests
func test_enemy_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	assert_not_null(enemy_resource, "Enemy resource should load")


func test_enemy_initializes_with_wave_1() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)

	assert_eq(enemy.current_wave, 1, "Enemy should be on wave 1")


func test_enemy_scales_health_with_wave() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 5)

	var scaled_stats = enemy_resource.get_scaled_stats(5)
	assert_eq(enemy.max_health, scaled_stats.hp, "Enemy HP should scale with wave")


func test_enemy_takes_damage() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)

	var initial_hp = enemy.current_health
	enemy.take_damage(10.0)

	assert_eq(enemy.current_health, initial_hp - 10.0, "Enemy should take 10 damage")


func test_enemy_health_percentage_calculation() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)

	enemy.current_health = enemy.max_health / 2.0
	assert_almost_eq(enemy.get_health_percentage(), 0.5, 0.01, "Half health = 50%")


func test_enemy_is_alive_when_health_positive() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)

	assert_true(enemy.is_alive(), "Enemy with positive health should be alive")


func test_enemy_is_dead_when_health_zero() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)

	enemy.current_health = 0
	assert_false(enemy.is_alive(), "Enemy with zero health should be dead")


# Projectile Entity Tests
func test_projectile_activates_with_parameters() -> void:
	pending("Disabled - Projectile implementation pending Week 10 Phase 2")


func test_projectile_velocity_is_set() -> void:
	pending("Disabled - Projectile implementation pending Week 10 Phase 2")


func test_projectile_pierce_is_set() -> void:
	pending("Disabled - Projectile implementation pending Week 10 Phase 2")


func test_projectile_remaining_range_is_full() -> void:
	pending("Disabled - Projectile implementation pending Week 10 Phase 2")


func test_projectile_deactivates() -> void:
	pending("Disabled - Projectile implementation pending Week 10 Phase 2")


# Integration Tests (Basic)
func test_enemy_targets_player() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	enemy.initialize(enemy_resource, 1)
	enemy.set_target(player)

	assert_eq(enemy.target, player, "Enemy should target player")


func test_player_fires_weapon() -> void:
	pending("Disabled - Weapon firing tested in scene_integration_test.gd")


func test_enemy_calculates_distance_to_player() -> void:
	pending("Disabled - AI tested in scene_integration_test.gd")


func test_player_armor_reduces_damage() -> void:
	var player = autofree(Player.new())
	player.character_id = test_character_id
	add_child(player)
	await wait_frames(2)

	# Give player some armor through stats
	player.stats["armor"] = 10

	player.take_damage(100.0)

	# With 10 armor, damage should be reduced
	# Formula: armor_multiplier = 1.0 / (1.0 + armor * 0.01)
	# With 10 armor: 1.0 / 1.1 = 0.909, so 100 * 0.909 = ~90.9 damage taken
	assert_lt(player.current_hp, 10.0, "Player with armor should take less than 100 damage")
	assert_gt(player.current_hp, 0.0, "Player should have some HP remaining")


func test_player_life_steal_modifier() -> void:
	pending("Disabled - Life steal not yet implemented in Week 10")


# Resource Loading Tests
func test_weapon_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var weapon = load("res://resources/weapons/rusty_pistol.tres")
	assert_not_null(weapon, "Weapon resource should load")


func test_enemy_resource_basic_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource = load("res://resources/enemies/scrap_bot.tres")
	assert_not_null(enemy_resource, "Enemy resource should load")


func test_health_boost_item_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost = load("res://resources/items/health_boost.tres")
	assert_not_null(health_boost, "Health boost item should load")


func test_vampiric_fangs_item_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var vampiric_fangs = load("res://resources/items/vampiric_fangs.tres")
	assert_not_null(vampiric_fangs, "Vampiric fangs item should load")
