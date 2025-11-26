extends GutTest
## IconButton Component Tests
## Phase 8.2c - Art Bible Hub Transformation
##
## Tests the IconButton reusable component for:
## - Instantiation and setup
## - Size variants (Small, Medium, Large)
## - Style variants (Primary, Secondary, Danger)
## - Icon and label configuration
## - Touch target compliance (UIConstants)
## - Signal emission

const IconButtonScene = preload("res://scenes/ui/components/icon_button.tscn")

var _button: IconButton
var _test_texture: Texture2D


func before_each() -> void:
	# Create a simple test texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	_test_texture = ImageTexture.create_from_image(image)

	# Instantiate button
	_button = IconButtonScene.instantiate()
	add_child(_button)
	await get_tree().process_frame


func after_each() -> void:
	if _button and is_instance_valid(_button):
		_button.queue_free()
	_button = null
	_test_texture = null


# ==== INSTANTIATION TESTS ====


func test_instantiation_creates_valid_button() -> void:
	"""IconButton should instantiate without errors"""
	assert_not_null(_button, "Button should be instantiated")
	assert_true(_button is Button, "Should extend Button")
	assert_true(_button is IconButton, "Should be IconButton type")


func test_default_size_is_medium() -> void:
	"""Default button size should be MEDIUM (80pt)"""
	assert_eq(_button.button_size, IconButton.ButtonSize.MEDIUM)
	assert_eq(_button.custom_minimum_size.x, 80.0)
	assert_eq(_button.custom_minimum_size.y, 80.0)


func test_default_variant_is_primary() -> void:
	"""Default button variant should be PRIMARY"""
	assert_eq(_button.button_variant, IconButton.ButtonVariant.PRIMARY)


# ==== SIZE TESTS ====


func test_small_size_is_50pt() -> void:
	"""SMALL size should be 50x50 pixels"""
	_button.button_size = IconButton.ButtonSize.SMALL
	await get_tree().process_frame

	assert_eq(_button.custom_minimum_size.x, 50.0)
	assert_eq(_button.custom_minimum_size.y, 50.0)


func test_medium_size_is_80pt() -> void:
	"""MEDIUM size should be 80x80 pixels"""
	_button.button_size = IconButton.ButtonSize.MEDIUM
	await get_tree().process_frame

	assert_eq(_button.custom_minimum_size.x, 80.0)
	assert_eq(_button.custom_minimum_size.y, 80.0)


func test_large_size_is_120pt() -> void:
	"""LARGE size should be 120x120 pixels"""
	_button.button_size = IconButton.ButtonSize.LARGE
	await get_tree().process_frame

	assert_eq(_button.custom_minimum_size.x, 120.0)
	assert_eq(_button.custom_minimum_size.y, 120.0)


func test_all_sizes_meet_minimum_touch_target() -> void:
	"""All sizes should meet iOS HIG 44pt minimum touch target"""
	for size_enum in IconButton.ButtonSize.values():
		var size_px = IconButton.SIZE_VALUES[size_enum]
		assert_gte(
			size_px,
			UIConstants.TOUCH_TARGET_MIN,
			(
				"Size %s (%d) should meet minimum touch target (%d)"
				% [IconButton.ButtonSize.keys()[size_enum], size_px, UIConstants.TOUCH_TARGET_MIN]
			)
		)


# ==== ICON TESTS ====


func test_set_icon_texture() -> void:
	"""Setting icon_texture should update the icon display"""
	_button.icon_texture = _test_texture
	await get_tree().process_frame

	assert_eq(_button.icon_texture, _test_texture)
	# Icon rect should be visible
	var icon_rect = _button.get_node_or_null("ContentContainer/VBoxContainer/IconTexture")
	if icon_rect:
		assert_true(icon_rect.visible, "Icon should be visible when texture is set")


func test_null_icon_hides_icon_rect() -> void:
	"""Setting icon_texture to null should hide the icon"""
	_button.icon_texture = null
	await get_tree().process_frame

	var icon_rect = _button.get_node_or_null("ContentContainer/VBoxContainer/IconTexture")
	if icon_rect:
		assert_false(icon_rect.visible, "Icon should be hidden when texture is null")


# ==== LABEL TESTS ====


func test_empty_label_hides_label_node() -> void:
	"""Empty label_text should hide the label"""
	_button.label_text = ""
	await get_tree().process_frame

	var label = _button.get_node_or_null("ContentContainer/VBoxContainer/ButtonLabel")
	if label:
		assert_false(label.visible, "Label should be hidden when text is empty")


func test_set_label_shows_label_node() -> void:
	"""Setting label_text should show the label"""
	_button.label_text = "Test Label"
	await get_tree().process_frame

	var label = _button.get_node_or_null("ContentContainer/VBoxContainer/ButtonLabel")
	if label:
		assert_true(label.visible, "Label should be visible when text is set")
		assert_eq(label.text, "Test Label")


