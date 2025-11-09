extends Node
## SaveSystem - Core save/load infrastructure with corruption recovery
##
## Week 6: Local-first save system using Godot ConfigFile
##
## Features:
## - Multiple save slots (0-9)
## - Atomic writes (write to temp, rename on success)
## - Automatic backup (.bak files)
## - Corruption detection and recovery
## - Version management
##
## Usage:
##   var result = SaveSystem.save_game(data, 0)
##   var result = SaveSystem.load_game(0)

# Constants
const SAVE_DIR = "user://saves/"
const MAX_SLOTS = 10
const CURRENT_VERSION = 1


# Save result structure
class SaveResult:
	var success: bool
	var error: String
	var slot: int

	func _init(p_success: bool, p_error: String = "", p_slot: int = 0):
		success = p_success
		error = p_error
		slot = p_slot


# Load result structure
class LoadResult:
	var success: bool
	var error: String
	var data: Dictionary
	var slot: int

	func _init(p_success: bool, p_data: Dictionary = {}, p_error: String = "", p_slot: int = 0):
		success = p_success
		data = p_data
		error = p_error
		slot = p_slot


# Save metadata structure
class SaveMetadata:
	var exists: bool
	var version: int
	var timestamp: int
	var slot: int
	var has_backup: bool

	func _init(
		p_exists: bool = false,
		p_version: int = 0,
		p_timestamp: int = 0,
		p_slot: int = 0,
		p_backup: bool = false
	):
		exists = p_exists
		version = p_version
		timestamp = p_timestamp
		slot = p_slot
		has_backup = p_backup


# Signals
signal save_started(slot: int)
signal save_completed(success: bool, slot: int)
signal load_started(slot: int)
signal load_completed(success: bool, slot: int)


func _ready() -> void:
	# Ensure save directory exists
	_ensure_save_directory()


## Save game data to specified slot
## Uses atomic write (temp file + rename) for safety
func save_game(data: Dictionary, slot: int = 0) -> SaveResult:
	if not _is_valid_slot(slot):
		return SaveResult.new(false, "Invalid slot: %d" % slot, slot)

	save_started.emit(slot)

	# Add metadata to save data
	var save_data = data.duplicate(true)
	save_data["_meta"] = {
		"version": CURRENT_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"slot": slot,
	}

	var save_path = _get_save_path(slot)
	var temp_path = save_path + ".tmp"
	var backup_path = save_path + ".bak"

	# Step 1: Write to temporary file
	var config = ConfigFile.new()

	# Store data in ConfigFile sections
	for key in save_data.keys():
		var value = save_data[key]
		if value is Dictionary:
			# Store dictionaries as separate section
			for subkey in value.keys():
				config.set_value(key, subkey, value[subkey])
		else:
			# Store primitives in "main" section
			config.set_value("main", key, value)

	var save_error = config.save(temp_path)
	if save_error != OK:
		GameLogger.error("Failed to write save file", {"slot": slot, "error": save_error})
		save_completed.emit(false, slot)
		return SaveResult.new(false, "Failed to write save file: %d" % save_error, slot)

	# Step 2: Create backup of existing save (if exists)
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			# Remove old backup
			if FileAccess.file_exists(backup_path):
				dir.remove(backup_path)

			# Rename current save to backup
			var rename_error = dir.rename(save_path, backup_path)
			if rename_error != OK:
				GameLogger.warning("Failed to create backup", {"slot": slot, "error": rename_error})

	# Step 3: Rename temp file to final save file (atomic operation)
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		GameLogger.error("Failed to open save directory", {"path": SAVE_DIR})
		save_completed.emit(false, slot)
		return SaveResult.new(false, "Failed to access save directory", slot)

	var rename_error = dir.rename(temp_path, save_path)
	if rename_error != OK:
		GameLogger.error("Failed to finalize save", {"slot": slot, "error": rename_error})
		save_completed.emit(false, slot)
		return SaveResult.new(false, "Failed to finalize save: %d" % rename_error, slot)

	GameLogger.info("Game saved successfully", {"slot": slot})
	save_completed.emit(true, slot)

	return SaveResult.new(true, "", slot)


