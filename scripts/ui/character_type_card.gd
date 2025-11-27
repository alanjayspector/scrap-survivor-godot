extends Button
## CharacterTypeCard - Unified card component for character type selection and player display
##
## Week 17 Phase 1: Premium card component with iOS-safe animations
##
## Two Modes:
## - setup_type(type_id): For Character Creation - shows silhouette, type name, stat preview
## - setup_player(character_data): For Barracks - shows portrait color, character name, level
##
## Features:
## - 170×220pt card size (fits 2-column grid)
## - Custom tap animation (0.95 scale, 80ms down / 120ms return with ease-out)
## - Animated selection glow (alpha 0.6↔1.0 over 800ms, Timer-based for iOS)
## - Lock overlay for tier-restricted types
## - Silhouette portraits for types, ColorRect for players
##
## iOS Compatibility:
## - NO Tweens (unreliable on Metal renderer per ios-tween-fixes-qa-guide.md)
## - Timer-based glow animation
## - _process()-based tap animation
##
## References:
## - docs/migration/week17-plan.md (Phase 1 spec)
## - art-docs/Scrapyard_Scene_Art_Bible.md (colors)
## - ios-tween-fixes-qa-guide.md (animation patterns)

signal card_pressed(identifier: String)
signal card_long_pressed(identifier: String)

## Card mode enum
enum CardMode { TYPE, PLAYER }

## Type silhouette texture paths
const SILHOUETTE_PATHS := {
	"scavenger": "res://assets/ui/portraits/silhouette_scavenger.png",
	"tank": "res://assets/ui/portraits/silhouette_tank.png",
	"commando": "res://assets/ui/portraits/silhouette_commando.png",
	"mutant": "res://assets/ui/portraits/silhouette_mutant.png",
}

## Type colors (from Art Bible - Week 17 plan)
const TYPE_COLORS := {
	"scavenger": Color("#999999"),  # Gray
	"tank": Color("#4D7A4D"),  # Olive
	"commando": Color("#CC3333"),  # Red
	"mutant": Color("#8033B3"),  # Purple
}

## Selection glow color (Primary Orange from Art Bible)
const COLOR_GLOW := Color("#FF6600")
const COLOR_GLOW_SELECTED := Color("#FF6600")

## Card background colors
const COLOR_CARD_BG := Color(0.15, 0.15, 0.15, 1.0)
const COLOR_CARD_BORDER := Color("#5C5C5C")
const COLOR_CARD_BORDER_SELECTED := Color("#FF6600")

## Lock overlay
const COLOR_LOCK_OVERLAY := Color(0.0, 0.0, 0.0, 0.5)

## Portrait background (lighter than card for contrast)
const COLOR_PORTRAIT_BG := Color(0.25, 0.25, 0.25, 1.0)

## Tap animation constants (iOS-safe, no Tween)
const TAP_DOWN_DURATION := 0.08  # 80ms - fast response
const TAP_UP_DURATION := 0.12  # 120ms - satisfying release
const TAP_SCALE_MIN := 0.95
const TAP_SCALE_MAX := 1.0

## Glow animation constants (iOS-safe, Timer-based)
const GLOW_MIN_ALPHA := 0.6
const GLOW_MAX_ALPHA := 1.0
const GLOW_CYCLE_TIME := 0.8  # 800ms full cycle
const GLOW_UPDATE_INTERVAL := 0.016  # ~60fps

## Long press detection
const LONG_PRESS_DURATION := 0.5  # 500ms for long press

