extends Camera2D
class_name CameraController

## Camera controller with smooth follow, boundaries, and screen shake

@export var follow_smoothness: float = 5.0
@export var screen_shake_intensity: float = 10.0
@export var boundaries: Rect2 = Rect2(-1000, -1000, 2000, 2000)

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

	# Smooth follow - lerp toward player's actual position
	var target_pos = target.global_position
	var new_camera_pos = global_position.lerp(target_pos, follow_smoothness * delta)

	# Clamp CAMERA position to boundaries (not target position!)
	# This allows player to reach world edges while preventing camera from showing off-canvas void
	new_camera_pos.x = clamp(
		new_camera_pos.x, boundaries.position.x, boundaries.position.x + boundaries.size.x
	)
	new_camera_pos.y = clamp(
		new_camera_pos.y, boundaries.position.y, boundaries.position.y + boundaries.size.y
	)

	# Diagnostic logging
	if (new_camera_pos - global_position).length() > 1.0:
		print(
			"[Camera] Position: ",
			new_camera_pos.snapped(Vector2.ONE),
			" | Target: ",
			target_pos.snapped(Vector2.ONE),
			" | Boundaries: ",
			boundaries
		)

	global_position = new_camera_pos

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


func _on_weapon_fired(weapon_id: String, _position: Vector2, _direction: Vector2) -> void:
	# Get weapon-specific shake intensity (Phase 1.5)
	var weapon_def = WeaponService.get_weapon(weapon_id)
	if not weapon_def.is_empty():
		var shake_intensity = weapon_def.get("screen_shake_intensity", 2.0)
		trigger_shake(shake_intensity)
	else:
		trigger_shake(2.0)  # Fallback to default


func _on_damage_dealt(_enemy_id: String, _damage: float, killed: bool) -> void:
	if killed:
		trigger_shake(5.0)  # Medium shake for kill
