extends Control
## CharacterDetailsScreen - Full-screen character details with action bar
## Phase 9.2: Added bottom action bar with Select/Start Run/Delete
##
## Architecture:
## - Full-screen hierarchical navigation (iOS HIG compliant)
## - Left sidebar: Character roster for quick switching
## - Main content: Embedded CharacterDetailsPanel
## - Bottom action bar: Select, Start Run, Delete buttons
##
## Flow:
## - Tap "Select Survivor" → Sets active character → Returns to Barracks
## - Tap "Start Run" → Launches combat with this character
## - Tap Delete → Confirmation modal → Delete character

## Audio
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")
const CHARACTER_SELECT_SOUND: AudioStream = preload("res://assets/audio/ui/character_select.ogg")
const ERROR_SOUND: AudioStream = preload("res://assets/audio/ui/ui_error.ogg")

## Component references
const CHARACTER_DETAILS_PANEL_SCENE: PackedScene = preload(
	"res://scenes/ui/character_details_panel.tscn"
)
const MODAL_FACTORY = preload("res://scripts/ui/components/modal_factory.gd")
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

## UI references
@onready var back_button: Button = $MainContainer/ContentArea/HeaderBar/BackButton
@onready var title_label: Label = $MainContainer/ContentArea/HeaderBar/TitleLabel
@onready
var details_content_container: MarginContainer = $MainContainer/ContentArea/DetailsContentContainer
@onready
var sidebar_character_list: VBoxContainer = $MainContainer/SidebarContainer/SidebarScroll/SidebarCharacterList
@onready var select_button: Button = $MainContainer/ContentArea/BottomActionBar/SelectButton
@onready var start_run_button: Button = $MainContainer/ContentArea/BottomActionBar/StartRunButton
@onready var delete_button: Button = $MainContainer/ContentArea/BottomActionBar/DeleteButton

## Audio player (created dynamically)
var audio_player: AudioStreamPlayer

## State
var current_character_id: String = ""
var details_panel: Panel = null


