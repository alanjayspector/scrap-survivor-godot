extends Node
## Test script for Logger utility


func _ready() -> void:
	print("=== Logger Test ===")
	print()

	test_file_creation()
	test_log_levels()
	test_log_rotation()
	test_error_service_integration()

	print()
	print("=== Logger Tests Complete ===")


func test_file_creation() -> void:
	print("--- Testing File Creation ---")

	# Ensure clean state
	var log_dir = "user://logs/"
	if DirAccess.dir_exists_absolute(log_dir):
		var dir = DirAccess.open(log_dir)
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			dir.remove(filename)
			filename = dir.get_next()

	# Test first log
	GameLogger.info("Test log entry")

	var log_path = GameLogger._get_log_path()
	var file = FileAccess.open(log_path, FileAccess.READ)
	assert(file, "Log file should exist")
	assert(file.get_length() > 0, "Log file should not be empty")
	file.close()
	print("✓ Log file created at: %s" % log_path)


func test_log_levels() -> void:
	print("--- Testing Log Levels ---")

	var log_path = GameLogger._get_log_path()
	var initial_size = FileAccess.get_file_as_string(log_path).length()

	GameLogger.debug("Debug message")
	GameLogger.info("Info message")
	GameLogger.warning("Warning message")
	GameLogger.error("Error message")

	var new_content = FileAccess.get_file_as_string(log_path)
	assert(new_content.length() > initial_size, "New entries should be added")
	assert(new_content.contains("DEBUG"), "Should contain debug level")
	assert(new_content.contains("WARNING"), "Should contain warning level")
	print("✓ All log levels recorded")


func test_log_rotation() -> void:
	print("--- Testing Log Rotation ---")

	# Create MAX_LOG_FILES + 1 logs
	for i in GameLogger.MAX_LOG_FILES + 1:
		GameLogger.info("Test log rotation %d" % i)
		OS.delay_msec(100)  # Ensure unique timestamps

	var dir = DirAccess.open("user://logs/")
	var log_count = 0
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.begins_with("scrap_survivor_") and filename.ends_with(".log"):
			log_count += 1
		filename = dir.get_next()

	assert(log_count <= GameLogger.MAX_LOG_FILES, "Should not exceed max log files")
	print("✓ Log rotation keeps <= %d files" % GameLogger.MAX_LOG_FILES)


func test_error_service_integration() -> void:
	print("--- Testing ErrorService Integration ---")
	print("⚠️ ErrorService integration requires autoload setup (test skipped)")
	# Note: ErrorService integration testing should be done in actual gameplay
	# where autoloads are properly registered
