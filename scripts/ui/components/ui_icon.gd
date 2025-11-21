class_name UIIcon
extends RefCounted
## UI Icon System - Texture-based icons that work reliably on iOS
## Replaces emoji characters which don't render on iOS devices

# Icon identifiers - used to look up the appropriate texture/fallback
enum Icon {
	# Stats
	HEALTH,
	DAMAGE,
	ARMOR,
	SPEED,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	ATTACK_SPEED,
	RANGE,
	REGEN,
	LIFESTEAL,
	DODGE,
	LUCK,
	# Currency/Resources
	SCRAP,
	XP,
	GOLD,
	# UI Actions
	EXPAND,
	COLLAPSE,
	CLOSE,
	SETTINGS,
	BACK,
	DELETE,
	INFO,
	# Misc
	WAVE,
	TIME,
	KILLS,
	LEVEL,
}

# Fallback text when no texture is available
# These are simple ASCII characters that render everywhere
const ICON_FALLBACK_TEXT: Dictionary = {
	Icon.HEALTH: "[HP]",
	Icon.DAMAGE: "[DMG]",
	Icon.ARMOR: "[ARM]",
	Icon.SPEED: "[SPD]",
	Icon.CRIT_CHANCE: "[CRIT]",
	Icon.CRIT_DAMAGE: "[CRIT+]",
	Icon.ATTACK_SPEED: "[ASPD]",
	Icon.RANGE: "[RNG]",
	Icon.REGEN: "[REG]",
	Icon.LIFESTEAL: "[LS]",
	Icon.DODGE: "[DOD]",
	Icon.LUCK: "[LCK]",
	Icon.SCRAP: "[S]",
	Icon.XP: "[XP]",
	Icon.GOLD: "[G]",
	Icon.EXPAND: "[+]",
	Icon.COLLAPSE: "[-]",
	Icon.CLOSE: "[X]",
	Icon.SETTINGS: "[=]",
	Icon.BACK: "[<]",
	Icon.DELETE: "[X]",
	Icon.INFO: "[i]",
	Icon.WAVE: "[W]",
	Icon.TIME: "[T]",
	Icon.KILLS: "[K]",
	Icon.LEVEL: "[L]",
}

# Icon colors for tinting
const ICON_COLORS: Dictionary = {
	Icon.HEALTH: Color(0.463, 1.0, 0.463),  # Green - SUCCESS
	Icon.DAMAGE: Color(0.8, 0.216, 0.216),  # Red - DANGER
	Icon.ARMOR: Color(0.329, 0.322, 0.529),  # Purple - SECONDARY
	Icon.SPEED: Color(0.918, 0.773, 0.239),  # Yellow - WARNING
	Icon.SCRAP: Color(0.918, 0.773, 0.239),  # Yellow
	Icon.XP: Color(0.463, 1.0, 0.463),  # Green
	Icon.GOLD: Color(0.918, 0.773, 0.239),  # Yellow
}

# Cache for loaded textures
static var _texture_cache: Dictionary = {}


static func get_icon_texture(icon: Icon) -> Texture2D:
	"""Get texture for an icon, returns null if not available"""
	if _texture_cache.has(icon):
		return _texture_cache[icon]

	var path = _get_icon_path(icon)
	if path.is_empty():
		return null

	if ResourceLoader.exists(path):
		var texture = load(path)
		_texture_cache[icon] = texture
		return texture

	return null


static func _get_icon_path(icon: Icon) -> String:
	"""Get the resource path for an icon texture"""
	var icon_name = Icon.keys()[icon].to_lower()
	return "res://themes/icons/icon_%s.png" % icon_name


static func get_fallback_text(icon: Icon) -> String:
	"""Get fallback text for an icon"""
	return ICON_FALLBACK_TEXT.get(icon, "[?]")


static func get_icon_color(icon: Icon) -> Color:
	"""Get the tint color for an icon"""
	return ICON_COLORS.get(icon, Color.WHITE)


static func create_icon_label(icon: Icon, text: String, font_size: int = 18) -> HBoxContainer:
	"""
	Create an HBoxContainer with icon (or fallback) + text label.
	Use this instead of emoji + text patterns.
	"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 8)

	var icon_texture = get_icon_texture(icon)

	if icon_texture:
		# Use texture icon
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.custom_minimum_size = Vector2(font_size + 4, font_size + 4)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.modulate = get_icon_color(icon)
		container.add_child(icon_rect)
	else:
		# Use text fallback
		var icon_label = Label.new()
		icon_label.text = get_fallback_text(icon)
		icon_label.add_theme_font_size_override("font_size", font_size)
		icon_label.add_theme_color_override("font_color", get_icon_color(icon))
		container.add_child(icon_label)

	var text_label = Label.new()
	text_label.text = text
	text_label.add_theme_font_size_override("font_size", font_size)
	text_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(text_label)

	return container


static func create_stat_row(
	icon: Icon, label_text: String, value: String, font_size: int = 18
) -> HBoxContainer:
	"""
	Create a stat row with icon, label, and right-aligned value.
	Example: [HP] Health         100
	"""
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 8)

	# Icon
	var icon_texture = get_icon_texture(icon)
	if icon_texture:
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.custom_minimum_size = Vector2(font_size + 4, font_size + 4)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.modulate = get_icon_color(icon)
		container.add_child(icon_rect)
	else:
		var icon_label = Label.new()
		icon_label.text = get_fallback_text(icon)
		icon_label.add_theme_font_size_override("font_size", font_size)
		icon_label.add_theme_color_override("font_color", get_icon_color(icon))
		container.add_child(icon_label)

	# Label (expands to fill)
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", GameColorPalette.TEXT_SECONDARY)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(label)

	# Value (right-aligned)
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", font_size)
	value_label.add_theme_color_override("font_color", Color.WHITE)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	container.add_child(value_label)

	return container
