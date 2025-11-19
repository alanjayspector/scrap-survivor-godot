class_name ColorPalette
extends RefCounted
## Color Palette - Brotato exact colors + WCAG contrast validation
## Week 16 Phase 2: Typography System Overhaul
## Source: docs/mobile-ui-specification.md v1.1

# ==== BROTATO EXACT COLORS ====
const PRIMARY_DANGER: Color = Color("#CC3737")  # Red (primary action/danger)
const SECONDARY_ACCENT: Color = Color("#545287")  # Purple (secondary)
const SUCCESS: Color = Color("#76FF76")  # Green (XP, positive stats)
const WARNING: Color = Color("#EAC43D")  # Yellow (gold, warnings)

# Backgrounds
const BG_DARK_PRIMARY: Color = Color("#282747")  # Main background
const BG_DARK_SECONDARY: Color = Color("#393854")  # Card backgrounds

# Text (15.1:1 contrast ratio with dark background)
const TEXT_PRIMARY: Color = Color("#FFFFFF")  # White - extreme contrast
const TEXT_SECONDARY: Color = Color("#D5D5D5")  # Light gray
const TEXT_TERTIARY: Color = Color("#EAE2B0")  # Cream

# Disabled
const DISABLED: Color = Color(0.3, 0.3, 0.3)  # Intentionally low contrast

# ==== EXISTING GAME COLORS (for compatibility) ====
# These are the current colors used in the game - keep for backward compatibility
const GAME_GOLD: Color = Color(0.9, 0.7, 0.3, 1)  # Current title color
const GAME_GRAY: Color = Color(0.7, 0.7, 0.7, 1)  # Current secondary text
const GAME_BG: Color = Color(0.15, 0.12, 0.1, 1)  # Current background

# ==== PRE-CALCULATED CONTRAST RATIOS ====
# PERFORMANCE: Cached at startup to avoid expensive pow() calls in hot paths
static var _contrast_cache: Dictionary = {}


static func _static_init():
	"""Pre-calculate all common color combinations (once at load)"""
	# Brotato colors against dark backgrounds
	_cache_contrast_ratio(TEXT_PRIMARY, BG_DARK_PRIMARY)
	_cache_contrast_ratio(TEXT_SECONDARY, BG_DARK_PRIMARY)
	_cache_contrast_ratio(TEXT_TERTIARY, BG_DARK_PRIMARY)
	_cache_contrast_ratio(SUCCESS, BG_DARK_PRIMARY)
	_cache_contrast_ratio(PRIMARY_DANGER, BG_DARK_PRIMARY)
	_cache_contrast_ratio(WARNING, BG_DARK_PRIMARY)
	_cache_contrast_ratio(TEXT_PRIMARY, BG_DARK_SECONDARY)
	_cache_contrast_ratio(TEXT_SECONDARY, BG_DARK_SECONDARY)

	# Existing game colors
	_cache_contrast_ratio(GAME_GOLD, GAME_BG)
	_cache_contrast_ratio(GAME_GRAY, GAME_BG)
	_cache_contrast_ratio(TEXT_PRIMARY, GAME_BG)

	GameLogger.info("[ColorPalette] Pre-calculated %d contrast ratios" % _contrast_cache.size())


static func _cache_contrast_ratio(color1: Color, color2: Color):
	"""Cache contrast ratio for a color pair"""
	var key = _get_cache_key(color1, color2)
	_contrast_cache[key] = _calculate_contrast_ratio(color1, color2)


static func _get_cache_key(color1: Color, color2: Color) -> String:
	"""Generate cache key from two colors"""
	return "%s_%s" % [color1.to_html(), color2.to_html()]


# ==== CONTRAST RATIO CALCULATION ====
static func get_contrast_ratio(color1: Color, color2: Color) -> float:
	"""
	Get contrast ratio between two colors (WCAG standard).
	Uses cache for performance if available.
	"""
	# Check cache first (avoids expensive pow() calls)
	var key = _get_cache_key(color1, color2)
	if _contrast_cache.has(key):
		return _contrast_cache[key]

	# Calculate if not cached
	return _calculate_contrast_ratio(color1, color2)


static func _calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var l1 = _get_relative_luminance(color1)
	var l2 = _get_relative_luminance(color2)

	var lighter = max(l1, l2)
	var darker = min(l1, l2)

	return (lighter + 0.05) / (darker + 0.05)


static func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance (WCAG formula)"""
	var r = _to_linear(color.r)
	var g = _to_linear(color.g)
	var b = _to_linear(color.b)
	return 0.2126 * r + 0.7152 * g + 0.0722 * b


static func _to_linear(channel: float) -> float:
	"""Convert sRGB channel to linear RGB (WCAG formula)"""
	if channel <= 0.03928:
		return channel / 12.92

	return pow((channel + 0.055) / 1.055, 2.4)


# ==== WCAG VALIDATION ====
static func validate_text_contrast(text_color: Color, bg_color: Color, font_size: int) -> bool:
	"""
	Validate text contrast against WCAG AA standards.
	Returns true if contrast is sufficient.

	WCAG AA Requirements:
	- Normal text (<18pt): 4.5:1 minimum
	- Large text (≥18pt): 3.0:1 minimum
	"""
	var ratio = get_contrast_ratio(text_color, bg_color)
	var min_ratio = 4.5 if font_size < 18 else 3.0  # WCAG AA
	return ratio >= min_ratio


static func print_all_contrast_ratios():
	"""Debug helper: Print all cached contrast ratios for validation"""
	print("\n=== COLOR CONTRAST RATIOS (WCAG Validation) ===")
	for key in _contrast_cache:
		var ratio = _contrast_cache[key]
		var passes_aa = ratio >= 4.5
		var passes_aaa = ratio >= 7.0
		var status = "AAA ✅" if passes_aaa else ("AA ✅" if passes_aa else "FAIL ❌")
		print("%s: %.2f:1 (%s)" % [key, ratio, status])
	print("==============================================\n")


# ==== SEMANTIC COLOR HELPERS ====
static func get_stat_color(value: int) -> Color:
	"""Get color for stat change display (positive/negative)"""
	if value > 0:
		return SUCCESS
	if value < 0:
		return PRIMARY_DANGER

	return TEXT_SECONDARY


static func get_rarity_color(rarity: String) -> Color:
	"""Get color for item rarity (standard roguelite pattern)"""
	match rarity.to_lower():
		"common":
			return TEXT_SECONDARY
		"uncommon":
			return SUCCESS
		"rare":
			return Color("#4D94FF")  # Blue
		"epic":
			return Color("#A64DFF")  # Purple
		"legendary":
			return WARNING  # Orange/Gold
		_:
			return TEXT_PRIMARY
