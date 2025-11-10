extends GutTest
## Test script for BankingService using GUT framework
##
## Tests currency management, tier-gating, and transaction validation.

class_name BankingServiceTest

# gdlint: disable=duplicated-load


func before_each() -> void:
	# Reset service before each test for isolation
	BankingService.reset()
	# Explicitly reset tier to FREE (autoload state persists between tests)
	BankingService.set_tier(BankingService.UserTier.FREE)


func after_each() -> void:
	# Cleanup after each test
	pass


func test_initial_state_all_balances_are_zero() -> void:
	# Arrange (done in before_each)

	# Act
	var scrap_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	var premium_balance = BankingService.get_balance(BankingService.CurrencyType.PREMIUM)

	# Assert
	assert_eq(scrap_balance, 0, "Initial scrap balance should be 0")
	assert_eq(premium_balance, 0, "Initial premium balance should be 0")


func test_add_currency_increases_balance() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	# Act
	var success = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	var balance_after_first_add = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	var success2 = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)
	var balance_after_second_add = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	# Assert
	assert_true(success, "Adding scrap should succeed")
	assert_eq(balance_after_first_add, 100, "Scrap balance should be 100 after first add")

	assert_true(success2, "Adding more scrap should succeed")
	assert_eq(balance_after_second_add, 150, "Scrap balance should be 150 after second add")


func test_subtract_currency_decreases_balance() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 200)

	# Act
	var success = BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 50)
	var balance_after_subtract = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	# Assert
	assert_true(success, "Subtracting scrap should succeed")
	assert_eq(balance_after_subtract, 150, "Scrap balance should be 150 after subtract")


func test_subtract_currency_with_insufficient_funds_fails() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)

	# Act
	var success = BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 100)
	var balance_unchanged = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	# Assert
	assert_false(success, "Subtracting more than balance should fail")
	assert_eq(balance_unchanged, 50, "Balance should remain 50 when transaction fails")


func test_tier_gating_free_tier_denies_access() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.FREE)

	# Act
	var has_access = BankingService.has_access()

	# Assert
	assert_false(has_access, "Free tier should not have banking access")


func test_tier_gating_premium_tier_grants_access() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	# Act
	var has_access = BankingService.has_access()

	# Assert
	assert_true(has_access, "Premium tier should have banking access")


func test_tier_gating_subscription_tier_grants_access() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.SUBSCRIPTION)

	# Act
	var has_access = BankingService.has_access()

	# Assert
	assert_true(has_access, "Subscription tier should have banking access")


func test_balance_caps_premium_tier_enforces_10k_limit() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	var caps = BankingService.get_balance_caps(BankingService.UserTier.PREMIUM)

	# Act
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 9_000)
	var success_over_cap = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 2_000)
	var balance_at_cap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	# Assert
	assert_eq(caps.per_character, 10_000, "Premium cap should be 10k")
	assert_false(success_over_cap, "Adding over cap should fail")
	assert_eq(balance_at_cap, 9_000, "Balance should remain 9000 when exceeding cap")


func test_balance_caps_subscription_tier_enforces_100k_limit() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.SUBSCRIPTION)
	var caps = BankingService.get_balance_caps(BankingService.UserTier.SUBSCRIPTION)

	# Act & Assert
	assert_eq(caps.per_character, 100_000, "Subscription cap should be 100k")


func test_transaction_history_records_all_operations() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	# Act
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 30)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)

	var history = BankingService.get_transaction_history()

	# Assert
	assert_eq(history.size(), 3, "Should have 3 transactions in history")
	assert_eq(history[0].action, "add", "First transaction should be add")
	assert_eq(history[1].action, "subtract", "Second transaction should be subtract")
	assert_eq(history[2].action, "add", "Third transaction should be add")


func test_get_tier_returns_current_tier() -> void:
	# Arrange (default tier is FREE after before_each reset)

	# Act & Assert - Default
	assert_eq(
		BankingService.current_tier, BankingService.UserTier.FREE, "Default tier should be FREE"
	)

	# Act & Assert - Premium
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	assert_eq(
		BankingService.current_tier, BankingService.UserTier.PREMIUM, "Tier should be PREMIUM"
	)

	# Act & Assert - Subscription
	BankingService.set_tier(BankingService.UserTier.SUBSCRIPTION)
	assert_eq(
		BankingService.current_tier,
		BankingService.UserTier.SUBSCRIPTION,
		"Tier should be SUBSCRIPTION"
	)


func test_currency_changed_signal_emits_on_add() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	watch_signals(BankingService)

	# Act
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	# Assert
	assert_signal_emitted(BankingService, "currency_changed", "currency_changed should emit on add")
	assert_signal_emit_count(
		BankingService, "currency_changed", 1, "currency_changed should emit once"
	)

	var signal_params = get_signal_parameters(BankingService, "currency_changed", 0)
	assert_eq(
		signal_params[0], BankingService.CurrencyType.SCRAP, "Signal should report SCRAP type"
	)
	assert_eq(signal_params[1], 100, "Signal should report new balance of 100")


func test_currency_changed_signal_emits_on_subtract() -> void:
	# Arrange
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	watch_signals(BankingService)

	# Act
	BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, 30)

	# Assert
	assert_signal_emitted(
		BankingService, "currency_changed", "currency_changed should emit on subtract"
	)

	var signal_params = get_signal_parameters(BankingService, "currency_changed", 0)
	assert_eq(signal_params[1], 70, "Signal should report new balance of 70 after subtract")
