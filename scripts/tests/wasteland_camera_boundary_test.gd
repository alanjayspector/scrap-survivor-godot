extends GutTest
class_name WastelandCameraBoundaryTest
## Wasteland Camera Boundary Integration Tests
##
## USER STORY: "As a player, I want the camera to stay within the game world
## boundaries so that I don't see empty void beyond the playable area"
##
## USER_STORY: US-MOBILE-UX-QA-004
##
## Critical functionality - ensures camera never shows off-canvas areas
## Regression test for mobile UX QA Round 4 Follow-Up #4

var wasteland_scene: Node2D
var camera: CameraController
var player: Player
var test_character_id: String = ""

const WASTELAND_SCENE = preload("res://scenes/game/wasteland.tscn")

## World boundaries from wasteland.tscn and camera_controller.gd
## Week 13 Phase 1: Reduced from 4000x4000 to 2000x2000 for better combat density
const WORLD_BOUNDS: Rect2 = Rect2(-1000, -1000, 2000, 2000)
const PLAYER_BOUNDS_MARGIN: float = 100.0  # Player stops 100px from world edge

## Viewport calculations (from project.godot and wasteland.tscn)
## Viewport: 1920x1080 pixels, Camera zoom: 1.5x
## Visible world area: 1280x720 units (1920/1.5 x 1080/1.5)
const VIEWPORT_SIZE: Vector2 = Vector2(1920, 1080)
const CAMERA_ZOOM: float = 1.5
const VISIBLE_WORLD_AREA: Vector2 = VIEWPORT_SIZE / CAMERA_ZOOM  # 1280x720

## Camera boundaries (adjusted for viewport to prevent off-canvas visibility)
## Camera must stay within bounds such that visible area never exceeds world bounds
## Camera X: -1000 + 640 to +1000 - 640 = [-360, +360]
## Camera Y: -1000 + 360 to +1000 - 360 = [-640, +640]
const CAMERA_BOUNDS: Rect2 = Rect2(-360, -640, 720, 1280)


func before_each() -> void:
	"""Set up test fixtures before each test"""
	# Create test character
	test_character_id = CharacterService.create_character("TestChar", "scavenger")
	CharacterService.set_active_character(test_character_id)

	# Load wasteland scene
	wasteland_scene = WASTELAND_SCENE.instantiate()
	add_child_autofree(wasteland_scene)

	# Get camera reference
	camera = wasteland_scene.get_node("Camera2D") as CameraController
	assert_not_null(camera, "Camera should exist in wasteland scene")
	assert_true(camera is CameraController, "Camera should be CameraController type")

	# Wait for scene to initialize
	await wait_frames(2)


func after_each() -> void:
	"""Clean up after each test"""
	# Scene cleanup handled by add_child_autofree
	CharacterService.delete_character(test_character_id)


## ============================================================================
## SECTION 1: Wasteland Scene Camera Configuration Tests
## ============================================================================


func test_wasteland_camera_has_camera_controller_script() -> void:
	"""Verify wasteland.tscn Camera2D has CameraController script attached"""
	assert_not_null(camera, "Camera should exist in wasteland scene")
	assert_true(
		camera is CameraController, "Camera should be CameraController class (script attached)"
	)


func test_wasteland_camera_has_correct_boundaries() -> void:
	"""Verify camera boundaries are adjusted for viewport size to prevent off-canvas visibility"""
	assert_eq(
		camera.boundaries,
		CAMERA_BOUNDS,
		"Camera boundaries should be Rect2(-360, -640, 720, 1280) (accounts for viewport)"
	)


func test_wasteland_camera_has_follow_smoothness() -> void:
	"""Verify camera has smooth follow enabled"""
	assert_gt(camera.follow_smoothness, 0.0, "Camera should have follow_smoothness > 0")
	assert_eq(camera.follow_smoothness, 5.0, "Camera follow_smoothness should be 5.0")


func test_camera_built_in_smoothing_disabled() -> void:
	"""Regression guard: Built-in Camera2D smoothing must be disabled to prevent double-smoothing

	ISSUE: Week 15 Phase 4 camera jump bug - double smoothing conflict
	- Custom lerp in CameraController._process() provides boundary-aware smoothing
	- Camera2D position_smoothing_enabled creates second smoothing layer
	- Result: Visual position (smoothed_camera_pos) != node position (global_position)
	- This causes visual camera jump on spawn despite correct logged positions

	FIX: Disable built-in smoothing, use only custom lerp (Option B from expert panel)
	"""
	assert_false(
		camera.position_smoothing_enabled,
		"Camera2D built-in smoothing MUST be disabled - we use custom lerp for boundary clamping"
	)


