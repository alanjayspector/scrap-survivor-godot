extends Node2D
## Gameplay Demo Scene
##
## Demonstrates the character system working end-to-end:
## - Character loaded from CharacterService
## - Stats displayed and applied
## - Aura visual working
## - Movement with character speed stat

@onready var player: CharacterBody2D = $DemoPlayer
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	# Check if we have an active character
	var character_id = CharacterService.get_active_character_id()

	if character_id.is_empty():
		push_error("No active character! Please select a character first.")
		# Go back to character selection
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
		return

	GameLogger.info("Gameplay demo started", {"character_id": character_id})

	# Camera follows player
	camera.position = player.position


func _physics_process(_delta: float) -> void:
	# Camera follows player
	if player:
		camera.position = player.position


func _input(event: InputEvent) -> void:
	# Return to character selection
	if event.is_action_pressed("ui_cancel"):  # ESC key
		get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _draw() -> void:
	# Draw a simple grid for visual reference
	_draw_grid()


func _draw_grid() -> void:
	"""Draw a simple grid for visual reference"""
	var grid_size = 100
	var grid_color = Color(0.2, 0.2, 0.2, 0.3)
	var line_width = 1.0

	# Get camera viewport size
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.position if camera else Vector2.ZERO
	var camera_zoom = camera.zoom if camera else Vector2.ONE

	# Calculate visible area
	var half_size = (viewport_size / camera_zoom) / 2
	var start_x = int((camera_pos.x - half_size.x) / grid_size) * grid_size
	var end_x = int((camera_pos.x + half_size.x) / grid_size) * grid_size
	var start_y = int((camera_pos.y - half_size.y) / grid_size) * grid_size
	var end_y = int((camera_pos.y + half_size.y) / grid_size) * grid_size

	# Draw vertical lines
	for x in range(start_x, end_x + grid_size, grid_size):
		draw_line(
			Vector2(x, start_y - grid_size), Vector2(x, end_y + grid_size), grid_color, line_width
		)

	# Draw horizontal lines
	for y in range(start_y, end_y + grid_size, grid_size):
		draw_line(
			Vector2(start_x - grid_size, y), Vector2(end_x + grid_size, y), grid_color, line_width
		)

	# Draw origin cross
	draw_line(Vector2(-50, 0), Vector2(50, 0), Color(1, 0, 0, 0.5), 2.0)
	draw_line(Vector2(0, -50), Vector2(0, 50), Color(0, 1, 0, 0.5), 2.0)
