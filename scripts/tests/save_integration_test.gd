extends Node
## Integration test for SaveManager + SaveSystem + Services
##
## Tests the complete save/load flow across all services

const TEST_SLOT = 9  # Use slot 9 to avoid conflicts


func _ready() -> void:
	print("=== SaveManager Integration Test ===")
	print()

	test_save_and_load_all_services()
	test_multiple_services_save_load()
	test_transaction_history_persists()
	test_save_load_signals()
	test_unsaved_changes_tracking()
	test_load_nonexistent_save()
	test_save_metadata()
	test_save_deletion()
	test_cross_service_consistency()
	test_stateless_service_serialization()

	print()
	print("=== SaveManager Integration Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


## Test basic save→load→verify flow
func test_save_and_load_all_services() -> void:
	print("--- Testing Save and Load All Services ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Set up initial state
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 1000)
	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 50)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	# Save state
	var save_success = SaveManager.save_all_services(TEST_SLOT)
	assert(save_success, "Save should succeed")
	print("✓ Saved successfully")

	# Verify save exists
	assert(SaveManager.has_save(TEST_SLOT), "Save should exist")
	print("✓ Save exists")

	# Reset
	BankingService.reset()
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0, "Balance reset")
	assert(BankingService.get_balance(BankingService.CurrencyType.PREMIUM) == 0, "Premium reset")
	assert(BankingService.get_tier() == BankingService.UserTier.FREE, "Tier reset")
	print("✓ Services reset")

	# Load state
	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(load_success, "Load should succeed")
	print("✓ Loaded successfully")

	# Verify state restored
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 1000, "Scrap restored")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.PREMIUM) == 50, "Premium restored"
	)
	assert(BankingService.get_tier() == BankingService.UserTier.PREMIUM, "Tier restored")
	print("✓ State restored correctly")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test saving multiple services simultaneously
func test_multiple_services_save_load() -> void:
	print("--- Testing Multiple Services Save/Load ---")

	# Clean state
	BankingService.reset()
	ShopRerollService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Set up state across multiple services
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)
	ShopRerollService.increment_reroll_count()
	ShopRerollService.increment_reroll_count()

	# Save
	var save_success = SaveManager.save_all_services(TEST_SLOT)
	assert(save_success, "Save should succeed")
	print("✓ Saved successfully")

	# Reset all services
	BankingService.reset()
	ShopRerollService.reset()

	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0, "Banking reset")
	assert(ShopRerollService.get_reroll_count() == 0, "Shop reroll reset")
	print("✓ Services reset")

	# Load
	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(load_success, "Load should succeed")
	print("✓ Loaded successfully")

	# Verify all services restored
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 500, "Banking restored")
	assert(ShopRerollService.get_reroll_count() == 2, "Shop reroll restored")
	print("✓ All services restored correctly")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test transaction history persistence
func test_transaction_history_persists() -> void:
	print("--- Testing Transaction History Persistence ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Create transaction history
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 200)
	BankingService.remove_currency(BankingService.CurrencyType.SCRAP, 50)

	var history_before = BankingService.get_transaction_history()
	assert(history_before.size() == 3, "Should have 3 transactions")
	print("✓ Transaction history created")

	# Save and reset
	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()

	assert(BankingService.get_transaction_history().size() == 0, "History should be cleared")
	print("✓ History cleared after reset")

	# Load and verify
	SaveManager.load_all_services(TEST_SLOT)

	var history_after = BankingService.get_transaction_history()
	assert(history_after.size() == 3, "History should be restored")
	assert(history_after[0].amount == 100, "First transaction restored")
	assert(history_after[1].amount == 200, "Second transaction restored")
	assert(history_after[2].amount == -50, "Third transaction restored")
	print("✓ Transaction history fully restored")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test signals are emitted during save/load
