extends Node2D
## Simple aura visual (ColorRect circle)
## Week 7: Basic prototype
## Week 8: Upgrade to GPUParticles2D

var aura_type: String = "collect"
var radius: float = 100.0
var color: Color = Color(1, 1, 0, 0.3)


func _ready() -> void:
	_create_simple_circle()


func _create_simple_circle() -> void:
	# Create circular mask using ColorRect
	var circle = ColorRect.new()
	circle.color = color
	circle.size = Vector2(radius * 2, radius * 2)
	circle.position = -Vector2(radius, radius)
	add_child(circle)

	# Optional: Add pulsing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(circle, "modulate:a", 0.5, 1.0)
	tween.tween_property(circle, "modulate:a", 0.2, 1.0)


func update_aura(new_type: String, new_radius: float) -> void:
	aura_type = new_type
	radius = new_radius

	# Update color based on type
	if AuraTypes.AURA_TYPES.has(aura_type):
		color = AuraTypes.AURA_TYPES[aura_type].color

	# Recreate visual
	for child in get_children():
		child.queue_free()
	_create_simple_circle()
