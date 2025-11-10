extends Node
## ShopRerollService - Progressive cost calculation for shop rerolls
##
## Ported from supabase/functions/shop-reroll/index.ts
## Week 5: Local-first architecture (no Supabase, in-memory state)
##
## Manages shop reroll costs that increase exponentially with each reroll:
## - Cost = BASE_COST * (COST_MULTIPLIER ^ reroll_count)
## - Resets daily based on game day
## - Tracks reroll count per day
##
## Usage:
##   var preview = ShopRerollService.get_reroll_preview()
##   var result = ShopRerollService.execute_reroll()

# Cost calculation constants (from edge function environment variables)
const BASE_COST = 50
const COST_MULTIPLIER = 2
const MAX_REROLL_COUNT = 99


# Reroll state structure
class RerollState:
	var game_day: String
	var reroll_count: int

	func _init(p_day: String = "", p_count: int = 0):
		game_day = p_day
		reroll_count = p_count


# Reroll preview (shows cost without executing)
class RerollPreview:
	var game_day: String
	var reroll_count: int
	var cost: int
	var next_cost: int

	func _init(p_day: String, p_count: int, p_cost: int, p_next: int):
		game_day = p_day
		reroll_count = p_count
		cost = p_cost
		next_cost = p_next


# Reroll execution result
class RerollExecution:
	var game_day: String
	var reroll_count: int
	var charged_cost: int
	var next_cost: int

	func _init(p_day: String, p_count: int, p_charged: int, p_next: int):
		game_day = p_day
		reroll_count = p_count
		charged_cost = p_charged
		next_cost = p_next


# Signals
signal reroll_executed(execution: RerollExecution)
signal reroll_count_reset(game_day: String)
signal state_loaded

# Internal state (Week 5: in-memory only, will persist in Week 6+)
var _current_state: RerollState = RerollState.new()


## Get current reroll preview (cost and count)
## Returns RerollPreview with current state
func get_reroll_preview() -> RerollPreview:
	var today = _get_game_day()

	# Check if day changed (reset count)
	if _current_state.game_day != today:
		_reset_for_new_day(today)

	var current_count = mini(_current_state.reroll_count, MAX_REROLL_COUNT)
	var cost = _calculate_cost(current_count)
	var next_count = mini(current_count + 1, MAX_REROLL_COUNT)
	var next_cost = _calculate_cost(next_count)

	return RerollPreview.new(today, current_count, cost, next_cost)


## Execute shop reroll and increment count
## Returns RerollExecution with charged cost
func execute_reroll() -> RerollExecution:
	var today = _get_game_day()

	# Check if day changed (reset count)
	if _current_state.game_day != today:
		_reset_for_new_day(today)

	var current_count = mini(_current_state.reroll_count, MAX_REROLL_COUNT)
	var charged_cost = _calculate_cost(current_count)

	# Increment reroll count (capped at MAX)
	var next_count = mini(current_count + 1, MAX_REROLL_COUNT)
	_current_state.reroll_count = next_count
	# Calculate cost for the reroll after the next one
	var next_next_count = mini(next_count + 1, MAX_REROLL_COUNT)
	var next_cost = _calculate_cost(next_next_count)

	(
		GameLogger
		. info(
			"Shop reroll executed",
			{
				"game_day": today,
				"reroll_count": next_count,
				"charged_cost": charged_cost,
				"next_cost": next_cost,
			}
		)
	)

	var execution = RerollExecution.new(today, next_count, charged_cost, next_cost)
	reroll_executed.emit(execution)

	return execution


## Get current reroll count for today
func get_reroll_count() -> int:
	var today = _get_game_day()
	if _current_state.game_day != today:
		return 0  # New day, not yet reset
	return _current_state.reroll_count


## Reset service state (for testing)
func reset() -> void:
	reset_reroll_count()


## Reset reroll count (for testing or admin use)
func reset_reroll_count() -> void:
	var today = _get_game_day()
	_current_state.game_day = today
	_current_state.reroll_count = 0
	reroll_count_reset.emit(today)


## Serialize service state to dictionary (Week 6)
func serialize() -> Dictionary:
	return {
		"version": 1,
		"game_day": _current_state.game_day,
		"reroll_count": _current_state.reroll_count,
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state from dictionary (Week 6)
func deserialize(data: Dictionary) -> void:
	if data.get("version", 0) != 1:
		GameLogger.warning("ShopRerollService: Unknown save version", data)
		return

	# Restore state
	_current_state.game_day = data.get("game_day", "")
	_current_state.reroll_count = data.get("reroll_count", 0)

	# Auto-reset if day changed since save
	var today = _get_game_day()
	if _current_state.game_day != today:
		GameLogger.info(
			"Shop reroll count reset (day changed since save)",
			{"saved_day": _current_state.game_day, "current_day": today}
		)
		_reset_for_new_day(today)
	else:
		GameLogger.info(
			"ShopRerollService state loaded",
			{"game_day": _current_state.game_day, "reroll_count": _current_state.reroll_count}
		)

	state_loaded.emit()


## Calculate reroll cost based on count
## Formula: BASE_COST * (COST_MULTIPLIER ^ count)
func _calculate_cost(count: int) -> int:
	var sanitized_count = maxi(0, count)
	return roundi(BASE_COST * pow(COST_MULTIPLIER, sanitized_count))


## Get current game day (ISO date string YYYY-MM-DD)
func _get_game_day() -> String:
	var time = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [time.year, time.month, time.day]


## Reset reroll count for new day
func _reset_for_new_day(new_day: String) -> void:
	var old_day = _current_state.game_day

	_current_state.game_day = new_day
	_current_state.reroll_count = 0

	if old_day != new_day and not old_day.is_empty():
		(
			GameLogger
			. info(
				"Shop reroll count reset for new day",
				{
					"old_day": old_day,
					"new_day": new_day,
				}
			)
		)
		reroll_count_reset.emit(new_day)