## Node references (set after _ready or via @onready)
@onready var glow_panel: Panel = $GlowPanel
@onready var panel_bg: Panel = $PanelBg
@onready var portrait_container: Control = $ContentContainer/VBoxContainer/PortraitContainer
@onready
var portrait_background: Panel = $ContentContainer/VBoxContainer/PortraitContainer/PortraitBackground
@onready
var portrait_rect: TextureRect = $ContentContainer/VBoxContainer/PortraitContainer/PortraitRect
@onready
var portrait_color_rect: ColorRect = $ContentContainer/VBoxContainer/PortraitContainer/PortraitColorRect
@onready var name_label: Label = $ContentContainer/VBoxContainer/NameLabel
@onready var sub_label: Label = $ContentContainer/VBoxContainer/SubLabel
@onready var lock_overlay: Panel = $LockOverlay
@onready var lock_icon_label: Label = $LockOverlay/LockIconLabel
@onready var badge_container: HBoxContainer = $ContentContainer/VBoxContainer/BadgeContainer
@onready var selection_badge: Panel = $ContentContainer/VBoxContainer/BadgeContainer/SelectionBadge

## State
var _mode: CardMode = CardMode.TYPE
var _identifier: String = ""  # type_id or character_id depending on mode
var _is_selected: bool = false
var _is_locked: bool = false
var _required_tier: int = 0

## Tap animation state (iOS-compatible)
var _is_animating_tap: bool = false
var _tap_elapsed: float = 0.0
var _tap_phase: int = 0  # 0 = idle, 1 = pressing down, 2 = releasing up

## Glow animation state (iOS-compatible)
var _glow_timer: Timer = null
var _glow_direction: float = 1.0  # 1.0 = fading in, -1.0 = fading out

## Long press detection
var _press_timer: Timer = null
var _is_pressing: bool = false


func _ready() -> void:
	# Connect button signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

	# Initialize glow as hidden
	if glow_panel:
		glow_panel.visible = false

	# Initialize lock overlay as hidden
	if lock_overlay:
		lock_overlay.visible = false

	# Initialize badge as hidden
	if selection_badge:
		selection_badge.visible = false

	# Hide portrait rects until setup
	if portrait_rect:
		portrait_rect.visible = false
	if portrait_color_rect:
		portrait_color_rect.visible = false

	# Apply default border style
	_update_border_style()

	# Style portrait background (lighter than card for contrast)
	_style_portrait_background()

	# Setup long press timer
	_press_timer = Timer.new()
	_press_timer.one_shot = true
	_press_timer.wait_time = LONG_PRESS_DURATION
	_press_timer.timeout.connect(_on_long_press_timeout)
	add_child(_press_timer)

	GameLogger.debug("[CharacterTypeCard] Ready", {"node": name})


func _process(delta: float) -> void:
	_update_tap_animation(delta)


## ============================================================================
## PUBLIC API - Setup Methods
## ============================================================================


func setup_type(type_id: String) -> void:
	"""Setup card for character type selection (Character Creation screen)"""
	_mode = CardMode.TYPE

	# Get type definition from CharacterService
	var type_def = CharacterService.CHARACTER_TYPES.get(type_id, {})
	if type_def.is_empty():
		GameLogger.warning("[CharacterTypeCard] Unknown type", {"type_id": type_id})
		_identifier = ""  # Clear identifier for unknown types
		return

	_identifier = type_id  # Only set after validation passes

	var display_name = type_def.get("display_name", type_id.capitalize())
	var description = type_def.get("description", "")
	var tier_required = type_def.get("tier_required", CharacterService.UserTier.FREE)
	var stat_mods = type_def.get("stat_modifiers", {})

	# Set portrait to silhouette texture
	_set_silhouette_portrait(type_id)

	# Set labels
	if name_label:
		name_label.text = display_name

	# Build stat preview string (e.g., "+20 HP, +3 Armor")
	var stat_preview = _build_stat_preview(stat_mods)
	if sub_label:
		sub_label.text = stat_preview if not stat_preview.is_empty() else description.substr(0, 30)

	# Check if locked based on tier
	var current_tier = CharacterService.get_tier()
	var is_locked = current_tier < tier_required
	set_locked(is_locked, tier_required)

	# Apply type color to glow
	var type_color = TYPE_COLORS.get(type_id, COLOR_GLOW)
	_set_glow_color(type_color)

	GameLogger.debug(
		"[CharacterTypeCard] Setup type complete",
		{"type_id": type_id, "display_name": display_name, "is_locked": is_locked}
	)


