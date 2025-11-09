class_name Player
extends CharacterBody2D
## Player entity for Scrap Survivor
##
## Handles player movement, health, weapon management, and combat.
## Integrates with WeaponResource and ItemResource systems.

## Emitted when player health changes
signal health_changed(current_health: float, max_health: float)

## Emitted when player takes damage
signal damage_taken(amount: float)

## Emitted when player dies
signal died

## Emitted when weapon is equipped
signal weapon_equipped(weapon: WeaponResource)

## Emitted when player fires weapon
signal weapon_fired(projectile_data: Dictionary)

## Base stats
@export_group("Base Stats")
@export var max_health: float = 100.0
@export var base_speed: float = 200.0
@export var base_damage: float = 10.0
@export var base_armor: float = 0.0

## Current stats (modified by items)
var current_health: float = 100.0
var current_speed: float = 200.0
var current_damage: float = 10.0
var current_armor: float = 0.0

## Combat properties
@export_group("Combat")
@export var invulnerability_duration: float = 0.5
@export var knockback_resistance: float = 0.5

var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0

## Weapon management
var equipped_weapon: WeaponResource = null
var weapon_cooldown: float = 0.0

## Item effects
var stat_modifiers: Dictionary = {
	"maxHp": 0,
	"damage": 0,
	"speed": 0,
	"armor": 0,
	"luck": 0,
	"lifeSteal": 0,
	"scrapGain": 0,
	"dodge": 0,
	"attackSpeed": 0,
	"pickupRange": 0,
	"range": 0
}

## Movement
var move_direction: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	current_health = max_health
	current_speed = base_speed
	current_damage = base_damage
	current_armor = base_armor

	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	# Update invulnerability timer
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0:
			is_invulnerable = false

	# Update weapon cooldown
	if weapon_cooldown > 0:
		weapon_cooldown -= delta

	# Handle movement
	handle_movement(delta)

	# Handle weapon firing
	if equipped_weapon and weapon_cooldown <= 0:
		if should_fire_weapon():
			fire_weapon()


func handle_movement(_delta: float) -> void:
	"""Handle player movement with physics"""
	# Get input direction
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Apply speed
	velocity = move_direction * current_speed

	# Move with collision
	move_and_slide()

	# Update aim direction (towards mouse or last movement)
	var mouse_pos = get_global_mouse_position()
	aim_direction = (mouse_pos - global_position).normalized()

	# Rotate sprite to face movement direction (optional)
	if move_direction.length() > 0.1:
		rotation = move_direction.angle()


func should_fire_weapon() -> bool:
	"""Check if weapon should fire (auto-fire or manual)"""
	# Auto-fire for now (can be changed to manual with Input.is_action_pressed)
	return true


func fire_weapon() -> void:
	"""Fire the equipped weapon"""
	if not equipped_weapon:
		return

	# Apply weapon cooldown (affected by attack speed modifier)
	var attack_speed_bonus = 1.0 + (stat_modifiers.get("attackSpeed", 0) / 100.0)
	weapon_cooldown = 1.0 / (equipped_weapon.fire_rate * attack_speed_bonus)

	# Calculate damage with modifiers
	var total_damage = equipped_weapon.damage + current_damage + stat_modifiers.get("damage", 0)

	# Calculate range with modifiers
	var total_range = equipped_weapon.weapon_range + stat_modifiers.get("range", 0)

	# Emit projectile data for weapon system to handle
	var projectile_data = {
		"position": global_position,
		"direction": aim_direction,
		"damage": total_damage,
		"speed": equipped_weapon.projectile_speed,
		"range": total_range,
		"weapon_id": equipped_weapon.weapon_id
	}

	weapon_fired.emit(projectile_data)


func equip_weapon(weapon: WeaponResource) -> void:
	"""Equip a weapon"""
	equipped_weapon = weapon
	weapon_cooldown = 0.0
	weapon_equipped.emit(weapon)


func take_damage(amount: float, source_position: Vector2 = Vector2.ZERO) -> void:
	"""Take damage with armor reduction and invulnerability"""
	if is_invulnerable:
		return

	# Apply armor reduction (each point of armor reduces damage by ~2%)
	var armor_reduction = 1.0 - (current_armor * 0.02)
	armor_reduction = clamp(armor_reduction, 0.2, 1.0)  # Min 20% damage, max 100%

	var final_damage = amount * armor_reduction

	# Apply damage
	current_health -= final_damage
	current_health = max(0, current_health)

	# Emit signals
	damage_taken.emit(final_damage)
	health_changed.emit(current_health, max_health)

	# Apply knockback if source position provided
	if source_position != Vector2.ZERO:
		apply_knockback(source_position)

	# Set invulnerability
	is_invulnerable = true
	invulnerability_timer = invulnerability_duration

	# Check for death
	if current_health <= 0:
		die()


func apply_knockback(source_position: Vector2) -> void:
	"""Apply knockback away from damage source"""
	var knockback_direction = (global_position - source_position).normalized()
	var knockback_force = 300.0 * (1.0 - knockback_resistance)
	velocity = knockback_direction * knockback_force


func heal(amount: float) -> void:
	"""Heal the player"""
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func die() -> void:
	"""Handle player death"""
	died.emit()
	# Disable physics
	set_physics_process(false)
	# Visual feedback (fade out, animation, etc.)
	# Game over logic handled by game manager


func apply_item_modifiers(item: ItemResource) -> void:
	"""Apply stat modifiers from an item"""
	for stat_name in item.stat_modifiers.keys():
		var value = item.stat_modifiers[stat_name]
		stat_modifiers[stat_name] = stat_modifiers.get(stat_name, 0) + value

	# Recalculate stats
	recalculate_stats()


func recalculate_stats() -> void:
	"""Recalculate current stats based on base stats and modifiers"""
	# Max health
	var old_max_health = max_health
	var base_max_health = 100.0  # Base max health value
	max_health = base_max_health + stat_modifiers.get("maxHp", 0)
	max_health = max(1, max_health)  # Minimum 1 HP

	# Adjust current health proportionally if max changed
	if old_max_health > 0:
		var health_ratio = current_health / old_max_health
		current_health = max_health * health_ratio

	# Speed
	current_speed = base_speed + stat_modifiers.get("speed", 0)
	current_speed = max(50, current_speed)  # Minimum 50 speed

	# Damage
	current_damage = base_damage + stat_modifiers.get("damage", 0)

	# Armor
	current_armor = base_armor + stat_modifiers.get("armor", 0)
	current_armor = max(0, current_armor)  # No negative armor

	# Emit health changed
	health_changed.emit(current_health, max_health)


func get_stat_value(stat_name: String) -> float:
	"""Get the current value of a stat including modifiers"""
	match stat_name:
		"maxHp":
			return max_health
		"health":
			return current_health
		"speed":
			return current_speed
		"damage":
			return current_damage
		"armor":
			return current_armor
		_:
			return stat_modifiers.get(stat_name, 0)


func _to_string() -> String:
	return (
		"Player(hp=%.0f/%.0f, spd=%.0f, dmg=%.0f, armor=%.0f)"
		% [current_health, max_health, current_speed, current_damage, current_armor]
	)
