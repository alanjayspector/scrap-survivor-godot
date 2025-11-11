extends Control
## Character Selection UI Controller
## Week 8 Phase 3: Character selection screen with type previews and tier restrictions
##
## Features:
## - Display all character types with stat previews
## - Show locked/unlocked states based on user tier
## - "Try for 1 Run" free trial button
## - "Unlock Forever" tier upgrade CTA
## - Character creation flow

signal character_selected(character_id: String)
signal character_created(character_id: String)
signal tier_upgrade_requested(required_tier: int)
signal free_trial_requested(character_type: String)

## UI References (cached from scene tree with @onready for performance)
@onready var character_cards_container: HBoxContainer = get_node(
	"MarginContainer/VBoxContainer/CharacterCardsContainer"
)
@onready
var stat_comparison_panel: Panel = get_node("MarginContainer/VBoxContainer/StatComparisonPanel")
@onready
var create_button: Button = get_node("MarginContainer/VBoxContainer/ButtonsContainer/CreateButton")
@onready
var back_button: Button = get_node("MarginContainer/VBoxContainer/ButtonsContainer/BackButton")

## Currently selected character type
var selected_character_type: String = "scavenger"
var character_type_cards: Dictionary = {}


func _ready() -> void:
	_validate_ui_nodes()
	_create_character_type_cards()
	_connect_signals()
	_update_ui_for_tier()


func _validate_ui_nodes() -> void:
	# Validate that @onready nodes were found successfully
	if not character_cards_container:
		push_error("CharacterSelection: Failed to find CharacterCardsContainer node")
	if not stat_comparison_panel:
		push_warning("CharacterSelection: Failed to find StatComparisonPanel node")
	if not create_button:
		push_warning("CharacterSelection: Failed to find CreateButton node")
	if not back_button:
		push_warning("CharacterSelection: Failed to find BackButton node")


func _create_character_type_cards() -> void:
	if not character_cards_container:
		push_warning("CharacterSelection: character_cards_container not set")
		return

	# Create a card for each character type
	var character_types = ["scavenger", "tank", "commando", "mutant"]

	for char_type in character_types:
		if not CharacterService.CHARACTER_TYPES.has(char_type):
			continue

		var card = _create_character_card(char_type)
		character_cards_container.add_child(card)
		character_type_cards[char_type] = card


func _create_character_card(character_type: String) -> Control:
	var type_def = CharacterService.CHARACTER_TYPES[character_type]

	# Create card container
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 300)
	card.name = "Card_%s" % character_type

	# Create card layout
	var vbox = VBoxContainer.new()
	card.add_child(vbox)

	# Character type name
	var name_label = Label.new()
	name_label.text = type_def.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(name_label)

	# Color indicator (visual distinction)
	var color_rect = ColorRect.new()
	color_rect.color = type_def.color
	color_rect.custom_minimum_size = Vector2(180, 20)
	vbox.add_child(color_rect)

	# Description
	var desc_label = Label.new()
	desc_label.text = type_def.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	# Stat modifiers display
	var stats_label = Label.new()
	stats_label.text = _format_stat_modifiers(type_def.stat_modifiers)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stats_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(stats_label)

	# Aura type display
	var aura_label = Label.new()
	if type_def.aura_type:
		aura_label.text = "Aura: %s" % type_def.aura_type.capitalize()
	else:
		aura_label.text = "Aura: None"
	aura_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aura_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	vbox.add_child(aura_label)

	# Tier requirement badge
	var tier_label = Label.new()
	tier_label.text = _get_tier_name(type_def.tier_required)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match type_def.tier_required:
		CharacterService.UserTier.FREE:
			tier_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		CharacterService.UserTier.PREMIUM:
			tier_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
		CharacterService.UserTier.SUBSCRIPTION:
			tier_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.8))
	vbox.add_child(tier_label)

	# Select button
	var select_btn = Button.new()
	select_btn.text = "Select"
	select_btn.pressed.connect(_on_character_card_selected.bind(character_type))
	vbox.add_child(select_btn)

	# Lock overlay (if user can't access this character)
	var user_tier = CharacterService.get_tier()
	if type_def.tier_required > user_tier:
		_add_lock_overlay(card, character_type, type_def.tier_required)

	return card


func _add_lock_overlay(card: Control, character_type: String, required_tier: int) -> void:
	# Semi-transparent overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_child(overlay)

	# Lock icon (use label for now, can be replaced with icon)
	var lock_label = Label.new()
	lock_label.text = "🔒 LOCKED"
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 20)
	overlay.add_child(lock_label)

	# Center the lock label
	lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Unlock buttons container
	var buttons_vbox = VBoxContainer.new()
	buttons_vbox.set_anchors_preset(Control.PRESET_CENTER)
	buttons_vbox.position = Vector2(50, 150)
	overlay.add_child(buttons_vbox)

	# "Try for 1 Run" button
	var trial_btn = Button.new()
	trial_btn.text = "Try for 1 Run"
	trial_btn.pressed.connect(_on_free_trial_requested.bind(character_type))
	buttons_vbox.add_child(trial_btn)

	# "Unlock Forever" button
	var unlock_btn = Button.new()
	unlock_btn.text = "Unlock Forever"
	unlock_btn.pressed.connect(_on_unlock_requested.bind(required_tier))
	buttons_vbox.add_child(unlock_btn)


