class_name ThemeHelper
extends RefCounted
## Theme Helper - Utilities for applying game theme styles programmatically
## Provides easy access to styled buttons, panels, and icons

# Preloaded StyleBox resources
const BUTTON_PRIMARY = preload("res://themes/styles/button_primary.tres")
const BUTTON_PRIMARY_PRESSED = preload("res://themes/styles/button_primary_pressed.tres")
const BUTTON_SECONDARY = preload("res://themes/styles/button_secondary.tres")
const BUTTON_SECONDARY_PRESSED = preload("res://themes/styles/button_secondary_pressed.tres")
const BUTTON_DANGER = preload("res://themes/styles/button_danger.tres")
const BUTTON_DANGER_PRESSED = preload("res://themes/styles/button_danger_pressed.tres")
const BUTTON_GHOST = preload("res://themes/styles/button_ghost.tres")
const BUTTON_GHOST_PRESSED = preload("res://themes/styles/button_ghost_pressed.tres")
const PANEL_CARD = preload("res://themes/styles/panel_card.tres")
const PANEL_ELEVATED = preload("res://themes/styles/panel_elevated.tres")
const TAB_SELECTED = preload("res://themes/styles/tab_selected.tres")
const TAB_UNSELECTED = preload("res://themes/styles/tab_unselected.tres")

# Main theme resource
const GAME_THEME = preload("res://themes/game_theme.tres")

enum ButtonStyle { PRIMARY, SECONDARY, DANGER, GHOST }


static func apply_button_style(button: Button, style: ButtonStyle) -> void:
	"""Apply a button style variant to a Button node"""
	match style:
		ButtonStyle.PRIMARY:
			button.add_theme_stylebox_override("normal", BUTTON_PRIMARY)
			button.add_theme_stylebox_override("pressed", BUTTON_PRIMARY_PRESSED)
			button.add_theme_stylebox_override("hover", BUTTON_PRIMARY)
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_color_override("font_pressed_color", GameColorPalette.TEXT_TERTIARY)

		ButtonStyle.SECONDARY:
			button.add_theme_stylebox_override("normal", BUTTON_SECONDARY)
			button.add_theme_stylebox_override("pressed", BUTTON_SECONDARY_PRESSED)
			button.add_theme_stylebox_override("hover", BUTTON_SECONDARY)
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_color_override("font_pressed_color", GameColorPalette.TEXT_TERTIARY)

		ButtonStyle.DANGER:
			button.add_theme_stylebox_override("normal", BUTTON_DANGER)
			button.add_theme_stylebox_override("pressed", BUTTON_DANGER_PRESSED)
			button.add_theme_stylebox_override("hover", BUTTON_DANGER)
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_color_override("font_pressed_color", Color(1, 0.8, 0.8))

		ButtonStyle.GHOST:
			button.add_theme_stylebox_override("normal", BUTTON_GHOST)
			button.add_theme_stylebox_override("pressed", BUTTON_GHOST_PRESSED)
			button.add_theme_stylebox_override("hover", BUTTON_GHOST_PRESSED)
			button.add_theme_color_override("font_color", GameColorPalette.TEXT_SECONDARY)
			button.add_theme_color_override("font_pressed_color", Color.WHITE)


static func apply_panel_style(panel: PanelContainer, elevated: bool = false) -> void:
	"""Apply card or elevated panel style"""
	if elevated:
		panel.add_theme_stylebox_override("panel", PANEL_ELEVATED)
	else:
		panel.add_theme_stylebox_override("panel", PANEL_CARD)


static func apply_game_theme(control: Control) -> void:
	"""Apply the main game theme to a Control node and all children"""
	control.theme = GAME_THEME


static func style_collapsible_header(button: Button, is_expanded: bool) -> void:
	"""Style a collapsible section header button"""
	apply_button_style(button, ButtonStyle.GHOST)

	# Add expand/collapse indicator text
	var arrow = " v" if is_expanded else " >"
	if not button.text.ends_with(" v") and not button.text.ends_with(" >"):
		button.text = button.text + arrow
	else:
		# Replace existing arrow
		button.text = button.text.substr(0, button.text.length() - 2) + arrow


static func create_styled_button(
	text: String, style: ButtonStyle = ButtonStyle.PRIMARY, animated: bool = true
) -> Button:
	"""
	Create a new Button with the specified style applied.

	Args:
		text: Button label text
		style: Button style variant (PRIMARY, SECONDARY, DANGER, GHOST)
		animated: Whether to add ButtonAnimation (default: true)

	Returns:
		The created Button node
	"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, UIConstants.TOUCH_TARGET_STANDARD)
	apply_button_style(button, style)

	if animated:
		add_button_animation(button)

	return button


static func create_stat_label(
	label_text: String, value_text: String, color: Color = Color.WHITE
) -> HBoxContainer:
	"""Create a styled stat row with label and value

	Note: Follows Parent-First protocol - children are parented BEFORE configuration.
	The container itself will be parented by the caller.
	"""
	var container = HBoxContainer.new()
	# Don't configure container yet - caller will parent it

	var label = Label.new()
	container.add_child(label)  # Parent FIRST
	label.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	label.text = label_text
	label.add_theme_color_override("font_color", GameColorPalette.TEXT_SECONDARY)
	label.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_BODY)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var value = Label.new()
	container.add_child(value)  # Parent FIRST
	value.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	value.text = value_text
	value.add_theme_color_override("font_color", color)
	value.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_BODY)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Configure container AFTER children are parented
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	return container


static func add_button_animation(button: Button, press_scale: float = 0.90) -> ButtonAnimation:
	"""
	Add ButtonAnimation component to a button for press/release scale animation.

	Args:
		button: The Button node to animate
		press_scale: Scale multiplier on press (default: 0.90 = 90% size, 10% reduction)

	Returns:
		The created ButtonAnimation node (for further configuration if needed)

	Example:
		ThemeHelper.add_button_animation(my_button)
		# Or with custom scale:
		ThemeHelper.add_button_animation(my_button, 0.85)  # Even more pronounced
	"""
	var animation = ButtonAnimation.new()
	animation.press_scale = press_scale
	button.add_child(animation)
	return animation
