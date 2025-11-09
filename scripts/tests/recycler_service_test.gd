extends Node
## Test script for RecyclerService
##
## Run this test:
## 1. Open scenes/tests/recycler_service_test.tscn in Godot
## 2. Press F5 to run
## 3. Check Output panel for results


func _ready() -> void:
	print("=== RecyclerService Test ===")
	print()

	test_rarity_constants()
	test_scrap_calculations()
	test_components_calculations()
	test_luck_modifiers()
	test_preview_vs_dismantle()
	test_edge_cases()
	test_rarity_helpers()

	print()
	print("=== RecyclerService Tests Complete ===")

	# CRITICAL: Exit after tests for headless mode
	get_tree().quit()


func test_rarity_constants() -> void:
	print("--- Testing Rarity Constants ---")

	# Verify all rarity levels exist
	assert(RecyclerService.ItemRarity.COMMON == 0, "COMMON rarity should be 0")
	assert(RecyclerService.ItemRarity.UNCOMMON == 1, "UNCOMMON rarity should be 1")
	assert(RecyclerService.ItemRarity.RARE == 2, "RARE rarity should be 1")
	assert(RecyclerService.ItemRarity.EPIC == 3, "EPIC rarity should be 3")
	assert(RecyclerService.ItemRarity.LEGENDARY == 4, "LEGENDARY rarity should be 4")
	print("✓ All rarity enum values correct")

	# Verify scrap base values
	assert(
		RecyclerService.SCRAP_BASE_BY_RARITY[RecyclerService.ItemRarity.COMMON] == 12,
		"Common scrap should be 12"
	)
	assert(
		RecyclerService.SCRAP_BASE_BY_RARITY[RecyclerService.ItemRarity.LEGENDARY] == 60,
		"Legendary scrap should be 60"
	)
	print("✓ Scrap base values correct")

	# Verify component values
	assert(
		RecyclerService.COMPONENTS_BASE_BY_RARITY[RecyclerService.ItemRarity.COMMON] == 0,
		"Common components should be 0"
	)
	assert(
		RecyclerService.COMPONENTS_BASE_BY_RARITY[RecyclerService.ItemRarity.LEGENDARY] == 3,
		"Legendary components should be 3"
	)
	print("✓ Component base values correct")


