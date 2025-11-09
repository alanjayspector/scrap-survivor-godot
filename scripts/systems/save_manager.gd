extends Node
## SaveManager - Coordinates saving/loading across all game services
##
## Week 6 Day 3: High-level save/load coordinator
##
## Responsibilities:
## - Collect state from all services via serialize()
## - Pass consolidated data to SaveSystem
## - Restore state to all services via deserialize()
## - Trigger auto-save at appropriate times
##
## Usage:
##   SaveManager.save_all_services()  # Manual save
##   SaveManager.load_all_services()  # Manual load
##   SaveManager.enable_auto_save()   # Enable 5-min auto-save

# Constants
const AUTO_SAVE_INTERVAL_SEC = 300.0  # 5 minutes
const CURRENT_SAVE_VERSION = 1

# Signals
signal save_started
signal save_completed(success: bool)
signal load_started
signal load_completed(success: bool)
signal auto_save_triggered

# Auto-save state
var _auto_save_enabled: bool = false
var _auto_save_timer: Timer = null
var _unsaved_changes: bool = false


func _ready() -> void:
	# Listen for service changes to track unsaved changes
	_connect_service_signals()

	# Set up exit handler for save-on-quit (not in headless mode)
	if not DisplayServer.get_name() == "headless":
		get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Auto-save before quit if enabled and there are changes
		if _auto_save_enabled and _unsaved_changes:
			GameLogger.info("Auto-saving before quit...")
			save_all_services()

		get_tree().quit()


## Save all game services to specified slot
## Returns true if save succeeded
func save_all_services(slot: int = 0) -> bool:
	save_started.emit()

	GameLogger.info("Saving all services", {"slot": slot})

	# Collect state from all services
	var save_data = {
		"version": CURRENT_SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"game_time": Time.get_ticks_msec(),
		"services": {}
	}

	# Serialize each service
	if is_instance_valid(BankingService):
		save_data.services["banking"] = BankingService.serialize()

	if is_instance_valid(ShopRerollService):
		save_data.services["shop_reroll"] = ShopRerollService.serialize()

	if is_instance_valid(RecyclerService):
		save_data.services["recycler"] = RecyclerService.serialize()

	if is_instance_valid(ErrorService):
		save_data.services["error"] = ErrorService.serialize()

	# Write to disk via SaveSystem
	var result = SaveSystem.save_game(save_data, slot)

	if result.success:
		_unsaved_changes = false
		GameLogger.info("All services saved successfully", {"slot": slot})
		save_completed.emit(true)
		return true

	GameLogger.error("Failed to save services", {"slot": slot, "error": result.error})
	save_completed.emit(false)
	return false


## Load all game services from specified slot
## Returns true if load succeeded
func load_all_services(slot: int = 0) -> bool:
	load_started.emit()

	GameLogger.info("Loading all services", {"slot": slot})

	# Read from disk via SaveSystem
	var result = SaveSystem.load_game(slot)

	if not result.success:
		GameLogger.error("Failed to load save file", {"slot": slot, "error": result.error})
		load_completed.emit(false)
		return false

	var save_data = result.data

	# Validate save version
	var version = save_data.get("version", 0)
	if version > CURRENT_SAVE_VERSION:
		GameLogger.error(
			"Save from newer version",
			{"save_version": version, "current_version": CURRENT_SAVE_VERSION}
		)
		load_completed.emit(false)
		return false

	# Deserialize all services
	if save_data.has("services"):
		var services = save_data.services

		if services.has("banking") and is_instance_valid(BankingService):
			BankingService.deserialize(services.banking)

		if services.has("shop_reroll") and is_instance_valid(ShopRerollService):
			ShopRerollService.deserialize(services.shop_reroll)

		if services.has("recycler") and is_instance_valid(RecyclerService):
			RecyclerService.deserialize(services.recycler)

		if services.has("error") and is_instance_valid(ErrorService):
			ErrorService.deserialize(services.error)

	_unsaved_changes = false
	GameLogger.info("All services loaded successfully", {"slot": slot})
	load_completed.emit(true)
	return true


## Check if a save exists for specified slot
func has_save(slot: int = 0) -> bool:
	return SaveSystem.has_save(slot)


## Delete save for specified slot
func delete_save(slot: int = 0) -> bool:
	var success = SaveSystem.delete_save(slot)
	if success:
		GameLogger.info("Save deleted", {"slot": slot})
	return success


## Enable auto-save (every 5 minutes)
func enable_auto_save() -> void:
	if _auto_save_enabled:
		GameLogger.warning("Auto-save already enabled")
		return

	_auto_save_enabled = true

	# Create timer if needed
	if not _auto_save_timer:
		_auto_save_timer = Timer.new()
		_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL_SEC
		_auto_save_timer.one_shot = false
		_auto_save_timer.timeout.connect(_on_auto_save_timeout)
		add_child(_auto_save_timer)

	_auto_save_timer.start()
	GameLogger.info("Auto-save enabled", {"interval_sec": AUTO_SAVE_INTERVAL_SEC})


## Disable auto-save
func disable_auto_save() -> void:
	if not _auto_save_enabled:
		return

	_auto_save_enabled = false

	if _auto_save_timer:
		_auto_save_timer.stop()

	GameLogger.info("Auto-save disabled")


## Check if there are unsaved changes
func has_unsaved_changes() -> bool:
	return _unsaved_changes


## Get metadata about a save slot
func get_save_metadata(slot: int = 0) -> SaveSystem.SaveMetadata:
	return SaveSystem.get_save_metadata(slot)


## Reset all services and clear saves (for testing)
func reset() -> void:
	# Reset all services
	if is_instance_valid(BankingService):
		BankingService.reset()

	if is_instance_valid(ShopRerollService):
		ShopRerollService.reset()

	if is_instance_valid(RecyclerService):
		RecyclerService.reset()

	if is_instance_valid(ErrorService):
		ErrorService.reset()

	# Clear save files
	SaveSystem.reset()

	_unsaved_changes = false
	GameLogger.info("SaveManager: All services and saves reset")


## Internal: Connect to service signals to track unsaved changes
func _connect_service_signals() -> void:
	# Connect to banking service signals
	if is_instance_valid(BankingService):
		if not BankingService.currency_changed.is_connected(_on_service_changed):
			BankingService.currency_changed.connect(_on_service_changed)

	# Connect to shop reroll service signals
	if is_instance_valid(ShopRerollService):
		if not ShopRerollService.reroll_executed.is_connected(_on_service_changed):
			ShopRerollService.reroll_executed.connect(_on_service_changed)
		if not ShopRerollService.reroll_count_reset.is_connected(_on_service_changed):
			ShopRerollService.reroll_count_reset.connect(_on_service_changed)


## Internal: Handle service state changes
func _on_service_changed(_arg1 = null, _arg2 = null) -> void:
	_unsaved_changes = true


## Internal: Handle auto-save timer timeout
func _on_auto_save_timeout() -> void:
	if not _unsaved_changes:
		GameLogger.info("Auto-save skipped (no changes)")
		return

	GameLogger.info("Auto-save triggered")
	auto_save_triggered.emit()
	save_all_services(0)  # Always save to slot 0
