extends Node
## Integration test for Week 5 services working together
##
## Tests realistic workflows combining:
## - BankingService (currency management)
## - RecyclerService (item recycling)
## - ShopRerollService (shop reroll costs)
##
## Run this test:
## 1. Open scenes/tests/service_integration_test.tscn in Godot
## 2. Press F5 to run
## 3. Check Output panel for results


func _ready() -> void:
	print("=== Service Integration Test ===")
	print()

	test_recycle_and_bank_flow()
	test_shop_reroll_economy()
	test_tier_gating_with_recycling()
	test_signal_integration()
	test_realistic_gameplay_loop()

	print()
	print("=== Service Integration Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


func test_recycle_and_bank_flow() -> void:
	print("--- Testing Recycle → Banking Flow ---")

	# Reset services
	BankingService.reset()

	# Player dismantles a rare weapon
	var input = RecyclerService.DismantleInput.new(
		"rusty_sword", RecyclerService.ItemRarity.RARE, true, 0  # is_weapon=true
	)
	var outcome = RecyclerService.dismantle_item(input)

	# Rare weapon: 35 * 1.5 = 53 scrap (rounded)
	assert(outcome.scrap_granted == 53, "Rare weapon should give 53 scrap")
	print("✓ Dismantled rare weapon: 53 scrap")

	# Add scrap to banking service
	var add_result = BankingService.add_currency(
		BankingService.CurrencyType.SCRAP, outcome.scrap_granted
	)
	assert(add_result, "Should successfully add scrap")
	print("✓ Added scrap to bank")

	# Verify balance
	var balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(balance == 53, "Scrap balance should be 53")
	print("✓ Bank balance: 53 scrap")


func test_shop_reroll_economy() -> void:
	print("--- Testing Shop Reroll Economy ---")

	# Reset services
	BankingService.reset()
	ShopRerollService.reset_reroll_count()

	# Give player starting scrap
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, 500)
	var initial_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(initial_balance == 500, "Should have 500 scrap")
	print("✓ Player has 500 scrap")

	# Check reroll cost
	var preview = ShopRerollService.get_reroll_preview()
	assert(preview.cost == 50, "First reroll should cost 50")
	print("✓ First reroll costs: 50 scrap")

	# Player can afford reroll
	var can_afford = BankingService.get_balance(BankingService.CurrencyType.SCRAP) >= preview.cost
	assert(can_afford, "Player should afford first reroll")
	print("✓ Player can afford reroll")

	# Execute reroll
	var execution = ShopRerollService.execute_reroll()
	assert(execution.charged_cost == 50, "Should charge 50 scrap")
	print("✓ Reroll executed: charged 50 scrap")

	# Deduct cost from bank
	var subtract_result = BankingService.subtract_currency(
		BankingService.CurrencyType.SCRAP, execution.charged_cost
	)
	assert(subtract_result, "Should successfully subtract cost")
	print("✓ Cost deducted from bank")

	# Verify new balance
	var new_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(new_balance == 450, "Balance should be 450 (500 - 50)")
	print("✓ New balance: 450 scrap")

	# Second reroll costs more
	var preview2 = ShopRerollService.get_reroll_preview()
	assert(preview2.cost == 100, "Second reroll should cost 100")
	print("✓ Second reroll costs: 100 scrap (2x)")


func test_tier_gating_with_recycling() -> void:
	print("--- Testing Tier Gating with Recycling Income ---")

	# Reset services
	BankingService.reset()

	# FREE tier has 0 scrap cap
	var caps = BankingService.get_balance_caps(BankingService.UserTier.FREE)
	assert(caps.per_character == 0, "FREE tier should have 0 per-character cap")
	print("✓ FREE tier: 0 scrap cap per character")

	# Try to add scrap from recycling (should fail for FREE tier)
	var add_result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	assert(not add_result, "FREE tier should reject scrap")
	print("✓ FREE tier: scrap addition rejected")

	# Upgrade to PREMIUM tier
	BankingService.set_user_tier(BankingService.UserTier.PREMIUM)
	var premium_caps = BankingService.get_balance_caps(BankingService.UserTier.PREMIUM)
	assert(premium_caps.per_character == 10000, "PREMIUM tier should have 10k per-character cap")
	print("✓ PREMIUM tier: 10,000 scrap cap per character")

	# Now scrap should work
	add_result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
	assert(add_result, "PREMIUM tier should accept scrap")
	print("✓ PREMIUM tier: scrap addition successful")

	# Recycle multiple items and verify cap enforcement
	for i in range(200):
		# Each adds 12 scrap (common non-weapon)
		BankingService.add_currency(BankingService.CurrencyType.SCRAP, 12)

	var balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(balance <= premium_caps.per_character, "Should not exceed PREMIUM cap")
	print("✓ Balance capped at: %d scrap" % balance)


