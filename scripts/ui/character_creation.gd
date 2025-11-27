# gdlint: disable=max-file-lines
extends Control
## Character Creation UI
## Week 15 Phase 2: Create and save named characters
##
## Features:
## - Name input (validation)
## - Character type selection (visual cards)
## - Save to CharacterService
## - Tier-based slot limit enforcement
## - Analytics integration
## - Comprehensive diagnostic logging

## Node references
@onready
var name_input: LineEdit = $ScreenContainer/MarginContainer/VBoxContainer/CreationContainer/NameInputContainer/NameInput
# gdlint: disable=max-line-length
@onready
var character_type_cards: GridContainer = $ScreenContainer/MarginContainer/VBoxContainer/CreationContainer/CharacterTypeCards
@onready
var create_button: Button = $ScreenContainer/MarginContainer/VBoxContainer/ButtonsContainer/CreateButton
@onready
var create_hub_button: Button = $ScreenContainer/MarginContainer/VBoxContainer/ButtonsContainer/CreateHubButton
@onready
var back_button: Button = $ScreenContainer/MarginContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready
var header_container: VBoxContainer = $ScreenContainer/MarginContainer/VBoxContainer/HeaderContainer

## State
var selected_character_type: String = "scavenger"  # Default type
var character_type_card_buttons: Dictionary = {}
var _upgrade_dialog_shown_this_session: bool = false  # Prevent dialog spam
var _slot_usage_label: Label = null  # Dynamic slot usage indicator (Week 17 Phase 4B)
var _upgrade_dialog_shown_at: int = 0  # Timestamp when upgrade dialog was shown (for time tracking)
var _active_preview_modal: MobileModal = null  # Track active modal to prevent stacking

## Constants
const MIN_NAME_LENGTH = 2
const MAX_NAME_LENGTH = 20

## Audio preloads (iOS-compatible pattern)
const BUTTON_CLICK_SOUND: String = "res://assets/audio/ui/button_click.ogg"
const CHARACTER_SELECT_SOUND: String = "res://assets/audio/ui/character_select.ogg"
const ERROR_SOUND: String = "res://assets/audio/ui/ui_error.ogg"

## Theme
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

## CharacterTypeCard component (Week 17)
const CHARACTER_TYPE_CARD_SCENE = preload("res://scenes/ui/components/character_type_card.tscn")


func _ready() -> void:
	var start_time = Time.get_ticks_msec()

	GameLogger.info(
		"[CharacterCreation] Initializing",
		{
			"current_tier": CharacterService.get_tier(),
			"character_count": CharacterService.get_character_count(),
			"slot_limit": CharacterService.get_character_slot_limit()
		}
	)

	_setup_name_input()
	_setup_keyboard_dismissal()
	_create_character_type_cards()
	_connect_signals()
	_update_create_button_state()
	_setup_slot_usage_indicator()

	# Add button animations (Week16: ButtonAnimation component)
	THEME_HELPER.add_button_animation(create_button)
	THEME_HELPER.add_button_animation(create_hub_button)
	THEME_HELPER.add_button_animation(back_button)

	# Track analytics
	Analytics.track_event("character_creation_opened", {})

	var init_duration = Time.get_ticks_msec() - start_time
	GameLogger.info("[CharacterCreation] Initialized", {"init_duration_ms": init_duration})


func _exit_tree() -> void:
	GameLogger.info("[CharacterCreation] Cleanup complete")


func _setup_name_input() -> void:
	"""Configure name input field with wasteland-themed styling"""
	name_input.placeholder_text = "Enter survivor name..."
	name_input.max_length = MAX_NAME_LENGTH
	name_input.text_changed.connect(_on_name_changed)
	# Note: Don't auto-focus on mobile - let user tap to show keyboard (iOS HIG)

	# Apply wasteland-themed styling for visibility against busy background
	_apply_name_input_styling()

	GameLogger.info(
		"[CharacterCreation] Name input configured",
		{"min_length": MIN_NAME_LENGTH, "max_length": MAX_NAME_LENGTH}
	)


