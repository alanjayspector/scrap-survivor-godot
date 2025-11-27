extends Control
## EnterWastelandConfirmation - Dramatic pre-combat confirmation screen
## Week 17 Phase 4: "Enter the Wasteland" transition moment
##
## Architecture:
## - Full-bleed wasteland-gate.png background (dramatic visual)
## - Semi-transparent overlay for modal contrast
## - Modal with CharacterTypeCard showing selected character
## - "SCAVENGE" primary action (launches combat)
## - "Cancel" secondary action (returns to previous screen)
##
## Flow:
## - Opened from Hub (wasteland gate button) or Character Details (Start Run)
## - Shows currently selected character (GameState.active_character_id)
## - "SCAVENGE" → Transitions to combat/game scene
## - "Cancel" → Returns to previous screen
##
## References:
## - docs/migration/week17-plan.md (Phase 4 spec)
## - art-docs/Scrapyard_Scene_Art_Bible.md (colors)
## - CLAUDE_RULES.md (Parent-First Protocol, Modal sizing)

## Audio
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")

## Component references
const CHARACTER_TYPE_CARD_SCENE: PackedScene = preload(
	"res://scenes/ui/components/character_type_card.tscn"
)
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

## Signals
signal scavenge_pressed
signal cancel_pressed

## Art Bible colors
const COLOR_PRIMARY_ORANGE := Color("#FF6600")
const COLOR_CHARCOAL_DARK := Color(0.1, 0.1, 0.1, 0.95)
const COLOR_MODAL_OVERLAY := Color(0, 0, 0, 0.7)

## Modal sizing (per CLAUDE_RULES destructive operation standards - using generous sizing)
const MODAL_WIDTH_PERCENT := 0.90
const MODAL_MAX_WIDTH := 500.0
const MODAL_MIN_HEIGHT := 380.0  # Taller for character preview
const MODAL_PADDING := 36
const MODAL_CORNER_RADIUS := 16

## Button sizing (prominence for important action)
const BUTTON_HEIGHT := 64
const BUTTON_MIN_WIDTH := 140
const BUTTON_FONT_SIZE := 22
const BUTTON_SPACING := 20

## Typography
const TITLE_FONT_SIZE := 32
const SUBTITLE_FONT_SIZE := 18

## UI node references (created in _ready)
var background_rect: TextureRect
var overlay_rect: ColorRect
var modal_panel: PanelContainer
var modal_vbox: VBoxContainer
var title_label: Label
var card_container: CenterContainer
var character_card: Button  # CharacterTypeCard
var button_container: HBoxContainer
var cancel_button: Button
var scavenge_button: Button

## Audio player
var audio_player: AudioStreamPlayer

## State
var _character_data: Dictionary = {}
var _return_scene: String = ""  # Where to go on cancel


func _ready() -> void:
	GameLogger.info("[EnterWastelandConfirmation] Initializing")

	# Create audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	# Build UI hierarchy
	_build_background()
	_build_overlay()
	_build_modal()

	# Load selected character data
	_load_character_data()

	GameLogger.info("[EnterWastelandConfirmation] Ready")


## ============================================================================
## UI BUILDING - Parent-First Protocol (CLAUDE_RULES mandatory)
## ============================================================================


func _build_background() -> void:
	"""Background is now defined in the .tscn file for proper rendering"""
	# Background TextureRect is in the scene file - no dynamic creation needed
	# This ensures proper resource loading and texture display
	GameLogger.debug("[EnterWastelandConfirmation] Using scene-defined background")


func _build_overlay() -> void:
	"""Build semi-transparent overlay for modal contrast"""
	overlay_rect = ColorRect.new()
	add_child(overlay_rect)  # Parent FIRST
	overlay_rect.layout_mode = 1
	overlay_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_rect.color = COLOR_MODAL_OVERLAY