func test_signal_integration() -> void:
	print("--- Testing Signal Integration ---")

	# Reset services
	BankingService.reset()
	ShopRerollService.reset_reroll_count()

	# Track events with array wrappers for lambda capture
	var events = []

	# Connect to all service signals
	BankingService.currency_added.connect(
		func(type, amount):
			events.append({"service": "banking", "event": "currency_added", "amount": amount})
	)

	RecyclerService.item_dismantled.connect(
		func(template_id, outcome):
			events.append(
				{"service": "recycler", "event": "item_dismantled", "scrap": outcome.scrap_granted}
			)
	)

	ShopRerollService.reroll_executed.connect(
		func(execution):
			events.append(
				{
					"service": "shop_reroll",
					"event": "reroll_executed",
					"cost": execution.charged_cost
				}
			)
	)

	# Execute a sequence of operations
	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 100)  # Event 1

	var input = RecyclerService.DismantleInput.new(
		"test_item", RecyclerService.ItemRarity.COMMON, false, 0
	)
	RecyclerService.dismantle_item(input)  # Event 2

	ShopRerollService.execute_reroll()  # Event 3

	# Verify all events fired
	assert(events.size() == 3, "Should have 3 events")
	assert(events[0].service == "banking", "First event should be banking")
	assert(events[1].service == "recycler", "Second event should be recycler")
	assert(events[2].service == "shop_reroll", "Third event should be shop_reroll")
	print("✓ All service signals fired in order")


func test_realistic_gameplay_loop() -> void:
	print("--- Testing Realistic Gameplay Loop ---")

	# Reset all services
	BankingService.reset()
	ShopRerollService.reset_reroll_count()
	BankingService.set_user_tier(BankingService.UserTier.PREMIUM)

	print("\n  SCENARIO: Premium player grinds and rerolls shop")

	# Step 1: Player starts with some premium currency
	BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 1000)
	print("  • Starting premium: 1000")

	# Step 2: Player dismantles 5 uncommon items
	for i in range(5):
		var input = RecyclerService.DismantleInput.new(
			"uncommon_item_%d" % i, RecyclerService.ItemRarity.UNCOMMON, false, 0
		)
		var outcome = RecyclerService.dismantle_item(input)
		BankingService.add_currency(BankingService.CurrencyType.SCRAP, outcome.scrap_granted)

	var scrap_balance = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(scrap_balance == 100, "Should have 100 scrap (5 * 20)")
	print("  • Dismantled 5 uncommon items: +100 scrap")

	# Step 3: Player rerolls shop 3 times
	# Costs: 50 + 100 + 200 = 350 scrap total
	var total_spent = 0

	for i in range(3):
		var preview = ShopRerollService.get_reroll_preview()
		var execution = ShopRerollService.execute_reroll()

		# Check if player can afford
		if BankingService.get_balance(BankingService.CurrencyType.SCRAP) >= execution.charged_cost:
			BankingService.subtract_currency(
				BankingService.CurrencyType.SCRAP, execution.charged_cost
			)
			total_spent += execution.charged_cost
			print("  • Reroll %d: -%d scrap" % [i + 1, execution.charged_cost])
		else:
			print("  • Reroll %d: INSUFFICIENT FUNDS" % (i + 1))
			break

	# Player should run out of scrap on 3rd reroll
	# After 2 rerolls: 100 - 50 - 100 = -50 (can't afford 3rd)
	assert(total_spent == 150, "Should have spent 150 scrap (50 + 100)")
	print("  • Total spent: %d scrap" % total_spent)

	var final_scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	assert(final_scrap == -50, "Should have -50 scrap (insufficient for 3rd reroll)")
	print("  • Final scrap: %d (can't afford 3rd reroll)" % final_scrap)

	# Step 4: Player dismantles a legendary weapon to get more scrap
	var legendary_input = RecyclerService.DismantleInput.new(
		"legendary_axe", RecyclerService.ItemRarity.LEGENDARY, true, 0
	)
	var legendary_outcome = RecyclerService.dismantle_item(legendary_input)
	BankingService.add_currency(BankingService.CurrencyType.SCRAP, legendary_outcome.scrap_granted)

	var new_scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	# Legendary weapon: 60 * 1.5 = 90 scrap
	# -50 + 90 = 40
	assert(new_scrap == 40, "Should have 40 scrap after legendary")
	print("  • Dismantled legendary weapon: +90 scrap")
	print("  • Final balance: %d scrap, 1000 premium" % new_scrap)

	# Verify player can now afford another reroll (cost should be 200 from 3rd attempt)
	var final_preview = ShopRerollService.get_reroll_preview()
	var can_afford = new_scrap >= final_preview.cost
	assert(not can_afford, "Player still cannot afford 3rd reroll (need 200, have 40)")
	print("  • Status: Need %d more scrap for next reroll" % (final_preview.cost - new_scrap))
