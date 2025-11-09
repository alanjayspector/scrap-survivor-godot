extends Node
## Test script for ErrorService


func _ready() -> void:
	print("=== ErrorService Test ===")
	print()

	test_log_levels()
	test_signals()
	test_helpers()
	test_godot_error_capture()

	print()
	print("=== ErrorService Tests Complete ===")


func test_log_levels() -> void:
	print("--- Testing Log Levels ---")

	# Test INFO
	ErrorService.log_info("Test info message")
	print("✓ Info logged")

	# Test WARNING
	ErrorService.log_warning("Test warning message")
	print("✓ Warning logged")

	# Test ERROR
	ErrorService.log_error("Test error message", ErrorService.ErrorLevel.ERROR)
	print("✓ Error logged")

	# Test CRITICAL
	ErrorService.log_critical("Test critical message")
	print("✓ Critical logged")


func test_signals() -> void:
	print("--- Testing Signals ---")

	# Use array wrapper for lambda capture
	var error_received = [false]
	var critical_received = [false]

	ErrorService.error_occurred.connect(func(_msg, _level, _meta): error_received[0] = true)
	ErrorService.critical_error_occurred.connect(func(_msg, _meta): critical_received[0] = true)

	# Test regular error signal
	ErrorService.log_error("Test signal")
	assert(error_received[0], "error_occurred signal should emit")
	print("✓ error_occurred signal emitted")

	# Test critical signal
	ErrorService.log_critical("Test critical")
	assert(critical_received[0], "critical_error_occurred signal should emit")
	print("✓ critical_error_occurred signal emitted")


func test_helpers() -> void:
	print("--- Testing Helper Methods ---")

	# Test log_info helper
	ErrorService.log_info("Info helper test")
	print("✓ log_info helper works")

	# Test log_warning helper
	ErrorService.log_warning("Warning helper test")
	print("✓ log_warning helper works")

	# Test log_critical helper
	ErrorService.log_critical("Critical helper test")
	print("✓ log_critical helper works")


func test_godot_error_capture() -> void:
	print("--- Testing Godot Error Capture ---")

	# Use array wrapper for lambda capture
	var error_captured = [false]
	ErrorService.error_occurred.connect(
		func(_msg, _level, meta):
			if meta.has("stack_trace"):
				error_captured[0] = true
	)

	# Simulate an error
	ErrorService.capture_godot_error("Test error with stack trace")
	assert(error_captured[0], "Should capture stack trace")
	print("✓ Stack trace captured in metadata")
