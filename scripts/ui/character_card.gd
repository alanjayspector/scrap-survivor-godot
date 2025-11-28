extends Button
## @deprecated - Use CharacterTypeCard instead (Week 17 Phase 1)
## This component is no longer used. Scheduled for removal.
## Migration: scenes/ui/components/character_type_card.tscn
##
## CharacterCard - Tappable portrait card for character grid
## Phase 9.2: Simplified vertical card layout
##
## Features:
## - 180×240pt portrait card
## - Color-coded portrait by character type
## - Selection state border (orange when selected)
## - Entire card tappable → navigates to detail screen

signal card_pressed(character_id: String)

const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")

## Selection state colors
const COLOR_BORDER_UNSELECTED := Color("#5C5C5C")
const COLOR_BORDER_SELECTED := Color("#FF6600")
const COLOR_BADGE_BG := Color("#FF6600")

@onready var panel_bg: Panel = $PanelBg
@onready var portrait_rect: ColorRect = $ContentContainer/VBoxContainer/PortraitRect
@onready var name_label: Label = $ContentContainer/VBoxContainer/NameLabel
@onready var type_level_label: Label = $ContentContainer/VBoxContainer/TypeLevelLabel
@onready var stats_label: Label = $ContentContainer/VBoxContainer/StatsLabel
@onready var selection_badge: Panel = $SelectionBadge

var character_data: Dictionary = {}
var is_selected: bool = false


func _ready() -> void:
	# Connect button press
	pressed.connect(_on_card_pressed)


func setup(character: Dictionary) -> void:
	"""Initialize card with character data"""
	character_data = character

	var character_id = character.get("id", "")
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var highest_wave = character.get("highest_wave", 0)
	var max_hp = character.get("max_hp", 100)

	# Week 18 Phase 2: Use CharacterTypeDatabase
	var type_display_name = CharacterTypeDatabase.get_display_name(character_type)
	var type_color = CharacterTypeDatabase.get_color(character_type)

	# Set portrait color
	portrait_rect.color = type_color

	# Set labels
	name_label.text = character_name
	type_level_label.text = "%s • Lv.%d" % [type_display_name, character_level]
	stats_label.text = "HP %d • Wave %d" % [max_hp, highest_wave]

	# Check if this character is selected
	var active_id = GameState.active_character_id
	set_selected(character_id == active_id and not active_id.is_empty())

	GameLogger.debug(
		"[CharacterCard] Setup complete",
		{"id": character_id, "name": character_name, "is_selected": is_selected}
	)


func set_selected(selected: bool) -> void:
	"""Update selection visual state"""
	is_selected = selected

	# Update border
	var border_color = COLOR_BORDER_SELECTED if selected else COLOR_BORDER_UNSELECTED
	var border_width = 4 if selected else 2

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(8)
	panel_bg.add_theme_stylebox_override("panel", style)

	# Update badge visibility
	if selection_badge:
		selection_badge.visible = selected
		if selected:
			_style_selection_badge()


func _style_selection_badge() -> void:
	"""Style the selection badge as orange circle with checkmark"""
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = COLOR_BADGE_BG
	badge_style.set_corner_radius_all(16)  # 32pt badge / 2 = 16 radius for circle
	selection_badge.add_theme_stylebox_override("panel", badge_style)


func _on_card_pressed() -> void:
	"""Emit card pressed signal with character ID"""
	var char_id = character_data.get("id", "")
	GameLogger.debug("[CharacterCard] Card pressed", {"character_id": char_id})
	HapticManager.light()
	card_pressed.emit(char_id)
