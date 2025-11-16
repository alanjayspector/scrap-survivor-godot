extends GutTest
class_name SceneIntegrationTest
## Scene Integration Tests - Week 10 Phase 1
##
## USER STORY: "As a developer, I want Player and Enemy entities to integrate
## correctly with services so that game mechanics work reliably"
##
## Tests for Player, Enemy, and scene entity integration with services

var player: Player
var enemy: Enemy
var test_character_id: String = ""


func before_each() -> void:
	"""Set up test fixtures before each test"""
	# Create test character (returns generated ID)
	test_character_id = CharacterService.create_character("TestChar", "scavenger")
	assert_not_null(test_character_id, "Test character ID should be returned")
	assert_false(test_character_id.is_empty(), "Test character ID should not be empty")
	CharacterService.set_active_character(test_character_id)


func after_each() -> void:
	"""Clean up after each test"""
	# Clean up player
	if player and is_instance_valid(player):
		player.queue_free()
		player = null

	# Clean up enemy
	if enemy and is_instance_valid(enemy):
		enemy.queue_free()
		enemy = null

	# Delete test character
	CharacterService.delete_character(test_character_id)


## Player Entity Tests


func test_player_entity_loads_character_stats() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)

	# Act
	await wait_physics_frames(5)  # Wait for _ready() async operations to complete

	# Assert
	assert_false(player.stats.is_empty(), "Player stats should be loaded")
	assert_gt(player.stats.get("max_hp", 0), 0, "Player should have max_hp")
	assert_gt(player.stats.get("speed", 0), 0, "Player should have speed")
	assert_eq(player.current_hp, player.stats.get("max_hp"), "Player should start at full health")


func test_player_movement_uses_speed_stat() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	var expected_speed = player.stats.get("speed", 200)

	# Act - Simulate input direction
	Input.action_press("move_right")
	await wait_frames(1)
	# Run multiple physics frames to allow velocity to ramp up with lerp smoothing
	for i in range(20):
		player._physics_process(1.0 / 60.0)
	Input.action_release("move_right")

	# Assert
	# Velocity should approach speed stat with lerp smoothing (allow 5% tolerance)
	var tolerance = expected_speed * 0.05
	assert_almost_eq(
		player.velocity.length(),
		expected_speed,
		tolerance,
		"Player velocity should match speed stat"
	)


func test_player_take_damage_applies_armor() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	var initial_hp = player.current_hp
	var armor = player.stats.get("armor", 0)
	var raw_damage = 20.0

	# Act
	player.take_damage(raw_damage)

	# Assert
	var expected_multiplier = 1.0 / (1.0 + armor * 0.01)
	var expected_damage = raw_damage * expected_multiplier
	expected_damage = max(expected_damage, raw_damage * 0.2)  # Minimum 20%

	var actual_damage = initial_hp - player.current_hp
	assert_almost_eq(actual_damage, expected_damage, 0.5, "Damage should be reduced by armor")


func test_player_death_triggers_signal() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	watch_signals(player)

	# Act
	player.current_hp = 1.0
	player.take_damage(100.0)  # Lethal damage

	# Assert
	assert_signal_emitted(player, "died", "Player should emit died signal")
	assert_eq(player.current_hp, 0.0, "Player HP should be 0")


func test_player_heal_respects_max_hp() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	var max_hp = player.stats.get("max_hp", 100)
	player.current_hp = max_hp / 2.0

	# Act
	player.heal(max_hp * 2.0)  # Heal more than max

	# Assert
	assert_eq(player.current_hp, max_hp, "Player HP should not exceed max_hp")


func test_player_equips_weapon() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	# Act
	var success = player.equip_weapon("rusty_blade")

	# Assert
	assert_true(success, "Player should equip weapon successfully")
	assert_eq(player.equipped_weapon_id, "rusty_blade", "Player should have weapon equipped")


## Enemy Entity Tests


func test_enemy_entity_scales_with_wave() -> void:
	# Arrange
	enemy = Enemy.new()
	add_child_autofree(enemy)

	var enemy_type = "scrap_bot"
	var wave = 5

	# Act
	enemy.setup("test_enemy_1", enemy_type, wave)

	# Assert
	var base_hp = EnemyService.ENEMY_TYPES[enemy_type].base_hp
	var hp_multiplier = EnemyService.get_enemy_hp_multiplier(wave)
	var expected_hp = base_hp * hp_multiplier

	assert_eq(enemy.max_hp, expected_hp, "Enemy HP should scale with wave")
	assert_eq(enemy.current_hp, expected_hp, "Enemy should start at full health")