func test_scrap_calculations() -> void:
	print("--- Testing Scrap Calculations ---")

	# Test basic scrap for non-weapon
	var input_common = RecyclerService.DismantleInput.new(
		"test_common", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var outcome_common = RecyclerService.dismantle_item(input_common)
	assert(outcome_common.scrap_granted == 12, "Common non-weapon should give 12 scrap")
	print("✓ Common non-weapon: 12 scrap")

	# Test weapon multiplier (1.5x)
	var input_weapon = RecyclerService.DismantleInput.new(
		"test_weapon", RecyclerService.ItemRarity.COMMON, true, 0
	)
	var outcome_weapon = RecyclerService.dismantle_item(input_weapon)
	assert(outcome_weapon.scrap_granted == 18, "Common weapon should give 18 scrap (12 * 1.5)")
	print("✓ Common weapon: 18 scrap (1.5x multiplier)")

	# Test rare item scrap
	var input_rare = RecyclerService.DismantleInput.new(
		"test_rare", RecyclerService.ItemRarity.RARE, false, 0
	)
	var outcome_rare = RecyclerService.dismantle_item(input_rare)
	assert(outcome_rare.scrap_granted == 35, "Rare non-weapon should give 35 scrap")
	print("✓ Rare non-weapon: 35 scrap")

	# Test rare weapon
	var input_rare_weapon = RecyclerService.DismantleInput.new(
		"test_rare_weapon", RecyclerService.ItemRarity.RARE, true, 0
	)
	var outcome_rare_weapon = RecyclerService.dismantle_item(input_rare_weapon)
	assert(
		outcome_rare_weapon.scrap_granted == 53,
		"Rare weapon should give 53 scrap (35 * 1.5 rounded)"
	)
	print("✓ Rare weapon: 53 scrap")


func test_components_calculations() -> void:
	print("--- Testing Workshop Components Calculations ---")

	# Common items never drop components
	var input_common = RecyclerService.DismantleInput.new(
		"test_common", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var outcome_common = RecyclerService.dismantle_item(input_common)
	assert(outcome_common.components_granted == 0, "Common should give 0 components")
	assert(outcome_common.components_chance == 0.0, "Common should have 0% component chance")
	print("✓ Common: 0 components, 0% chance")

	# Uncommon has 40% chance for 1 component
	var input_uncommon = RecyclerService.DismantleInput.new(
		"test_uncommon", RecyclerService.ItemRarity.UNCOMMON, false, 0
	)
	var preview_uncommon = RecyclerService.preview_dismantle(input_uncommon)
	assert(preview_uncommon.potential_components == 1, "Uncommon should have 1 potential component")
	assert(preview_uncommon.components_chance == 0.4, "Uncommon should have 40% chance")
	print("✓ Uncommon: 1 potential component, 40% chance")

	# Rare has 65% chance for 2 components
	var input_rare = RecyclerService.DismantleInput.new(
		"test_rare", RecyclerService.ItemRarity.RARE, false, 0
	)
	var preview_rare = RecyclerService.preview_dismantle(input_rare)
	assert(preview_rare.potential_components == 2, "Rare should have 2 potential components")
	assert(preview_rare.components_chance == 0.65, "Rare should have 65% chance")
	print("✓ Rare: 2 potential components, 65% chance")

	# Epic has 75% chance for 3 components
	var input_epic = RecyclerService.DismantleInput.new(
		"test_epic", RecyclerService.ItemRarity.EPIC, false, 0
	)
	var preview_epic = RecyclerService.preview_dismantle(input_epic)
	assert(preview_epic.potential_components == 3, "Epic should have 3 potential components")
	assert(preview_epic.components_chance == 0.75, "Epic should have 75% chance")
	print("✓ Epic: 3 potential components, 75% chance")

	# Legendary has 85% chance for 3 components
	var input_legendary = RecyclerService.DismantleInput.new(
		"test_legendary", RecyclerService.ItemRarity.LEGENDARY, false, 0
	)
	var preview_legendary = RecyclerService.preview_dismantle(input_legendary)
	assert(
		preview_legendary.potential_components == 3, "Legendary should have 3 potential components"
	)
	assert(preview_legendary.components_chance == 0.85, "Legendary should have 85% chance")
	print("✓ Legendary: 3 potential components, 85% chance")


func test_luck_modifiers() -> void:
	print("--- Testing Luck Modifiers ---")

	# Luck chance bonus: +2.5% per 10 luck
	# Example: 40 luck = +10% chance
	var input_luck_40 = RecyclerService.DismantleInput.new(
		"test_luck", RecyclerService.ItemRarity.UNCOMMON, false, 40
	)
	var preview_luck_40 = RecyclerService.preview_dismantle(input_luck_40)
	assert(
		abs(preview_luck_40.components_chance - 0.5) < 0.001,
		"40 luck on uncommon should give 50% chance (0.4 + 0.1)"
	)
	print("✓ Luck chance bonus: +10% at 40 luck")

	# Luck chance bonus caps at +25% (100 luck)
	var input_luck_100 = RecyclerService.DismantleInput.new(
		"test_luck_100", RecyclerService.ItemRarity.UNCOMMON, false, 100
	)
	var preview_luck_100 = RecyclerService.preview_dismantle(input_luck_100)
	assert(
		abs(preview_luck_100.components_chance - 0.65) < 0.001,
		"100 luck on uncommon should give 65% chance (0.4 + 0.25)"
	)
	print("✓ Luck chance bonus capped at +25%")

	# Luck components bonus: +1 component per 120 luck
	var input_luck_120 = RecyclerService.DismantleInput.new(
		"test_luck_120", RecyclerService.ItemRarity.UNCOMMON, false, 120
	)
	var preview_luck_120 = RecyclerService.preview_dismantle(input_luck_120)
	assert(
		preview_luck_120.potential_components == 2,
		"120 luck on uncommon should give 2 components (1 + 1)"
	)
	print("✓ Luck components bonus: +1 component at 120 luck")

	# Luck components bonus: +2 components at 240 luck
	var input_luck_240 = RecyclerService.DismantleInput.new(
		"test_luck_240", RecyclerService.ItemRarity.RARE, false, 240
	)
	var preview_luck_240 = RecyclerService.preview_dismantle(input_luck_240)
	assert(
		preview_luck_240.potential_components == 4,
		"240 luck on rare should give 4 components (2 + 2)"
	)
	print("✓ Luck components bonus: +2 components at 240 luck")

	# Verify chance caps at 95% even with high luck
	var input_luck_500 = RecyclerService.DismantleInput.new(
		"test_luck_500", RecyclerService.ItemRarity.LEGENDARY, false, 500
	)
	var preview_luck_500 = RecyclerService.preview_dismantle(input_luck_500)
	assert(preview_luck_500.components_chance <= 0.95, "Components chance should be capped at 95%")
	print("✓ Components chance capped at 95%")


func test_preview_vs_dismantle() -> void:
	print("--- Testing Preview vs Dismantle ---")

	# Preview should always show potential components
	var input_epic = RecyclerService.DismantleInput.new(
		"test_preview", RecyclerService.ItemRarity.EPIC, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input_epic)
	assert(preview.components_granted == 3, "Preview should show 3 components for epic")
	assert(preview.potential_components == 3, "Preview should show potential components")
	print("✓ Preview shows potential components")

	# Dismantle uses randomness (test multiple times)
	var got_components = false
	var got_zero = false

	for i in range(20):
		var outcome = RecyclerService.dismantle_item(input_epic)
		if outcome.components_granted > 0:
			got_components = true
		if outcome.components_granted == 0:
			got_zero = true

	assert(got_components, "Should get components in some dismantles (75% chance over 20 tries)")
	# Note: got_zero tracks 0-component results (25% chance), but we don't assert it
	# since it's probabilistic and might not occur in 20 tries
	print("✓ Dismantle uses randomness (got zero components: %s)" % got_zero)


func test_edge_cases() -> void:
	print("--- Testing Edge Cases ---")

	# Broken item (durability 0) gives 0 scrap
	var input_broken = RecyclerService.DismantleInput.new(
		"test_broken", RecyclerService.ItemRarity.RARE, false, 0
	)
	input_broken.durability = 0
	var outcome_broken = RecyclerService.dismantle_item(input_broken)
	assert(outcome_broken.scrap_granted == 0, "Broken items should give 0 scrap")
	print("✓ Broken item (durability 0): 0 scrap")

	# Negative luck should be normalized to 0
	var input_neg_luck = RecyclerService.DismantleInput.new(
		"test_neg_luck", RecyclerService.ItemRarity.UNCOMMON, false, -10
	)
	var preview_neg_luck = RecyclerService.preview_dismantle(input_neg_luck)
	assert(preview_neg_luck.normalized_luck == 0, "Negative luck should be normalized to 0")
	print("✓ Negative luck normalized to 0")

	# Empty template_id should log error and return zero outcome
	var input_empty = RecyclerService.DismantleInput.new(
		"", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var outcome_empty = RecyclerService.dismantle_item(input_empty)
	assert(outcome_empty.scrap_granted == 0, "Empty template_id should return zero scrap")
	assert(outcome_empty.components_granted == 0, "Empty template_id should return zero components")
	print("✓ Empty template_id handled")

	# Base scrap override
	var input_override = RecyclerService.DismantleInput.new(
		"test_override", RecyclerService.ItemRarity.COMMON, false, 0
	)
	input_override.base_scrap_value = 50
	var outcome_override = RecyclerService.dismantle_item(input_override)
	assert(outcome_override.scrap_granted == 50, "Base scrap override should work")
	print("✓ Base scrap override: 50 scrap")


func test_rarity_helpers() -> void:
	print("--- Testing Rarity Helper Functions ---")

	# Test string to enum conversion
	assert(
		RecyclerService.rarity_from_string("common") == RecyclerService.ItemRarity.COMMON,
		"Should convert 'common' to COMMON"
	)
	assert(
		RecyclerService.rarity_from_string("RARE") == RecyclerService.ItemRarity.RARE,
		"Should convert 'RARE' to RARE (case insensitive)"
	)
	assert(
		RecyclerService.rarity_from_string("legendary") == RecyclerService.ItemRarity.LEGENDARY,
		"Should convert 'legendary' to LEGENDARY"
	)
	print("✓ String to rarity enum conversion")

	# Test enum to string conversion
	assert(
		RecyclerService.rarity_to_string(RecyclerService.ItemRarity.UNCOMMON) == "uncommon",
		"Should convert UNCOMMON to 'uncommon'"
	)
	assert(
		RecyclerService.rarity_to_string(RecyclerService.ItemRarity.EPIC) == "epic",
		"Should convert EPIC to 'epic'"
	)
	print("✓ Rarity enum to string conversion")

	# Test unknown rarity defaults to COMMON
	var unknown_rarity = RecyclerService.rarity_from_string("invalid")
	assert(
		unknown_rarity == RecyclerService.ItemRarity.COMMON,
		"Unknown rarity should default to COMMON"
	)
	print("✓ Unknown rarity defaults to COMMON")
