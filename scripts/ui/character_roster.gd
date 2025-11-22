extends Control
## Character Roster UI
## Week 15 Phase 3: View, select, and manage saved characters
##
## Features:
## - List all saved characters
## - Select character to start run
## - Delete characters (with confirmation)
## - Create new character button (respects slot limits)

## Audio
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")
const CHARACTER_SELECT_SOUND: AudioStream = preload("res://assets/audio/ui/character_select.ogg")
const ERROR_SOUND: AudioStream = preload("res://assets/audio/ui/ui_error.ogg")

## Components (QA Fix #2: Use CharacterCard component instead of manual UI generation)
const CHARACTER_CARD_SCENE: PackedScene = preload("res://scenes/ui/character_card.tscn")
const CHARACTER_DETAILS_PANEL_SCENE: PackedScene = preload(
	"res://scenes/ui/character_details_panel.tscn"
)
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

@onready var character_list: VBoxContainer = $CharacterListContainer/ScrollContainer/CharacterList
@onready var slot_label: Label = $HeaderContainer/SlotLabel
@onready var create_new_button: Button = $ButtonsContainer/CreateNewButton
@onready var back_button: Button = $ButtonsContainer/BackButton
@onready var delete_confirmation: ConfirmationDialog = $DeleteConfirmationDialog
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var character_to_delete: String = ""  # Track character ID pending deletion
var character_details_panel: Control = null  # Details panel instance (created on demand)


func _ready() -> void:
	GameLogger.info("[CharacterRoster] Initializing")

	_populate_character_list()
	_update_slot_label()
	_connect_signals()

	# Add button animations (Week16: ButtonAnimation component)
	THEME_HELPER.add_button_animation(create_new_button)
	THEME_HELPER.add_button_animation(back_button)

	GameLogger.info(
		"[CharacterRoster] Initialized", {"character_count": CharacterService.get_character_count()}
	)


func _exit_tree() -> void:
	GameLogger.info("[CharacterRoster] Cleanup complete")


func _populate_character_list() -> void:
	"""Load and display all saved characters"""
	# Clear existing list
	for child in character_list.get_children():
		child.queue_free()

	# Get characters from CharacterService
	var characters = CharacterService.get_all_characters()

	# Null safety: Handle corrupted save data
	if characters == null:
		GameLogger.error("[CharacterRoster] Failed to load characters (corrupted save data)")
		_show_empty_state()
		return

	if characters.is_empty():
		_show_empty_state()
		return

	# Sort by last played (most recent first)
	characters.sort_custom(func(a, b): return a.get("last_played", 0) > b.get("last_played", 0))

	# Create list item for each character
	for character in characters:
		_create_character_list_item(character)

	GameLogger.info("[CharacterRoster] Displayed characters", {"count": characters.size()})


func _create_character_list_item(character: Dictionary) -> void:
	"""Create a character list item using CharacterCard component (QA Fix #2)"""
	# Instantiate CharacterCard component
	var card = CHARACTER_CARD_SCENE.instantiate()

	# Add to scene tree FIRST (so @onready variables initialize)
	character_list.add_child(card)

	# THEN setup with character data (after @onready vars are ready)
	card.setup(character)

	# Connect signals
	card.play_pressed.connect(_on_character_play_pressed)
	card.delete_pressed.connect(_on_character_delete_pressed)
	card.details_pressed.connect(_on_character_details_pressed)


func _show_empty_state() -> void:
	"""Show message when no characters exist"""
	var empty_label = Label.new()
	empty_label.text = "No survivors yet.\nCreate your first character to begin!"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 20)
	empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	character_list.add_child(empty_label)


func _update_slot_label() -> void:
	"""Update slot count display"""
	var character_count = CharacterService.get_character_count()
	var slot_limit = CharacterService.get_character_slot_limit()
	var tier = CharacterService.get_tier()
	var tier_name = ["Free", "Premium", "Subscription"][tier]

	slot_label.text = "%d/%d Survivors (%s Tier)" % [character_count, slot_limit, tier_name]

	# Disable create button if at limit
	if character_count >= slot_limit:
		create_new_button.disabled = true
		create_new_button.tooltip_text = "Slot limit reached. Upgrade tier for more slots."

		GameLogger.info(
			"[CharacterRoster] Slot limit reached",
			{"count": character_count, "limit": slot_limit, "tier": tier}
		)
	else:
		create_new_button.disabled = false
		create_new_button.tooltip_text = ""


