extends Panel
## CharacterDetailsPanel - Tabbed character information panel
## Week 15 Phase 3: Modern mobile UI redesign
##
## Features:
## - 3-tab layout: Stats | Gear | Records
## - Primary stats card with 4 key stats + icons
## - Collapsible stat categories (Offense/Defense/Utility)
## - Readable fonts (18-20px) for accessibility

signal closed

# UI references (set in _ready to keep lines short)
var character_name_label: Label
var character_type_label: Label
var aura_label: Label
var tab_container: TabContainer
var hp_label: Label
var damage_label: Label
var armor_label: Label
var speed_label: Label
var collapsible_stats: VBoxContainer
var items_label: Label
var kills_value: Label
var wave_value: Label
var deaths_value: Label
var scrap_value: Label
var nanites_value: Label
var components_value: Label
var close_button: Button

# Track expanded state of collapsible sections
var _expanded_sections: Dictionary = {"Offense": false, "Defense": false, "Utility": false}


func _ready() -> void:
	# Get node references (paths split for line length compliance)
	var vbox = $MarginContainer/VBoxContainer
	var header = vbox.get_node("HeaderContainer")
	character_name_label = header.get_node("CharacterNameLabel")
	character_type_label = header.get_node("CharacterTypeLabel")
	aura_label = vbox.get_node("AuraContainer/AuraLabel")
	tab_container = vbox.get_node("TabContainer")
	close_button = vbox.get_node("CloseButton")

	# Stats tab references
	var stats_grid = tab_container.get_node("Stats/StatsContent/PrimaryStatsCard/PrimaryStatsGrid")
	hp_label = stats_grid.get_node("HPContainer/HPLabel")
	damage_label = stats_grid.get_node("DamageContainer/DamageLabel")
	armor_label = stats_grid.get_node("ArmorContainer/ArmorLabel")
	speed_label = stats_grid.get_node("SpeedContainer/SpeedLabel")
	collapsible_stats = tab_container.get_node("Stats/StatsContent/CollapsibleStats")

	# Gear tab
	items_label = tab_container.get_node("Gear/ItemsLabel")

	# Records tab
	var records_grid = tab_container.get_node("Records/RecordsGrid")
	kills_value = records_grid.get_node("KillsValue")
	wave_value = records_grid.get_node("WaveValue")
	deaths_value = records_grid.get_node("DeathsValue")
	var currency_grid = tab_container.get_node("Records/CurrencyGrid")
	scrap_value = currency_grid.get_node("ScrapValue")
	nanites_value = currency_grid.get_node("NanitesValue")
	components_value = currency_grid.get_node("ComponentsValue")

	close_button.pressed.connect(_on_close_pressed)
	tab_container.current_tab = 0  # Start on Stats tab

	# Apply button styling
	ThemeHelper.apply_button_style(close_button, ThemeHelper.ButtonStyle.SECONDARY)


func show_character(character: Dictionary) -> void:
	"""Display full character details in tabbed layout"""
	var character_id = character.get("id", "")
	var character_name = character.get("name", "Unknown")
	var character_type = character.get("character_type", "scavenger")
	var character_level = character.get("level", 1)
	var aura_data = character.get("aura", {})
	var stats = character.get("stats", {})

	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var type_display_name = type_def.get("display_name", character_type.capitalize())
	var type_color = type_def.get("color", Color.GRAY)

	# Header - Compact format
	character_name_label.text = character_name
	character_type_label.text = "%s • Level %d" % [type_display_name, character_level]
	character_type_label.add_theme_color_override("font_color", type_color)

	# Aura
	var aura_type = aura_data.get("type", "none")
	var aura_level = aura_data.get("level", 1)
	if aura_type == null or aura_type == "none":
		aura_label.text = "None (Pure DPS)"
	else:
		aura_label.text = "%s (Level %d)" % [aura_type.capitalize(), aura_level]

	# Stats Tab - Primary Stats Card
	_update_primary_stats(stats)

	# Stats Tab - Collapsible sections
	await _populate_collapsible_stats(stats)

	# Gear Tab
	items_label.text = "No equipped items yet"

	# Records Tab
	kills_value.text = str(character.get("total_kills", 0))
	wave_value.text = str(character.get("highest_wave", 0))
	deaths_value.text = str(character.get("death_count", 0))

	# Currency
	var currency = character.get("starting_currency", {})
	scrap_value.text = str(currency.get("scrap", 0))
	nanites_value.text = str(currency.get("nanites", 0))
	components_value.text = str(currency.get("components", 0))

	# Reset to Stats tab and show
	tab_container.current_tab = 0
	show()


func _update_primary_stats(stats: Dictionary) -> void:
	"""Update the 4 primary stats in the always-visible card"""
	hp_label.text = "%d HP" % stats.get("max_hp", 100)
	damage_label.text = "%d DMG" % stats.get("damage", 10)
	armor_label.text = "%d ARM" % stats.get("armor", 0)
	speed_label.text = "%d SPD" % stats.get("speed", 200)


