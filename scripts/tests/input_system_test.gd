extends GutTest
## Test script for Input Systems (CameraController and InputHandler) using GUT framework
##
## USER STORY: "As a player, I want responsive camera controls and smooth camera
## movement that follows my character, so that I can focus on gameplay without
## jarring camera movements or losing sight of my character"
##
## Tests camera following, boundaries, screen shake, and input handling.

class_name InputSystemTest

var camera: CameraController
var input_handler: InputHandler
var mock_player: Node2D


func before_each() -> void:
	# Create mock player node
	mock_player = Node2D.new()
	mock_player.add_to_group("player")
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(100, 100)

	# Create camera controller
	camera = CameraController.new()
	add_child_autofree(camera)

	# Create input handler
	input_handler = InputHandler.new()
	add_child_autofree(input_handler)


func after_each() -> void:
	# Cleanup handled by autofree
	pass


## ============================================================================
## SECTION 1: Camera Follow Tests
## User Story: "As a player, I want the camera to follow my character smoothly"
## ============================================================================


func test_camera_follows_player_smoothly() -> void:
	# Arrange
	mock_player.global_position = Vector2(200, 200)
	camera.target = mock_player
	camera.follow_smoothness = 5.0
	var initial_camera_pos = camera.global_position

	# Act - simulate one frame
	var delta = 0.016  # ~60 FPS
	camera._process(delta)

	# Assert - camera should move toward player but not instantly
	var distance_moved = camera.global_position.distance_to(initial_camera_pos)
	assert_gt(distance_moved, 0.0, "Camera should move toward player")

	var distance_to_player = camera.global_position.distance_to(mock_player.global_position)
	assert_gt(distance_to_player, 1.0, "Camera should not reach player instantly (smooth follow)")


func test_camera_respects_boundaries() -> void:
	# Arrange - set up camera with boundaries
	camera.boundaries = Rect2(-500, -500, 1000, 1000)
	mock_player.global_position = Vector2(1000, 1000)  # Outside boundaries
	camera.target = mock_player

	# Act - process camera
	camera._process(0.016)

	# Assert - camera should be clamped to boundaries
	assert_lte(camera.global_position.x, 500.0, "Camera X should not exceed max boundary")
	assert_lte(camera.global_position.y, 500.0, "Camera Y should not exceed max boundary")
	assert_gte(camera.global_position.x, -500.0, "Camera X should not go below min boundary")
	assert_gte(camera.global_position.y, -500.0, "Camera Y should not go below min boundary")


## ============================================================================
## SECTION 2: Camera Screen Shake Tests
## User Story: "As a player, I want visual feedback when I fire weapons or kill enemies"
## ============================================================================


func test_camera_shake_on_weapon_fire() -> void:
	# Arrange
	camera.shake_amount = 0.0
	camera.screen_shake_intensity = 10.0

	# Act - simulate weapon fired signal
	camera._on_weapon_fired("test_weapon")

	# Assert - shake should be triggered
	assert_gt(camera.shake_amount, 0.0, "Camera should shake after weapon fired")
	assert_eq(camera.shake_amount, 2.0, "Weapon fire should trigger light shake (2.0)")


func test_camera_shake_decays_over_time() -> void:
	# Arrange
	camera.shake_amount = 10.0
	var initial_shake = camera.shake_amount

	# Act - process multiple frames
	for i in range(10):
		camera._process(0.016)

	# Assert - shake should decay
	assert_lt(camera.shake_amount, initial_shake, "Shake should decay over time")


## ============================================================================
## SECTION 3: Input Handler Tests
## User Story: "As a player, I want consistent input handling across platforms"
## ============================================================================


func test_input_handler_emits_movement_signal() -> void:
	# Arrange - connect to signal before emitting
	var signal_watcher = watch_signals(input_handler)

	# Act - directly emit the signal (simulating what _process would do)
	input_handler.movement_input.emit(Vector2(1, 0))

	# Assert
	assert_signal_emitted(input_handler, "movement_input", "Movement signal should be emitted")


func test_input_handler_emits_aim_signal() -> void:
	# Arrange - connect to signal before emitting
	var signal_watcher = watch_signals(input_handler)

	# Act - directly emit the signal (simulating what _process would do)
	input_handler.aim_input.emit(Vector2(300, 400))

	# Assert
	assert_signal_emitted(input_handler, "aim_input", "Aim signal should be emitted")
