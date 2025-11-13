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
@onready var character_cards_container: VBoxContainer = get_node(
	"MarginContainer/VBoxContainer/ScrollContainer/CharacterCardsContainer"
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

	# Create card container with professional styling (Week 13 Phase 2)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(340, 420)  # Increased from 280×400 for more breathing room
	card.name = "Card_%s" % character_type

	# Apply StyleBoxFlat for professional mobile game look
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15, 0.95)  # Dark semi-transparent background
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	style_box.border_width_left = 3
	style_box.border_width_top = 3
	style_box.border_width_right = 3
	style_box.border_width_bottom = 3
	style_box.border_color = type_def.color  # Character type color border
	style_box.shadow_size = 8
	style_box.shadow_color = Color(0, 0, 0, 0.5)
	style_box.content_margin_left = 12
	style_box.content_margin_right = 12
	style_box.content_margin_top = 12
	style_box.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", style_box)

	# Create card layout
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)  # Better spacing between elements
	card.add_child(vbox)

	# Character type color header (full-width, professional look)
	var header_panel = PanelContainer.new()
	header_panel.custom_minimum_size = Vector2(0, 60)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = type_def.color.lightened(0.2)  # Slightly brighter for visibility
	header_style.corner_radius_top_left = 8
	header_style.corner_radius_top_right = 8
	header_panel.add_theme_stylebox_override("panel", header_style)
	vbox.add_child(header_panel)

	# Character type name on colored header
	var name_label = Label.new()
	name_label.text = type_def.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 32)  # Larger, bolder
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 3)
	header_panel.add_child(name_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = type_def.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 24)  # Mobile UX: body text minimum
	desc_label.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_label.add_theme_constant_override("outline_size", 3)
	vbox.add_child(desc_label)

	# Stat modifiers display with visual icons (Week 13 Phase 2)
	var stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 6)
	vbox.add_child(stats_container)

	# Add each stat with a colored icon
	for stat_name in type_def.stat_modifiers.keys():
		var value = type_def.stat_modifiers[stat_name]
		var stat_row = HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 8)

		# Stat icon (color-coded by category)
		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(12, 12)
		icon.color = _get_stat_color(stat_name)
		stat_row.add_child(icon)

		# Stat label
		var stat_label = Label.new()
		var sign = "+" if value >= 0 else ""
		stat_label.text = "%s%s %s" % [sign, value, stat_name.capitalize()]
		stat_label.add_theme_font_size_override("font_size", 22)
		stat_label.add_theme_color_override("font_outline_color", Color.BLACK)
		stat_label.add_theme_constant_override("outline_size", 2)
		stat_row.add_child(stat_label)

		stats_container.add_child(stat_row)

	# Aura type display
	var aura_label = Label.new()
	if type_def.aura_type:
		aura_label.text = "Aura: %s" % type_def.aura_type.capitalize()
	else:
		aura_label.text = "Aura: None"
	aura_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aura_label.add_theme_font_size_override("font_size", 22)  # Mobile UX: readable stat info
	aura_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	aura_label.add_theme_color_override("font_outline_color", Color.BLACK)
	aura_label.add_theme_constant_override("outline_size", 3)
	vbox.add_child(aura_label)

	# Tier requirement badge
	var tier_label = Label.new()
	tier_label.text = _get_tier_name(type_def.tier_required)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_label.add_theme_font_size_override("font_size", 22)  # Mobile UX: readable tier info
	tier_label.add_theme_color_override("font_outline_color", Color.BLACK)
	tier_label.add_theme_constant_override("outline_size", 3)
	match type_def.tier_required:
		CharacterService.UserTier.FREE:
			tier_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		CharacterService.UserTier.PREMIUM:
			tier_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
		CharacterService.UserTier.SUBSCRIPTION:
			tier_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.8))
	vbox.add_child(tier_label)

	# Select button (iOS HIG compliant - Round 4)
	var select_btn = Button.new()
	select_btn.text = "Select"
	select_btn.custom_minimum_size = Vector2(220, 60)
	select_btn.add_theme_font_size_override("font_size", 28)
	select_btn.pressed.connect(_on_character_card_selected.bind(character_type))
	vbox.add_child(select_btn)

	# Lock overlay (if user can't access this character)
	var user_tier = CharacterService.get_tier()
	if type_def.tier_required > user_tier:
		_add_lock_overlay(card, character_type, type_def.tier_required)

	return card


