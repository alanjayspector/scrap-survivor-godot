extends CharacterBody2D
class_name Enemy
## Enemy entity for Scrap Survivor - Week 10 Combat Integration
##
## Integrates with EnemyService, DropSystem, and combat systems
## Handles AI pathfinding, health, and drop spawning

## Signals
signal died(enemy_id: String, drops: Dictionary, xp_reward: int)
signal damaged(damage: float)

## Enemy configuration
@export var enemy_id: String = ""
@export var enemy_type: String = "scrap_bot"

## Node references
@onready var health_bar: ProgressBar = $HealthBar if has_node("HealthBar") else null
@onready var visual: ColorRect = $Visual if has_node("Visual") else null

## Enemy stats (from EnemyService)
var current_hp: float = 50.0
var max_hp: float = 50.0
var speed: float = 80.0
var damage: float = 5.0
var xp_reward: int = 10
var enemy_type_def: Dictionary = {}  # Full enemy type definition

## AI state
var player: Player = null
var current_wave: int = 1

## Ranged attack state (Week 13 Phase 3)
var ranged_attack_cooldown: float = 0.0

## Visual feedback
var damage_flash_timer: float = 0.0
var damage_flash_duration: float = 0.1
var base_color: Color = Color(1, 0.3, 0.3, 1)

## Contact damage cooldown
var contact_damage_cooldown: float = 0.0
var contact_damage_rate: float = 1.0  # Deal damage once per second


func _ready() -> void:
	# Add to enemy group
	add_to_group("enemies")


func setup(id: String, type: String, wave: int) -> void:
	"""Initialize enemy with type and wave scaling"""
	enemy_id = id
	enemy_type = type
	current_wave = wave

	# Get enemy definition from EnemyService
	if not EnemyService.enemy_type_exists(type):
		GameLogger.error("Enemy: Invalid enemy type", {"type": type})
		return

	enemy_type_def = EnemyService.get_enemy_type(type)

	# Get wave-scaled HP
	var hp_multiplier = EnemyService.get_enemy_hp_multiplier(wave)
	max_hp = enemy_type_def.base_hp * hp_multiplier
	current_hp = max_hp

	# Set other stats
	speed = enemy_type_def.speed
	damage = enemy_type_def.base_damage
	xp_reward = enemy_type_def.xp_reward

	# Apply size multiplier for tank enemies (Week 13 Phase 3)
	var size_mult = enemy_type_def.get("size_multiplier", 1.0)
	scale = Vector2(size_mult, size_mult)

	# Update health bar
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

	# Set visual color (basic for now)
	base_color = _get_enemy_color(type)
	if visual:
		visual.color = base_color

	GameLogger.debug(
		"Enemy setup complete", {"id": enemy_id, "type": type, "wave": wave, "hp": max_hp}
	)


func _get_enemy_color(type: String) -> Color:
	"""Get color for enemy type"""
	# Week 13 Phase 3: Use dictionary lookup to avoid max-returns linting issue
	const ENEMY_COLORS = {
		"scrap_bot": Color(0.6, 0.4, 0.2, 1),  # Brown (melee)
		"mutant_rat": Color(0.4, 0.6, 0.3, 1),  # Green (melee)
		"rust_spider": Color(0.8, 0.3, 0.3, 1),  # Red (melee)
		"turret_drone": Color(0.9, 0.2, 0.2, 1),  # Bright red (ranged threat)
		"scrap_titan": Color(0.3, 0.3, 0.3, 1),  # Dark grey (tank)
		"feral_runner": Color(0.9, 0.9, 0.3, 1),  # Yellow (fast)
		"nano_swarm": Color(0.4, 0.8, 0.9, 1)  # Cyan (swarm)
	}

	return ENEMY_COLORS.get(type, Color(1, 0.3, 0.3, 1))  # Default red if not found


func _physics_process(delta: float) -> void:
	# Update damage flash
	if damage_flash_timer > 0:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0 and visual:
			visual.color = base_color

	# Update contact damage cooldown
	if contact_damage_cooldown > 0:
		contact_damage_cooldown -= delta

	# Update ranged attack cooldown (Week 13 Phase 3)
	if ranged_attack_cooldown > 0:
		ranged_attack_cooldown -= delta

	# Find player if needed
	if not player:
		player = get_tree().get_first_node_in_group("player") as Player
		return

	# AI: Behavior-based movement (Week 13 Phase 3)
	if player and player.is_alive():
		var distance_to_player = global_position.distance_to(player.global_position)
		var behavior = enemy_type_def.get("behavior", "melee")

		# Ranged behavior: stop at distance and shoot
		if behavior == "ranged":
			var attack_distance = enemy_type_def.get("ranged_attack_distance", 400)

			if distance_to_player <= attack_distance:
				# In range: stop moving, shoot at player
				velocity = Vector2.ZERO
				_ranged_attack(player)
			else:
				# Out of range: move toward player
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				move_and_slide()

				# Flip visual based on direction
				if visual and direction.x != 0:
					visual.scale.x = -1 if direction.x < 0 else 1

		# Melee/Tank/Fast/Swarm behavior: move toward player (default)
		else:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()

			# Flip visual based on direction
			if visual and direction.x != 0:
				visual.scale.x = -1 if direction.x < 0 else 1

			# Check for contact damage (distance-based, more reliable than slide collisions)
			if contact_damage_cooldown <= 0:
				var contact_threshold = 40.0  # Sum of collision radii (enemy 20px + player ~20px)

				if distance_to_player <= contact_threshold:
					# Deal contact damage to player
					player.take_damage(damage, global_position)
					contact_damage_cooldown = contact_damage_rate
					GameLogger.debug(
						"Enemy dealt contact damage",
						{"id": enemy_id, "damage": damage, "distance": distance_to_player}
					)


