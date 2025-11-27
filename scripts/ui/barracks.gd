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

## Components (Week 17: Unified CharacterTypeCard component)
const CHARACTER_TYPE_CARD_SCENE: PackedScene = preload(
	"res://scenes/ui/components/character_type_card.tscn"
)
const MODAL_FACTORY = preload("res://scripts/ui/components/modal_factory.gd")
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

@onready
var character_list: GridContainer = $ScreenContainer/VBoxContainer/CharacterListContainer/ScrollContainer/CharacterList
@onready var slot_label: Label = $ScreenContainer/VBoxContainer/HeaderContainer/SlotLabel
@onready
var create_new_button: Button = $ScreenContainer/VBoxContainer/ButtonsContainer/CreateNewButton
@onready var back_button: Button = $ScreenContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


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
	"""Create a character card for grid display (Week 17: CharacterTypeCard component)"""
	# Instantiate CharacterTypeCard component
	var card = CHARACTER_TYPE_CARD_SCENE.instantiate()

	# Add to scene tree FIRST (so @onready variables initialize)
	character_list.add_child(card)

	# THEN setup with character data (after @onready vars are ready)
	card.setup_player(character)

	# Connect card tap signal → navigate to details
	card.card_pressed.connect(_on_character_card_pressed)

	GameLogger.debug(
		"[CharacterRoster] Card created",
		{"character_id": character.get("id", ""), "name": character.get("name", "")}
	)


func _show_empty_state() -> void:
	"""Show message when no characters exist"""
	var empty_label = Label.new()
	character_list.add_child(empty_label)  # Parent FIRST (Godot 4 Parent-First Protocol)
	empty_label.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	empty_label.text = "No survivors yet.\nCreate your first character to begin!"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 20)
	empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))


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

	# Apply button styling
	THEME_HELPER.apply_button_style(create_new_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(back_button, THEME_HELPER.ButtonStyle.SECONDARY)

	# Apply button icons
	UI_ICONS.apply_button_icon(back_button, UI_ICONS.Icon.BACK)


func _on_character_card_pressed(character_id: String) -> void:
	"""Handle card tap - navigate to full-screen character details (Phase 9.2)"""
	GameLogger.debug("[CharacterRoster] Card pressed", {"character_id": character_id})
	_play_sound(BUTTON_CLICK_SOUND)

	# Get character data to verify it exists
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.error(
			"[CharacterRoster] Character not found for details", {"character_id": character_id}
		)
		return

	# Phase 9.2 Fix: Set viewing_character_id (NOT active_character_id)
	# Tapping a card opens details for VIEWING, not SELECTING
	# Selection only happens when user taps "Select Survivor" button
	GameState.viewing_character_id = character_id

	# Navigate to full-screen character details screen
	get_tree().change_scene_to_file("res://scenes/ui/character_details_screen.tscn")


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