func _add_lock_overlay(card: Control, character_type: String, required_tier: int) -> void:
	# Professional lock overlay (Week 13 Phase 2)
	var overlay = Panel.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Semi-transparent dark overlay with rounded corners
	var overlay_style = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0, 0, 0, 0.85)  # Darker for locked state
	overlay_style.corner_radius_top_left = 12
	overlay_style.corner_radius_top_right = 12
	overlay_style.corner_radius_bottom_left = 12
	overlay_style.corner_radius_bottom_right = 12
	overlay.add_theme_stylebox_override("panel", overlay_style)
	card.add_child(overlay)

	# Lock content container
	var lock_content = VBoxContainer.new()
	lock_content.set_anchors_preset(Control.PRESET_CENTER)
	lock_content.position = Vector2(-100, -80)
	lock_content.custom_minimum_size = Vector2(200, 160)
	lock_content.add_theme_constant_override("separation", 16)
	overlay.add_child(lock_content)

	# Lock icon with background
	var lock_icon_bg = PanelContainer.new()
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	icon_style.corner_radius_top_left = 8
	icon_style.corner_radius_top_right = 8
	icon_style.corner_radius_bottom_left = 8
	icon_style.corner_radius_bottom_right = 8
	lock_icon_bg.add_theme_stylebox_override("panel", icon_style)
	lock_content.add_child(lock_icon_bg)

	# Lock icon label
	var lock_label = Label.new()
	lock_label.text = "🔒"
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 48)
	lock_icon_bg.add_child(lock_label)

	# Tier requirement badge
	var tier_badge = Label.new()
	tier_badge.text = _get_tier_name(required_tier) + " REQUIRED"
	tier_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_badge.add_theme_font_size_override("font_size", 22)
	tier_badge.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))  # Orange/gold
	tier_badge.add_theme_color_override("font_outline_color", Color.BLACK)
	tier_badge.add_theme_constant_override("outline_size", 3)
	lock_content.add_child(tier_badge)

	# Unlock buttons container
	var buttons_vbox = VBoxContainer.new()
	buttons_vbox.set_anchors_preset(Control.PRESET_CENTER)
	buttons_vbox.position = Vector2(50, 150)
	overlay.add_child(buttons_vbox)

	# "Try for 1 Run" button (iOS HIG compliant - Round 4)
	var trial_btn = Button.new()
	trial_btn.text = "Try for 1 Run"
	trial_btn.custom_minimum_size = Vector2(200, 60)
	trial_btn.add_theme_font_size_override("font_size", 24)
	trial_btn.pressed.connect(_on_free_trial_requested.bind(character_type))
	buttons_vbox.add_child(trial_btn)

	# "Unlock Forever" button (iOS HIG compliant - Round 4)
	var unlock_btn = Button.new()
	unlock_btn.text = "Unlock Forever"
	unlock_btn.custom_minimum_size = Vector2(200, 60)
	unlock_btn.add_theme_font_size_override("font_size", 24)
	unlock_btn.pressed.connect(_on_unlock_requested.bind(required_tier))
	buttons_vbox.add_child(unlock_btn)


func _get_stat_color(stat_name: String) -> Color:
	"""Return color-coded stat icon based on stat category (Week 13 Phase 2)"""
	# HP/Armor: Red/Orange
	if stat_name in ["max_hp", "armor", "hp_regen"]:
		return Color(0.9, 0.3, 0.2)  # Red

	# Damage/Speed: Yellow/Green
	if stat_name in ["damage", "attack_speed", "speed"]:
		return Color(0.9, 0.8, 0.2)  # Yellow

	# Utility (pickup_range, luck, etc.): Blue/Purple
	if stat_name in ["pickup_range", "luck", "scavenging"]:
		return Color(0.3, 0.6, 0.9)  # Blue

	# Default: Grey
	return Color(0.7, 0.7, 0.7)


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

	# Tap feedback animation (Week 13 Phase 2 - Professional mobile game feel)
	if character_type_cards.has(character_type):
		var card = character_type_cards[character_type]
		if card:
			# Scale animation: 1.0 → 1.05 → 1.0 (tactile feedback)
			var tween = create_tween()
			tween.set_parallel(false)
			tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.1)
			tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.1)

	# Update visual indication (highlight selected card)
	_highlight_selected_card(character_type)


func _highlight_selected_card(character_type: String) -> void:
	# Remove highlight from all cards (Week 13 Phase 2 - Enhanced visual feedback)
	for card_type in character_type_cards.keys():
		var card = character_type_cards[card_type]
		if card is PanelContainer:
			# Reset to normal state
			card.modulate = Color(1, 1, 1, 1)

			# Reset border width
			var style = card.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				style.border_width_left = 3
				style.border_width_top = 3
				style.border_width_right = 3
				style.border_width_bottom = 3

	# Highlight selected card with glow effect
	if character_type_cards.has(character_type):
		var card = character_type_cards[character_type]
		if card is PanelContainer:
			# Brighter glow
			card.modulate = Color(1.2, 1.2, 1.2, 1)

			# Thicker border for selected card
			var style = card.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				style.border_width_left = 5  # Thicker border (3px → 5px)
				style.border_width_top = 5
				style.border_width_right = 5
				style.border_width_bottom = 5


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
