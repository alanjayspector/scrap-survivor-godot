extends GutTest
## Test script for entity classes (Player, Enemy, Projectile) using GUT framework
##
## USER STORY: "As a developer, I want entity data structures"
##
## Tests entity initialization, stats, combat mechanics, and resource integration.

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
const ENABLE_RESOURCE_TESTS = true


func before_each() -> void:
	# Setup before each test
	pass


func after_each() -> void:
	# Cleanup after each test
	pass


# Player Entity Tests
func test_player_initial_max_health_is_100() -> void:
	var player = autofree(Player.new())
	add_child(player)

	assert_eq(player.max_health, 100.0, "Player should start with 100 max health")


func test_player_initial_current_health_is_100() -> void:
	var player = autofree(Player.new())
	add_child(player)

	assert_eq(player.current_health, 100.0, "Player should start at full health")


func test_player_base_speed_is_200() -> void:
	var player = autofree(Player.new())
	add_child(player)

	assert_eq(player.base_speed, 200.0, "Player should have 200 base speed")


func test_player_takes_damage_correctly() -> void:
	var player = autofree(Player.new())
	add_child(player)

	player.take_damage(30.0)

	assert_eq(player.current_health, 70.0, "Player should have 70 health after 30 damage")


func test_player_heals_correctly() -> void:
	var player = autofree(Player.new())
	add_child(player)

	player.take_damage(30.0)
	player.heal(20.0)

	assert_eq(player.current_health, 90.0, "Player should have 90 health after healing")


func test_player_applies_health_item_modifiers() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)

	var health_boost = load("res://resources/items/health_boost.tres")
	player.apply_item_modifiers(health_boost)

	assert_eq(player.max_health, 120.0, "Max health should increase to 120 with +20 modifier")


func test_player_applies_speed_item_modifiers() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)

	var speed_item = load("res://resources/items/speed_boost.tres")
	player.apply_item_modifiers(speed_item)

	assert_eq(player.current_speed, 210.0, "Speed should be 210 with +10 modifier")


func test_player_equips_weapon() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)

	var weapon = load("res://resources/weapons/rusty_pistol.tres")
	player.equip_weapon(weapon)

	assert_eq(player.equipped_weapon, weapon, "Weapon should be equipped")


func test_player_invulnerability_blocks_damage() -> void:
	var player = autofree(Player.new())
	add_child(player)

	player.take_damage(10.0)
	var health_after_first = player.current_health
	player.take_damage(10.0)  # Should be blocked by invulnerability

	assert_eq(
		player.current_health,
		health_after_first,
		"Second damage should be blocked by invulnerability"
	)


# Enemy Entity Tests
func test_enemy_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")

	assert_not_null(enemy_resource, "Enemy resource should load")


func test_enemy_initializes_with_wave_1() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)

	assert_eq(enemy.current_wave, 1, "Enemy should be on wave 1")
	assert_gt(enemy.max_health, 0, "Enemy should have health")


func test_enemy_scales_health_with_wave() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)
	var wave1_health = enemy.max_health

	enemy.initialize(enemy_resource, 5)
	var wave5_health = enemy.max_health

	assert_gt(wave5_health, wave1_health, "Wave 5 should have more health than wave 1")


func test_enemy_takes_damage() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)
	var initial_health = enemy.current_health

	enemy.take_damage(20.0)

	assert_eq(enemy.current_health, initial_health - 20.0, "Enemy should take 20 damage")


func test_enemy_health_percentage_calculation() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)
	enemy.take_damage(20.0)

	var health_pct = enemy.get_health_percentage()

	assert_lt(health_pct, 1.0, "Health percentage should be less than 100% after damage")


func test_enemy_is_alive_when_health_positive() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)

	assert_true(enemy.is_alive(), "Enemy should be alive")


func test_enemy_is_dead_when_health_zero() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	var enemy = autofree(Enemy.new())
	add_child(enemy)

	enemy.initialize(enemy_resource, 1)
	enemy.current_health = 0

	assert_false(enemy.is_alive(), "Enemy should be dead at 0 health")


