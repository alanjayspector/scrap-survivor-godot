class_name UIConstants
extends RefCounted
## UI Constants - Mobile-optimized measurements (Brotato-informed, iOS HIG validated)
## Week 16 Phase 2: Typography System Overhaul
## Source: docs/mobile-ui-specification.md v1.1

# ==== TOUCH TARGETS (from Brotato measurements) ====
const TOUCH_TARGET_MIN: int = 44  # iOS HIG absolute minimum
const TOUCH_TARGET_STANDARD: int = 56  # Standard buttons
const TOUCH_TARGET_LARGE: int = 64  # Primary actions (Brotato primary)
const TOUCH_TARGET_COMBAT: int = 48  # Pause button (Brotato)

# Button widths (Brotato measurements)
const BUTTON_PRIMARY_WIDTH: int = 280  # 75% screen width
const BUTTON_SECONDARY_WIDTH: int = 120

# ==== SPACING (8pt Grid System) ====
const SPACING_XXS: int = 4
const SPACING_XS: int = 8
const SPACING_SM: int = 12
const SPACING_MD: int = 16  # Brotato element gap (MANDATORY minimum)
const SPACING_LG: int = 24  # Brotato horizontal padding
const SPACING_XL: int = 32  # Brotato section spacing
const SPACING_XXL: int = 48
const SPACING_XXXL: int = 64

# ==== SAFE AREAS (Brotato-aligned) ====
const SAFE_AREA_TOP: int = 59  # Brotato HUD top clearance (Dynamic Island)
const SAFE_AREA_BOTTOM: int = 34  # iOS home indicator
const SAFE_AREA_SIDES: int = 24  # Brotato horizontal margin
const SAFE_AREA_SIDES_LANDSCAPE: int = 44

# ==== TYPOGRAPHY (Brotato measurements) ====
# Screen titles
const FONT_SIZE_DISPLAY_LARGE: int = 48  # "SCRAP SURVIVOR", main titles
const FONT_SIZE_DISPLAY_MEDIUM: int = 40  # Alternate screen titles

# Section headers
const FONT_SIZE_TITLE_LARGE: int = 28  # Section headers, wave labels
const FONT_SIZE_TITLE_MEDIUM: int = 24  # Subsection headers

# Button labels
const FONT_SIZE_BUTTON_PRIMARY: int = 20  # Primary button text (upper range)
const FONT_SIZE_BUTTON_SECONDARY: int = 18  # Secondary button text

# Body text
const FONT_SIZE_BODY_LARGE: int = 18  # Large body text
const FONT_SIZE_BODY: int = 14  # Brotato body text (strategic deviation from iOS HIG 17pt)

# Meta text
const FONT_SIZE_CAPTION: int = 12  # Timestamps, wave counter
const FONT_SIZE_META: int = 16  # Labels, secondary info

# Combat-specific
const FONT_SIZE_STAT_COMBAT: int = 28  # HP/Stats (Brotato minimum)
const FONT_SIZE_STAT_COMBAT_LARGE: int = 32  # HP/Stats (upper range)
const FONT_SIZE_TIMER: int = 40  # Wave timer (LARGEST in HUD)
const FONT_SIZE_CURRENCY: int = 20  # Gold/XP display

# ==== COMBAT HUD (Brotato measurements) ====
const HUD_HP_BAR_WIDTH: int = 180
const HUD_HP_BAR_HEIGHT: int = 48
const HUD_XP_BAR_WIDTH: int = 342
const HUD_XP_BAR_HEIGHT: int = 40
const HUD_PAUSE_BUTTON_SIZE: int = 48

# ==== ANIMATION DURATIONS (seconds) ====
const ANIM_BUTTON_PRESS: float = 0.05  # Brotato ultra-fast (50ms)
const ANIM_BUTTON_RELEASE: float = 0.05
const ANIM_FAST: float = 0.1
const ANIM_NORMAL: float = 0.2
const ANIM_MODAL: float = 0.25  # Brotato screen transitions
const ANIM_SUCCESS: float = 0.3  # Brotato success feedback

# ==== CORNER RADIUS ====
const CORNER_RADIUS_SM: int = 4
const CORNER_RADIUS_MD: int = 8
const CORNER_RADIUS_LG: int = 12
const CORNER_RADIUS_XL: int = 16

# ==== OUTLINE SIZES (for text readability) ====
const OUTLINE_SIZE_CRITICAL: int = 3  # Critical labels (HP, Timer, Stats)
const OUTLINE_SIZE_HEADER: int = 3  # Headers and titles
const OUTLINE_SIZE_BUTTON: int = 2  # Button text (optional)

# ==== ACCESSIBILITY ====
static var animations_enabled: bool = true  # Set to false for reduced motion


# Helper functions
static func ensure_minimum_touch_target(size: Vector2) -> Vector2:
	"""Ensures a size meets minimum 44pt touch target requirement"""
	return Vector2(max(size.x, TOUCH_TARGET_MIN), max(size.y, TOUCH_TARGET_MIN))


static func get_animation_duration(base_duration: float) -> float:
	"""Returns 0.0 if animations disabled, base_duration otherwise"""
	return base_duration if animations_enabled else 0.0


static func should_animate() -> bool:
	"""Returns whether animations should be played"""
	return animations_enabled


static func get_scaled_font_size(base_size: int) -> int:
	"""
	Returns font size scaled for device screen size.
	Scales up 15% on small devices (<5.5" diagonal) for readability.
	"""
	var screen_size = DisplayServer.screen_get_size()
	var diagonal_inches = _calculate_diagonal_inches(screen_size)

	# Scale up text on small devices
	if diagonal_inches < 5.5:
		return int(base_size * 1.15)  # 15% larger on small screens

	return base_size


static func _calculate_diagonal_inches(size: Vector2i) -> float:
	"""Calculate screen diagonal in inches from pixel size"""
	var dpi = DisplayServer.screen_get_dpi()
	if dpi == 0:
		dpi = 160  # Fallback for desktop

	var width_inches = size.x / float(dpi)
	var height_inches = size.y / float(dpi)
	return sqrt(width_inches * width_inches + height_inches * height_inches)
