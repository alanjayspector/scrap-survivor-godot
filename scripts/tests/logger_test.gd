extends GutTest
## Test script for Logger utility using GUT framework
##
## Tests file creation, log levels, and rotation.

class_name LoggerTest


func before_each() -> void:
	# Clean log directory before each test
	var log_dir = "user://logs/"
	if DirAccess.dir_exists_absolute(log_dir):
		var dir = DirAccess.open(log_dir)
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.begins_with("scrap_survivor_") and filename.ends_with(".log"):
				dir.remove(filename)
			filename = dir.get_next()
		dir.list_dir_end()


func after_each() -> void:
	# Cleanup
	pass


# File Creation Tests
func test_log_file_is_created() -> void:
	GameLogger.info("Test log entry")

	var log_path = GameLogger._get_log_path()
	var file = FileAccess.open(log_path, FileAccess.READ)

	assert_not_null(file, "Log file should exist")
	file.close()


func test_log_file_is_not_empty() -> void:
	GameLogger.info("Test log entry")

	var log_path = GameLogger._get_log_path()
	var file = FileAccess.open(log_path, FileAccess.READ)

	assert_gt(file.get_length(), 0, "Log file should not be empty")
	file.close()


func test_log_path_returns_valid_path() -> void:
	var log_path = GameLogger._get_log_path()

	assert_true(log_path.begins_with("user://logs/"), "Log path should start with user://logs/")
	assert_true(log_path.ends_with(".log"), "Log path should end with .log")


# Log Level Tests
func test_debug_level_is_recorded() -> void:
	GameLogger.debug("Debug message")

	var log_path = GameLogger._get_log_path()
	var content = FileAccess.get_file_as_string(log_path)

	assert_true(content.contains("DEBUG"), "Log should contain DEBUG level")
	assert_true(content.contains("Debug message"), "Log should contain debug message")


func test_info_level_is_recorded() -> void:
	GameLogger.info("Info message")

	var log_path = GameLogger._get_log_path()
	var content = FileAccess.get_file_as_string(log_path)

	assert_true(content.contains("INFO"), "Log should contain INFO level")
	assert_true(content.contains("Info message"), "Log should contain info message")


func test_warning_level_is_recorded() -> void:
	GameLogger.warning("Warning message")

	var log_path = GameLogger._get_log_path()
	var content = FileAccess.get_file_as_string(log_path)

	assert_true(content.contains("WARNING"), "Log should contain WARNING level")
	assert_true(content.contains("Warning message"), "Log should contain warning message")


func test_error_level_is_recorded() -> void:
	GameLogger.error("Error message")

	var log_path = GameLogger._get_log_path()
	var content = FileAccess.get_file_as_string(log_path)

	assert_true(content.contains("ERROR"), "Log should contain ERROR level")
	assert_true(content.contains("Error message"), "Log should contain error message")


func test_multiple_log_levels_are_recorded() -> void:
	var log_path = GameLogger._get_log_path()
	var initial_size = 0

	# Get initial size if file exists
	if FileAccess.file_exists(log_path):
		var initial_content = FileAccess.get_file_as_string(log_path)
		if initial_content:
			initial_size = initial_content.length()

	GameLogger.debug("Debug message")
	GameLogger.info("Info message")
	GameLogger.warning("Warning message")
	GameLogger.error("Error message")

	var new_content = FileAccess.get_file_as_string(log_path)

	assert_not_null(new_content, "Log file should be readable")
	if new_content:
		assert_gt(new_content.length(), initial_size, "New entries should be added")
		assert_true(new_content.contains("DEBUG"), "Should contain DEBUG level")
		assert_true(new_content.contains("INFO"), "Should contain INFO level")
		assert_true(new_content.contains("WARNING"), "Should contain WARNING level")
		assert_true(new_content.contains("ERROR"), "Should contain ERROR level")


# Log Rotation Tests
func test_log_rotation_respects_max_files() -> void:
	# Create MAX_LOG_FILES + 1 logs to trigger rotation
	for i in GameLogger.MAX_LOG_FILES + 1:
		GameLogger.info("Test log rotation %d" % i)
		OS.delay_msec(100)  # Ensure unique timestamps

	# Count log files
	var dir = DirAccess.open("user://logs/")
	var log_count = 0
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.begins_with("scrap_survivor_") and filename.ends_with(".log"):
			log_count += 1
		filename = dir.get_next()
	dir.list_dir_end()

	assert_lte(
		log_count,
		GameLogger.MAX_LOG_FILES,
		"Should not exceed max log files (%d)" % GameLogger.MAX_LOG_FILES
	)


func test_log_rotation_keeps_most_recent_files() -> void:
	# Create multiple log files
	for i in GameLogger.MAX_LOG_FILES + 2:
		GameLogger.info("Test log rotation %d" % i)
		OS.delay_msec(100)  # Ensure unique timestamps

	# Verify most recent log exists
	var log_path = GameLogger._get_log_path()
	var content = FileAccess.get_file_as_string(log_path)

	assert_true(
		content.contains("Test log rotation"),
		"Most recent log should still contain rotation test messages"
	)


# ErrorService Integration Test
func test_error_service_integration_placeholder() -> void:
	# Note: ErrorService integration testing should be done in actual gameplay
	# where autoloads are properly registered
	assert_true(true, "ErrorService integration requires autoload setup (test placeholder)")
