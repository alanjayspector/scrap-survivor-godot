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

## Explosive properties
@export var splash_damage: float = 0.0  # Damage dealt to enemies in splash radius
@export var splash_radius: float = 0.0  # Radius for splash damage (0 = no splash)

## Collision layers
const ENEMY_LAYER = 2  # Assuming enemies are on layer 2

## Trail
var trail: Line2D = null
const TRAIL_MAX_LENGTH: int = 15  # Maximum number of trail points


func _ready() -> void:
	# Get trail node reference
	trail = get_node_or_null("Trail")
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

	# Update trail before moving
	if trail:
		# Add current position to trail (in local coordinates)
		trail.add_point(Vector2.ZERO)

		# Limit trail length
		if trail.get_point_count() > TRAIL_MAX_LENGTH:
			trail.remove_point(0)

		# Shift all points back (since we're moving forward)
		for i in range(trail.get_point_count() - 1):
			var point = trail.get_point_position(i)
			trail.set_point_position(i, point - velocity * delta)

	# Move projectile
	var movement = velocity * delta
	position += movement

	# Track distance
	distance_traveled += movement.length()

	# Check if exceeded range
	if distance_traveled >= max_range:
		# Trigger explosion for explosive projectiles before deactivating
		if splash_radius > 0.0:
			_explode()
		deactivate()


func activate(
	spawn_position: Vector2,
	direction: Vector2,
	proj_damage: float,
	proj_speed: float,
	proj_range: float,
	proj_splash_damage: float = 0.0,
	proj_splash_radius: float = 0.0,
	proj_color: Color = Color.WHITE,
	trail_color: Color = Color.WHITE,
	trail_width: float = 2.0
) -> void:
	"""Activate projectile with given parameters"""
	# Set properties
	global_position = spawn_position
	start_position = spawn_position
	velocity = direction.normalized() * proj_speed
	damage = proj_damage
	projectile_speed = proj_speed
	max_range = proj_range
	splash_damage = proj_splash_damage
	splash_radius = proj_splash_radius

	# Apply visual properties (Phase 1.5)
	modulate = proj_color  # Color the entire projectile
	projectile_color = proj_color

	# Reset tracking
	distance_traveled = 0.0
	enemies_hit.clear()

	# Clear and configure trail
	if trail:
		trail.clear_points()
		trail.default_color = trail_color
		trail.width = trail_width

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

	# Clear trail
	if trail:
		trail.clear_points()

	# Emit destroyed signal
	destroyed.emit()

	# For now, just queue free (object pooling can be added later)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with areas (if enemies use Area2D)"""
	print("[Projectile] _on_area_entered called, area: ", area)
	if not is_active:
		print("[Projectile] Projectile not active, ignoring")
		return

	# Check if the area's owner is an enemy
	var enemy = area.owner as Enemy
	print("[Projectile] Area owner as Enemy: ", enemy)
	if enemy and enemy.is_alive():
		print("[Projectile] Hitting enemy: ", enemy.enemy_id)
		hit_enemy(enemy)


func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with bodies (if enemies use CharacterBody2D)"""
	print("[Projectile] _on_body_entered called, body: ", body)
	if not is_active:
		print("[Projectile] Projectile not active, ignoring")
		return

	# Check if it's an enemy
	var enemy = body as Enemy
	print("[Projectile] Body as Enemy: ", enemy)
	if enemy and enemy.is_alive():
		print("[Projectile] Hitting enemy: ", enemy.enemy_id)
		hit_enemy(enemy)


func hit_enemy(enemy: Enemy) -> void:
	"""Deal damage to an enemy"""
	print("[Projectile] hit_enemy called for: ", enemy.enemy_id, " damage: ", damage)
	# Check if already hit this enemy (for pierce)
	if enemy in enemies_hit:
		print("[Projectile] Already hit this enemy, skipping")
		return

	# Deal damage
	print("[Projectile] Calling enemy.take_damage(", damage, ")")
	var killed = enemy.take_damage(damage)
	print("[Projectile] Enemy killed: ", killed)
	enemies_hit.append(enemy)

	# Create impact VFX (Phase 1.5 P1)
	if splash_radius <= 0.0:  # Don't create impact for explosives (they have their own effect)
		_create_impact_visual(global_position)

	# Emit signal
	enemy_hit.emit(enemy, damage)

	# Check pierce
	if enemies_hit.size() > pierce_count:
		# Exceeded pierce count, trigger explosion if applicable, then deactivate
		print("[Projectile] Pierce count exceeded, deactivating")
		if splash_radius > 0.0:
			_explode()
		deactivate()
	# Otherwise, continue flying (piercing)


func _explode() -> void:
	"""Handle explosion for explosive projectiles"""
	print("[Projectile] Exploding at position: ", global_position, " radius: ", splash_radius)

	# Get all enemies in splash radius
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = splash_radius
	query.shape = circle_shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 1 << (ENEMY_LAYER - 1)  # Only check enemy layer

	var results = space_state.intersect_shape(query)
	print("[Projectile] Explosion found ", results.size(), " colliders")

	# Deal splash damage to all enemies in radius
	for result in results:
		var collider = result.collider
		# Try to get enemy from collider or its owner
		var enemy = collider as Enemy
		if not enemy and collider.owner:
			enemy = collider.owner as Enemy

		if enemy and enemy.is_alive():
			print(
				"[Projectile] Splash damage to enemy: ", enemy.enemy_id, " damage: ", splash_damage
			)
			enemy.take_damage(splash_damage)
			enemy_hit.emit(enemy, splash_damage)

	# Create visual explosion effect
	_create_explosion_visual()


func _create_explosion_visual() -> void:
	"""Create particle burst explosion visual (Phase 1.5 P1)"""
	var particles = CPUParticles2D.new()
	particles.global_position = global_position
	particles.z_index = 1

	# Emission settings
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 24  # More particles for larger explosion
	particles.lifetime = 0.5

	# Particle appearance - use rocket color
	particles.color = Color(1.0, 0.4, 0.0)  # Orange/red explosion
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0

	# Particle physics - radial burst
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 50)
	particles.linear_accel_min = -60.0
	particles.linear_accel_max = -100.0

	# Fade out
	particles.scale_amount_curve = _create_fade_curve()

	# Add screen shake for explosion
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("trigger_shake"):
		camera.trigger_shake(8.0)  # Extra shake for explosion impact

	# Add to parent scene
	var parent = get_parent()
	if parent:
		parent.add_child(particles)

		# Auto-cleanup after lifetime
		await get_tree().create_timer(particles.lifetime + 0.1).timeout
		if is_instance_valid(particles):
			particles.queue_free()


func _create_impact_visual(impact_position: Vector2) -> void:
	"""Create bullet impact particle burst (Phase 1.5 P1)"""
	var particles = CPUParticles2D.new()
	particles.global_position = impact_position
	particles.z_index = 1

	# Emission settings
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 8
	particles.lifetime = 0.3

	# Particle appearance
	particles.color = projectile_color
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0

	# Particle physics
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2(0, 100)
	particles.linear_accel_min = -20.0
	particles.linear_accel_max = -40.0

	# Fade out
	particles.scale_amount_curve = _create_fade_curve()

	# Add to parent scene
	var parent = get_parent()
	if parent:
		parent.add_child(particles)

		# Auto-cleanup after lifetime
		await get_tree().create_timer(particles.lifetime + 0.1).timeout
		if is_instance_valid(particles):
			particles.queue_free()


func _create_fade_curve() -> Curve:
	"""Create a curve for particle fade-out"""
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve


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
