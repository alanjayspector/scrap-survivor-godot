extends GutTest
## VirtualJoystick Unit Tests
##
## USER_STORY: US-MOBILE-INPUT-001
## As a mobile player, I want responsive and accurate touch controls
## so I can move my character smoothly during combat
##
## Critical functionality - ensures joystick touch detection, dead zone,
## and floating positioning work correctly across all screen areas
##
## Regression tests for:
## - 150x150px rect bug (full-screen anchors required)
## - Round 4 dead zone "stuck" feeling (one-time threshold gate)

const VirtualJoystick = preload("res://scenes/ui/virtual_joystick.tscn")

var joystick: Control


func before_each() -> void:
	"""Set up test fixtures before each test"""
	joystick = VirtualJoystick.instantiate()
	add_child_autofree(joystick)
	await wait_frames(2)  # Wait for _ready() to complete


## ============================================================================
## SECTION 1: Scene Configuration Tests (Regression: 150x150px bug)
## ============================================================================


func test_virtual_joystick_has_full_screen_anchors() -> void:
	"""
	Regression test for 150x150px bug

	Root Cause: VirtualJoystick Control was only 150x150px, preventing touch
	input outside that tiny area. Control nodes only receive input within their rect.

	Fix: Full-screen anchors (anchor_right=1.0, anchor_bottom=1.0)
	"""
	assert_eq(joystick.anchor_right, 1.0, "Right anchor should be 1.0 (full screen)")
	assert_eq(joystick.anchor_bottom, 1.0, "Bottom anchor should be 1.0 (full screen)")
	assert_eq(joystick.anchor_left, 0.0, "Left anchor should be 0.0")
	assert_eq(joystick.anchor_top, 0.0, "Top anchor should be 0.0")


func test_virtual_joystick_has_correct_mouse_filter() -> void:
	"""Verify mouse_filter is IGNORE so it doesn't block other UI"""
	assert_eq(
		joystick.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"Should use MOUSE_FILTER_IGNORE (value 2) to not block UI"
	)


func test_virtual_joystick_control_rect_covers_viewport() -> void:
	"""
	Verify Control rect is large enough to receive touch input

	This test would have caught the 150x150px bug - Control rect must be
	at least as large as viewport to capture touches anywhere on screen
	"""
	var viewport_size = joystick.get_viewport_rect().size
	var control_rect = joystick.get_rect()

	# Control rect should be at least as large as viewport
	assert_gte(
		control_rect.size.x, viewport_size.x, "Control width must cover viewport for touch input"
	)
	assert_gte(
		control_rect.size.y, viewport_size.y, "Control height must cover viewport for touch input"
	)


func test_virtual_joystick_initially_hidden() -> void:
	"""Verify joystick base and stick are hidden until touch"""
	assert_false(joystick.base.visible, "Base should be hidden initially")
	assert_false(joystick.stick.visible, "Stick should be hidden initially")


## ============================================================================
## SECTION 2: Touch Zone Detection Tests (Left half filtering)
## ============================================================================


func test_touch_zone_is_left_half_of_screen() -> void:
	"""Verify touch zone covers exactly left half of viewport"""
	var viewport_size = joystick.get_viewport_rect().size
	var expected_zone = Rect2(0, 0, viewport_size.x / 2, viewport_size.y)

	assert_eq(joystick.touch_zone_rect, expected_zone, "Touch zone should be left half of screen")


func test_left_half_touch_activates_joystick() -> void:
	"""Verify touches in left half activate joystick"""
	var viewport_size = joystick.get_viewport_rect().size
	var left_touch = InputEventScreenTouch.new()
	left_touch.pressed = true
	left_touch.index = 0
	left_touch.position = Vector2(viewport_size.x / 4, viewport_size.y / 2)  # Left quarter

	joystick._handle_touch(left_touch)

	assert_true(joystick.is_pressed, "Left half touch should activate joystick")
	assert_eq(joystick.state, joystick.JoystickState.ACTIVE, "State should be ACTIVE")
	assert_true(joystick.base.visible, "Base should be visible after activation")
	assert_true(joystick.stick.visible, "Stick should be visible after activation")


