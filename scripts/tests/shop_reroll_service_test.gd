extends GutTest
## Test script for ShopRerollService using GUT framework
##
## USER STORY: "As a player, I want to reroll shop offerings with escalating costs"
##
## Tests reroll mechanics, cost calculations, and progressive scaling.

class_name ShopRerollServiceTest


func before_each() -> void:
	# Reset service before each test
	ShopRerollService.reset_reroll_count()


func after_each() -> void:
	# Cleanup
	pass


# Constants Tests
func test_base_cost_constant_is_50() -> void:
	assert_eq(ShopRerollService.BASE_COST, 50, "BASE_COST should be 50")


func test_cost_multiplier_constant_is_2() -> void:
	assert_eq(ShopRerollService.COST_MULTIPLIER, 2, "COST_MULTIPLIER should be 2")


func test_max_reroll_count_constant_is_99() -> void:
	assert_eq(ShopRerollService.MAX_REROLL_COUNT, 99, "MAX_REROLL_COUNT should be 99")


# Cost Calculation Tests
func test_calculate_cost_for_reroll_0_equals_50() -> void:
	var cost = ShopRerollService._calculate_cost(0)
	assert_eq(cost, 50, "Reroll 0 should cost 50 (50 * 2^0)")


func test_calculate_cost_for_reroll_1_equals_100() -> void:
	var cost = ShopRerollService._calculate_cost(1)
	assert_eq(cost, 100, "Reroll 1 should cost 100 (50 * 2^1)")


func test_calculate_cost_for_reroll_2_equals_200() -> void:
	var cost = ShopRerollService._calculate_cost(2)
	assert_eq(cost, 200, "Reroll 2 should cost 200 (50 * 2^2)")


func test_calculate_cost_for_reroll_3_equals_400() -> void:
	var cost = ShopRerollService._calculate_cost(3)
	assert_eq(cost, 400, "Reroll 3 should cost 400 (50 * 2^3)")


func test_calculate_cost_for_reroll_5_equals_1600() -> void:
	var cost = ShopRerollService._calculate_cost(5)
	assert_eq(cost, 1600, "Reroll 5 should cost 1600 (50 * 2^5)")


func test_calculate_cost_for_reroll_10_equals_51200() -> void:
	var cost = ShopRerollService._calculate_cost(10)
	assert_eq(cost, 51200, "Reroll 10 should cost 51,200 (50 * 2^10)")


# Initial State Tests
func test_initial_reroll_count_is_zero() -> void:
	var count = ShopRerollService.get_reroll_count()
	assert_eq(count, 0, "Initial reroll count should be 0")


func test_initial_preview_shows_zero_rerolls() -> void:
	var preview = ShopRerollService.get_reroll_preview()
	assert_eq(preview.reroll_count, 0, "Initial preview should show 0 rerolls")


func test_initial_preview_cost_is_50() -> void:
	var preview = ShopRerollService.get_reroll_preview()
	assert_eq(preview.cost, 50, "First reroll should cost 50")


func test_initial_preview_next_cost_is_100() -> void:
	var preview = ShopRerollService.get_reroll_preview()
	assert_eq(preview.next_cost, 100, "Second reroll should cost 100")


# Preview Tests
func test_preview_does_not_mutate_state() -> void:
	var preview1 = ShopRerollService.get_reroll_preview()
	var preview2 = ShopRerollService.get_reroll_preview()
	var preview3 = ShopRerollService.get_reroll_preview()

	assert_eq(preview1.reroll_count, 0, "First preview should show count 0")
	assert_eq(preview2.reroll_count, 0, "Second preview should show count 0")
	assert_eq(preview3.reroll_count, 0, "Third preview should show count 0")


func test_preview_shows_accurate_costs() -> void:
	var preview = ShopRerollService.get_reroll_preview()
	assert_eq(preview.cost, 50, "Preview cost should be 50")
	assert_eq(preview.next_cost, 100, "Preview next_cost should be 100")


# Execution Tests
func test_execute_first_reroll_increments_count() -> void:
	var exec = ShopRerollService.execute_reroll()
	assert_eq(exec.reroll_count, 1, "First execution should increment count to 1")


func test_execute_first_reroll_charges_50() -> void:
	var exec = ShopRerollService.execute_reroll()
	assert_eq(exec.charged_cost, 50, "First execution should charge 50")


func test_execute_first_reroll_next_cost_is_200() -> void:
	var exec = ShopRerollService.execute_reroll()
	assert_eq(exec.next_cost, 200, "After first reroll, next cost should be 200")


func test_execute_second_reroll_increments_count() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	var exec = ShopRerollService.execute_reroll()  # Second reroll
	assert_eq(exec.reroll_count, 2, "Second execution should increment count to 2")


func test_execute_second_reroll_charges_100() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	var exec = ShopRerollService.execute_reroll()  # Second reroll
	assert_eq(exec.charged_cost, 100, "Second execution should charge 100")


func test_execute_second_reroll_next_cost_is_400() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	var exec = ShopRerollService.execute_reroll()  # Second reroll
	assert_eq(exec.next_cost, 400, "After second reroll, next cost should be 400")


