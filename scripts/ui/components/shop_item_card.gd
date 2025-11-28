class_name ShopItemCard
extends Button
## ShopItemCard - Displays a single shop item with purchase functionality
##
## Week 18 Phase 6: Hub Shop UI
## Part of the Shop scene - displays item name, rarity, stats, and price.
##
## Features:
## - Rarity-colored border (matches CharacterTypeCard pattern)
## - Tap animation (iOS-safe, no Tweens)
## - SOLD overlay when purchased
## - Haptic feedback on tap
##
## Usage:
##   var card = SHOP_ITEM_CARD_SCENE.instantiate()
##   parent.add_child(card)
##   card.setup(item_data)
##   card.purchase_requested.connect(_on_purchase_requested)

## Emitted when player requests to purchase this item
signal purchase_requested(item_id: String)

## Card background color
const COLOR_CARD_BG := Color(0.12, 0.12, 0.14, 1.0)

## Tap animation constants (iOS-safe, no Tween - matches CharacterTypeCard)
const TAP_DOWN_DURATION := 0.08  # 80ms - fast response
const TAP_UP_DURATION := 0.12  # 120ms - satisfying release
const TAP_SCALE_MIN := 0.95
const TAP_SCALE_MAX := 1.0

## Item data dictionary (from ShopService)
var _item_data: Dictionary = {}

## Whether this item has been purchased (sold out)
var _is_sold: bool = false

## Tap animation state (iOS-compatible)
var _is_animating_tap: bool = false
var _tap_elapsed: float = 0.0
var _tap_phase: int = 0  # 0 = idle, 1 = pressing down, 2 = releasing up

## Node references
@onready var _panel_bg: Panel = $PanelBg
@onready var _rarity_border: Panel = $RarityBorder
@onready var _content: MarginContainer = $ContentContainer
@onready var _name_label: Label = $ContentContainer/VBoxContainer/NameLabel
@onready var _rarity_label: Label = $ContentContainer/VBoxContainer/RarityLabel
@onready var _stats_label: Label = $ContentContainer/VBoxContainer/StatsLabel
@onready var _price_container: HBoxContainer = $ContentContainer/VBoxContainer/PriceContainer
@onready var _price_label: Label = $ContentContainer/VBoxContainer/PriceContainer/PriceLabel
@onready var _sold_overlay: Panel = $SoldOverlay
@onready var _sold_label: Label = $SoldOverlay/SoldLabel


func _ready() -> void:
	# Connect button signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

	# Apply initial styling
	_apply_panel_style()


func _process(delta: float) -> void:
	_update_tap_animation(delta)


func setup(item_data: Dictionary) -> void:
	"""Configure card with item data from ShopService"""
	_item_data = item_data
	_is_sold = false

	# Wait for nodes if not ready
	if not is_node_ready():
		await ready

	# Update display
	_update_display()


func mark_as_sold() -> void:
	"""Mark this item as sold (purchased)"""
	_is_sold = true
	_update_sold_state()


func get_item_id() -> String:
	"""Get the item ID for this card"""
	return _item_data.get("id", "")


func get_item_data() -> Dictionary:
	"""Get the full item data dictionary"""
	return _item_data


func is_sold() -> bool:
	"""Check if this item has been sold"""
	return _is_sold


func _update_display() -> void:
	"""Update all display elements from item data"""
	if _item_data.is_empty():
		return

	# Item name
	_name_label.text = _item_data.get("name", "Unknown Item")

	# Rarity with color
	var rarity = _item_data.get("rarity", "common")
	_rarity_label.text = rarity.capitalize()
	_rarity_label.add_theme_color_override("font_color", GameColorPalette.get_rarity_color(rarity))

	# Update rarity border color
	_update_rarity_border(rarity)

	# Stats summary
	var stats_text = _format_stats(_item_data.get("stats", {}))
	_stats_label.text = stats_text if not stats_text.is_empty() else "No bonuses"

	# Price
	var price = _item_data.get("base_price", 0)
	_price_label.text = "%d" % price

	# Sold state
	_update_sold_state()


func _format_stats(stats: Dictionary) -> String:
	"""Format stats dictionary into readable string"""
	if stats.is_empty():
		return ""

	var parts: Array[String] = []
	for stat_name in stats:
		var value = stats[stat_name]
		var formatted_name = stat_name.replace("_", " ").capitalize()

		# Format value with + for positive
		if value is int or value is float:
			if value > 0:
				parts.append("+%d %s" % [value, formatted_name])
			elif value < 0:
				parts.append("%d %s" % [value, formatted_name])
		else:
			parts.append("%s: %s" % [formatted_name, str(value)])

	return ", ".join(parts)


func _update_rarity_border(rarity: String) -> void:
	"""Update the border panel color based on rarity"""
	if not _rarity_border:
		return

	var border_color = GameColorPalette.get_rarity_color(rarity)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)  # Transparent fill
	style.border_color = border_color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	_rarity_border.add_theme_stylebox_override("panel", style)


func _update_sold_state() -> void:
	"""Update visual state based on sold status"""
	if not _sold_overlay:
		return

	_sold_overlay.visible = _is_sold
	disabled = _is_sold

	# Dim the card when sold
	if _is_sold:
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		modulate = Color(1, 1, 1, 1)


func _apply_panel_style() -> void:
	"""Apply wasteland-themed panel styling"""
	if not _panel_bg:
		return

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_CARD_BG
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	_panel_bg.add_theme_stylebox_override("panel", style)

	# Sold overlay style
	if _sold_overlay:
		var sold_style = StyleBoxFlat.new()
		sold_style.bg_color = Color(0, 0, 0, 0.75)
		sold_style.corner_radius_top_left = 10
		sold_style.corner_radius_top_right = 10
		sold_style.corner_radius_bottom_left = 10
		sold_style.corner_radius_bottom_right = 10
		_sold_overlay.add_theme_stylebox_override("panel", sold_style)


## ============================================================================
## TAP ANIMATION (iOS-safe _process-based, matches CharacterTypeCard)
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
## INPUT HANDLING
## ============================================================================


func _on_button_down() -> void:
	"""Handle button press start"""
	if _is_sold:
		return
	_animate_tap()


func _on_button_up() -> void:
	"""Handle button release - animation continues in _process"""
	return


func _on_pressed() -> void:
	"""Handle card press - request purchase"""
	if _is_sold:
		return

	HapticManager.light()

	var item_id = _item_data.get("id", "")
	if not item_id.is_empty():
		purchase_requested.emit(item_id)
		GameLogger.debug("[ShopItemCard] Purchase requested", {"item_id": item_id})
