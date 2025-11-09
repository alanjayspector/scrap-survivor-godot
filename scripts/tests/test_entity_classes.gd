extends Node
## Test script for entity classes (Player, Enemy, Projectile)
##
## Tests entity initialization, stats, combat mechanics, and resource integration.
##
## Usage:
##   1. Attach this script to a Node in a test scene
##   2. Run the scene
##   3. Check console output for test results

# gdlint: disable=duplicated-load

# Preload resources to avoid duplicated loading
const RUSTY_PISTOL = preload("res://resources/weapons/rusty_pistol.tres")
const BASIC_ENEMY = preload("res://resources/enemies/basic.tres")
const HEALTH_BOOST = preload("res://resources/items/health_boost.tres")
const VAMPIRIC_FANGS = preload("res://resources/items/vampiric_fangs.tres")


func _ready() -> void:
	print("=== Entity Classes Test Suite ===")
	print()

	test_player_entity()
	test_enemy_entity()
	test_projectile_entity()
	test_combat_integration()

	print()
	print("=== All Entity Tests Complete ===")


func test_player_entity() -> void:
	print("--- Testing Player Entity ---")

	# Create player instance
	var player = Player.new()
	add_child(player)

	# Test initial stats
	assert(player.max_health == 100.0, "Player should start with 100 max health")
	assert(player.current_health == 100.0, "Player should start at full health")
	assert(player.base_speed == 200.0, "Player should have 200 base speed")
	print("✓ Player initialized with correct base stats")

	# Test damage
	player.take_damage(30.0)
	assert(player.current_health == 70.0, "Player should have 70 health after 30 damage")
	print("✓ Player takes damage correctly")

	# Test healing
	player.heal(20.0)
	assert(player.current_health == 90.0, "Player should have 90 health after healing")
	print("✓ Player heals correctly")

	# Test item modifiers
	player.apply_item_modifiers(HEALTH_BOOST)
	assert(player.max_health == 120.0, "Max health should increase to 120 with +20 modifier")
	print("✓ Player applies item modifiers (+20 maxHp)")

	# Test stat calculation
	var speed_item = load("res://resources/items/speed_boost.tres")
	player.apply_item_modifiers(speed_item)
	assert(player.current_speed == 210.0, "Speed should be 210 with +10 modifier")
	print("✓ Player recalculates stats with multiple modifiers")

	# Test weapon equipping
	var weapon = load("res://resources/weapons/rusty_pistol.tres")
	player.equip_weapon(weapon)
	assert(player.equipped_weapon == weapon, "Weapon should be equipped")
	print("✓ Player equips weapon: %s" % weapon.weapon_name)

	# Test invulnerability
	player.take_damage(10.0)
	var health_after_first = player.current_health
	player.take_damage(10.0)  # Should be blocked by invulnerability
	assert(
		player.current_health == health_after_first,
		"Second damage should be blocked by invulnerability"
	)
	print("✓ Player invulnerability works")

	# Cleanup
	player.queue_free()
	print()


func test_enemy_entity() -> void:
	print("--- Testing Enemy Entity ---")

	# Load enemy resource
	var enemy_resource: EnemyResource = load("res://resources/enemies/scrap_shambler.tres")
	assert(enemy_resource != null, "Enemy resource should load")

	# Create enemy instance
	var enemy = Enemy.new()
	add_child(enemy)

	# Initialize with wave 1
	enemy.initialize(enemy_resource, 1)
	assert(enemy.current_wave == 1, "Enemy should be on wave 1")
	assert(enemy.max_health > 0, "Enemy should have health")
	print("✓ Enemy initialized with resource (wave 1)")
	print(
		(
			"  Stats: hp=%.0f, spd=%.0f, dmg=%.0f, value=%d"
			% [enemy.max_health, enemy.move_speed, enemy.damage, enemy.scrap_value]
		)
	)

	# Test wave scaling
	var wave1_health = enemy.max_health
	enemy.initialize(enemy_resource, 5)
	assert(enemy.max_health > wave1_health, "Wave 5 should have more health than wave 1")
	print(
		(
			"✓ Enemy scales with wave number (wave 5 hp=%.0f > wave 1 hp=%.0f)"
			% [enemy.max_health, wave1_health]
		)
	)

	# Test damage
	var initial_health = enemy.current_health
	enemy.take_damage(20.0)
	assert(enemy.current_health == initial_health - 20.0, "Enemy should take 20 damage")
	print("✓ Enemy takes damage correctly")

	# Test health percentage
	var health_pct = enemy.get_health_percentage()
	assert(health_pct < 1.0, "Health percentage should be less than 100%")
	print("✓ Enemy health percentage: %.1f%%" % (health_pct * 100))

	# Test alive check
	assert(enemy.is_alive(), "Enemy should be alive")
	enemy.current_health = 0
	assert(!enemy.is_alive(), "Enemy should be dead at 0 health")
	print("✓ Enemy alive check works")

	# Cleanup
	enemy.queue_free()
	print()


