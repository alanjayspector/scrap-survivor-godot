extends Control
## Hub - The Scrapyard
## Week 15 Phase 1: Central hub scene for navigation
##
## Features:
## - Main menu navigation (Play, Characters, Settings, Quit)
## - First-run detection and guided character creation
## - Save corruption handling with user feedback
## - Audio feedback (button clicks)
## - Analytics instrumentation

## Audio (iOS-compatible preload pattern)
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var characters_button: Button = $MenuContainer/CharactersButton
@onready var settings_button: Button = $MenuContainer/SettingsButton
@onready var quit_button: Button = $MenuContainer/QuitButton
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var debug_qa_button: Button = $DebugQAButton

var is_first_run: bool = false


func _ready() -> void:
	var start_time = Time.get_ticks_msec()

	GameLogger.info("[Hub] Scrapyard initializing", {"has_save": SaveManager.has_save(0)})

	# Track hub opened
	if is_instance_valid(Analytics):
		Analytics.hub_opened()

	_check_first_run()
	_connect_signals()
	_setup_buttons()

	# Load saved data if exists
	if SaveManager.has_save(0):
		var load_result = SaveManager.load_all_services()
		if load_result.success:
			GameLogger.info("[Hub] Save data loaded successfully", {"source": load_result.source})

			# Track if recovered from backup
			if load_result.source == "backup" and is_instance_valid(Analytics):
				Analytics.save_recovered_from_backup()
		else:
			# Save corruption - show dialog and treat as first run
			GameLogger.error(
				"[Hub] Failed to load save data - treating as first run",
				{"error": load_result.error}
			)
			_show_save_corruption_dialog()
			is_first_run = true

	var init_duration = Time.get_ticks_msec() - start_time
	GameLogger.info(
		"[Hub] Scrapyard initialized",
		{"init_duration_ms": init_duration, "is_first_run": is_first_run}
	)

	# Auto-navigate to character creation on first run (with small delay for UX)
	# Week 15 Phase 1: Disabled until Phase 2 (character_creation.tscn) is implemented
	if is_first_run:
		if is_instance_valid(Analytics):
			Analytics.first_launch()
		GameLogger.info("[Hub] First run detected - auto-navigation disabled until Phase 2")
		# TODO Phase 2: Uncomment this when character_creation.tscn exists
		# await get_tree().create_timer(0.5).timeout
		# _launch_first_run_flow()


func _exit_tree() -> void:
	GameLogger.info("[Hub] Scrapyard cleanup complete")


func _check_first_run() -> void:
	"""Detect if this is the first time the game has been launched"""
	is_first_run = not SaveManager.has_save(0)

	if is_first_run:
		GameLogger.info("[Hub] First run detected - will trigger character creation")


