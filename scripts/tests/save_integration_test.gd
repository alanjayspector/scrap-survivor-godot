extends GutTest
## Integration test for SaveManager + SaveSystem + Services using GUT framework
##
## USER STORY: "As a player, I want my progress saved across sessions"
##
## Tests the complete save/load flow across all services.

class_name SaveIntegrationTest

const TEST_SLOT = 9  # Use slot 9 to avoid conflicts


func before_each() -> void:
	# Clean state before each test
	BankingService.reset()
	ShopRerollService.reset()

	# Set PREMIUM tier for save/load tests (FREE tier blocks scrap transactions)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	# Save to clear unsaved changes flag after tier setup
	if SaveManager.has_save(0):
		SaveManager.delete_save(0)
	SaveManager.save_all_services(0)

	if SaveManager.has_save(TEST_SLOT):
		SaveManager.delete_save(TEST_SLOT)


func after_each() -> void:
	# Cleanup after each test
	for slot in range(10):
		if SaveManager.has_save(slot):
			SaveManager.delete_save(slot)

	BankingService.reset()
	ShopRerollService.reset()
	SaveManager.disable_auto_save()


# Save and Load All Services Tests
func test_save_all_services_succeeds() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 1000)

	var save_success = SaveManager.save_all_services(TEST_SLOT)

	assert_true(save_success, "Save should succeed")
	assert_true(SaveManager.has_save(TEST_SLOT), "Save should exist")


func test_load_all_services_restores_state() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 1000)
	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 50)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()

	var load_success = SaveManager.load_all_services(TEST_SLOT)

	assert_true(load_success, "Load should succeed")
	assert_eq(BankingService.get_balance(BankingService.CurrencyType.SCRAP), 1000, "Scrap restored")
	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.PREMIUM), 50, "Premium restored"
	)
	assert_eq(BankingService.current_tier, BankingService.UserTier.PREMIUM, "Tier restored")


# Multiple Services Tests
func test_multiple_services_save_and_load() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()
	ShopRerollService.reset()

	SaveManager.load_all_services(TEST_SLOT)

	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP), 500, "Banking restored"
	)
	assert_eq(ShopRerollService.get_reroll_count(), 2, "Shop reroll restored")


# Transaction History Tests
func test_transaction_history_persists() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 200)
	BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 50)

	var history_before = BankingService.get_transaction_history()
	assert_eq(history_before.size(), 3, "Should have 3 transactions")

	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()

	assert_eq(BankingService.get_transaction_history().size(), 0, "History cleared after reset")

	SaveManager.load_all_services(TEST_SLOT)

	var history_after = BankingService.get_transaction_history()
	assert_eq(history_after.size(), 3, "History should be restored")
	assert_eq(history_after[0].amount, 100, "First transaction restored")
	assert_eq(history_after[1].amount, 200, "Second transaction restored")
	assert_eq(
		history_after[2].amount, 50, "Third transaction restored (subtract stores positive amount)"
	)
	assert_eq(history_after[2].action, "subtract", "Third transaction should be a subtract")


# Signal Tests
func test_save_started_signal_emits() -> void:
	watch_signals(SaveManager)

	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	assert_signal_emitted(SaveManager, "save_started", "save_started signal should emit")


func test_save_completed_signal_emits() -> void:
	watch_signals(SaveManager)

	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	assert_signal_emitted(SaveManager, "save_completed", "save_completed signal should emit")
	var signal_params = get_signal_parameters(SaveManager, "save_completed", 0)
	assert_true(signal_params[0], "Save should complete with success=true")


func test_load_started_signal_emits() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	watch_signals(SaveManager)
	SaveManager.load_all_services(TEST_SLOT)

	assert_signal_emitted(SaveManager, "load_started", "load_started signal should emit")


func test_load_completed_signal_emits() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	watch_signals(SaveManager)
	SaveManager.load_all_services(TEST_SLOT)

	assert_signal_emitted(SaveManager, "load_completed", "load_completed signal should emit")
	var signal_params = get_signal_parameters(SaveManager, "load_completed", 0)
	assert_true(signal_params[0], "Load should complete with success=true")