func test_enemy_moves_toward_player() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	player.add_to_group("player")
	add_child_autofree(player)
	await wait_physics_frames(5)

	enemy = Enemy.new()
	add_child_autofree(enemy)  # Add to tree FIRST (data.tree gets initialized)
	enemy.setup("test_enemy_2", "scrap_bot", 1)  # Then initialize

	player.global_position = Vector2(100, 0)
	enemy.global_position = Vector2(0, 0)

	# Act
	await wait_physics_frames(3)  # Let enemy find player
	enemy._physics_process(0.1)

	# Assert
	# Enemy velocity should point toward player
	var direction_to_player = (player.global_position - enemy.global_position).normalized()
	var enemy_direction = enemy.velocity.normalized()

	assert_almost_eq(
		enemy_direction.x, direction_to_player.x, 0.1, "Enemy should move toward player X"
	)
	assert_almost_eq(
		enemy_direction.y, direction_to_player.y, 0.1, "Enemy should move toward player Y"
	)


func test_enemy_death_emits_signal() -> void:
	# Arrange
	enemy = Enemy.new()
	add_child_autofree(enemy)  # Add to tree FIRST
	enemy.setup("test_enemy_3", "scrap_bot", 1)  # Then initialize

	watch_signals(enemy)

	# Act
	enemy.current_hp = 1.0
	var killed = enemy.take_damage(100.0)

	# Assert
	assert_true(killed, "Enemy should be killed")
	assert_signal_emitted(enemy, "died", "Enemy should emit died signal")


func test_enemy_updates_health_bar_on_damage() -> void:
	# Arrange
	enemy = Enemy.new()

	# Add health bar BEFORE setup() so enemy can find it
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	enemy.add_child(health_bar)

	add_child_autofree(enemy)

	# Now setup enemy (it will find and initialize the health bar)
	enemy.setup("test_enemy_4", "rust_spider", 1)

	var initial_hp = enemy.current_hp

	# Act
	enemy.take_damage(20.0)

	# Assert
	assert_not_null(enemy.health_bar, "Enemy should have health bar")
	if enemy.health_bar:
		assert_eq(enemy.health_bar.value, enemy.current_hp, "Health bar should match current HP")
	assert_lt(enemy.current_hp, initial_hp, "Enemy HP should decrease")


func test_enemy_has_correct_speed_from_type() -> void:
	# Arrange
	enemy = Enemy.new()
	add_child_autofree(enemy)

	var enemy_type = "mutant_rat"
	var expected_speed = EnemyService.ENEMY_TYPES[enemy_type].speed

	# Act
	enemy.setup("test_enemy_5", enemy_type, 1)

	# Assert
	assert_eq(enemy.speed, expected_speed, "Enemy speed should match type definition")


## Integration Tests


func test_player_damage_triggers_health_signal() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	watch_signals(player)

	# Act
	player.take_damage(10.0)

	# Assert
	assert_signal_emitted(player, "player_damaged", "Player should emit player_damaged signal")
	assert_signal_emitted(player, "health_changed", "Player should emit health_changed signal")


func test_enemy_type_colors_differ() -> void:
	# Arrange
	var enemy1 = Enemy.new()
	var enemy2 = Enemy.new()
	var enemy3 = Enemy.new()

	add_child_autofree(enemy1)
	add_child_autofree(enemy2)
	add_child_autofree(enemy3)

	# Act
	enemy1.setup("e1", "scrap_bot", 1)
	enemy2.setup("e2", "mutant_rat", 1)
	enemy3.setup("e3", "rust_spider", 1)

	# Assert
	assert_ne(
		enemy1.base_color, enemy2.base_color, "Different enemy types should have different colors"
	)
	assert_ne(
		enemy2.base_color, enemy3.base_color, "Different enemy types should have different colors"
	)


func test_player_level_up_reloads_stats() -> void:
	# Arrange
	player = Player.new()
	player.character_id = test_character_id
	add_child_autofree(player)
	await wait_physics_frames(5)

	var initial_max_hp = player.stats.get("max_hp", 100)

	# Act - Trigger level up by adding enough XP
	var character = CharacterService.get_character(test_character_id)
	var level = character.get("level", 1)
	var xp_needed = level * CharacterService.XP_PER_LEVEL
	CharacterService.add_experience(test_character_id, xp_needed)

	await wait_physics_frames(5)  # Let signal propagate

	# Assert
	assert_gt(
		player.stats.get("max_hp", 0),
		initial_max_hp,
		"Player max_hp should increase after level up"
	)
	assert_eq(
		player.current_hp, player.stats.get("max_hp"), "Player should be healed to full on level up"
	)


func test_enemy_get_health_percentage() -> void:
	# Arrange
	enemy = Enemy.new()
	add_child_autofree(enemy)  # Add to tree FIRST
	enemy.setup("test_enemy_6", "scrap_bot", 1)  # Then initialize

	# Act & Assert - Full health
	assert_eq(enemy.get_health_percentage(), 1.0, "Enemy at full health should be 100%")

	# Damage to half health
	enemy.current_hp = enemy.max_hp / 2.0
	assert_almost_eq(enemy.get_health_percentage(), 0.5, 0.01, "Enemy at half health should be 50%")

	# Zero health
	enemy.current_hp = 0.0
	assert_eq(enemy.get_health_percentage(), 0.0, "Enemy at zero health should be 0%")