func _ready() -> void:
	GameLogger.info("[CharacterDetailsScreen] Initializing")

	# Create audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	# Connect signals
	back_button.pressed.connect(_on_back_pressed)
	select_button.pressed.connect(_on_select_pressed)
	start_run_button.pressed.connect(_on_start_run_pressed)
	delete_button.pressed.connect(_on_delete_pressed)

	# Apply button styling
	THEME_HELPER.apply_button_style(select_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(start_run_button, THEME_HELPER.ButtonStyle.SECONDARY)
	THEME_HELPER.apply_button_style(delete_button, THEME_HELPER.ButtonStyle.DANGER)
	THEME_HELPER.apply_button_style(back_button, THEME_HELPER.ButtonStyle.SECONDARY)

	# Apply button icons
	UI_ICONS.apply_button_icon(delete_button, UI_ICONS.Icon.DELETE)
	UI_ICONS.apply_button_icon(back_button, UI_ICONS.Icon.BACK)

	# Add button animations
	THEME_HELPER.add_button_animation(select_button)
	THEME_HELPER.add_button_animation(start_run_button)
	THEME_HELPER.add_button_animation(delete_button)
	THEME_HELPER.add_button_animation(back_button)

	# Phase 9.2 Fix: Load character from viewing_character_id (set by card tap)
	# This is the character user wants to VIEW (not necessarily the selected one)
	var viewing_id = GameState.viewing_character_id
	if viewing_id.is_empty():
		GameLogger.error("[CharacterDetailsScreen] No character to view, returning to roster")
		_navigate_to_roster()
		return

	# Show the character being viewed
	_show_character(viewing_id)

	# Populate sidebar roster
	_populate_sidebar_roster()

	GameLogger.info("[CharacterDetailsScreen] Initialized", {"character_id": viewing_id})


func _show_character(character_id: String) -> void:
	"""Display character details in main content area"""
	GameLogger.debug("[CharacterDetailsScreen] _show_character()", {"character_id": character_id})

	# Get character data
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.error(
			"[CharacterDetailsScreen] Character not found", {"character_id": character_id}
		)
		_navigate_to_roster()
		return

	current_character_id = character_id

	# Update title
	title_label.text = character.get("name", "Character Details")

	# Clear existing details panel
	if details_panel:
		details_panel.queue_free()
		details_panel = null

	# Create CharacterDetailsPanel
	details_panel = CHARACTER_DETAILS_PANEL_SCENE.instantiate()

	# Parent FIRST (Parent-First Protocol)
	details_content_container.add_child(details_panel)

	# THEN configure (after parenting)
	details_panel.layout_mode = 2
	details_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Hide close button (we have header back button instead)
	var close_btn = details_panel.get_node_or_null("MarginContainer/VBoxContainer/CloseButton")
	if close_btn:
		close_btn.visible = false

	# Connect close signal (redirect to back navigation)
	details_panel.closed.connect(_on_back_pressed)

	# Show character data
	details_panel.show_character(character)

	# Update Select button state
	_update_select_button_state()


func _update_select_button_state() -> void:
	"""Update Select button based on whether this character is already selected"""
	var is_currently_selected = (
		GameState.active_character_id == current_character_id
		and not current_character_id.is_empty()
	)

	if is_currently_selected:
		select_button.text = "✓ Selected"
		select_button.disabled = true
	else:
		select_button.text = "Select Survivor"
		select_button.disabled = false


func _populate_sidebar_roster() -> void:
	"""Populate sidebar with character portraits for quick switching"""
	GameLogger.debug("[CharacterDetailsScreen] _populate_sidebar_roster() ENTRY")

	# Clear existing
	for child in sidebar_character_list.get_children():
		child.queue_free()

	# Get all characters
	var characters = CharacterService.get_all_characters()
	if characters == null or characters.is_empty():
		GameLogger.warning("[CharacterDetailsScreen] No characters to display in sidebar")
		return

	# Sort by last played (most recent first)
	characters.sort_custom(func(a, b): return a.get("last_played", 0) > b.get("last_played", 0))

	# Create button for each character
	for character in characters:
		var char_id = character.get("id", "")
		var char_name = character.get("name", "Unknown")

		var btn = Button.new()

		# Parent FIRST (Parent-First Protocol)
		sidebar_character_list.add_child(btn)

		# THEN configure (after parenting)
		btn.layout_mode = 2
		btn.custom_minimum_size = Vector2(0, 70)
		btn.text = char_name
		btn.add_theme_font_size_override("font_size", 20)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Highlight current character
		if char_id == current_character_id:
			btn.disabled = true

		# Connect signal with character_id binding
		btn.pressed.connect(_on_sidebar_character_pressed.bind(char_id))

	GameLogger.debug(
		"[CharacterDetailsScreen] _populate_sidebar_roster() EXIT", {"count": characters.size()}
	)


func _on_sidebar_character_pressed(character_id: String) -> void:
	"""Handle sidebar character button - switch to different character"""
	GameLogger.debug(
		"[CharacterDetailsScreen] Sidebar character pressed", {"character_id": character_id}
	)

	# Show new character
	_show_character(character_id)

	# Update sidebar highlighting
	_populate_sidebar_roster()


func _on_select_pressed() -> void:
	"""Handle Select Survivor button - set as active character and return to Barracks"""
	_play_sound(CHARACTER_SELECT_SOUND)
	GameLogger.info(
		"[CharacterDetailsScreen] Select button pressed", {"character_id": current_character_id}
	)

	# Get character for analytics
	var character = CharacterService.get_character(current_character_id)

	# Set as active character (this persists via GameState)
	GameState.set_active_character(current_character_id)

	# Track analytics
	Analytics.character_selected(
		character.get("character_type", "unknown"), character.get("level", 1)
	)

	# Update last_played timestamp
	character["last_played"] = Time.get_unix_time_from_system()
	CharacterService.update_character(current_character_id, character)

	# Save changes
	SaveManager.save_all_services()

	GameLogger.info(
		"[CharacterDetailsScreen] Character selected, returning to Barracks",
		{"character_id": current_character_id}
	)

	# Return to Barracks (roster) with selection visible
	_navigate_to_roster()


func _on_start_run_pressed() -> void:
	"""Handle Start Run button - select character and launch combat"""
	_play_sound(CHARACTER_SELECT_SOUND)
	GameLogger.info(
		"[CharacterDetailsScreen] Start Run pressed", {"character_id": current_character_id}
	)

	# Get character for analytics
	var character = CharacterService.get_character(current_character_id)

	# Set as active character
	GameState.set_active_character(current_character_id)

	# Track analytics
	Analytics.character_selected(
		character.get("character_type", "unknown"), character.get("level", 1)
	)

	# Update last_played timestamp
	character["last_played"] = Time.get_unix_time_from_system()
	CharacterService.update_character(current_character_id, character)

	# Save before launching
	SaveManager.save_all_services()

	# Launch combat
	if ResourceLoader.exists("res://scenes/game/wasteland.tscn"):
		get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")
	else:
		GameLogger.error("[CharacterDetailsScreen] wasteland.tscn not found")
		_play_sound(ERROR_SOUND)


func _on_delete_pressed() -> void:
	"""Handle Delete button - show destructive confirmation modal"""
	_play_sound(BUTTON_CLICK_SOUND)

	var character = CharacterService.get_character(current_character_id)
	var character_name = character.get("name", "this character")

	# Show mobile-native destructive confirmation
	MODAL_FACTORY.show_destructive_confirmation(
		self,
		"Delete Survivor?",
		"Delete '%s'? This cannot be undone." % character_name,
		func(): _execute_delete()
	)


func _execute_delete() -> void:
	"""Execute character deletion after confirmation"""
	# Get character data for analytics before deletion
	var character = CharacterService.get_character(current_character_id)

	# Delete character
	var success = CharacterService.delete_character(current_character_id)
	if success:
		GameLogger.info(
			"[CharacterDetailsScreen] Character deleted", {"character_id": current_character_id}
		)

		# Track deletion in analytics
		Analytics.character_deleted(
			character.get("character_type", "unknown"), character.get("level", 1)
		)

		# Save changes
		SaveManager.save_all_services()

		# Return to roster (character no longer exists)
		_navigate_to_roster()
	else:
		GameLogger.error(
			"[CharacterDetailsScreen] Failed to delete character",
			{"character_id": current_character_id}
		)
		_play_sound(ERROR_SOUND)


func _on_back_pressed() -> void:
	"""Handle back button - return to character roster"""
	GameLogger.debug("[CharacterDetailsScreen] Back button pressed")
	_navigate_to_roster()


func _navigate_to_roster() -> void:
	"""Navigate back to character roster screen"""
	get_tree().change_scene_to_file("res://scenes/ui/character_roster.tscn")


func _play_sound(sound: AudioStream) -> void:
	"""Play UI sound and haptic feedback"""
	HapticManager.light()
	if audio_player:
		audio_player.stream = sound
		audio_player.play()
