extends PanelContainer
## CharacterCard - Reusable character list item component
## Week 15 Phase 3: Godot Specialist architecture improvement
##
## Features:
## - Displays character info (name, type, level, stats)
## - View Details button to show full character preview
## - Play button to select character
## - Delete button with proper spacing (20pt)
## - Color-coded by character type

signal play_pressed(character_id: String)
signal delete_pressed(character_id: String, character_name: String)
signal details_pressed(character_id: String)

@onready var character_icon: ColorRect = $HBoxContainer/CharacterIcon
@onready var name_label: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var type_label: Label = $HBoxContainer/InfoContainer/TypeLabel
@onready var stats_label: Label = $HBoxContainer/InfoContainer/StatsLabel
@onready var details_button: Button = $HBoxContainer/DetailsButton
@onready var play_button: Button = $HBoxContainer/PlayButton
@onready var delete_button: Button = $HBoxContainer/DeleteButton

var character_data: Dictionary = {}


func setup(character: Dictionary) -> void:
	"""Initialize card with character data"""
	character_data = character

	var character_id = character.get("id", "")
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var highest_wave = character.get("highest_wave", 0)

	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var type_display_name = type_def.get("display_name", character_type.capitalize())
	var type_color = type_def.get("color", Color.GRAY)

	# Set icon color
	character_icon.color = type_color

	# Set labels
	name_label.text = character_name
	type_label.text = type_display_name
	type_label.add_theme_color_override("font_color", type_color)
	stats_label.text = "Level %d • Best Wave %d" % [character_level, highest_wave]

	# Style panel border with character type color
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)
	style.border_color = type_color
	style.border_width_left = 3
	style.corner_radius_top_left = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)

	# iOS HIG: Style delete button as destructive action (red)
	delete_button.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	delete_button.add_theme_color_override("font_hover_color", Color(1, 0.3, 0.3))
	delete_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.1, 0.1))

	# Connect buttons
	details_button.pressed.connect(_on_details_pressed)
	play_button.pressed.connect(_on_play_pressed)
	delete_button.pressed.connect(_on_delete_pressed)


func _on_details_pressed() -> void:
	"""Emit details signal"""
	details_pressed.emit(character_data.get("id", ""))


func _on_play_pressed() -> void:
	"""Emit play signal"""
	play_pressed.emit(character_data.get("id", ""))


func _on_delete_pressed() -> void:
	"""Emit delete signal"""
	delete_pressed.emit(character_data.get("id", ""), character_data.get("name", "Unknown"))