func _apply_name_input_styling() -> void:
	"""
	Apply wasteland-themed StyleBox to name input field.

	Design Pattern: StyleBoxFlat for custom input field appearance
	Rationale: Default LineEdit is nearly invisible against busy background images.
	Solution: Solid dark background with rust-orange border matches wasteland aesthetic.

	Expert Panel Recommendations (Week 17 Phase 4B):
	- Background: SOOT_BLACK (#2B2B2B) at 95% alpha
	- Border: RUST_ORANGE (#D4722B) for consistency with primary actions
	- Corner radius: 8px (matches button styling)
	- Content margin: 12px for comfortable text padding
	- Focus state: Brighter border to indicate active input
	"""
	# Normal state style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.17, 0.17, 0.17, 0.95)  # SOOT_BLACK with 95% alpha
	style_normal.border_color = GameColorPalette.RUST_ORANGE
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(8)
	style_normal.set_content_margin_all(12)

	# Focus state style (brighter border for active indication)
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0.17, 0.17, 0.17, 0.98)  # Slightly more opaque when focused
	style_focus.border_color = GameColorPalette.RUST_LIGHT  # Brighter rust for focus
	style_focus.set_border_width_all(3)  # Thicker border when focused
	style_focus.set_corner_radius_all(8)
	style_focus.set_content_margin_all(12)

	# Apply styles to LineEdit
	name_input.add_theme_stylebox_override("normal", style_normal)
	name_input.add_theme_stylebox_override("focus", style_focus)

	# Set placeholder text color for visibility
	name_input.add_theme_color_override("font_placeholder_color", GameColorPalette.CONCRETE_GRAY)

	# Ensure text color is readable
	name_input.add_theme_color_override("font_color", GameColorPalette.DIRTY_WHITE)

	# Caret color for visibility
	name_input.add_theme_color_override("caret_color", GameColorPalette.RUST_LIGHT)

	GameLogger.debug("[CharacterCreation] Name input styling applied (wasteland theme)")


func _setup_keyboard_dismissal() -> void:
	"""Setup tap-outside-to-dismiss keyboard behavior (iOS HIG compliance)"""
	# Connect to root gui_input for background taps
	gui_input.connect(_on_background_input)

	GameLogger.info("[CharacterCreation] Keyboard dismissal configured")


func _on_background_input(event: InputEvent) -> void:
	"""Dismiss keyboard when tapping outside the name input field"""
	if event is InputEventMouseButton and event.pressed:
		# Release focus from name input to dismiss virtual keyboard
		if name_input.has_focus():
			name_input.release_focus()
			GameLogger.debug("[CharacterCreation] Keyboard dismissed via background tap")


func _create_character_type_cards() -> void:
	"""Create character type selection cards using CharacterTypeCard component (Week 17)"""
	# Clear existing cards to prevent leaks on scene reload
	for child in character_type_cards.get_children():
		child.queue_free()
	character_type_card_buttons.clear()

	var character_types = ["scavenger", "tank", "commando", "mutant"]
	var cards_created = 0

	for char_type in character_types:
		if not CharacterService.CHARACTER_TYPES.has(char_type):
			GameLogger.warning("[CharacterCreation] Unknown character type", {"type": char_type})
			continue

		# Create CharacterTypeCard instance
		var card = CHARACTER_TYPE_CARD_SCENE.instantiate()
		character_type_cards.add_child(card)

		# Setup card for type display (handles lock state internally)
		card.setup_type(char_type)

		# Connect signals
		card.card_pressed.connect(_on_card_pressed)
		card.card_long_pressed.connect(_on_card_long_pressed)

		character_type_card_buttons[char_type] = card
		cards_created += 1

		var type_def = CharacterService.CHARACTER_TYPES[char_type]
		var is_locked = type_def.tier_required > CharacterService.get_tier()

		if is_locked:
			GameLogger.info(
				"[CharacterCreation] Character type LOCKED (shown with lock overlay)",
				{
					"type": char_type,
					"required_tier": type_def.tier_required,
					"current_tier": CharacterService.get_tier()
				}
			)

	# Select default type
	_select_character_type("scavenger")

	GameLogger.info("[CharacterCreation] Character type cards created", {"count": cards_created})


func _select_character_type(character_type: String) -> void:
	"""Select a character type and update UI using CharacterTypeCard.set_selected()"""
	selected_character_type = character_type

	# Update card visual states using set_selected()
	for type_name in character_type_card_buttons.keys():
		var card = character_type_card_buttons[type_name]
		card.set_selected(type_name == character_type)

	_update_create_button_state()

	GameLogger.info("[CharacterCreation] Type selected", {"type": character_type})
	Analytics.track_event("character_type_selected", {"type": character_type})


func _setup_slot_usage_indicator() -> void:
	"""
	Show slot usage indicator as a prominent badge below title (Week 17 Phase 4B).

	Uses shared ThemeHelper.create_slot_usage_badge() for uniform appearance
	across all screens (Create, Barracks, etc.).

	Design Pattern: Transparent Scarcity with Visual Prominence
	- Shows slot limits BEFORE users hit the wall
	- Soft CTA for upgrade consideration
	- Consistent visual treatment game-wide
	"""
	var badge_nodes = THEME_HELPER.create_slot_usage_badge(header_container)
	_slot_usage_label = badge_nodes.label

	# Track analytics
	var tier = CharacterService.get_tier()
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()

	Analytics.track_event(
		"slot_usage_indicator_shown",
		{
			"screen": "character_creation",
			"tier": tier,
			"slots_used": character_count,
			"slots_total": slot_limit,
			"slots_remaining": slot_limit - character_count
		}
	)


