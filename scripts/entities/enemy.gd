extends CharacterBody2D
class_name Enemy
## Enemy entity for Scrap Survivor - Week 10 Combat Integration
##
## Integrates with EnemyService, DropSystem, and combat systems
## Handles AI pathfinding, health, and drop spawning

## Signals
signal died(enemy_id: String, drops: Dictionary)
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

## AI state
var player: Player = null
var current_wave: int = 1

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

	var enemy_def = EnemyService.get_enemy_type(type)

	# Get wave-scaled HP
	var hp_multiplier = EnemyService.get_enemy_hp_multiplier(wave)
	max_hp = enemy_def.base_hp * hp_multiplier
	current_hp = max_hp

	# Set other stats
	speed = enemy_def.speed
	damage = enemy_def.base_damage
	xp_reward = enemy_def.xp_reward

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
	match type:
		"scrap_bot":
			return Color(0.6, 0.4, 0.2, 1)  # Brown
		"mutant_rat":
			return Color(0.4, 0.6, 0.3, 1)  # Green
		"rust_spider":
			return Color(0.8, 0.3, 0.3, 1)  # Red
		_:
			return Color(1, 0.3, 0.3, 1)  # Default red


func _physics_process(delta: float) -> void:
	# Update damage flash
	if damage_flash_timer > 0:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0 and visual:
			visual.color = base_color

	# Update contact damage cooldown
	if contact_damage_cooldown > 0:
		contact_damage_cooldown -= delta

	# Find player if needed
	if not player:
		player = get_tree().get_first_node_in_group("player") as Player
		return

	# AI: Move toward player
	if player and player.is_alive():
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Flip visual based on direction
		if visual and direction.x != 0:
			visual.scale.x = -1 if direction.x < 0 else 1

		# Check for collision with player (contact damage)
		if contact_damage_cooldown <= 0:
			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider == player:
					# Deal contact damage to player
					player.take_damage(damage, global_position)
					contact_damage_cooldown = contact_damage_rate
					GameLogger.debug(
						"Enemy dealt contact damage", {"id": enemy_id, "damage": damage}
					)
					break  # Only deal damage once per cooldown period


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
	# Generate drops using DropSystem
	var drops = {}
	if DropSystem:
		# Get player scavenging stat for drop calculation
		var player_scavenging = 0
		if player:
			player_scavenging = player.get_stat("scavenging")

		# Generate drops
		drops = DropSystem.generate_drops(enemy_type, player_scavenging)

		# Spawn drop pickups at death location
		if not drops.is_empty():
			DropSystem.spawn_drop_pickups(drops, global_position)

		# Award XP to player
		if player:
			DropSystem.award_xp_for_kill(player.character_id, enemy_type)

	# Emit death signal
	died.emit(enemy_id, drops)

	# Death animation (fade out + scale down)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.3)
	tween.tween_callback(queue_free)

	GameLogger.info("Enemy died", {"id": enemy_id, "type": enemy_type, "drops": drops})


func get_health_percentage() -> float:
	"""Get current health as percentage (0.0 to 1.0)"""
	if max_hp <= 0:
		return 0.0
	return current_hp / max_hp


func is_alive() -> bool:
	"""Check if enemy is alive"""
	return current_hp > 0
