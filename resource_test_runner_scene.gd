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
	var gut_scene = $GutScene

	if gut_scene and gut_scene.has_node("Gut"):
		var gut = gut_scene.get_node("Gut")

		# Clear any existing scripts
		gut.clear()

		# Add only resource test scripts
		gut.add_script("res://scripts/tests/weapon_loading_test.gd")
		gut.add_script("res://scripts/tests/enemy_loading_test.gd")
		gut.add_script("res://scripts/tests/entity_classes_test.gd")
		gut.add_script("res://scripts/tests/item_resources_test.gd")

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
	else:
		push_error("GutScene or Gut node not found!")
