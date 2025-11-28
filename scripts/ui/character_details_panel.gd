extends Control
## CharacterDetailsPanel - Three-column landscape character showcase
## Week 17 Phase 3: Character Details Overhaul (QA Pass 12)
##
## Design: Brotato-inspired clean layout optimized for landscape
## - Column 1 (Left): Portrait, Name, Type/Level, Aura
## - Column 2 (Center): Primary Stats (HP, DMG, ARM, SPD)
## - Column 3 (Right): Records + Currency
##
## Features:
## - Color-coded stat values (green positive, red negative, white neutral)
## - Compact, scannable Brotato-style stat rows
## - No emojis (iOS compatibility)

signal closed

# Showcase portrait paths (1024x1024 high-detail versions for Character Details)
# Week 18: Updated for CharacterTypeDatabase types
const SHOWCASE_PORTRAIT_PATHS = {
	"scavenger": "res://assets/ui/portraits/showcase/showcase_scavenger.png",
	"rustbucket": "res://assets/ui/portraits/showcase/showcase_rustbucket.png",
	"hotshot": "res://assets/ui/portraits/showcase/showcase_hotshot.png",
	"tinkerer": "res://assets/ui/portraits/showcase/showcase_tinkerer.png",
	"salvager": "res://assets/ui/portraits/showcase/showcase_salvager.png",
	"overclocked": "res://assets/ui/portraits/showcase/showcase_overclocked.png",
}

# Base stats for color comparison (green if above, red if below)
const BASE_STATS = {
	"max_hp": 100,
	"damage": 10,
	"armor": 0,
	"speed": 0,  # Speed shown as % modifier, 0 is base
}

# Node references - Three Column Layout
# Left Column
var portrait_panel: Panel
var portrait_texture: TextureRect
var character_name_label: Label
var character_type_label: Label
var aura_name: Label
var aura_description: Label

# Center Column - Primary Stats
var hp_value: Label
var damage_value: Label
var armor_value: Label
var speed_value: Label

# Right Column - Records & Currency
var kills_value: Label
var wave_value: Label
var deaths_value: Label
var scrap_value: Label
var nanites_value: Label
var components_value: Label


func _ready() -> void:
	# Get node references - Three Column Layout
	var layout = $MarginContainer/ThreeColumnLayout

	# Left Column
	var left_col = layout.get_node("LeftColumn")
	portrait_panel = left_col.get_node("PortraitPanel")
	portrait_texture = portrait_panel.get_node("PortraitTexture")
	character_name_label = left_col.get_node("CharacterNameLabel")
	character_type_label = left_col.get_node("CharacterTypeLabel")
	aura_name = left_col.get_node("AuraName")
	aura_description = left_col.get_node("AuraDescription")

	# Center Column - Stats
	var center_col = layout.get_node("CenterColumn")
	var stats_list = center_col.get_node("StatsList")
	hp_value = stats_list.get_node("HPRow/HPValue")
	damage_value = stats_list.get_node("DamageRow/DamageValue")
	armor_value = stats_list.get_node("ArmorRow/ArmorValue")
	speed_value = stats_list.get_node("SpeedRow/SpeedValue")

	# Right Column - Records & Currency
	var right_col = layout.get_node("RightColumn")
	var records_list = right_col.get_node("RecordsList")
	kills_value = records_list.get_node("KillsRow/KillsValue")
	wave_value = records_list.get_node("WaveRow/WaveValue")
	deaths_value = records_list.get_node("DeathsRow/DeathsValue")

	var currency_list = right_col.get_node("CurrencyList")
	scrap_value = currency_list.get_node("ScrapRow/ScrapValue")
	nanites_value = currency_list.get_node("NanitesRow/NanitesValue")
	components_value = currency_list.get_node("ComponentsRow/ComponentsValue")


