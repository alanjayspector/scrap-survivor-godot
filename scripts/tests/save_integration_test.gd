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
	test_cross_service_consistency()

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

	# Save state
	var save_success = SaveManager.save_all_services(TEST_SLOT)
	assert(save_success, "Save should succeed")
	print("✓ Saved successfully")

	# Reset
	BankingService.reset()
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0, "Balance reset")
	print("✓ Services reset")

	# Load state
	var load_success = SaveManager.load_all_services(TEST_SLOT)
	assert(load_success, "Load should succeed")
	print("✓ Loaded successfully")

	# Verify state restored
	assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 1000, "Scrap restored")
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
