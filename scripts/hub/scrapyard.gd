extends Control
## Hub - The Scrapyard
## Week 15 Phase 1: Central hub scene for navigation
## Phase 8.2c: Art Bible hub transformation with IconButton components
##
## Features:
## - Main menu navigation (Start Run, Roster, Settings)
## - First-run detection and guided character creation
## - Save corruption handling with user feedback
## - Audio feedback (button clicks)
## - Analytics instrumentation
## - Art Bible visual styling with IconButton components

## Audio (iOS-compatible preload pattern)
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")

## References to new IconButton components
@onready var start_run_button: Button = $StartRunButton
@onready var roster_button: Button = $RosterButton
@onready var shop_button: Button = $ShopButton
@onready var settings_button: Button = $SettingsButton
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


func _exit_tree() -> void:
	GameLogger.info("[Hub] Scrapyard cleanup complete")


func _check_first_run() -> void:
	"""Detect if this is the first time the game has been launched"""
	is_first_run = not SaveManager.has_save(0)

	if is_first_run:
		GameLogger.info("[Hub] First run detected - will trigger character creation")


func _connect_signals() -> void:
	"""Connect button signals - IconButton uses standard Button.pressed signal"""
	start_run_button.pressed.connect(_on_start_run_pressed)
	roster_button.pressed.connect(_on_roster_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	debug_qa_button.pressed.connect(_on_debug_qa_pressed)


func _setup_buttons() -> void:
	"""Configure button states based on game state"""
	# IconButton handles its own styling via button_variant property
	# No need for THEME_HELPER.apply_button_style() - already set in scene

	# Settings button enabled but shows "Coming Soon" toast
	settings_button.disabled = false

	# Show debug QA button ONLY in debug builds (Week 16 Priority 1)
	var is_debug = OS.is_debug_build()
	GameLogger.warning("[Hub] OS.is_debug_build() = %s" % is_debug)

	if is_debug:
		debug_qa_button.visible = true
		GameLogger.warning("[Hub] Debug QA button ENABLED and VISIBLE (bottom-right corner)")
	else:
		debug_qa_button.visible = false
		GameLogger.info("[Hub] Debug QA button hidden (not a debug build)")

	# Note: Roster (Barracks) is always enabled - users need it to recruit their first character
	# Start Run button handles the "no characters" case with a helpful message


func _show_save_corruption_dialog() -> void:
	"""Show dialog when save data is corrupted"""
	# Week 15: Log the issue (dialog UI in future sprint)
	GameLogger.error("[Hub] Save corruption dialog should be shown")
	# TODO Week 16: Create AcceptDialog popup with "Start Fresh" / "Contact Support"


func _play_button_click_sound() -> void:
	"""Play button click sound (haptic handled by IconButton)"""
	if audio_player and BUTTON_CLICK_SOUND:
		audio_player.stream = BUTTON_CLICK_SOUND
		audio_player.play()


func _on_start_run_pressed() -> void:
	"""Handle Start Run button - validate character state before launching"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("StartRun")

	var character_count := CharacterService.get_character_count()
	var active_id := CharacterService.get_active_character_id()

	GameLogger.info(
		"[Hub] Start Run button pressed",
		{
			"character_count": character_count,
			"active_character_id": active_id,
			"is_first_run": is_first_run
		}
	)

	# Check 1: No survivors exist
	if character_count == 0:
		GameLogger.info("[Hub] No survivors - showing recruitment prompt")
		ModalFactory.show_alert(
			self, "No Survivors", "Recruit a survivor at the Barracks first.", Callable()
		)
		return

	# Check 2: Survivors exist but none selected
	if active_id.is_empty():
		GameLogger.info("[Hub] No survivor selected - showing selection prompt")
		ModalFactory.show_alert(
			self, "No Survivor Selected", "Select a survivor at the Barracks first.", Callable()
		)
		return

	# Has selected survivor - show Enter Wasteland confirmation screen
	GameLogger.info("[Hub] Opening Enter Wasteland confirmation", {"character_id": active_id})
	if ResourceLoader.exists("res://scenes/ui/enter_wasteland_confirmation.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/enter_wasteland_confirmation.tscn")
	else:
		# Fallback to direct wasteland launch if confirmation screen doesn't exist
		GameLogger.warning("[Hub] enter_wasteland_confirmation.tscn not found - direct launch")
		if ResourceLoader.exists("res://scenes/game/wasteland.tscn"):
			get_tree().change_scene_to_file("res://scenes/game/wasteland.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _on_roster_pressed() -> void:
	"""Handle Roster button - view character roster"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Roster")

	GameLogger.info("[Hub] Roster button pressed")

	if ResourceLoader.exists("res://scenes/ui/barracks.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/barracks.tscn")
	else:
		GameLogger.warning("[Hub] barracks.tscn not yet implemented")
		get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")