func test_camera_starts_disabled() -> void:
	"""Regression guard: Camera must start disabled, spawn code enables it

	ISSUE: Camera enabled=true from scene start caused jump (QA log showed enabled=true pre-spawn)
	FIX: Explicit enabled=false in wasteland.tscn, spawn code sets enabled=true after positioning

	NOTE: This test loads wasteland scene WITHOUT an active character to test initial camera state
	"""
	# Delete test character and reset services so wasteland._ready() doesn't spawn player
	CharacterService.delete_character(test_character_id)
	CharacterService.reset()  # This clears active_character_id

	# Load fresh wasteland scene
	var fresh_wasteland = WASTELAND_SCENE.instantiate()
	add_child_autofree(fresh_wasteland)

	# Get camera before player spawn
	var fresh_camera = fresh_wasteland.get_node("Camera2D") as CameraController

	# Wait for scene _ready() but without active character, camera should stay disabled
	await wait_frames(2)

	assert_false(
		fresh_camera.enabled,
		"Camera should start disabled in scene, spawn code enables it after positioning"
	)


## ============================================================================
## SECTION 2: Camera Boundary Clamping Tests
## ============================================================================


func test_camera_clamps_to_left_boundary() -> void:
	"""Verify camera cannot show beyond left world boundary (-1000)"""
	# Arrange - create mock player at far left edge
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(-900, 0)  # Player at left edge

	camera.target = mock_player

	# Act - process camera multiple times to ensure smooth follow completes (lerp takes time)
	for i in range(100):
		camera._process(0.016)

	# Assert - camera should be clamped to left camera boundary
	assert_gte(
		camera.global_position.x,
		CAMERA_BOUNDS.position.x,
		"Camera X should not go below left camera boundary (-360)"
	)


func test_camera_clamps_to_right_boundary() -> void:
	"""Verify camera cannot show beyond right world boundary (+1000)"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(900, 0)  # Player at right edge

	camera.target = mock_player

	# Act - process camera multiple times to ensure smooth follow completes
	for i in range(100):
		camera._process(0.016)

	# Assert - camera should be clamped to right camera boundary
	assert_lte(
		camera.global_position.x,
		CAMERA_BOUNDS.position.x + CAMERA_BOUNDS.size.x,
		"Camera X should not exceed right camera boundary (+360)"
	)


func test_camera_clamps_to_top_boundary() -> void:
	"""Verify camera cannot show beyond top world boundary (-1000)"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(0, -900)  # Player at top edge

	camera.target = mock_player

	# Act - process camera multiple times to ensure smooth follow completes
	for i in range(100):
		camera._process(0.016)

	# Assert - camera should be clamped to top camera boundary
	assert_gte(
		camera.global_position.y,
		CAMERA_BOUNDS.position.y,
		"Camera Y should not go below top camera boundary (-640)"
	)


func test_camera_clamps_to_bottom_boundary() -> void:
	"""Verify camera cannot show beyond bottom world boundary (+1000)"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(0, 900)  # Player at bottom edge

	camera.target = mock_player

	# Act - process camera multiple times to ensure smooth follow completes
	for i in range(100):
		camera._process(0.016)

	# Assert - camera should be clamped to bottom camera boundary
	assert_lte(
		camera.global_position.y,
		CAMERA_BOUNDS.position.y + CAMERA_BOUNDS.size.y,
		"Camera Y should not exceed bottom camera boundary (+640)"
	)


## ============================================================================
## SECTION 3: Visible Viewport Tests (Regression Test for Bug)
## ============================================================================


func test_camera_visible_area_stays_within_boundaries_left_edge() -> void:
	"""
	Verify camera doesn't show void beyond left boundary

	Root Cause (Bug): When player at -900, camera centered there shows down to
	-1540 (540 units beyond -1000 boundary). This is the actual bug we fixed.

	Math: Visible area width = 1280 units, half = 640 units
	Camera at -900: left edge visible = -900 - 640 = -1540 ❌
	Camera should clamp so: left edge visible >= -1000 ✅
	"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(-900, 0)

	camera.target = mock_player

	# Act - let camera follow and clamp (process many frames for lerp to complete)
	for i in range(100):
		camera._process(0.016)

	# Assert - calculate left edge of visible area
	var half_visible_width = VISIBLE_WORLD_AREA.x / 2.0  # 640 units
	var left_edge_visible = camera.global_position.x - half_visible_width

	assert_gte(
		left_edge_visible,
		WORLD_BOUNDS.position.x,
		"Left edge of visible area should not extend beyond boundary (-1000)"
	)

	# Verify the fix prevents the 540-unit overshoot
	var overshoot = WORLD_BOUNDS.position.x - left_edge_visible
	assert_lte(
		abs(overshoot), 1.0, "Camera should not overshoot boundary (was 540 units before fix)"
	)


