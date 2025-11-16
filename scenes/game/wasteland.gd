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

@onready var camera: CameraController = $Camera2D
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

## iOS-safe label pool (replaces queue_free() pattern) - 2025-01-14
# Label pool (DISABLED - no longer using text overlays, 2025-11-15)
# var label_pool: IOSLabelPool = null

## ENHANCED DIAGNOSTIC: Real-time label state monitoring (2025-11-15)
var label_monitor_timer: float = 0.0
const LABEL_MONITOR_INTERVAL: float = 1.0  # Check every second


func _ready() -> void:
	print("[Wasteland] _ready() called")

	# Set player tier to PREMIUM so they can collect currency
	# (FREE tier has 0 balance cap and blocks all currency collection)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	print("[Wasteland] Player tier set to PREMIUM")

	# Set weapon tier to SUBSCRIPTION for testing all weapons (Week 14 QA)
	# TODO: Remove when proper account system is implemented
	WeaponService.set_tier(WeaponService.UserTier.SUBSCRIPTION)
	print("[Wasteland] Weapon tier set to SUBSCRIPTION (all weapons unlocked)")

	# Verify scene nodes loaded
	print("[Wasteland] Camera: ", camera)
	print("[Wasteland] Player container: ", player_container)
	print("[Wasteland] Enemies container: ", enemies_container)
	print("[Wasteland] Wave manager: ", wave_manager)
	print("[Wasteland] Wave complete screen: ", wave_complete_screen)

	# Initialize iOS-safe label pool (replaces queue_free() pattern)
	# Label pool (DISABLED - no longer using text overlays, 2025-11-15)
	# label_pool = IOSLabelPool.new($UI)
	# print("[Wasteland] Label pool initialized")

	# Get active character from CharacterService
	print("[Wasteland] Getting active character...")
	var active_char = CharacterService.get_active_character()
	if active_char:
		print("[Wasteland] Active character found: ", active_char.id)
		character_id = active_char.id
		_spawn_player(character_id)
		_setup_wave_manager()

		# iOS-only: Add debug weapon switcher for testing (Week 14 Phase 1.0)
		# TEMPORARY: Remove before production release
		_add_debug_weapon_switcher()
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

	# Connect wave started signal to re-enable player
	print("[Wasteland] Connecting to wave_manager.wave_started...")
	wave_manager.wave_started.connect(_on_wave_started)
	print("[Wasteland] wave_manager.wave_started signal connected")

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

	# Get visual properties (Phase 1.5+)
	var projectile_color = weapon_def.get("projectile_color", Color.WHITE)
	var trail_color = weapon_def.get("trail_color", Color.WHITE)
	var trail_width = weapon_def.get("trail_width", 2.0)
	var proj_shape = weapon_def.get("projectile_shape", 0)
	var proj_shape_size = weapon_def.get("projectile_shape_size", Vector2(8, 8))

	# Handle special behaviors
	match special_behavior:
		"spread":
			# Scattergun: Fire multiple projectiles in a spread pattern
			_spawn_spread_projectiles(
				position,
				direction,
				damage,
				speed,
				range,
				projectiles_per_shot,
				weapon_def,
				projectile_color,
				trail_color,
				trail_width,
				proj_shape,
				proj_shape_size
			)
		"cone":
			# Scorcher: Similar to spread but with piercing
			_spawn_spread_projectiles(
				position,
				direction,
				damage,
				speed,
				range,
				projectiles_per_shot,
				weapon_def,
				projectile_color,
				trail_color,
				trail_width,
				proj_shape,
				proj_shape_size
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
				splash_radius,
				projectile_color,
				trail_color,
				trail_width,
				proj_shape,
				proj_shape_size
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
	splash_radius: float = 0.0,
	projectile_color: Color = Color.WHITE,
	trail_color: Color = Color.WHITE,
	trail_width: float = 2.0,
	proj_shape: int = 0,
	proj_shape_size: Vector2 = Vector2(8, 8)
) -> void:
	"""Spawn a single projectile with given properties"""
	const PROJECTILE_SCENE = preload("res://scenes/entities/projectile.tscn")
	var projectile = PROJECTILE_SCENE.instantiate()
	projectiles_container.add_child(projectile)

	# Set pierce count if applicable
	if pierce_count > 0:
		projectile.pierce_count = pierce_count

	# Activate projectile with all properties including visual properties (Phase 1.5+)
	projectile.activate(
		position,
		direction,
		damage,
		speed,
		range,
		splash_damage,
		splash_radius,
		projectile_color,
		trail_color,
		trail_width,
		proj_shape,
		proj_shape_size
	)


