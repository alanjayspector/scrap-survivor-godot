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

const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

@onready var character_icon: ColorRect = $HBoxContainer/CharacterIcon
@onready var name_label: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var type_label: Label = $HBoxContainer/InfoContainer/TypeLabel
@onready var stats_label: Label = $HBoxContainer/InfoContainer/StatsLabel
@onready var details_button: Button = $HBoxContainer/DetailsButton
@onready var play_button: Button = $HBoxContainer/PlayButton
@onready var delete_button: Button = $HBoxContainer/DeleteButton

var character_data: Dictionary = {}

# Week 16 Phase 4: Progressive delete confirmation (prevent accidental taps)
var _delete_confirm_state: int = 0  # 0 = normal, 1 = warning, 2 = executing
var _confirm_timer: Timer = null
var _original_delete_text: String = ""


func setup(character: Dictionary) -> void:
	"""Initialize card with character data"""
	character_data = character

	var character_id = character.get("id", "")
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var highest_wave = character.get("highest_wave", 0)

	GameLogger.info(
		"[CharacterCard] Setup starting",
		{"id": character_id, "name": character_name, "buttons_exist": details_button != null}
	)

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

	# Apply button styling
	THEME_HELPER.apply_button_style(details_button, THEME_HELPER.ButtonStyle.SECONDARY)
	THEME_HELPER.apply_button_style(play_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(delete_button, THEME_HELPER.ButtonStyle.DANGER)

	# Apply button icons
	UI_ICONS.apply_button_icon(delete_button, UI_ICONS.Icon.DELETE)

	# Store original delete button text
	_original_delete_text = delete_button.text

	# Connect buttons
	details_button.pressed.connect(_on_details_pressed)
	play_button.pressed.connect(_on_play_pressed)
	delete_button.pressed.connect(_on_delete_pressed)

	GameLogger.info(
		"[CharacterCard] Setup complete, buttons connected",
		{
			"id": character_id,
			"details_disabled": details_button.disabled,
			"play_disabled": play_button.disabled,
			"delete_disabled": delete_button.disabled
		}
	)


func _on_details_pressed() -> void:
	"""Emit details signal"""
	var char_id = character_data.get("id", "")
	GameLogger.info("[CharacterCard] Details button pressed", {"character_id": char_id})
	HapticManager.light()
	details_pressed.emit(char_id)
	GameLogger.info("[CharacterCard] Details signal emitted", {"character_id": char_id})


func _on_play_pressed() -> void:
	"""Emit play signal"""
	var char_id = character_data.get("id", "")
	GameLogger.info("[CharacterCard] Play button pressed", {"character_id": char_id})
	HapticManager.light()
	play_pressed.emit(char_id)
	GameLogger.info("[CharacterCard] Play signal emitted", {"character_id": char_id})


func _on_delete_pressed() -> void:
	"""Progressive delete confirmation (Week 16 Phase 4 - prevent accidental deletions)"""
	GameLogger.info(
		"[CharacterCard] Delete button pressed",
		{"character_id": character_data.get("id", ""), "state": _delete_confirm_state}
	)
	if _delete_confirm_state == 0:
		# First tap - show warning state
		_delete_confirm_state = 1
		delete_button.text = "Tap Again to Confirm"
		HapticManager.warning()  # Warning haptic

		# Start 3-second reset timer
		if _confirm_timer:
			_confirm_timer.queue_free()

		_confirm_timer = Timer.new()
		_confirm_timer.wait_time = 3.0
		_confirm_timer.one_shot = true
		_confirm_timer.timeout.connect(_reset_delete_button)
		add_child(_confirm_timer)
		_confirm_timer.start()

	elif _delete_confirm_state == 1:
		# Second tap - execute deletion
		_delete_confirm_state = 2
		delete_button.text = "Deleting..."
		delete_button.disabled = true
		HapticManager.heavy()  # Heavy haptic for destructive action

		# Emit delete signal
		delete_pressed.emit(character_data.get("id", ""), character_data.get("name", "Unknown"))

		# Note: Button will be reset when card is removed from scene


func _reset_delete_button() -> void:
	"""Reset delete button to normal state after timeout"""
	_delete_confirm_state = 0
	delete_button.text = _original_delete_text
	delete_button.disabled = false

	if _confirm_timer:
		_confirm_timer.queue_free()
		_confirm_timer = null
