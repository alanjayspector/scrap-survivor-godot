class_name MobileModal
extends Control
## MobileModal - iOS-native modal/dialog component
## Week 16 Phase 4: Mobile-native dialog and modal patterns
##
## Features:
## - Three modal types: Alert, Sheet, Full-Screen
## - Backdrop overlay with tap-to-dismiss
## - Entrance/exit animations (fade, slide, scale)
## - Swipe-down gesture support (for sheets)
## - iOS HIG compliant sizing and spacing
## - Haptic feedback integration
##
## Usage:
## ```gdscript
## var modal = MobileModal.new()
## modal.modal_type = MobileModal.ModalType.ALERT
## modal.title_text = "Character Created!"
## modal.message_text = "Your character is ready to fight."
## modal.add_primary_button("Start Playing", _on_start)
## add_child(modal)
## modal.show_modal()
## ```

## Signals
signal shown
signal dismissed
signal backdrop_tapped

## Modal Types:
## - ALERT: Small centered dialog (confirmations, alerts)
## - SHEET: Bottom sheet (character details, complex info)
## - FULLSCREEN: Full-screen takeover (onboarding, tutorials)
enum ModalType { ALERT, SHEET, FULLSCREEN }

## Configuration (exported for easy scene configuration)
@export var modal_type: ModalType = ModalType.ALERT
@export var allow_tap_outside_dismiss: bool = true
@export var allow_swipe_dismiss: bool = false
@export var backdrop_color: Color = Color(0, 0, 0, 0.6)
@export var title_text: String = ""
@export var message_text: String = ""

## Constants (iOS HIG specifications)
const ANIMATION_ENTRANCE_DURATION: float = 0.3  # 300ms
const ANIMATION_EXIT_DURATION: float = 0.25  # 250ms
const BACKDROP_FADE_IN: float = 0.2  # 200ms
const BACKDROP_FADE_OUT: float = 0.15  # 150ms
const SWIPE_THRESHOLD: float = 100.0  # 100pt downward swipe
const MIN_ALERT_WIDTH: float = 300.0
const MAX_ALERT_WIDTH: float = 400.0
const ALERT_WIDTH_PERCENT: float = 0.85  # 85% of screen width

## Child nodes (created programmatically)
var backdrop: ColorRect
var modal_container: PanelContainer
var content_vbox: VBoxContainer
var title_label: Label
var message_label: Label
var button_container: HBoxContainer

## Internal state
var _is_showing: bool = false
var _tween: Tween = null
var _swipe_start_position: Vector2 = Vector2.ZERO
var _is_swiping: bool = false
var _original_position: Vector2 = Vector2.ZERO

## Theme constants
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")


func _init() -> void:
	"""Initialize modal with default settings"""
	# Full-screen control to contain backdrop and modal
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let backdrop handle input


func _ready() -> void:
	"""Build modal structure"""
	_build_backdrop()
	_build_modal_container()
	_build_content()

	# Start hidden
	visible = false
	modulate.a = 0.0


func _build_backdrop() -> void:
	"""Create backdrop overlay"""
	backdrop = ColorRect.new()
	backdrop.name = "ModalBackdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = backdrop_color
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP  # Block clicks to content below
	backdrop.modulate.a = 0.0  # Start invisible
	add_child(backdrop)

	# Connect tap-to-dismiss
	backdrop.gui_input.connect(_on_backdrop_input)


func _build_modal_container() -> void:
	"""Create modal container with proper sizing based on type"""
	modal_container = PanelContainer.new()
	modal_container.name = "ModalContainer"
	add_child(modal_container)

	# Apply sizing based on modal type
	match modal_type:
		ModalType.ALERT:
			_setup_alert_sizing()
		ModalType.SHEET:
			_setup_sheet_sizing()
		ModalType.FULLSCREEN:
			_setup_fullscreen_sizing()

	# Style the panel
	_style_modal_panel()

	# Enable input for swipe gestures (sheets only)
	if modal_type == ModalType.SHEET and allow_swipe_dismiss:
		modal_container.gui_input.connect(_on_modal_input)


