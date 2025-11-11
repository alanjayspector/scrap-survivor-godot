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

var player_instance: Player = null
var character_id: String = ""


func _ready() -> void:
	# Get active character from CharacterService
	var active_char = CharacterService.get_active_character()
	if active_char:
		character_id = active_char.id
		_spawn_player(character_id)
		_setup_wave_manager()
	else:
		GameLogger.error("No active character found for Wasteland scene")


func _setup_wave_manager() -> void:
	"""Initialize wave manager and connect signals"""
	# Set spawn container for enemies
	wave_manager.spawn_container = enemies_container

	# Connect wave complete screen to wave manager
	wave_complete_screen.next_wave_pressed.connect(_on_next_wave_pressed)

	# Start first wave
	await get_tree().create_timer(1.0).timeout
	wave_manager.start_wave()


func _on_next_wave_pressed() -> void:
	"""Handle next wave button press"""
	wave_manager.next_wave()


func _spawn_player(char_id: String) -> void:
	"""Spawn player entity with character data"""
	# Load player scene
	const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
	player_instance = PLAYER_SCENE.instantiate()

	# Set character ID for player to load stats
	player_instance.character_id = char_id

	# Add to player group for easy finding
	player_instance.add_to_group("player")

	# Position at center
	player_instance.global_position = Vector2.ZERO

	# Add to scene
	player_container.add_child(player_instance)

	# Set camera target
	camera.enabled = true

	GameLogger.info("Player spawned in Wasteland", {"character_id": char_id})


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
