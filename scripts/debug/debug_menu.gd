extends ConfirmationDialog
## Debug Menu for QA Testing
##
## Week 16 Priority 1: Debug tooling for manual tier testing
##
## SAFETY: This should NEVER ship to production. Only visible when OS.is_debug_build() returns true.
##
## Features:
## - Tier switching (FREE/PREMIUM/SUBSCRIPTION)
## - Account reset options (keep characters, reset characters, nuclear reset)
## - Status display (current tier, character count, slot limit, save file size)
##
## Usage:
## - In Hub scene, press QA button (bottom-right, debug builds only)
## - Select tier and reset option
## - Confirm destructive actions

class_name DebugMenu

## UI References
@onready var tier_buttons_container: HBoxContainer = %TierButtonsContainer
@onready var status_label: Label = %StatusLabel
@onready var reset_options_container: VBoxContainer = %ResetOptionsContainer

## Tier buttons
var free_button: Button
var premium_button: Button
var subscription_button: Button

## Reset option buttons
var keep_chars_button: Button
var reset_chars_button: Button
var nuclear_reset_button: Button

## Current selections
var selected_tier: CharacterService.UserTier = CharacterService.UserTier.FREE
var selected_reset_mode: String = "keep_chars"  # "keep_chars", "reset_chars", "nuclear"


func _ready() -> void:
	GameLogger.warning("[DEBUG MENU] _ready() called - initializing...")

	# Safety check - this should NEVER be accessible in production builds
	if not OS.is_debug_build():
		push_error(
			"[DEBUG MENU] Attempted to open debug menu in production build! This is a critical error."
		)
		GameLogger.error("[DEBUG MENU] OS.is_debug_build() returned false - aborting")
		queue_free()
		return

	GameLogger.info("[DEBUG MENU] Debug build confirmed - continuing...")

	# Verify CharacterService is loaded
	if not is_instance_valid(CharacterService):
		push_error("[DEBUG MENU] CharacterService not loaded! Cannot open debug menu.")
		GameLogger.error("[DEBUG MENU] CharacterService not valid - aborting")
		queue_free()
		return

	GameLogger.info("[DEBUG MENU] CharacterService valid - continuing...")

	# Setup dialog properties
	title = "🛠️ QA Debug Menu"
	dialog_text = ""  # Clear default text - we're using custom UI
	ok_button_text = "Apply Changes"
	cancel_button_text = "Cancel"
	size = Vector2i(700, 650)  # Increased height to prevent button cutoff (matches .tscn)

	GameLogger.info("[DEBUG MENU] Dialog properties set")

	# Build UI
	GameLogger.info("[DEBUG MENU] Building tier buttons...")
	_setup_tier_buttons()

	GameLogger.info("[DEBUG MENU] Building reset options...")
	_setup_reset_options()

	GameLogger.info("[DEBUG MENU] Updating status display...")
	_update_status_display()

	# Connect signals
	confirmed.connect(_on_apply_changes)
	canceled.connect(_on_cancel)

	# Auto-cleanup
	confirmed.connect(queue_free)
	canceled.connect(queue_free)

	# Log opening
	GameLogger.warning("[DEBUG MENU] Debug menu initialized and ready to show")


func _setup_tier_buttons() -> void:
	GameLogger.info("[DEBUG MENU] _setup_tier_buttons() called")
	GameLogger.info(
		"[DEBUG MENU] tier_buttons_container valid: %s" % is_instance_valid(tier_buttons_container)
	)

	if not is_instance_valid(tier_buttons_container):
		push_error("[DEBUG MENU] TierButtonsContainer not found!")
		GameLogger.error("[DEBUG MENU] TierButtonsContainer is null or invalid!")
		return

	GameLogger.info("[DEBUG MENU] TierButtonsContainer found - creating buttons...")

	# Create tier selection buttons
	free_button = Button.new()
	free_button.text = "FREE\n(3 slots)"
	free_button.custom_minimum_size = Vector2(120, 80)
	free_button.toggle_mode = true
	free_button.pressed.connect(func(): _on_tier_selected(CharacterService.UserTier.FREE))
	tier_buttons_container.add_child(free_button)

	premium_button = Button.new()
	premium_button.text = "PREMIUM\n(15 slots)"
	premium_button.custom_minimum_size = Vector2(120, 80)
	premium_button.toggle_mode = true
	premium_button.pressed.connect(func(): _on_tier_selected(CharacterService.UserTier.PREMIUM))
	tier_buttons_container.add_child(premium_button)

	subscription_button = Button.new()
	subscription_button.text = "SUBSCRIPTION\n(50 slots)"
	subscription_button.custom_minimum_size = Vector2(120, 80)
	subscription_button.toggle_mode = true
	subscription_button.pressed.connect(
		func(): _on_tier_selected(CharacterService.UserTier.SUBSCRIPTION)
	)
	tier_buttons_container.add_child(subscription_button)

	# Highlight current tier
	selected_tier = CharacterService.current_tier
	_update_tier_button_states()

	GameLogger.info(
		(
			"[DEBUG MENU] Tier buttons created: Free=%s, Premium=%s, Sub=%s"
			% [
				is_instance_valid(free_button),
				is_instance_valid(premium_button),
				is_instance_valid(subscription_button)
			]
		)
	)