func test_execute_third_reroll_increments_count() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	ShopRerollService.execute_reroll()  # Second reroll
	var exec = ShopRerollService.execute_reroll()  # Third reroll
	assert_eq(exec.reroll_count, 3, "Third execution should increment count to 3")


func test_execute_third_reroll_charges_200() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	ShopRerollService.execute_reroll()  # Second reroll
	var exec = ShopRerollService.execute_reroll()  # Third reroll
	assert_eq(exec.charged_cost, 200, "Third execution should charge 200")


func test_execute_third_reroll_next_cost_is_800() -> void:
	ShopRerollService.execute_reroll()  # First reroll
	ShopRerollService.execute_reroll()  # Second reroll
	var exec = ShopRerollService.execute_reroll()  # Third reroll
	assert_eq(exec.next_cost, 800, "After third reroll, next cost should be 800")


func test_get_reroll_count_tracks_executions() -> void:
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	var count = ShopRerollService.get_reroll_count()
	assert_eq(count, 3, "Current count should be 3 after 3 executions")


# Progressive Costs Tests
func test_exponential_cost_progression() -> void:
	var costs = []
	for i in range(6):
		var exec = ShopRerollService.execute_reroll()
		costs.append(exec.charged_cost)

	assert_eq(costs[0], 50, "Cost 0 should be 50")
	assert_eq(costs[1], 100, "Cost 1 should be 100 (2x)")
	assert_eq(costs[2], 200, "Cost 2 should be 200 (4x)")
	assert_eq(costs[3], 400, "Cost 3 should be 400 (8x)")
	assert_eq(costs[4], 800, "Cost 4 should be 800 (16x)")
	assert_eq(costs[5], 1600, "Cost 5 should be 1600 (32x)")


# Max Reroll Cap Tests
func test_reroll_count_reaches_max() -> void:
	# Manually set count to MAX - 1
	ShopRerollService._current_state.reroll_count = ShopRerollService.MAX_REROLL_COUNT - 1

	var exec = ShopRerollService.execute_reroll()
	assert_eq(
		exec.reroll_count, ShopRerollService.MAX_REROLL_COUNT, "Should reach MAX_REROLL_COUNT"
	)


func test_reroll_count_does_not_exceed_max() -> void:
	# Manually set count to MAX - 1
	ShopRerollService._current_state.reroll_count = ShopRerollService.MAX_REROLL_COUNT - 1

	# Execute two rerolls
	ShopRerollService.execute_reroll()
	var exec = ShopRerollService.execute_reroll()

	assert_eq(
		exec.reroll_count, ShopRerollService.MAX_REROLL_COUNT, "Should stay at MAX_REROLL_COUNT"
	)


func test_max_cost_still_calculated_correctly() -> void:
	var max_cost = ShopRerollService._calculate_cost(ShopRerollService.MAX_REROLL_COUNT)
	assert_gt(max_cost, 0, "Max cost should still be calculated and positive")


# Reset Functionality Tests
func test_reset_clears_reroll_count() -> void:
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	var count_before = ShopRerollService.get_reroll_count()
	assert_eq(count_before, 3, "Should have 3 rerolls before reset")

	ShopRerollService.reset_reroll_count()

	var count_after = ShopRerollService.get_reroll_count()
	assert_eq(count_after, 0, "Should have 0 rerolls after reset")


func test_reset_restores_initial_costs() -> void:
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	ShopRerollService.reset_reroll_count()

	var preview = ShopRerollService.get_reroll_preview()
	assert_eq(preview.cost, 50, "First reroll cost should be 50 again after reset")


# Signal Tests
func test_reroll_executed_signal_emits_on_execution() -> void:
	watch_signals(ShopRerollService)

	ShopRerollService.execute_reroll()

	assert_signal_emitted(
		ShopRerollService, "reroll_executed", "reroll_executed signal should emit"
	)
	assert_signal_emit_count(ShopRerollService, "reroll_executed", 1, "Signal should emit once")


func test_reroll_executed_signal_contains_correct_data() -> void:
	watch_signals(ShopRerollService)

	ShopRerollService.execute_reroll()

	var signal_params = get_signal_parameters(ShopRerollService, "reroll_executed", 0)
	var execution = signal_params[0]

	assert_eq(execution.reroll_count, 1, "Signal should report count=1")
	assert_eq(execution.charged_cost, 50, "Signal should report cost=50")


func test_reroll_executed_signal_emits_multiple_times() -> void:
	watch_signals(ShopRerollService)

	ShopRerollService.execute_reroll()
	ShopRerollService.execute_reroll()

	assert_signal_emit_count(
		ShopRerollService, "reroll_executed", 2, "Signal should emit twice for two rerolls"
	)

	var signal_params = get_signal_parameters(ShopRerollService, "reroll_executed", 1)
	var execution = signal_params[0]

	assert_eq(execution.reroll_count, 2, "Second signal should report count=2")
	assert_eq(execution.charged_cost, 100, "Second signal should report cost=100")


func test_reroll_count_reset_signal_emits_on_reset() -> void:
	watch_signals(ShopRerollService)

	ShopRerollService.reset_reroll_count()

	assert_signal_emitted(
		ShopRerollService, "reroll_count_reset", "reroll_count_reset signal should emit"
	)
	assert_signal_emit_count(
		ShopRerollService, "reroll_count_reset", 1, "Signal should emit once on reset"
	)
