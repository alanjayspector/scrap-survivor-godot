extends CharacterBody2D
class_name Player
## Player entity for Scrap Survivor - Week 10 Combat Integration
##
## Integrates with CharacterService, WeaponService, and combat systems
## Handles movement, aiming, auto-fire, and health management

## Signals
signal health_changed(current_health: float, max_health: float)
signal player_damaged(current_hp: float, max_hp: float)
signal player_healed(current_hp: float, max_hp: float)
signal player_leveled_up(new_level: int, stats: Dictionary)
signal died

## Character integration
@export var character_id: String = ""

## Node references
@onready var weapon_pivot: Node2D = $WeaponPivot if has_node("WeaponPivot") else null

## Character stats (loaded from CharacterService)
var stats: Dictionary = {}
var current_hp: float = 100.0
var equipped_weapon_id: String = ""

## Weapon firing state
var weapon_cooldown: float = 0.0

## Visual feedback
var damage_flash_timer: float = 0.0
var damage_flash_duration: float = 0.1


func _ready() -> void:
	print("[Player] _ready() called, character_id: ", character_id)

	# Load character stats from CharacterService
	print("[Player] Loading character stats...")
	await _load_character_stats()
	print("[Player] Character stats loaded")

	# Connect to character signals
	print("[Player] Connecting to CharacterService signals...")
	CharacterService.character_level_up_post.connect(_on_character_level_up_post)
	CharacterService.character_death_post.connect(_on_character_death_post)
	print("[Player] CharacterService signals connected")

	# Connect to weapon service signals
	print("[Player] Checking WeaponService...")
	if WeaponService:
		print("[Player] Connecting to WeaponService signals...")
		WeaponService.weapon_fired.connect(_on_weapon_fired)
		print("[Player] WeaponService signals connected")

	# Add to player group
	add_to_group("player")
	print("[Player] Added to 'player' group")

	GameLogger.info("Player initialized", {"character_id": character_id})
	print("[Player] _ready() complete")


func _load_character_stats() -> void:
	"""Load character stats from CharacterService"""
	print("[Player] _load_character_stats() called")
	print("[Player] Current character_id: '", character_id, "'")

	if character_id.is_empty():
		print("[Player] character_id is empty, getting active character...")
		# Get active character
		var active_char = CharacterService.get_active_character()
		if active_char:
			character_id = active_char.id
			print("[Player] Got active character ID: ", character_id)
		else:
			print("[Player] ERROR: No active character found!")
			GameLogger.error("Player: No character ID and no active character")
			return

	# Get character data
	print("[Player] Getting character data for ID: ", character_id)
	var character = CharacterService.get_character(character_id)
	if character:
		print("[Player] Character found: ", character)
		stats = character.stats.duplicate()
		current_hp = stats.get("max_hp", 100)
		print("[Player] Stats loaded - max_hp: ", current_hp)

		# Emit initial health
		health_changed.emit(current_hp, stats.get("max_hp", 100))
		print("[Player] health_changed signal emitted")

		GameLogger.info("Player stats loaded", {"character_id": character_id, "stats": stats})
	else:
		print("[Player] ERROR: Character not found for ID: ", character_id)
		GameLogger.error("Player: Failed to load character stats", {"character_id": character_id})


func _physics_process(delta: float) -> void:
	# Update damage flash
	if damage_flash_timer > 0:
		damage_flash_timer -= delta

	# Update weapon cooldown
	if weapon_cooldown > 0:
		weapon_cooldown -= delta

	# WASD movement
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed = stats.get("speed", 200)
	velocity = input_direction * speed
	move_and_slide()

	# Mouse aiming (rotate weapon pivot if it exists)
	if weapon_pivot:
		var mouse_pos = get_global_mouse_position()
		weapon_pivot.look_at(mouse_pos)

		# Auto-fire weapon (if equipped and cooldown ready)
		if not equipped_weapon_id.is_empty() and weapon_cooldown <= 0:
			var direction = (mouse_pos - global_position).normalized()
			_fire_weapon(direction)


func _fire_weapon(direction: Vector2) -> void:
	"""Fire the equipped weapon using WeaponService"""
	if not WeaponService:
		return

	# Generate weapon instance ID for cooldown tracking
	var weapon_instance_id = "%s_%s" % [character_id, equipped_weapon_id]

	# Check if can fire
	if not WeaponService.can_fire_weapon(weapon_instance_id):
		return

	# Get weapon definition
	var weapon_def = WeaponService.get_weapon(equipped_weapon_id)
	if weapon_def.is_empty():
		return

	# Calculate cooldown with attack speed modifier
	var attack_speed_bonus = stats.get("attack_speed", 0) / 100.0
	var base_cooldown = weapon_def.get("cooldown", 1.0)
	weapon_cooldown = base_cooldown / (1.0 + attack_speed_bonus)

	# Get fire position (weapon pivot or player position)
	var fire_position = weapon_pivot.global_position if weapon_pivot else global_position

	# Fire through WeaponService (4 arguments required)
	var success = WeaponService.fire_weapon(
		equipped_weapon_id, weapon_instance_id, fire_position, direction
	)

	if success:
		GameLogger.debug("Player fired weapon", {"weapon_id": equipped_weapon_id})