func _spawn_spread_projectiles(
	position: Vector2,
	direction: Vector2,
	damage: float,
	speed: float,
	range: float,
	projectile_count: int,
	weapon_def: Dictionary,
	projectile_color: Color = Color.WHITE,
	trail_color: Color = Color.WHITE,
	trail_width: float = 2.0,
	proj_shape: int = 0,
	proj_shape_size: Vector2 = Vector2(8, 8)
) -> void:
	"""Spawn multiple projectiles in a spread pattern"""
	var spread_angle = weapon_def.get("spread_angle", 40.0)  # Default 40° total spread
	var cone_angle = weapon_def.get("cone_angle", 30.0)  # For flamethrower
	var pierce_count = weapon_def.get("pierce_count", 0)
	var special_behavior = weapon_def.get("special_behavior", "spread")

	# Use cone_angle for flamethrower, spread_angle for shotgun
	var total_angle = cone_angle if special_behavior == "cone" else spread_angle

	# Spawn particle effects for flamethrower (Phase 1.5 P1)
	if special_behavior == "cone":
		_spawn_flamethrower_particles(position, direction, projectile_color, cone_angle, range)

	# Calculate angle step between projectiles
	var angle_step = total_angle / max(1, projectile_count - 1) if projectile_count > 1 else 0.0
	var start_angle = -total_angle / 2.0  # Start from leftmost angle

	# Spawn projectiles in spread pattern
	for i in range(projectile_count):
		var angle_offset = start_angle + (angle_step * i)
		var spread_direction = direction.rotated(deg_to_rad(angle_offset))

		_spawn_projectile(
			position,
			spread_direction,
			damage,
			speed,
			range,
			pierce_count,
			0.0,
			0.0,
			projectile_color,
			trail_color,
			trail_width,
			proj_shape,
			proj_shape_size
		)


func _spawn_flamethrower_particles(
	spawn_position: Vector2, direction: Vector2, color: Color, cone_angle: float, max_range: float
) -> void:
	"""Spawn CPUParticles2D cone emitter for flamethrower visual (Phase 1.5 P1)"""
	var particles = CPUParticles2D.new()
	particles.global_position = spawn_position
	particles.z_index = 0

	# Emission settings - continuous short burst
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.0  # Continuous stream
	particles.amount = 12
	particles.lifetime = 0.4  # Short-lived particles
	particles.preprocess = 0.0

	# Particle appearance
	particles.color = color
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0

	# Cone emission
	var angle_rad = direction.angle()
	particles.direction = Vector2(cos(angle_rad), sin(angle_rad))
	particles.spread = cone_angle

	# Velocity to match range
	var particle_speed = max_range / particles.lifetime
	particles.initial_velocity_min = particle_speed * 0.8
	particles.initial_velocity_max = particle_speed * 1.2

	# Fade and shrink over lifetime
	particles.scale_amount_curve = _create_fade_curve()

	# Add to scene
	projectiles_container.add_child(particles)

	# Auto-cleanup
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()


func _create_fade_curve() -> Curve:
	"""Create a curve for particle fade-out"""
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.2))
	return curve


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

	# Set camera to follow player
	camera.target = player_instance
	camera.enabled = true
	print("[Wasteland] Camera enabled and set to follow player")

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

	# Gather currency stats from BankingService
	var scrap = BankingService.balances.get("scrap", 0) if BankingService else 0
	var components = BankingService.balances.get("components", 0) if BankingService else 0
	var nanites = BankingService.balances.get("nanites", 0) if BankingService else 0

	# Show game over screen with stats
	var stats = {
		"wave": wave_manager.current_wave,
		"kills": total_kills,
		"time": survival_time,
		"scrap": scrap,
		"components": components,
		"nanites": nanites
	}
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


func _on_wave_started(wave: int) -> void:
	"""Handle wave start - re-enable player gameplay"""
	print("[Wasteland] Wave ", wave, " started")

	# Re-enable player input and physics (disabled during wave complete screen)
	if player_instance:
		player_instance.set_physics_process(true)
		player_instance.set_process_input(true)
		print("[Wasteland] Player movement/input re-enabled")

	GameLogger.info("Wave started", {"wave": wave})


