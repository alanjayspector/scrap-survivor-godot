class_name Enemy
extends CharacterBody2D
## Enemy entity for Scrap Survivor
##
## Handles enemy behavior, health, movement, and wave scaling.
## Integrates with EnemyResource for data-driven enemy types.

## Emitted when enemy takes damage
signal damage_taken(amount: float)

## Emitted when enemy dies
signal died(enemy: Enemy, scrap_value: int)

## Emitted when enemy hits player
signal player_hit(damage: float)

## Enemy resource defining base stats
@export var enemy_resource: EnemyResource

## Current wave number (affects scaling)
var current_wave: int = 1

## Current stats (scaled by wave)
var max_health: float = 100.0
var current_health: float = 100.0
var move_speed: float = 100.0
var damage: float = 10.0
var scrap_value: int = 5

## Combat properties
@export_group("Combat")
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 50.0
@export var knockback_force: float = 200.0

var attack_timer: float = 0.0
var is_attacking: bool = false

## AI properties
var target: Node2D = null
var chase_distance: float = 800.0
var stop_distance: float = 40.0

## Visual properties
var base_color: Color = Color.WHITE
var damage_flash_duration: float = 0.1
var damage_flash_timer: float = 0.0


func _ready() -> void:
	# Initialize with resource if available
	if enemy_resource:
		initialize_from_resource(enemy_resource, current_wave)


func initialize(resource: EnemyResource, wave: int) -> void:
	"""Initialize enemy with resource and wave number"""
	enemy_resource = resource
	current_wave = wave
	initialize_from_resource(resource, wave)


func initialize_from_resource(resource: EnemyResource, wave: int) -> void:
	"""Set up enemy stats from resource with wave scaling"""
	if not resource:
		push_error("Enemy: No resource provided")
		return

	# Get scaled stats for current wave
	var scaled_stats = resource.get_scaled_stats(wave)

	max_health = scaled_stats.hp
	current_health = max_health
	move_speed = scaled_stats.speed
	damage = scaled_stats.damage
	scrap_value = scaled_stats.value

	# Set visual properties
	base_color = resource.color

	# Apply color to sprite/visual (assuming a ColorRect or Sprite2D child)
	apply_visual_color()


func apply_visual_color() -> void:
	"""Apply color to visual representation"""
	# Look for ColorRect or Sprite2D child
	for child in get_children():
		if child is ColorRect:
			child.color = base_color
		elif child is Sprite2D:
			child.modulate = base_color


func _physics_process(delta: float) -> void:
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta

	# Update damage flash
	if damage_flash_timer > 0:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0:
			reset_visual_color()

	# AI behavior
	if target:
		handle_ai_behavior(delta)

	# Move with physics
	move_and_slide()


func handle_ai_behavior(_delta: float) -> void:
	"""Handle enemy AI - chase and attack player"""
	if not target:
		return

	var distance_to_target = global_position.distance_to(target.global_position)

	# Check if in attack range
	if distance_to_target <= attack_range:
		# Stop moving and attack
		velocity = Vector2.ZERO
		attempt_attack()
	elif distance_to_target <= chase_distance:
		# Chase player
		var direction = (target.global_position - global_position).normalized()

		# Stop at minimum distance
		if distance_to_target > stop_distance:
			velocity = direction * move_speed
		else:
			velocity = Vector2.ZERO

		# Face target
		rotation = direction.angle()
	else:
		# Too far, stop moving
		velocity = Vector2.ZERO


func attempt_attack() -> void:
	"""Attempt to attack the target"""
	if attack_timer > 0 or is_attacking:
		return

	if not target or not target.has_method("take_damage"):
		return

	# Start attack
	is_attacking = true
	attack_timer = attack_cooldown

	# Deal damage to target
	target.take_damage(damage, global_position)
	player_hit.emit(damage)

	# End attack (can be delayed for animation)
	is_attacking = false


func set_target(new_target: Node2D) -> void:
	"""Set the target to chase (usually the player)"""
	target = new_target


func take_damage(amount: float, source_position: Vector2 = Vector2.ZERO) -> void:
	"""Take damage and handle death"""
	current_health -= amount
	current_health = max(0, current_health)

	# Emit damage signal
	damage_taken.emit(amount)

	# Visual feedback
	flash_damage()

	# Apply knockback
	if source_position != Vector2.ZERO:
		apply_knockback(source_position)

	# Check for death
	if current_health <= 0:
		die()


func apply_knockback(source_position: Vector2) -> void:
	"""Apply knockback away from damage source"""
	var knockback_direction = (global_position - source_position).normalized()
	velocity = knockback_direction * knockback_force


func flash_damage() -> void:
	"""Flash white when taking damage"""
	damage_flash_timer = damage_flash_duration

	# Flash white
	for child in get_children():
		if child is ColorRect:
			child.color = Color.WHITE
		elif child is Sprite2D:
			child.modulate = Color.WHITE


func reset_visual_color() -> void:
	"""Reset to base color after damage flash"""
	for child in get_children():
		if child is ColorRect:
			child.color = base_color
		elif child is Sprite2D:
			child.modulate = base_color


func die() -> void:
	"""Handle enemy death"""
	# Emit death signal with scrap value
	died.emit(self, scrap_value)

	# Disable physics
	set_physics_process(false)

	# Visual feedback (fade out, particle effect, etc.)
	# Can be handled by game manager or animation

	# Queue for removal
	queue_free()


func get_health_percentage() -> float:
	"""Get current health as percentage (0.0 to 1.0)"""
	if max_health <= 0:
		return 0.0
	return current_health / max_health


func is_alive() -> bool:
	"""Check if enemy is alive"""
	return current_health > 0


func _to_string() -> String:
	var enemy_name = enemy_resource.enemy_name if enemy_resource else "Unknown"
	return (
		"Enemy(%s, wave=%d, hp=%.0f/%.0f, dmg=%.0f)"
		% [enemy_name, current_wave, current_health, max_health, damage]
	)
