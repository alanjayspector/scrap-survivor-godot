class_name IconButton
extends Button
## IconButton - Reusable icon button component with Art Bible styling
##
## A versatile button component supporting:
## - Icon-only or Icon + Label layouts
## - Three variants: Primary, Secondary, Danger
## - Three sizes: Small (50pt), Medium (80pt), Large (120pt)
## - Art Bible styling (weathered metal plate aesthetic)
## - Mobile-first design with proper touch targets
##
## Usage:
##   var btn = preload("res://scenes/ui/components/icon_button.tscn").instantiate()
##   parent.add_child(btn)
##   btn.setup(preload("res://assets/icons/hub/icon_start_run_final.svg"), "Start Run")
##   btn.pressed.connect(_on_start_pressed)
##
## Or configure in editor via @export properties.

## Emitted when button is pressed (same as built-in pressed signal)
signal icon_button_pressed

## Button size presets matching UIConstants touch targets
enum ButtonSize {
	SMALL,  # 50pt - Settings, utility actions
	MEDIUM,  # 80pt - Secondary actions (Roster)
	LARGE,  # 120pt - Primary actions (Start Run)
}

## Button style variants matching Art Bible
enum ButtonVariant {
	PRIMARY,  # Orange metal plate - main actions
	SECONDARY,  # Outlined/hollow - secondary actions
	DANGER,  # Red/hazard - destructive actions
}

## Size in pixels for each ButtonSize
const SIZE_VALUES: Dictionary = {
	ButtonSize.SMALL: 50,
	ButtonSize.MEDIUM: 80,
	ButtonSize.LARGE: 120,
}

## Icon scale relative to button size (icon takes 60% of button)
const ICON_SCALE: float = 0.6

## Spacing between icon and label
const ICON_LABEL_SPACING: int = 8

# ==== EXPORTS ====

## The icon texture to display
@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_icon()

## Optional label text (empty = icon only)
@export var label_text: String = "":
	set(value):
		label_text = value
		_update_label()

## Button size preset
@export var button_size: ButtonSize = ButtonSize.MEDIUM:
	set(value):
		button_size = value
		_update_size()

## Button style variant
@export var button_variant: ButtonVariant = ButtonVariant.PRIMARY:
	set(value):
		button_variant = value
		_update_style()

## Whether to show drop shadow
@export var show_shadow: bool = true:
	set(value):
		show_shadow = value
		_update_shadow()

## Enable press animation (uses ButtonAnimation component)
@export var animate_press: bool = true

# ==== NODE REFERENCES ====
# Using explicit node caching pattern for performance

var _icon_rect: TextureRect
var _label_node: Label
var _shadow_panel: Panel
var _content_container: CenterContainer
var _button_animation: ButtonAnimation
var _is_ready: bool = false


func _ready() -> void:
	# Setup node structure
	_setup_nodes()
	_is_ready = true

	# Apply initial configuration
	_update_all()

	# Connect pressed signal
	pressed.connect(_on_pressed)

	# Log initialization
	if GameLogger:
		GameLogger.debug(
			(
				"[IconButton] Initialized: size=%s, variant=%s"
				% [ButtonSize.keys()[button_size], ButtonVariant.keys()[button_variant]]
			)
		)


func _setup_nodes() -> void:
	"""Create and setup child nodes following Parent-First protocol"""
	# Clear any existing children (in case of re-setup)
	for child in get_children():
		child.queue_free()

	# Create shadow panel (behind button content)
	_shadow_panel = Panel.new()
	add_child(_shadow_panel)
	_shadow_panel.name = "ShadowPanel"
	_shadow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_panel.visible = show_shadow

	# Create content container (centers icon and optional label)
	_content_container = CenterContainer.new()
	add_child(_content_container)
	_content_container.name = "ContentContainer"
	_content_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Create VBox for icon + label layout
	var vbox = VBoxContainer.new()
	_content_container.add_child(vbox)
	vbox.name = "VBoxContainer"
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", ICON_LABEL_SPACING)

	# Create icon TextureRect
	_icon_rect = TextureRect.new()
	vbox.add_child(_icon_rect)
	_icon_rect.name = "IconTexture"
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Create optional label
	_label_node = Label.new()
	vbox.add_child(_label_node)
	_label_node.name = "ButtonLabel"
	_label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_node.visible = false  # Hidden until label_text is set

	# Add ButtonAnimation if enabled
	if animate_press:
		_button_animation = ButtonAnimation.new()
		add_child(_button_animation)
		_button_animation.name = "ButtonAnimation"
		_button_animation.press_scale = 0.92


