extends Panel
## Game Over screen shown when player dies
## Week 15 Phase 5: Enhanced with XP award and character progression

signal retry_pressed
signal main_menu_pressed

@onready var game_over_label: Label = $PaddingContainer/Content/GameOverLabel
@onready var stats_display: VBoxContainer = $PaddingContainer/Content/StatsDisplay
@onready var xp_gained_label: Label = $PaddingContainer/Content/XPContainer/XPGainedLabel
@onready var level_up_label: Label = $PaddingContainer/Content/XPContainer/LevelUpLabel
@onready var xp_progress_bar: ProgressBar = $PaddingContainer/Content/XPContainer/XPProgressBar
@onready var retry_button: Button = $PaddingContainer/Content/ButtonsContainer/RetryButton
@onready var main_menu_button: Button = $PaddingContainer/Content/ButtonsContainer/MainMenuButton

var run_stats: Dictionary = {}
var character_id: String = ""


func _ready() -> void:
	# Allow UI to work when game is paused (PROCESS_MODE_ALWAYS)
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()  # Hidden by default
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func show_game_over(stats: Dictionary, char_id: String = "") -> void:
	"""Display game over screen with stats and award XP (Week 15 Phase 5)"""
	run_stats = stats
	character_id = char_id

	GameLogger.info(
		"[GameOverScreen] Shown",
		{
			"character_id": character_id,
			"wave": stats.get("wave", 0),
			"kills": stats.get("kills", 0),
			"damage_dealt": stats.get("damage_dealt", 0),
			"time": stats.get("time", 0)
		}
	)

	# Clear previous stats
	for child in stats_display.get_children():
		child.queue_free()

	# Add stats with larger font for mobile
	_add_stat_label("Wave Reached: %d" % stats.get("wave", 0))
	_add_stat_label("Enemies Killed: %d" % stats.get("kills", 0))
	_add_stat_label("Damage Dealt: %s" % _format_number(stats.get("damage_dealt", 0)))
	_add_stat_label("Survival Time: %s" % _format_time(stats.get("time", 0)))

	# Add currency stats (matching HUD display)
	_add_stat_label("")  # Spacer
	_add_stat_label("Scrap: %d" % stats.get("scrap", 0))
	_add_stat_label("Components: %d" % stats.get("components", 0))
	_add_stat_label("Nanites: %d" % stats.get("nanites", 0))

	# Award XP and update character (Week 15 Phase 5)
	if not character_id.is_empty():
		_award_xp()
		_update_character_records()
	else:
		# No character (shouldn't happen in normal flow)
		GameLogger.warning("[GameOverScreen] No character_id provided - skipping XP award")
		xp_gained_label.text = "XP Gained: N/A"
		level_up_label.hide()

	show()


func _award_xp() -> void:
	"""Calculate and award XP to character (Week 15 Phase 5)"""
	# XP formula: 10 XP per wave + 1 XP per 10 enemies killed
	var wave = run_stats.get("wave", 0)
	var kills = run_stats.get("kills", 0)

	var xp_from_waves = wave * 10
	var xp_from_kills = int(kills / 10)
	var total_xp = xp_from_waves + xp_from_kills

	GameLogger.info(
		"[GameOverScreen] Calculating XP",
		{
			"character_id": character_id,
			"wave": wave,
			"kills": kills,
			"xp_from_waves": xp_from_waves,
			"xp_from_kills": xp_from_kills,
			"total_xp": total_xp
		}
	)

	# Award XP to character
	var result = CharacterService.add_xp(character_id, total_xp)

	# Update XP gained label
	xp_gained_label.text = "XP Gained: +%d" % total_xp

	# Show level up if occurred
	if result.get("leveled_up", false):
		var new_level = result.get("new_level", 1)
		var levels_gained = result.get("levels_gained", 1)

		if levels_gained > 1:
			level_up_label.text = "LEVEL UP! +%d LEVELS → %d" % [levels_gained, new_level]
		else:
			level_up_label.text = "LEVEL UP! → Level %d" % new_level

		level_up_label.show()

		GameLogger.info(
			"[GameOverScreen] Character leveled up!",
			{"character_id": character_id, "new_level": new_level, "levels_gained": levels_gained}
		)
	else:
		level_up_label.hide()

	# Update XP progress bar
	var character = CharacterService.get_character(character_id)
	if not character.is_empty():
		var current_level = character.get("level", 1)
		var current_xp = character.get("experience", 0)  # XP overflow toward next level
		var xp_for_next_level = current_level * CharacterService.XP_PER_LEVEL

		xp_progress_bar.max_value = xp_for_next_level
		xp_progress_bar.value = current_xp

		GameLogger.debug(
			"[GameOverScreen] XP progress updated",
			{"level": current_level, "xp": current_xp, "next_level_xp": xp_for_next_level}
		)


func _update_character_records() -> void:
	"""Update character's highest wave and total kills (Week 15 Phase 5)"""
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.warning("[GameOverScreen] Character not found", {"character_id": character_id})
		return

	var wave_reached = run_stats.get("wave", 0)
	var kills = run_stats.get("kills", 0)
	var updates = {}

	# Update highest wave if this is a new record
	if wave_reached > character.get("highest_wave", 0):
		updates["highest_wave"] = wave_reached
		GameLogger.info(
			"[GameOverScreen] New highest wave record!",
			{
				"character_id": character_id,
				"previous_highest": character.get("highest_wave", 0),
				"new_highest": wave_reached
			}
		)

	# Update total kills
	var previous_kills = character.get("total_kills", 0)
	updates["total_kills"] = previous_kills + kills

	# Update death count
	var previous_deaths = character.get("death_count", 0)
	updates["death_count"] = previous_deaths + 1

	# Apply updates
	if not updates.is_empty():
		var success = CharacterService.update_character(character_id, updates)
		if success:
			GameLogger.info(
				"[GameOverScreen] Character records updated",
				{"character_id": character_id, "updates": updates}
			)

			# Save immediately
			var save_success = SaveManager.save_all_services()
			if save_success:
				GameLogger.info("[GameOverScreen] Progress saved successfully")
			else:
				GameLogger.error("[GameOverScreen] Failed to save progress!")
		else:
			GameLogger.error(
				"[GameOverScreen] Failed to update character", {"character_id": character_id}
			)


func _add_stat_label(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)  # Mobile-friendly font size
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_constant_override("line_spacing", 4)  # Better line height
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_display.add_child(label)


func _format_number(num: int) -> String:
	"""Format number with comma separators"""
	var s = str(num)
	var result = ""
	var count = 0

	for i in range(s.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
		result = s[i] + result
		count += 1

	return result


func _format_time(seconds: float) -> String:
	"""Format seconds as MM:SS"""
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]


func _on_retry_pressed() -> void:
	GameLogger.info("[GameOverScreen] Try Again pressed", {"character_id": character_id})
	hide()
	retry_pressed.emit()


func _on_main_menu_pressed() -> void:
	GameLogger.info("[GameOverScreen] Return to Hub pressed", {"character_id": character_id})
	hide()
	main_menu_pressed.emit()