func _setup_alert_sizing() -> void:
	"""Setup alert dialog sizing (centered, 85% width)"""
	modal_container.set_anchors_preset(Control.PRESET_CENTER)
	modal_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	modal_container.grow_vertical = Control.GROW_DIRECTION_BOTH

	# Calculate width (85% of screen, clamped)
	var screen_size = get_viewport().get_visible_rect().size
	var target_width = clamp(screen_size.x * ALERT_WIDTH_PERCENT, MIN_ALERT_WIDTH, MAX_ALERT_WIDTH)

	modal_container.custom_minimum_size = Vector2(target_width, 150)
	modal_container.size = Vector2(target_width, 0)  # Auto height


func _setup_sheet_sizing() -> void:
	"""Setup sheet modal sizing (bottom sheet, 80-90% height)"""
	# Anchor to bottom
	modal_container.anchor_left = 0.0
	modal_container.anchor_top = 1.0  # Start at bottom
	modal_container.anchor_right = 1.0
	modal_container.anchor_bottom = 1.0
	modal_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	modal_container.grow_vertical = Control.GROW_DIRECTION_BEGIN

	# Size: Full width, 85% height
	var screen_size = get_viewport().get_visible_rect().size
	var target_height = screen_size.y * 0.85

	modal_container.offset_left = 0
	modal_container.offset_top = -target_height
	modal_container.offset_right = 0
	modal_container.offset_bottom = 0

	# Store original position for animations
	_original_position = Vector2(0, -target_height)


func _setup_fullscreen_sizing() -> void:
	"""Setup full-screen modal sizing"""
	modal_container.set_anchors_preset(Control.PRESET_FULL_RECT)


