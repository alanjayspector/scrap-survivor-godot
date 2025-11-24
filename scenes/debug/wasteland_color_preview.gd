extends Control
## Wasteland Color Palette Preview
## Phase 8.1 - Visual Identity
## Displays all wasteland colors with swatches, names, hex codes, and usage

@onready var primary_grid = $ScrollContainer/VBoxContainer/PrimaryColors/ColorGrid1
@onready var hazard_grid = $ScrollContainer/VBoxContainer/HazardColors/ColorGrid2
@onready var danger_grid = $ScrollContainer/VBoxContainer/DangerColors/ColorGrid3
@onready var neutral_grid = $ScrollContainer/VBoxContainer/NeutralColors/ColorGrid4
@onready var accent_grid = $ScrollContainer/VBoxContainer/AccentColors/ColorGrid5


func _ready():
	_create_primary_colors()
	_create_hazard_colors()
	_create_danger_colors()
	_create_neutral_colors()
	_create_accent_colors()


func _create_primary_colors():
	_add_color_swatch(
		primary_grid,
		"RUST_ORANGE",
		GameColorPalette.RUST_ORANGE,
		"Primary action buttons (welded metal)"
	)
	_add_color_swatch(
		primary_grid, "RUST_DARK", GameColorPalette.RUST_DARK, "Pressed state, borders (oxidized)"
	)
	_add_color_swatch(
		primary_grid,
		"RUST_LIGHT",
		GameColorPalette.RUST_LIGHT,
		"Highlights, hover state (fresh metal)"
	)


func _create_hazard_colors():
	_add_color_swatch(
		hazard_grid,
		"HAZARD_YELLOW",
		GameColorPalette.HAZARD_YELLOW,
		"Caution, warnings (bright yellow)"
	)
	_add_color_swatch(
		hazard_grid, "HAZARD_BLACK", GameColorPalette.HAZARD_BLACK, "Contrast stripe, dark base"
	)


func _create_danger_colors():
	_add_color_swatch(
		danger_grid, "BLOOD_RED", GameColorPalette.BLOOD_RED, "Destructive actions (dark blood)"
	)
	_add_color_swatch(
		danger_grid, "WARNING_RED", GameColorPalette.WARNING_RED, "Error states (tomato red)"
	)


func _create_neutral_colors():
	_add_color_swatch(
		neutral_grid, "CONCRETE_GRAY", GameColorPalette.CONCRETE_GRAY, "Backgrounds, subtle borders"
	)
	_add_color_swatch(
		neutral_grid,
		"DIRTY_WHITE",
		GameColorPalette.DIRTY_WHITE,
		"Text on dark (cream, aged paper)"
	)
	_add_color_swatch(
		neutral_grid, "SOOT_BLACK", GameColorPalette.SOOT_BLACK, "Panel backgrounds, dark UI"
	)


func _create_accent_colors():
	_add_color_swatch(
		accent_grid, "NEON_GREEN", GameColorPalette.NEON_GREEN, "Success, health (radioactive glow)"
	)
	_add_color_swatch(
		accent_grid,
		"OXIDIZED_COPPER",
		GameColorPalette.OXIDIZED_COPPER,
		"Info, neutral (aged copper)"
	)


func _add_color_swatch(
	parent: GridContainer, color_name: String, color: Color, description: String
):
	# Color swatch (large visual square)
	var swatch = ColorRect.new()
	parent.add_child(swatch)
	swatch.custom_minimum_size = Vector2(200, 120)
	swatch.color = color

	# Add border to swatch
	var border = StyleBoxFlat.new()
	border.bg_color = color
	border.border_width_left = 2
	border.border_width_top = 2
	border.border_width_right = 2
	border.border_width_bottom = 2
	border.border_color = Color.WHITE

	# Name label (constant name)
	var name_label = Label.new()
	parent.add_child(name_label)
	name_label.text = color_name
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)

	# Info label (hex + description)
	var info_label = Label.new()
	parent.add_child(info_label)
	info_label.text = "%s\n\n%s" % [color.to_html(), description]
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	info_label.add_theme_constant_override("outline_size", 2)
	info_label.add_theme_color_override("font_outline_color", Color.BLACK)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_label.custom_minimum_size = Vector2(300, 0)