func show_character(character: Dictionary) -> void:
	"""Display character details in three-column landscape layout"""
	GameLogger.debug(
		"[CharacterDetailsPanel] show_character()",
		{"name": character.get("name", "Unknown"), "id": character.get("id", "")}
	)

	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var aura_data = character.get("aura", {})
	var stats = character.get("stats", {})

	# Week 18 Phase 2: Use CharacterTypeDatabase
	var type_display_name = CharacterTypeDatabase.get_display_name(character_type)
	var type_color = _get_type_color(character_type)

	# LEFT COLUMN - Portrait with type-colored border
	_setup_portrait(character_type, type_color)

	# LEFT COLUMN - Name and type
	character_name_label.text = character_name
	character_name_label.add_theme_color_override("font_color", Color.WHITE)
	character_type_label.text = "%s • Level %d" % [type_display_name, character_level]
	character_type_label.add_theme_color_override("font_color", type_color)

	# LEFT COLUMN - Aura Section
	_setup_aura_section(character_type, aura_data)

	# CENTER COLUMN - Primary Stats with color coding
	var max_hp = stats.get("max_hp", 100)
	var damage = stats.get("damage", 10)
	var armor = stats.get("armor", 0)
	var speed_mod = stats.get("speed", 200) - 200  # Show as % modifier from base 200

	hp_value.text = str(max_hp)
	_color_stat_value(hp_value, max_hp, BASE_STATS.max_hp)

	damage_value.text = str(damage)
	_color_stat_value(damage_value, damage, BASE_STATS.damage)

	armor_value.text = str(armor)
	_color_stat_value(armor_value, armor, BASE_STATS.armor)

	speed_value.text = str(speed_mod)
	_color_stat_value(speed_value, speed_mod, BASE_STATS.speed)

	# RIGHT COLUMN - Records
	var total_kills = character.get("total_kills", 0)
	var highest_wave = character.get("highest_wave", 0)
	var death_count = character.get("death_count", 0)

	kills_value.text = _format_number(total_kills)
	_color_stat_value(kills_value, total_kills, 0)  # Green if any kills

	wave_value.text = str(highest_wave)
	_color_stat_value(wave_value, highest_wave, 0)  # Green if any waves

	deaths_value.text = str(death_count)
	# Deaths: red if any, white if zero
	if death_count > 0:
		deaths_value.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	else:
		deaths_value.add_theme_color_override("font_color", Color.WHITE)

	# RIGHT COLUMN - Currency (colors set in scene, just update values)
	var currency = character.get("starting_currency", {})
	scrap_value.text = _format_number(currency.get("scrap", 0))
	nanites_value.text = _format_number(currency.get("nanites", 0))
	components_value.text = _format_number(currency.get("components", 0))

	show()
	GameLogger.debug("[CharacterDetailsPanel] Panel displayed successfully (3-column layout)")


func _setup_portrait(character_type: String, type_color: Color) -> void:
	"""Setup portrait panel with type-colored border and silhouette"""
	var portrait_style = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.12, 0.12, 0.12, 1.0)
	portrait_style.border_color = type_color
	portrait_style.set_border_width_all(3)
	portrait_style.set_corner_radius_all(12)
	portrait_panel.add_theme_stylebox_override("panel", portrait_style)

	var texture_path = SHOWCASE_PORTRAIT_PATHS.get(character_type, "")
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		var texture = load(texture_path) as Texture2D
		if texture:
			portrait_texture.texture = texture
			GameLogger.debug(
				"[CharacterDetailsPanel] Showcase portrait loaded", {"type": character_type}
			)
	else:
		GameLogger.warning(
			"[CharacterDetailsPanel] Showcase portrait not found", {"type": character_type}
		)


func _setup_aura_section(character_type: String, aura_data: Dictionary) -> void:
	"""Setup aura section with name and description"""
	var aura_info = _get_type_aura_info(character_type)
	var aura_type = aura_data.get("type", "none")
	var aura_level = aura_data.get("level", 1)
	var type_color = _get_type_color(character_type)

	if aura_info.is_empty() or aura_type == null or aura_type == "none":
		# No aura (Commando) - show "Pure DPS" message
		aura_name.text = "No Aura - Pure DPS"
		aura_description.text = "Focuses on raw damage output"
		aura_name.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	else:
		aura_name.text = "%s Aura (Lv%d)" % [aura_info.get("name", "Special"), aura_level]
		aura_description.text = aura_info.get("description", "")
		aura_name.add_theme_color_override("font_color", type_color)


func _color_stat_value(label: Label, value: int, base: int) -> void:
	"""Color stat value: green if above base, red if below, white if equal"""
	if value > base:
		label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))  # Green
	elif value < base:
		label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))  # Red
	else:
		label.add_theme_color_override("font_color", Color.WHITE)


func _get_type_color(type_id: String) -> Color:
	"""Get the signature color for a character type (from Art Bible)"""
	var colors = {
		"scavenger": Color("#999999"),
		"tank": Color("#4D7A4D"),
		"commando": Color("#CC3333"),
		"mutant": Color("#8033B3"),
	}
	return colors.get(type_id, Color.GRAY)


func _get_type_aura_info(type_id: String) -> Dictionary:
	"""Get aura information for a character type (from AURA-SYSTEM.md)"""
	var auras = {
		"scavenger": {"name": "Collection", "description": "Auto-collects nearby items"},
		"tank": {"name": "Shield", "description": "Armor bonus to nearby allies"},
		"commando": {},  # No aura - pure DPS
		"mutant": {"name": "Damage", "description": "Damages nearby enemies"},
	}
	return auras.get(type_id, {})


func _format_number(value: int) -> String:
	"""Format large numbers with commas (e.g., 1523 → 1,523)"""
	var str_value = str(value)
	var result = ""
	var count = 0
	for i in range(str_value.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_value[i] + result
		count += 1
	return result
