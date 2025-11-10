extends Node2D
## Aura visual with GPUParticles2D
## Week 7: Basic ColorRect prototype
## Week 8: Upgraded to GPUParticles2D with particle effects

var aura_type: String = "collect"
var radius: float = 100.0
var color: Color = Color(1, 1, 0, 0.3)

# References to child nodes
var _particles: GPUParticles2D = null
var _ring_visual: Line2D = null
var _pulse_tween: Tween = null


func _ready() -> void:
	_create_particle_aura()


func _create_particle_aura() -> void:
	# Create radius ring visual (shows aura boundary)
	_create_ring_visual()

	# Create particle system
	_create_particle_system()


func _create_ring_visual() -> void:
	# Create a circle outline to show aura radius
	_ring_visual = Line2D.new()
	_ring_visual.width = 2.0
	_ring_visual.default_color = color
	_ring_visual.z_index = -1  # Behind particles

	# Generate circle points
	var points: PackedVector2Array = []
	var segments = 64
	for i in range(segments + 1):
		var angle = (float(i) / segments) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

	_ring_visual.points = points
	add_child(_ring_visual)

	# Add pulsing animation to ring
	_start_pulse_animation()


func _create_particle_system() -> void:
	_particles = GPUParticles2D.new()
	_particles.emitting = true
	_particles.amount = int(radius / 2.0)  # More particles for larger auras
	_particles.lifetime = 2.0
	_particles.explosiveness = 0.0
	_particles.randomness = 0.5
	_particles.process_material = _create_particle_material()
	_particles.texture = _create_particle_texture()

	add_child(_particles)


func _create_particle_material() -> ParticleProcessMaterial:
	var material = ParticleProcessMaterial.new()

	# Emit particles in a ring shape (aura radius)
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	material.emission_ring_axis = Vector3(0, 0, 1)
	material.emission_ring_height = 1.0
	material.emission_ring_radius = radius * 0.8
	material.emission_ring_inner_radius = radius * 0.6

	# Particle appearance
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 10.0
	material.initial_velocity_max = 30.0

	# Particle behavior based on aura type
	match aura_type:
		"damage":
			# Aggressive outward burst
			material.radial_accel_min = 20.0
			material.radial_accel_max = 40.0
			material.scale_min = 0.8
			material.scale_max = 1.5
		"knockback":
			# Strong outward push
			material.radial_accel_min = 50.0
			material.radial_accel_max = 80.0
			material.scale_min = 1.0
			material.scale_max = 2.0
		"heal":
			# Gentle floating upward
			material.gravity = Vector3(0, -20, 0)
			material.scale_min = 0.5
			material.scale_max = 1.0
		"collect":
			# Swirling inward
			material.tangential_accel_min = 30.0
			material.tangential_accel_max = 50.0
			material.radial_accel_min = -10.0
			material.radial_accel_max = -20.0
			material.scale_min = 0.3
			material.scale_max = 0.8
		"slow":
			# Slow drifting
			material.initial_velocity_min = 5.0
			material.initial_velocity_max = 15.0
			material.scale_min = 1.0
			material.scale_max = 1.5
		"shield":
			# Orbiting particles
			material.tangential_accel_min = 20.0
			material.tangential_accel_max = 40.0
			material.scale_min = 0.5
			material.scale_max = 1.0

	# Color variation
	material.color = color

	return material


func _create_particle_texture() -> GradientTexture2D:
	# Create a circular gradient texture for particles
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))  # White center
	gradient.add_point(0.5, color)  # Aura color mid
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0))  # Fade to transparent

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.width = 32
	gradient_texture.height = 32

	return gradient_texture


func _start_pulse_animation() -> void:
	if _pulse_tween:
		_pulse_tween.kill()

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(_ring_visual, "modulate:a", 0.8, 1.0)
	_pulse_tween.tween_property(_ring_visual, "modulate:a", 0.3, 1.0)


func update_aura(new_type: String, new_radius: float) -> void:
	aura_type = new_type
	radius = new_radius

	# Update color based on type
	if AuraTypes.AURA_TYPES.has(aura_type):
		color = AuraTypes.AURA_TYPES[aura_type].color

	# Recreate visual with new parameters
	for child in get_children():
		child.queue_free()

	_particles = null
	_ring_visual = null

	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null

	_create_particle_aura()


func set_emitting(enabled: bool) -> void:
	if _particles:
		_particles.emitting = enabled
