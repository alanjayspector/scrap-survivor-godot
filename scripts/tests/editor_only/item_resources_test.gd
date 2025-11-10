extends GutTest
## Test script for ItemResource loading and functionality using GUT framework
##
## USER STORY: "As a player, I want items with different rarities and effects"
##
## Tests upgrades, consumables, trade-off items, craftable weapons, and helper methods.

class_name ItemResourcesTest

# gdlint: disable=duplicated-load

# Preload the ItemResource script to ensure class is registered in headless mode
const _ITEM_RESOURCE_SCRIPT = preload("res://scripts/resources/item_resource.gd")

## RESOURCE TESTS TOGGLE
## Set to true to enable resource tests when running in Godot Editor GUI
## These tests fail in headless CI due to Godot limitation with custom Resource loading
## See docs/godot-headless-resource-loading-guide.md for technical details
##
## To run tests in Godot Editor:
## 1. Change ENABLE_RESOURCE_TESTS to true
## 2. Open project in Godot Editor GUI
## 3. Run tests from GUT panel (bottom panel)
const ENABLE_RESOURCE_TESTS = true


func before_each() -> void:
	# Setup before each test
	pass


func after_each() -> void:
	# Cleanup
	pass


# Upgrade Tests
func test_health_boost_loads() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var item: ItemResource = load("res://resources/items/health_boost.tres")

	assert_not_null(item, "health_boost should load")


func test_health_boost_has_correct_id() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_eq(health_boost.item_id, "health_boost", "ID should match")


func test_health_boost_has_correct_name() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_eq(health_boost.item_name, "Scrap-Stitched Vitals", "Name should match")


func test_health_boost_is_upgrade_type() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_true(health_boost.is_upgrade(), "Should be upgrade type")


func test_health_boost_has_maxhp_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_eq(health_boost.get_stat_modifier("maxHp"), 20, "Should have +20 maxHp")


func test_health_boost_has_no_trade_offs() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_false(health_boost.has_trade_offs(), "Should have no trade-offs")


func test_damage_up_has_damage_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var damage_up: ItemResource = load("res://resources/items/damage_up.tres")

	assert_eq(damage_up.get_stat_modifier("damage"), 5, "Should have +5 damage")


func test_speed_boost_is_uncommon() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var speed_boost: ItemResource = load("res://resources/items/speed_boost.tres")
	assert_eq(speed_boost.rarity, "uncommon", "Should be uncommon")


func test_speed_boost_has_speed_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var speed_boost: ItemResource = load("res://resources/items/speed_boost.tres")
	assert_eq(speed_boost.get_stat_modifier("speed"), 10, "Should have +10 speed")


func test_armor_plate_is_rare() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var armor_plate: ItemResource = load("res://resources/items/armor_plate.tres")
	assert_eq(armor_plate.rarity, "rare", "Should be rare")


func test_armor_plate_has_armor_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var armor_plate: ItemResource = load("res://resources/items/armor_plate.tres")
	assert_eq(armor_plate.get_stat_modifier("armor"), 5, "Should have +5 armor")


# Consumable Tests
func test_lucky_charm_is_consumable_type() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var lucky_charm: ItemResource = load("res://resources/items/lucky_charm.tres")
	assert_true(lucky_charm.is_consumable(), "Should be consumable type")


func test_lucky_charm_is_epic() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var lucky_charm: ItemResource = load("res://resources/items/lucky_charm.tres")
	assert_eq(lucky_charm.rarity, "epic", "Should be epic")


func test_lucky_charm_has_luck_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var lucky_charm: ItemResource = load("res://resources/items/lucky_charm.tres")
	assert_eq(lucky_charm.get_stat_modifier("luck"), 10, "Should have +10 luck")


func test_vampiric_fangs_is_legendary() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var vampiric_fangs: ItemResource = load("res://resources/items/vampiric_fangs.tres")
	assert_eq(vampiric_fangs.rarity, "legendary", "Should be legendary")