func test_right_half_touch_is_rejected() -> void:
	"""Verify touches in right half are ignored (reserved for UI buttons)"""
	var viewport_size = joystick.get_viewport_rect().size
	var right_touch = InputEventScreenTouch.new()
	right_touch.pressed = true
	right_touch.index = 0
	right_touch.position = Vector2(viewport_size.x * 0.75, viewport_size.y / 2)  # Right quarter

	joystick._handle_touch(right_touch)

	assert_false(joystick.is_pressed, "Right half touch should be rejected")
	assert_eq(joystick.state, joystick.JoystickState.INACTIVE, "State should remain INACTIVE")
	assert_false(joystick.base.visible, "Base should remain hidden")


func test_touch_at_exact_boundary_left_side() -> void:
	"""Test boundary condition: touch exactly at middle of screen (left edge of right half)"""
	var viewport_size = joystick.get_viewport_rect().size
	var boundary_touch = InputEventScreenTouch.new()
	boundary_touch.pressed = true
	boundary_touch.index = 0
	boundary_touch.position = Vector2(viewport_size.x / 2 - 1, viewport_size.y / 2)  # 1px left of boundary

	joystick._handle_touch(boundary_touch)

	assert_true(joystick.is_pressed, "Touch 1px left of boundary should activate")


func test_touch_at_exact_boundary_right_side() -> void:
	"""Test boundary condition: touch exactly at middle of screen (right half)"""
	var viewport_size = joystick.get_viewport_rect().size
	var boundary_touch = InputEventScreenTouch.new()
	boundary_touch.pressed = true
	boundary_touch.index = 0
	boundary_touch.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)  # Exactly at boundary

	joystick._handle_touch(boundary_touch)

	assert_false(joystick.is_pressed, "Touch at boundary should be rejected (right half)")


## ============================================================================
## SECTION 3: Dead Zone Behavior Tests (One-time threshold gate)
## ============================================================================


func test_dead_zone_prevents_small_movements() -> void:
	"""
	Verify dead zone (12px) prevents accidental tap-movement

	User must drag >12px before player starts moving. This prevents
	accidental movement from small finger movements or taps.
	"""
	_activate_joystick_at(Vector2(100, 100))

	# Drag within dead zone (< 12px)
	var small_offset = Vector2(8, 8)  # ~11.3px diagonal
	joystick._update_stick_position_from_offset(small_offset)

	assert_eq(joystick.current_direction, Vector2.ZERO, "Should not move within dead zone")
	assert_false(joystick.has_crossed_dead_zone, "Dead zone should not be crossed yet")


func test_dead_zone_crossed_at_threshold() -> void:
	"""Verify dead zone is crossed when drag exceeds 12px"""
	_activate_joystick_at(Vector2(100, 100))

	# Drag beyond dead zone (> 12px)
	var large_offset = Vector2(15, 0)  # 15px horizontal
	joystick._update_stick_position_from_offset(large_offset)

	assert_ne(joystick.current_direction, Vector2.ZERO, "Should move beyond dead zone")
	assert_true(joystick.has_crossed_dead_zone, "Dead zone should be crossed")


func test_dead_zone_exactly_at_threshold() -> void:
	"""Test boundary condition: exactly 12px should cross threshold"""
	_activate_joystick_at(Vector2(100, 100))

	# Exactly at threshold
	var threshold_offset = Vector2(12.1, 0)  # Just over 12px
	joystick._update_stick_position_from_offset(threshold_offset)

	assert_ne(joystick.current_direction, Vector2.ZERO, "Should move at threshold")
	assert_true(joystick.has_crossed_dead_zone, "Dead zone should be crossed at threshold")


func test_dead_zone_does_not_reapply_during_drag() -> void:
	"""
	Regression test: Dead zone should only apply once per gesture (Round 4 fix)

	Root Cause: Dead zone was checked continuously during drag, creating
	circular "stop zone" in center. User felt "stuck" when finger drifted
	back toward origin during active drag.

	Fix: One-time threshold gate - dead zone only checked once at gesture start
	"""
	_activate_joystick_at(Vector2(100, 100))

	# Step 1: Cross dead zone
	joystick._update_stick_position_from_offset(Vector2(20, 0))  # 20px - well beyond threshold
	assert_true(joystick.has_crossed_dead_zone, "Should have crossed dead zone")
	assert_ne(joystick.current_direction, Vector2.ZERO, "Should be moving")

	# Step 2: Move back INSIDE dead zone radius (this was the bug)
	joystick._update_stick_position_from_offset(Vector2(5, 0))  # 5px - within dead zone

	# Should STILL emit direction (dead zone doesn't reapply)
	assert_ne(joystick.current_direction, Vector2.ZERO, "Should continue moving (no stuck feeling)")
	assert_almost_eq(
		joystick.current_direction,
		Vector2(1, 0),
		Vector2(0.01, 0.01),
		"Direction should still be right"
	)


