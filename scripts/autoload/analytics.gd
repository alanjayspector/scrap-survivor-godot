extends Node
## Analytics - Track user events for product decisions
## Week 15 Phase 1: Placeholder implementation (logs to GameLogger)
## Week 16+: Wire up to actual analytics service (Firebase, Mixpanel, etc.)
##
## Purpose: Instrument all user actions now, connect to real analytics later.
## This provides funnel tracking, feature validation, and bug detection.


func _ready() -> void:
	GameLogger.info("[Analytics] Analytics service initialized (placeholder mode)")


func track_event(event_name: String, properties: Dictionary = {}) -> void:
	"""Track user event - currently logs, will wire to analytics later"""
	GameLogger.info("[Analytics] Event tracked", {"event": event_name, "properties": properties})

	# Week 16+: Send to actual analytics service
	# if AnalyticsService.is_initialized():
	#     AnalyticsService.send_event(event_name, properties)


# ============================================================================
# Hub Events
# ============================================================================


func hub_opened() -> void:
	"""Hub/Scrapyard scene opened"""
	track_event("hub_opened", {})


func hub_button_pressed(button: String) -> void:
	"""Button pressed in hub"""
	track_event("hub_button_pressed", {"button": button})


# ============================================================================
# Character Events
# ============================================================================


func character_created(character_type: String) -> void:
	"""New character created"""
	track_event("character_created", {"type": character_type})


func character_deleted(character_type: String, level: int) -> void:
	"""Character deleted"""
	track_event("character_deleted", {"type": character_type, "level": level})


func character_selected(character_type: String, level: int) -> void:
	"""Character selected for play"""
	track_event("character_selected", {"type": character_type, "level": level})


# ============================================================================
# Run Events
# ============================================================================


func run_started(character_type: String, level: int) -> void:
	"""Combat run started"""
	track_event("run_started", {"type": character_type, "level": level})


func run_ended(wave: int, kills: int, duration: float) -> void:
	"""Combat run ended (death)"""
	track_event("run_ended", {"wave": wave, "kills": kills, "duration_seconds": duration})


# ============================================================================
# First-Run Events
# ============================================================================


func first_launch() -> void:
	"""First time app launched (no save file exists)"""
	track_event("first_launch", {})


func tutorial_started() -> void:
	"""Tutorial overlay shown"""
	track_event("tutorial_started", {})


func tutorial_completed() -> void:
	"""Tutorial dismissed/completed"""
	track_event("tutorial_completed", {})


# ============================================================================
# Save Corruption Events (Critical for Debugging)
# ============================================================================


func save_corruption_detected(source: String, error: String) -> void:
	"""Save file corruption detected"""
	track_event("save_corruption_detected", {"source": source, "error": error})


func save_recovered_from_backup() -> void:
	"""Save successfully recovered from backup file"""
	track_event("save_recovered_from_backup", {})


func save_recovered_from_cloud() -> void:
	"""Save successfully recovered from cloud"""
	track_event("save_recovered_from_cloud", {})


# ============================================================================
# Session Events
# ============================================================================


func session_started() -> void:
	"""App session started"""
	track_event(
		"session_started",
		{
			"platform": OS.get_name(),
			"version": ProjectSettings.get_setting("application/config/version", "unknown")
		}
	)


func session_ended() -> void:
	"""App session ended (quit)"""
	track_event("session_ended", {})