func _on_wave_completed(wave: int, stats: Dictionary) -> void:
	"""Handle wave completion - track kills and freeze gameplay"""
	var completion_time = Time.get_ticks_msec() / 1000.0
	print(
		"[Wasteland] Wave ",
		wave,
		" completed with stats: ",
		stats,
		" (time: ",
		completion_time,
		"s)"
	)

	# Bug #9 fix (2025-01-14): Clear any active level-up labels before showing complete screen
	# Prevents level-up overlays from appearing over wave complete panel
	_clear_all_level_up_labels()

	# ENHANCED DIAGNOSTIC: Log Metal rendering stats after clearing labels (2025-11-15)
	_log_metal_rendering_stats("after_clear_level_up_labels")

	# Bug #11 fix (2025-01-14): Clean up all enemies to prevent zombie persistence
	# iOS race condition: dying enemies still in scene tree when wave completes
	_cleanup_all_enemies()

	# ENHANCED DIAGNOSTIC: Log Metal rendering stats after wave complete (2025-11-15)
	_log_metal_rendering_stats("after_wave_complete_cleanup")

	# Add wave kills to total kills
	var wave_kills = stats.get("enemies_killed", 0)
	total_kills += wave_kills

	print("[Wasteland] Total kills updated: ", total_kills)
	GameLogger.info(
		"Wave completed", {"wave": wave, "wave_kills": wave_kills, "total_kills": total_kills}
	)

	# Freeze gameplay - disable player
	if player_instance:
		player_instance.set_physics_process(false)
		player_instance.set_process_input(false)
		print("[Wasteland] Player movement/input disabled")


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
	"""Display level-up feedback using screen flash + camera shake (2025-11-15)

	Industry standard approach (Brotato, Vampire Survivors, Halls of Torment):
	- Screen flash effect (white flash fade-out)
	- Camera shake for impact
	- Sound effect (TODO: Add level-up sound)
	- HUD level number animation (handled by HudService)

	NO text overlays - avoids iOS Metal Tween issues entirely.

	Reference: docs/experiments/ios-tween-failure-analysis-2025-11-15.md
	"""
	print("[Wasteland] Showing level up feedback for level ", new_level)

	# Screen flash effect (white flash fade-out)
	_trigger_screen_flash()

	# Camera shake for impact (reusing existing implementation)
	screen_shake(8.0, 0.3)

	# TODO: Play level-up sound effect here
	# AudioServer.play_sound("level_up")

	print("[Wasteland] Level up feedback complete (screen flash + camera shake)")


func _trigger_screen_flash() -> void:
	"""Trigger white screen flash effect for level-up feedback (2025-11-15)

	Creates a temporary white overlay that fades out quickly using manual animation.
	Industry standard pattern used by Vampire Survivors, Brotato, etc.

	Note: Can't use Tweens on iOS (they don't execute), so we use manual _process animation.
	"""
	# Get or create flash overlay
	var ui_layer = $UI
	var flash_overlay = ui_layer.get_node_or_null("FlashOverlay")

	if not flash_overlay:
		# Create flash overlay (first time only)
		flash_overlay = ColorRect.new()
		flash_overlay.name = "FlashOverlay"
		flash_overlay.color = Color(1, 1, 1, 0)  # White, start transparent
		flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Cover entire screen
		flash_overlay.anchor_left = 0.0
		flash_overlay.anchor_top = 0.0
		flash_overlay.anchor_right = 1.0
		flash_overlay.anchor_bottom = 1.0

		ui_layer.add_child(flash_overlay)
		print("[Wasteland] Created flash overlay")

	# Start flash animation: 0.0 → 0.5 → 0.0 (white flash fade-out, 0.2s duration)
	flash_overlay.color.a = 0.5  # Instant flash to 50% opacity
	flash_overlay.set_meta("flash_time", 0.0)
	flash_overlay.set_meta("flash_duration", 0.2)  # 0.2 second fade-out
	flash_overlay.set_meta("flash_active", true)

	print("[Wasteland] Screen flash triggered (50% white → fade to 0% over 0.2s)")


# DISABLED: Tween-based cleanup (no longer used - screen flash replaces text overlays, 2025-11-15)
# func _on_level_up_tween_finished(label: Label, level: int) -> void:
# 	"""Tween-based cleanup callback - return label to pool (2025-01-15)
#
# 	Called when Tween animation completes (fade in → hold → fade out).
# 	Uses iOS-safe modulate.a pattern, never calls hide() or queue_free().
#
# 	Reference: docs/godot-ios-temp-ui.md (Pattern 1: Reusable Label with Tween)
# 	"""
# 	print("[Wasteland] _on_level_up_tween_finished CALLED for level ", level)
#
# 	if is_instance_valid(label):
# 		print("[Wasteland]   Label modulate.a BEFORE cleanup: %.3f" % label.modulate.a)
# 		print("[Wasteland]   Returning label to pool (ID: ", label.get_instance_id(), ")")
# 		# Return to pool (sets modulate.a = 0.0, never calls hide())
# 		label_pool.return_label(label)
# 		print("[Wasteland]   Label modulate.a AFTER cleanup: %.3f" % label.modulate.a)
# 	else:
# 		print("[Wasteland]   WARNING: Label already invalid!")
#
# 	print("[Wasteland] _on_level_up_tween_finished COMPLETE")
#
# 	# Log pool stats
# 	var stats = label_pool.get_stats()
# 	print("[Wasteland] Label pool: ", stats.available, " available, ", stats.active, " active")
#
# 	# ENHANCED DIAGNOSTIC: Log Metal rendering stats after Tween finished (2025-11-15)
# 	_log_metal_rendering_stats("after_level_up_tween_finished")


