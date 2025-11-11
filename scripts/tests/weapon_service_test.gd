extends GutTest
## Test script for WeaponService using GUT framework
##
## USER STORY: "As a player, I want to equip different weapons with unique
## damage types and attack speeds, so that I can customize my combat playstyle
## and take advantage of my character's stat bonuses"
##
## Tests weapon equipping, damage calculation, cooldown mechanics, attack speed
## integration, and tier restrictions.

class_name WeaponServiceTest


func before_each() -> void:
	# Reset service state before each test
	WeaponService.reset_cooldowns()
	WeaponService.equipped_weapons.clear()

	# Set PREMIUM tier for most tests (allows all test weapons)
	WeaponService.set_tier(WeaponService.UserTier.PREMIUM)


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Weapon Existence and Data Tests
## User Story: "As a player, I want to see weapon information"
## ============================================================================


func test_weapon_exists_returns_true_for_valid_weapon() -> void:
	# Arrange & Act
	var exists = WeaponService.weapon_exists("rusty_blade")

	# Assert
	assert_true(exists, "rusty_blade should exist")


func test_weapon_exists_returns_false_for_invalid_weapon() -> void:
	# Arrange & Act
	var exists = WeaponService.weapon_exists("nonexistent_weapon")

	# Assert
	assert_false(exists, "Nonexistent weapon should return false")


func test_get_weapon_returns_valid_data() -> void:
	# Arrange & Act
	var weapon = WeaponService.get_weapon("plasma_pistol")

	# Assert
	assert_eq(weapon.display_name, "Plasma Pistol", "Should return correct display name")
	assert_eq(weapon.type, WeaponService.WeaponType.RANGED, "Should be RANGED type")
	assert_eq(weapon.base_damage, 10, "Should have base damage 10")
	assert_almost_eq(weapon.cooldown, 0.8, 0.01, "Should have 0.8s cooldown")
	assert_eq(weapon.range, 500, "Should have 500 range (Week 11 auto-targeting range)")


func test_get_weapon_returns_empty_for_invalid_weapon() -> void:
	# Arrange & Act
	var weapon = WeaponService.get_weapon("invalid_weapon")

	# Assert
	assert_true(weapon.is_empty(), "Should return empty dictionary for invalid weapon")


## ============================================================================
## SECTION 2: Weapon Equipping Tests
## User Story: "As a player, I want to equip weapons to my character"
## ============================================================================


func test_equip_weapon_success() -> void:
	# Arrange
	var character_id = "char_test123"
	var weapon_id = "rusty_blade"

	# Act
	var success = WeaponService.equip_weapon(character_id, weapon_id)

	# Assert
	assert_true(success, "Should successfully equip weapon")
	assert_eq(
		WeaponService.get_equipped_weapon(character_id),
		weapon_id,
		"Character should have weapon equipped"
	)


func test_equip_weapon_with_empty_character_id_fails() -> void:
	# Arrange
	var character_id = ""
	var weapon_id = "rusty_blade"

	# Act
	var success = WeaponService.equip_weapon(character_id, weapon_id)

	# Assert
	assert_false(success, "Should fail with empty character_id")


func test_equip_weapon_with_invalid_weapon_id_fails() -> void:
	# Arrange
	var character_id = "char_test123"
	var weapon_id = "nonexistent_weapon"

	# Act
	var success = WeaponService.equip_weapon(character_id, weapon_id)

	# Assert
	assert_false(success, "Should fail with invalid weapon_id")


func test_equip_weapon_with_tier_restriction() -> void:
	# Arrange
	WeaponService.set_tier(WeaponService.UserTier.FREE)
	var character_id = "char_test123"
	var weapon_id = "steel_sword"  # Requires PREMIUM tier

	# Act
	var success = WeaponService.equip_weapon(character_id, weapon_id)

	# Assert
	assert_false(success, "Should fail when tier requirement not met")
	assert_eq(
		WeaponService.get_equipped_weapon(character_id), "", "Character should not have weapon"
	)


func test_equip_weapon_replaces_previous_weapon() -> void:
	# Arrange
	var character_id = "char_test123"
	WeaponService.equip_weapon(character_id, "rusty_blade")

	# Act
	var success = WeaponService.equip_weapon(character_id, "plasma_pistol")

	# Assert
	assert_true(success, "Should successfully replace weapon")
	assert_eq(
		WeaponService.get_equipped_weapon(character_id),
		"plasma_pistol",
		"Should have new weapon equipped"
	)


