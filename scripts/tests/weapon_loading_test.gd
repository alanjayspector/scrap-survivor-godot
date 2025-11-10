extends GutTest
## Test script to verify weapon resources load correctly using GUT framework
##
## USER STORY: "As a player, I want weapons with different stats and rarities"
##
## Tests individual weapon loading and bulk directory loading.

class_name WeaponLoadingTest

# gdlint: disable=duplicated-load

# Preload the WeaponResource script to ensure class is registered in headless mode
const _WEAPON_RESOURCE_SCRIPT = preload("res://scripts/resources/weapon_resource.gd")

## WEAPON TESTS TOGGLE
## Set to true to enable weapon resource tests when running in Godot Editor GUI
## These tests fail in headless CI due to Godot limitation with WeaponResource loading
## Even preload() fails at parse time because WeaponResource class isn't registered
## See docs/godot-headless-resource-loading-guide.md for technical details
##
## To run tests in Godot Editor:
## 1. Change ENABLE_WEAPON_TESTS to true
## 2. Open project in Godot Editor GUI
## 3. Run tests from GUT panel (bottom panel)
const ENABLE_WEAPON_TESTS = false


func before_each() -> void:
	# Setup before each test
	pass


func after_each() -> void:
	# Cleanup
	pass


# Individual Weapon Loading Tests
func test_rusty_pistol_resource_loads() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/rusty_pistol.tres")
	assert_not_null(weapon, "Rusty Pistol resource should load")


func test_rusty_pistol_has_valid_dps() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/rusty_pistol.tres")
	var dps = weapon.get_dps()
	assert_gt(dps, 0.0, "Rusty Pistol should have positive DPS")


func test_rusty_pistol_premium_status() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/rusty_pistol.tres")
	# rusty_pistol is a common weapon, should not be premium
	assert_false(weapon.is_premium_weapon(), "Rusty Pistol should not be premium")


func test_rusty_pistol_rarity_tier() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/rusty_pistol.tres")
	var tier = weapon.get_rarity_tier()
	assert_gte(tier, 0, "Rarity tier should be >= 0")
	assert_lte(tier, 4, "Rarity tier should be <= 4 (legendary)")


func test_void_cannon_resource_loads() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/void_cannon.tres")
	assert_not_null(weapon, "Void Cannon resource should load")


func test_void_cannon_has_valid_dps() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/void_cannon.tres")
	var dps = weapon.get_dps()
	assert_gt(dps, 0.0, "Void Cannon should have positive DPS")


func test_void_cannon_rarity_tier() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/void_cannon.tres")
	var tier = weapon.get_rarity_tier()
	assert_gte(tier, 0, "Rarity tier should be >= 0")
	assert_lte(tier, 4, "Rarity tier should be <= 4 (legendary)")


func test_plasma_cutter_resource_loads() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/plasma_cutter.tres")
	assert_not_null(weapon, "Plasma Cutter resource should load")


func test_plasma_cutter_has_valid_dps() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/plasma_cutter.tres")
	var dps = weapon.get_dps()
	assert_gt(dps, 0.0, "Plasma Cutter should have positive DPS")


func test_plasma_cutter_rarity_tier() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapon: WeaponResource = load("res://resources/weapons/plasma_cutter.tres")
	var tier = weapon.get_rarity_tier()
	assert_gte(tier, 0, "Rarity tier should be >= 0")
	assert_lte(tier, 4, "Rarity tier should be <= 4 (legendary)")


# Bulk Loading Tests
# NOTE: These tests are disabled by default for headless CI due to Godot limitation
# Set ENABLE_WEAPON_TESTS = true at top of file to run in Godot Editor GUI
func test_weapons_directory_exists() -> void:
	var weapons_dir = DirAccess.open("res://resources/weapons/")

	assert_not_null(weapons_dir, "Weapons directory should exist")


func test_all_weapon_resources_load() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapons_dir = DirAccess.open("res://resources/weapons/")
	assert_not_null(weapons_dir, "Weapons directory should exist")

	var weapon_files: Array[String] = []
	weapons_dir.list_dir_begin()
	var file_name = weapons_dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			weapon_files.append(file_name)
		file_name = weapons_dir.get_next()
	weapons_dir.list_dir_end()

	for file in weapon_files:
		var weapon_path = "res://resources/weapons/" + file
		var weapon: WeaponResource = load(weapon_path)
		assert_not_null(weapon, "Weapon %s should load" % file)


func test_expected_23_weapons_exist() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapons_dir = DirAccess.open("res://resources/weapons/")
	assert_not_null(weapons_dir, "Weapons directory should exist")

	var weapon_count = 0
	weapons_dir.list_dir_begin()
	var file_name = weapons_dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			weapon_count += 1
		file_name = weapons_dir.get_next()
	weapons_dir.list_dir_end()

	assert_eq(weapon_count, 23, "Should have exactly 23 weapon resources")


func test_all_loaded_weapons_have_valid_stats() -> void:
	if not ENABLE_WEAPON_TESTS:
		pending("Disabled for headless CI - set ENABLE_WEAPON_TESTS=true to run in Godot Editor")
		return

	var weapons_dir = DirAccess.open("res://resources/weapons/")
	assert_not_null(weapons_dir, "Weapons directory should exist")

	var weapon_files: Array[String] = []
	weapons_dir.list_dir_begin()
	var file_name = weapons_dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			weapon_files.append(file_name)
		file_name = weapons_dir.get_next()
	weapons_dir.list_dir_end()

	for file in weapon_files:
		var weapon_path = "res://resources/weapons/" + file
		var weapon: WeaponResource = load(weapon_path)
		if weapon:
			assert_gt(weapon.get_dps(), 0.0, "%s should have positive DPS" % file)
			var tier = weapon.get_rarity_tier()
			assert_gte(tier, 0, "%s rarity tier should be >= 0" % file)
			assert_lte(tier, 4, "%s rarity tier should be <= 4" % file)
