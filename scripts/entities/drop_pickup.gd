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
var magnet_range: float = 100.0  # Default pickup detection range (overridden by player stat)
var magnet_speed: float = 200.0  # How fast drops fly toward player (px/s)
var is_magnetized: bool = false  # Tracking state for visual feedback
var is_collected: bool = false  # Guard against multiple collections

## Visual reference
var visual_node: ColorRect = null

## Currency colors (Brotato-inspired visual clarity)
const CURRENCY_COLORS = {
	"scrap": Color(0.6, 0.4, 0.2, 1),  # Brown
	"components": Color(0.2, 0.5, 0.9, 1),  # Blue
	"nanites": Color(0.7, 0.3, 0.8, 1)  # Purple
}


func _ready() -> void:
	print("[DropPickup] _ready() called for ", currency_type, " x", amount, " at ", global_position)

	# Defer collision setup to avoid physics state changes during callbacks
	call_deferred("_setup_collision")

	# Connect signals for player detection
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	print("[DropPickup] Signals connected")

	# Get visual node reference
	visual_node = get_node_or_null("Visual")
	print("[DropPickup] Visual node: ", visual_node)

	# Update visual based on currency type
	update_visual()

	# Add eye-catching animations
	_start_idle_animations()
	print("[DropPickup] Initialization complete")


func _setup_collision() -> void:
	"""Setup collision properties (deferred to avoid physics callback issues)"""
	# Set up collision
	collision_layer = 8  # Layer 4 (2^3 = 8)
	collision_mask = 1  # Detect player on layer 1
	monitoring = true
	monitorable = true
	print("[DropPickup] Collision configured: layer=8, mask=1")


func _physics_process(delta: float) -> void:
	"""Handle drop magnetism - fly toward player when in range"""
	# Get player reference
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		is_magnetized = false
		return

	# Get player's pickup_range stat
	var player_pickup_range = player.get_stat("pickup_range")
	if player_pickup_range <= 0:
		player_pickup_range = magnet_range  # Fallback to default

	# Calculate distance to player
	var distance = global_position.distance_to(player.global_position)

	# Check if within pickup range
	if distance <= player_pickup_range:
		# Drop is magnetized - fly toward player
		is_magnetized = true

		# Calculate direction to player
		var direction = (player.global_position - global_position).normalized()

		# Calculate speed multiplier (accelerates as drop gets closer)
		# Speed ranges from 1x (at max range) to 3x (very close to player)
		var speed_multiplier = 1.0 + (1.0 - distance / player_pickup_range) * 2.0

		# Apply velocity
		var velocity = direction * magnet_speed * speed_multiplier
		global_position += velocity * delta

		# Update magnetized visual feedback
		_update_magnetized_visual()
	else:
		# Drop is not magnetized
		if is_magnetized:
			# Just left magnet range - reset visual
			is_magnetized = false
			_update_magnetized_visual()


func setup(type: String, amt: int) -> void:
	"""Initialize drop with currency type and amount"""
	print("[DropPickup] setup() called: ", type, " x", amt)
	currency_type = type
	amount = amt
	update_visual()
	print("[DropPickup] Setup complete")


func update_visual() -> void:
	"""Update visual appearance based on currency type"""
	if not visual_node:
		visual_node = get_node_or_null("Visual")

	if visual_node and currency_type in CURRENCY_COLORS:
		visual_node.color = CURRENCY_COLORS[currency_type]


func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with player (CharacterBody2D)"""
	print("[DropPickup] ═══ _on_body_entered() ENTRY ═══")
	print("[DropPickup]   Body: ", body)
	print("[DropPickup]   Body type: ", body.get_class())
	print("[DropPickup]   Is in player group: ", body.is_in_group("player"))
	print("[DropPickup]   Instance ID: ", get_instance_id())
	print("[DropPickup]   Currency: ", currency_type, " x", amount)
	print("[DropPickup]   Already collected: ", is_collected)

	# Check if it's the player
	if body.is_in_group("player"):
		print("[DropPickup]   Player body detected, calling collect()")
		collect()
	else:
		print("[DropPickup]   Not a player, ignoring")

	print("[DropPickup] ═══ _on_body_entered() EXIT ═══")


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with player area (if player uses Area2D)"""
	print("[DropPickup] ═══ _on_area_entered() ENTRY ═══")
	print("[DropPickup]   Area: ", area)
	print("[DropPickup]   Area owner: ", area.owner if area.owner else "none")
	print("[DropPickup]   Instance ID: ", get_instance_id())
	print("[DropPickup]   Currency: ", currency_type, " x", amount)
	print("[DropPickup]   Already collected: ", is_collected)

	# Check if area belongs to player
	if area.is_in_group("player") or (area.owner and area.owner.is_in_group("player")):
		print("[DropPickup]   Player area detected, calling collect()")
		collect()
	else:
		print("[DropPickup]   Not a player area, ignoring")

	print("[DropPickup] ═══ _on_area_entered() EXIT ═══")


func collect() -> void:
	"""Collect the drop - emit signal and remove"""
	print("[DropPickup] ═══ collect() ENTRY ═══")
	print("[DropPickup]   Currency: ", currency_type, " x", amount)
	print("[DropPickup]   Instance ID: ", get_instance_id())
	print("[DropPickup]   Position: ", global_position)
	print("[DropPickup]   Is collected: ", is_collected)
	print("[DropPickup]   Is inside tree: ", is_inside_tree())
	print("[DropPickup]   Is queued for deletion: ", is_queued_for_deletion())

	# Guard against multiple collections
	if is_collected:
		print("[DropPickup]   REJECTED: Already collected!")
		print("[DropPickup] ═══ collect() EXIT (early return) ═══")
		return

	print("[DropPickup]   Marking as collected")
	is_collected = true

	# Emit signal for DropSystem to handle
	print("[DropPickup]   Emitting collected signal (", currency_type, ", ", amount, ")")
	collected.emit(currency_type, amount)
	print("[DropPickup]   Signal emitted successfully")

	# Immediate cleanup (iOS-compatible - Tweens don't work on iOS Metal renderer)
	print("[DropPickup]   Calling queue_free() for immediate cleanup")
	queue_free()
	print("[DropPickup] ═══ collect() EXIT (immediate cleanup) ═══")


func _start_idle_animations() -> void:
	"""Start looping animations for visual appeal (disabled for iOS compatibility)"""
	# NOTE: Idle animations disabled - Tweens don't work on iOS Metal renderer
	# Pickups are still fully functional, just without cosmetic bob/pulse/rotate
	return


func _update_magnetized_visual() -> void:
	"""Update visual feedback based on magnetized state"""
	if is_magnetized:
		# Brighter color when magnetized (1.3x brightness)
		modulate = Color(1.3, 1.3, 1.3, 1.0)
	else:
		# Normal color
		modulate = Color(1.0, 1.0, 1.0, 1.0)


func _to_string() -> String:
	return "DropPickup(%s x%d)" % [currency_type, amount]