func _setup_reset_options() -> void:
	GameLogger.info("[DEBUG MENU] _setup_reset_options() called")
	GameLogger.info(
		(
			"[DEBUG MENU] reset_options_container valid: %s"
			% is_instance_valid(reset_options_container)
		)
	)

	if not is_instance_valid(reset_options_container):
		push_error("[DEBUG MENU] ResetOptionsContainer not found!")
		GameLogger.error("[DEBUG MENU] ResetOptionsContainer is null or invalid!")
		return

	GameLogger.info("[DEBUG MENU] ResetOptionsContainer found - creating buttons...")

	# Create reset mode buttons
	var label = Label.new()
	label.text = "Reset Options:"
	label.add_theme_font_size_override("font_size", 16)
	reset_options_container.add_child(label)

	# Keep characters (upgrade flow)
	keep_chars_button = Button.new()
	keep_chars_button.text = "✓ Keep Characters (test upgrade flow)"
	keep_chars_button.custom_minimum_size = Vector2(400, 60)
	keep_chars_button.toggle_mode = true
	keep_chars_button.pressed.connect(func(): _on_reset_mode_selected("keep_chars"))
	reset_options_container.add_child(keep_chars_button)

	# Reset characters (fresh account at tier)
	reset_chars_button = Button.new()
	reset_chars_button.text = "Reset Characters (fresh account at tier)"
	reset_chars_button.custom_minimum_size = Vector2(400, 60)
	reset_chars_button.toggle_mode = true
	reset_chars_button.pressed.connect(func(): _on_reset_mode_selected("reset_chars"))
	reset_options_container.add_child(reset_chars_button)

	# Nuclear reset (delete everything)
	nuclear_reset_button = Button.new()
	nuclear_reset_button.text = "⚠️ NUCLEAR RESET (delete all saves)"
	nuclear_reset_button.custom_minimum_size = Vector2(400, 60)
	nuclear_reset_button.toggle_mode = true
	nuclear_reset_button.pressed.connect(func(): _on_reset_mode_selected("nuclear"))
	reset_options_container.add_child(nuclear_reset_button)

	# Default selection
	_update_reset_button_states()

	GameLogger.info(
		(
			"[DEBUG MENU] Reset buttons created: Keep=%s, Reset=%s, Nuclear=%s"
			% [
				is_instance_valid(keep_chars_button),
				is_instance_valid(reset_chars_button),
				is_instance_valid(nuclear_reset_button)
			]
		)
	)


func _on_tier_selected(tier: CharacterService.UserTier) -> void:
	selected_tier = tier
	_update_tier_button_states()
	_update_status_display()
	GameLogger.info("[DEBUG] Tier selected: %s" % CharacterService.UserTier.keys()[tier])


func _on_reset_mode_selected(mode: String) -> void:
	selected_reset_mode = mode
	_update_reset_button_states()
	GameLogger.info("[DEBUG] Reset mode selected: %s" % mode)


func _update_tier_button_states() -> void:
	# Highlight selected tier
	free_button.button_pressed = (selected_tier == CharacterService.UserTier.FREE)
	premium_button.button_pressed = (selected_tier == CharacterService.UserTier.PREMIUM)
	subscription_button.button_pressed = (selected_tier == CharacterService.UserTier.SUBSCRIPTION)


func _update_reset_button_states() -> void:
	# Highlight selected reset mode
	keep_chars_button.button_pressed = (selected_reset_mode == "keep_chars")
	reset_chars_button.button_pressed = (selected_reset_mode == "reset_chars")
	nuclear_reset_button.button_pressed = (selected_reset_mode == "nuclear")


func _update_status_display() -> void:
	var current_tier_name = CharacterService.UserTier.keys()[CharacterService.current_tier]
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()
	var save_file_size = _get_save_file_size()

	var preview_tier_name = CharacterService.UserTier.keys()[selected_tier]
	var preview_slot_limit = CharacterService.SLOT_LIMITS[selected_tier]

	status_label.text = (
		"""CURRENT STATE:
• Tier: %s
• Characters: %d / %d slots
• Save File: %s

PREVIEW (after apply):
• New Tier: %s
• New Slot Limit: %d
• Reset Mode: %s
"""
		% [
			current_tier_name,
			character_count,
			slot_limit,
			save_file_size,
			preview_tier_name,
			preview_slot_limit,
			_get_reset_mode_description(selected_reset_mode)
		]
	)


func _get_reset_mode_description(mode: String) -> String:
	match mode:
		"keep_chars":
			return "Keep all characters (test upgrade)"
		"reset_chars":
			return "Delete all characters (fresh account)"
		"nuclear":
			return "⚠️ DELETE ALL SAVES (full reset)"
		_:
			return "Unknown"


