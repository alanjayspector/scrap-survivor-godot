extends Panel
## CharacterDetailsPanel - Full character information preview
## Week 15 Phase 3: Game Designer recommendation
##
## Features:
## - Display all character information
## - Aura type and level
## - All 14 stats with values
## - Equipped items (when inventory system exists)
## - Character records (kills, waves, deaths)
## - Close button to dismiss

signal closed

@onready
var character_name_label: Label = $MarginContainer/VBoxContainer/HeaderContainer/CharacterNameLabel
@onready
var character_type_label: Label = $MarginContainer/VBoxContainer/HeaderContainer/CharacterTypeLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/HeaderContainer/LevelLabel
@onready var aura_label: Label = $MarginContainer/VBoxContainer/AuraContainer/AuraLabel
@onready
var stats_container: VBoxContainer = $MarginContainer/VBoxContainer/StatsScrollContainer/StatsContainer
@onready var items_label: Label = $MarginContainer/VBoxContainer/ItemsContainer/ItemsLabel
@onready var records_label: Label = $MarginContainer/VBoxContainer/RecordsContainer/RecordsLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)


func show_character(character: Dictionary) -> void:
	"""Display full character details"""
	var character_id = character.get("id", "")
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var aura_data = character.get("aura", {})
	var stats = character.get("stats", {})

	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var type_display_name = type_def.get("display_name", character_type.capitalize())
	var type_color = type_def.get("color", Color.GRAY)

	# Header
	character_name_label.text = character_name
	character_type_label.text = type_display_name
	character_type_label.add_theme_color_override("font_color", type_color)
	level_label.text = "Level %d" % character_level

	# Aura
	var aura_type = aura_data.get("type", "none")
	var aura_level = aura_data.get("level", 1)
	if aura_type == null or aura_type == "none":
		aura_label.text = "Aura: None (Pure DPS build)"
	else:
		aura_label.text = "Aura: %s (Level %d)" % [aura_type.capitalize(), aura_level]

	# Stats - Display all 14 stats
	_populate_stats(stats)

	# Items (placeholder for future inventory system)
	items_label.text = "No equipped items (Inventory system coming in Week 16+)"

	# Records
	var total_kills = character.get("total_kills", 0)
	var highest_wave = character.get("highest_wave", 0)
	var death_count = character.get("death_count", 0)

	# Currency (Week 15 Phase 4)
	var currency = character.get("starting_currency", {})
	var scrap = currency.get("scrap", 0)
	var nanites = currency.get("nanites", 0)
	var components = currency.get("components", 0)

	records_label.text = (
		"Total Kills: %d\nHighest Wave: %d\nDeaths: %d\n\nCurrency:\nScrap: %d\nNanites: %d\nComponents: %d"
		% [total_kills, highest_wave, death_count, scrap, nanites, components]
	)

	# Show panel
	show()
	GameLogger.info("[CharacterDetailsPanel] Showing details", {"character_id": character_id})


func _populate_stats(stats: Dictionary) -> void:
	"""Populate all 14 stats in organized categories"""
	# Clear existing stats
	for child in stats_container.get_children():
		child.queue_free()

	# Core Survival Stats
	_add_stat_category("Core Survival")
	_add_stat_row("Max HP", stats.get("max_hp", 100))
	_add_stat_row("HP Regen", stats.get("hp_regen", 0))
	_add_stat_row("Life Steal", "%d%%" % int(stats.get("life_steal", 0) * 100))
	_add_stat_row("Armor", stats.get("armor", 0))

	# Offense Stats
	_add_stat_category("Offense")
	_add_stat_row("Damage", stats.get("damage", 10))
	_add_stat_row("Melee Damage", stats.get("melee_damage", 0))
	_add_stat_row("Ranged Damage", stats.get("ranged_damage", 0))
	_add_stat_row("Attack Speed", "%d%%" % int(stats.get("attack_speed", 0)))
	_add_stat_row("Crit Chance", "%d%%" % int(stats.get("crit_chance", 0.05) * 100))
	_add_stat_row("Resonance", stats.get("resonance", 0))

	# Defense Stats
	_add_stat_category("Defense")
	_add_stat_row("Dodge", "%d%%" % int(stats.get("dodge", 0) * 100))

	# Utility Stats
	_add_stat_category("Utility")
	_add_stat_row("Speed", stats.get("speed", 200))
	_add_stat_row("Luck", stats.get("luck", 0))
	_add_stat_row("Pickup Range", stats.get("pickup_range", 100))
	_add_stat_row("Scavenging", "%d%%" % int(stats.get("scavenging", 0)))


func _add_stat_category(category_name: String) -> void:
	"""Add a stat category header"""
	var category_label = Label.new()
	category_label.text = category_name
	category_label.add_theme_font_size_override("font_size", 18)
	category_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))
	stats_container.add_child(category_label)


func _add_stat_row(stat_name: String, stat_value) -> void:
	"""Add a stat row (name + value)"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var name_label = Label.new()
	name_label.text = stat_name + ":"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(name_label)

	var value_label = Label.new()
	value_label.text = str(stat_value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value_label)

	stats_container.add_child(hbox)


func _on_close_pressed() -> void:
	"""Handle close button"""
	GameLogger.info("[CharacterDetailsPanel] Closed")
	closed.emit()
	hide()
