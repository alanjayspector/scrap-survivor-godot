extends Control
## Character Selection UI Controller
## Week 8 Phase 3: Character selection screen with type previews and tier restrictions
## Week 14 Phase 1.5: UI audio feedback (button clicks, character selection, errors)
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

## Audio (Week 14 Phase 1.5 - iOS-compatible preload pattern)
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")
const CHARACTER_SELECT_SOUND: AudioStream = preload("res://assets/audio/ui/character_select.ogg")
const ERROR_SOUND: AudioStream = preload("res://assets/audio/ui/ui_error.ogg")

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
var current_detail_panel: Control = null  # Track active detail panel for dismissal


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
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
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

		# Visual feedback disabled - Tweens don't work on iOS Metal renderer


func _show_character_detail_panel(character_type: String) -> void:
	"""Show detail panel with full character information and Try/Unlock buttons"""
	print("[CharacterSelection] Showing detail panel for: ", character_type)

	# Close existing panel if any
	if current_detail_panel:
		_dismiss_detail_panel()

	var type_def = CharacterService.CHARACTER_TYPES[character_type]
	var user_tier = CharacterService.get_tier()
	var is_locked = type_def.tier_required > user_tier

	# Create full-screen container for backdrop + panel
	var panel_root = Control.new()
	panel_root.name = "DetailPanelRoot"
	panel_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_root.mouse_filter = Control.MOUSE_FILTER_STOP  # Capture all input
	add_child(panel_root)
	current_detail_panel = panel_root

	# Backdrop (semi-transparent black, tappable to dismiss)
	var backdrop = Panel.new()
	backdrop.name = "Backdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop_style = StyleBoxFlat.new()
	backdrop_style.bg_color = Color(0, 0, 0, 0)  # Start transparent for fade-in
	backdrop.add_theme_stylebox_override("panel", backdrop_style)
	backdrop.gui_input.connect(_on_backdrop_tapped)
	panel_root.add_child(backdrop)

	# Content panel (bottom 70% of screen, rounded corners)
	var content_panel = PanelContainer.new()
	content_panel.name = "ContentPanel"
	# Position at bottom, 70% height
	content_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	content_panel.anchor_top = 0.3
	content_panel.anchor_bottom = 1.0
	content_panel.offset_top = 20  # Start below screen for slide-up animation

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.12, 0.98)  # Almost opaque dark background
	panel_style.corner_radius_top_left = 24
	panel_style.corner_radius_top_right = 24
	panel_style.border_width_top = 3
	panel_style.border_color = type_def.color  # Character color border
	panel_style.shadow_size = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 16
	panel_style.content_margin_bottom = 24
	content_panel.add_theme_stylebox_override("panel", panel_style)
	panel_root.add_child(content_panel)

	# Scroll container for content (in case of overflow)
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_panel.add_child(scroll)

	# Main content VBox
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(content_vbox)

	# === HEADER SECTION ===
	_build_detail_header(content_vbox, type_def)

	# === DESCRIPTION ===
	_build_detail_description(content_vbox, type_def)

	# === STATS SECTION ===
	_build_detail_stats(content_vbox, type_def)

	# === AURA SECTION ===
	_build_detail_aura(content_vbox, type_def)

	# === TIER BADGE (if locked) ===
	if is_locked:
		_build_detail_tier_badge(content_vbox, type_def.tier_required)

	# === ACTION BUTTONS ===
	_build_detail_buttons(content_vbox, character_type, is_locked, type_def.tier_required)

	# === ANIMATIONS ===
	_animate_detail_panel_entrance(backdrop_style, content_panel)


func _build_detail_header(parent: VBoxContainer, type_def: Dictionary) -> void:
	"""Build header section with character name and close button"""
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 60)

	var header_style = StyleBoxFlat.new()
	header_style.bg_color = type_def.color.darkened(0.2)
	header_style.corner_radius_top_left = 16
	header_style.corner_radius_top_right = 16
	header.add_theme_stylebox_override("panel", header_style)
	parent.add_child(header)

	# Header content (character name + close button)
	var header_hbox = HBoxContainer.new()
	header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(header_hbox)

	# Character name
	var name_label = Label.new()
	name_label.text = type_def.display_name.to_upper()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 3)
	header_hbox.add_child(name_label)

	# Close button (X)
	var close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(48, 48)  # iOS HIG touch target
	close_button.add_theme_font_size_override("font_size", 32)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	close_button.pressed.connect(_dismiss_detail_panel)
	header_hbox.add_child(close_button)


func _build_detail_description(parent: VBoxContainer, type_def: Dictionary) -> void:
	"""Build description section with compelling copy"""
	var desc_label = Label.new()
	desc_label.text = type_def.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	parent.add_child(desc_label)


