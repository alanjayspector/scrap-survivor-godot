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
	print("[DropPickup] _on_body_entered: ", body, " is_player: ", body.is_in_group("player"))
	# Check if it's the player
	if body.is_in_group("player"):
		print("[DropPickup] Player body detected, collecting!")
		collect()


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with player area (if player uses Area2D)"""
	print("[DropPickup] _on_area_entered: ", area)
	# Check if area belongs to player
	if area.is_in_group("player") or (area.owner and area.owner.is_in_group("player")):
		print("[DropPickup] Player area detected, collecting!")
		collect()


func collect() -> void:
	"""Collect the drop - emit signal and remove"""
	print("[DropPickup] collect() called for ", currency_type, " x", amount)

	# Emit signal for DropSystem to handle
	print("[DropPickup] Emitting collected signal...")
	collected.emit(currency_type, amount)
	print("[DropPickup] Signal emitted")

	# Play collection animation (scale up + fade out)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)


func _start_idle_animations() -> void:
	"""Start looping animations for visual appeal"""
	# Bobbing animation (up and down)
	var bob_tween = create_tween()
	bob_tween.set_loops()
	bob_tween.tween_property(self, "position:y", position.y - 3, 0.6).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(self, "position:y", position.y + 3, 0.6).set_ease(Tween.EASE_IN_OUT)

	# Pulsing scale animation (breathing effect)
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.5).set_ease(Tween.EASE_IN_OUT)

	# Slight rotation for extra flair
	var rotate_tween = create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property(self, "rotation", deg_to_rad(5), 0.8).set_ease(Tween.EASE_IN_OUT)
	rotate_tween.tween_property(self, "rotation", deg_to_rad(-5), 0.8).set_ease(Tween.EASE_IN_OUT)


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
