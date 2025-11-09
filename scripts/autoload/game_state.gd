extends Node
## Global game state management autoload
##
## Tracks game state variables and emits signals when state changes.
## Configured in Project Settings → Autoload as "GameState".

## Emitted when current wave changes
signal wave_changed(new_wave: int)

## Emitted when score changes
signal score_changed(new_score: int)

## Emitted when gameplay state changes
signal gameplay_state_changed(is_active: bool)

## Emitted when current character changes
signal character_changed(character_id: String)

## Current game state variables
var current_user: String = ""
var current_character: String = ""
var is_gameplay_active: bool = false
var current_wave: int = 0
var score: int = 0
var high_score: int = 0
var difficulty: String = "normal"
var is_paused: bool = false


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
	is_paused = false


func _to_string() -> String:
	return (
		"GameState(wave=%d, score=%d, active=%s, char=%s)"
		% [current_wave, score, is_gameplay_active, current_character]
	)