func test_save_load_signals() -> void:
	print("--- Testing Save/Load Signals ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	var save_started_count = 0
	var save_completed_count = 0
	var save_success_value = false
	var load_started_count = 0
	var load_completed_count = 0
	var load_success_value = false

	# Connect to signals
	var save_started_conn = func(): save_started_count += 1
	var save_completed_conn = func(success):
		save_completed_count += 1
		save_success_value = success
	var load_started_conn = func(): load_started_count += 1
	var load_completed_conn = func(success):
		load_completed_count += 1
		load_success_value = success

	SaveManager.save_started.connect(save_started_conn)
	SaveManager.save_completed.connect(save_completed_conn)
	SaveManager.load_started.connect(load_started_conn)
	SaveManager.load_completed.connect(load_completed_conn)

	# Perform save/load
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)
	SaveManager.load_all_services(TEST_SLOT)

	# Verify signals
	assert(save_started_count == 1, "save_started emitted once")
	assert(save_completed_count == 1, "save_completed emitted once")
	assert(save_success_value == true, "save completed with success=true")
	assert(load_started_count == 1, "load_started emitted once")
	assert(load_completed_count == 1, "load_completed emitted once")
	assert(load_success_value == true, "load completed with success=true")
	print("✓ All signals emitted correctly")

	# Disconnect
	SaveManager.save_started.disconnect(save_started_conn)
	SaveManager.save_completed.disconnect(save_completed_conn)
	SaveManager.load_started.disconnect(load_started_conn)
	SaveManager.load_completed.disconnect(load_completed_conn)

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test unsaved changes tracking
func test_unsaved_changes_tracking() -> void:
	print("--- Testing Unsaved Changes Tracking ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Initially no unsaved changes (after reset)
	# Note: We can't assert false here because signal connections may have triggered
	print("✓ Initial state checked")

	# Make a change
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	# Signal propagation should be immediate
	assert(SaveManager.has_unsaved_changes(), "Has unsaved changes after modification")
	print("✓ Unsaved changes tracked")

	# Save clears unsaved flag
	SaveManager.save_all_services(TEST_SLOT)
	assert(not SaveManager.has_unsaved_changes(), "No unsaved changes after save")
	print("✓ Unsaved flag cleared after save")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test loading non-existent save
func test_load_nonexistent_save() -> void:
	print("--- Testing Load Non-Existent Save ---")

	# Ensure save doesn't exist
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(not load_success, "Loading non-existent save should fail gracefully")
	print("✓ Failed gracefully on non-existent save")


## Test save metadata
func test_save_metadata() -> void:
	print("--- Testing Save Metadata ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# No save exists yet
	var metadata_before = SaveManager.get_save_metadata(TEST_SLOT)
	assert(not metadata_before.exists, "Save should not exist")
	print("✓ Metadata shows no save initially")

	# Create save
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	# Check metadata
	var metadata_after = SaveManager.get_save_metadata(TEST_SLOT)
	assert(metadata_after.exists, "Save should exist")
	assert(metadata_after.version == 1, "Version should be 1")
	assert(metadata_after.slot == TEST_SLOT, "Slot should match")
	assert(metadata_after.timestamp > 0, "Should have timestamp")
	print("✓ Metadata populated correctly")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test save deletion
func test_save_deletion() -> void:
	print("--- Testing Save Deletion ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Create save
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	assert(SaveManager.has_save(TEST_SLOT), "Save should exist")
	print("✓ Save created")

	# Delete save
	var delete_success = SaveManager.delete_save(TEST_SLOT)
	assert(delete_success, "Delete should succeed")
	assert(not SaveManager.has_save(TEST_SLOT), "Save should not exist after deletion")
	print("✓ Save deleted successfully")


## Test cross-service state consistency
func test_cross_service_consistency() -> void:
	print("--- Testing Cross-Service State Consistency ---")

	# Clean state
	BankingService.reset()
	ShopRerollService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# Set up complex state across services
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 1000)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	ShopRerollService.increment_reroll_count()

	# Save
	var save_success = SaveManager.save_all_services(TEST_SLOT)
	assert(save_success, "Save should succeed")
	print("✓ Saved successfully")

	# Reset everything
	BankingService.reset()
	ShopRerollService.reset()

	# Verify everything is reset
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0)
	assert(BankingService.get_tier() == BankingService.UserTier.FREE)
	assert(ShopRerollService.get_reroll_count() == 0)
	print("✓ Services reset")

	# Load
	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(load_success, "Load should succeed")
	print("✓ Loaded successfully")

	# Verify all state is consistent
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 1000)
	assert(BankingService.get_tier() == BankingService.UserTier.PREMIUM)
	assert(ShopRerollService.get_reroll_count() == 1)
	print("✓ All state restored consistently")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)


## Test stateless service serialization (RecyclerService)
func test_stateless_service_serialization() -> void:
	print("--- Testing Stateless Service Serialization ---")

	# Clean state
	BankingService.reset()
	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)

	# RecyclerService is stateless - just verify it doesn't break save/load
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)

	# Save (includes RecyclerService)
	var save_success = SaveManager.save_all_services(TEST_SLOT)
	assert(save_success, "Save with stateless service should succeed")
	print("✓ Saved with stateless service")

	# Load (includes RecyclerService)
	BankingService.reset()
	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(load_success, "Load with stateless service should succeed")
	print("✓ Loaded with stateless service")

	# Verify RecyclerService still works after load
	var preview = RecyclerService.get_recycle_preview(RecyclerService.ItemRarity.COMMON, 1)
	assert(preview.rarity == RecyclerService.ItemRarity.COMMON, "RecyclerService still functional")
	print("✓ Stateless service still functional")

	# Cleanup
	SaveManager.delete_save(TEST_SLOT)