func _build_detail_stats(parent: VBoxContainer, type_def: Dictionary) -> void:
	"""Build stats section with large, color-coded stat display"""
	var stats_header = Label.new()
	stats_header.text = "STATS"
	stats_header.add_theme_font_size_override("font_size", 20)
	stats_header.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	parent.add_child(stats_header)

	# Stats grid
	var stats_vbox = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 8)
	parent.add_child(stats_vbox)

	for stat_name in type_def.stat_modifiers.keys():
		var value = type_def.stat_modifiers[stat_name]
		var stat_row = HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 12)

		# Stat icon (larger for detail view)
		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(12, 12)
		icon.color = _get_stat_color(stat_name)
		stat_row.add_child(icon)

		# Stat label (larger, more readable)
		var stat_label = Label.new()
		var sign = "+" if value >= 0 else ""
		stat_label.text = "%s%s %s" % [sign, value, stat_name.capitalize()]
		stat_label.add_theme_font_size_override("font_size", 18)
		stat_label.add_theme_color_override("font_color", Color.WHITE)
		stat_row.add_child(stat_label)

		stats_vbox.add_child(stat_row)


func _build_detail_aura(parent: VBoxContainer, type_def: Dictionary) -> void:
	"""Build aura section"""
	var aura_header = Label.new()
	aura_header.text = "AURA"
	aura_header.add_theme_font_size_override("font_size", 20)
	aura_header.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	parent.add_child(aura_header)

	var aura_label = Label.new()
	if type_def.aura_type:
		aura_label.text = (
			"%s\n%s" % [type_def.aura_type.capitalize(), "Provides defensive benefits"]
		)  # Could be customized per aura type
	else:
		aura_label.text = "None\nNo defensive aura (trade-off for raw stats)"
	aura_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	aura_label.add_theme_font_size_override("font_size", 16)
	aura_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	parent.add_child(aura_label)


func _build_detail_tier_badge(parent: VBoxContainer, required_tier: int) -> void:
	"""Build prominent tier badge for locked characters"""
	var tier_panel = PanelContainer.new()
	tier_panel.custom_minimum_size = Vector2(0, 60)

	var tier_color = _get_tier_color(required_tier)
	var tier_style = StyleBoxFlat.new()
	tier_style.bg_color = tier_color
	tier_style.corner_radius_top_left = 8
	tier_style.corner_radius_top_right = 8
	tier_style.corner_radius_bottom_left = 8
	tier_style.corner_radius_bottom_right = 8
	tier_style.border_width_left = 3
	tier_style.border_width_top = 3
	tier_style.border_width_right = 3
	tier_style.border_width_bottom = 3
	tier_style.border_color = tier_color.lightened(0.3)
	tier_panel.add_theme_stylebox_override("panel", tier_style)
	parent.add_child(tier_panel)

	var tier_label = Label.new()
	tier_label.text = _get_tier_name(required_tier)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tier_label.add_theme_font_size_override("font_size", 24)
	tier_label.add_theme_color_override("font_color", Color.WHITE)
	tier_label.add_theme_color_override("font_outline_color", Color.BLACK)
	tier_label.add_theme_constant_override("outline_size", 2)
	tier_panel.add_child(tier_label)


func _build_detail_buttons(
	parent: VBoxContainer, character_type: String, is_locked: bool, required_tier: int
) -> void:
	"""Build action buttons (Try/Unlock for locked, Select for unlocked)"""
	if is_locked:
		# Button container for Try + Unlock
		var button_hbox = HBoxContainer.new()
		button_hbox.add_theme_constant_override("separation", 16)
		button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		parent.add_child(button_hbox)

		# Try button (grey)
		var try_button = Button.new()
		try_button.text = "TRY"
		try_button.custom_minimum_size = Vector2(140, 56)  # iOS HIG touch target
		try_button.add_theme_font_size_override("font_size", 20)
		var try_style = StyleBoxFlat.new()
		try_style.bg_color = Color(0.4, 0.4, 0.4)
		try_style.corner_radius_top_left = 8
		try_style.corner_radius_top_right = 8
		try_style.corner_radius_bottom_left = 8
		try_style.corner_radius_bottom_right = 8
		try_button.add_theme_stylebox_override("normal", try_style)
		try_button.pressed.connect(_on_detail_try_pressed.bind(character_type))
		button_hbox.add_child(try_button)

		# Unlock button (tier colored)
		var unlock_button = Button.new()
		unlock_button.text = "UNLOCK"
		unlock_button.custom_minimum_size = Vector2(140, 56)
		unlock_button.add_theme_font_size_override("font_size", 20)
		var unlock_style = StyleBoxFlat.new()
		unlock_style.bg_color = _get_tier_color(required_tier)
		unlock_style.corner_radius_top_left = 8
		unlock_style.corner_radius_top_right = 8
		unlock_style.corner_radius_bottom_left = 8
		unlock_style.corner_radius_bottom_right = 8
		unlock_button.add_theme_stylebox_override("normal", unlock_style)
		unlock_button.pressed.connect(_on_detail_unlock_pressed.bind(required_tier))
		button_hbox.add_child(unlock_button)
	else:
		# Select button (green, prominent)
		var select_button = Button.new()
		select_button.text = "SELECT"
		select_button.custom_minimum_size = Vector2(280, 56)
		select_button.add_theme_font_size_override("font_size", 22)
		var select_style = StyleBoxFlat.new()
		select_style.bg_color = Color(0.1, 0.7, 0.3)  # Green
		select_style.corner_radius_top_left = 8
		select_style.corner_radius_top_right = 8
		select_style.corner_radius_bottom_left = 8
		select_style.corner_radius_bottom_right = 8
		select_button.add_theme_stylebox_override("normal", select_style)
		select_button.pressed.connect(_on_detail_select_pressed.bind(character_type))
		parent.add_child(select_button)