func _style_modal_panel() -> void:
	"""Apply visual styling to modal panel"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)  # Dark background
	style.border_color = Color(0.9, 0.7, 0.3)  # Accent border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	# Border radius based on type
	if modal_type == ModalType.ALERT:
		# Rounded all corners
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
	elif modal_type == ModalType.SHEET:
		# Rounded top corners only
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		style.corner_radius_bottom_left = 0
		style.corner_radius_bottom_right = 0

	# Padding
	var padding = 24 if modal_type == ModalType.ALERT else 20
	style.content_margin_left = padding
	style.content_margin_top = padding
	style.content_margin_right = padding
	style.content_margin_bottom = padding

	modal_container.add_theme_stylebox_override("panel", style)


func _build_content() -> void:
	"""Build content structure (title, message, buttons)"""
	content_vbox = VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.add_theme_constant_override("separation", 16)
	modal_container.add_child(content_vbox)

	# Title label
	if not title_text.is_empty():
		title_label = Label.new()
		title_label.name = "TitleLabel"
		title_label.text = title_text
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 22)
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(title_label)

	# Message label
	if not message_text.is_empty():
		message_label = Label.new()
		message_label.name = "MessageLabel"
		message_label.text = message_text
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_label.add_theme_font_size_override("font_size", 16)
		message_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(message_label)

	# Button container (added later via add_button methods)
	button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.add_theme_constant_override("separation", 16)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	content_vbox.add_child(button_container)


func add_primary_button(button_text: String, callback: Callable) -> Button:
	"""Add a primary action button"""
	return _add_button(button_text, callback, THEME_HELPER.ButtonStyle.PRIMARY)


func add_secondary_button(button_text: String, callback: Callable) -> Button:
	"""Add a secondary action button"""
	return _add_button(button_text, callback, THEME_HELPER.ButtonStyle.SECONDARY)


func add_danger_button(button_text: String, callback: Callable) -> Button:
	"""Add a danger/destructive action button"""
	return _add_button(button_text, callback, THEME_HELPER.ButtonStyle.DANGER)


func _add_button(button_text: String, callback: Callable, style: int) -> Button:
	"""Internal: Add a button with specified style"""
	var button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(0, 50)  # iOS HIG: 44pt + safety
	button.add_theme_font_size_override("font_size", 18)

	# Apply theme styling
	THEME_HELPER.apply_button_style(button, style)
	THEME_HELPER.add_button_animation(button)

	# Connect callback
	button.pressed.connect(
		func():
			HapticManager.light()
			callback.call()
	)

	button_container.add_child(button)
	return button


func show_modal() -> void:
	"""Show modal with animation"""
	if _is_showing:
		return

	_is_showing = true
	visible = true

	# Play entrance animation
	_animate_entrance()

	# Emit signal
	shown.emit()

	# Haptic feedback
	HapticManager.light()


func dismiss() -> void:
	"""Dismiss modal with animation"""
	if not _is_showing:
		return

	_is_showing = false

	# Play exit animation
	_animate_exit()

	# Emit signal
	dismissed.emit()

	# Haptic feedback
	HapticManager.light()


func _animate_entrance() -> void:
	"""Play entrance animation based on modal type"""
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	# Backdrop fade in
	_tween.tween_property(backdrop, "modulate:a", 1.0, BACKDROP_FADE_IN)

	match modal_type:
		ModalType.ALERT:
			# Fade + scale animation
			modal_container.modulate.a = 0.0
			modal_container.scale = Vector2(0.9, 0.9)

			_tween.tween_property(modal_container, "modulate:a", 1.0, ANIMATION_ENTRANCE_DURATION)
			_tween.tween_property(
				modal_container, "scale", Vector2(1.0, 1.0), ANIMATION_ENTRANCE_DURATION
			)

		ModalType.SHEET:
			# Slide up from bottom
			var screen_height = get_viewport().get_visible_rect().size.y
			modal_container.offset_top = 0  # Start off-screen

			_tween.tween_property(
				modal_container, "offset_top", _original_position.y, ANIMATION_ENTRANCE_DURATION
			)

		ModalType.FULLSCREEN:
			# Fade in
			modal_container.modulate.a = 0.0
			_tween.tween_property(modal_container, "modulate:a", 1.0, ANIMATION_ENTRANCE_DURATION)


func _animate_exit() -> void:
	"""Play exit animation based on modal type"""
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)

	# Backdrop fade out
	_tween.tween_property(backdrop, "modulate:a", 0.0, BACKDROP_FADE_OUT)

	match modal_type:
		ModalType.ALERT:
			# Fade + slight scale down
			_tween.tween_property(modal_container, "modulate:a", 0.0, ANIMATION_EXIT_DURATION)
			_tween.tween_property(
				modal_container, "scale", Vector2(0.95, 0.95), ANIMATION_EXIT_DURATION
			)

		ModalType.SHEET:
			# Slide down
			_tween.tween_property(modal_container, "offset_top", 0, ANIMATION_EXIT_DURATION)

		ModalType.FULLSCREEN:
			# Fade out
			_tween.tween_property(modal_container, "modulate:a", 0.0, ANIMATION_EXIT_DURATION)

	# Hide after animation completes
	_tween.tween_callback(func(): visible = false)


func _on_backdrop_input(event: InputEvent) -> void:
	"""Handle backdrop tap for dismiss"""
	if not allow_tap_outside_dismiss:
		return

	if event is InputEventScreenTouch and event.pressed:
		backdrop_tapped.emit()
		dismiss()


func _on_modal_input(event: InputEvent) -> void:
	"""Handle swipe-down gesture for sheets"""
	if not allow_swipe_dismiss or modal_type != ModalType.SHEET:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_swipe_start_position = event.position
			_is_swiping = true
		else:
			_is_swiping = false

			# Check if swipe was far enough to dismiss
			var swipe_distance = event.position.y - _swipe_start_position.y
			if swipe_distance > SWIPE_THRESHOLD:
				dismiss()
			else:
				# Snap back to original position
				_snap_back_to_position()

	elif event is InputEventScreenDrag and _is_swiping:
		# Follow finger during drag (elastic effect)
		var drag_distance = event.position.y - _swipe_start_position.y
		if drag_distance > 0:  # Only allow downward drag
			modal_container.offset_top = _original_position.y + drag_distance


func _snap_back_to_position() -> void:
	"""Animate modal back to original position after incomplete swipe"""
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(modal_container, "offset_top", _original_position.y, 0.2)


## Public API for dynamic content


func set_title(new_title: String) -> void:
	"""Set modal title dynamically"""
	title_text = new_title
	if title_label:
		title_label.text = new_title


func set_message(new_message: String) -> void:
	"""Set modal message dynamically"""
	message_text = new_message
	if message_label:
		message_label.text = new_message


func add_custom_content(content_node: Control) -> void:
	"""Add custom content to modal (for advanced use cases)"""
	# Insert before button container
	var button_index = button_container.get_index()
	content_vbox.add_child(content_node)
	content_vbox.move_child(content_node, button_index)


func get_content_container() -> VBoxContainer:
	"""Get content container for advanced customization"""
	return content_vbox
