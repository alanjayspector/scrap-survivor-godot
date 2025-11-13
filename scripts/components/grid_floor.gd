extends Node2D
class_name GridFloor
## Visual grid floor for spatial awareness
## Draws grid lines every 200 units within world bounds

const GRID_SPACING: float = 200.0  # Grid line spacing
const GRID_COLOR: Color = Color(0.3, 0.3, 0.3, 0.3)  # Subtle grey, semi-transparent
const LINE_WIDTH: float = 2.0

@export var world_bounds: Rect2 = Rect2(-1000, -1000, 2000, 2000)


func _ready() -> void:
	z_index = -10  # Render below all entities
	_generate_grid()


func _generate_grid() -> void:
	"""Generate grid lines within world bounds"""
	var min_x = world_bounds.position.x
	var max_x = world_bounds.position.x + world_bounds.size.x
	var min_y = world_bounds.position.y
	var max_y = world_bounds.position.y + world_bounds.size.y

	# Draw vertical lines
	var x = min_x
	while x <= max_x:
		var line = Line2D.new()
		line.add_point(Vector2(x, min_y))
		line.add_point(Vector2(x, max_y))
		line.default_color = GRID_COLOR
		line.width = LINE_WIDTH
		add_child(line)
		x += GRID_SPACING

	# Draw horizontal lines
	var y = min_y
	while y <= max_y:
		var line = Line2D.new()
		line.add_point(Vector2(min_x, y))
		line.add_point(Vector2(max_x, y))
		line.default_color = GRID_COLOR
		line.width = LINE_WIDTH
		add_child(line)
		y += GRID_SPACING

	print("[GridFloor] Generated grid with spacing ", GRID_SPACING, " within bounds ", world_bounds)
