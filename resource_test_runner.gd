extends SceneTree
## Resource Test Runner - Run resource tests in Godot Editor
##
## This script runs ONLY the resource tests (weapon, enemy, entity, item)
## that are disabled in CI but can run in the editor.
##
## Usage: Set this scene as main scene temporarily and run with F5
## Or run from command line: godot --path . -s resource_test_runner.gd


func _init():
	var gut = load("res://addons/gut/gut.gd").new()

	# Configure GUT - Use editor-only versions with flags enabled
	gut.add_script("res://scripts/tests/editor_only/weapon_loading_test.gd")
	gut.add_script("res://scripts/tests/editor_only/enemy_loading_test.gd")
	gut.add_script("res://scripts/tests/editor_only/entity_classes_test.gd")
	gut.add_script("res://scripts/tests/editor_only/item_resources_test.gd")

	gut.include_subdirectories = false
	gut.log_level = gut.LOG_LEVEL_ALL_ASSERTS  # Show all test output
	gut.should_maximize = true

	# Print header
	print("=== Resource Tests Runner ===")
	print("Running 4 test files (108 total tests):")
	print("  - weapon_loading_test.gd (14 tests)")
	print("  - enemy_loading_test.gd (23 tests)")
	print("  - entity_classes_test.gd (30 tests)")
	print("  - item_resources_test.gd (41 tests)")
	print("")

	# Run tests
	add_child(gut)
	gut.test_scripts(true)  # true = print results

	# Wait for tests to complete
	await gut.test_ran

	print("")
	print("=== Resource Tests Complete ===")
	print("Tests passed: ", gut.get_pass_count())
	print("Tests failed: ", gut.get_fail_count())
	print("Total assertions: ", gut.get_assert_count())

	quit()
