class_name GameColorPalette
extends RefCounted
## Game Color Palette - Brotato exact colors + WCAG contrast validation
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

# ==== WASTELAND PALETTE (Week 16 Phase 8 - Visual Identity) ====
# Post-apocalyptic aesthetic: rust, metal, hazard warnings, scavenged materials
# Usage: Apply to all UI elements for thematic consistency

# Primary Colors (rust and oxidation)
const RUST_ORANGE: Color = Color("#D4722B")  # Primary action buttons (welded metal)
const RUST_DARK: Color = Color("#8B4513")  # Pressed state, borders (oxidized)
const RUST_LIGHT: Color = Color("#E89B5C")  # Highlights, hover state (fresh metal)

# Hazard Warning Colors (road signs, caution tape)
const HAZARD_YELLOW: Color = Color("#FFD700")  # Caution, warnings (bright yellow)
const HAZARD_BLACK: Color = Color("#1A1A1A")  # Contrast stripe, dark base

# Danger Colors (blood, emergency)
const BLOOD_RED: Color = Color("#8B0000")  # Destructive actions (dark blood)
const WARNING_RED: Color = Color("#FF6347")  # Error states (tomato red)

# Neutral Colors (weathered materials)
const CONCRETE_GRAY: Color = Color("#707070")  # Backgrounds, subtle borders
const DIRTY_WHITE: Color = Color("#E8E8D0")  # Text on dark (cream, aged paper)
const SOOT_BLACK: Color = Color("#2B2B2B")  # Panel backgrounds, dark UI

# Accent Colors (scavenged tech)
const NEON_GREEN: Color = Color("#39FF14")  # Success, health (radioactive glow)
const OXIDIZED_COPPER: Color = Color("#4A7C59")  # Info, neutral (aged copper)

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

	# Wasteland palette against common backgrounds (Phase 8)
	# Against GAME_BG (current scrapyard background)
	_cache_contrast_ratio(RUST_ORANGE, GAME_BG)
	_cache_contrast_ratio(RUST_LIGHT, GAME_BG)
	_cache_contrast_ratio(HAZARD_YELLOW, GAME_BG)
	_cache_contrast_ratio(BLOOD_RED, GAME_BG)
	_cache_contrast_ratio(WARNING_RED, GAME_BG)
	_cache_contrast_ratio(NEON_GREEN, GAME_BG)
	_cache_contrast_ratio(DIRTY_WHITE, GAME_BG)
	_cache_contrast_ratio(CONCRETE_GRAY, GAME_BG)

	# Against SOOT_BLACK (new panel backgrounds)
	_cache_contrast_ratio(RUST_ORANGE, SOOT_BLACK)
	_cache_contrast_ratio(RUST_LIGHT, SOOT_BLACK)
	_cache_contrast_ratio(HAZARD_YELLOW, SOOT_BLACK)
	_cache_contrast_ratio(DIRTY_WHITE, SOOT_BLACK)
	_cache_contrast_ratio(TEXT_PRIMARY, SOOT_BLACK)

	# Against RUST_ORANGE (button backgrounds need text contrast)
	_cache_contrast_ratio(DIRTY_WHITE, RUST_ORANGE)
	_cache_contrast_ratio(TEXT_PRIMARY, RUST_ORANGE)
	_cache_contrast_ratio(HAZARD_BLACK, RUST_ORANGE)

	GameLogger.info("[GameColorPalette] Pre-calculated %d contrast ratios" % _contrast_cache.size())


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


# ==== WASTELAND SEMANTIC HELPERS (Phase 8) ====
static func get_wasteland_primary() -> Color:
	"""Get primary wasteland button color (rust orange)"""
	return RUST_ORANGE


static func get_wasteland_primary_pressed() -> Color:
	"""Get pressed state for primary buttons (darker rust)"""
	return RUST_DARK


static func get_wasteland_primary_highlight() -> Color:
	"""Get highlight/hover state for primary buttons (lighter rust)"""
	return RUST_LIGHT


static func get_wasteland_danger() -> Color:
	"""Get danger/destructive action color (blood red)"""
	return BLOOD_RED