func equip_weapon(weapon_id: String) -> bool:
	"""Equip a weapon for the player"""
	if not WeaponService:
		return false

	# Try to equip through service
	var success = WeaponService.equip_weapon(character_id, weapon_id)

	if success:
		equipped_weapon_id = weapon_id
		weapon_cooldown = 0.0
		GameLogger.info("Player equipped weapon", {"weapon_id": weapon_id})

	return success


func take_damage(amount: float, source_position: Vector2 = Vector2.ZERO) -> void:
	"""Take damage with armor reduction"""
	if current_hp <= 0:
		return

	# Apply armor reduction
	var armor = stats.get("armor", 0)
	var armor_multiplier = 1.0 / (1.0 + armor * 0.01)  # 1% damage reduction per armor point
	var actual_damage = amount * armor_multiplier
	actual_damage = max(actual_damage, amount * 0.2)  # Minimum 20% damage

	# Apply damage
	current_hp -= actual_damage
	current_hp = max(0, current_hp)

	# Emit signals
	player_damaged.emit(current_hp, stats.get("max_hp", 100))
	health_changed.emit(current_hp, stats.get("max_hp", 100))

	# Visual feedback
	damage_flash_timer = damage_flash_duration
	_flash_damage()

	# Apply knockback if source provided
	if source_position != Vector2.ZERO:
		var knockback_direction = (global_position - source_position).normalized()
		velocity = knockback_direction * 300.0

	# Check for death
	if current_hp <= 0:
		die()

	GameLogger.debug("Player took damage", {"damage": actual_damage, "current_hp": current_hp})


func heal(amount: float) -> void:
	"""Heal the player"""
	if current_hp <= 0:
		return

	var max_hp = stats.get("max_hp", 100)
	current_hp = min(current_hp + amount, max_hp)

	# Emit signals
	player_healed.emit(current_hp, max_hp)
	health_changed.emit(current_hp, max_hp)

	GameLogger.debug("Player healed", {"amount": amount, "current_hp": current_hp})


func die() -> void:
	"""Handle player death"""
	print("[Player] die() called for character: ", character_id)
	died.emit()

	# Disable physics
	set_physics_process(false)
	print("[Player] Physics processing disabled")

	# Trigger character death event
	if CharacterService:
		CharacterService.on_character_death(character_id)
		print("[Player] Character death event triggered")

	GameLogger.info("Player died", {"character_id": character_id})

	print("[Player] Game over - no game over screen implemented yet")
	# TODO Week 10 Phase 4: Show game over screen
	# get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")


func _flash_damage() -> void:
	"""Visual feedback for taking damage"""
	# Find Visual child and flash red
	for child in get_children():
		if child is ColorRect:
			var tween = create_tween()
			tween.tween_property(child, "color", Color.RED, 0.1)
			tween.tween_property(child, "color", Color(0.2, 0.6, 1, 1), 0.1)
		elif child is Sprite2D:
			var tween = create_tween()
			tween.tween_property(child, "modulate", Color.RED, 0.1)
			tween.tween_property(child, "modulate", Color.WHITE, 0.1)


## Signal Handlers


func _on_character_level_up_post(context: Dictionary) -> void:
	"""Handle character level up"""
	var char_id = context.get("character_id", "")
	if char_id != character_id:
		return

	var new_level = context.get("new_level", 1)

	# Reload stats after level up
	var character = CharacterService.get_character(character_id)
	if character:
		stats = character.stats.duplicate()

		# Heal to full on level up
		var max_hp = stats.get("max_hp", 100)
		current_hp = max_hp
		health_changed.emit(current_hp, max_hp)

		# Emit level up signal
		player_leveled_up.emit(new_level, stats)

		GameLogger.info("Player leveled up", {"level": new_level, "stats": stats})


func _on_character_death_post(context: Dictionary) -> void:
	"""Handle character death signal"""
	var char_id = context.get("character_id", "")
	if char_id == character_id:
		# Already handled in die(), this is just for cleanup
		return


func _on_weapon_fired(_weapon_id: String, _position: Vector2, _direction: Vector2) -> void:
	"""Handle weapon fired event (for visual/audio feedback)"""
	# Could add muzzle flash, sound effects, etc.
	# TODO Week 10 Phase 2: Add muzzle flash visual effect
	return


func get_stat(stat_name: String) -> float:
	"""Get a stat value"""
	return stats.get(stat_name, 0)


func is_alive() -> bool:
	"""Check if player is alive"""
	return current_hp > 0
