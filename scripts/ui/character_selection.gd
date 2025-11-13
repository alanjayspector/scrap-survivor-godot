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
@onready var character_cards_container: GridContainer = get_node(
	"MarginContainer/VBoxContainer/CharacterCardsContainer"
)
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

	# Create card container with professional styling (Week 13 Phase 2: Grid layout)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(170, 330)  # 2×2 grid optimized, increased height for breathing room
	card.name = "Card_%s" % character_type

	# Apply StyleBoxFlat for professional mobile game look
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15, 0.95)  # Dark semi-transparent background
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = type_def.color  # Character type color border
	style_box.shadow_size = 4
	style_box.shadow_color = Color(0, 0, 0, 0.5)
	style_box.content_margin_left = 6
	style_box.content_margin_right = 6
	style_box.content_margin_top = 6
	style_box.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", style_box)

	# Create card layout
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)  # Very tight for grid
	card.add_child(vbox)

	# Character type color header (compact for grid)
	var header_panel = PanelContainer.new()
	header_panel.custom_minimum_size = Vector2(0, 36)  # Slightly larger header
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = type_def.color.lightened(0.2)  # Slightly brighter for visibility
	header_style.corner_radius_top_left = 6
	header_style.corner_radius_top_right = 6
	header_panel.add_theme_stylebox_override("panel", header_style)
	vbox.add_child(header_panel)

	# Character type name on colored header
	var name_label = Label.new()
	name_label.text = type_def.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)  # Larger for readability
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 2)
	header_panel.add_child(name_label)

	# Description (abbreviated for grid layout)
	var desc_label = Label.new()
	desc_label.text = type_def.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 13)  # Larger for readability
	desc_label.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_label.add_theme_constant_override("outline_size", 1)
	vbox.add_child(desc_label)

	# Stat modifiers display with visual icons (Week 13 Phase 2: Grid optimized)
	var stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 2)  # Very tight spacing
	vbox.add_child(stats_container)

	# Add each stat with a colored icon
	for stat_name in type_def.stat_modifiers.keys():
		var value = type_def.stat_modifiers[stat_name]
		var stat_row = HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 4)  # Tight spacing

		# Stat icon (color-coded by category)
		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(6, 6)  # Tiny icons for grid
		icon.color = _get_stat_color(stat_name)
		stat_row.add_child(icon)

		# Stat label
		var stat_label = Label.new()
		var sign = "+" if value >= 0 else ""
		stat_label.text = "%s%s %s" % [sign, value, stat_name.capitalize()]
		stat_label.add_theme_font_size_override("font_size", 12)  # Larger for readability
		stat_label.add_theme_color_override("font_outline_color", Color.BLACK)
		stat_label.add_theme_constant_override("outline_size", 1)
		stat_row.add_child(stat_label)

		stats_container.add_child(stat_row)

	# Aura type display (compact)
	var aura_label = Label.new()
	if type_def.aura_type:
		aura_label.text = "Aura: %s" % type_def.aura_type.capitalize()
	else:
		aura_label.text = "Aura: None"
	aura_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aura_label.add_theme_font_size_override("font_size", 12)  # Larger for readability
	aura_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	aura_label.add_theme_color_override("font_outline_color", Color.BLACK)
	aura_label.add_theme_constant_override("outline_size", 1)
	vbox.add_child(aura_label)

	# Add "Tap for details" hint (for unlocked cards too)
	var hint_label = Label.new()
	hint_label.text = "Tap for details"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.8))
	hint_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hint_label.add_theme_constant_override("outline_size", 1)
	vbox.add_child(hint_label)

	# Lock overlay (if user can't access this character)
	var user_tier = CharacterService.get_tier()
	if type_def.tier_required > user_tier:
		_add_lock_overlay(card, type_def.tier_required)

	# Make entire card tappable (tap → show detail panel)
	card.gui_input.connect(_on_card_tapped.bind(character_type))

	return card