func _connect_signals() -> void:
	"""Connect button signals"""
	create_button.pressed.connect(_on_create_pressed)
	create_hub_button.pressed.connect(_on_create_hub_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# Apply button styling
	THEME_HELPER.apply_button_style(create_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(create_hub_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(back_button, THEME_HELPER.ButtonStyle.SECONDARY)

	# Apply button icons
	UI_ICONS.apply_button_icon(back_button, UI_ICONS.Icon.BACK)


func _on_name_changed(new_text: String) -> void:
	"""Validate name input and update button state"""
	_update_create_button_state()

	# Track user engagement
	if new_text.length() > 0:
		Analytics.track_event("name_input_started", {})


func _update_create_button_state() -> void:
	"""Enable/disable create button based on validation"""
	# Strip whitespace FIRST, then validate (prevents '   ' from passing)
	var name = name_input.text.strip_edges()
	var is_valid = name.length() >= MIN_NAME_LENGTH and name.length() <= MAX_NAME_LENGTH

	create_button.disabled = not is_valid
	create_hub_button.disabled = not is_valid

	# Show helpful tooltip for invalid names
	if name_input.text.length() > 0 and name.length() < MIN_NAME_LENGTH:
		var tooltip = "Name must be at least %d characters" % MIN_NAME_LENGTH
		create_button.tooltip_text = tooltip
		create_hub_button.tooltip_text = tooltip
	else:
		create_button.tooltip_text = ""
		create_hub_button.tooltip_text = ""


func _on_card_pressed(type_id: String) -> void:
	"""Handle CharacterTypeCard press signal (Week 17)"""
	# CharacterTypeCard handles locked state internally (disabled button)
	# If we receive the signal, the card is unlocked
	_play_sound(CHARACTER_SELECT_SOUND)
	_select_character_type(type_id)


func _on_card_long_pressed(type_id: String) -> void:
	"""Handle CharacterTypeCard long press signal - show type preview (Week 17 Phase 2)"""
	GameLogger.info("[CharacterCreation] Long press on type card", {"type_id": type_id})
	_show_type_preview_modal(type_id)


func _show_type_preview_modal(type_id: String) -> void:
	"""Show Character Type Preview Modal (iOS HIG Sheet pattern)"""
	# Dismiss existing modal to prevent stacking
	if _active_preview_modal and is_instance_valid(_active_preview_modal):
		_active_preview_modal.dismiss()
		_active_preview_modal = null

	var type_def = CharacterService.CHARACTER_TYPES.get(type_id, {})
	if type_def.is_empty():
		GameLogger.warning(
			"[CharacterCreation] Cannot show preview for unknown type", {"type_id": type_id}
		)
		return

	var display_name = type_def.get("display_name", type_id.capitalize())
	var description = type_def.get("description", "A survivor type.")
	var stat_mods = type_def.get("stat_modifiers", {})
	var tier_required = type_def.get("tier_required", CharacterService.UserTier.FREE)

	# Check if this type is locked for current user
	var current_tier = CharacterService.get_tier()
	var is_locked = current_tier < tier_required

	# Create sheet modal using ModalFactory
	var modal = ModalFactory.create_sheet(self, display_name, true, true)
	_active_preview_modal = modal

	# Build custom content with aura info and upgrade CTA
	var content = _build_type_preview_content(
		type_id, display_name, description, stat_mods, tier_required, is_locked
	)
	modal.add_custom_content(content)

	# Add buttons based on lock state
	if is_locked:
		# CTA button for upgrade
		var tier_names = ["Free", "Premium", "Subscription"]
		var tier_name = (
			tier_names[tier_required] if tier_required < tier_names.size() else "Premium"
		)
		modal.add_primary_button(
			"Upgrade to %s" % tier_name,
			func():
				modal.dismiss()
				_active_preview_modal = null
				_show_upgrade_flow(tier_required)
		)
		modal.add_secondary_button(
			"Close",
			func():
				modal.dismiss()
				_active_preview_modal = null
		)
	else:
		# Select button for unlocked types
		modal.add_primary_button(
			"Select Type",
			func():
				modal.dismiss()
				_active_preview_modal = null
				_select_character_type(type_id)
		)
		modal.add_secondary_button(
			"Close",
			func():
				modal.dismiss()
				_active_preview_modal = null
		)

	modal.show_modal()

	# Track analytics
	Analytics.track_event(
		"type_preview_opened",
		{"type_id": type_id, "is_locked": is_locked, "tier_required": tier_required}
	)


func _build_type_preview_content(
	type_id: String,
	_display_name: String,
	description: String,
	stat_mods: Dictionary,
	tier_required: int,
	is_locked: bool = false
) -> Control:
	"""Build the content for type preview modal - HYPED sales pitch for locked types"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 16)

	# Portrait section - LARGER centered silhouette (250x250 for impact)
	var portrait_container = CenterContainer.new()
	container.add_child(portrait_container)
	portrait_container.layout_mode = 2

	var portrait_panel = Panel.new()
	portrait_container.add_child(portrait_panel)
	portrait_panel.layout_mode = 2
	portrait_panel.custom_minimum_size = Vector2(250, 250)

	# Style portrait panel background with type-colored border
	var type_color = _get_type_color(type_id)
	var portrait_style = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	portrait_style.border_color = type_color
	portrait_style.set_border_width_all(3)
	portrait_style.set_corner_radius_all(16)
	portrait_panel.add_theme_stylebox_override("panel", portrait_style)

	# Add portrait texture
	var portrait_rect = TextureRect.new()
	portrait_panel.add_child(portrait_rect)
	portrait_rect.layout_mode = 2
	portrait_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Load silhouette texture
	var silhouette_paths = {
		"scavenger": "res://assets/ui/portraits/silhouette_scavenger.png",
		"tank": "res://assets/ui/portraits/silhouette_tank.png",
		"commando": "res://assets/ui/portraits/silhouette_commando.png",
		"mutant": "res://assets/ui/portraits/silhouette_mutant.png",
	}
	var texture_path = silhouette_paths.get(type_id, "")
	if not texture_path.is_empty():
		var texture = load(texture_path) as Texture2D
		if texture:
			portrait_rect.texture = texture

	# Description
	var desc_label = Label.new()
	container.add_child(desc_label)
	desc_label.layout_mode = 2
	desc_label.text = description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Aura section (unique selling point!) - Clean text, no emojis (iOS compatible)
	var aura_info = _get_type_aura_info(type_id)
	if not aura_info.is_empty():
		var aura_label = Label.new()
		container.add_child(aura_label)
		aura_label.layout_mode = 2
		aura_label.text = "%s Aura" % aura_info.get("name", "Special")
		aura_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		aura_label.add_theme_font_size_override("font_size", 20)
		aura_label.add_theme_color_override("font_color", type_color)

		# Aura description
		var aura_desc = Label.new()
		container.add_child(aura_desc)
		aura_desc.layout_mode = 2
		aura_desc.text = aura_info.get("description", "")
		aura_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		aura_desc.add_theme_font_size_override("font_size", 14)
		aura_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		aura_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Stats section header
	var stats_header = Label.new()
	container.add_child(stats_header)
	stats_header.layout_mode = 2
	stats_header.text = "Starting Bonuses"
	stats_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_header.add_theme_font_size_override("font_size", 20)
	stats_header.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))

	# Stats grid - centered
	var stats_center = CenterContainer.new()
	container.add_child(stats_center)
	stats_center.layout_mode = 2

	var stats_grid = GridContainer.new()
	stats_center.add_child(stats_grid)
	stats_grid.layout_mode = 2
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 24)
	stats_grid.add_theme_constant_override("v_separation", 6)

	# Stat display names
	var stat_display = {
		"max_hp": "Health",
		"armor": "Armor",
		"damage": "Damage",
		"ranged_damage": "Ranged",
		"melee_damage": "Melee",
		"attack_speed": "Attack Speed",
		"speed": "Move Speed",
		"crit_chance": "Critical",
		"dodge": "Dodge",
		"luck": "Luck",
		"scavenging": "Scavenging",
		"pickup_range": "Pickup Range",
		"resonance": "Resonance",
	}

	for stat_key in stat_mods.keys():
		var value = stat_mods[stat_key]
		var stat_name = stat_display.get(stat_key, stat_key.capitalize())
		var sign_str = "+" if value >= 0 else ""
		var color = Color(0.4, 0.9, 0.4) if value >= 0 else Color(0.9, 0.4, 0.4)

		var name_label = Label.new()
		stats_grid.add_child(name_label)
		name_label.layout_mode = 2
		name_label.text = stat_name + ":"
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

		var value_label = Label.new()
		stats_grid.add_child(value_label)
		value_label.layout_mode = 2
		value_label.text = "%s%s" % [sign_str, value]
		value_label.add_theme_font_size_override("font_size", 16)
		value_label.add_theme_color_override("font_color", color)

	# CTA messaging for locked types (THE MONEY SHOT)
	if is_locked:
		var tier_names = ["Free", "Premium", "Subscription"]
		var tier_name = (
			tier_names[tier_required] if tier_required < tier_names.size() else "Premium"
		)

		# Separator
		var sep = HSeparator.new()
		container.add_child(sep)
		sep.layout_mode = 2
		sep.modulate = Color(0.3, 0.3, 0.3, 1.0)

		# CTA headline
		var cta_headline = Label.new()
		container.add_child(cta_headline)
		cta_headline.layout_mode = 2
		cta_headline.text = "🔓 Unlock with %s" % tier_name
		cta_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cta_headline.add_theme_font_size_override("font_size", 22)
		cta_headline.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))

		# Value proposition
		var value_prop = Label.new()
		container.add_child(value_prop)
		value_prop.layout_mode = 2
		if tier_required == CharacterService.UserTier.PREMIUM:
			value_prop.text = "One-time purchase • Permanent access"
		else:
			value_prop.text = "All premium content • Monthly rewards"
		value_prop.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_prop.add_theme_font_size_override("font_size", 14)
		value_prop.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	return container


func _get_type_color(type_id: String) -> Color:
	"""Get the signature color for a character type"""
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
		"scavenger":
		{"name": "Collection", "description": "Auto-collects nearby currency and items faster"},
		"tank": {"name": "Shield", "description": "Grants armor bonus to you and nearby minions"},
		"commando": {},  # No aura - pure DPS
		"mutant": {"name": "Damage", "description": "Deals damage to nearby enemies every second"},
	}
	return auras.get(type_id, {})


func _show_upgrade_flow(required_tier: int) -> void:
	"""Show upgrade flow for tier (placeholder - integrate with IAP)"""
	var tier_names = ["Free", "Premium", "Subscription"]
	var tier_name = tier_names[required_tier] if required_tier < tier_names.size() else "Premium"

	# For now, show an info modal - will integrate with actual IAP later
	ModalFactory.show_alert(
		self,
		"Upgrade to %s" % tier_name,
		"In-app purchases coming soon!\n\nFor now, all character types are available for testing.",
		func(): pass
	)

	Analytics.track_event("upgrade_flow_shown", {"tier_required": required_tier})


func _on_create_pressed() -> void:
	"""Handle Create button - create and save character"""
	# Debounce: Disable button immediately to prevent double-tap
	create_button.disabled = true

	var name = name_input.text.strip_edges()

	GameLogger.info(
		"[CharacterCreation] Create button pressed", {"name": name, "type": selected_character_type}
	)

	# Validate name
	if name.length() < MIN_NAME_LENGTH:
		# Re-enable button on validation failure
		create_button.disabled = false
		_play_sound(ERROR_SOUND)
		GameLogger.warning(
			"[CharacterCreation] Name too short", {"name": name, "length": name.length()}
		)
		return

	# Check slot limits
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()

	if character_count >= slot_limit:
		# Re-enable button on slot limit error
		create_button.disabled = false
		_play_sound(ERROR_SOUND)
		_show_slot_limit_error(slot_limit, CharacterService.get_tier())
		Analytics.track_event(
			"slot_limit_reached",
			{"tier": CharacterService.get_tier(), "count": character_count, "limit": slot_limit}
		)
		return

	# Create character
	_play_sound(CHARACTER_SELECT_SOUND)

	var character_id = CharacterService.create_character(name, selected_character_type)

	if not character_id.is_empty():
		GameLogger.info(
			"[CharacterCreation] Character created",
			{"character_id": character_id, "name": name, "type": selected_character_type}
		)

		# Track analytics
		Analytics.character_created(selected_character_type)

		# Set as active character
		GameState.set_active_character(character_id)

		# Save immediately
		var save_success = SaveManager.save_all_services()
		if not save_success:
			# Re-enable button on save failure
			create_button.disabled = false
			GameLogger.error("[CharacterCreation] Failed to save character")
			_show_save_error_dialog()
			return

		GameLogger.info("[CharacterCreation] Character saved successfully")

		# Launch combat with this character
		GameLogger.info("[CharacterCreation] Launching combat", {"character_id": character_id})
		get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")
	else:
		# Re-enable button on creation failure
		create_button.disabled = false
		_play_sound(ERROR_SOUND)
		GameLogger.error(
			"[CharacterCreation] Failed to create character",
			{"name": name, "type": selected_character_type}
		)

		# Show error dialog to user
		_show_creation_error_dialog()


func _on_create_hub_pressed() -> void:
	"""Handle Create & Hub button - create character and go to hub (QA shortcut)"""
	# Debounce: Disable buttons immediately to prevent double-tap
	create_button.disabled = true
	create_hub_button.disabled = true

	var name = name_input.text.strip_edges()

	GameLogger.info(
		"[CharacterCreation] Create & Hub button pressed (QA shortcut)",
		{"name": name, "type": selected_character_type}
	)

	# Validate name
	if name.length() < MIN_NAME_LENGTH:
		# Re-enable buttons on validation failure
		create_button.disabled = false
		create_hub_button.disabled = false
		_play_sound(ERROR_SOUND)
		GameLogger.warning(
			"[CharacterCreation] Name too short", {"name": name, "length": name.length()}
		)
		return

	# Check slot limits
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()

	if character_count >= slot_limit:
		# Re-enable buttons on slot limit error
		create_button.disabled = false
		create_hub_button.disabled = false
		_play_sound(ERROR_SOUND)
		_show_slot_limit_error(slot_limit, CharacterService.get_tier())
		Analytics.track_event(
			"slot_limit_reached",
			{"tier": CharacterService.get_tier(), "count": character_count, "limit": slot_limit}
		)
		return

	# Create character
	_play_sound(CHARACTER_SELECT_SOUND)

	var character_id = CharacterService.create_character(name, selected_character_type)

	if not character_id.is_empty():
		GameLogger.info(
			"[CharacterCreation] Character created (hub route)",
			{"character_id": character_id, "name": name, "type": selected_character_type}
		)

		# Track analytics
		Analytics.character_created(selected_character_type)
		Analytics.track_event("character_creation_hub_route", {"type": selected_character_type})

		# Set as active character
		GameState.set_active_character(character_id)

		# Save immediately
		var save_success = SaveManager.save_all_services()
		if not save_success:
			# Re-enable buttons on save failure
			create_button.disabled = false
			create_hub_button.disabled = false
			GameLogger.error("[CharacterCreation] Failed to save character")
			_show_save_error_dialog()
			return

		GameLogger.info("[CharacterCreation] Character saved, going to hub (QA shortcut)")

		# Go to hub instead of wasteland (QA shortcut)
		get_tree().change_scene_to_file("res://scenes/hub/scrapyard.tscn")
	else:
		# Re-enable buttons on creation failure
		create_button.disabled = false
		create_hub_button.disabled = false
		_play_sound(ERROR_SOUND)
		GameLogger.error(
			"[CharacterCreation] Failed to create character",
			{"name": name, "type": selected_character_type}
		)

		# Show error dialog to user
		_show_creation_error_dialog()


func _on_back_pressed() -> void:
	"""Handle Back button - return to hub"""
	_play_sound(BUTTON_CLICK_SOUND)

	GameLogger.info("[CharacterCreation] Back button pressed")
	Analytics.track_event("character_creation_cancelled", {})

	get_tree().change_scene_to_file("res://scenes/hub/scrapyard.tscn")


func _show_slot_limit_error(limit: int, tier: int) -> void:
	"""Show upgrade dialog when slot limit reached"""
	# Prevent dialog spam - only show once per session
	if _upgrade_dialog_shown_this_session:
		GameLogger.info("[CharacterCreation] Slot limit dialog already shown this session")
		return

	var tier_names = ["Free", "Premium", "Subscription"]
	var tier_name = tier_names[tier] if tier < tier_names.size() else "Unknown"

	GameLogger.warning(
		"[CharacterCreation] Slot limit reached",
		{"limit": limit, "tier": tier, "tier_name": tier_name}
	)

	# Track analytics
	Analytics.track_event(
		"slot_limit_cta_shown", {"tier": tier, "tier_name": tier_name, "slot_count": limit}
	)

	# Track time shown (for warm lead identification)
	_upgrade_dialog_shown_at = Time.get_ticks_msec()

	# Create dialog
	var dialog = AcceptDialog.new()
	dialog.title = "Character Slots Full (%d/%d)" % [limit, limit]
	dialog.dialog_text = _get_slot_limit_dialog_text(tier, limit)
	dialog.ok_button_text = "Maybe Later"

	# Add tier-specific action buttons
	match tier:
		CharacterService.UserTier.FREE:
			dialog.add_button("Upgrade to Premium ($4.99)", true, "upgrade_premium")
		CharacterService.UserTier.PREMIUM:
			dialog.add_button("Buy +5 Slots ($0.99)", true, "buy_slots_5")
			dialog.add_button("Buy +25 Slots ($3.99)", true, "buy_slots_25")
			dialog.add_button("Subscribe ($2.99/mo)", true, "upgrade_subscription")
		CharacterService.UserTier.SUBSCRIPTION:
			# At 50/50 - suggest Hall of Fame archiving (Week 16 feature)
			dialog.add_button("Learn About Hall of Fame", true, "hall_of_fame_info")

	# Connect signals
	dialog.custom_action.connect(_on_upgrade_dialog_action)
	dialog.canceled.connect(_on_upgrade_dialog_dismissed)
	dialog.confirmed.connect(_on_upgrade_dialog_dismissed)

	# Auto-cleanup on close (prevent memory leak)
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.custom_action.connect(func(_action): dialog.queue_free())

	# Show dialog
	add_child(dialog)
	dialog.popup_centered()

	_upgrade_dialog_shown_this_session = true


func _get_slot_limit_dialog_text(tier: int, _limit: int) -> String:
	"""Get tier-specific dialog copy"""
	match tier:
		CharacterService.UserTier.FREE:
			return """You've filled all 3 Free tier character slots!

Want to create more characters and unlock deeper gameplay?

✨ Upgrade to Premium ✨

• 15 character slots (5x more!)
• Premium character types
• Black Market access
• 8 exclusive weapons
• Minions system (2 active companions)

One-time price: $4.99"""

		CharacterService.UserTier.PREMIUM:
			return """You're a power player! 🔥

You've filled all 15 Premium character slots.

Need more space for experimentation?

Quick Add:
• +5 slots for $0.99
• +25 slots for $3.99

OR

✨ Upgrade to Subscription ✨
• 50 active character slots
• 200 Hall of Fame archived slots
• Quantum Banking (transfer currency)
• Quantum Storage (transfer items)
• Atomic Vending Machine (personalized shop)

Monthly: $2.99"""

		CharacterService.UserTier.SUBSCRIPTION:
			return """You've reached the maximum of 50 active character slots!

You're in the top 1% of players. 🎉

Consider using the Hall of Fame to archive retired characters and preserve their legacy while freeing up active slots.

(Hall of Fame feature coming in Week 16)"""

		_:
			return "Character slot limit reached."


func _on_upgrade_dialog_action(action: String) -> void:
	"""Handle upgrade dialog button presses"""
	GameLogger.info("[CharacterCreation] Upgrade dialog action", {"action": action})

	# Calculate time spent on dialog (warm lead identification)
	var time_spent_ms = 0
	if _upgrade_dialog_shown_at > 0:
		time_spent_ms = Time.get_ticks_msec() - _upgrade_dialog_shown_at

	# Track analytics with time spent
	Analytics.track_event(
		"slot_limit_cta_clicked",
		{
			"action": action,
			"tier": CharacterService.get_tier(),
			"time_spent_ms": time_spent_ms,
			"time_spent_seconds": time_spent_ms / 1000.0
		}
	)

	# Week 15: Stub out purchase flow (Week 16: wire to actual IAP)
	match action:
		"upgrade_premium":
			_show_purchase_stub("Premium Upgrade", "$4.99")
		"buy_slots_5":
			_show_purchase_stub("+5 Character Slots", "$0.99")
		"buy_slots_25":
			_show_purchase_stub("+25 Character Slots", "$3.99")
		"upgrade_subscription":
			_show_purchase_stub("Subscription", "$2.99/month")
		"hall_of_fame_info":
			_show_purchase_stub("Hall of Fame Info", "Coming in Week 16")


func _on_upgrade_dialog_dismissed() -> void:
	"""Handle upgrade dialog dismissal (Maybe Later or X button)"""
	GameLogger.info("[CharacterCreation] Upgrade dialog dismissed")

	# Calculate time spent on dialog (warm lead identification)
	var time_spent_ms = 0
	if _upgrade_dialog_shown_at > 0:
		time_spent_ms = Time.get_ticks_msec() - _upgrade_dialog_shown_at

	# Track analytics with time spent
	Analytics.track_event(
		"slot_limit_cta_dismissed",
		{
			"tier": CharacterService.get_tier(),
			"time_spent_ms": time_spent_ms,
			"time_spent_seconds": time_spent_ms / 1000.0
		}
	)


func _show_purchase_stub(product_name: String, price: String) -> void:
	"""Stub for purchase flow (Week 16: wire to actual IAP)"""
	GameLogger.info("[CharacterCreation] Purchase stub", {"product": product_name, "price": price})

	# Show simple confirmation dialog
	var stub_dialog = AcceptDialog.new()
	stub_dialog.title = "Purchase Feature"
	stub_dialog.dialog_text = (
		"""This purchase feature will be implemented in Week 16.

Product: %s
Price: %s

For now, this is a placeholder to test the upgrade flow."""
		% [product_name, price]
	)
	stub_dialog.ok_button_text = "Got It"

	add_child(stub_dialog)
	stub_dialog.popup_centered()

	# Auto-cleanup after close
	stub_dialog.confirmed.connect(func(): stub_dialog.queue_free())


func _show_creation_error_dialog() -> void:
	"""Show error dialog when character creation fails"""
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Creation Failed"
	error_dialog.dialog_text = """Failed to create character.

This may happen if:
• Character type requires higher tier
• Invalid character configuration

Please try again or contact support if this persists."""
	error_dialog.ok_button_text = "OK"

	add_child(error_dialog)
	error_dialog.popup_centered()

	# Auto-cleanup
	error_dialog.confirmed.connect(func(): error_dialog.queue_free())


func _show_save_error_dialog() -> void:
	"""Show error dialog when save fails"""
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Save Failed"
	error_dialog.dialog_text = """Failed to save your character.

Your character was created but couldn't be saved to disk. This may happen if:
• Storage is full
• File permissions issue
• Disk write error

Please try again or free up storage space."""
	error_dialog.ok_button_text = "Retry"

	add_child(error_dialog)
	error_dialog.popup_centered()

	# Auto-cleanup
	error_dialog.confirmed.connect(func(): error_dialog.queue_free())


func _show_locked_character_dialog(character_type: String, required_tier: int) -> void:
	"""Show upgrade dialog when locked character is clicked"""
	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var character_name = type_def.get("display_name", character_type.capitalize())
	var tier_names = ["Free", "Premium", "Subscription"]
	var tier_name = tier_names[required_tier] if required_tier < tier_names.size() else "Unknown"

	GameLogger.info(
		"[CharacterCreation] Locked character clicked",
		{"character": character_type, "required_tier": tier_name}
	)

	# Track analytics
	Analytics.track_event(
		"locked_character_clicked",
		{"character_type": character_type, "required_tier": required_tier, "tier_name": tier_name}
	)

	# Create unlock dialog
	var dialog = AcceptDialog.new()
	dialog.title = "%s - %s Tier Required" % [character_name, tier_name]
	dialog.dialog_text = _get_locked_character_dialog_text(character_type, required_tier)
	dialog.ok_button_text = "Maybe Later"

	# Add tier-specific upgrade button
	if required_tier == CharacterService.UserTier.PREMIUM:
		dialog.add_button("Unlock Premium ($4.99)", true, "upgrade_premium")
	elif required_tier == CharacterService.UserTier.SUBSCRIPTION:
		dialog.add_button("Subscribe ($2.99/mo)", true, "upgrade_subscription")

	# Connect signals
	dialog.custom_action.connect(_on_upgrade_dialog_action)

	# Auto-cleanup
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.custom_action.connect(func(_action): dialog.queue_free())

	# Show dialog
	add_child(dialog)
	dialog.popup_centered()


func _get_locked_character_dialog_text(character_type: String, required_tier: int) -> String:
	"""Get tier-specific dialog copy for locked characters"""
	var type_def = CharacterService.CHARACTER_TYPES.get(character_type, {})
	var character_name = type_def.get("display_name", character_type.capitalize())
	var character_desc = type_def.get("description", "A powerful character")

	match required_tier:
		CharacterService.UserTier.PREMIUM:
			return (
				"""%s is a Premium character!

"%s"

✨ Unlock with Premium Tier ✨

Premium includes:
• 15 character slots (5x more!)
• 3 exclusive character types (Tank, Commando, Mutant)
• Black Market access
• 8 exclusive weapons
• Minions system (2 active companions)

One-time price: $4.99"""
				% [character_name, character_desc]
			)

		CharacterService.UserTier.SUBSCRIPTION:
			return (
				"""%s is a Subscription-exclusive character!

"%s"

✨ Unlock with Subscription ✨

Subscription includes:
• All Premium features
• 50 active character slots
• 200 Hall of Fame archived slots
• Quantum Banking (transfer currency)
• Quantum Storage (transfer items)
• Atomic Vending Machine (personalized shop)

Monthly: $2.99"""
				% [character_name, character_desc]
			)

		_:
			return "%s requires a higher tier to unlock." % character_name


func _play_sound(sound_path: String) -> void:
	"""Play UI sound and haptic feedback"""
	HapticManager.light()
	if audio_player and ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		if sound:
			audio_player.stream = sound
			audio_player.play()