func _update_all() -> void:
	"""Update all visual properties"""
	if not _is_ready:
		return

	_update_size()
	_update_style()
	_update_icon()
	_update_label()
	_update_shadow()


func _update_size() -> void:
	"""Update button size based on button_size preset"""
	if not _is_ready or not _icon_rect:
		return

	var size_px = SIZE_VALUES[button_size]

	# Set minimum size (square by default)
	custom_minimum_size = Vector2(size_px, size_px)

	# Icon size is 60% of button
	var icon_size = int(size_px * ICON_SCALE)
	_icon_rect.custom_minimum_size = Vector2(icon_size, icon_size)

	# Update font size based on button size
	var font_size = _get_font_size_for_button_size()
	_label_node.add_theme_font_size_override("font_size", font_size)

	# Update shadow offset
	_update_shadow()


func _update_style() -> void:
	"""Apply style variant (colors, borders)"""
	if not _is_ready:
		return

	# Create or update StyleBoxFlat based on variant
	var style = _create_style_for_variant(button_variant, false)
	var style_pressed = _create_style_for_variant(button_variant, true)
	var style_hover = _create_style_for_variant(button_variant, false, true)

	# Apply styles
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("pressed", style_pressed)
	add_theme_stylebox_override("hover", style_hover)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	add_theme_stylebox_override("disabled", _create_disabled_style())

	# Update label colors
	_update_label_colors()


func _create_style_for_variant(
	variant: ButtonVariant, is_pressed: bool, is_hover: bool = false
) -> StyleBoxFlat:
	"""Create StyleBoxFlat for a specific variant and state"""
	var style = StyleBoxFlat.new()

	# Base corner radius (Art Bible: slightly rounded metal edges)
	style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD

	# Border (heavier on bottom for depth - "welded metal" effect)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 4  # Extra thick bottom = beveled edge

	match variant:
		ButtonVariant.PRIMARY:
			if is_pressed:
				style.bg_color = GameColorPalette.RUST_DARK
				style.border_color = GameColorPalette.RUST_LIGHT
			elif is_hover:
				style.bg_color = GameColorPalette.RUST_LIGHT
				style.border_color = GameColorPalette.RUST_DARK
			else:
				style.bg_color = GameColorPalette.RUST_ORANGE
				style.border_color = GameColorPalette.RUST_DARK

		ButtonVariant.SECONDARY:
			# Hollow/outlined style
			style.bg_color = Color(0, 0, 0, 0.3) if not is_pressed else GameColorPalette.RUST_ORANGE
			style.border_color = GameColorPalette.RUST_ORANGE
			style.border_width_bottom = 2  # Even borders for outlined style

			if is_hover:
				style.bg_color = Color(
					GameColorPalette.RUST_ORANGE.r,
					GameColorPalette.RUST_ORANGE.g,
					GameColorPalette.RUST_ORANGE.b,
					0.2
				)

		ButtonVariant.DANGER:
			if is_pressed:
				style.bg_color = GameColorPalette.BLOOD_RED
				style.border_color = GameColorPalette.WARNING_RED
			elif is_hover:
				style.bg_color = GameColorPalette.WARNING_RED
				style.border_color = GameColorPalette.BLOOD_RED
			else:
				style.bg_color = GameColorPalette.SOOT_BLACK
				style.border_color = GameColorPalette.HAZARD_YELLOW

	return style


func _create_disabled_style() -> StyleBoxFlat:
	"""Create style for disabled state"""
	var style = StyleBoxFlat.new()
	style.bg_color = GameColorPalette.DISABLED
	style.border_color = GameColorPalette.CONCRETE_GRAY
	style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
	style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	return style


func _update_icon() -> void:
	"""Update icon texture"""
	if not _is_ready or not _icon_rect:
		return

	_icon_rect.texture = icon_texture
	_icon_rect.visible = icon_texture != null


