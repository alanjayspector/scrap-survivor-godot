extends Node
## Test script for StatService


func _ready() -> void:
	print("=== StatService Test ===")
	print()

	test_damage_calculation()
	test_health_calculation()
	test_speed_calculation()
	test_stat_modifiers()
	test_armor_reduction()
	test_dodge_crit_calculations()

	print()
	print("=== StatService Tests Complete ===")


func test_damage_calculation() -> void:
	print("--- Testing Damage Calculation ---")

	# Base only
	var damage = StatService.calculate_damage(50.0, 0.0)
	assert(damage == 50.0, "Base damage should be 50")

	# With strength
	damage = StatService.calculate_damage(50.0, 20.0)
	assert(damage == 60.0, "20 strength should add 10 damage")

	# With weapon
	damage = StatService.calculate_damage(50.0, 20.0, 15.0)
	assert(damage == 75.0, "Should include weapon bonus")

	print("✓ All damage calculations correct")


func test_health_calculation() -> void:
	print("--- Testing Health Calculation ---")

	# Base only
	var health = StatService.calculate_health(100.0, 0.0)
	assert(health == 100.0, "Base health should be 100")

	# With vitality
	health = StatService.calculate_health(100.0, 30.0)
	assert(health == 160.0, "30 vitality should add 60 health")

	print("✓ All health calculations correct")


func test_speed_calculation() -> void:
	print("--- Testing Speed Calculation ---")

	# Base only
	var speed = StatService.calculate_speed(200.0, 0.0)
	assert(speed == 200.0, "Base speed should be 200")

	# With agility
	speed = StatService.calculate_speed(200.0, 40.0)
	assert(speed == 210.0, "40 agility should add 10 speed")

	print("✓ All speed calculations correct")


func test_stat_modifiers() -> void:
	print("--- Testing Stat Modifiers ---")

	var base_stats = {"damage": 50.0, "speed": 200.0, "armor": 10.0}

	var modifiers = {"damage": 15.0, "speed": -20.0, "new_stat": 5.0}  # Should be ignored

	var result = StatService.apply_stat_modifiers(base_stats, modifiers)

	assert(result["damage"] == 65.0, "Damage should increase by 15")
	assert(result["speed"] == 180.0, "Speed should decrease by 20")
	assert(result["armor"] == 10.0, "Armor should remain unchanged")
	assert(!result.has("new_stat"), "Should not add new stats")

	# Test negative clamping
	modifiers = {"speed": -250.0}
	result = StatService.apply_stat_modifiers(base_stats, modifiers)
	assert(result["speed"] == 0.0, "Speed should clamp to 0")

	print("✓ Stat modifiers apply correctly")


func test_armor_reduction() -> void:
	print("--- Testing Armor Reduction ---")

	# No armor
	var reduction = StatService.calculate_armor_reduction(0.0)
	assert(reduction == 0.0, "0 armor should give 0% reduction")

	# Normal armor
	reduction = StatService.calculate_armor_reduction(25.0)
	assert(reduction == 0.5, "25 armor should give 50% reduction")

	# Cap test
	reduction = StatService.calculate_armor_reduction(100.0)
	assert(reduction == 0.8, "Should cap at 80% reduction")

	print("✓ Armor reduction calculations correct")


func test_dodge_crit_calculations() -> void:
	print("--- Testing Dodge/Crit Calculations ---")

	# Dodge chance
	var dodge = StatService.calculate_dodge_chance(100.0)
	assert(dodge == 0.1, "100 agility should give 10% dodge")

	dodge = StatService.calculate_dodge_chance(600.0)
	assert(dodge == 0.5, "Should cap at 50% dodge")

	# Crit chance
	var crit = StatService.calculate_crit_chance(50.0)
	assert(crit == 0.1, "50 luck should give 10% crit")

	crit = StatService.calculate_crit_chance(200.0)
	assert(crit == 0.3, "Should cap at 30% crit")

	# Life steal
	var heal = StatService.calculate_life_steal(10.0, 100.0)
	assert(heal == 10.0, "10% of 100 damage should heal 10")

	print("✓ Secondary stat calculations correct")