func test_dead_zone_resets_on_touch_release() -> void:
	"""Verify dead zone resets for next gesture when touch is released"""
	_activate_joystick_at(Vector2(100, 100))

	# Cross dead zone
	joystick._update_stick_position_from_offset(Vector2(20, 0))
	assert_true(joystick.has_crossed_dead_zone, "Dead zone should be crossed")

	# Release touch
	var release = InputEventScreenTouch.new()
	release.pressed = false
	release.index = joystick.touch_index
	release.position = Vector2(120, 100)
	joystick._handle_touch(release)

	# Dead zone should be reset for next gesture
	assert_false(joystick.has_crossed_dead_zone, "Dead zone should reset on release")
	assert_eq(joystick.state, joystick.JoystickState.INACTIVE, "State should be INACTIVE")


## ============================================================================
## SECTION 4: Floating Joystick Positioning Tests
## ============================================================================


func test_joystick_appears_at_touch_point() -> void:
	"""Verify floating joystick positions at touch location"""
	var touch_pos = Vector2(200, 300)
	var touch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 0
	touch.position = touch_pos

	joystick._handle_touch(touch)

	assert_eq(joystick.global_position, touch_pos, "Joystick should appear exactly at touch point")
	assert_eq(joystick.touch_origin, touch_pos, "Touch origin should be recorded")


func test_joystick_hides_on_release() -> void:
	"""Verify joystick disappears when touch is released"""
	_activate_joystick_at(Vector2(100, 100))

	# Release touch
	var release = InputEventScreenTouch.new()
	release.pressed = false
	release.index = joystick.touch_index
	release.position = Vector2(120, 100)
	joystick._handle_touch(release)

	assert_false(joystick.base.visible, "Base should be hidden after release")
	assert_false(joystick.stick.visible, "Stick should be hidden after release")
	assert_false(joystick.is_pressed, "is_pressed should be false")


func test_stick_position_updates_during_drag() -> void:
	"""Verify stick visual moves with finger position"""
	_activate_joystick_at(Vector2(100, 100))

	# Drag to create offset
	var offset = Vector2(30, 20)
	joystick._update_stick_position_from_offset(offset)

	assert_eq(joystick.stick.position, offset, "Stick should move to offset position")


func test_stick_clamped_to_max_distance() -> void:
	"""Verify stick doesn't move beyond max_distance (85px)"""
	_activate_joystick_at(Vector2(100, 100))

	# Drag beyond max distance
	var huge_offset = Vector2(150, 0)  # 150px - beyond 85px max
	joystick._update_stick_position_from_offset(huge_offset)

	# Stick should be clamped
	assert_lte(
		joystick.stick.position.length(),
		joystick.max_distance,
		"Stick should be clamped to max distance"
	)
	assert_almost_eq(
		joystick.stick.position.length(),
		joystick.max_distance,
		0.1,
		"Stick should be at max distance"
	)


## ============================================================================
## SECTION 5: Direction Calculation Tests
## ============================================================================


func test_direction_calculation_right() -> void:
	"""Verify right direction is calculated correctly"""
	_activate_joystick_at(Vector2(100, 100))

	joystick._update_stick_position_from_offset(Vector2(50, 0))  # Right

	assert_almost_eq(
		joystick.current_direction, Vector2(1, 0), Vector2(0.01, 0.01), "Should point right"
	)


func test_direction_calculation_down() -> void:
	"""Verify down direction is calculated correctly"""
	_activate_joystick_at(Vector2(100, 100))

	joystick._update_stick_position_from_offset(Vector2(0, 50))  # Down

	assert_almost_eq(
		joystick.current_direction, Vector2(0, 1), Vector2(0.01, 0.01), "Should point down"
	)