func test_camera_visible_area_stays_within_boundaries_right_edge() -> void:
	"""Verify camera doesn't show void beyond right boundary"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(900, 0)

	camera.target = mock_player

	# Act - let camera follow and clamp (process many frames for lerp to complete)
	for i in range(100):
		camera._process(0.016)

	# Assert
	var half_visible_width = VISIBLE_WORLD_AREA.x / 2.0
	var right_edge_visible = camera.global_position.x + half_visible_width

	assert_lte(
		right_edge_visible,
		WORLD_BOUNDS.position.x + WORLD_BOUNDS.size.x,
		"Right edge of visible area should not extend beyond boundary (+1000)"
	)


func test_camera_visible_area_stays_within_boundaries_top_edge() -> void:
	"""Verify camera doesn't show void beyond top boundary"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(0, -900)

	camera.target = mock_player

	# Act - let camera follow and clamp (process many frames for lerp to complete)
	for i in range(100):
		camera._process(0.016)

	# Assert
	var half_visible_height = VISIBLE_WORLD_AREA.y / 2.0  # 360 units
	var top_edge_visible = camera.global_position.y - half_visible_height

	assert_gte(
		top_edge_visible,
		WORLD_BOUNDS.position.y,
		"Top edge of visible area should not extend beyond boundary (-1000)"
	)


func test_camera_visible_area_stays_within_boundaries_bottom_edge() -> void:
	"""Verify camera doesn't show void beyond bottom boundary"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2(0, 900)

	camera.target = mock_player

	# Act - let camera follow and clamp (process many frames for lerp to complete)
	for i in range(100):
		camera._process(0.016)

	# Assert
	var half_visible_height = VISIBLE_WORLD_AREA.y / 2.0
	var bottom_edge_visible = camera.global_position.y + half_visible_height

	assert_lte(
		bottom_edge_visible,
		WORLD_BOUNDS.position.y + WORLD_BOUNDS.size.y,
		"Bottom edge of visible area should not extend beyond boundary (+1000)"
	)


## ============================================================================
## SECTION 4: Camera + Player Integration Tests
## ============================================================================


func test_camera_follows_player_smoothly() -> void:
	"""Verify camera smoothly follows player movement"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2.ZERO

	camera.target = mock_player
	camera.global_position = Vector2.ZERO

	# Act - move player and process camera
	mock_player.global_position = Vector2(100, 100)
	camera._process(0.016)

	# Assert - camera should move toward player (smooth follow, not instant)
	var distance_to_player = camera.global_position.distance_to(mock_player.global_position)
	assert_gt(distance_to_player, 0.0, "Camera should not instantly teleport to player")
	assert_lt(
		distance_to_player, 142.0, "Camera should be moving toward player (< 141.4 = full distance)"
	)


func test_camera_and_player_boundaries_work_together() -> void:
	"""
	Verify camera boundaries and player boundaries work together correctly

	Player stops at ±900 (100px margin from world edge)
	Camera clamps to ±1000 (world boundary)
	Result: Player always visible, no off-canvas movement
	"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)

	# Position player at maximum allowed position (accounting for margin)
	var max_player_x = (WORLD_BOUNDS.position.x + WORLD_BOUNDS.size.x) - PLAYER_BOUNDS_MARGIN
	mock_player.global_position = Vector2(max_player_x, 0)  # 900

	camera.target = mock_player

	# Act - let camera follow (process many frames for lerp to complete)
	for i in range(100):
		camera._process(0.016)

	# Assert - calculate if player would be visible
	var half_visible_width = VISIBLE_WORLD_AREA.x / 2.0
	var left_edge_visible = camera.global_position.x - half_visible_width
	var right_edge_visible = camera.global_position.x + half_visible_width

	# Player should be well within visible area
	assert_gte(
		mock_player.global_position.x,
		left_edge_visible,
		"Player should be visible (not off left edge)"
	)
	assert_lte(
		mock_player.global_position.x,
		right_edge_visible,
		"Player should be visible (not off right edge)"
	)


## ============================================================================
## SECTION 5: Regression Tests (Preserve Existing Functionality)
## ============================================================================


func test_camera_screen_shake_still_works() -> void:
	"""Verify screen shake functionality preserved after boundary fix"""
	# Arrange
	camera.shake_amount = 0.0

	# Act
	camera.trigger_shake(10.0)

	# Assert
	assert_eq(camera.shake_amount, 10.0, "Shake amount should be set")

	# Process to apply shake
	camera._process(0.016)

	# Camera offset should be non-zero (shake applied)
	assert_gt(camera.offset.length(), 0.0, "Camera offset should have shake applied")


func test_camera_smooth_follow_preserved() -> void:
	"""Verify smooth follow still works after boundary fix"""
	# Arrange
	var mock_player = Node2D.new()
	add_child_autofree(mock_player)
	mock_player.global_position = Vector2.ZERO
	camera.target = mock_player
	camera.global_position = Vector2.ZERO

	# Act - move player far away
	mock_player.global_position = Vector2(500, 500)

	# Process once
	camera._process(0.016)
	var distance_after_one_frame = camera.global_position.distance_to(mock_player.global_position)

	# Process again
	camera._process(0.016)
	var distance_after_two_frames = camera.global_position.distance_to(mock_player.global_position)

	# Assert - distance should decrease (camera moving toward player)
	assert_lt(
		distance_after_two_frames,
		distance_after_one_frame,
		"Camera should continuously move toward player (smooth follow)"
	)