func _animate_detail_panel_entrance(
	backdrop_style: StyleBoxFlat, content_panel: PanelContainer
) -> void:
	"""Animate detail panel entrance (disabled for iOS compatibility)"""
	# NOTE: Entrance animation disabled - Tweens don't work on iOS Metal renderer
	# Set final state immediately
	print("[CharacterSelection] Panel entrance: iOS-compatible immediate display (no animation)")
	backdrop_style.bg_color = Color(0, 0, 0, 0.7)
	content_panel.offset_top = 0


func _dismiss_detail_panel() -> void:
	"""Dismiss the detail panel with immediate cleanup (iOS-compatible)"""
	if not current_detail_panel:
		return

	var panel = current_detail_panel

	# Immediate cleanup (iOS-compatible - Tweens don't work on iOS Metal renderer)
	print("[CharacterSelection] Dismissing detail panel (iOS-compatible immediate cleanup)")
	print("[CharacterSelection]   Panel instance ID: ", panel.get_instance_id())
	if panel:
		panel.queue_free()
		print("[CharacterSelection]   Panel queued for deletion")
	current_detail_panel = null
	print("[CharacterSelection]   current_detail_panel cleared")


func _on_backdrop_tapped(event: InputEvent) -> void:
	"""Handle backdrop tap to dismiss detail panel"""
	if event is InputEventScreenTouch and event.pressed:
		_dismiss_detail_panel()


func _on_detail_try_pressed(character_type: String) -> void:
	"""Handle Try button press from detail panel"""
	# Play button click sound (Week 14 Phase 1.5)
	_play_ui_sound(BUTTON_CLICK_SOUND, "button_click")

	_dismiss_detail_panel()
	_on_free_trial_requested(character_type)


func _on_detail_unlock_pressed(required_tier: int) -> void:
	"""Handle Unlock button press from detail panel"""
	# Play button click sound (Week 14 Phase 1.5)
	_play_ui_sound(BUTTON_CLICK_SOUND, "button_click")

	_dismiss_detail_panel()
	_on_unlock_requested(required_tier)


func _on_detail_select_pressed(character_type: String) -> void:
	"""Handle Select button press from detail panel"""
	# Play character select sound (Week 14 Phase 1.5)
	_play_ui_sound(CHARACTER_SELECT_SOUND, "character_select")

	_dismiss_detail_panel()
	_on_character_card_selected(character_type)


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

	# Tap feedback animation disabled - Tweens don't work on iOS Metal renderer

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
		# Play error sound (Week 14 Phase 1.5)
		_play_ui_sound(ERROR_SOUND, "error")

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
		# Play error sound (Week 14 Phase 1.5)
		_play_ui_sound(ERROR_SOUND, "error")

		GameLogger.warning("Cannot create character - slot limit reached")
		_show_slot_limit_message()
		return

	# Play character select sound (Week 14 Phase 1.5)
	_play_ui_sound(CHARACTER_SELECT_SOUND, "character_select")

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
	# Play button click sound (Week 14 Phase 1.5)
	_play_ui_sound(BUTTON_CLICK_SOUND, "button_click")

	# Week 15 Phase 1: Navigate back to Hub (main scene)
	# Old behavior was queue_free() which left a grey screen
	get_tree().change_scene_to_file("res://scenes/hub/scrapyard.tscn")


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


func _play_ui_sound(sound: AudioStream, sound_name: String) -> void:
	"""Play UI sound with diagnostic logging (Week 14 Phase 1.5)

	Args:
		sound: Preloaded AudioStream resource
		sound_name: Sound name for logging ("button_click", "character_select", "error")

	iOS-compatible pattern: Uses preload() and programmatic AudioStreamPlayer
	"""
	if not sound:
		print("[CharacterSelection:Audio] ERROR: No sound provided for ", sound_name)
		return

	# Create AudioStreamPlayer for non-positional audio
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound
	audio_player.volume_db = -10.0 if sound_name == "button_click" else -5.0

	# Auto-cleanup after playback
	audio_player.finished.connect(audio_player.queue_free)

	# Add to scene tree
	add_child(audio_player)
	audio_player.play()

	# Diagnostic logging
	print("[CharacterSelection:Audio] Playing ", sound_name, " sound")
