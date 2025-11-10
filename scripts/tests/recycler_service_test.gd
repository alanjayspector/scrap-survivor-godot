extends GutTest
## Test script for RecyclerService using GUT framework
##
## Tests dismantling mechanics, rarity systems, luck modifiers, and component drops.

class_name RecyclerServiceTest


func before_each() -> void:
	# Reset recycler service before each test
	RecyclerService.reset()


func after_each() -> void:
	# Cleanup
	pass


# Rarity Constants Tests
func test_rarity_enum_values_are_correct() -> void:
	assert_eq(RecyclerService.ItemRarity.COMMON, 0, "COMMON rarity should be 0")
	assert_eq(RecyclerService.ItemRarity.UNCOMMON, 1, "UNCOMMON rarity should be 1")
	assert_eq(RecyclerService.ItemRarity.RARE, 2, "RARE rarity should be 2")
	assert_eq(RecyclerService.ItemRarity.EPIC, 3, "EPIC rarity should be 3")
	assert_eq(RecyclerService.ItemRarity.LEGENDARY, 4, "LEGENDARY rarity should be 4")


func test_scrap_base_values_by_rarity() -> void:
	assert_eq(
		RecyclerService.SCRAP_BASE_BY_RARITY[RecyclerService.ItemRarity.COMMON],
		12,
		"Common scrap base should be 12"
	)
	assert_eq(
		RecyclerService.SCRAP_BASE_BY_RARITY[RecyclerService.ItemRarity.LEGENDARY],
		60,
		"Legendary scrap base should be 60"
	)


func test_component_base_values_by_rarity() -> void:
	assert_eq(
		RecyclerService.COMPONENTS_BASE_BY_RARITY[RecyclerService.ItemRarity.COMMON],
		0,
		"Common components base should be 0"
	)
	assert_eq(
		RecyclerService.COMPONENTS_BASE_BY_RARITY[RecyclerService.ItemRarity.LEGENDARY],
		3,
		"Legendary components base should be 3"
	)


# Scrap Calculations Tests
func test_dismantle_common_non_weapon_gives_base_scrap() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_common", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 12, "Common non-weapon should give 12 scrap")


func test_dismantle_common_weapon_applies_multiplier() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_weapon", RecyclerService.ItemRarity.COMMON, true, 0
	)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 18, "Common weapon should give 18 scrap (12 * 1.5)")


func test_dismantle_rare_non_weapon_gives_higher_scrap() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_rare", RecyclerService.ItemRarity.RARE, false, 0
	)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 35, "Rare non-weapon should give 35 scrap")


func test_dismantle_rare_weapon_applies_multiplier_and_rounds() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_rare_weapon", RecyclerService.ItemRarity.RARE, true, 0
	)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 53, "Rare weapon should give 53 scrap (35 * 1.5 rounded)")


# Component Calculations Tests
func test_common_items_never_drop_components() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_common", RecyclerService.ItemRarity.COMMON, false, 0
	)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.components_granted, 0, "Common should give 0 components")
	assert_eq(outcome.components_chance, 0.0, "Common should have 0% component chance")


func test_uncommon_has_correct_component_chance_and_potential() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_uncommon", RecyclerService.ItemRarity.UNCOMMON, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.potential_components, 1, "Uncommon should have 1 potential component")
	assert_eq(preview.components_chance, 0.4, "Uncommon should have 40% chance")


func test_rare_has_correct_component_chance_and_potential() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_rare", RecyclerService.ItemRarity.RARE, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.potential_components, 2, "Rare should have 2 potential components")
	assert_eq(preview.components_chance, 0.65, "Rare should have 65% chance")


func test_epic_has_correct_component_chance_and_potential() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_epic", RecyclerService.ItemRarity.EPIC, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.potential_components, 3, "Epic should have 3 potential components")
	assert_eq(preview.components_chance, 0.75, "Epic should have 75% chance")


func test_legendary_has_correct_component_chance_and_potential() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_legendary", RecyclerService.ItemRarity.LEGENDARY, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.potential_components, 3, "Legendary should have 3 potential components")
	assert_eq(preview.components_chance, 0.85, "Legendary should have 85% chance")


# Luck Modifier Tests
func test_luck_40_adds_10_percent_component_chance() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_luck", RecyclerService.ItemRarity.UNCOMMON, false, 40
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_almost_eq(
		preview.components_chance, 0.5, 0.001, "40 luck should give 50% chance (0.4 + 0.1)"
	)