func setup_player(character_data: Dictionary) -> void:
	"""Setup card for player character display (Barracks screen)"""
	_mode = CardMode.PLAYER
	_identifier = character_data.get("id", "")

	var char_name = character_data.get("name", "Unknown")
	var char_type = character_data.get("character_type", "scavenger")
	var char_level = character_data.get("level", 1)
	var highest_wave = character_data.get("highest_wave", 0)

	# Get type definition for color
	var type_def = CharacterService.CHARACTER_TYPES.get(char_type, {})
	var type_display = type_def.get("display_name", char_type.capitalize())
	var type_color = type_def.get("color", Color.GRAY)

	# Set portrait to silhouette (same as type cards for visual consistency)
	_set_silhouette_portrait(char_type)

	# Set labels
	if name_label:
		name_label.text = char_name

	if sub_label:
		sub_label.text = "%s • Lv.%d" % [type_display, char_level]

	# Check if this character is currently selected
	var active_id = GameState.active_character_id
	var is_selected = _identifier == active_id and not active_id.is_empty()
	set_selected(is_selected)

	# Players are never locked
	set_locked(false, 0)

	# Apply type color to glow
	_set_glow_color(type_color)

	GameLogger.debug(
		"[CharacterTypeCard] Setup player complete",
		{"id": _identifier, "name": char_name, "type": char_type, "is_selected": is_selected}
	)


## ============================================================================
## PUBLIC API - State Methods
## ============================================================================


func set_selected(selected: bool) -> void:
	"""Set selection state with animated glow"""
	_is_selected = selected

	# Update border style
	_update_border_style()

	# Update selection badge
	if selection_badge:
		selection_badge.visible = selected
		if selected:
			_style_selection_badge()

	# Start/stop glow animation
	if selected:
		_start_glow_animation()
	else:
		_stop_glow_animation()

	GameLogger.debug(
		"[CharacterTypeCard] Selection changed", {"identifier": _identifier, "selected": selected}
	)


func set_locked(locked: bool, required_tier: int = 0) -> void:
	"""Set locked state with overlay"""
	_is_locked = locked
	_required_tier = required_tier

	if lock_overlay:
		lock_overlay.visible = locked

	# Disable button interaction if locked
	disabled = locked

	# Update lock icon text based on tier
	if lock_icon_label and locked:
		match required_tier:
			CharacterService.UserTier.PREMIUM:
				lock_icon_label.text = "🔒 Premium"
			CharacterService.UserTier.SUBSCRIPTION:
				lock_icon_label.text = "🔒 Subscriber"
			_:
				lock_icon_label.text = "🔒"

	GameLogger.debug(
		"[CharacterTypeCard] Lock state changed",
		{"identifier": _identifier, "locked": locked, "required_tier": required_tier}
	)


func get_identifier() -> String:
	"""Get the card's identifier (type_id or character_id)"""
	return _identifier


func get_mode() -> CardMode:
	"""Get the card's current mode"""
	return _mode


func is_selected() -> bool:
	"""Check if card is currently selected"""
	return _is_selected


func is_locked() -> bool:
	"""Check if card is currently locked"""
	return _is_locked


## ============================================================================
## PRIVATE - Portrait Setup
## ============================================================================


func _set_silhouette_portrait(type_id: String) -> void:
	"""Load and display silhouette texture for type"""
	var texture_path = SILHOUETTE_PATHS.get(type_id, "")

	if texture_path.is_empty():
		GameLogger.warning("[CharacterTypeCard] No silhouette for type", {"type_id": type_id})
		_set_color_portrait(TYPE_COLORS.get(type_id, Color.GRAY))
		return

	var texture = load(texture_path) as Texture2D
	if texture == null:
		GameLogger.warning("[CharacterTypeCard] Failed to load silhouette", {"path": texture_path})
		_set_color_portrait(TYPE_COLORS.get(type_id, Color.GRAY))
		return

	# Show TextureRect, hide ColorRect
	if portrait_rect:
		portrait_rect.texture = texture
		portrait_rect.visible = true
	if portrait_color_rect:
		portrait_color_rect.visible = false

	GameLogger.debug(
		"[CharacterTypeCard] Silhouette loaded", {"type_id": type_id, "path": texture_path}
	)