func _get_save_file_size() -> String:
	# Construct save path using SaveSystem's constants
	var save_path = SaveSystem.SAVE_DIR + "save_%d.cfg" % 0
	if not FileAccess.file_exists(save_path):
		return "No save file"

	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return "Error reading save"

	var size_bytes = file.get_length()
	file.close()

	if size_bytes < 1024:
		return "%d bytes" % size_bytes
	if size_bytes < 1024 * 1024:
		return "%.1f KB" % (size_bytes / 1024.0)
	return "%.2f MB" % (size_bytes / (1024.0 * 1024.0))


func _on_apply_changes() -> void:
	# Confirmation dialog for destructive actions
	if selected_reset_mode == "nuclear":
		_show_nuclear_confirmation()
		return
	if selected_reset_mode == "reset_chars":
		_show_reset_chars_confirmation()
		return

	# Safe path - just change tier
	_apply_tier_change()


func _show_nuclear_confirmation() -> void:
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.title = "⚠️ CONFIRM NUCLEAR RESET"
	confirm_dialog.dialog_text = (
		"""THIS WILL DELETE ALL DATA:
• All characters will be permanently deleted
• All save files will be erased
• GameState will be reset
• You will start fresh at %s tier

This action CANNOT be undone.

Are you absolutely sure?"""
		% CharacterService.UserTier.keys()[selected_tier]
	)

	confirm_dialog.ok_button_text = "YES, DELETE EVERYTHING"
	confirm_dialog.cancel_button_text = "Cancel"

	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

	confirm_dialog.confirmed.connect(
		func():
			_apply_nuclear_reset()
			confirm_dialog.queue_free()
	)
	confirm_dialog.canceled.connect(func(): confirm_dialog.queue_free())


func _show_reset_chars_confirmation() -> void:
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.title = "Confirm Character Reset"
	confirm_dialog.dialog_text = (
		"""This will:
• Delete all %d characters
• Keep save file structure
• Set tier to %s
• Reset GameState

Continue?"""
		% [CharacterService.get_character_count(), CharacterService.UserTier.keys()[selected_tier]]
	)

	confirm_dialog.ok_button_text = "Reset Characters"
	confirm_dialog.cancel_button_text = "Cancel"

	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

	confirm_dialog.confirmed.connect(
		func():
			_apply_char_reset()
			confirm_dialog.queue_free()
	)
	confirm_dialog.canceled.connect(func(): confirm_dialog.queue_free())


func _apply_tier_change() -> void:
	var old_tier = CharacterService.current_tier
	var new_tier = selected_tier

	# Change tier
	CharacterService.set_tier(new_tier)

	# Save
	SaveManager.save_all_services()

	# Log
	GameLogger.warning(
		(
			"[DEBUG] Tier changed: %s → %s (kept %d characters)"
			% [
				CharacterService.UserTier.keys()[old_tier],
				CharacterService.UserTier.keys()[new_tier],
				CharacterService.get_character_count()
			]
		)
	)

	_show_success_notification("Tier changed to %s" % CharacterService.UserTier.keys()[new_tier])


func _apply_char_reset() -> void:
	# Delete all characters
	var character_ids = CharacterService.characters.keys()
	for character_id in character_ids:
		CharacterService.delete_character(character_id)

	# Change tier
	CharacterService.set_tier(selected_tier)

	# Reset GameState
	GameState.reset()

	# Save
	SaveManager.save_all_services()

	# Log
	var tier_name = CharacterService.UserTier.keys()[selected_tier]
	var msg = "[DEBUG] Character reset: deleted %d characters, set tier to %s"
	GameLogger.warning(msg % [character_ids.size(), tier_name])

	_show_success_notification(
		"Reset complete: 0 characters, %s tier" % CharacterService.UserTier.keys()[selected_tier]
	)


func _apply_nuclear_reset() -> void:
	# Delete save file
	SaveManager.delete_save(0)

	# Reset all services
	CharacterService.reset()
	GameState.reset()

	# Set new tier
	CharacterService.set_tier(selected_tier)

	# Save fresh state
	SaveManager.save_all_services()

	# Log
	GameLogger.warning(
		(
			"[DEBUG] NUCLEAR RESET: all data deleted, fresh start at %s tier"
			% CharacterService.UserTier.keys()[selected_tier]
		)
	)

	_show_success_notification(
		(
			"Nuclear reset complete: fresh start at %s tier"
			% CharacterService.UserTier.keys()[selected_tier]
		)
	)


func _show_success_notification(message: String) -> void:
	var notification = AcceptDialog.new()
	notification.title = "✓ Debug Action Complete"
	notification.dialog_text = message
	notification.ok_button_text = "OK"

	add_child(notification)
	notification.popup_centered()
	notification.confirmed.connect(func(): notification.queue_free())


func _on_cancel() -> void:
	GameLogger.info("[DEBUG] Debug menu canceled (no changes)")