func _build_modal() -> void:
	"""Build centered modal with character preview and action buttons"""
	# Calculate modal dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	var modal_width = min(viewport_size.x * MODAL_WIDTH_PERCENT, MODAL_MAX_WIDTH)

	# Create modal panel - Parent FIRST, then configure
	modal_panel = PanelContainer.new()
	add_child(modal_panel)  # Parent FIRST per CLAUDE_RULES
	modal_panel.layout_mode = 1

	# Manual centering (per CLAUDE_RULES - size first, then position)
	modal_panel.custom_minimum_size = Vector2(modal_width, MODAL_MIN_HEIGHT)
	modal_panel.size = Vector2(modal_width, MODAL_MIN_HEIGHT)

	# Set anchors to center
	modal_panel.anchor_left = 0.5
	modal_panel.anchor_top = 0.5
	modal_panel.anchor_right = 0.5
	modal_panel.anchor_bottom = 0.5

	# Calculate offsets based on size
	var half_width = modal_width / 2.0
	var half_height = MODAL_MIN_HEIGHT / 2.0
	modal_panel.offset_left = -half_width
	modal_panel.offset_top = -half_height
	modal_panel.offset_right = half_width
	modal_panel.offset_bottom = half_height

	# Style the modal panel
	_style_modal_panel()

	# Build modal content
	_build_modal_content()


func _style_modal_panel() -> void:
	"""Apply dark charcoal styling to modal panel"""
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_CHARCOAL_DARK
	style.corner_radius_top_left = MODAL_CORNER_RADIUS
	style.corner_radius_top_right = MODAL_CORNER_RADIUS
	style.corner_radius_bottom_left = MODAL_CORNER_RADIUS
	style.corner_radius_bottom_right = MODAL_CORNER_RADIUS
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_PRIMARY_ORANGE
	style.content_margin_left = MODAL_PADDING
	style.content_margin_right = MODAL_PADDING
	style.content_margin_top = MODAL_PADDING
	style.content_margin_bottom = MODAL_PADDING
	modal_panel.add_theme_stylebox_override("panel", style)


func _build_modal_content() -> void:
	"""Build modal interior: title, character card, buttons"""
	# VBoxContainer for vertical layout
	modal_vbox = VBoxContainer.new()
	modal_panel.add_child(modal_vbox)  # Parent FIRST
	modal_vbox.layout_mode = 2
	modal_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_vbox.add_theme_constant_override("separation", 24)

	# Title: "ENTER THE WASTELAND"
	_build_title()

	# Character card preview (centered)
	_build_character_preview()

	# Spacer to push buttons to bottom
	var spacer = Control.new()
	modal_vbox.add_child(spacer)
	spacer.layout_mode = 2
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Action buttons
	_build_buttons()


func _build_title() -> void:
	"""Build dramatic title label"""
	title_label = Label.new()
	modal_vbox.add_child(title_label)  # Parent FIRST
	title_label.layout_mode = 2
	title_label.text = "ENTER THE WASTELAND"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title_label.add_theme_color_override("font_color", COLOR_PRIMARY_ORANGE)


func _build_character_preview() -> void:
	"""Build centered character card preview"""
	# CenterContainer to center the card
	card_container = CenterContainer.new()
	modal_vbox.add_child(card_container)  # Parent FIRST
	card_container.layout_mode = 2
	card_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Instantiate CharacterTypeCard
	character_card = CHARACTER_TYPE_CARD_SCENE.instantiate()
	card_container.add_child(character_card)  # Parent FIRST
	character_card.layout_mode = 2

	# Card will be set up in _load_character_data()
	# Disable card interaction (it's just a preview here)
	character_card.disabled = true
	character_card.focus_mode = Control.FOCUS_NONE