# Projectile Entity Tests
func test_projectile_activates_with_parameters() -> void:
	var projectile = autofree(Projectile.new())
	add_child(projectile)

	var spawn_pos = Vector2(100, 100)
	var direction = Vector2.RIGHT
	projectile.activate(spawn_pos, direction, 25.0, 400.0, 500.0)

	assert_true(projectile.is_active, "Projectile should be active")
	assert_eq(projectile.damage, 25.0, "Projectile should have 25 damage")
	assert_eq(projectile.projectile_speed, 400.0, "Projectile should have 400 speed")
	assert_eq(projectile.max_range, 500.0, "Projectile should have 500 range")


func test_projectile_velocity_is_set() -> void:
	var projectile = autofree(Projectile.new())
	add_child(projectile)

	var direction = Vector2.RIGHT
	projectile.activate(Vector2.ZERO, direction, 25.0, 400.0, 500.0)

	assert_gt(projectile.velocity.length(), 0, "Projectile should have velocity")
	assert_eq(
		projectile.velocity.normalized(), direction, "Projectile should move in correct direction"
	)


func test_projectile_pierce_is_set() -> void:
	var projectile = autofree(Projectile.new())
	add_child(projectile)

	projectile.activate(Vector2.ZERO, Vector2.RIGHT, 25.0, 400.0, 500.0)
	projectile.set_pierce(2)

	assert_eq(projectile.pierce_count, 2, "Projectile should have 2 pierce")


func test_projectile_remaining_range_is_full() -> void:
	var projectile = autofree(Projectile.new())
	add_child(projectile)

	projectile.activate(Vector2.ZERO, Vector2.RIGHT, 25.0, 400.0, 500.0)

	var remaining = projectile.get_remaining_range()

	assert_eq(remaining, 500.0, "Projectile should have full range remaining")


func test_projectile_deactivates() -> void:
	var projectile = autofree(Projectile.new())
	add_child(projectile)

	projectile.activate(Vector2.ZERO, Vector2.RIGHT, 25.0, 400.0, 500.0)
	projectile.deactivate()

	assert_false(projectile.is_active, "Projectile should be inactive")


# Combat Integration Tests
func test_enemy_targets_player() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)
	player.position = Vector2(100, 100)

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var basic_enemy = load("res://resources/enemies/basic.tres")
	enemy.initialize(basic_enemy, 1)
	enemy.position = Vector2(200, 100)
	enemy.set_target(player)

	assert_eq(enemy.target, player, "Enemy should target player")


func test_player_fires_weapon() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)
	var rusty_pistol = load("res://resources/weapons/rusty_pistol.tres")
	player.equip_weapon(rusty_pistol)

	watch_signals(player)
	player.fire_weapon()

	assert_signal_emitted(player, "weapon_fired", "Player should fire weapon signal")


func test_enemy_calculates_distance_to_player() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)
	player.position = Vector2(100, 100)

	var enemy = autofree(Enemy.new())
	add_child(enemy)
	var basic_enemy = load("res://resources/enemies/basic.tres")
	enemy.initialize(basic_enemy, 1)
	enemy.position = Vector2(200, 100)

	var distance = enemy.global_position.distance_to(player.global_position)

	assert_eq(distance, 100.0, "Distance should be 100 units")


func test_player_armor_reduces_damage() -> void:
	var player = autofree(Player.new())
	add_child(player)

	player.current_armor = 10.0
	var health_before = player.current_health
	player.take_damage(100.0)
	var damage_taken = health_before - player.current_health

	assert_lt(damage_taken, 100.0, "Armor should reduce damage")


func test_player_life_steal_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var player = autofree(Player.new())
	add_child(player)

	var vampiric_fangs = load("res://resources/items/vampiric_fangs.tres")
	player.apply_item_modifiers(vampiric_fangs)

	assert_eq(player.stat_modifiers.get("lifeSteal", 0), 3, "Player should have 3 life steal")


# Resource Loading Tests
func test_weapon_resource_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rusty_pistol = load("res://resources/weapons/rusty_pistol.tres")
	assert_not_null(rusty_pistol, "Weapon resource should load")
	assert_eq(rusty_pistol.weapon_name, "Rusty Pistol", "Weapon should have correct name")


func test_enemy_resource_basic_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var basic_enemy = load("res://resources/enemies/basic.tres")
	assert_not_null(basic_enemy, "Enemy resource should load")


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