func _connect_signals() -> void:
	"""Connect button signals"""
	create_new_button.pressed.connect(_on_create_new_pressed)
	back_button.pressed.connect(_on_back_pressed)
	delete_confirmation.confirmed.connect(_on_delete_confirmed)
	delete_confirmation.canceled.connect(_on_delete_cancelled)  # Fixed: American spelling

	# Apply button styling
	THEME_HELPER.apply_button_style(create_new_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(back_button, THEME_HELPER.ButtonStyle.SECONDARY)

	# Apply button icons
	UI_ICONS.apply_button_icon(back_button, UI_ICONS.Icon.BACK)


func _on_character_play_pressed(character_id: String) -> void:
	"""Handle Play button - select character and launch combat"""
	_play_sound(CHARACTER_SELECT_SOUND)

	GameLogger.info("[CharacterRoster] Character selected for play", {"character_id": character_id})
	Analytics.character_selected(
		CharacterService.get_character(character_id).get("character_type", "unknown"),
		CharacterService.get_character(character_id).get("level", 1)
	)

	# Set as active character
	GameState.set_active_character(character_id)

	# Update last_played timestamp
	var character = CharacterService.get_character(character_id)
	character["last_played"] = Time.get_unix_time_from_system()
	CharacterService.update_character(character_id, character)

	# Save before launching
	SaveManager.save_all_services()

	# Launch combat (with safety check)
	if ResourceLoader.exists("res://scenes/game/wasteland.tscn"):
		get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")
	else:
		GameLogger.error("[CharacterRoster] wasteland.tscn not found")
		_play_sound(ERROR_SOUND)


func _on_character_delete_pressed(character_id: String, character_name: String) -> void:
	"""Handle Delete button - show confirmation dialog"""
	_play_sound(BUTTON_CLICK_SOUND)
	HapticManager.warning()  # Extra warning haptic for destructive action

	GameLogger.info(
		"[CharacterRoster] Delete button pressed",
		{"character_id": character_id, "name": character_name}
	)

	character_to_delete = character_id
	delete_confirmation.dialog_text = (
		"Delete survivor '%s'?\nThis cannot be undone." % character_name
	)

	# iOS HIG: Apply red destructive styling to Delete button
	var ok_button = delete_confirmation.get_ok_button()
	if ok_button:
		THEME_HELPER.apply_button_style(ok_button, THEME_HELPER.ButtonStyle.DANGER)

	delete_confirmation.popup_centered()


func _on_character_details_pressed(character_id: String) -> void:
	"""Handle Details button - show character details panel (QA Fix #2b)"""
	_play_sound(BUTTON_CLICK_SOUND)

	GameLogger.info("[CharacterRoster] Details button pressed", {"character_id": character_id})

	# Get character data
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.error(
			"[CharacterRoster] Character not found for details", {"character_id": character_id}
		)
		return

	# Create details panel if it doesn't exist
	if character_details_panel == null:
		character_details_panel = CHARACTER_DETAILS_PANEL_SCENE.instantiate()
		add_child(character_details_panel)
		character_details_panel.closed.connect(_on_details_panel_closed)

	# Show character details
	character_details_panel.show_character(character)
	character_details_panel.visible = true


func _on_details_panel_closed() -> void:
	"""Handle details panel close"""
	if character_details_panel:
		character_details_panel.visible = false


func _on_delete_confirmed() -> void:
	"""Handle delete confirmation - actually delete character"""
	if character_to_delete.is_empty():
		return

	var character = CharacterService.get_character(character_to_delete)
	var success = CharacterService.delete_character(character_to_delete)

	if success:
		GameLogger.info(
			"[CharacterRoster] Character deleted", {"character_id": character_to_delete}
		)
		Analytics.character_deleted(
			character.get("character_type", "unknown"), character.get("level", 1)
		)

		SaveManager.save_all_services()

		# Refresh list
		_populate_character_list()
		_update_slot_label()
	else:
		_play_sound(ERROR_SOUND)
		GameLogger.error(
			"[CharacterRoster] Failed to delete character", {"character_id": character_to_delete}
		)

	character_to_delete = ""


func _on_delete_cancelled() -> void:
	"""Handle delete dialog cancelled - clear pending deletion"""
	GameLogger.info("[CharacterRoster] Delete cancelled")
	character_to_delete = ""


func _on_create_new_pressed() -> void:
	"""Handle Create New button - navigate to character creation"""
	_play_sound(BUTTON_CLICK_SOUND)

	GameLogger.info("[CharacterRoster] Create new button pressed")
	Analytics.hub_button_pressed("CreateNewCharacter")

	if ResourceLoader.exists("res://scenes/ui/character_creation.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/character_creation.tscn")
	else:
		GameLogger.error("[CharacterRoster] character_creation.tscn not found")
		_play_sound(ERROR_SOUND)


func _on_back_pressed() -> void:
	"""Handle Back button - return to hub"""
	_play_sound(BUTTON_CLICK_SOUND)

	GameLogger.info("[CharacterRoster] Back button pressed")
	Analytics.hub_button_pressed("BackFromRoster")

	if ResourceLoader.exists("res://scenes/hub/scrapyard.tscn"):
		get_tree().change_scene_to_file("res://scenes/hub/scrapyard.tscn")
	else:
		GameLogger.error("[CharacterRoster] scrapyard.tscn not found")
		_play_sound(ERROR_SOUND)


func _play_sound(sound: AudioStream) -> void:
	"""Play UI sound and haptic feedback"""
	HapticManager.light()
	if audio_player:
		audio_player.stream = sound
		audio_player.play()
