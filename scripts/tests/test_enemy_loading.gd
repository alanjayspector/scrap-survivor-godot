extends Node
## Test script to verify enemy resources load correctly
##
## Tests:
## - Loading all 3 enemy types
## - Wave scaling formulas
## - Spawn weight distribution
## - Drop chance mechanics
##
## Usage:
## 1. Create a new scene with a Node
## 2. Attach this script
## 3. Run the scene (F6)
## 4. Check console output

# Cached enemy resources (loaded once)
var enemy_basic: EnemyResource
var enemy_fast: EnemyResource
var enemy_tank: EnemyResource


func _ready() -> void:
	# Load enemies once
	enemy_basic = load("res://resources/enemies/basic.tres")
	enemy_fast = load("res://resources/enemies/fast.tres")
	enemy_tank = load("res://resources/enemies/tank.tres")
	print("=== Enemy Resource Loading Test ===")
	print("")

	_test_load_enemies()
	print("")
	_test_wave_scaling()
	print("")
	_test_spawn_weights()
	print("")
	_test_drop_chances()

	print("")
	print("=== Test Complete ===")


func _test_load_enemies() -> void:
	print("1. Loading Enemy Resources:")

	var enemy_ids = ["basic", "fast", "tank"]

	for enemy_id in enemy_ids:
		var path = "res://resources/enemies/%s.tres" % enemy_id
		var enemy: EnemyResource = load(path)

		if enemy == null:
			push_error("Failed to load: %s" % path)
			continue

		print(
			(
				"  ✓ %s: %s (HP=%d, Speed=%d, Damage=%d, Weight=%d%%)"
				% [
					enemy.enemy_id,
					enemy.enemy_name,
					enemy.base_hp,
					enemy.base_speed,
					enemy.base_damage,
					enemy.spawn_weight
				]
			)
		)


func _test_wave_scaling() -> void:
	print("2. Wave Scaling Tests:")

	print("  Scrap Shambler scaling:")
	print(
		(
			"  Base: HP=%d, Speed=%d, Damage=%d, Value=%d"
			% [
				enemy_basic.base_hp,
				enemy_basic.base_speed,
				enemy_basic.base_damage,
				enemy_basic.base_value
			]
		)
	)

	for wave in [1, 5, 10, 15, 20]:
		var stats = enemy_basic.get_scaled_stats(wave)
		print(
			(
				"  Wave %2d: HP=%3d, Speed=%2d, Damage=%2d, Value=%2d"
				% [wave, stats.hp, stats.speed, stats.damage, stats.value]
			)
		)

	# Verify formulas
	print("")
	print("  Formula Verification (Wave 5):")
	var wave5_stats = enemy_basic.get_scaled_stats(5)

	var expected_hp = int(enemy_basic.base_hp * (1.0 + (5 - 1) * 0.25))
	var expected_speed = int(enemy_basic.base_speed * (1.0 + (5 - 1) * 0.05))
	var expected_damage = int(enemy_basic.base_damage * (1.0 + (5 - 1) * 0.10))
	var expected_value = int(enemy_basic.base_value * (1.0 + (5 - 1) * 0.20))

	var hp_match = wave5_stats.hp == expected_hp
	var speed_match = wave5_stats.speed == expected_speed
	var damage_match = wave5_stats.damage == expected_damage
	var value_match = wave5_stats.value == expected_value

	print(
		(
			"  HP formula:     %s (got %d, expected %d)"
			% ["✓" if hp_match else "✗", wave5_stats.hp, expected_hp]
		)
	)
	print(
		(
			"  Speed formula:  %s (got %d, expected %d)"
			% ["✓" if speed_match else "✗", wave5_stats.speed, expected_speed]
		)
	)
	print(
		(
			"  Damage formula: %s (got %d, expected %d)"
			% ["✓" if damage_match else "✗", wave5_stats.damage, expected_damage]
		)
	)
	print(
		(
			"  Value formula:  %s (got %d, expected %d)"
			% ["✓" if value_match else "✗", wave5_stats.value, expected_value]
		)
	)


func _test_spawn_weights() -> void:
	print("3. Spawn Weight Distribution:")

	var total_weight = enemy_basic.spawn_weight + enemy_fast.spawn_weight + enemy_tank.spawn_weight

	print("  Total weight: %d" % total_weight)
	print(
		(
			"  Basic: %d%% (%d/%d)"
			% [enemy_basic.get_spawn_percentage(), enemy_basic.spawn_weight, total_weight]
		)
	)
	print(
		(
			"  Fast:  %d%% (%d/%d)"
			% [enemy_fast.get_spawn_percentage(), enemy_fast.spawn_weight, total_weight]
		)
	)
	print(
		(
			"  Tank:  %d%% (%d/%d)"
			% [enemy_tank.get_spawn_percentage(), enemy_tank.spawn_weight, total_weight]
		)
	)

	if total_weight == 100:
		print("  ✅ Weights sum to 100 (perfect for weighted selection)")
	else:
		push_warning("  ⚠️  Weights sum to %d, not 100" % total_weight)


func _test_drop_chances() -> void:
	print("4. Drop Chance System:")

	print("  Basic: %.0f%% drop chance" % (enemy_basic.drop_chance * 100))
	print("  Fast:  %.0f%% drop chance" % (enemy_fast.drop_chance * 100))
	print("  Tank:  %.0f%% drop chance" % (enemy_tank.drop_chance * 100))

	# Test should_drop_item (probabilistic)
	print("")
	print("  Testing should_drop_item() (1000 trials):")

	var enemies = [enemy_basic, enemy_fast, enemy_tank]
	for enemy in enemies:
		var drop_count = 0
		var trials = 1000

		for i in range(trials):
			if enemy.should_drop_item():
				drop_count += 1

		var actual_rate = float(drop_count) / float(trials)
		var expected_rate = enemy.drop_chance
		var diff = abs(actual_rate - expected_rate)

		print(
			(
				"  %s: %d/%d drops (%.1f%%, expected %.1f%%, diff %.1f%%)"
				% [
					enemy.enemy_name,
					drop_count,
					trials,
					actual_rate * 100,
					expected_rate * 100,
					diff * 100
				]
			)
		)
