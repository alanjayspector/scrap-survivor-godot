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
@export var title_text: String = "":
	set(value):
		title_text = value
		_update_title_label()
@export var message_text: String = "":
	set(value):
		message_text = value
		_update_message_label()

## Constants (iOS HIG specifications)
const ANIMATION_ENTRANCE_DURATION: float = 0.3  # 300ms
const ANIMATION_EXIT_DURATION: float = 0.25  # 250ms
const BACKDROP_FADE_IN: float = 0.2  # 200ms
const BACKDROP_FADE_OUT: float = 0.15  # 150ms
const SWIPE_THRESHOLD: float = 100.0  # 100pt downward swipe
const MIN_ALERT_WIDTH: float = 300.0
const MAX_ALERT_WIDTH: float = 500.0  # Increased from 400 for more prominence
const ALERT_WIDTH_PERCENT: float = 0.90  # Increased from 85% for larger modals

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

	# Apply any text values that were set before _ready() ran
	# (property setters early-return if not is_node_ready())
	_update_title_label()
	_update_message_label()

	# Start hidden (only use visible, not modulate - parent alpha affects all children)
	visible = false


func _build_backdrop() -> void:
	"""Create backdrop overlay"""
	backdrop = ColorRect.new()
	add_child(backdrop)  # Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	backdrop.name = "ModalBackdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = backdrop_color
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP  # Block clicks to content below
	backdrop.modulate.a = 0.0  # Start invisible

	# Connect tap-to-dismiss
	backdrop.gui_input.connect(_on_backdrop_input)


func _build_modal_container() -> void:
	"""Create modal container with proper sizing based on type"""
	modal_container = PanelContainer.new()
	add_child(modal_container)  # Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	modal_container.name = "ModalContainer"

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
	"""Setup alert dialog sizing (centered, 90% width)"""
	# Calculate size FIRST (must set size before centering for correct offset calculation)
	var screen_size = get_viewport().get_visible_rect().size
	var target_width = clamp(screen_size.x * ALERT_WIDTH_PERCENT, MIN_ALERT_WIDTH, MAX_ALERT_WIDTH)

	# Set size explicitly for prominent display (destructive operations need prominence)
	modal_container.custom_minimum_size = Vector2(target_width, 300)  # Increased from 220 to 300
	modal_container.size = Vector2(target_width, 300)  # Set explicit height for centering calculation

	# CRITICAL: Set anchors to center (0.5, 0.5) manually first
	modal_container.anchor_left = 0.5
	modal_container.anchor_top = 0.5
	modal_container.anchor_right = 0.5
	modal_container.anchor_bottom = 0.5

	# Now manually set offsets based on size to achieve true centering
	# For a centered control, offsets should be -size/2 to +size/2
	var half_width = target_width / 2.0
	var half_height = 300.0 / 2.0  # Use explicit height

	modal_container.offset_left = -half_width
	modal_container.offset_top = -half_height
	modal_container.offset_right = half_width
	modal_container.offset_bottom = half_height

	modal_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	modal_container.grow_vertical = Control.GROW_DIRECTION_BOTH


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

	# Padding - increased for ALERT modals to give more breathing room
	var padding = 36 if modal_type == ModalType.ALERT else 20  # Increased from 28 for alerts
	style.content_margin_left = padding
	style.content_margin_top = padding
	style.content_margin_right = padding
	style.content_margin_bottom = padding

	modal_container.add_theme_stylebox_override("panel", style)


func _build_content() -> void:
	"""Build content structure (title, message, buttons)"""
	content_vbox = VBoxContainer.new()
	modal_container.add_child(content_vbox)  # Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	content_vbox.name = "ContentVBox"
	content_vbox.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	content_vbox.add_theme_constant_override("separation", 24)  # Increased from 20 for more breathing room

	# Labels will be created on-demand by property setters
	# This allows ModalFactory to set title/message AFTER parenting

	# Button container (added later via add_button methods)
	button_container = HBoxContainer.new()
	content_vbox.add_child(button_container)  # Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	button_container.name = "ButtonContainer"
	button_container.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	button_container.add_theme_constant_override("separation", 16)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER


func _update_title_label() -> void:
	"""Create or update title label when title_text changes"""
	if not is_node_ready() or not content_vbox:
		return  # Not ready yet, property setter will be called again later

	if title_text.is_empty():
		# Remove title label if it exists
		if title_label:
			title_label.queue_free()
			title_label = null
		return

	# Create label if it doesn't exist
	if not title_label:
		title_label = Label.new()
		content_vbox.add_child(title_label)  # Parent FIRST
		title_label.name = "TitleLabel"
		title_label.layout_mode = 2
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 28)  # Increased from 24 for prominence
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Move before button container
		content_vbox.move_child(title_label, 0)

	# Update text
	title_label.text = title_text


func _update_message_label() -> void:
	"""Create or update message label when message_text changes"""
	if not is_node_ready() or not content_vbox:
		return  # Not ready yet, property setter will be called again later

	if message_text.is_empty():
		# Remove message label if it exists
		if message_label:
			message_label.queue_free()
			message_label = null
		return

	# Create label if it doesn't exist
	if not message_label:
		message_label = Label.new()
		content_vbox.add_child(message_label)  # Parent FIRST
		message_label.name = "MessageLabel"
		message_label.layout_mode = 2
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_label.add_theme_font_size_override("font_size", 20)  # Increased from 18 for better readability
		message_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Move before button container (after title if it exists)
		var target_index = 1 if title_label else 0
		content_vbox.move_child(message_label, target_index)

	# Update text
	message_label.text = message_text


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
	button_container.add_child(button)  # Parent FIRST
	button.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	button.text = button_text
	button.custom_minimum_size = Vector2(140, 64)  # Increased from 120x56 for better touch targets and prominence
	button.add_theme_font_size_override("font_size", 20)  # Increased from 19 for better button text visibility

	# Apply theme styling
	THEME_HELPER.apply_button_style(button, style)
	THEME_HELPER.add_button_animation(button)

	# Connect callback
	button.pressed.connect(
		func():
			HapticManager.light()
			callback.call()
	)

	return button


func show_modal() -> void:
	"""Show modal with animation"""
	GameLogger.debug("[MobileModal] show_modal() ENTRY", {"type": ModalType.keys()[modal_type]})

	if _is_showing:
		GameLogger.debug("[MobileModal] Already showing, skipping")
		return

	_is_showing = true
	visible = true

	# Play entrance animation
	GameLogger.debug("[MobileModal] Starting entrance animation")
	_animate_entrance()

	# Emit signal
	shown.emit()

	# Haptic feedback
	HapticManager.light()

	GameLogger.debug("[MobileModal] show_modal() EXIT - Modal displayed successfully")


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
			# Set pivot to center so scale animation doesn't shift position
			modal_container.pivot_offset = modal_container.size / 2.0

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
	"""Set modal title dynamically (property setter handles label creation)"""
	title_text = new_title  # Triggers property setter → _update_title_label()


func set_message(new_message: String) -> void:
	"""Set modal message dynamically (property setter handles label creation)"""
	message_text = new_message  # Triggers property setter → _update_message_label()


func add_custom_content(content_node: Control) -> void:
	"""Add custom content to modal (for advanced use cases)"""
	# Insert before button container
	var button_index = button_container.get_index()
	content_vbox.add_child(content_node)
	content_vbox.move_child(content_node, button_index)


func get_content_container() -> VBoxContainer:
	"""Get content container for advanced customization"""
	return content_vbox
