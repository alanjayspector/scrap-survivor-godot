extends Node2D
## Resource Test Runner Scene - Run resource tests in Godot Editor
##
## This scene runs ONLY the resource tests (weapon, enemy, entity, item)
## that are disabled in CI but can run in the editor.
##
## Usage:
## 1. Open this scene in Godot: scenes/resource_test_runner.tscn
## 2. Press F6 (Run Scene) or click "Run Current Scene"
## 3. Watch the GUT UI show test results


func _ready():
	# The GutScene node itself is the GUT instance
	var gut = $GutScene

	if not gut:
		push_error("GutScene node not found!")
		return

	# Clear any existing scripts
	gut.clear()

	# Add editor-only resource test scripts (flags enabled)
	gut.add_script("res://scripts/tests/editor_only/weapon_loading_test.gd")
	gut.add_script("res://scripts/tests/editor_only/enemy_loading_test.gd")
	gut.add_script("res://scripts/tests/editor_only/entity_classes_test.gd")
	gut.add_script("res://scripts/tests/editor_only/item_resources_test.gd")

	# Configure for verbose output
	gut.log_level = gut.LOG_LEVEL_ALL_ASSERTS

	print("=== Resource Tests Runner ===")
	print("Running 4 test files (108 total tests):")
	print("  - weapon_loading_test.gd (14 tests)")
	print("  - enemy_loading_test.gd (23 tests)")
	print("  - entity_classes_test.gd (30 tests)")
	print("  - item_resources_test.gd (41 tests)")
	print("")

	# Run tests
	gut.test_scripts(true)