func test_unequip_weapon() -> void:
	# Arrange
	var character_id = "char_test123"
	WeaponService.equip_weapon(character_id, "rusty_blade")

	# Act
	WeaponService.unequip_weapon(character_id)

	# Assert
	assert_eq(
		WeaponService.get_equipped_weapon(character_id), "", "Character should have no weapon"
	)


## ============================================================================
## SECTION 3: Damage Calculation Tests
## User Story: "As a player, I want my character stats to affect weapon damage"
## ============================================================================


func test_get_weapon_damage_with_base_stats_only() -> void:
	# Arrange
	var weapon_id = "rusty_blade"
	var character_stats = {"damage": 0, "melee_damage": 0, "ranged_damage": 0}

	# Act
	var damage = WeaponService.get_weapon_damage(weapon_id, character_stats)

	# Assert
	assert_almost_eq(damage, 15.0, 0.01, "Should return base damage only (15)")


func test_get_weapon_damage_with_character_damage_bonus() -> void:
	# Arrange
	var weapon_id = "rusty_blade"
	var character_stats = {"damage": 10, "melee_damage": 0, "ranged_damage": 0}

	# Act
	var damage = WeaponService.get_weapon_damage(weapon_id, character_stats)

	# Assert
	assert_almost_eq(damage, 25.0, 0.01, "Should add character damage (15 + 10 = 25)")


func test_get_weapon_damage_with_melee_bonus() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # MELEE weapon
	var character_stats = {"damage": 5, "melee_damage": 10, "ranged_damage": 0}

	# Act
	var damage = WeaponService.get_weapon_damage(weapon_id, character_stats)

	# Assert
	assert_almost_eq(damage, 30.0, 0.01, "Should add melee bonus (15 + 5 + 10 = 30)")


func test_get_weapon_damage_with_ranged_bonus() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"  # RANGED weapon
	var character_stats = {"damage": 5, "melee_damage": 0, "ranged_damage": 8}

	# Act
	var damage = WeaponService.get_weapon_damage(weapon_id, character_stats)

	# Assert
	assert_almost_eq(damage, 23.0, 0.01, "Should add ranged bonus (10 + 5 + 8 = 23)")


func test_get_weapon_damage_ignores_wrong_type_bonus() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # MELEE weapon
	var character_stats = {"damage": 5, "melee_damage": 10, "ranged_damage": 50}

	# Act
	var damage = WeaponService.get_weapon_damage(weapon_id, character_stats)

	# Assert
	assert_almost_eq(
		damage, 30.0, 0.01, "Should ignore ranged_damage for melee weapon (15 + 5 + 10 = 30)"
	)


## ============================================================================
## SECTION 4: Cooldown Calculation Tests
## User Story: "As a player, I want attack speed to make me attack faster"
## ============================================================================


func test_get_weapon_cooldown_with_zero_attack_speed() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"  # 0.8s base cooldown
	var attack_speed = 0.0

	# Act
	var cooldown = WeaponService.get_weapon_cooldown(weapon_id, attack_speed)

	# Assert
	assert_almost_eq(cooldown, 0.8, 0.01, "Should return base cooldown with 0 attack speed")


func test_attack_speed_reduces_cooldown() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"  # 0.8s base cooldown
	var attack_speed = 15.0  # 15% reduction

	# Act
	var cooldown = WeaponService.get_weapon_cooldown(weapon_id, attack_speed)

	# Assert
	# 0.8 * (1 - 0.15) = 0.68
	assert_almost_eq(cooldown, 0.68, 0.01, "Should reduce cooldown by 15% (0.8 * 0.85 = 0.68)")


func test_attack_speed_caps_at_75_percent() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"  # 0.8s base cooldown
	var attack_speed = 100.0  # 100% reduction (should cap at 75%)

	# Act
	var cooldown = WeaponService.get_weapon_cooldown(weapon_id, attack_speed)

	# Assert
	# 0.8 * (1 - 0.75) = 0.2
	assert_almost_eq(cooldown, 0.2, 0.01, "Should cap at 75% reduction (0.8 * 0.25 = 0.2)")


func test_attack_speed_50_percent_reduction() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # 0.5s base cooldown
	var attack_speed = 50.0  # 50% reduction

	# Act
	var cooldown = WeaponService.get_weapon_cooldown(weapon_id, attack_speed)

	# Assert
	# 0.5 * (1 - 0.5) = 0.25
	assert_almost_eq(cooldown, 0.25, 0.01, "Should reduce by 50% (0.5 * 0.5 = 0.25)")


