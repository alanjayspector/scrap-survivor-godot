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

var player_instance: Player = null
var character_id: String = ""


func _ready() -> void:
	# Get active character from CharacterService
	var active_char = CharacterService.get_active_character()
	if active_char:
		character_id = active_char.id
		_spawn_player(character_id)
	else:
		GameLogger.error("No active character found for Wasteland scene")


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
