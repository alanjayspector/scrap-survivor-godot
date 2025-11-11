extends Node
class_name InputHandler

## Handles cross-platform input (keyboard, mouse, touch, gamepad)

signal movement_input(direction: Vector2)
signal aim_input(target_position: Vector2)

var is_mobile: bool = false


func _ready() -> void:
	is_mobile = OS.has_feature("mobile")


func _process(_delta: float) -> void:
	# Movement (WASD or virtual joystick on mobile)
	var direction = _get_movement_direction()
	if direction != Vector2.ZERO:
		movement_input.emit(direction)

	# Aiming (mouse or touch)
	var aim_pos = _get_aim_position()
	aim_input.emit(aim_pos)


func _get_movement_direction() -> Vector2:
	if is_mobile:
		# Future: Use virtual joystick input
		return Vector2.ZERO

	# Keyboard input
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _get_aim_position() -> Vector2:
	if is_mobile:
		# Future: Use touch position
		return get_viewport().get_mouse_position()

	return get_viewport().get_mouse_position()
