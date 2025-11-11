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

	# Set player tier to PREMIUM so they can collect currency
	# (FREE tier has 0 balance cap and blocks all currency collection)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	print("[Wasteland] Player tier set to PREMIUM")

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

	# Connect wave manager signals for kill tracking
	print("[Wasteland] Connecting to wave_manager.wave_completed...")
	wave_manager.wave_completed.connect(_on_wave_completed)
	print("[Wasteland] wave_manager.wave_completed signal connected")

	# Connect wave manager enemy died signal for screen shake
	print("[Wasteland] Connecting to wave_manager.enemy_died...")
	wave_manager.enemy_died.connect(_on_enemy_died_screen_shake)
	print("[Wasteland] wave_manager.enemy_died signal connected for screen shake")

	# Connect CharacterService level-up signal for visual feedback
	print("[Wasteland] Connecting to CharacterService.character_level_up_post...")
	CharacterService.character_level_up_post.connect(_on_character_level_up)
	print("[Wasteland] CharacterService.character_level_up_post signal connected")

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
	var damage = weapon_def.get("base_damage", 10)
	if player_instance:
		damage = WeaponService.get_weapon_damage(weapon_id, player_instance.stats)

	# Get weapon properties
	var speed = weapon_def.get("projectile_speed", 400)
	var range = weapon_def.get("range", 500)
	var special_behavior = weapon_def.get("special_behavior", "none")
	var projectiles_per_shot = weapon_def.get("projectiles_per_shot", 1)
	var pierce_count = weapon_def.get("pierce_count", 0)
	var splash_damage = weapon_def.get("splash_damage", 0.0)
	var splash_radius = weapon_def.get("splash_radius", 0.0)

	# Handle special behaviors
	match special_behavior:
		"spread":
			# Scattergun: Fire multiple projectiles in a spread pattern
			_spawn_spread_projectiles(
				position, direction, damage, speed, range, projectiles_per_shot, weapon_def
			)
		"cone":
			# Scorcher: Similar to spread but with piercing
			_spawn_spread_projectiles(
				position, direction, damage, speed, range, projectiles_per_shot, weapon_def
			)
		_:
			# Default: Single projectile with optional pierce/splash
			_spawn_projectile(
				position,
				direction,
				damage,
				speed,
				range,
				pierce_count,
				splash_damage,
				splash_radius
			)

	print("[Wasteland] Projectile(s) spawned with damage: ", damage, " speed: ", speed)


func _spawn_projectile(
	position: Vector2,
	direction: Vector2,
	damage: float,
	speed: float,
	range: float,
	pierce_count: int = 0,
	splash_damage: float = 0.0,
	splash_radius: float = 0.0
) -> void:
	"""Spawn a single projectile with given properties"""
	const PROJECTILE_SCENE = preload("res://scenes/entities/projectile.tscn")
	var projectile = PROJECTILE_SCENE.instantiate()
	projectiles_container.add_child(projectile)

	# Set pierce count if applicable
	if pierce_count > 0:
		projectile.pierce_count = pierce_count

	# Activate projectile with all properties including splash damage
	projectile.activate(position, direction, damage, speed, range, splash_damage, splash_radius)


func _spawn_spread_projectiles(
	position: Vector2,
	direction: Vector2,
	damage: float,
	speed: float,
	range: float,
	projectile_count: int,
	weapon_def: Dictionary
) -> void:
	"""Spawn multiple projectiles in a spread pattern"""
	var spread_angle = weapon_def.get("spread_angle", 40.0)  # Default 40° total spread
	var cone_angle = weapon_def.get("cone_angle", 30.0)  # For flamethrower
	var pierce_count = weapon_def.get("pierce_count", 0)
	var special_behavior = weapon_def.get("special_behavior", "spread")

	# Use cone_angle for flamethrower, spread_angle for shotgun
	var total_angle = cone_angle if special_behavior == "cone" else spread_angle

	# Calculate angle step between projectiles
	var angle_step = total_angle / max(1, projectile_count - 1) if projectile_count > 1 else 0.0
	var start_angle = -total_angle / 2.0  # Start from leftmost angle

	# Spawn projectiles in spread pattern
	for i in range(projectile_count):
		var angle_offset = start_angle + (angle_step * i)
		var spread_direction = direction.rotated(deg_to_rad(angle_offset))

		_spawn_projectile(position, spread_direction, damage, speed, range, pierce_count, 0.0, 0.0)


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

	# Connect player damaged signal for screen shake
	player_instance.player_damaged.connect(_on_player_damaged)
	print("[Wasteland] Player damaged signal connected for screen shake")

	# Connect player to HudService for HP/XP tracking
	print("[Wasteland] Connecting player to HudService...")
	HudService.set_player(player_instance)
	print("[Wasteland] HudService.set_player() called")

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

	# FREEZE GAME - prevent player movement/shooting/loot collection
	get_tree().paused = true
	print("[Wasteland] Game paused")

	# Calculate survival time
	var survival_time = (Time.get_ticks_msec() / 1000.0) - start_time

	# Show game over screen with stats
	var stats = {"wave": wave_manager.current_wave, "kills": total_kills, "time": survival_time}
	game_over_screen.show_game_over(stats)

	GameLogger.info("Player died", stats)