func _update_label() -> void:
	"""Update label text and visibility"""
	if not _is_ready or not _label_node:
		return

	_label_node.text = label_text
	_label_node.visible = not label_text.is_empty()

	# If we have a label, adjust button width
	if not label_text.is_empty():
		var size_px = SIZE_VALUES[button_size]
		# Widen button for text (at least 1.5x icon width)
		custom_minimum_size.x = max(size_px, size_px * 1.5)

	_update_label_colors()


func _update_label_colors() -> void:
	"""Update label colors based on variant"""
	if not _is_ready or not _label_node:
		return

	match button_variant:
		ButtonVariant.PRIMARY:
			_label_node.add_theme_color_override("font_color", GameColorPalette.DIRTY_WHITE)
		ButtonVariant.SECONDARY:
			_label_node.add_theme_color_override("font_color", GameColorPalette.RUST_ORANGE)
		ButtonVariant.DANGER:
			_label_node.add_theme_color_override("font_color", GameColorPalette.DIRTY_WHITE)

	# Add outline for readability
	_label_node.add_theme_color_override("font_outline_color", Color.BLACK)
	_label_node.add_theme_constant_override("outline_size", 2)


func _update_shadow() -> void:
	"""Update drop shadow visibility and position"""
	if not _is_ready or not _shadow_panel:
		return

	_shadow_panel.visible = show_shadow

	if show_shadow:
		# Create shadow style
		var shadow_style = StyleBoxFlat.new()
		shadow_style.bg_color = Color(0, 0, 0, 0.4)
		shadow_style.corner_radius_top_left = UIConstants.CORNER_RADIUS_MD
		shadow_style.corner_radius_top_right = UIConstants.CORNER_RADIUS_MD
		shadow_style.corner_radius_bottom_left = UIConstants.CORNER_RADIUS_MD
		shadow_style.corner_radius_bottom_right = UIConstants.CORNER_RADIUS_MD

		_shadow_panel.add_theme_stylebox_override("panel", shadow_style)

		# Position shadow offset (below and right of button)
		var shadow_offset = 4
		_shadow_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_shadow_panel.offset_left = shadow_offset
		_shadow_panel.offset_top = shadow_offset
		_shadow_panel.offset_right = shadow_offset
		_shadow_panel.offset_bottom = shadow_offset


func _get_font_size_for_button_size() -> int:
	"""Get appropriate font size for button size"""
	match button_size:
		ButtonSize.SMALL:
			return UIConstants.FONT_SIZE_CAPTION
		ButtonSize.MEDIUM:
			return UIConstants.FONT_SIZE_BODY
		ButtonSize.LARGE:
			return UIConstants.FONT_SIZE_BUTTON_PRIMARY
		_:
			return UIConstants.FONT_SIZE_BODY


func _on_pressed() -> void:
	"""Handle button press"""
	# Trigger haptic feedback if available
	if HapticManager:
		HapticManager.light()

	# Emit our custom signal (in addition to built-in pressed)
	icon_button_pressed.emit()


# ==== PUBLIC API ====


func setup(
	texture: Texture2D,
	text: String = "",
	size: ButtonSize = ButtonSize.MEDIUM,
	variant: ButtonVariant = ButtonVariant.PRIMARY
) -> IconButton:
	"""
	Convenience method to configure button in one call (chainable).

	Usage:
		btn.setup(icon_texture, "Start", IconButton.ButtonSize.LARGE)
	"""
	icon_texture = texture
	label_text = text
	button_size = size
	button_variant = variant
	return self


func set_icon(texture: Texture2D) -> IconButton:
	"""Set icon texture (chainable)"""
	icon_texture = texture
	return self


func set_label(text: String) -> IconButton:
	"""Set label text (chainable)"""
	label_text = text
	return self


func set_button_size(size: ButtonSize) -> IconButton:
	"""Set button size (chainable)"""
	button_size = size
	return self


func set_variant(variant: ButtonVariant) -> IconButton:
	"""Set button variant (chainable)"""
	button_variant = variant
	return self


func set_shadow(enabled: bool) -> IconButton:
	"""Enable/disable drop shadow (chainable)"""
	show_shadow = enabled
	return self