func test_vampiric_fangs_has_lifesteal_modifier() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var vampiric_fangs: ItemResource = load("res://resources/items/vampiric_fangs.tres")
	assert_eq(vampiric_fangs.get_stat_modifier("lifeSteal"), 3, "Should have +3 lifeSteal")


func test_scrap_magnet_has_multiple_modifiers() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var scrap_magnet: ItemResource = load("res://resources/items/scrap_magnet.tres")

	assert_eq(scrap_magnet.get_stat_modifier("pickupRange"), 20, "Should have +20 pickupRange")
	assert_eq(scrap_magnet.get_stat_modifier("scrapGain"), 10, "Should have +10 scrapGain")


# Trade-off Item Tests
func test_reactor_coolant_has_trade_offs() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var reactor_coolant: ItemResource = load("res://resources/items/reactor_coolant.tres")

	assert_true(reactor_coolant.has_trade_offs(), "Should have trade-offs")


func test_reactor_coolant_positive_and_negative_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var reactor_coolant: ItemResource = load("res://resources/items/reactor_coolant.tres")

	assert_eq(reactor_coolant.get_stat_modifier("armor"), 5, "Should have +5 armor")
	assert_eq(reactor_coolant.get_stat_modifier("speed"), -5, "Should have -5 speed")


func test_unstable_serum_has_trade_offs() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var unstable_serum: ItemResource = load("res://resources/items/unstable_serum.tres")

	assert_true(unstable_serum.has_trade_offs(), "Should have trade-offs")


func test_unstable_serum_positive_and_negative_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var unstable_serum: ItemResource = load("res://resources/items/unstable_serum.tres")

	assert_eq(unstable_serum.get_stat_modifier("damage"), 15, "Should have +15 damage")
	assert_eq(unstable_serum.get_stat_modifier("maxHp"), -10, "Should have -10 maxHp")


func test_scavenger_toolkit_has_trade_offs() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var scavenger_toolkit: ItemResource = load("res://resources/items/scavenger_toolkit.tres")
	assert_true(scavenger_toolkit.has_trade_offs(), "Should have trade-offs")


func test_scavenger_toolkit_multiple_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var scavenger_toolkit: ItemResource = load("res://resources/items/scavenger_toolkit.tres")
	assert_eq(scavenger_toolkit.get_stat_modifier("luck"), 12, "Should have +12 luck")
	assert_eq(scavenger_toolkit.get_stat_modifier("scrapGain"), 5, "Should have +5 scrapGain")
	assert_eq(scavenger_toolkit.get_stat_modifier("damage"), -5, "Should have -5 damage")


func test_relic_of_decay_is_legendary() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var relic_of_decay: ItemResource = load("res://resources/items/relic_of_decay.tres")

	assert_eq(relic_of_decay.rarity, "legendary", "Should be legendary")


func test_relic_of_decay_extreme_trade_offs() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var relic_of_decay: ItemResource = load("res://resources/items/relic_of_decay.tres")

	assert_eq(relic_of_decay.get_stat_modifier("damage"), 20, "Should have +20 damage")
	assert_eq(relic_of_decay.get_stat_modifier("speed"), -20, "Should have -20 speed")
	assert_eq(relic_of_decay.get_stat_modifier("dodge"), -20, "Should have -20 dodge")


# Craftable Weapon Tests
func test_rusty_wrench_is_weapon_type() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rusty_wrench: ItemResource = load("res://resources/items/rusty_wrench.tres")

	assert_true(rusty_wrench.is_weapon(), "Should be weapon type")


func test_rusty_wrench_weapon_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rusty_wrench: ItemResource = load("res://resources/items/rusty_wrench.tres")

	assert_eq(rusty_wrench.base_damage, 8, "Should have 8 base damage")
	assert_eq(rusty_wrench.damage_type, "ranged", "Should be ranged")
	assert_eq(rusty_wrench.fire_rate, 1.5, "Should have 1.5 fire rate")
	assert_eq(rusty_wrench.projectile_speed, 350, "Should have 350 projectile speed")
	assert_eq(rusty_wrench.base_range, 200, "Should have 200 range")
	assert_eq(rusty_wrench.max_durability, 100, "Should have 100 durability")
	assert_eq(rusty_wrench.max_fuse_tier, 3, "Should have tier 3 fusion")


