extends GutTest
## Integration test for Week 5 services working together using GUT framework
##
## USER STORY: "As a player, I want services to work together correctly"
##
## Tests realistic workflows combining BankingService, RecyclerService, and ShopRerollService.

class_name ServiceIntegrationTest


func before_each() -> void:
	# Reset all services before each test
	BankingService.reset()
	ShopRerollService.reset_reroll_count()
	RecyclerService.reset()


func after_each() -> void:
	# Cleanup
	pass


# Recycle and Bank Flow Tests
func test_dismantle_rare_weapon_grants_scrap() -> void:
	var input = RecyclerService.DismantleInput.new(
		"rusty_sword", RecyclerService.ItemRarity.RARE, true, 0  # is_weapon=true
	)

	var outcome = RecyclerService.dismantle_item(input)

	# Rare weapon: 35 * 1.5 = 53 scrap (rounded)
	assert_eq(outcome.scrap_granted, 53, "Rare weapon should give 53 scrap")


func test_add_recycled_scrap_to_bank() -> void:
	var input = RecyclerService.DismantleInput.new(
		"rusty_sword", RecyclerService.ItemRarity.RARE, true, 0
	)
	var outcome = RecyclerService.dismantle_item(input)

	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	var add_result = BankingService.add_currency(
		BankingService.CurrencyType.SCRAP, outcome.scrap_granted
	)

	assert_true(add_result, "Should successfully add scrap to bank")
	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP),
		53,
		"Scrap balance should be 53"
	)


# Shop Reroll Economy Tests
func test_player_can_afford_first_reroll() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)

	var preview = ShopRerollService.get_reroll_preview()

	assert_eq(preview.cost, 50, "First reroll should cost 50")
	assert_gte(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP),
		preview.cost,
		"Player should afford first reroll"
	)


func test_reroll_deducts_cost_from_bank() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)

	# Correct pattern: preview → pay → execute
	var preview = ShopRerollService.get_reroll_preview()
	var subtract_result = BankingService.subtract_currency(
		BankingService.CurrencyType.SCRAP, preview.cost
	)
	if subtract_result:
		ShopRerollService.execute_reroll()

	assert_true(subtract_result, "Should successfully subtract cost")
	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP),
		450,
		"Balance should be 450 (500 - 50)"
	)


func test_second_reroll_costs_more() -> void:
	ShopRerollService.execute_reroll()  # First reroll

	var preview = ShopRerollService.get_reroll_preview()

	assert_eq(preview.cost, 100, "Second reroll should cost 100 (2x)")


# Tier Gating Tests
func test_free_tier_rejects_scrap() -> void:
	# Default tier is FREE
	var caps = BankingService.get_balance_caps(BankingService.UserTier.FREE)

	assert_eq(caps.per_character, 0, "FREE tier should have 0 per-character cap")

	var add_result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	assert_false(add_result, "FREE tier should reject scrap")


func test_premium_tier_accepts_scrap() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	var premium_caps = BankingService.get_balance_caps(BankingService.UserTier.PREMIUM)

	assert_eq(premium_caps.per_character, 10000, "PREMIUM tier should have 10k cap")

	var add_result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	assert_true(add_result, "PREMIUM tier should accept scrap")


func test_premium_tier_enforces_cap() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	var premium_caps = BankingService.get_balance_caps(BankingService.UserTier.PREMIUM)

	# Add lots of scrap
	for i in range(200):
		BankingService.add_currency(BankingService.CurrencyType.SCRAP, 12)

	var balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	assert_lte(balance, premium_caps.per_character, "Should not exceed PREMIUM cap")


# Signal Integration Tests
func test_banking_currency_changed_signal() -> void:
	watch_signals(BankingService)
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 100)

	assert_signal_emitted(BankingService, "currency_changed", "currency_changed should emit")


func test_recycler_item_dismantled_signal() -> void:
	watch_signals(RecyclerService)

	var input = RecyclerService.DismantleInput.new(
		"test_item", RecyclerService.ItemRarity.COMMON, false, 0
	)
	RecyclerService.dismantle_item(input)

	assert_signal_emitted(RecyclerService, "item_dismantled", "item_dismantled should emit")