## Load game data from specified slot
## Attempts to recover from backup if main save is corrupted
func load_game(slot: int = 0) -> LoadResult:
	if not _is_valid_slot(slot):
		return LoadResult.new(false, {}, "Invalid slot: %d" % slot, slot)

	load_started.emit(slot)

	var save_path = _get_save_path(slot)

	if not FileAccess.file_exists(save_path):
		GameLogger.info("No save file found", {"slot": slot})
		load_completed.emit(false, slot)
		return LoadResult.new(false, {}, "No save file found", slot)

	# Attempt to load main save
	var result = _load_save_file(save_path, slot)

	if result.success:
		load_completed.emit(true, slot)
		return result

	# Main save failed, try backup
	GameLogger.warning("Main save corrupted, attempting backup", {"slot": slot})
	var backup_path = save_path + ".bak"

	if FileAccess.file_exists(backup_path):
		result = _load_save_file(backup_path, slot)

		if result.success:
			GameLogger.info("Recovered from backup", {"slot": slot})
			load_completed.emit(true, slot)
			return result

	# Both failed
	GameLogger.error("Failed to load save (main and backup corrupted)", {"slot": slot})
	load_completed.emit(false, slot)
	return LoadResult.new(false, {}, "Save file corrupted and backup failed", slot)


## Check if a save exists for the specified slot
func has_save(slot: int = 0) -> bool:
	if not _is_valid_slot(slot):
		return false

	return FileAccess.file_exists(_get_save_path(slot))


## Delete save file for specified slot
func delete_save(slot: int = 0) -> bool:
	if not _is_valid_slot(slot):
		return false

	var save_path = _get_save_path(slot)
	var backup_path = save_path + ".bak"

	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		return false

	var success = true

	# Delete main save
	if FileAccess.file_exists(save_path):
		if dir.remove(save_path) != OK:
			success = false

	# Delete backup
	if FileAccess.file_exists(backup_path):
		if dir.remove(backup_path) != OK:
			success = false

	if success:
		GameLogger.info("Save deleted", {"slot": slot})

	return success


## Get metadata about a save slot without loading full data
func get_save_metadata(slot: int = 0) -> SaveMetadata:
	if not _is_valid_slot(slot):
		return SaveMetadata.new()

	var save_path = _get_save_path(slot)

	if not FileAccess.file_exists(save_path):
		return SaveMetadata.new(false, 0, 0, slot, false)

	var config = ConfigFile.new()
	var load_error = config.load(save_path)

	if load_error != OK:
		return SaveMetadata.new(false, 0, 0, slot, false)

	var version = config.get_value("_meta", "version", 0)
	var timestamp = config.get_value("_meta", "timestamp", 0)
	var has_backup = FileAccess.file_exists(save_path + ".bak")

	return SaveMetadata.new(true, version, timestamp, slot, has_backup)


## Internal: Load save file and parse into dictionary
func _load_save_file(file_path: String, slot: int) -> LoadResult:
	var config = ConfigFile.new()
	var load_error = config.load(file_path)

	if load_error != OK:
		return LoadResult.new(false, {}, "Failed to load file: %d" % load_error, slot)

	# Parse ConfigFile back into dictionary
	var data = {}

	for section in config.get_sections():
		if section == "main":
			# Load primitives from main section
			for key in config.get_section_keys(section):
				data[key] = config.get_value(section, key)
		else:
			# Load dictionaries from other sections
			data[section] = {}
			for key in config.get_section_keys(section):
				data[section][key] = config.get_value(section, key)

	# Validate version
	if data.has("_meta"):
		var version = data["_meta"].get("version", 0)
		if version > CURRENT_VERSION:
			return LoadResult.new(false, {}, "Save file from newer version: %d" % version, slot)

	return LoadResult.new(true, data, "", slot)


## Internal: Ensure save directory exists
func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var error = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		if error != OK:
			GameLogger.error("Failed to create save directory", {"path": SAVE_DIR, "error": error})
		else:
			GameLogger.info("Created save directory", {"path": SAVE_DIR})


## Internal: Check if slot number is valid
func _is_valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < MAX_SLOTS


## Internal: Get save file path for slot
func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_%d.cfg" % slot


## Reset all save data (for testing only)
func reset() -> void:
	for slot in range(MAX_SLOTS):
		delete_save(slot)

	GameLogger.info("All saves deleted (reset)")
