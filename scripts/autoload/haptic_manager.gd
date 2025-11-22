extends Node
## HapticManager - Centralized haptic feedback system for mobile devices
##
## Industry-standard wrapper pattern for platform-specific haptic APIs.
## Provides consistent haptic feedback across iOS and Android while handling
## platform quirks and iOS 26.1 compatibility issues.
##
## Usage:
##   HapticManager.light()      # Button tap
##   HapticManager.medium()     # Selection, confirmation
##   HapticManager.heavy()      # Impact, error, warning
##   HapticManager.success()    # Success pattern (double-tap)
##
## Platform Support:
## - iOS 13+: Core Haptics with duration + amplitude control
## - iOS <13: Legacy AudioServices (ignores duration/amplitude)
## - Android 8+: Vibrator API with amplitude control
## - Desktop: No-op (silent)
## - Simulator: No-op (prevents error spam)
##
## References:
## - docs/gemini-haptic-research.md (section 6.1)
## - Godot PR #94580 (rapid haptic fixes)
## - .system/NEXT_SESSION.md (iOS 26.1 compatibility notes)

## Haptic intensity levels
enum Intensity {
	LIGHT = 0,  # Quick tap (10ms, 30% intensity) - UI feedback
	MEDIUM = 1,  # Standard (25ms, 50% intensity) - Selections
	HEAVY = 2,  # Strong (50ms, 80% intensity) - Impacts, errors
}

## Vibration parameters (tuned for mobile feel)
const PARAMS := {
	Intensity.LIGHT: {"duration": 10, "amplitude": 0.3},
	Intensity.MEDIUM: {"duration": 25, "amplitude": 0.5},
	Intensity.HEAVY: {"duration": 50, "amplitude": 0.8},
}

## User preference (can be toggled in settings)
var enabled: bool = true

## Platform capability flag (set during _ready)
var _platform_supports_haptics: bool = false


func _ready() -> void:
	_check_platform_support()
	_load_user_preferences()


## Check if current platform supports haptics
func _check_platform_support() -> void:
	var os_name := OS.get_name()

	# Only mobile platforms have haptic hardware
	_platform_supports_haptics = (os_name == "iOS" or os_name == "Android")

	if not _platform_supports_haptics:
		print("HapticManager: Platform '%s' does not support haptics (desktop/web)" % os_name)


## Load haptic preferences from SaveManager
func _load_user_preferences() -> void:
	# Check if SaveManager exists (might not be ready yet during early init)
	if not has_node("/root/SaveManager"):
		enabled = true  # Default enabled
		return

	enabled = SaveManager.get_setting("haptics_enabled", true)


## Enable or disable haptic feedback (save to user preferences)
func set_enabled(value: bool) -> void:
	enabled = value

	# Save preference if SaveManager is available
	if has_node("/root/SaveManager"):
		SaveManager.set_setting("haptics_enabled", value)


## Check if haptics are available and enabled
func is_available() -> bool:
	return _platform_supports_haptics and enabled


## Light haptic - for button presses, UI taps
func light() -> void:
	_vibrate(Intensity.LIGHT)


## Medium haptic - for selections, confirmations
func medium() -> void:
	_vibrate(Intensity.MEDIUM)


## Heavy haptic - for impacts, errors, warnings
func heavy() -> void:
	_vibrate(Intensity.HEAVY)


## Success feedback - double-tap pattern (light + medium)
func success() -> void:
	_vibrate(Intensity.LIGHT)
	await get_tree().create_timer(0.05).timeout
	_vibrate(Intensity.MEDIUM)


## Error/warning feedback - single heavy vibration
func error() -> void:
	_vibrate(Intensity.HEAVY)


## Impact feedback - for damage, collisions, heavy actions
func impact() -> void:
	_vibrate(Intensity.HEAVY)


## Warning feedback - for destructive actions (delete confirmation)
func warning() -> void:
	_vibrate(Intensity.MEDIUM)


## Core vibration implementation
func _vibrate(intensity: Intensity) -> void:
	# Early exit if disabled or unavailable
	if not enabled:
		return

	if not _platform_supports_haptics:
		return

	# Don't call haptics in editor (prevents simulator errors during testing)
	if OS.has_feature("editor"):
		return

	# Get parameters for this intensity level
	var params: Dictionary = PARAMS.get(intensity, PARAMS[Intensity.LIGHT])
	var duration_ms: int = params.duration
	var amplitude: float = params.amplitude

	# Clamp values to safe ranges (Godot validates but be defensive)
	duration_ms = clampi(duration_ms, 1, 5000)
	amplitude = clampf(amplitude, 0.0, 1.0)

	# Call Godot 4.3+ haptic API with amplitude control
	# Note: On iOS 26.1, this may log "(null)" errors but still works
	# See docs/gemini-haptic-research.md section 7.2 for details
	Input.vibrate_handheld(duration_ms, amplitude)


## Utility: Play custom haptic with specific duration and amplitude
## Use this for special effects or fine-tuned feedback
func play_custom(duration_ms: int, amplitude: float) -> void:
	if not enabled or not _platform_supports_haptics:
		return

	if OS.has_feature("editor"):
		return

	# Clamp to safe ranges
	duration_ms = clampi(duration_ms, 1, 5000)
	amplitude = clampf(amplitude, 0.0, 1.0)

	Input.vibrate_handheld(duration_ms, amplitude)