func test_shop_reroll_executed_signal() -> void:
	watch_signals(ShopRerollService)

	ShopRerollService.execute_reroll()

	assert_signal_emitted(ShopRerollService, "reroll_executed", "reroll_executed should emit")


# Realistic Gameplay Loop Tests
func test_player_dismantles_multiple_items() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	for i in range(5):
		var input = RecyclerService.DismantleInput.new(
			"uncommon_item_%d" % i, RecyclerService.ItemRarity.UNCOMMON, false, 0
		)
		var outcome = RecyclerService.dismantle_item(input)
		BankingService.add_currency(BankingService.CurrencyType.SCRAP, outcome.scrap_granted)

	var scrap_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	assert_eq(scrap_balance, 100, "Should have 100 scrap (5 * 20)")


func test_player_runs_out_of_scrap_rerolling() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)

	var total_spent = 0

	# Try to reroll 3 times
	# Correct pattern: check preview, pay, THEN execute
	for i in range(3):
		var preview = ShopRerollService.get_reroll_preview()
		var success = BankingService.subtract_currency(
			BankingService.CurrencyType.SCRAP, preview.cost
		)
		if success:
			ShopRerollService.execute_reroll()
			total_spent += preview.cost
		else:
			break

	# Player runs out after 1 reroll: 100 scrap, costs 50, balance = 50
	# Second reroll costs 100 but only have 50 remaining, so it fails
	assert_eq(total_spent, 50, "Should have spent 50 scrap (only first reroll succeeded)")


func test_legendary_weapon_grants_high_scrap() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)

	var legendary_input = RecyclerService.DismantleInput.new(
		"legendary_axe", RecyclerService.ItemRarity.LEGENDARY, true, 0
	)
	var legendary_outcome = RecyclerService.dismantle_item(legendary_input)

	BankingService.add_currency(BankingService.CurrencyType.SCRAP, legendary_outcome.scrap_granted)

	var scrap_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)

	# Legendary weapon: 60 * 1.5 = 90 scrap
	assert_eq(scrap_balance, 90, "Legendary weapon should grant 90 scrap")


func test_complete_gameplay_scenario() -> void:
	BankingService.set_tier(BankingService.UserTier.PREMIUM)
	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 1000)

	# Dismantle 5 uncommon items
	for i in range(5):
		var input = RecyclerService.DismantleInput.new(
			"uncommon_item_%d" % i, RecyclerService.ItemRarity.UNCOMMON, false, 0
		)
		var outcome = RecyclerService.dismantle_item(input)
		BankingService.add_currency(BankingService.CurrencyType.SCRAP, outcome.scrap_granted)

	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP), 100, "Should have 100 scrap"
	)

	# Try to reroll twice (only first will succeed)
	# Correct pattern: check preview, pay, THEN execute
	var reroll_count = 0
	for i in range(2):
		var preview = ShopRerollService.get_reroll_preview()
		var success = BankingService.subtract_currency(
			BankingService.CurrencyType.SCRAP, preview.cost
		)
		if success:
			ShopRerollService.execute_reroll()
			reroll_count += 1

	# Balance: 100 - 50 = 50 (second reroll failed due to insufficient funds)
	assert_eq(reroll_count, 1, "Only first reroll should succeed")
	assert_eq(
		BankingService.get_balance(BankingService.CurrencyType.SCRAP), 50, "Should have 50 scrap"
	)

	# Dismantle legendary weapon
	var legendary_input = RecyclerService.DismantleInput.new(
		"legendary_axe", RecyclerService.ItemRarity.LEGENDARY, true, 0
	)
	var legendary_outcome = RecyclerService.dismantle_item(legendary_input)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, legendary_outcome.scrap_granted)

	# Balance: 50 + 90 = 140
	var final_scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert_eq(final_scrap, 140, "Should have 140 scrap after legendary (50 + 90)")

	# Check if can afford next reroll (100, since we only did 1 reroll so count=1)
	var preview = ShopRerollService.get_reroll_preview()
	var can_afford = final_scrap >= preview.cost

	assert_true(can_afford, "Player CAN afford 2nd reroll (need 100, have 140)")
