extends Control

class_name VirtualJoystick

signal direction_changed(direction: Vector2)

@onready var base: ColorRect = $Base
@onready var stick: ColorRect = $Stick

var is_pressed: bool = false
var max_distance: float = 50.0  # pixels from center
var current_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Add to group for player to find
	add_to_group("virtual_joystick")

	# Position in bottom-left corner
	position = Vector2(100, get_viewport_rect().size.y - 150)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_pressed = true
			_update_stick_position(event.position)
		else:
			is_pressed = false
			stick.position = Vector2.ZERO
			current_direction = Vector2.ZERO
			direction_changed.emit(Vector2.ZERO)

	elif event is InputEventScreenDrag and is_pressed:
		_update_stick_position(event.position)


func _update_stick_position(touch_pos: Vector2) -> void:
	var center: Vector2 = base.size / 2
	var offset: Vector2 = touch_pos - center

	# Clamp to max distance
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance

	stick.position = offset
	current_direction = offset.normalized() if offset.length() > 0 else Vector2.ZERO
	direction_changed.emit(current_direction)