func _clear_all_level_up_labels() -> void:
	"""Clear all active level-up labels (NO-OP, text overlays removed 2025-11-15)

	Text overlays have been removed in favor of screen flash + camera shake.
	This function is kept for compatibility but does nothing.

	Reference: docs/experiments/ios-tween-failure-analysis-2025-11-15.md
	"""
	print("[Wasteland] _clear_all_level_up_labels() called (NO-OP - no text overlays)")


func _cleanup_all_enemies() -> void:
	"""Clean up all enemies from scene tree (Bug #11 fix - 2025-01-14, updated 2025-01-14)

	iOS Metal renderer bug fix: Enemies remain in GPU draw list even after
	hide() + remove_child() + queue_free(). Updated to use IOSCleanup utility
	which forces visual invalidation through multiple redundant methods.

	Reference: docs/experiments/ios-rendering-pipeline-bug-analysis.md
	"""
	var cleanup_time = Time.get_ticks_msec() / 1000.0
	print("[Wasteland] _cleanup_all_enemies() called (time: ", cleanup_time, "s)")

	var enemies = get_tree().get_nodes_in_group("enemies")
	print(
		"[Wasteland]   Enemies to clean: ", enemies.size(), " (in 'enemies' group at cleanup time)"
	)

	# Use IOSCleanup utility for iOS-safe visual invalidation
	IOSCleanup.force_invisible_and_destroy_batch(enemies)

	# iOS Metal renderer fix: Force viewport to flush cached framebuffer
	_force_viewport_refresh()

	print("[Wasteland] All enemies cleaned up via IOSCleanup")


