class_name ShopItemCard
extends Button
## ShopItemCard - Displays a single shop item with purchase functionality
##
## Week 18 Phase 6: Hub Shop UI
## Part of the Shop scene - displays item name, rarity, stats, and price.
##
## Usage:
##   var card = SHOP_ITEM_CARD_SCENE.instantiate()
##   parent.add_child(card)
##   card.setup(item_data)
##   card.purchase_requested.connect(_on_purchase_requested)

## Emitted when player requests to purchase this item
signal purchase_requested(item_id: String)

## Item data dictionary (from ShopService)
var _item_data: Dictionary = {}

## Whether this item has been purchased (sold out)
var _is_sold: bool = false

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
	# Connect button press
	pressed.connect(_on_pressed)

	# Apply initial styling
	_apply_panel_style()


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
	style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD

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
	style.bg_color = GameColorPalette.SOOT_BLACK
	style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD

	_panel_bg.add_theme_stylebox_override("panel", style)

	# Sold overlay style
	if _sold_overlay:
		var sold_style = StyleBoxFlat.new()
		sold_style.bg_color = Color(0, 0, 0, 0.7)
		sold_style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
		sold_style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
		sold_style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
		sold_style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD
		_sold_overlay.add_theme_stylebox_override("panel", sold_style)


func _on_pressed() -> void:
	"""Handle card press - request purchase"""
	if _is_sold:
		return

	var item_id = _item_data.get("id", "")
	if not item_id.is_empty():
		purchase_requested.emit(item_id)
		GameLogger.info("[ShopItemCard] Purchase requested", {"item_id": item_id})
