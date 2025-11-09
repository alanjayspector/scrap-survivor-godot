extends Node
## Test script for SaveSystem
##
## Run this test:
## 1. Open scenes/tests/save_system_test.tscn in Godot
## 2. Press F5 to run
## 3. Check Output panel for results


func _ready() -> void:
	print("=== SaveSystem Test ===")
	print()

	test_basic_save_load()
	test_multiple_slots()
	test_save_metadata()
	test_delete_save()
	test_has_save()
	test_invalid_slots()
	test_corruption_recovery()
	test_version_validation()

	print()
	print("=== SaveSystem Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


func test_basic_save_load() -> void:
	print("--- Testing Basic Save/Load Cycle ---")

	# Reset
	SaveSystem.reset()

	# Create test data
	var test_data = {"player_name": "TestPlayer", "level": 42, "gold": 1000}

	# Save
	var save_result = SaveSystem.save_game(test_data, 0)
	assert(save_result.success, "Save should succeed")
	assert(save_result.slot == 0, "Save should be in slot 0")
	print("✓ Saved test data")

	# Load
	var load_result = SaveSystem.load_game(0)
	assert(load_result.success, "Load should succeed")
	assert(load_result.slot == 0, "Load should be from slot 0")
	print("✓ Loaded test data")

	# Verify data (ignore _meta)
	assert(load_result.data.has("player_name"), "Should have player_name")
	assert(load_result.data.player_name == "TestPlayer", "Player name should match")
	assert(load_result.data.level == 42, "Level should match")
	assert(load_result.data.gold == 1000, "Gold should match")
	print("✓ Data verified")

	# Cleanup
	SaveSystem.delete_save(0)


func test_multiple_slots() -> void:
	print("--- Testing Multiple Save Slots ---")

	# Reset
	SaveSystem.reset()

	# Save to 3 different slots
	for slot in range(3):
		var data = {"slot_id": slot, "value": slot * 100}
		var result = SaveSystem.save_game(data, slot)
		assert(result.success, "Save to slot %d should succeed" % slot)

	print("✓ Saved to 3 slots")

	# Load from each slot and verify
	for slot in range(3):
		var result = SaveSystem.load_game(slot)
		assert(result.success, "Load from slot %d should succeed" % slot)
		assert(result.data.slot_id == slot, "Slot ID should match")
		assert(result.data.value == slot * 100, "Value should match")

	print("✓ Loaded from 3 slots, data correct")

	# Cleanup
	for slot in range(3):
		SaveSystem.delete_save(slot)


func test_save_metadata() -> void:
	print("--- Testing Save Metadata ---")

	# Reset
	SaveSystem.reset()

	# Check non-existent save
	var meta = SaveSystem.get_save_metadata(0)
	assert(not meta.exists, "Non-existent save should have exists=false")
	print("✓ Non-existent save detected")

	# Create save
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	# Get metadata
	meta = SaveSystem.get_save_metadata(0)
	assert(meta.exists, "Existing save should have exists=true")
	assert(meta.version == 1, "Version should be 1")
	assert(meta.slot == 0, "Slot should be 0")
	assert(meta.timestamp > 0, "Timestamp should be set")
	assert(not meta.has_backup, "New save should not have backup")
	print("✓ Metadata correct")

	# Save again (creates backup)
	SaveSystem.save_game(data, 0)

	# Check for backup
	meta = SaveSystem.get_save_metadata(0)
	assert(meta.has_backup, "Second save should create backup")
	print("✓ Backup created")

	# Cleanup
	SaveSystem.delete_save(0)


func test_delete_save() -> void:
	print("--- Testing Delete Save ---")

	# Reset
	SaveSystem.reset()

	# Create save
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	assert(SaveSystem.has_save(0), "Save should exist")
	print("✓ Save created")

	# Delete
	var delete_result = SaveSystem.delete_save(0)
	assert(delete_result, "Delete should succeed")
	assert(not SaveSystem.has_save(0), "Save should not exist after delete")
	print("✓ Save deleted")


func test_has_save() -> void:
	print("--- Testing has_save() ---")

	# Reset
	SaveSystem.reset()

	# Check non-existent
	assert(not SaveSystem.has_save(0), "Slot 0 should be empty")
	assert(not SaveSystem.has_save(1), "Slot 1 should be empty")
	print("✓ Empty slots detected")

	# Create save in slot 0
	SaveSystem.save_game({"test": "data"}, 0)

	# Check
	assert(SaveSystem.has_save(0), "Slot 0 should have save")
	assert(not SaveSystem.has_save(1), "Slot 1 should still be empty")
	print("✓ Save detection works")

	# Cleanup
	SaveSystem.delete_save(0)


func test_invalid_slots() -> void:
	print("--- Testing Invalid Slot Handling ---")

	# Test negative slot
	var save_result = SaveSystem.save_game({"test": "data"}, -1)
	assert(not save_result.success, "Negative slot should fail")
	assert("Invalid slot" in save_result.error, "Error should mention invalid slot")
	print("✓ Negative slot rejected")

	# Test too large slot
	save_result = SaveSystem.save_game({"test": "data"}, 999)
	assert(not save_result.success, "Slot 999 should fail")
	print("✓ Too large slot rejected")

	# Test load from invalid slot
	var load_result = SaveSystem.load_game(-1)
	assert(not load_result.success, "Load from invalid slot should fail")
	print("✓ Invalid load rejected")

	# Test has_save on invalid slot
	assert(not SaveSystem.has_save(-1), "has_save should return false for invalid slot")
	print("✓ Invalid has_save handled")


func test_corruption_recovery() -> void:
	print("--- Testing Corruption Recovery ---")

	# Reset
	SaveSystem.reset()

	# Create valid save
	var data = {"player": "Test", "score": 100}
	SaveSystem.save_game(data, 0)
	print("✓ Created initial save")

	# Update save (creates backup)
	data["score"] = 200
	SaveSystem.save_game(data, 0)
	print("✓ Updated save (backup created)")

	# Simulate corruption by writing invalid data to main save
	var save_path = "user://saves/save_0.cfg"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string("CORRUPTED DATA @#$%^&*()")
		file.close()
	print("✓ Simulated corruption")

	# Try to load (should recover from backup)
	var load_result = SaveSystem.load_game(0)
	assert(load_result.success, "Should recover from backup")
	assert(load_result.data.player == "Test", "Player name should be from backup")
	assert(load_result.data.score == 100, "Score should be from backup (first save)")
	print("✓ Recovered from backup")

	# Cleanup
	SaveSystem.delete_save(0)


func test_version_validation() -> void:
	print("--- Testing Version Validation ---")

	# Reset
	SaveSystem.reset()

	# Create save with current version
	var data = {"test": "data"}
	var save_result = SaveSystem.save_game(data, 0)
	assert(save_result.success, "Save should succeed")
	print("✓ Saved with current version")

	# Load and verify version
	var load_result = SaveSystem.load_game(0)
	assert(load_result.success, "Load should succeed")
	assert(load_result.data._meta.version == 1, "Version should be 1")
	print("✓ Version correct")

	# Manually create save with future version
	var config = ConfigFile.new()
	config.set_value("_meta", "version", 999)
	config.set_value("_meta", "timestamp", Time.get_unix_time_from_system())
	config.set_value("main", "test", "future data")
	config.save("user://saves/save_1.cfg")
	print("✓ Created future version save")

	# Try to load future version (should fail)
	load_result = SaveSystem.load_game(1)
	assert(not load_result.success, "Future version should fail to load")
	assert("newer version" in load_result.error, "Error should mention newer version")
	print("✓ Future version rejected")

	# Cleanup
	SaveSystem.delete_save(0)
	SaveSystem.delete_save(1)