func test_rusty_sword_is_melee() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rusty_sword: ItemResource = load("res://resources/items/rusty_sword.tres")

	assert_eq(rusty_sword.damage_type, "melee", "Should be melee")


func test_rusty_sword_melee_properties() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rusty_sword: ItemResource = load("res://resources/items/rusty_sword.tres")

	assert_eq(rusty_sword.projectile_speed, 0, "Melee should have 0 projectile speed")
	assert_eq(rusty_sword.base_range, 60, "Should have short melee range")


func test_plasma_arc_is_legendary() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var plasma_arc: ItemResource = load("res://resources/items/plasma_arc.tres")

	assert_eq(plasma_arc.rarity, "legendary", "Should be legendary")


func test_plasma_arc_legendary_stats() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var plasma_arc: ItemResource = load("res://resources/items/plasma_arc.tres")

	assert_eq(plasma_arc.base_damage, 28, "Should have 28 damage")
	assert_eq(plasma_arc.max_fuse_tier, 1, "Legendary should have tier 1 fusion")
	assert_eq(plasma_arc.base_value, 60, "Should have 60 scrap value")


func test_rail_slagger_is_epic() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rail_slagger: ItemResource = load("res://resources/items/rail_slagger.tres")

	assert_eq(rail_slagger.rarity, "epic", "Should be epic")


func test_rail_slagger_high_damage_slow_rate() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var rail_slagger: ItemResource = load("res://resources/items/rail_slagger.tres")

	assert_eq(rail_slagger.base_damage, 35, "Should have highest damage")
	assert_eq(rail_slagger.fire_rate, 0.4, "Should have slow fire rate")


func test_nail_spitter_fast_fire_rate() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var nail_spitter: ItemResource = load("res://resources/items/nail_spitter.tres")

	assert_eq(nail_spitter.fire_rate, 3.0, "Should have fast fire rate")


# Helper Method Tests
func test_get_stat_descriptions_returns_array() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var scavenger_toolkit: ItemResource = load("res://resources/items/scavenger_toolkit.tres")
	var descriptions = scavenger_toolkit.get_stat_descriptions()

	assert_eq(descriptions.size(), 3, "Should have 3 stat descriptions")


func test_get_rarity_tier_common_is_0() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert_eq(health_boost.get_rarity_tier(), 0, "Common should be tier 0")


func test_get_rarity_tier_uncommon_is_1() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var speed_boost: ItemResource = load("res://resources/items/speed_boost.tres")
	assert_eq(speed_boost.get_rarity_tier(), 1, "Uncommon should be tier 1")


func test_get_rarity_tier_rare_is_2() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var armor_plate: ItemResource = load("res://resources/items/armor_plate.tres")
	assert_eq(armor_plate.get_rarity_tier(), 2, "Rare should be tier 2")


func test_get_rarity_tier_epic_is_3() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var lucky_charm: ItemResource = load("res://resources/items/lucky_charm.tres")
	assert_eq(lucky_charm.get_rarity_tier(), 3, "Epic should be tier 3")


func test_get_rarity_tier_legendary_is_4() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var vampiric_fangs: ItemResource = load("res://resources/items/vampiric_fangs.tres")
	assert_eq(vampiric_fangs.get_rarity_tier(), 4, "Legendary should be tier 4")


func test_to_string_contains_id() -> void:
	if not ENABLE_RESOURCE_TESTS:
		pending("Disabled for headless CI - set ENABLE_RESOURCE_TESTS=true to run in Godot Editor")
		return

	var scavenger_toolkit: ItemResource = load("res://resources/items/scavenger_toolkit.tres")
	var item_str = str(scavenger_toolkit)

	assert_true("scavenger_toolkit" in item_str, "String should contain ID")
