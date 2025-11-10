extends SceneTree
## Simple test runner to verify GUT can find tests
## Run with: godot --script test_runner.gd


func _init():
	var gut = load("res://addons/gut/gut.gd").new()

	# Configure GUT
	gut.add_directory("res://scripts/tests", "", "_test.gd")
	gut.include_subdirectories = true
	gut.log_level = 1  # Info level

	# Print what tests were found
	print("=== GUT Test Discovery ===")
	print("Scanning: res://scripts/tests")
	print("Pattern: *_test.gd")
	print("")

	# Run tests
	gut.run_tests()

	print("")
	print("=== Test Discovery Complete ===")
	print("Check output above for test files found")

	quit()
