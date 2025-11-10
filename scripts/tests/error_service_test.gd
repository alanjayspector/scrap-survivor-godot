extends GutTest
## Test script for ErrorService using GUT framework
##
## Tests logging, signal emission, and Godot error capture.

class_name ErrorServiceTest


func before_each() -> void:
	# Reset error service before each test
	ErrorService.reset()


func after_each() -> void:
	# Cleanup
	pass


func test_error_occurred_signal_emits_on_error() -> void:
	# Arrange
	watch_signals(ErrorService)

	# Act
	ErrorService.log_error("Test signal")

	# Assert
	assert_signal_emitted(ErrorService, "error_occurred", "error_occurred signal should emit")
	assert_signal_emit_count(ErrorService, "error_occurred", 1, "Signal should emit once")

	var signal_params = get_signal_parameters(ErrorService, "error_occurred", 0)
	assert_eq(signal_params[0], "Test signal", "Signal should contain error message")


func test_critical_error_occurred_signal_emits_on_critical() -> void:
	# Arrange
	watch_signals(ErrorService)

	# Act
	ErrorService.log_critical("Test critical")

	# Assert
	assert_signal_emitted(
		ErrorService, "critical_error_occurred", "critical_error_occurred signal should emit"
	)
	assert_signal_emit_count(
		ErrorService, "critical_error_occurred", 1, "Critical signal should emit once"
	)

	var signal_params = get_signal_parameters(ErrorService, "critical_error_occurred", 0)
	assert_eq(signal_params[0], "Test critical", "Signal should contain critical message")


func test_godot_error_capture_includes_stack_trace_in_metadata() -> void:
	# Arrange
	watch_signals(ErrorService)

	# Act
	ErrorService.capture_godot_error("Test error with stack trace")

	# Assert
	assert_signal_emitted(ErrorService, "error_occurred", "Should emit error_occurred signal")

	var signal_params = get_signal_parameters(ErrorService, "error_occurred", 0)
	var metadata = signal_params[2]  # Third parameter is metadata
	assert_true(
		metadata.has("stack_trace"),
		"Metadata should contain stack_trace when capturing Godot errors"
	)