func _set_color_portrait(color: Color) -> void:
	"""Display colored rect for player portrait (Phase 1 fallback)"""
	# Show ColorRect, hide TextureRect
	if portrait_color_rect:
		portrait_color_rect.color = color
		portrait_color_rect.visible = true
	if portrait_rect:
		portrait_rect.visible = false

	GameLogger.debug("[CharacterTypeCard] Color portrait set", {"color": color})


## ============================================================================
## PRIVATE - Stat Preview Builder
## ============================================================================


func _build_stat_preview(stat_mods: Dictionary) -> String:
	"""Build human-readable stat preview string from modifiers"""
	var parts: Array[String] = []

	# Priority order for display
	var stat_display = {
		"max_hp": "HP",
		"armor": "Armor",
		"damage": "DMG",
		"ranged_damage": "Ranged",
		"melee_damage": "Melee",
		"attack_speed": "AtkSpd",
		"speed": "Speed",
		"crit_chance": "Crit",
		"dodge": "Dodge",
		"luck": "Luck",
		"scavenging": "Scav",
		"pickup_range": "Range",
		"resonance": "Res",
	}

	for stat_key in stat_display.keys():
		if stat_mods.has(stat_key):
			var value = stat_mods[stat_key]
			var display_name = stat_display[stat_key]
			var sign = "+" if value >= 0 else ""
			parts.append("%s%s %s" % [sign, value, display_name])

	# Limit to 2 stats for card display
	if parts.size() > 2:
		parts = parts.slice(0, 2)

	return ", ".join(parts)


## ============================================================================
## PRIVATE - Visual Styling
## ============================================================================


func _update_border_style() -> void:
	"""Update card border based on selection state"""
	if not panel_bg:
		return

	var border_color = COLOR_CARD_BORDER_SELECTED if _is_selected else COLOR_CARD_BORDER
	var border_width = 3 if _is_selected else 2

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_CARD_BG
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(8)
	panel_bg.add_theme_stylebox_override("panel", style)


func _style_portrait_background() -> void:
	"""Style the portrait background panel (lighter than card for contrast)"""
	if not portrait_background:
		return

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PORTRAIT_BG
	style.set_corner_radius_all(8)
	portrait_background.add_theme_stylebox_override("panel", style)


func _style_selection_badge() -> void:
	"""Style the selection badge as orange circle with checkmark"""
	if not selection_badge:
		return

	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = COLOR_GLOW_SELECTED
	badge_style.set_corner_radius_all(12)  # 24pt badge / 2 = 12 radius for circle
	selection_badge.add_theme_stylebox_override("panel", badge_style)


func _set_glow_color(color: Color) -> void:
	"""Set the glow panel color"""
	if not glow_panel:
		return

	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = color
	glow_style.set_corner_radius_all(12)
	glow_panel.add_theme_stylebox_override("panel", glow_style)


## ============================================================================
## PRIVATE - Glow Animation (iOS-safe Timer-based)
## ============================================================================


func _start_glow_animation() -> void:
	"""Start the breathing glow animation"""
	if not glow_panel:
		return

	# Create timer if needed
	if not _glow_timer:
		_glow_timer = Timer.new()
		_glow_timer.wait_time = GLOW_UPDATE_INTERVAL
		_glow_timer.timeout.connect(_update_glow)
		add_child(_glow_timer)

	# Reset state
	_glow_direction = 1.0
	glow_panel.modulate.a = GLOW_MIN_ALPHA
	glow_panel.visible = true

	_glow_timer.start()

	GameLogger.debug("[CharacterTypeCard] Glow animation started", {"identifier": _identifier})


func _stop_glow_animation() -> void:
	"""Stop the breathing glow animation"""
	if _glow_timer:
		_glow_timer.stop()

	if glow_panel:
		glow_panel.visible = false

	GameLogger.debug("[CharacterTypeCard] Glow animation stopped", {"identifier": _identifier})