func test_projectile_entity() -> void:
	print("--- Testing Projectile Entity ---")

	# Create projectile instance
	var projectile = Projectile.new()
	add_child(projectile)

	# Test activation
	var spawn_pos = Vector2(100, 100)
	var direction = Vector2.RIGHT
	projectile.activate(spawn_pos, direction, 25.0, 400.0, 500.0)

	assert(projectile.is_active, "Projectile should be active")
	assert(projectile.damage == 25.0, "Projectile should have 25 damage")
	assert(projectile.projectile_speed == 400.0, "Projectile should have 400 speed")
	assert(projectile.max_range == 500.0, "Projectile should have 500 range")
	print("✓ Projectile activates with correct parameters")

	# Test velocity
	assert(projectile.velocity.length() > 0, "Projectile should have velocity")
	assert(
		projectile.velocity.normalized() == direction, "Projectile should move in correct direction"
	)
	print("✓ Projectile velocity set correctly")

	# Test pierce
	projectile.set_pierce(2)
	assert(projectile.pierce_count == 2, "Projectile should have 2 pierce")
	print("✓ Projectile pierce set to 2")

	# Test remaining range
	var remaining = projectile.get_remaining_range()
	assert(remaining == 500.0, "Projectile should have full range remaining")
	print("✓ Projectile range tracking works")

	# Test deactivation
	projectile.deactivate()
	assert(!projectile.is_active, "Projectile should be inactive")
	print("✓ Projectile deactivates correctly")

	print()


func test_combat_integration() -> void:
	print("--- Testing Combat Integration ---")

	# Create player
	var player = Player.new()
	add_child(player)
	player.position = Vector2(100, 100)

	# Equip weapon
	player.equip_weapon(RUSTY_PISTOL)

	# Create enemy
	var enemy = Enemy.new()
	add_child(enemy)
	enemy.initialize(BASIC_ENEMY, 1)
	enemy.position = Vector2(200, 100)
	enemy.set_target(player)

	assert(enemy.target == player, "Enemy should target player")
	print("✓ Enemy targets player")

	# Test player weapon firing (use array wrapper for lambda capture)
	var projectile_fired = [false]
	player.weapon_fired.connect(func(_data): projectile_fired[0] = true)
	player.fire_weapon()
	assert(projectile_fired[0], "Player should fire weapon")
	print("✓ Player fires weapon")

	# Test enemy AI distance calculation
	var distance = enemy.global_position.distance_to(player.global_position)
	assert(distance == 100.0, "Distance should be 100 units")
	print("✓ Enemy calculates distance to player: %.0f units" % distance)

	# Test player armor reduction
	player.current_armor = 10.0
	var health_before = player.current_health
	player.take_damage(100.0)
	var damage_taken = health_before - player.current_health
	assert(damage_taken < 100.0, "Armor should reduce damage")
	print(
		(
			"✓ Player armor reduces damage: %.0f → %.0f (%.0f armor)"
			% [100.0, damage_taken, player.current_armor]
		)
	)

	# Test life steal (if implemented)
	player.apply_item_modifiers(VAMPIRIC_FANGS)
	assert(player.stat_modifiers.get("lifeSteal", 0) == 3, "Player should have life steal")
	print("✓ Player has life steal modifier: +%d" % player.stat_modifiers.get("lifeSteal", 0))

	# Cleanup
	player.queue_free()
	enemy.queue_free()

	print()


func test_resource_loading() -> void:
	print("--- Testing Resource Loading ---")

	# Test weapon loading
	print("✓ Weapon loaded: %s" % RUSTY_PISTOL.weapon_name)

	# Test enemy resource loading
	print("✓ Enemy resource loaded: %s" % BASIC_ENEMY.enemy_name)

	# Test item loading
	print("✓ Item loaded: %s" % HEALTH_BOOST.item_name)

	print()