func _connect_signals() -> void:
	"""Connect button signals"""
	play_button.pressed.connect(_on_play_pressed)
	characters_button.pressed.connect(_on_characters_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	debug_qa_button.pressed.connect(_on_debug_qa_pressed)


func _setup_buttons() -> void:
	"""Configure button states based on game state"""
	# Disable settings button (not implemented in Week 15)
	settings_button.disabled = true
	settings_button.tooltip_text = "Coming in Week 16"

	# Show debug QA button ONLY in debug builds (Week 16 Priority 1)
	if OS.is_debug_build():
		debug_qa_button.visible = true
		GameLogger.info("[Hub] Debug QA button enabled (debug build)")
	else:
		debug_qa_button.visible = false

	# If first run, force character creation flow
	if is_first_run:
		play_button.text = "Start Adventure"
		characters_button.disabled = true  # No characters exist yet
		characters_button.tooltip_text = "Create your first character to unlock"


func _launch_first_run_flow() -> void:
	"""Launch first-run character creation flow"""
	GameLogger.info("[Hub] Launching first-run flow")
	get_tree().change_scene_to_file("res://scenes/ui/character_creation.tscn")


func _show_save_corruption_dialog() -> void:
	"""Show dialog when save data is corrupted"""
	# Week 15: Log the issue (dialog UI in future sprint)
	GameLogger.error("[Hub] Save corruption dialog should be shown")
	# TODO Week 16: Create AcceptDialog popup with "Start Fresh" / "Contact Support"


func _play_button_click_sound() -> void:
	"""Play button click sound"""
	if audio_player and BUTTON_CLICK_SOUND:
		audio_player.stream = BUTTON_CLICK_SOUND
		audio_player.play()


func _on_play_pressed() -> void:
	"""Handle Play button - launch character selection or creation"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Play")

	GameLogger.info(
		"[Hub] Play button pressed",
		{
			"is_first_run": is_first_run,
			"target_scene": "character_creation" if is_first_run else "character_roster"
		}
	)

	# Week 15 Phase 1: Temporary fallback until Phase 2/3 scenes exist
	if is_first_run:
		# First run: Force character creation (Phase 2 - not yet implemented)
		if ResourceLoader.exists("res://scenes/ui/character_creation.tscn"):
			get_tree().change_scene_to_file("res://scenes/ui/character_creation.tscn")
		else:
			GameLogger.warning("[Hub] character_creation.tscn not yet implemented (Phase 2)")
			# Temporary: Go to old character selection as fallback
			get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
	else:
		# Has characters: Show character roster (Phase 3 - not yet implemented)
		if ResourceLoader.exists("res://scenes/ui/character_roster.tscn"):
			get_tree().change_scene_to_file("res://scenes/ui/character_roster.tscn")
		else:
			GameLogger.warning("[Hub] character_roster.tscn not yet implemented (Phase 3)")
			# Temporary: Go to old character selection as fallback
			get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _on_characters_pressed() -> void:
	"""Handle Characters button - view character roster"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Characters")

	GameLogger.info("[Hub] Characters button pressed")

	# Week 15 Phase 1: Temporary fallback until Phase 3 exists
	if ResourceLoader.exists("res://scenes/ui/character_roster.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/character_roster.tscn")
	else:
		GameLogger.warning("[Hub] character_roster.tscn not yet implemented (Phase 3)")
		# Temporary: Go to old character selection as fallback
		get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _on_settings_pressed() -> void:
	"""Handle Settings button - open settings menu"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Settings")

	GameLogger.warning("[Hub] Settings button pressed but not implemented (Week 15)")


func _on_quit_pressed() -> void:
	"""Handle Quit button - exit game"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Quit")
		Analytics.session_ended()

	GameLogger.info(
		"[Hub] Quit button pressed", {"has_unsaved_changes": SaveManager.has_unsaved_changes()}
	)

	# Save before quit if unsaved changes
	if SaveManager.has_unsaved_changes():
		GameLogger.info("[Hub] Saving before quit...")
		var save_success = SaveManager.save_all_services()
		if save_success:
			GameLogger.info("[Hub] Save successful before quit")
		else:
			GameLogger.error("[Hub] Save failed before quit")

	get_tree().quit()


func _on_debug_qa_pressed() -> void:
	"""Handle Debug QA button - open debug menu for tier testing (Week 16 Priority 1)"""
	_play_button_click_sound()

	# Safety check - should never reach here in production
	if not OS.is_debug_build():
		GameLogger.error(
			"[Hub] Debug QA button pressed in production build - THIS IS A CRITICAL ERROR"
		)
		return

	GameLogger.warning("[Hub] Debug QA button pressed - opening debug menu")

	# Load and show debug menu
	var debug_menu_scene = load("res://scenes/debug/debug_menu.tscn")
	if debug_menu_scene:
		var debug_menu = debug_menu_scene.instantiate()
		add_child(debug_menu)
		debug_menu.popup_centered()
	else:
		GameLogger.error("[Hub] Failed to load debug menu scene")
