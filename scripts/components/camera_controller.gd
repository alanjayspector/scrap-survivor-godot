extends Camera2D
class_name CameraController

## Camera controller with smooth follow, boundaries, and screen shake

@export var follow_smoothness: float = 5.0
@export var screen_shake_intensity: float = 10.0
@export var boundaries: Rect2 = Rect2(-2000, -2000, 4000, 4000)

var target: Node2D = null
var shake_amount: float = 0.0


func _ready() -> void:
	# Find player
	target = get_tree().get_first_node_in_group("player")

	# Connect to combat events for screen shake
	WeaponService.weapon_fired.connect(_on_weapon_fired)
	CombatService.damage_dealt.connect(_on_damage_dealt)


func _process(delta: float) -> void:
	if not target:
		return

	# Smooth follow
	var target_pos = target.global_position
	target_pos.x = clamp(
		target_pos.x, boundaries.position.x, boundaries.position.x + boundaries.size.x
	)
	target_pos.y = clamp(
		target_pos.y, boundaries.position.y, boundaries.position.y + boundaries.size.y
	)

	global_position = global_position.lerp(target_pos, follow_smoothness * delta)

	# Screen shake
	if shake_amount > 0:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount)
		)
		shake_amount = lerp(shake_amount, 0.0, 10.0 * delta)
	else:
		offset = Vector2.ZERO


func trigger_shake(intensity: float) -> void:
	shake_amount = intensity


func _on_weapon_fired(_weapon_id: String) -> void:
	trigger_shake(2.0)  # Light shake for firing


func _on_damage_dealt(_enemy_id: String, _damage: float, killed: bool) -> void:
	if killed:
		trigger_shake(5.0)  # Medium shake for kill
