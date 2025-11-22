class_name ButtonAnimation
extends Node
## ButtonAnimation - Smooth scale animation for button press feedback
##
## Attach this node as a child of any Button to add press/release animations.
## Respects UIConstants.animations_enabled for accessibility.
##
## Usage:
##   1. Add as child node to Button in scene editor
##   2. Or programmatically: button.add_child(ButtonAnimation.new())
##   3. Animations automatically connect to button signals
##
## Configuration:
##   @export var press_scale: float = 0.95  # Scale down amount on press
##   @export var enabled: bool = true       # Enable/disable per button
##   @export var use_global_setting: bool = true  # Respect UIConstants.animations_enabled

## Scale multiplier when button is pressed (0.90 = 90% of original size, 10% reduction)
@export var press_scale: float = 0.90

## Enable/disable animation for this specific button
@export var enabled: bool = true

## Respect global UIConstants.animations_enabled setting
@export var use_global_setting: bool = true

## Override animation durations (optional - uses UIConstants by default)
@export var press_duration_override: float = -1.0  # -1 = use UIConstants.ANIM_BUTTON_PRESS
@export var release_duration_override: float = -1.0  # -1 = use UIConstants.ANIM_BUTTON_RELEASE

@onready var _button: Button = get_parent()
var _tween: Tween = null
var _original_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	# Validate parent is a Button
	if not _button:
		push_error("ButtonAnimation must be a child of a Button node")
		queue_free()
		return

	_original_scale = _button.scale

	# Connect button signals
	_button.button_down.connect(_on_button_down)
	_button.button_up.connect(_on_button_up)
	# Handle case where button is released while mouse is outside button area
	_button.mouse_exited.connect(_on_mouse_exited)


func _on_button_down() -> void:
	"""Animate button scale down when pressed"""
	if not _should_animate():
		return

	# Kill existing tween if running
	if _tween and _tween.is_running():
		_tween.kill()

	# Get duration
	var duration = (
		press_duration_override if press_duration_override >= 0.0 else UIConstants.ANIM_BUTTON_PRESS
	)
	duration = UIConstants.get_animation_duration(duration) if use_global_setting else duration

	# Create tween to scale down
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_button, "scale", _original_scale * press_scale, duration)


func _on_button_up() -> void:
	"""Animate button scale back to normal when released"""
	if not _should_animate():
		# Even if animations disabled, reset scale
		_button.scale = _original_scale
		return

	# Kill existing tween if running
	if _tween and _tween.is_running():
		_tween.kill()

	# Get duration
	var duration = (
		release_duration_override
		if release_duration_override >= 0.0
		else UIConstants.ANIM_BUTTON_RELEASE
	)
	duration = UIConstants.get_animation_duration(duration) if use_global_setting else duration

	# Create tween to scale back up
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)  # Slight overshoot for satisfying feel
	_tween.tween_property(_button, "scale", _original_scale, duration)


func _on_mouse_exited() -> void:
	"""Reset scale if mouse exits button while pressed"""
	# Only reset if button was actually pressed
	if _button.is_pressed():
		_on_button_up()


func _should_animate() -> bool:
	"""Check if animation should play based on settings"""
	if not enabled:
		return false

	if use_global_setting:
		return UIConstants.should_animate()

	return true


func set_press_scale(scale: float) -> void:
	"""Set the press scale amount (chainable)"""
	press_scale = scale


func set_enabled(enable: bool) -> void:
	"""Enable or disable animations (chainable)"""
	enabled = enable


func _exit_tree() -> void:
	"""Cleanup: kill tween and reset scale"""
	if _tween and _tween.is_running():
		_tween.kill()

	if _button and is_instance_valid(_button):
		_button.scale = _original_scale