func _update_glow() -> void:
	"""Update glow alpha for breathing effect (called by Timer)"""
	if not glow_panel or not glow_panel.visible:
		return

	var current_alpha = glow_panel.modulate.a
	var half_cycle = GLOW_CYCLE_TIME / 2.0
	var step = (GLOW_MAX_ALPHA - GLOW_MIN_ALPHA) / (half_cycle / GLOW_UPDATE_INTERVAL)

	current_alpha += step * _glow_direction

	# Reverse direction at bounds
	if current_alpha >= GLOW_MAX_ALPHA:
		current_alpha = GLOW_MAX_ALPHA
		_glow_direction = -1.0
	elif current_alpha <= GLOW_MIN_ALPHA:
		current_alpha = GLOW_MIN_ALPHA
		_glow_direction = 1.0

	glow_panel.modulate.a = current_alpha


## ============================================================================
## PRIVATE - Tap Animation (iOS-safe _process-based)
## ============================================================================


func _update_tap_animation(delta: float) -> void:
	"""Update tap scale animation (called every frame via _process)"""
	if not _is_animating_tap:
		return

	_tap_elapsed += delta

	if _tap_phase == 1:  # Pressing down (linear for immediate response)
		var t = clampf(_tap_elapsed / TAP_DOWN_DURATION, 0.0, 1.0)
		var current_scale = lerpf(TAP_SCALE_MAX, TAP_SCALE_MIN, t)
		scale = Vector2(current_scale, current_scale)

		if t >= 1.0:
			_tap_phase = 2
			_tap_elapsed = 0.0

	elif _tap_phase == 2:  # Releasing up (ease-out for satisfying release)
		var t = clampf(_tap_elapsed / TAP_UP_DURATION, 0.0, 1.0)
		# Quadratic ease-out: fast start, slow finish
		var eased_t = 1.0 - pow(1.0 - t, 2.0)
		var current_scale = lerpf(TAP_SCALE_MIN, TAP_SCALE_MAX, eased_t)
		scale = Vector2(current_scale, current_scale)

		if t >= 1.0:
			_is_animating_tap = false
			_tap_phase = 0
			scale = Vector2.ONE


func _animate_tap() -> void:
	"""Start the tap animation sequence"""
	_is_animating_tap = true
	_tap_phase = 1
	_tap_elapsed = 0.0


## ============================================================================
## PRIVATE - Input Handling
## ============================================================================


func _on_button_down() -> void:
	"""Handle button press start"""
	if _is_locked:
		return

	_is_pressing = true
	_animate_tap()

	# Start long press timer
	if _press_timer:
		_press_timer.start()


func _on_button_up() -> void:
	"""Handle button release"""
	_is_pressing = false

	# Cancel long press timer
	if _press_timer:
		_press_timer.stop()


func _on_pressed() -> void:
	"""Handle button press complete (short tap)"""
	if _is_locked:
		return

	HapticManager.light()
	card_pressed.emit(_identifier)

	GameLogger.debug(
		"[CharacterTypeCard] Card pressed",
		{"identifier": _identifier, "mode": "TYPE" if _mode == CardMode.TYPE else "PLAYER"}
	)


func _on_long_press_timeout() -> void:
	"""Handle long press detected"""
	if not _is_pressing or _is_locked:
		return

	HapticManager.medium()
	card_long_pressed.emit(_identifier)

	GameLogger.debug(
		"[CharacterTypeCard] Card long pressed",
		{"identifier": _identifier, "mode": "TYPE" if _mode == CardMode.TYPE else "PLAYER"}
	)


## ============================================================================
## CLEANUP
## ============================================================================


func _exit_tree() -> void:
	"""Clean up timers when removed from scene"""
	if _glow_timer:
		_glow_timer.stop()
		_glow_timer.queue_free()
		_glow_timer = null

	if _press_timer:
		_press_timer.stop()
		_press_timer.queue_free()
		_press_timer = null

	GameLogger.debug("[CharacterTypeCard] Cleanup complete", {"identifier": _identifier})
