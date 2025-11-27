extends Button
## SurvivorStatusPanel - Hub component showing active survivor
## Phase 9.3: Expert Panel specification
##
## Features:
## - 200×80pt panel in bottom-left of Hub
## - Shows: Portrait (60×60), Name, Level/Type, Stats
## - Tap → Navigate to Barracks
## - Empty state: "No Survivor Selected"
## - Reactive: Updates when selection changes

## Art Bible Colors
const COLOR_BACKGROUND := Color(0.102, 0.102, 0.102, 0.85)  # #1A1A1A at 85%
const COLOR_BORDER := Color(0.722, 0.361, 0.220)  # Rust Orange #B85C38
const COLOR_NAME := Color(0.769, 0.655, 0.490)  # Corrugated Tan #C4A77D
const COLOR_MUTED := Color(0.361, 0.361, 0.361)  # Scrap Gray #5C5C5C
const COLOR_EMPTY_ICON := Color(1.0, 0.784, 0.333)  # Window Yellow #FFC857

@onready var panel_bg: Panel = $PanelBg
@onready var portrait_rect: ColorRect = $ContentContainer/HBoxContainer/PortraitRect
@onready var portrait_label: Label = $ContentContainer/HBoxContainer/PortraitRect/PortraitLabel
@onready var name_label: Label = $ContentContainer/HBoxContainer/InfoContainer/NameLabel
@onready var type_level_label: Label = $ContentContainer/HBoxContainer/InfoContainer/TypeLevelLabel
@onready var stats_label: Label = $ContentContainer/HBoxContainer/InfoContainer/StatsLabel

var current_character_id: String = ""


func _ready() -> void:
	# Connect button press
	pressed.connect(_on_panel_pressed)

	# Subscribe to selection changes
	CharacterService.active_character_changed.connect(_on_active_character_changed)

	# Initial display
	_refresh_display()


func _exit_tree() -> void:
	# Disconnect signal to prevent errors
	if CharacterService.active_character_changed.is_connected(_on_active_character_changed):
		CharacterService.active_character_changed.disconnect(_on_active_character_changed)


func _on_active_character_changed(_character_id: String) -> void:
	"""Called when active character changes"""
	_refresh_display()


func _refresh_display() -> void:
	"""Update display based on current active character"""
	var active_id = CharacterService.get_active_character_id()

	if active_id.is_empty():
		_show_empty_state()
		return

	var character = CharacterService.get_character(active_id)
	if character.is_empty():
		_show_empty_state()
		return

	_show_character(character)
	current_character_id = active_id


func _show_character(character: Dictionary) -> void:
	"""Display character info in panel"""
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var highest_wave = character.get("highest_wave", 0)
	var max_hp = character.get("max_hp", 100)

	# Get type definition for color and display name
	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var type_display_name = type_def.get("display_name", character_type.capitalize())
	var type_color = type_def.get("color", Color.GRAY)

	# Set portrait color
	portrait_rect.color = type_color
	portrait_label.text = ""
	portrait_label.visible = false

	# Set labels - truncate name if too long
	var display_name = character_name
	if display_name.length() > 15:
		display_name = display_name.substr(0, 14) + "…"
	name_label.text = display_name
	name_label.add_theme_color_override("font_color", COLOR_NAME)

	type_level_label.text = "Lv.%d %s" % [character_level, type_display_name]
	type_level_label.add_theme_color_override("font_color", COLOR_MUTED)

	stats_label.text = "Wave %d • %d HP" % [highest_wave, max_hp]
	stats_label.add_theme_color_override("font_color", COLOR_MUTED)
	stats_label.visible = true

	_apply_panel_style()

	GameLogger.debug(
		"[SurvivorStatusPanel] Showing character",
		{"name": character_name, "type": character_type, "level": character_level}
	)


func _show_empty_state() -> void:
	"""Display empty state when no survivor selected"""
	current_character_id = ""

	# Portrait shows "?" icon
	portrait_rect.color = COLOR_MUTED
	portrait_label.text = "?"
	portrait_label.visible = true
	portrait_label.add_theme_color_override("font_color", COLOR_EMPTY_ICON)
	portrait_label.add_theme_font_size_override("font_size", 32)

	# Text labels - shortened to fit 200px panel
	name_label.text = "No Survivor"
	name_label.add_theme_color_override("font_color", COLOR_MUTED)

	type_level_label.text = "Tap to choose"
	type_level_label.add_theme_color_override("font_color", Color(COLOR_MUTED, 0.8))

	stats_label.visible = false

	_apply_panel_style()

	GameLogger.debug("[SurvivorStatusPanel] Showing empty state")


func _apply_panel_style() -> void:
	"""Apply Art Bible styling to panel background"""
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_BACKGROUND
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)

	# Subtle shadow effect
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)

	panel_bg.add_theme_stylebox_override("panel", style)


func _on_panel_pressed() -> void:
	"""Navigate to Barracks when panel is tapped"""
	HapticManager.light()
	GameLogger.info("[SurvivorStatusPanel] Panel tapped - navigating to Barracks")

	if ResourceLoader.exists("res://scenes/ui/barracks.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/barracks.tscn")
	else:
		GameLogger.error("[SurvivorStatusPanel] barracks.tscn not found")