func test_luck_chance_bonus_caps_at_25_percent() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_luck_100", RecyclerService.ItemRarity.UNCOMMON, false, 100
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_almost_eq(
		preview.components_chance, 0.65, 0.001, "100 luck should give 65% chance (0.4 + 0.25 cap)"
	)


func test_luck_120_adds_one_component() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_luck_120", RecyclerService.ItemRarity.UNCOMMON, false, 120
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(
		preview.potential_components, 2, "120 luck should give 2 components (1 base + 1 bonus)"
	)


func test_luck_240_adds_two_components() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_luck_240", RecyclerService.ItemRarity.RARE, false, 240
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(
		preview.potential_components, 4, "240 luck should give 4 components (2 base + 2 bonus)"
	)


func test_component_chance_caps_at_95_percent() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_luck_500", RecyclerService.ItemRarity.LEGENDARY, false, 500
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_lte(preview.components_chance, 0.95, "Components chance should be capped at 95%")


# Preview vs Dismantle Tests
func test_preview_shows_potential_components() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_preview", RecyclerService.ItemRarity.EPIC, false, 0
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.components_granted, 3, "Preview should show 3 components for epic")
	assert_eq(preview.potential_components, 3, "Preview should show potential components")


func test_dismantle_uses_randomness_for_components() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_randomness", RecyclerService.ItemRarity.EPIC, false, 0
	)

	var got_components = false
	for i in range(20):
		var outcome = RecyclerService.dismantle_item(input)
		if outcome.components_granted > 0:
			got_components = true
			break

	assert_true(
		got_components, "Should get components in some dismantles over 20 tries (75% chance)"
	)


# Edge Cases Tests
func test_broken_item_gives_zero_scrap() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_broken", RecyclerService.ItemRarity.RARE, false, 0
	)
	input.durability = 0
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 0, "Broken items (durability 0) should give 0 scrap")


func test_negative_luck_normalized_to_zero() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_neg_luck", RecyclerService.ItemRarity.UNCOMMON, false, -10
	)
	var preview = RecyclerService.preview_dismantle(input)
	assert_eq(preview.normalized_luck, 0, "Negative luck should be normalized to 0")


func test_empty_template_id_returns_zero_outcome() -> void:
	var input = RecyclerService.DismantleInput.new("", RecyclerService.ItemRarity.COMMON, false, 0)
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 0, "Empty template_id should return zero scrap")
	assert_eq(outcome.components_granted, 0, "Empty template_id should return zero components")


func test_base_scrap_override_works() -> void:
	var input = RecyclerService.DismantleInput.new(
		"test_override", RecyclerService.ItemRarity.COMMON, false, 0
	)
	input.base_scrap_value = 50
	var outcome = RecyclerService.dismantle_item(input)
	assert_eq(outcome.scrap_granted, 50, "Base scrap override should work")


# Rarity Helper Tests
func test_rarity_from_string_converts_correctly() -> void:
	assert_eq(
		RecyclerService.rarity_from_string("common"),
		RecyclerService.ItemRarity.COMMON,
		"Should convert 'common' to COMMON"
	)
	assert_eq(
		RecyclerService.rarity_from_string("RARE"),
		RecyclerService.ItemRarity.RARE,
		"Should convert 'RARE' to RARE (case insensitive)"
	)
	assert_eq(
		RecyclerService.rarity_from_string("legendary"),
		RecyclerService.ItemRarity.LEGENDARY,
		"Should convert 'legendary' to LEGENDARY"
	)


func test_rarity_to_string_converts_correctly() -> void:
	assert_eq(
		RecyclerService.rarity_to_string(RecyclerService.ItemRarity.UNCOMMON),
		"uncommon",
		"Should convert UNCOMMON to 'uncommon'"
	)
	assert_eq(
		RecyclerService.rarity_to_string(RecyclerService.ItemRarity.EPIC),
		"epic",
		"Should convert EPIC to 'epic'"
	)


func test_unknown_rarity_string_defaults_to_common() -> void:
	var unknown_rarity = RecyclerService.rarity_from_string("invalid")
	assert_eq(
		unknown_rarity, RecyclerService.ItemRarity.COMMON, "Unknown rarity should default to COMMON"
	)
