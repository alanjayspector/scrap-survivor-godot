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


static func create_styled_button(text: String, style: ButtonStyle = ButtonStyle.PRIMARY) -> Button:
	"""Create a new Button with the specified style applied"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, UIConstants.TOUCH_TARGET_STANDARD)
	apply_button_style(button, style)
	return button


static func create_stat_label(
	label_text: String, value_text: String, color: Color = Color.WHITE
) -> HBoxContainer:
	"""Create a styled stat row with label and value"""
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label = Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", GameColorPalette.TEXT_SECONDARY)
	label.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_BODY)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var value = Label.new()
	value.text = value_text
	value.add_theme_color_override("font_color", color)
	value.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_BODY)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	container.add_child(label)
	container.add_child(value)

	return container
