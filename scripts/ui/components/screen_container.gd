extends MarginContainer
class_name ScreenContainer
## Automatically applies safe area insets for notches, Dynamic Island, home indicator
##
## This component wraps screen content and adds margins to prevent UI overlap with:
## - iPhone notches (iPhone X and newer)
## - Dynamic Island (iPhone 14 Pro and newer)
## - Home indicator (all modern iPhones)
## - Status bar
##
## Usage: Wrap your screen's root container with ScreenContainer in the scene tree.
## No manual configuration needed - margins are calculated automatically.


func _ready() -> void:
	_apply_safe_area_insets()
	get_tree().root.size_changed.connect(_on_viewport_resized)


func _apply_safe_area_insets() -> void:
	if not OS.has_feature("mobile"):
		print("[ScreenContainer] Desktop detected - no safe area margins applied")
		return  # No safe areas on desktop

	# Get safe area from viewport
	var safe_area = DisplayServer.get_display_safe_area()
	var viewport_size = get_viewport().get_visible_rect().size

	print("[ScreenContainer] Safe area calculation:")
	print("  viewport_size: ", viewport_size)
	print("  safe_area.position: ", safe_area.position)
	print("  safe_area.size: ", safe_area.size)

	# Calculate insets
	var inset_top = safe_area.position.y
	var inset_left = safe_area.position.x
	var inset_bottom = viewport_size.y - (safe_area.position.y + safe_area.size.y)
	var inset_right = viewport_size.x - (safe_area.position.x + safe_area.size.x)

	# Clamp to non-negative (iOS API can return bad data in landscape)
	inset_top = max(0, inset_top)
	inset_left = max(0, inset_left)
	inset_bottom = max(0, inset_bottom)
	inset_right = max(0, inset_right)

	# Landscape mode: Make left/right symmetric (no side notches in landscape)
	var is_landscape = viewport_size.x > viewport_size.y
	if is_landscape:
		var side_margin = max(inset_left, inset_right)
		inset_left = side_margin
		inset_right = side_margin

	# Enforce minimum bottom margin for home indicator (iOS HIG: ~34px)
	inset_bottom = max(34, inset_bottom)

	print("  Calculated insets:")
	print("    top: ", inset_top)
	print("    left: ", inset_left)
	print("    bottom: ", inset_bottom)
	print("    right: ", inset_right)

	# Apply as margins
	add_theme_constant_override("margin_top", int(inset_top))
	add_theme_constant_override("margin_left", int(inset_left))
	add_theme_constant_override("margin_bottom", int(inset_bottom))
	add_theme_constant_override("margin_right", int(inset_right))

	print("[ScreenContainer] Safe area margins applied")


func _on_viewport_resized() -> void:
	# Recalculate safe area insets when viewport size changes
	# (e.g., device rotation, split-screen mode changes)
	_apply_safe_area_insets()