# Unsaved Changes Tests
func test_unsaved_changes_tracked_after_modification() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	assert_true(SaveManager.has_unsaved_changes(), "Has unsaved changes after modification")


func test_unsaved_changes_cleared_after_save() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	assert_false(SaveManager.has_unsaved_changes(), "No unsaved changes after save")


# Load Non-Existent Save Tests
func test_load_nonexistent_save_fails_gracefully() -> void:
	var load_success = SaveManager.load_all_services(TEST_SLOT)

	assert_false(load_success, "Loading non-existent save should fail gracefully")


# Metadata Tests
func test_metadata_shows_no_save_initially() -> void:
	var metadata = SaveManager.get_save_metadata(TEST_SLOT)

	assert_false(metadata.exists, "Save should not exist initially")


func test_metadata_populated_after_save() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	var metadata = SaveManager.get_save_metadata(TEST_SLOT)

	assert_true(metadata.exists, "Save should exist")
	assert_eq(metadata.version, 1, "Version should be 1")
	assert_eq(metadata.slot, TEST_SLOT, "Slot should match")
	assert_gt(metadata.timestamp, 0, "Should have timestamp")


# Deletion Tests
func test_save_deleted_successfully() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager.save_all_services(TEST_SLOT)

	assert_true(SaveManager.has_save(TEST_SLOT), "Save should exist")

	var delete_success = SaveManager.delete_save(TEST_SLOT)

	assert_true(delete_success, "Delete should succeed")
	assert_false(SaveManager.has_save(TEST_SLOT), "Save should not exist after deletion")


# Cross-Service Consistency Tests
func test_cross_service_state_consistency() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 1000)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	ShopRerollService.execute_reroll()

	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()
	ShopRerollService.reset()

	SaveManager.load_all_services(TEST_SLOT)

	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP),
		1000,
		"Should restore scrap balance after load"
	)
	assert_eq(
		BankingService.current_tier,
		BankingService.UserTier.PREMIUM,
		"Should restore banking tier after load"
	)
	assert_eq(ShopRerollService.get_reroll_count(), 1, "Should restore reroll count after load")


# Stateless Service Tests
func test_stateless_service_save_succeeds() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)

	var save_success = SaveManager.save_all_services(TEST_SLOT)

	assert_true(save_success, "Save with stateless service should succeed")


func test_stateless_service_load_succeeds() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)
	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()

	var load_success = SaveManager.load_all_services(TEST_SLOT)

	assert_true(load_success, "Load with stateless service should succeed")


func test_recycler_service_functional_after_load() -> void:
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)
	SaveManager.save_all_services(TEST_SLOT)
	BankingService.reset()
	SaveManager.load_all_services(TEST_SLOT)

	var test_input = RecyclerService.DismantleInput.new(
		"test_item", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var preview = RecyclerService.preview_dismantle(test_input)

	assert_gt(preview.scrap_granted, 0, "RecyclerService still functional")


# Auto-Save Tests
func test_auto_save_enabled() -> void:
	SaveManager.enable_auto_save()

	# Verify it's enabled by making a change and triggering the timeout
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	assert_true(SaveManager.has_unsaved_changes(), "Should have unsaved changes")


func test_auto_save_trigger_signal_emits() -> void:
	watch_signals(SaveManager)

	SaveManager.enable_auto_save()
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager._on_auto_save_timeout()

	assert_signal_emitted(
		SaveManager, "auto_save_triggered", "auto_save_triggered signal should emit"
	)


func test_auto_save_creates_save_in_slot_0() -> void:
	SaveManager.enable_auto_save()
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	SaveManager._on_auto_save_timeout()

	assert_true(SaveManager.has_save(0), "Auto-save should create save in slot 0")
	assert_false(SaveManager.has_unsaved_changes(), "Unsaved changes should be cleared")


func test_auto_save_skips_when_no_changes() -> void:
	watch_signals(SaveManager)

	SaveManager.enable_auto_save()
	SaveManager._on_auto_save_timeout()  # No changes

	assert_signal_not_emitted(
		SaveManager, "auto_save_triggered", "auto_save_triggered should not emit when no changes"
	)
