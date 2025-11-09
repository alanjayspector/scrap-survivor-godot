extends Node
## Test script for ShopRerollService
##
## Run this test:
## 1. Open scenes/tests/shop_reroll_service_test.tscn in Godot
## 2. Press F5 to run
## 3. Check Output panel for results


func _ready() -> void:
	print("=== ShopRerollService Test ===")
	print()

	test_cost_constants()
	test_cost_calculation()
	test_initial_state()
	test_reroll_preview()
	test_reroll_execution()
	test_progressive_costs()
	test_max_reroll_cap()
	test_reset_functionality()

	print()
	print("=== ShopRerollService Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


func test_cost_constants() -> void:
	print("--- Testing Cost Constants ---")

	assert(ShopRerollService.BASE_COST == 50, "BASE_COST should be 50")
	assert(ShopRerollService.COST_MULTIPLIER == 2, "COST_MULTIPLIER should be 2")
	assert(ShopRerollService.MAX_REROLL_COUNT == 99, "MAX_REROLL_COUNT should be 99")
	print("✓ All constants correct")


func test_cost_calculation() -> void:
	print("--- Testing Cost Calculation Formula ---")

	# Formula: BASE_COST * (COST_MULTIPLIER ^ count)
	# 50 * (2 ^ 0) = 50
	var cost_0 = ShopRerollService._calculate_cost(0)
	assert(cost_0 == 50, "Reroll 0 should cost 50")
	print("✓ Reroll 0: 50 scrap")

	# 50 * (2 ^ 1) = 100
	var cost_1 = ShopRerollService._calculate_cost(1)
	assert(cost_1 == 100, "Reroll 1 should cost 100")
	print("✓ Reroll 1: 100 scrap")

	# 50 * (2 ^ 2) = 200
	var cost_2 = ShopRerollService._calculate_cost(2)
	assert(cost_2 == 200, "Reroll 2 should cost 200")
	print("✓ Reroll 2: 200 scrap")

	# 50 * (2 ^ 3) = 400
	var cost_3 = ShopRerollService._calculate_cost(3)
	assert(cost_3 == 400, "Reroll 3 should cost 400")
	print("✓ Reroll 3: 400 scrap")

	# 50 * (2 ^ 5) = 1600
	var cost_5 = ShopRerollService._calculate_cost(5)
	assert(cost_5 == 1600, "Reroll 5 should cost 1600")
	print("✓ Reroll 5: 1600 scrap")

	# 50 * (2 ^ 10) = 51200
	var cost_10 = ShopRerollService._calculate_cost(10)
	assert(cost_10 == 51200, "Reroll 10 should cost 51200")
	print("✓ Reroll 10: 51,200 scrap")


func test_initial_state() -> void:
	print("--- Testing Initial State ---")

	# Reset service to initial state
	ShopRerollService.reset_reroll_count()

	var initial_count = ShopRerollService.get_reroll_count()
	assert(initial_count == 0, "Initial reroll count should be 0")
	print("✓ Initial reroll count: 0")

	var preview = ShopRerollService.get_reroll_preview()
	assert(preview.reroll_count == 0, "Preview should show 0 rerolls")
	assert(preview.cost == 50, "First reroll should cost 50")
	assert(preview.next_cost == 100, "Second reroll should cost 100")
	print("✓ Initial preview correct")


func test_reroll_preview() -> void:
	print("--- Testing Reroll Preview ---")

	# Reset to known state
	ShopRerollService.reset_reroll_count()

	# Preview doesn't change state
	var preview1 = ShopRerollService.get_reroll_preview()
	var preview2 = ShopRerollService.get_reroll_preview()
	var preview3 = ShopRerollService.get_reroll_preview()

	assert(preview1.reroll_count == 0, "All previews should show same count")
	assert(preview2.reroll_count == 0, "All previews should show same count")
	assert(preview3.reroll_count == 0, "All previews should show same count")
	print("✓ Preview is read-only")

	# Verify cost accuracy
	assert(preview1.cost == 50, "First preview cost should be 50")
	assert(preview1.next_cost == 100, "Preview next_cost should be 100")
	print("✓ Preview costs accurate")


func test_reroll_execution() -> void:
	print("--- Testing Reroll Execution ---")

	# Reset to known state
	ShopRerollService.reset_reroll_count()

	# Execute first reroll
	var exec1 = ShopRerollService.execute_reroll()
	assert(exec1.reroll_count == 1, "First execution should increment count to 1")
	assert(exec1.charged_cost == 50, "First execution should charge 50")
	assert(exec1.next_cost == 200, "Next cost should be 200")
	print("✓ First reroll: count=1, charged=50, next=200")

	# Execute second reroll
	var exec2 = ShopRerollService.execute_reroll()
	assert(exec2.reroll_count == 2, "Second execution should increment count to 2")
	assert(exec2.charged_cost == 100, "Second execution should charge 100")
	assert(exec2.next_cost == 400, "Next cost should be 400")
	print("✓ Second reroll: count=2, charged=100, next=400")

	# Execute third reroll
	var exec3 = ShopRerollService.execute_reroll()
	assert(exec3.reroll_count == 3, "Third execution should increment count to 3")
	assert(exec3.charged_cost == 200, "Third execution should charge 200")
	assert(exec3.next_cost == 800, "Next cost should be 800")
	print("✓ Third reroll: count=3, charged=200, next=800")

	# Verify current count
	var current_count = ShopRerollService.get_reroll_count()
	assert(current_count == 3, "Current count should be 3")
	print("✓ Current count tracking correct")


func test_progressive_costs() -> void:
	print("--- Testing Progressive Cost Scaling ---")

	# Reset to known state
	ShopRerollService.reset_reroll_count()

	# Execute multiple rerolls and verify exponential growth
	var costs = []
	for i in range(6):
		var exec = ShopRerollService.execute_reroll()
		costs.append(exec.charged_cost)

	# Verify exponential progression
	assert(costs[0] == 50, "Cost 0 should be 50")
	assert(costs[1] == 100, "Cost 1 should be 100 (2x)")
	assert(costs[2] == 200, "Cost 2 should be 200 (4x)")
	assert(costs[3] == 400, "Cost 3 should be 400 (8x)")
	assert(costs[4] == 800, "Cost 4 should be 800 (16x)")
	assert(costs[5] == 1600, "Cost 5 should be 1600 (32x)")
	print("✓ Exponential cost progression: [50, 100, 200, 400, 800, 1600]")


func test_max_reroll_cap() -> void:
	print("--- Testing Maximum Reroll Cap ---")

	# Reset to known state
	ShopRerollService.reset_reroll_count()

	# Manually set count to MAX - 1
	ShopRerollService._current_state.reroll_count = ShopRerollService.MAX_REROLL_COUNT - 1

	# Execute reroll (should hit max)
	var exec1 = ShopRerollService.execute_reroll()
	assert(
		exec1.reroll_count == ShopRerollService.MAX_REROLL_COUNT, "Should reach MAX_REROLL_COUNT"
	)
	print("✓ Reached max reroll count: %d" % ShopRerollService.MAX_REROLL_COUNT)

	# Execute another reroll (should stay at max)
	var exec2 = ShopRerollService.execute_reroll()
	assert(
		exec2.reroll_count == ShopRerollService.MAX_REROLL_COUNT, "Should stay at MAX_REROLL_COUNT"
	)
	print("✓ Capped at max reroll count (doesn't exceed)")

	# Verify costs are still calculated correctly at max
	var max_cost = ShopRerollService._calculate_cost(ShopRerollService.MAX_REROLL_COUNT)
	assert(max_cost > 0, "Max cost should still be calculated")
	print("✓ Max cost still calculated: %d" % max_cost)


func test_reset_functionality() -> void:
	print("--- Testing Reset Functionality ---")

	# Execute some rerolls
	ShopRerollService.reset_reroll_count()
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	var count_before = ShopRerollService.get_reroll_count()
	assert(count_before == 3, "Should have 3 rerolls before reset")
	print("✓ Before reset: count = 3")

	# Manual reset
	ShopRerollService.reset_reroll_count()

	var count_after = ShopRerollService.get_reroll_count()
	assert(count_after == 0, "Should have 0 rerolls after reset")
	print("✓ After reset: count = 0")

	# Verify costs reset
	var preview = ShopRerollService.get_reroll_preview()
	assert(preview.cost == 50, "First reroll cost should be 50 again")
	print("✓ Costs reset to initial values")