func _on_retry_pressed() -> void:
	"""Retry the game"""
	print("[Wasteland] Retry pressed - reloading scene")

	# Unpause before reloading (otherwise new scene starts paused)
	get_tree().paused = false
	print("[Wasteland] Game unpaused")

	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	"""Return to main menu"""
	print("[Wasteland] Main menu pressed - returning to character selection")

	# Unpause before transitioning (otherwise main menu starts paused)
	get_tree().paused = false
	print("[Wasteland] Game unpaused")

	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _on_wave_completed(wave: int, stats: Dictionary) -> void:
	"""Handle wave completion - track kills"""
	print("[Wasteland] Wave ", wave, " completed with stats: ", stats)

	# Add wave kills to total kills
	var wave_kills = stats.get("enemies_killed", 0)
	total_kills += wave_kills

	print("[Wasteland] Total kills updated: ", total_kills)
	GameLogger.info(
		"Wave completed", {"wave": wave, "wave_kills": wave_kills, "total_kills": total_kills}
	)


func _on_character_level_up(context: Dictionary) -> void:
	"""Handle character level up - show visual feedback"""
	var character_id = context.get("character_id", "")
	var new_level = context.get("new_level", 1)

	# Only show feedback if this is the player's character
	if player_instance and player_instance.character_id == character_id:
		print("[Wasteland] Player leveled up to level ", new_level, "!")
		_show_level_up_feedback(new_level)
		GameLogger.info("Player level up", {"character_id": character_id, "level": new_level})


func _show_level_up_feedback(new_level: int) -> void:
	"""Display 'LEVEL UP!' visual feedback"""
	print("[Wasteland] Showing level up feedback for level ", new_level)

	# Create temporary label for level up text
	var level_up_label = Label.new()
	level_up_label.text = "LEVEL UP!\nLevel %d" % new_level
	level_up_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Style the label
	level_up_label.add_theme_font_size_override("font_size", 48)
	level_up_label.modulate = Color(1, 1, 0, 1)  # Yellow

	# Position at center of screen
	level_up_label.position = Vector2(
		get_viewport().get_visible_rect().size.x / 2 - 200,
		get_viewport().get_visible_rect().size.y / 2 - 50
	)
	level_up_label.size = Vector2(400, 100)

	# Add to UI layer
	$UI.add_child(level_up_label)

	# Animate: fade in, stay, fade out
	var tween = create_tween()
	level_up_label.modulate.a = 0.0
	tween.tween_property(level_up_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)  # Stay visible for 1.5 seconds
	tween.tween_property(level_up_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(level_up_label.queue_free)

	print("[Wasteland] Level up feedback displayed")


func _on_player_damaged(_current_hp: float, _max_hp: float) -> void:
	"""Handle player taking damage - trigger screen shake"""
	screen_shake(5.0, 0.2)


func _on_enemy_died_screen_shake(_enemy_id: String) -> void:
	"""Handle enemy death - trigger small screen shake"""
	screen_shake(2.0, 0.1)


func screen_shake(intensity: float, duration: float) -> void:
	"""Shake the camera for visual impact"""
	if not camera:
		return

	# Cancel any existing shake
	var existing_tweens = camera.get_tree().get_processed_tweens()
	for tween in existing_tweens:
		if tween.is_valid():
			tween.kill()

	# Create shake tween
	var shake_tween = create_tween()
	shake_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	# Shake with random offsets
	var shake_count = int(duration * 60)  # 60 shakes per second
	var time_per_shake = duration / shake_count

	for i in range(shake_count):
		var shake_amount = intensity * (1.0 - float(i) / shake_count)  # Decay intensity
		var offset = Vector2(
			randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount)
		)
		shake_tween.tween_property(camera, "offset", offset, time_per_shake)

	# Return to center
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
