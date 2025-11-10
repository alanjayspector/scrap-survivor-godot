extends GutTest
## Test script for StatService using GUT framework
##
## Tests stat calculations, modifiers, and secondary stats (dodge, crit, life steal).

class_name StatServiceTest


func before_each() -> void:
	# StatService is stateless, no setup needed
	pass


func after_each() -> void:
	# No cleanup needed
	pass


func test_calculate_damage_with_base_only() -> void:
	# Arrange
	var base_damage = 50.0
	var strength = 0.0

	# Act
	var damage = StatService.calculate_damage(base_damage, strength)

	# Assert
	assert_eq(damage, 50.0, "Base damage should be 50 with no strength")


func test_calculate_damage_with_strength_bonus() -> void:
	# Arrange
	var base_damage = 50.0
	var strength = 20.0

	# Act
	var damage = StatService.calculate_damage(base_damage, strength)

	# Assert
	assert_eq(damage, 60.0, "20 strength should add 10 damage (50% conversion)")


func test_calculate_damage_with_weapon_bonus() -> void:
	# Arrange
	var base_damage = 50.0
	var strength = 20.0
	var weapon_bonus = 15.0

	# Act
	var damage = StatService.calculate_damage(base_damage, strength, weapon_bonus)

	# Assert
	assert_eq(damage, 75.0, "Should include weapon bonus of 15")


func test_calculate_health_with_base_only() -> void:
	# Arrange
	var base_health = 100.0
	var vitality = 0.0

	# Act
	var health = StatService.calculate_health(base_health, vitality)

	# Assert
	assert_eq(health, 100.0, "Base health should be 100 with no vitality")


func test_calculate_health_with_vitality_bonus() -> void:
	# Arrange
	var base_health = 100.0
	var vitality = 30.0

	# Act
	var health = StatService.calculate_health(base_health, vitality)

	# Assert
	assert_eq(health, 160.0, "30 vitality should add 60 health (2x conversion)")


func test_calculate_speed_with_base_only() -> void:
	# Arrange
	var base_speed = 200.0
	var agility = 0.0

	# Act
	var speed = StatService.calculate_speed(base_speed, agility)

	# Assert
	assert_eq(speed, 200.0, "Base speed should be 200 with no agility")


func test_calculate_speed_with_agility_bonus() -> void:
	# Arrange
	var base_speed = 200.0
	var agility = 40.0

	# Act
	var speed = StatService.calculate_speed(base_speed, agility)

	# Assert
	assert_eq(speed, 210.0, "40 agility should add 10 speed (25% conversion)")


func test_apply_stat_modifiers_increases_and_decreases_stats() -> void:
	# Arrange
	var base_stats = {"damage": 50.0, "speed": 200.0, "armor": 10.0}
	var modifiers = {"damage": 15.0, "speed": -20.0, "new_stat": 5.0}

	# Act
	var result = StatService.apply_stat_modifiers(base_stats, modifiers)

	# Assert
	assert_eq(result["damage"], 65.0, "Damage should increase by 15")
	assert_eq(result["speed"], 180.0, "Speed should decrease by 20")
	assert_eq(result["armor"], 10.0, "Armor should remain unchanged")
	assert_false(result.has("new_stat"), "Should not add new stats from modifiers")


func test_apply_stat_modifiers_clamps_negative_values_to_zero() -> void:
	# Arrange
	var base_stats = {"damage": 50.0, "speed": 200.0, "armor": 10.0}
	var modifiers = {"speed": -250.0}

	# Act
	var result = StatService.apply_stat_modifiers(base_stats, modifiers)

	# Assert
	assert_eq(result["speed"], 0.0, "Speed should clamp to 0 when modifier exceeds base")


func test_calculate_armor_reduction_with_zero_armor() -> void:
	# Arrange
	var armor = 0.0

	# Act
	var reduction = StatService.calculate_armor_reduction(armor)

	# Assert
	assert_eq(reduction, 0.0, "0 armor should give 0% reduction")


func test_calculate_armor_reduction_with_normal_armor() -> void:
	# Arrange
	var armor = 25.0

	# Act
	var reduction = StatService.calculate_armor_reduction(armor)

	# Assert
	assert_eq(reduction, 0.5, "25 armor should give 50% damage reduction")


func test_calculate_armor_reduction_caps_at_80_percent() -> void:
	# Arrange
	var armor = 100.0

	# Act
	var reduction = StatService.calculate_armor_reduction(armor)

	# Assert
	assert_eq(reduction, 0.8, "Armor reduction should cap at 80%")


func test_calculate_dodge_chance_scales_with_agility() -> void:
	# Arrange
	var agility = 100.0

	# Act
	var dodge = StatService.calculate_dodge_chance(agility)

	# Assert
	assert_eq(dodge, 0.1, "100 agility should give 10% dodge chance")


func test_calculate_dodge_chance_caps_at_50_percent() -> void:
	# Arrange
	var agility = 600.0

	# Act
	var dodge = StatService.calculate_dodge_chance(agility)

	# Assert
	assert_eq(dodge, 0.5, "Dodge chance should cap at 50%")


func test_calculate_crit_chance_scales_with_luck() -> void:
	# Arrange
	var luck = 50.0

	# Act
	var crit = StatService.calculate_crit_chance(luck)

	# Assert
	assert_eq(crit, 0.1, "50 luck should give 10% crit chance")


func test_calculate_crit_chance_caps_at_30_percent() -> void:
	# Arrange
	var luck = 200.0

	# Act
	var crit = StatService.calculate_crit_chance(luck)

	# Assert
	assert_eq(crit, 0.3, "Crit chance should cap at 30%")


func test_calculate_life_steal_percentage_of_damage() -> void:
	# Arrange
	var life_steal_percent = 10.0
	var damage_dealt = 100.0

	# Act
	var heal_amount = StatService.calculate_life_steal(life_steal_percent, damage_dealt)

	# Assert
	assert_eq(heal_amount, 10.0, "10% life steal on 100 damage should heal 10 HP")