func _format_stat_modifiers(stat_mods: Dictionary) -> String:
	var lines: Array[String] = []
	for stat_name in stat_mods.keys():
		var value = stat_mods[stat_name]
		var sign = "+" if value >= 0 else ""
		lines.append("%s%s %s" % [sign, value, stat_name.capitalize()])
	return "\n".join(lines)


func _get_tier_name(tier: int) -> String:
	match tier:
		CharacterService.UserTier.FREE:
			return "FREE"
		CharacterService.UserTier.PREMIUM:
			return "PREMIUM"
		CharacterService.UserTier.SUBSCRIPTION:
			return "SUBSCRIPTION"
	return "UNKNOWN"


func _connect_signals() -> void:
	# Prevent double-connection errors
	if create_button and not create_button.is_connected("pressed", _on_create_character_pressed):
		create_button.pressed.connect(_on_create_character_pressed)
	if back_button and not back_button.is_connected("pressed", _on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)


func _update_ui_for_tier() -> void:
	# Refresh all cards to show/hide lock overlays
	for child in character_cards_container.get_children():
		child.queue_free()

	character_type_cards.clear()
	_create_character_type_cards()


func _on_character_card_selected(character_type: String) -> void:
	selected_character_type = character_type
	GameLogger.info("Character type selected", {"type": character_type})

	# Update visual indication (could add highlight to selected card)
	_highlight_selected_card(character_type)


func _highlight_selected_card(character_type: String) -> void:
	# Remove highlight from all cards
	for card_type in character_type_cards.keys():
		var card = character_type_cards[card_type]
		if card is PanelContainer:
			# Reset modulate
			card.modulate = Color(1, 1, 1, 1)

	# Highlight selected card
	if character_type_cards.has(character_type):
		var card = character_type_cards[character_type]
		if card is PanelContainer:
			card.modulate = Color(1.2, 1.2, 1.2, 1)


func _on_create_character_pressed() -> void:
	# Check if user can create this character type
	var user_tier = CharacterService.get_tier()
	var type_def = CharacterService.CHARACTER_TYPES[selected_character_type]

	if type_def.tier_required > user_tier:
		GameLogger.warning(
			"Cannot create character - tier too low",
			{
				"type": selected_character_type,
				"required": type_def.tier_required,
				"current": user_tier
			}
		)
		# Show error message to user
		_show_tier_restriction_message()
		return

	# Check if player has available slots
	if not CharacterService.can_create_character():
		GameLogger.warning("Cannot create character - slot limit reached")
		_show_slot_limit_message()
		return

	# Create character (would normally open a name input dialog)
	var character_name = "Hero_%d" % randi()
	var character_id = CharacterService.create_character(character_name, selected_character_type)

	if character_id != "":
		GameLogger.info(
			"Character created successfully", {"id": character_id, "type": selected_character_type}
		)
		character_created.emit(character_id)

		# Auto-launch demo after creating character
		_launch_demo(character_id)


func _launch_demo(character_id: String) -> void:
	"""Launch the gameplay demo with the selected/created character"""
	print("[CharacterSelection] _launch_demo called with character_id: ", character_id)

	# Set as active character
	CharacterService.set_active_character(character_id)
	print("[CharacterSelection] Active character set")

	# Verify active character was set
	var active = CharacterService.get_active_character()
	if active:
		print("[CharacterSelection] Verified active character: ", active.id)
	else:
		print("[CharacterSelection] ERROR: Failed to set active character!")

	# Change to Wasteland scene for wave-based combat
	print("[CharacterSelection] Changing scene to wasteland.tscn")
	get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")


func _on_back_pressed() -> void:
	# Return to previous screen
	queue_free()


func _on_free_trial_requested(character_type: String) -> void:
	GameLogger.info("Free trial requested", {"type": character_type})
	free_trial_requested.emit(character_type)

	# Emit analytics event
	# AnalyticsService.track_event("free_trial_started", {"character_type": character_type})


func _on_unlock_requested(required_tier: int) -> void:
	GameLogger.info("Tier upgrade requested", {"required_tier": required_tier})
	tier_upgrade_requested.emit(required_tier)

	# Emit analytics event
	# AnalyticsService.track_event("tier_upgrade_viewed", {"required_tier": required_tier})


func _show_tier_restriction_message() -> void:
	# TODO: Show proper modal dialog
	GameLogger.warning("This character type requires a higher tier subscription")


func _show_slot_limit_message() -> void:
	# TODO: Show proper modal dialog
	GameLogger.warning("Character slot limit reached. Delete a character or upgrade tier.")


## Public API for external control
func set_user_tier(tier: int) -> void:
	CharacterService.set_tier(tier)
	_update_ui_for_tier()


func get_selected_character_type() -> String:
	return selected_character_type
