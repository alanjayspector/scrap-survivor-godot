extends Control

class_name VirtualJoystick

signal direction_changed(direction: Vector2)

@onready var base: ColorRect = $Base
@onready var stick: ColorRect = $Stick

var is_pressed: bool = false
var max_distance: float = 85.0  # pixels from center (85% of base radius for comfortable movement)
var current_direction: Vector2 = Vector2.ZERO

# Dead zone - user must move thumb >12px before player moves (prevents accidental movement)
const DEAD_ZONE_THRESHOLD: float = 12.0  # pixels


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
	var offset_length: float = offset.length()

	# Clamp to max distance
	if offset_length > max_distance:
		offset = offset.normalized() * max_distance
		offset_length = max_distance

	# Always update stick visual position (shows where thumb is)
	stick.position = offset

	# Only emit movement direction if outside dead zone (prevents accidental movement)
	if offset_length > DEAD_ZONE_THRESHOLD:
		current_direction = offset.normalized()
		direction_changed.emit(current_direction)
	else:
		# Within dead zone - no movement
		current_direction = Vector2.ZERO
		direction_changed.emit(Vector2.ZERO)