func _ranged_attack(target: Player) -> void:
	"""Fire projectile at player (Week 13 Phase 3)"""
	# Check cooldown
	if ranged_attack_cooldown > 0:
		return

	# Reset cooldown
	var attack_cooldown = enemy_type_def.get("attack_cooldown", 2.0)
	ranged_attack_cooldown = attack_cooldown

	# Spawn enemy projectile
	var projectile_scene = load("res://scenes/entities/projectile.tscn")
	if not projectile_scene:
		GameLogger.error("Enemy: Failed to load projectile scene")
		return

	var projectile = projectile_scene.instantiate()

	# Calculate direction to player
	var direction = (target.global_position - global_position).normalized()
	var projectile_speed = enemy_type_def.get("projectile_speed", 300)
	var projectile_damage = damage

	# Configure projectile (enemy projectile)
	# activate(spawn_position, direction, proj_damage, proj_speed, proj_range,
	#          proj_splash_damage, proj_splash_radius, proj_color, trail_color,
	#          trail_width, proj_shape, proj_shape_size, enemy_projectile)
	projectile.activate(
		global_position,  # spawn_position
		direction,  # direction
		projectile_damage,  # proj_damage
		projectile_speed,  # proj_speed
		600,  # proj_range
		0.0,  # proj_splash_damage
		0.0,  # proj_splash_radius
		Color(0.9, 0.2, 0.2),  # proj_color (red for enemy projectiles)
		Color(0.9, 0.2, 0.2),  # trail_color
		2.0,  # trail_width
		0,  # proj_shape (circle)
		Vector2(6, 6),  # proj_shape_size (smaller than player projectiles)
		true  # enemy_projectile
	)

	# Add to scene (get parent node for projectiles)
	var projectiles_container = get_tree().get_first_node_in_group("projectiles")
	if projectiles_container:
		projectiles_container.add_child(projectile)
	else:
		# Fallback: add to parent
		get_parent().add_child(projectile)

	GameLogger.debug(
		"Enemy fired projectile",
		{"id": enemy_id, "type": enemy_type, "direction": direction, "damage": projectile_damage}
	)


func take_damage(dmg: float) -> bool:
	"""Take damage and return true if killed"""
	current_hp -= dmg
	current_hp = max(0, current_hp)

	# Update health bar
	if health_bar:
		health_bar.value = current_hp

	# Visual feedback (flash white)
	_flash_damage()

	# Emit damage signal
	damaged.emit(dmg)

	GameLogger.debug("Enemy took damage", {"id": enemy_id, "damage": dmg, "hp": current_hp})

	# Check for death
	if current_hp <= 0:
		die()
		return true

	return false


func _flash_damage() -> void:
	"""Visual feedback for taking damage"""
	damage_flash_timer = damage_flash_duration

	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color.WHITE, 0.1)
		tween.tween_property(visual, "color", base_color, 0.1)


func die() -> void:
	"""Handle enemy death"""
	print("[Enemy] die() called for ", enemy_type, " at position ", global_position)
	GameLogger.info(
		"Enemy died - START", {"id": enemy_id, "type": enemy_type, "position": global_position}
	)

	# Generate drops using DropSystem
	var drops = {}
	if DropSystem:
		print("[Enemy] DropSystem found, generating drops...")
		# Get player scavenging stat for drop calculation
		var player_scavenging = 0
		if player:
			player_scavenging = player.get_stat("scavenging")

		# Generate drops
		print(
			"[Enemy] Calling DropSystem.generate_drops for ",
			enemy_type,
			" with scavenging: ",
			player_scavenging
		)
		drops = DropSystem.generate_drops(enemy_type, player_scavenging)
		print("[Enemy] Drops generated: ", drops)

		# Spawn drop pickups at death location
		if not drops.is_empty():
			print("[Enemy] Spawning drop pickups at ", global_position)
			DropSystem.spawn_drop_pickups(drops, global_position)
			print("[Enemy] Drop pickups spawned")
		else:
			print("[Enemy] No drops to spawn (empty drops dict)")

		# Award XP to player
		if player:
			print("[Enemy] Awarding XP to player ", player.character_id)
			DropSystem.award_xp_for_kill(player.character_id, enemy_type)

	# Log completion BEFORE animation
	print("[Enemy] Enemy death complete: ", enemy_type, " drops: ", drops)
	GameLogger.info("Enemy died - COMPLETE", {"id": enemy_id, "type": enemy_type, "drops": drops})

	# Emit death signal with XP reward
	died.emit(enemy_id, drops, xp_reward)

	# Death animation (fade out + scale down)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.3)
	tween.tween_callback(queue_free)


func get_health_percentage() -> float:
	"""Get current health as percentage (0.0 to 1.0)"""
	if max_hp <= 0:
		return 0.0
	return current_hp / max_hp


func is_alive() -> bool:
	"""Check if enemy is alive"""
	return current_hp > 0
