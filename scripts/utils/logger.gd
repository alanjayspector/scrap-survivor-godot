## Static utility for file-based logging
class_name GameLogger
##
## Usage:
##   GameLogger.debug("Message")
##   GameLogger.error("Something broke", {"context": extra_data})

const LOG_DIR = "user://logs/"
const MAX_LOG_FILES = 5

enum Level { DEBUG, INFO, WARNING, ERROR }


static func _ensure_log_dir() -> void:
	if not DirAccess.dir_exists_absolute(LOG_DIR):
		DirAccess.make_dir_recursive_absolute(LOG_DIR)


static func _get_log_path() -> String:
	return LOG_DIR + "scrap_survivor_" + Time.get_date_string_from_system() + ".log"


static func _rotate_logs() -> void:
	var dir = DirAccess.open(LOG_DIR)
	if not dir:
		return

	var log_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("scrap_survivor_") and file_name.ends_with(".log"):
			log_files.append(file_name)
		file_name = dir.get_next()

	if log_files.size() > MAX_LOG_FILES:
		log_files.sort()
		for i in log_files.size() - MAX_LOG_FILES:
			dir.remove(LOG_DIR + log_files[i])


static func _write_log(level: Level, message: String, metadata: Dictionary = {}) -> void:
	_ensure_log_dir()

	var log_path = _get_log_path()
	var file_exists = FileAccess.file_exists(log_path)

	# Use READ_WRITE to preserve existing content, or WRITE to create new file
	var mode = FileAccess.READ_WRITE if file_exists else FileAccess.WRITE
	var file = FileAccess.open(log_path, mode)
	if not file:
		push_error("Logger failed to open file: " + log_path)
		return

	file.seek_end()

	var level_str = ""
	match level:
		Level.DEBUG:
			level_str = "DEBUG"
		Level.INFO:
			level_str = "INFO"
		Level.WARNING:
			level_str = "WARNING"
		Level.ERROR:
			level_str = "ERROR"

	var timestamp = Time.get_time_string_from_system()
	var entry = "[%s] %s: %s" % [timestamp, level_str, message]

	if not metadata.is_empty():
		entry += " | " + str(metadata)

	file.store_line(entry)
	file.close()

	# ALSO print to console in debug builds for QA visibility
	if OS.is_debug_build():
		print(entry)

	_rotate_logs()


static func debug(message: String, metadata: Dictionary = {}) -> void:
	_write_log(Level.DEBUG, message, metadata)


static func info(message: String, metadata: Dictionary = {}) -> void:
	_write_log(Level.INFO, message, metadata)


static func warning(message: String, metadata: Dictionary = {}) -> void:
	_write_log(Level.WARNING, message, metadata)


static func error(message: String, metadata: Dictionary = {}) -> void:
	_write_log(Level.ERROR, message, metadata)


static func capture_error_service() -> void:
	# Note: This method requires ErrorService to be registered as an autoload
	# It will only work when called from a Node in the scene tree
	pass