func _log_metal_rendering_stats(context: String) -> void:
	"""ENHANCED DIAGNOSTIC: Log Metal rendering stats (2025-11-15)

	Logs Performance monitor statistics and canvas item counts to diagnose
	iOS Metal ghost rendering issues.

	NOTE: Godot 4.5.1 doesn't have RENDER_2D_* Performance constants.
	We manually count canvas items instead.

	Args:
		context: Description of when this is being called (e.g. "after_level_up", "wave_complete")
	"""
	print("[MetalDebug] === Rendering Stats (%s) ===" % context)

	# Performance monitors (validated working in Godot 4.5.1)
	print("[MetalDebug]   Objects in memory: ", Performance.get_monitor(Performance.OBJECT_COUNT))
	print("[MetalDebug]   Nodes in tree: ", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	print(
		"[MetalDebug]   Orphan nodes: ",
		Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	)
	print("[MetalDebug]   FPS: %.1f" % Performance.get_monitor(Performance.TIME_FPS))
	print(
		(
			"[MetalDebug]   Frame time: %.2f ms"
			% (Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
		)
	)
	print(
		(
			"[MetalDebug]   Memory: %.2f MB"
			% (Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0)
		)
	)

	# Manual canvas item counting for iOS Metal diagnostics
	var canvas_items = _count_canvas_items_recursive(self)
	print("[MetalDebug]   Canvas items (manual count): ", canvas_items)

	# Label pool diagnostics (DISABLED - no longer using text overlays, 2025-11-15)
	# if label_pool:
	# 	print("[MetalDebug]   Label pool - active: ", label_pool.active_labels.size())
	# 	print("[MetalDebug]   Label pool - available: ", label_pool.available_labels.size())


func _count_canvas_items_recursive(node: Node) -> int:
	"""Manually count visible CanvasItem nodes in scene tree for Metal diagnostics

	Since Godot 4.5.1 doesn't expose RENDER_2D_ITEMS_IN_FRAME, we count manually.
	This helps us verify if cleanup actually removes items from the render tree.
	"""
	var count = 0
	if node is CanvasItem and node.visible:
		count = 1
	for child in node.get_children():
		count += _count_canvas_items_recursive(child)
	return count


func _force_viewport_refresh() -> void:
	"""Force iOS Metal renderer to flush cached framebuffer and rebuild canvas

	iOS Metal renderer bug: Ghost images persist even after nodes are cleaned up.
	This attempts to force the renderer to rebuild by manipulating viewport settings.

	Reference: docs/experiments/ios-rendering-pipeline-bug-analysis.md
	"""
	print("[Wasteland] _force_viewport_refresh() - attempting to flush Metal renderer cache")

	var viewport = get_viewport()
	if viewport:
		# Method 1: Toggle viewport transparency to force redraw
		var original_transparent = viewport.transparent_bg
		viewport.transparent_bg = not original_transparent
		viewport.transparent_bg = original_transparent
		print("[Wasteland]   Toggled viewport transparency")

		# Method 2: Force canvas layer redraw by toggling UI layer visibility
		var ui_layer = get_node_or_null("UI")
		if ui_layer and ui_layer is CanvasLayer:
			ui_layer.visible = false
			ui_layer.visible = true
			print("[Wasteland]   Toggled UI CanvasLayer visibility")

		print("[Wasteland] ✓ Viewport refresh complete")
	else:
		print("[Wasteland]   WARNING: No viewport found!")


func _on_player_damaged(_current_hp: float, _max_hp: float) -> void:
	"""Handle player taking damage - trigger screen shake"""
	screen_shake(5.0, 0.2)


func _on_enemy_died_screen_shake(_enemy_id: String) -> void:
	"""Handle enemy death - trigger small screen shake"""
	screen_shake(2.0, 0.1)


func _process(delta: float) -> void:
	"""Handle per-frame animations and monitoring (2025-11-15)"""

	# Screen flash animation (manual, since Tweens don't work on iOS)
	var ui_layer = $UI
	var flash_overlay = ui_layer.get_node_or_null("FlashOverlay")

	if (
		flash_overlay
		and flash_overlay.has_meta("flash_active")
		and flash_overlay.get_meta("flash_active")
	):
		var flash_time = flash_overlay.get_meta("flash_time")
		var flash_duration = flash_overlay.get_meta("flash_duration")

		flash_time += delta
		flash_overlay.set_meta("flash_time", flash_time)

		if flash_time >= flash_duration:
			# Animation complete, hide flash
			flash_overlay.color.a = 0.0
			flash_overlay.set_meta("flash_active", false)
		else:
			# Fade out: 0.5 → 0.0 over duration
			var t = flash_time / flash_duration
			flash_overlay.color.a = lerp(0.5, 0.0, t)

	# Label pool monitoring (DISABLED - no longer using text overlays, 2025-11-15)
	# label_monitor_timer += delta
	# if label_monitor_timer >= LABEL_MONITOR_INTERVAL:
	# 	label_monitor_timer = 0.0
	# 	if label_pool and label_pool.active_labels.size() > 0:
	# 		print("[LabelMonitor] Active labels: ", label_pool.active_labels.size())
	# 		for label in label_pool.active_labels:
	# 			if is_instance_valid(label):
	# 				print("[LabelMonitor]   Label ID: %d, text: '%s', modulate.a: %.3f, visible: %s"
	# 					% [label.get_instance_id(), label.text, label.modulate.a, label.visible])
	# 			else:
	# 				print("[LabelMonitor]   WARNING: Invalid label in active pool!")


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


func _add_debug_weapon_switcher() -> void:
	"""Add debug weapon switcher UI for iOS testing (Week 14 Phase 1.0)

	TEMPORARY: This is for testing weapon sounds on iOS.
	Remove before production release.

	Platform detection:
	- iOS: Always enabled
	- Desktop: Enable for testing by setting DEBUG_WEAPON_SWITCHER=true
	"""
	var enable_switcher = false

	# Check platform
	if OS.get_name() == "iOS":
		enable_switcher = true
		print("[Wasteland] iOS detected - enabling weapon switcher")
	elif OS.has_environment("DEBUG_WEAPON_SWITCHER"):
		# Desktop testing: Set environment variable to enable
		enable_switcher = true
		print("[Wasteland] DEBUG_WEAPON_SWITCHER enabled - weapon switcher active")

	if enable_switcher:
		var weapon_switcher = preload("res://scenes/ui/debug_weapon_switcher.tscn").instantiate()
		$UI.add_child(weapon_switcher)
		print("[Wasteland] Debug weapon switcher added to UI")
	else:
		print("[Wasteland] Debug weapon switcher NOT enabled (iOS-only or DEBUG_WEAPON_SWITCHER)")