func _on_shop_pressed() -> void:
	"""Handle Shop button - validate character state before opening shop"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Shop")

	var character_count := CharacterService.get_character_count()
	var active_id := CharacterService.get_active_character_id()

	GameLogger.info(
		"[Hub] Shop button pressed",
		{"character_count": character_count, "active_character_id": active_id}
	)

	# Check 1: No survivors exist
	if character_count == 0:
		GameLogger.info("[Hub] No survivors - showing recruitment prompt")
		ModalFactory.show_alert(
			self, "No Survivors", "Recruit a survivor at the Barracks first.", Callable()
		)
		return

	# Check 2: Survivors exist but none selected
	if active_id.is_empty():
		GameLogger.info("[Hub] No survivor selected - showing selection prompt")
		ModalFactory.show_alert(
			self, "No Survivor Selected", "Select a survivor at the Barracks first.", Callable()
		)
		return

	# Has selected survivor - open shop
	GameLogger.info("[Hub] Opening shop", {"character_id": active_id})
	if ResourceLoader.exists("res://scenes/ui/shop.tscn"):
		get_tree().change_scene_to_file("res://scenes/ui/shop.tscn")
	else:
		GameLogger.warning("[Hub] shop.tscn not yet implemented")
		ModalFactory.show_alert(self, "Coming Soon", "The Shop will be available soon.", Callable())


func _on_settings_pressed() -> void:
	"""Handle Settings button - show Coming Soon toast"""
	_play_button_click_sound()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Settings")

	GameLogger.info("[Hub] Settings button pressed - showing Coming Soon alert")

	ModalFactory.show_alert(
		self, "Coming Soon", "Settings will be available in a future update.", Callable()
	)


func _on_debug_qa_pressed() -> void:
	"""Handle Debug QA button - open debug menu for tier testing (Week 16 Priority 1)"""
	_play_button_click_sound()

	GameLogger.warning("[Hub] Debug QA button pressed!")

	# Safety check - should never reach here in production
	if not OS.is_debug_build():
		GameLogger.error(
			"[Hub] Debug QA button pressed in production build - THIS IS A CRITICAL ERROR"
		)
		return

	GameLogger.warning("[Hub] Debug build confirmed - loading debug menu scene...")

	# Load and show debug menu
	var debug_menu_scene = load("res://scenes/debug/debug_menu.tscn")
	if debug_menu_scene:
		GameLogger.info("[Hub] Debug menu scene loaded successfully")
		var debug_menu = debug_menu_scene.instantiate()
		GameLogger.info("[Hub] Debug menu instantiated - adding to scene tree...")
		add_child(debug_menu)
		GameLogger.info("[Hub] Debug menu added to scene - calling popup_centered()...")
		debug_menu.popup_centered()
		GameLogger.warning("[Hub] Debug menu popup_centered() called - should be visible now")
	else:
		GameLogger.error(
			"[Hub] Failed to load debug menu scene at res://scenes/debug/debug_menu.tscn"
		)