static func get_wasteland_warning() -> Color:
	"""Get warning/hazard color (bright yellow)"""
	return HAZARD_YELLOW


static func get_wasteland_success() -> Color:
	"""Get success/positive color (radioactive green)"""
	return NEON_GREEN


static func get_wasteland_text_primary() -> Color:
	"""Get primary text color for wasteland theme (dirty white/cream)"""
	return DIRTY_WHITE


static func get_wasteland_text_secondary() -> Color:
	"""Get secondary text color for wasteland theme (concrete gray)"""
	return CONCRETE_GRAY


static func get_wasteland_background() -> Color:
	"""Get panel/card background color (soot black)"""
	return SOOT_BLACK


static func get_icon_color_for_stat(stat_type: String) -> Color:
	"""
	Get semantic icon color for stat type (wasteland aesthetic).

	Usage:
		icon.modulate = GameColorPalette.get_icon_color_for_stat("health")
	"""
	match stat_type.to_lower():
		"health", "hp", "healing":
			return NEON_GREEN  # Radioactive glow = life force
		"xp", "experience", "progression":
			return WARNING  # Gold = achievement
		"damage", "attack", "weapon":
			return BLOOD_RED  # Red = danger
		"armor", "defense", "shield":
			return CONCRETE_GRAY  # Gray = metal plating
		"speed", "movement":
			return RUST_LIGHT  # Orange = motion
		"warning", "caution", "wave":
			return HAZARD_YELLOW  # Yellow = alert
		"energy", "mana", "resource":
			return OXIDIZED_COPPER  # Copper = scavenged tech
		_:
			return DIRTY_WHITE  # Default = neutral


static func get_button_border_color(button_type: String) -> Color:
	"""
	Get border color for button type (wasteland aesthetic).

	Usage:
		style_box.border_color = GameColorPalette.get_button_border_color("primary")
	"""
	match button_type.to_lower():
		"primary":
			return RUST_DARK  # Darker seam/weld
		"secondary":
			return RUST_ORANGE  # Hollow frame
		"danger":
			return HAZARD_YELLOW  # Warning stripe
		"success":
			return NEON_GREEN  # Positive action
		_:
			return CONCRETE_GRAY  # Neutral border

# ==== WASTELAND COLOR USAGE DOCUMENTATION ====
## Color Selection Guide (Phase 8 patterns):
##
## PRIMARY BUTTONS:
##   - Background: RUST_ORANGE
##   - Border: RUST_DARK
##   - Text: DIRTY_WHITE or TEXT_PRIMARY
##   - Pressed: RUST_DARK background, RUST_LIGHT border
##
## SECONDARY BUTTONS (hollow):
##   - Background: Transparent Color(0,0,0,0)
##   - Border: RUST_ORANGE (3pt width)
##   - Text: RUST_ORANGE or DIRTY_WHITE
##   - Pressed: RUST_ORANGE background (10% alpha)
##
## DANGER BUTTONS (destructive):
##   - Background: SOOT_BLACK or HAZARD_BLACK
##   - Border: HAZARD_YELLOW (3pt width)
##   - Text: DIRTY_WHITE
##   - Pressed: HAZARD_BLACK background, WARNING_RED border
##
## PANEL BACKGROUNDS:
##   - Default: SOOT_BLACK
##   - Elevated: Color("#323232") - slightly lighter
##   - Border: CONCRETE_GRAY at 50% alpha
##
## ICONS (semantic tinting):
##   - Health: NEON_GREEN (radioactive glow)
##   - XP: WARNING (gold progression)
##   - Damage: BLOOD_RED (danger)
##   - Armor: CONCRETE_GRAY (metal)
##   - Warning: HAZARD_YELLOW (caution)
##
## TEXT:
##   - Primary: DIRTY_WHITE (cream, aged paper)
##   - Secondary: CONCRETE_GRAY (de-emphasized)
##   - Headers: TEXT_PRIMARY (white, high contrast)
##   - Disabled: DISABLED (intentionally low contrast)
