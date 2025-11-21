class_name HapticFeedback
extends RefCounted
## HapticFeedback - Mobile haptic/vibration feedback utility
## Week 16: Tactile feedback for button presses and game events
##
## Usage:
##   HapticFeedback.tap()        # Light tap for button press
##   HapticFeedback.success()    # Success confirmation
##   HapticFeedback.error()      # Error/warning feedback
##   HapticFeedback.impact()     # Heavy impact (damage, collision)
##
## Platform Support:
## - iOS: Uses system haptic engine (via Input.vibrate_handheld)
## - Android: Uses vibration API
## - Desktop: No-op (silent)

## Haptic intensity levels (duration in milliseconds)
enum Intensity {
	LIGHT,  # Quick tap (button press)
	MEDIUM,  # Standard feedback (selection)
	HEAVY,  # Strong feedback (impact, error)
}

## Vibration durations (ms) - tuned for feel
const DURATION_LIGHT: int = 10
const DURATION_MEDIUM: int = 25
const DURATION_HEAVY: int = 50

## Global enable/disable (respects user settings)
static var enabled: bool = true


## Light tap - for button presses
static func tap() -> void:
	_vibrate(Intensity.LIGHT)


## Medium feedback - for selections, confirmations
static func select() -> void:
	_vibrate(Intensity.MEDIUM)


## Success feedback - for achievements, completions
static func success() -> void:
	# Double tap pattern for success
	_vibrate(Intensity.LIGHT)
	await Engine.get_main_loop().create_timer(0.05).timeout
	_vibrate(Intensity.MEDIUM)


## Error/warning feedback - for validation errors, blocked actions
static func error() -> void:
	_vibrate(Intensity.HEAVY)


## Impact feedback - for damage, collisions, heavy actions
static func impact() -> void:
	_vibrate(Intensity.HEAVY)


## Delete/destructive action warning
static func warning() -> void:
	_vibrate(Intensity.MEDIUM)


## Core vibration function
static func _vibrate(intensity: Intensity) -> void:
	if not enabled:
		return

	# Only vibrate on mobile platforms
	if not _is_mobile():
		return

	var duration_ms: int
	match intensity:
		Intensity.LIGHT:
			duration_ms = DURATION_LIGHT
		Intensity.MEDIUM:
			duration_ms = DURATION_MEDIUM
		Intensity.HEAVY:
			duration_ms = DURATION_HEAVY
		_:
			duration_ms = DURATION_LIGHT

	# Godot 4.x haptic API
	Input.vibrate_handheld(duration_ms)


## Check if running on mobile platform
static func _is_mobile() -> bool:
	var os_name = OS.get_name()
	return os_name == "iOS" or os_name == "Android"


## Enable/disable haptic feedback (for settings menu)
static func set_enabled(value: bool) -> void:
	enabled = value


## Check if haptics are available on this platform
static func is_available() -> bool:
	return _is_mobile()
