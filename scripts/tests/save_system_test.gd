extends GutTest
## Test script for SaveSystem using GUT framework
##
## Tests save/load cycles, multiple slots, metadata, deletion, and corruption recovery.

class_name SaveSystemTest


func before_each() -> void:
	# Reset save system before each test
	SaveSystem.reset()


func after_each() -> void:
	# Cleanup all save slots
	for slot in range(10):
		SaveSystem.delete_save(slot)


# Basic Save/Load Tests
func test_save_game_succeeds() -> void:
	var test_data = {"player_name": "TestPlayer", "level": 42, "gold": 1000}

	var save_result = SaveSystem.save_game(test_data, 0)

	assert_true(save_result.success, "Save should succeed")
	assert_eq(save_result.slot, 0, "Save should be in slot 0")


func test_load_game_succeeds() -> void:
	var test_data = {"player_name": "TestPlayer", "level": 42, "gold": 1000}
	SaveSystem.save_game(test_data, 0)

	var load_result = SaveSystem.load_game(0)

	assert_true(load_result.success, "Load should succeed")
	assert_eq(load_result.slot, 0, "Load should be from slot 0")


func test_loaded_data_matches_saved_data() -> void:
	var test_data = {"player_name": "TestPlayer", "level": 42, "gold": 1000}
	SaveSystem.save_game(test_data, 0)

	var load_result = SaveSystem.load_game(0)

	assert_true(load_result.data.has("player_name"), "Should have player_name")
	assert_eq(load_result.data.player_name, "TestPlayer", "Player name should match")
	assert_eq(load_result.data.level, 42, "Level should match")
	assert_eq(load_result.data.gold, 1000, "Gold should match")


# Multiple Slots Tests
func test_save_to_multiple_slots() -> void:
	for slot in range(3):
		var data = {"slot_id": slot, "value": slot * 100}
		var result = SaveSystem.save_game(data, slot)

		assert_true(result.success, "Save to slot %d should succeed" % slot)


func test_load_from_multiple_slots() -> void:
	# Save to 3 slots
	for slot in range(3):
		var data = {"slot_id": slot, "value": slot * 100}
		SaveSystem.save_game(data, slot)

	# Load and verify
	for slot in range(3):
		var result = SaveSystem.load_game(slot)

		assert_true(result.success, "Load from slot %d should succeed" % slot)
		assert_eq(result.data.slot_id, slot, "Slot ID should match for slot %d" % slot)
		assert_eq(result.data.value, slot * 100, "Value should match for slot %d" % slot)


# Metadata Tests
func test_non_existent_save_metadata() -> void:
	var meta = SaveSystem.get_save_metadata(0)

	assert_false(meta.exists, "Non-existent save should have exists=false")


func test_existing_save_metadata() -> void:
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	var meta = SaveSystem.get_save_metadata(0)

	assert_true(meta.exists, "Existing save should have exists=true")
	assert_eq(meta.version, 1, "Version should be 1")
	assert_eq(meta.slot, 0, "Slot should be 0")
	assert_gt(meta.timestamp, 0, "Timestamp should be set")
	assert_false(meta.has_backup, "New save should not have backup")


func test_second_save_creates_backup() -> void:
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)
	SaveSystem.save_game(data, 0)  # Second save

	var meta = SaveSystem.get_save_metadata(0)

	assert_true(meta.has_backup, "Second save should create backup")


# Delete Save Tests
func test_save_exists_after_creation() -> void:
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	assert_true(SaveSystem.has_save(0), "Save should exist after creation")


func test_save_deleted_successfully() -> void:
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	var delete_result = SaveSystem.delete_save(0)

	assert_true(delete_result, "Delete should succeed")
	assert_false(SaveSystem.has_save(0), "Save should not exist after delete")


# has_save() Tests
func test_has_save_detects_empty_slots() -> void:
	assert_false(SaveSystem.has_save(0), "Slot 0 should be empty")
	assert_false(SaveSystem.has_save(1), "Slot 1 should be empty")


func test_has_save_detects_existing_save() -> void:
	SaveSystem.save_game({"test": "data"}, 0)

	assert_true(SaveSystem.has_save(0), "Slot 0 should have save")
	assert_false(SaveSystem.has_save(1), "Slot 1 should still be empty")


# Invalid Slot Tests
func test_negative_slot_save_fails() -> void:
	var save_result = SaveSystem.save_game({"test": "data"}, -1)

	assert_false(save_result.success, "Negative slot should fail")
	assert_true("Invalid slot" in save_result.error, "Error should mention invalid slot")


func test_too_large_slot_save_fails() -> void:
	var save_result = SaveSystem.save_game({"test": "data"}, 999)

	assert_false(save_result.success, "Slot 999 should fail")


func test_invalid_slot_load_fails() -> void:
	var load_result = SaveSystem.load_game(-1)

	assert_false(load_result.success, "Load from invalid slot should fail")


func test_invalid_slot_has_save_returns_false() -> void:
	var has_save = SaveSystem.has_save(-1)

	assert_false(has_save, "has_save should return false for invalid slot")


# Corruption Recovery Tests
func test_corruption_recovers_from_backup() -> void:
	# Create valid save
	var data = {"player": "Test", "score": 100}
	SaveSystem.save_game(data, 0)

	# Update save (creates backup)
	data["score"] = 200
	SaveSystem.save_game(data, 0)

	# Simulate corruption by writing invalid data to main save
	var save_path = "user://saves/save_0.cfg"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string("CORRUPTED DATA @#$%^&*()")
		file.close()

	# Try to load (should recover from backup)
	var load_result = SaveSystem.load_game(0)

	assert_true(load_result.success, "Should recover from backup")
	assert_not_null(load_result.data, "Data should be loaded from backup")
	if load_result.data:
		assert_eq(load_result.data.get("player", ""), "Test", "Player name should be from backup")
		assert_eq(load_result.data.get("score", 0), 100, "Score should be from backup (first save)")


# Version Validation Tests
func test_save_with_current_version() -> void:
	var data = {"test": "data"}

	var save_result = SaveSystem.save_game(data, 0)

	assert_true(save_result.success, "Save should succeed")


func test_load_verifies_version() -> void:
	var data = {"test": "data"}
	SaveSystem.save_game(data, 0)

	var load_result = SaveSystem.load_game(0)

	assert_true(load_result.success, "Load should succeed")
	assert_eq(load_result.data._meta.version, 1, "Version should be 1")


func test_future_version_rejected() -> void:
	# Manually create save with future version
	var config = ConfigFile.new()
	config.set_value("_meta", "version", 999)
	config.set_value("_meta", "timestamp", Time.get_unix_time_from_system())
	config.set_value("main", "test", "future data")
	config.save("user://saves/save_1.cfg")

	# Try to load future version
	var load_result = SaveSystem.load_game(1)

	assert_false(load_result.success, "Future version should fail to load")
	assert_true("newer version" in load_result.error, "Error should mention newer version")
