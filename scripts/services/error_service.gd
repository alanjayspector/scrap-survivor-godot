extends Node
## Centralized error handling and logging service
##
## Usage:
##   ErrorService.log_error("Message", ErrorService.ErrorLevel.ERROR)
##   ErrorService.log_warning("Warning message")
## Configure in Project Settings → Autoload as "ErrorService"

## Error severity levels:
## - INFO: General information
## - WARNING: Recoverable issue
## - ERROR: Operation failed
## - CRITICAL: Game-breaking issue
enum ErrorLevel { INFO, WARNING, ERROR, CRITICAL }

## Emitted when an error occurs
signal error_occurred(message: String, level: ErrorLevel, metadata: Dictionary)

## Emitted specifically for critical errors
signal critical_error_occurred(message: String, metadata: Dictionary)


func log_error(
	message: String, level: ErrorLevel = ErrorLevel.ERROR, metadata: Dictionary = {}
) -> void:
	"""Log an error with severity level and optional metadata"""
	# Format the message with metadata if present
	var full_message = message
	if not metadata.is_empty():
		full_message += " | Metadata: " + str(metadata)

	# Emit signals
	error_occurred.emit(message, level, metadata)

	if level == ErrorLevel.CRITICAL:
		critical_error_occurred.emit(message, metadata)

	# Print to console with appropriate prefix
	var prefix = ""
	match level:
		ErrorLevel.INFO:
			prefix = "[INFO] "
		ErrorLevel.WARNING:
			prefix = "[WARNING] "
		ErrorLevel.ERROR:
			prefix = "[ERROR] "
		ErrorLevel.CRITICAL:
			prefix = "[CRITICAL] "

	print(prefix + full_message)


func log_info(message: String, metadata: Dictionary = {}) -> void:
	"""Helper for INFO level messages"""
	log_error(message, ErrorLevel.INFO, metadata)


func log_warning(message: String, metadata: Dictionary = {}) -> void:
	"""Helper for WARNING level messages"""
	log_error(message, ErrorLevel.WARNING, metadata)


func log_critical(message: String, metadata: Dictionary = {}) -> void:
	"""Helper for CRITICAL level messages"""
	log_error(message, ErrorLevel.CRITICAL, metadata)


func capture_godot_error(
	error: String, error_level: ErrorLevel = ErrorLevel.ERROR, metadata: Dictionary = {}
) -> void:
	"""Capture and log a Godot error with stack trace"""
	var stack_trace = get_stack()
	metadata["stack_trace"] = stack_trace
	log_error(error, error_level, metadata)


func _to_string() -> String:
	return "ErrorService"