## ============================================================================
## SECTION 5: Weapon Firing Tests
## User Story: "As a player, I want to fire weapons with cooldown mechanics"
## ============================================================================


func test_can_fire_weapon_when_ready() -> void:
	# Arrange
	var weapon_instance_id = "weapon_instance_1"

	# Act
	var can_fire = WeaponService.can_fire_weapon(weapon_instance_id)

	# Assert
	assert_true(can_fire, "Should be able to fire weapon when no cooldown")


func test_can_fire_weapon_returns_false_during_cooldown() -> void:
	# Arrange
	var weapon_instance_id = "weapon_instance_1"
	WeaponService.fire_weapon("rusty_blade", weapon_instance_id, Vector2.ZERO, Vector2.RIGHT)

	# Act
	var can_fire = WeaponService.can_fire_weapon(weapon_instance_id)

	# Assert
	assert_false(can_fire, "Should not be able to fire weapon during cooldown")


func test_fire_weapon_success() -> void:
	# Arrange
	var weapon_id = "rusty_blade"
	var weapon_instance_id = "weapon_instance_1"
	var position = Vector2(100, 200)
	var direction = Vector2(1, 0)

	# Act
	var success = WeaponService.fire_weapon(weapon_id, weapon_instance_id, position, direction)

	# Assert
	assert_true(success, "Should successfully fire weapon")
	assert_false(
		WeaponService.can_fire_weapon(weapon_instance_id), "Should start cooldown after firing"
	)


func test_fire_weapon_with_invalid_weapon_id_fails() -> void:
	# Arrange
	var weapon_id = "invalid_weapon"
	var weapon_instance_id = "weapon_instance_1"

	# Act
	var success = WeaponService.fire_weapon(
		weapon_id, weapon_instance_id, Vector2.ZERO, Vector2.RIGHT
	)

	# Assert
	assert_false(success, "Should fail with invalid weapon_id")


func test_fire_weapon_respects_cooldown() -> void:
	# Arrange
	var weapon_id = "rusty_blade"
	var weapon_instance_id = "weapon_instance_1"
	WeaponService.fire_weapon(weapon_id, weapon_instance_id, Vector2.ZERO, Vector2.RIGHT)

	# Act
	var success = WeaponService.fire_weapon(
		weapon_id, weapon_instance_id, Vector2.ZERO, Vector2.RIGHT
	)

	# Assert
	assert_false(success, "Should not fire weapon during cooldown")


func test_get_cooldown_remaining() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # 0.5s cooldown
	var weapon_instance_id = "weapon_instance_1"
	WeaponService.fire_weapon(weapon_id, weapon_instance_id, Vector2.ZERO, Vector2.RIGHT)

	# Act
	var remaining = WeaponService.get_cooldown_remaining(weapon_instance_id)

	# Assert
	assert_almost_eq(remaining, 0.5, 0.01, "Should return remaining cooldown time")


## ============================================================================
## SECTION 6: Tier-Based Weapon Availability Tests
## User Story: "As a player, I want to unlock premium weapons"
## ============================================================================


func test_get_available_weapons_for_free_tier() -> void:
	# Arrange
	WeaponService.set_tier(WeaponService.UserTier.FREE)

	# Act
	var available = WeaponService.get_available_weapons(WeaponService.UserTier.FREE)

	# Assert
	assert_true(available.has("rusty_blade"), "FREE tier should have rusty_blade")
	assert_true(available.has("plasma_pistol"), "FREE tier should have plasma_pistol")
	assert_false(available.has("steel_sword"), "FREE tier should not have steel_sword")


func test_get_available_weapons_for_premium_tier() -> void:
	# Arrange
	WeaponService.set_tier(WeaponService.UserTier.PREMIUM)

	# Act
	var available = WeaponService.get_available_weapons(WeaponService.UserTier.PREMIUM)

	# Assert
	assert_true(available.has("rusty_blade"), "PREMIUM tier should have rusty_blade")
	assert_true(available.has("plasma_pistol"), "PREMIUM tier should have plasma_pistol")
	assert_true(available.has("steel_sword"), "PREMIUM tier should have steel_sword")
	assert_true(available.has("shock_rifle"), "PREMIUM tier should have shock_rifle")