func test_direction_calculation_diagonal() -> void:
	"""Verify diagonal directions are normalized correctly"""
	_activate_joystick_at(Vector2(100, 100))

	joystick._update_stick_position_from_offset(Vector2(50, 50))  # Down-right diagonal

	# Direction should be normalized (length = 1.0)
	assert_almost_eq(
		joystick.current_direction.length(), 1.0, 0.01, "Diagonal direction should be normalized"
	)

	# Should be approximately 45 degrees (0.707, 0.707)
	var expected = Vector2(1, 1).normalized()
	assert_almost_eq(
		joystick.current_direction, expected, Vector2(0.01, 0.01), "Should point down-right at 45°"
	)


func test_direction_zero_at_origin() -> void:
	"""Verify direction is zero when stick returns to exact origin"""
	_activate_joystick_at(Vector2(100, 100))

	# Cross dead zone first
	joystick._update_stick_position_from_offset(Vector2(20, 0))
	assert_ne(joystick.current_direction, Vector2.ZERO, "Should be moving")

	# Return to exact origin (rare edge case)
	joystick._update_stick_position_from_offset(Vector2(0, 0))

	assert_eq(joystick.current_direction, Vector2.ZERO, "Direction should be zero at exact origin")


## ============================================================================
## SECTION 6: Multi-Touch Handling Tests
## ============================================================================


func test_ignores_second_touch_while_active() -> void:
	"""Verify joystick ignores second touch while already active"""
	_activate_joystick_at(Vector2(100, 100))
	var first_index = joystick.touch_index

	# Try to activate with second touch
	var second_touch = InputEventScreenTouch.new()
	second_touch.pressed = true
	second_touch.index = 1  # Different index
	second_touch.position = Vector2(200, 200)
	joystick._handle_touch(second_touch)

	# Should still be tracking first touch
	assert_eq(joystick.touch_index, first_index, "Should still track first touch")
	assert_ne(
		joystick.global_position, second_touch.position, "Should not move to second touch position"
	)


func test_tracks_correct_touch_index() -> void:
	"""Verify joystick tracks and responds only to its assigned touch index"""
	_activate_joystick_at(Vector2(100, 100))
	var correct_index = joystick.touch_index

	# Drag with correct index - should work
	var correct_drag = InputEventScreenDrag.new()
	correct_drag.index = correct_index
	correct_drag.position = Vector2(120, 100)
	joystick._handle_drag(correct_drag)

	var direction_after_correct = joystick.current_direction

	# Drag with wrong index - should be ignored
	var wrong_drag = InputEventScreenDrag.new()
	wrong_drag.index = correct_index + 1  # Different index
	wrong_drag.position = Vector2(100, 200)
	joystick._handle_drag(wrong_drag)

	# Direction should not change from wrong index drag
	assert_eq(
		joystick.current_direction,
		direction_after_correct,
		"Should ignore drag from different touch index"
	)


## ============================================================================
## SECTION 7: Signal Emission Tests
## ============================================================================


func test_direction_changed_signal_emitted() -> void:
	"""Verify direction_changed signal is emitted with correct value"""
	_activate_joystick_at(Vector2(100, 100))

	# Watch for signal
	watch_signals(joystick)

	# Cross dead zone to trigger direction change
	joystick._update_stick_position_from_offset(Vector2(20, 0))

	# Signal should have been emitted
	assert_signal_emitted(joystick, "direction_changed", "direction_changed should be emitted")


func test_direction_changed_signal_on_release() -> void:
	"""Verify direction_changed emits Vector2.ZERO on touch release"""
	# Track all emitted directions
	var emitted_directions: Array[Vector2] = []

	# Connect to signal BEFORE activation to capture all emissions
	joystick.direction_changed.connect(func(dir): emitted_directions.append(dir))

	# Activate and move
	_activate_joystick_at(Vector2(100, 100))
	joystick._update_stick_position_from_offset(Vector2(20, 0))  # Move

	# Release touch
	var release = InputEventScreenTouch.new()
	release.pressed = false
	release.index = joystick.touch_index
	release.position = Vector2(120, 100)
	joystick._handle_touch(release)

	# Should have emitted multiple directions, with final one being ZERO
	assert_gt(emitted_directions.size(), 0, "Should have emitted at least one direction")
	var last_direction = emitted_directions[emitted_directions.size() - 1]
	assert_eq(last_direction, Vector2.ZERO, "Final direction on release should be ZERO")


## ============================================================================
## Helper Functions
## ============================================================================


func _activate_joystick_at(position: Vector2) -> void:
	"""Helper: Activate joystick at given position"""
	var touch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 0
	touch.position = position
	joystick._handle_touch(touch)
