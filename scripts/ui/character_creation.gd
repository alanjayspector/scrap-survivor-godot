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
var name_input: LineEdit = $ScreenContainer/MarginContainer/VBoxContainer/CreationContainer/NameInput
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

## State
var selected_character_type: String = "scavenger"  # Default type
var character_type_card_buttons: Dictionary = {}
var _upgrade_dialog_shown_this_session: bool = false  # Prevent dialog spam
var _slot_usage_banner: Label = null  # Banner showing slot usage for FREE tier
var _upgrade_dialog_shown_at: int = 0  # Timestamp when upgrade dialog was shown (for time tracking)

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
	_create_character_type_cards()
	_connect_signals()
	_update_create_button_state()
	_setup_slot_usage_banner()

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
	"""Configure name input field"""
	name_input.placeholder_text = "Enter survivor name..."
	name_input.max_length = MAX_NAME_LENGTH
	name_input.text_changed.connect(_on_name_changed)
	name_input.grab_focus()  # Auto-focus for keyboard

	GameLogger.info(
		"[CharacterCreation] Name input configured",
		{"min_length": MIN_NAME_LENGTH, "max_length": MAX_NAME_LENGTH}
	)


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


func _setup_slot_usage_banner() -> void:
	"""Show slot usage banner for FREE tier users (early upgrade awareness)"""
	var tier = CharacterService.get_tier()
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()

	# Only show for FREE tier users who have created at least 1 character
	if tier != CharacterService.UserTier.FREE or character_count == 0:
		return

	# Create banner label
	_slot_usage_banner = Label.new()
	_slot_usage_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_usage_banner.add_theme_font_size_override("font_size", 18)
	_slot_usage_banner.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))  # Gold color
	_slot_usage_banner.text = (
		"Using %d/%d Free slots. Upgrade to Premium for 15 slots + exclusive features!"
		% [character_count, slot_limit]
	)

	# Insert banner after subtitle (before creation container)
	var vbox = $ScreenContainer/MarginContainer/VBoxContainer
	var header_container = $ScreenContainer/MarginContainer/VBoxContainer/HeaderContainer
	vbox.add_child(_slot_usage_banner)
	vbox.move_child(_slot_usage_banner, header_container.get_index() + 1)

	GameLogger.info(
		"[CharacterCreation] Slot usage banner shown",
		{"character_count": character_count, "slot_limit": slot_limit}
	)

	# Track analytics (early awareness opportunity)
	Analytics.track_event(
		"slot_usage_banner_shown",
		{"tier": tier, "slots_used": character_count, "slots_total": slot_limit}
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
	# Phase 2: Will show Character Type Preview Modal with full stats/abilities
	# For now, just log for testing
	GameLogger.info(
		"[CharacterCreation] Long press on type card (Preview modal coming Phase 2)",
		{"type_id": type_id}
	)


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
