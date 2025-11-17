extends Node
## Global game state management autoload
##
## Tracks game state variables and emits signals when state changes.
## Configured in Project Settings → Autoload as "GameState".
## Week 15 Phase 1: Added run tracking and active character management

## Emitted when current wave changes
signal wave_changed(new_wave: int)

## Emitted when score changes
signal score_changed(new_score: int)

## Emitted when gameplay state changes
signal gameplay_state_changed(is_active: bool)

## Emitted when current character changes
signal character_changed(character_id: String)

## Week 15: Emitted when active character is set
signal character_activated(character_id: String)

## Week 15: Emitted when a run starts
signal run_started(character_id: String)

## Week 15: Emitted when a run ends with stats
signal run_ended(stats: Dictionary)

## Current game state variables
var current_user: String = ""
var current_character: String = ""  # Legacy - use active_character_id
var is_gameplay_active: bool = false
var current_wave: int = 0
var score: int = 0
var high_score: int = 0
var difficulty: String = "normal"
var is_paused: bool = false

## Week 15: Active character ID (persists across scenes)
var active_character_id: String = ""

## Week 15: Run tracking
var current_run_active: bool = false
var run_start_time: float = 0.0


func set_current_wave(wave: int) -> void:
	"""Set current wave and emit signal"""
	if wave == current_wave:
		return

	current_wave = wave
	wave_changed.emit(wave)


func set_score(new_score: int) -> void:
	"""Set score and update high score if needed"""
	if new_score == score:
		return

	score = new_score
	high_score = max(high_score, score)
	score_changed.emit(score)


func add_score(amount: int) -> void:
	"""Add to score"""
	set_score(score + amount)


func set_gameplay_active(active: bool) -> void:
	"""Set gameplay state (active/inactive)"""
	if active == is_gameplay_active:
		return

	is_gameplay_active = active
	gameplay_state_changed.emit(active)


func set_current_character(character_id: String) -> void:
	"""Set current character"""
	if character_id == current_character:
		return

	current_character = character_id
	character_changed.emit(character_id)


func reset_game_state() -> void:
	"""Reset all state for new game"""
	set_current_wave(0)
	set_score(0)
	set_gameplay_active(false)
	set_current_character("")
	active_character_id = ""  # Clear active character (Week 15 Phase 4 fix)
	is_paused = false


## Week 15: Set the active character for the next run
func set_active_character(character_id: String) -> void:
	"""Set the active character for the next run"""
	active_character_id = character_id
	character_activated.emit(character_id)
	GameLogger.info("[GameState] Active character set", {"character_id": character_id})


## Week 15: Start a new combat run
func start_run() -> void:
	"""Start a new combat run with the active character"""
	if active_character_id.is_empty():
		GameLogger.error("[GameState] Cannot start run - no active character")
		return

	current_run_active = true
	run_start_time = Time.get_ticks_msec() / 1000.0
	current_wave = 0

	run_started.emit(active_character_id)
	GameLogger.info("[GameState] Run started", {"character_id": active_character_id})


## Week 15: End the current run and return stats
func end_run(stats: Dictionary) -> void:
	"""End the current run and emit stats"""
	if not current_run_active:
		GameLogger.warning("[GameState] end_run called but no active run")
		return

	current_run_active = false
	var run_duration = (Time.get_ticks_msec() / 1000.0) - run_start_time
	stats["duration"] = run_duration
	stats["character_id"] = active_character_id

	run_ended.emit(stats)
	GameLogger.info("[GameState] Run ended", stats)


## Week 15: Get the active character data from CharacterService
func get_active_character() -> Dictionary:
	"""Get the active character data from CharacterService"""
	if active_character_id.is_empty():
		GameLogger.warning("[GameState] No active character set")
		return {}

	# Access CharacterService (Week 6 service)
	if not is_instance_valid(CharacterService):
		GameLogger.error("[GameState] CharacterService not available")
		return {}

	return CharacterService.get_character(active_character_id)


func _to_string() -> String:
	return (
		"GameState(wave=%d, score=%d, active=%s, char=%s, active_char=%s, run_active=%s)"
		% [
			current_wave,
			score,
			is_gameplay_active,
			current_character,
			active_character_id,
			current_run_active
		]
	)