func _populate_collapsible_stats(stats: Dictionary) -> void:
	"""Create collapsible sections for secondary stats"""
	# Clear existing
	for child in collapsible_stats.get_children():
		child.queue_free()

	await get_tree().process_frame

	# Offense section (collapsed by default)
	_add_collapsible_section(
		"Offense",
		[
			["[CRIT] Crit Chance", "%d%%" % int(stats.get("crit_chance", 0.05) * 100)],
			["[ASPD] Attack Speed", "%d%%" % int(stats.get("attack_speed", 0))],
			["[MEL] Melee DMG", str(stats.get("melee_damage", 0))],
			["[RNG] Ranged DMG", str(stats.get("ranged_damage", 0))],
			["[RES] Resonance", str(stats.get("resonance", 0))],
		]
	)

	# Defense section
	_add_collapsible_section(
		"Defense",
		[
			["[DOD] Dodge", "%d%%" % int(stats.get("dodge", 0) * 100)],
			["[LS] Life Steal", "%d%%" % int(stats.get("life_steal", 0) * 100)],
			["[REG] HP Regen", str(stats.get("hp_regen", 0))],
		]
	)

	# Utility section
	_add_collapsible_section(
		"Utility",
		[
			["[LCK] Luck", str(stats.get("luck", 0))],
			["[PKP] Pickup Range", str(stats.get("pickup_range", 100))],
			["[SCV] Scavenging", "%d%%" % int(stats.get("scavenging", 0))],
		]
	)

	await get_tree().process_frame


func _add_collapsible_section(section_name: String, stat_rows: Array) -> void:
	"""Add a collapsible section with header button and stat rows"""
	var section_container = VBoxContainer.new()
	section_container.name = section_name + "Section"
	collapsible_stats.add_child(section_container)  # Parent FIRST
	section_container.layout_mode = Control.LAYOUT_MODE_CONTAINER  # Explicit Mode 2 for iOS
	section_container.add_theme_constant_override("separation", 4)

	# Header button (tap to expand/collapse)
	var header_btn = Button.new()
	header_btn.name = section_name + "Header"
	section_container.add_child(header_btn)  # Parent FIRST
	header_btn.layout_mode = Control.LAYOUT_MODE_CONTAINER  # Explicit Mode 2 for iOS
	header_btn.custom_minimum_size = Vector2(0, 44)  # Touch-friendly
	header_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_update_section_header(header_btn, section_name, _expanded_sections.get(section_name, false))
	header_btn.add_theme_font_size_override("font_size", 18)
	header_btn.pressed.connect(_on_section_toggled.bind(section_name, section_container))

	# Content container (stats)
	var content = VBoxContainer.new()
	content.name = section_name + "Content"
	section_container.add_child(content)  # Parent FIRST
	content.layout_mode = Control.LAYOUT_MODE_CONTAINER  # Explicit Mode 2 for iOS
	content.add_theme_constant_override("separation", 6)
	content.visible = _expanded_sections.get(section_name, false)

	for stat_data in stat_rows:
		var row = _create_stat_row(stat_data[0], stat_data[1])
		content.add_child(row)


func _create_stat_row(stat_name: String, stat_value: String) -> HBoxContainer:
	"""Create a single stat row with icon+name and value"""
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 28)

	var name_label = Label.new()
	hbox.add_child(name_label)  # Parent FIRST
	name_label.layout_mode = Control.LAYOUT_MODE_CONTAINER  # Explicit Mode 2 for iOS
	name_label.text = stat_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 18)

	var value_label = Label.new()
	hbox.add_child(value_label)  # Parent FIRST
	value_label.layout_mode = Control.LAYOUT_MODE_CONTAINER  # Explicit Mode 2 for iOS
	value_label.text = stat_value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 18)

	return hbox


func _on_section_toggled(section_name: String, section_container: VBoxContainer) -> void:
	"""Toggle a collapsible section"""
	_expanded_sections[section_name] = not _expanded_sections.get(section_name, false)
	var is_expanded = _expanded_sections[section_name]

	# Update header text
	var header_btn = section_container.get_node(section_name + "Header") as Button
	_update_section_header(header_btn, section_name, is_expanded)

	# Show/hide content
	var content = section_container.get_node(section_name + "Content")
	content.visible = is_expanded


func _update_section_header(header_btn: Button, section_name: String, is_expanded: bool) -> void:
	"""Update section header with expand/collapse indicator"""
	var arrow = "[-] " if is_expanded else "[+] "
	header_btn.text = arrow + section_name
	# Apply ghost button styling for collapsible headers
	ThemeHelper.apply_button_style(header_btn, ThemeHelper.ButtonStyle.GHOST)


func _on_close_pressed() -> void:
	"""Handle close button"""
	closed.emit()
	hide()
