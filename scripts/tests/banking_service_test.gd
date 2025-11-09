extends Node
## Test script for BankingService
##
## Tests currency management, tier-gating, and transaction validation.

# gdlint: disable=duplicated-load


func _ready() -> void:
	print("=== BankingService Test ===")
	print()

	test_initial_state()
	test_add_currency()
	test_subtract_currency()
	test_insufficient_funds()
	test_tier_gating()
	test_balance_caps()
	test_transaction_history()

	print()
	print("=== All BankingService Tests Complete ===")

	# Exit after tests complete (for headless mode)
	get_tree().quit()


func test_initial_state() -> void:
	print("--- Testing Initial State ---")

	# Reset service
	BankingService.reset()

	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 0,
		"Initial scrap should be 0"
	)
	assert(
		BankingService.get_balance(BankingService.CurrencyType.PREMIUM) == 0,
		"Initial premium should be 0"
	)

	print("✓ Initial balances correct")
	print()


func test_add_currency() -> void:
	print("--- Testing Add Currency ---")

	BankingService.reset()
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	var success = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	assert(success, "Adding scrap should succeed")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 100,
		"Scrap balance should be 100"
	)

	success = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)
	assert(success, "Adding more scrap should succeed")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 150,
		"Scrap balance should be 150"
	)

	print("✓ Add currency works correctly")
	print()


func test_subtract_currency() -> void:
	print("--- Testing Subtract Currency ---")

	BankingService.reset()
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 200)

	var success = BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 50)
	assert(success, "Subtracting scrap should succeed")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 150,
		"Scrap balance should be 150"
	)

	print("✓ Subtract currency works correctly")
	print()


func test_insufficient_funds() -> void:
	print("--- Testing Insufficient Funds ---")

	BankingService.reset()
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)

	var success = BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 100)
	assert(not success, "Subtracting more than balance should fail")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 50,
		"Balance should remain 50"
	)

	print("✓ Insufficient funds handled correctly")
	print()


func test_tier_gating() -> void:
	print("--- Testing Tier Gating ---")

	BankingService.reset()

	# Free tier - no banking access
	BankingService.set_tier(BankingService.UserTier.FREE)
	assert(not BankingService.has_access(), "Free tier should not have banking access")

	# Premium tier - has access
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	assert(BankingService.has_access(), "Premium tier should have banking access")

	# Subscription tier - has access
	BankingService.set_tier(BankingService.UserTier.SUBSCRIPTION)
	assert(BankingService.has_access(), "Subscription tier should have banking access")

	print("✓ Tier gating works correctly")
	print()


func test_balance_caps() -> void:
	print("--- Testing Balance Caps ---")

	BankingService.reset()

	# Premium tier: 10k cap
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	var caps = BankingService.get_balance_caps(BankingService.UserTier.PREMIUM)
	assert(caps.per_character == 10_000, "Premium cap should be 10k")

	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 9_000)
	var success = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 2_000)
	assert(not success, "Adding over cap should fail")
	assert(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP) == 9_000,
		"Balance should remain 9000"
	)

	# Subscription tier: 100k cap
	BankingService.reset()
	BankingService.set_tier(BankingService.UserTier.SUBSCRIPTION)
	caps = BankingService.get_balance_caps(BankingService.UserTier.SUBSCRIPTION)
	assert(caps.per_character == 100_000, "Subscription cap should be 100k")

	print("✓ Balance caps enforced correctly")
	print()


func test_transaction_history() -> void:
	print("--- Testing Transaction History ---")

	BankingService.reset()
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 30)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)

	var history = BankingService.get_transaction_history()
	assert(history.size() == 3, "Should have 3 transactions")
	assert(history[0].action == "add", "First transaction should be add")
	assert(history[1].action == "subtract", "Second transaction should be subtract")
	assert(history[2].action == "add", "Third transaction should be add")

	print("✓ Transaction history recorded correctly")
	print()
