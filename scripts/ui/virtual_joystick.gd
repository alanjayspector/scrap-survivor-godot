extends Control

class_name VirtualJoystick

signal direction_changed(direction: Vector2)

# State machine for floating joystick
enum JoystickState { INACTIVE, ACTIVE }  # No touch, joystick hidden  # Touch active, joystick visible

@onready var base: ColorRect = $Base
@onready var stick: ColorRect = $Stick

var is_pressed: bool = false
var max_distance: float = 85.0  # pixels from center (85% of base radius for comfortable movement)
var current_direction: Vector2 = Vector2.ZERO

# Dead zone - user must move thumb >12px before player moves (prevents accidental movement)
const DEAD_ZONE_THRESHOLD: float = 12.0  # pixels

# Floating joystick state
var state: JoystickState = JoystickState.INACTIVE
var touch_origin: Vector2 = Vector2.ZERO  # Where user first touched
var touch_index: int = -1  # Track specific touch (multi-touch safe)
var touch_zone_rect: Rect2  # Left half of screen

# Dead zone state tracking (prevents "stuck" feeling during drag - Round 4 fix)
var has_crossed_dead_zone: bool = false  # One-time threshold gate


func _ready() -> void:
	# Add to group for player to find
	add_to_group("virtual_joystick")

	# Hide joystick initially (appears on touch)
	base.visible = false
	stick.visible = false

	# Define touch zone (left half of screen)
	var viewport_size = get_viewport_rect().size
	touch_zone_rect = Rect2(0, 0, viewport_size.x / 2, viewport_size.y)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Only capture touches in left half of screen
		if touch_zone_rect.has_point(event.position) and state == JoystickState.INACTIVE:
			# Start floating joystick
			touch_origin = event.position
			touch_index = event.index
			is_pressed = true
			state = JoystickState.ACTIVE
			has_crossed_dead_zone = false  # Reset for new gesture (Round 4 fix)

			# Position joystick at touch point
			global_position = touch_origin
			base.visible = true
			stick.visible = true
			stick.position = Vector2.ZERO
	else:
		# Touch released
		if event.index == touch_index:
			is_pressed = false
			state = JoystickState.INACTIVE
			base.visible = false
			stick.visible = false
			current_direction = Vector2.ZERO
			direction_changed.emit(Vector2.ZERO)
			touch_index = -1
			has_crossed_dead_zone = false  # Reset for next gesture (Round 4 fix)


func _handle_drag(event: InputEventScreenDrag) -> void:
	if is_pressed and event.index == touch_index and state == JoystickState.ACTIVE:
		# Calculate offset from touch origin (not fixed center)
		var offset = event.position - touch_origin
		_update_stick_position_from_offset(offset)


func _update_stick_position_from_offset(offset: Vector2) -> void:
	"""Update stick position from touch offset with one-time dead zone gate (Round 4 fix)"""
	var offset_length: float = offset.length()

	# Clamp to max distance
	if offset_length > max_distance:
		offset = offset.normalized() * max_distance
		offset_length = max_distance

	# Always update stick visual position (shows where thumb is)
	stick.position = offset

	# Dead zone logic: One-time threshold gate (industry standard - Brotato/Vampire Survivors)
	if not has_crossed_dead_zone:
		# First-time check: User must drag >12px to start moving (prevents accidental tap-movement)
		if offset_length > DEAD_ZONE_THRESHOLD:
			has_crossed_dead_zone = true  # Transition to ACTIVE_DRAG state
			current_direction = offset.normalized()
			direction_changed.emit(current_direction)
		else:
			# Still within initial dead zone - no movement yet
			current_direction = Vector2.ZERO
			direction_changed.emit(Vector2.ZERO)
	else:
		# Already crossed threshold - always emit direction (dead zone no longer applies)
		# User can move finger anywhere within 85px radius and direction tracks continuously
		if offset_length > 0.1:  # Avoid division by zero on exact center
			current_direction = offset.normalized()
			direction_changed.emit(current_direction)
		else:
			# Finger at exact origin (rare) - no direction
			current_direction = Vector2.ZERO
			direction_changed.emit(Vector2.ZERO)
