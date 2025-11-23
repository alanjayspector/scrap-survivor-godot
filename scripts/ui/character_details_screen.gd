extends Control
## CharacterDetailsScreen - Full-screen character details with sidebar navigation
## Week 16 QA Pass 10 Fix: Replaces modal sheet pattern with full-screen pattern
##
## Architecture:
## - Full-screen hierarchical navigation (iOS HIG compliant)
## - Left sidebar: Character roster for quick switching
## - Main content: Embedded CharacterDetailsPanel
## - Matches Genshin Impact pattern for complex character management
##
## Fixes:
## - Design: Modal sheets inappropriate for 3-tab + 20-stat complexity
## - Technical: Simpler lifecycle than modal overlay hierarchy

## Component references
const CHARACTER_DETAILS_PANEL_SCENE: PackedScene = preload(
	"res://scenes/ui/character_details_panel.tscn"
)

## UI references
@onready var back_button: Button = $MainContainer/ContentArea/HeaderBar/BackButton
@onready var title_label: Label = $MainContainer/ContentArea/HeaderBar/TitleLabel
@onready
var details_content_container: MarginContainer = $MainContainer/ContentArea/DetailsContentContainer
@onready
var sidebar_character_list: VBoxContainer = $MainContainer/SidebarContainer/SidebarScroll/SidebarCharacterList

## State
var current_character_id: String = ""
var details_panel: Panel = null


func _ready() -> void:
	GameLogger.info("[CharacterDetailsScreen] Initializing")

	# Connect signals
	back_button.pressed.connect(_on_back_pressed)

	# Load character from GameState (set by previous screen)
	var selected_id = GameState.active_character_id
	if selected_id.is_empty():
		GameLogger.error("[CharacterDetailsScreen] No character selected, returning to roster")
		_navigate_to_roster()
		return

	# Show the selected character
	_show_character(selected_id)

	# Populate sidebar roster
	_populate_sidebar_roster()

	GameLogger.info("[CharacterDetailsScreen] Initialized", {"character_id": selected_id})


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


func _populate_sidebar_roster() -> void:
	"""Populate sidebar with character portraits for quick switching"""
	GameLogger.debug("[CharacterDetailsScreen] _populate_sidebar_roster() ENTRY")

	# Clear existing
	for child in sidebar_character_list.get_children():
		child.queue_free()

	# Get all characters
	var characters = CharacterService.get_all_characters()
	if characters == null or characters.is_empty():
		GameLogger.warn("[CharacterDetailsScreen] No characters to display in sidebar")
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
		btn.custom_minimum_size = Vector2(0, 60)
		btn.text = char_name
		btn.theme_override_font_sizes["font_size"] = 16
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


func _on_back_pressed() -> void:
	"""Handle back button - return to character roster"""
	GameLogger.debug("[CharacterDetailsScreen] Back button pressed")
	_navigate_to_roster()


func _navigate_to_roster() -> void:
	"""Navigate back to character roster screen"""
	get_tree().change_scene_to_file("res://scenes/ui/character_roster.tscn")
