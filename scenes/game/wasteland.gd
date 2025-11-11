extends Node2D
## Wasteland - Main combat scene for Scrap Survivor
##
## Week 10 Phase 1: Scene architecture for combat loop
##
## Responsibilities:
## - Initialize player with character from CharacterService
## - Manage enemy/projectile/drop containers
## - Coordinate wave progression
## - Handle scene setup and cleanup

@onready var camera: Camera2D = $Camera2D
@onready var player_container: Node2D = $Player
@onready var enemies_container: Node2D = $Enemies
@onready var projectiles_container: Node2D = $Projectiles
@onready var drops_container: Node2D = $Drops
@onready var wave_manager: WaveManager = $GameController
@onready var wave_complete_screen: Panel = $UI/WaveCompleteScreen
@onready var game_over_screen: Panel = $UI/GameOverScreen

var player_instance: Player = null
var character_id: String = ""
var start_time: float = 0.0
var total_kills: int = 0


func _ready() -> void:
	print("[Wasteland] _ready() called")

	# Verify scene nodes loaded
	print("[Wasteland] Camera: ", camera)
	print("[Wasteland] Player container: ", player_container)
	print("[Wasteland] Enemies container: ", enemies_container)
	print("[Wasteland] Wave manager: ", wave_manager)
	print("[Wasteland] Wave complete screen: ", wave_complete_screen)

	# Get active character from CharacterService
	print("[Wasteland] Getting active character...")
	var active_char = CharacterService.get_active_character()
	if active_char:
		print("[Wasteland] Active character found: ", active_char.id)
		character_id = active_char.id
		_spawn_player(character_id)
		_setup_wave_manager()
	else:
		print("[Wasteland] ERROR: No active character found!")
		GameLogger.error("No active character found for Wasteland scene")


func _setup_wave_manager() -> void:
	"""Initialize wave manager and connect signals"""
	print("[Wasteland] _setup_wave_manager() called")

	# Set spawn container for enemies
	wave_manager.spawn_container = enemies_container
	print("[Wasteland] Wave manager spawn container set to: ", enemies_container)

	# Connect wave complete screen to wave manager
	print("[Wasteland] Connecting wave complete screen signal...")
	wave_complete_screen.next_wave_pressed.connect(_on_next_wave_pressed)
	print("[Wasteland] Signal connected")

	# Connect game over screen signals
	print("[Wasteland] Connecting game over screen signals...")
	game_over_screen.retry_pressed.connect(_on_retry_pressed)
	game_over_screen.main_menu_pressed.connect(_on_main_menu_pressed)
	print("[Wasteland] Game over screen signals connected")

	# Connect weapon fired signal for projectile spawning
	print("[Wasteland] Connecting to WeaponService.weapon_fired...")
	WeaponService.weapon_fired.connect(_on_weapon_fired)
	print("[Wasteland] WeaponService.weapon_fired signal connected")

	# Start game timer
	start_time = Time.get_ticks_msec() / 1000.0

	# Start first wave
	print("[Wasteland] Waiting 1 second before starting wave...")
	await get_tree().create_timer(1.0).timeout
	print("[Wasteland] Starting wave 1...")
	wave_manager.start_wave()
	print("[Wasteland] Wave start called")


func _on_next_wave_pressed() -> void:
	"""Handle next wave button press"""
	wave_manager.next_wave()


func _on_weapon_fired(weapon_id: String, position: Vector2, direction: Vector2) -> void:
	"""Spawn projectile when weapon fires"""
	print("[Wasteland] _on_weapon_fired called: ", weapon_id, " at ", position)

	# Get weapon definition for projectile properties
	var weapon_def = WeaponService.get_weapon(weapon_id)
	if weapon_def.is_empty():
		print("[Wasteland] ERROR: Weapon definition not found for ", weapon_id)
		return

	# Calculate damage with player stats
	var damage = weapon_def.get("damage", 10)
	if player_instance:
		damage = WeaponService.get_weapon_damage(weapon_id, player_instance.stats)

	# Load and spawn projectile
	const PROJECTILE_SCENE = preload("res://scenes/entities/projectile.tscn")
	var projectile = PROJECTILE_SCENE.instantiate()
	projectiles_container.add_child(projectile)

	# Activate projectile with weapon properties
	var speed = weapon_def.get("projectile_speed", 400)
	var range = weapon_def.get("range", 500)
	projectile.activate(position, direction, damage, speed, range)

	print("[Wasteland] Projectile spawned with damage: ", damage, " speed: ", speed)


func _spawn_player(char_id: String) -> void:
	"""Spawn player entity with character data"""
	print("[Wasteland] _spawn_player() called with char_id: ", char_id)

	# Load player scene
	const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
	player_instance = PLAYER_SCENE.instantiate()
	print("[Wasteland] Player instance created: ", player_instance)

	# Set character ID for player to load stats
	player_instance.character_id = char_id
	print("[Wasteland] Character ID set on player")

	# Add to player group for easy finding
	player_instance.add_to_group("player")
	print("[Wasteland] Player added to 'player' group")

	# Position at center
	player_instance.global_position = Vector2.ZERO
	print("[Wasteland] Player positioned at center")

	# Add to scene
	print("[Wasteland] Adding player to scene...")
	player_container.add_child(player_instance)
	print("[Wasteland] Player added to scene tree")

	# Set camera target
	camera.enabled = true
	print("[Wasteland] Camera enabled")

	# Equip default weapon (plasma pistol is FREE tier)
	print("[Wasteland] Waiting for player _ready()...")
	await get_tree().process_frame  # Wait for player _ready() to complete
	print("[Wasteland] Equipping plasma_pistol...")
	var equipped = player_instance.equip_weapon("plasma_pistol")
	print("[Wasteland] Weapon equipped: ", equipped)

	# Connect player death signal
	player_instance.died.connect(_on_player_died)
	print("[Wasteland] Player death signal connected")

	GameLogger.info("Player spawned in Wasteland", {"character_id": char_id})
	print("[Wasteland] Player spawn complete")


func get_player() -> Player:
	"""Get the player instance"""
	return player_instance


func get_enemies_container() -> Node2D:
	"""Get the enemies container for spawning"""
	return enemies_container


func get_projectiles_container() -> Node2D:
	"""Get the projectiles container for spawning"""
	return projectiles_container


func get_drops_container() -> Node2D:
	"""Get the drops container for spawning"""
	return drops_container


func _on_player_died() -> void:
	"""Handle player death"""
	print("[Wasteland] Player died!")

	# Calculate survival time
	var survival_time = (Time.get_ticks_msec() / 1000.0) - start_time

	# Show game over screen with stats
	var stats = {"wave": wave_manager.current_wave, "kills": total_kills, "time": survival_time}
	game_over_screen.show_game_over(stats)

	GameLogger.info("Player died", stats)


func _on_retry_pressed() -> void:
	"""Retry the game"""
	print("[Wasteland] Retry pressed - reloading scene")
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	"""Return to main menu"""
	print("[Wasteland] Main menu pressed - returning to character selection")
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