func test_label_widens_button() -> void:
	"""Adding a label should widen the button"""
	var original_width = _button.custom_minimum_size.x

	_button.label_text = "A Longer Label"
	await get_tree().process_frame

	assert_gte(
		_button.custom_minimum_size.x,
		original_width,
		"Button should be at least as wide with label"
	)


# ==== VARIANT TESTS ====


func test_primary_variant_uses_rust_orange() -> void:
	"""PRIMARY variant should use RUST_ORANGE background"""
	_button.button_variant = IconButton.ButtonVariant.PRIMARY
	await get_tree().process_frame

	var style = _button.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(style, "Should have normal style")
	if style:
		assert_eq(
			style.bg_color,
			GameColorPalette.RUST_ORANGE,
			"Primary should use RUST_ORANGE background"
		)


func test_secondary_variant_is_transparent() -> void:
	"""SECONDARY variant should have transparent/semi-transparent background"""
	_button.button_variant = IconButton.ButtonVariant.SECONDARY
	await get_tree().process_frame

	var style = _button.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(style, "Should have normal style")
	if style:
		assert_lt(style.bg_color.a, 1.0, "Secondary should have transparent background")


func test_danger_variant_uses_hazard_colors() -> void:
	"""DANGER variant should use hazard colors"""
	_button.button_variant = IconButton.ButtonVariant.DANGER
	await get_tree().process_frame

	var style = _button.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(style, "Should have normal style")
	if style:
		assert_eq(
			style.border_color,
			GameColorPalette.HAZARD_YELLOW,
			"Danger should use HAZARD_YELLOW border"
		)


# ==== SETUP API TESTS ====


func test_setup_method_configures_all_properties() -> void:
	"""setup() method should configure icon, label, size, and variant"""
	_button.setup(
		_test_texture, "Test Button", IconButton.ButtonSize.LARGE, IconButton.ButtonVariant.DANGER
	)
	await get_tree().process_frame

	assert_eq(_button.icon_texture, _test_texture)
	assert_eq(_button.label_text, "Test Button")
	assert_eq(_button.button_size, IconButton.ButtonSize.LARGE)
	assert_eq(_button.button_variant, IconButton.ButtonVariant.DANGER)


func test_setup_is_chainable() -> void:
	"""setup() should return self for chaining"""
	var result = _button.setup(_test_texture, "Test")
	assert_eq(result, _button, "setup() should return self")


func test_chainable_setters() -> void:
	"""Individual setters should be chainable"""
	var result = _button.set_icon(_test_texture).set_label("Test").set_button_size(
		IconButton.ButtonSize.SMALL
	)
	assert_eq(result, _button, "Setters should return self for chaining")
	assert_eq(_button.icon_texture, _test_texture)
	assert_eq(_button.label_text, "Test")
	assert_eq(_button.button_size, IconButton.ButtonSize.SMALL)


# ==== SIGNAL TESTS ====


func test_pressed_emits_icon_button_pressed_signal() -> void:
	"""Pressing button should emit icon_button_pressed signal"""
	# Use GUT's built-in signal watching
	watch_signals(_button)

	# Simulate press by calling IconButton's _on_pressed handler directly
	_button._on_pressed()
	await get_tree().process_frame

	assert_signal_emitted(_button, "icon_button_pressed")


# ==== SHADOW TESTS ====


func test_shadow_visible_by_default() -> void:
	"""Drop shadow should be visible by default"""
	assert_true(_button.show_shadow, "Shadow should be enabled by default")

	var shadow = _button.get_node_or_null("ShadowPanel")
	if shadow:
		assert_true(shadow.visible, "Shadow panel should be visible")


func test_disable_shadow() -> void:
	"""Setting show_shadow to false should hide shadow"""
	_button.show_shadow = false
	await get_tree().process_frame

	var shadow = _button.get_node_or_null("ShadowPanel")
	if shadow:
		assert_false(shadow.visible, "Shadow panel should be hidden")


# ==== BUTTON ANIMATION TESTS ====


func test_button_animation_child_exists() -> void:
	"""ButtonAnimation child should exist when animate_press is true"""
	assert_true(_button.animate_press, "animate_press should be true by default")

	var anim = _button.get_node_or_null("ButtonAnimation")
	assert_not_null(anim, "ButtonAnimation child should exist")
	if anim:
		assert_true(anim is ButtonAnimation, "Should be ButtonAnimation type")


# ==== ACCESSIBILITY TESTS ====


func test_focus_mode_is_set() -> void:
	"""Button should have proper focus mode for controller support"""
	assert_eq(
		_button.focus_mode,
		Control.FOCUS_ALL,
		"Focus mode should be FOCUS_ALL for controller support"
	)


func test_disabled_state_styling() -> void:
	"""Disabled button should have distinct styling"""
	_button.disabled = true
	await get_tree().process_frame

	var style = _button.get_theme_stylebox("disabled") as StyleBoxFlat
	assert_not_null(style, "Should have disabled style")