func _build_buttons() -> void:
	"""Build Cancel and SCAVENGE action buttons"""
	button_container = HBoxContainer.new()
	modal_vbox.add_child(button_container)  # Parent FIRST
	button_container.layout_mode = 2
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_theme_constant_override("separation", BUTTON_SPACING)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER

	# Cancel button (secondary style)
	cancel_button = Button.new()
	button_container.add_child(cancel_button)  # Parent FIRST
	cancel_button.layout_mode = 2
	cancel_button.text = "Cancel"
	cancel_button.custom_minimum_size = Vector2(BUTTON_MIN_WIDTH, BUTTON_HEIGHT)
	cancel_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	cancel_button.pressed.connect(_on_cancel_pressed)
	THEME_HELPER.apply_button_style(cancel_button, THEME_HELPER.ButtonStyle.SECONDARY)
	THEME_HELPER.add_button_animation(cancel_button)

	# SCAVENGE button (primary style - prominent)
	scavenge_button = Button.new()
	button_container.add_child(scavenge_button)  # Parent FIRST
	scavenge_button.layout_mode = 2
	scavenge_button.text = "SCAVENGE"
	scavenge_button.custom_minimum_size = Vector2(BUTTON_MIN_WIDTH + 40, BUTTON_HEIGHT)  # Wider for emphasis
	scavenge_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	scavenge_button.pressed.connect(_on_scavenge_pressed)
	THEME_HELPER.apply_button_style(scavenge_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.add_button_animation(scavenge_button)


## ============================================================================
## DATA LOADING
## ============================================================================


func _load_character_data() -> void:
	"""Load selected character data and set up preview card"""
	var active_id = GameState.active_character_id

	if active_id.is_empty():
		GameLogger.error("[EnterWastelandConfirmation] No active character selected")
		_show_no_character_error()
		return

	# Get character data from CharacterService
	_character_data = CharacterService.get_character(active_id)

	if _character_data.is_empty():
		GameLogger.error("[EnterWastelandConfirmation] Character not found: %s" % active_id)
		_show_no_character_error()
		return

	# Set up the card with character data
	if character_card and character_card.has_method("setup_player"):
		character_card.setup_player(_character_data)
		# Force selection glow on for visual emphasis
		if character_card.has_method("set_selected"):
			character_card.set_selected(true)
		GameLogger.info(
			(
				"[EnterWastelandConfirmation] Character loaded: %s"
				% _character_data.get("name", "Unknown")
			)
		)


func _show_no_character_error() -> void:
	"""Show error state when no character is selected"""
	if title_label:
		title_label.text = "NO SURVIVOR SELECTED"
		title_label.add_theme_color_override("font_color", Color.RED)

	if scavenge_button:
		scavenge_button.disabled = true
		scavenge_button.text = "Select a Survivor First"


## ============================================================================
## EVENT HANDLERS
## ============================================================================


func _on_cancel_pressed() -> void:
	"""Handle cancel button press - return to previous screen"""
	GameLogger.info("[EnterWastelandConfirmation] Cancel pressed")
	_play_sound(BUTTON_CLICK_SOUND)

	# Emit signal for parent to handle
	cancel_pressed.emit()

	# Navigate back (default to Hub if no return scene specified)
	var target = (
		_return_scene if not _return_scene.is_empty() else "res://scenes/hub/scrapyard.tscn"
	)
	get_tree().change_scene_to_file(target)


func _on_scavenge_pressed() -> void:
	"""Handle SCAVENGE button press - launch combat"""
	GameLogger.info("[EnterWastelandConfirmation] SCAVENGE pressed - launching combat")
	_play_sound(BUTTON_CLICK_SOUND)

	# Emit signal for parent to handle
	scavenge_pressed.emit()

	# Navigate to combat/wasteland scene
	get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")


## ============================================================================
## PUBLIC API
## ============================================================================


func set_return_scene(scene_path: String) -> void:
	"""Set the scene to return to when Cancel is pressed"""
	_return_scene = scene_path


func get_character_data() -> Dictionary:
	"""Get the currently displayed character data"""
	return _character_data


## ============================================================================
## AUDIO
## ============================================================================


func _play_sound(sound: AudioStream) -> void:
	"""Play UI sound effect"""
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()
