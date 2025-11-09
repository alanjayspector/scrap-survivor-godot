class_name Projectile
extends Area2D
## Projectile entity for Scrap Survivor
##
## Handles projectile movement, collision, and damage dealing.
## Supports object pooling with activate/deactivate pattern.

## Emitted when projectile hits an enemy
signal enemy_hit(enemy: Enemy, damage: float)

## Emitted when projectile is destroyed
signal destroyed

## Projectile properties
var velocity: Vector2 = Vector2.ZERO
var damage: float = 10.0
var max_range: float = 500.0
var projectile_speed: float = 400.0

## Tracking
var start_position: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var is_active: bool = false

## Visual properties
@export var projectile_color: Color = Color.YELLOW
@export var projectile_size: float = 8.0

## Piercing properties
@export var pierce_count: int = 0  # 0 = no pierce, 1 = pierce once, etc.
var enemies_hit: Array[Enemy] = []

## Collision layers
const ENEMY_LAYER = 2  # Assuming enemies are on layer 2


func _ready() -> void:
	# Set up collision
	collision_layer = 0  # Projectiles don't collide with each other
	collision_mask = 1 << (ENEMY_LAYER - 1)  # Only collide with enemies

	# Connect area entered signal
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	# Create visual representation if none exists
	if get_child_count() == 0:
		create_default_visual()


func create_default_visual() -> void:
	"""Create a simple circle visual for the projectile"""
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = projectile_size / 2
	collision_shape.shape = circle
	add_child(collision_shape)

	# Add visual circle
	var visual = ColorRect.new()
	visual.color = projectile_color
	visual.size = Vector2(projectile_size, projectile_size)
	visual.position = Vector2(-projectile_size / 2, -projectile_size / 2)
	add_child(visual)


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	# Move projectile
	var movement = velocity * delta
	position += movement

	# Track distance
	distance_traveled += movement.length()

	# Check if exceeded range
	if distance_traveled >= max_range:
		deactivate()


func activate(
	spawn_position: Vector2,
	direction: Vector2,
	proj_damage: float,
	proj_speed: float,
	proj_range: float
) -> void:
	"""Activate projectile with given parameters"""
	# Set properties
	global_position = spawn_position
	start_position = spawn_position
	velocity = direction.normalized() * proj_speed
	damage = proj_damage
	projectile_speed = proj_speed
	max_range = proj_range

	# Reset tracking
	distance_traveled = 0.0
	enemies_hit.clear()

	# Set rotation to face direction
	rotation = direction.angle()

	# Activate
	is_active = true
	visible = true
	set_physics_process(true)
	monitoring = true


func deactivate() -> void:
	"""Deactivate projectile (for object pooling)"""
	is_active = false
	visible = false
	set_physics_process(false)
	monitoring = false

	# Emit destroyed signal
	destroyed.emit()

	# For now, just queue free (object pooling can be added later)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with areas (if enemies use Area2D)"""
	if not is_active:
		return

	# Check if the area's owner is an enemy
	var enemy = area.owner as Enemy
	if enemy and enemy.is_alive():
		hit_enemy(enemy)


func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with bodies (if enemies use CharacterBody2D)"""
	if not is_active:
		return

	# Check if it's an enemy
	var enemy = body as Enemy
	if enemy and enemy.is_alive():
		hit_enemy(enemy)


func hit_enemy(enemy: Enemy) -> void:
	"""Deal damage to an enemy"""
	# Check if already hit this enemy (for pierce)
	if enemy in enemies_hit:
		return

	# Deal damage
	enemy.take_damage(damage, global_position)
	enemies_hit.append(enemy)

	# Emit signal
	enemy_hit.emit(enemy, damage)

	# Check pierce
	if enemies_hit.size() > pierce_count:
		# Exceeded pierce count, deactivate
		deactivate()
	# Otherwise, continue flying (piercing)


func set_pierce(pierce_amount: int) -> void:
	"""Set how many enemies this projectile can pierce"""
	pierce_count = pierce_amount


func set_visual_color(color: Color) -> void:
	"""Set the visual color of the projectile"""
	projectile_color = color

	# Update existing visual if present
	for child in get_children():
		if child is ColorRect:
			child.color = color
		elif child is Sprite2D:
			child.modulate = color


func get_remaining_range() -> float:
	"""Get remaining range before deactivation"""
	return max(0, max_range - distance_traveled)


func _to_string() -> String:
	return (
		"Projectile(dmg=%.0f, spd=%.0f, range=%.0f/%.0f)"
		% [damage, projectile_speed, distance_traveled, max_range]
	)
