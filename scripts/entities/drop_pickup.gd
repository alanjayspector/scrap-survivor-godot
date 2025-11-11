class_name DropPickup
extends Area2D
## Drop pickup entity for Scrap Survivor
##
## Handles collectible currency drops that spawn from enemy deaths.
## Player walks over drops to collect them.

## Emitted when drop is collected by player
signal collected(currency_type: String, amount: int)

## Drop properties
var currency_type: String = "scrap"  # scrap, components, nanites
var amount: int = 1
var magnet_range: float = 80.0  # Pickup detection range

## Visual reference
var visual_node: ColorRect = null

## Currency colors (Brotato-inspired visual clarity)
const CURRENCY_COLORS = {
	"scrap": Color(0.6, 0.4, 0.2, 1),  # Brown
	"components": Color(0.2, 0.5, 0.9, 1),  # Blue
	"nanites": Color(0.7, 0.3, 0.8, 1)  # Purple
}


func _ready() -> void:
	# Set up collision
	collision_layer = 8  # Layer 4 (2^3 = 8)
	collision_mask = 1  # Detect player on layer 1

	# Connect signals for player detection
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Get visual node reference
	visual_node = get_node_or_null("Visual")

	# Update visual based on currency type
	update_visual()


func setup(type: String, amt: int) -> void:
	"""Initialize drop with currency type and amount"""
	currency_type = type
	amount = amt
	update_visual()


func update_visual() -> void:
	"""Update visual appearance based on currency type"""
	if not visual_node:
		visual_node = get_node_or_null("Visual")

	if visual_node and currency_type in CURRENCY_COLORS:
		visual_node.color = CURRENCY_COLORS[currency_type]


func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with player (CharacterBody2D)"""
	# Check if it's the player
	if body.is_in_group("player"):
		collect()


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with player area (if player uses Area2D)"""
	# Check if area belongs to player
	if area.is_in_group("player") or (area.owner and area.owner.is_in_group("player")):
		collect()


func collect() -> void:
	"""Collect the drop - emit signal and remove"""
	# Emit signal for DropSystem to handle
	collected.emit(currency_type, amount)

	# TODO: Add collection animation/effect (future polish)
	# - Scale tween
	# - Move toward player
	# - Particle effect

	# Remove the pickup
	queue_free()


func _to_string() -> String:
	return "DropPickup(%s x%d)" % [currency_type, amount]