func _add_lock_overlay(card: Control, required_tier: int) -> void:
	# Professional lock overlay (Week 13 Phase 2: Grid optimized)
	var overlay = Panel.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Semi-transparent dark overlay with rounded corners (50% opacity - lets stats show through)
	var tier_color = _get_tier_color(required_tier)
	var overlay_style = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0, 0, 0, 0.5)  # 50% opacity - visible but clearly locked
	overlay_style.corner_radius_top_left = 8
	overlay_style.corner_radius_top_right = 8
	overlay_style.corner_radius_bottom_left = 8
	overlay_style.corner_radius_bottom_right = 8

	# Add tier-colored border to lock overlay for visual distinction
	overlay_style.border_width_left = 3
	overlay_style.border_width_top = 3
	overlay_style.border_width_right = 3
	overlay_style.border_width_bottom = 3
	overlay_style.border_color = tier_color  # Tier-colored border makes tier instantly recognizable

	overlay.add_theme_stylebox_override("panel", overlay_style)
	card.add_child(overlay)

	# Thumbnail lock indicator (simplified - no buttons, just icon + tier badge)
	# Buttons moved to detail panel for better UX
	var lock_content = VBoxContainer.new()
	lock_content.set_anchors_preset(Control.PRESET_CENTER)
	lock_content.position = Vector2(-65, -80)  # Centered for thumbnail
	lock_content.custom_minimum_size = Vector2(130, 160)
	lock_content.add_theme_constant_override("separation", 12)
	overlay.add_child(lock_content)

	# Lock icon (larger, more prominent)
	var lock_label = Label.new()
	lock_label.text = "🔒"
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 48)  # Larger for thumbnail visibility
	lock_content.add_child(lock_label)

	# Tier requirement badge with colored background panel (reuse tier_color from above)
	var tier_badge_panel = PanelContainer.new()
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = tier_color
	badge_style.corner_radius_top_left = 6
	badge_style.corner_radius_top_right = 6
	badge_style.corner_radius_bottom_left = 6
	badge_style.corner_radius_bottom_right = 6
	badge_style.border_width_left = 2
	badge_style.border_width_top = 2
	badge_style.border_width_right = 2
	badge_style.border_width_bottom = 2
	badge_style.border_color = tier_color.lightened(0.3)  # Brighter border
	tier_badge_panel.add_theme_stylebox_override("panel", badge_style)
	lock_content.add_child(tier_badge_panel)

	var tier_badge = Label.new()
	tier_badge.text = _get_tier_name(required_tier)
	tier_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tier_badge.custom_minimum_size = Vector2(120, 40)  # Prominent badge
	tier_badge.add_theme_font_size_override("font_size", 18)  # Readable
	tier_badge.add_theme_color_override("font_color", Color.WHITE)
	tier_badge.add_theme_color_override("font_outline_color", Color.BLACK)
	tier_badge.add_theme_constant_override("outline_size", 2)
	tier_badge_panel.add_child(tier_badge)

	# Add "Tap for details" hint
	var hint_label = Label.new()
	hint_label.text = "Tap for details"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.9))
	hint_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hint_label.add_theme_constant_override("outline_size", 1)
	lock_content.add_child(hint_label)


func _on_card_tapped(event: InputEvent, character_type: String) -> void:
	"""Handle card tap - show detail panel with full character info"""
	if event is InputEventScreenTouch and event.pressed:
		print("[CharacterSelection] Card tapped: ", character_type)
		_show_character_detail_panel(character_type)

		# Visual feedback - brief scale animation
		if character_type_cards.has(character_type):
			var card = character_type_cards[character_type]
			var tween = create_tween()
			tween.tween_property(card, "scale", Vector2(0.95, 0.95), 0.1)
			tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.1)


func _show_character_detail_panel(character_type: String) -> void:
	"""Show detail panel with full character information and Try/Unlock buttons"""
	print("[CharacterSelection] Showing detail panel for: ", character_type)
	# TODO: Implement detail panel (next step)


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


func _get_tier_color(tier: int) -> Color:
	"""Return tier-specific color for visual hierarchy (matches UI design system)"""
	match tier:
		CharacterService.UserTier.FREE:
			return Color(0.42, 0.45, 0.50)  # Gray (#6B7280) - Basic tier
		CharacterService.UserTier.PREMIUM:
			return Color(0.96, 0.62, 0.04)  # Gold (#F59E0B) - Premium tier
		CharacterService.UserTier.SUBSCRIPTION:
			return Color(0.55, 0.36, 0.96)  # Purple (#8B5CF6) - Subscription tier
	return Color(0.6, 0.6, 0.6)  # Default gray


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
	# Remove highlight from all cards (Week 13 Phase 2 - Grid optimized)
	for card_type in character_type_cards.keys():
		var card = character_type_cards[card_type]
		if card is PanelContainer:
			# Reset to normal state
			card.modulate = Color(1, 1, 1, 1)

			# Reset border width (2px for grid)
			var style = card.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2

	# Highlight selected card with glow effect
	if character_type_cards.has(character_type):
		var card = character_type_cards[character_type]
		if card is PanelContainer:
			# Brighter glow
			card.modulate = Color(1.2, 1.2, 1.2, 1)

			# Thicker border for selected card (2px → 4px for grid)
			var style = card.get_theme_stylebox("panel")
			if style and style is StyleBoxFlat:
				style.border_width_left = 4
				style.border_width_top = 4
				style.border_width_right = 4
				style.border_width_bottom = 4


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
