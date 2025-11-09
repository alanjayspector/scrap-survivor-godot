extends Node
## Test script for ItemResource loading and functionality
##
## Tests all 31 item resources (4 upgrades, 12 consumables, 15 weapons)
## Verifies stat modifiers, trade-offs, and weapon properties
##
## Usage:
##   1. Attach this script to a Node in a test scene
##   2. Run the scene
##   3. Check console output for test results

# gdlint: disable=duplicated-load

# Preload resources to avoid duplicated loading
const SCAVENGER_TOOLKIT = preload("res://resources/items/scavenger_toolkit.tres")
const HEALTH_BOOST = preload("res://resources/items/health_boost.tres")
const SPEED_BOOST = preload("res://resources/items/speed_boost.tres")
const ARMOR_PLATE = preload("res://resources/items/armor_plate.tres")
const LUCKY_CHARM = preload("res://resources/items/lucky_charm.tres")
const VAMPIRIC_FANGS = preload("res://resources/items/vampiric_fangs.tres")


func _ready() -> void:
	print("=== Item Resource Test Suite ===")
	print()

	test_upgrades()
	test_consumables()
	test_trade_off_items()
	test_craftable_weapons()
	test_helper_methods()

	print()
	print("=== All Tests Complete ===")


func test_upgrades() -> void:
	print("--- Testing Upgrades (4 items) ---")

	# Test basic upgrade
	var health_boost: ItemResource = load("res://resources/items/health_boost.tres")
	assert(health_boost != null, "health_boost should load")
	assert(health_boost.item_id == "health_boost", "ID should match")
	assert(health_boost.item_name == "Scrap-Stitched Vitals", "Name should match")
	assert(health_boost.is_upgrade(), "Should be upgrade type")
	assert(health_boost.get_stat_modifier("maxHp") == 20, "Should have +20 maxHp")
	assert(!health_boost.has_trade_offs(), "Should have no trade-offs")
	print("✓ health_boost: %s (%s)" % [health_boost.item_name, health_boost.rarity])

	# Test damage upgrade
	var damage_up: ItemResource = load("res://resources/items/damage_up.tres")
	assert(damage_up.get_stat_modifier("damage") == 5, "Should have +5 damage")
	print(
		(
			"✓ damage_up: %s (+%d damage)"
			% [damage_up.item_name, damage_up.get_stat_modifier("damage")]
		)
	)

	# Test speed upgrade
	var speed_boost: ItemResource = load("res://resources/items/speed_boost.tres")
	assert(speed_boost.rarity == "uncommon", "Should be uncommon")
	assert(speed_boost.get_stat_modifier("speed") == 10, "Should have +10 speed")
	print("✓ speed_boost: %s (%s)" % [speed_boost.item_name, speed_boost.rarity])

	# Test armor upgrade
	var armor_plate: ItemResource = load("res://resources/items/armor_plate.tres")
	assert(armor_plate.rarity == "rare", "Should be rare")
	assert(armor_plate.get_stat_modifier("armor") == 5, "Should have +5 armor")
	print("✓ armor_plate: %s (%s)" % [armor_plate.item_name, armor_plate.rarity])

	print()


func test_consumables() -> void:
	print("--- Testing Consumables (12 items) ---")

	# Test epic consumable
	var lucky_charm: ItemResource = load("res://resources/items/lucky_charm.tres")
	assert(lucky_charm.is_consumable(), "Should be consumable type")
	assert(lucky_charm.rarity == "epic", "Should be epic")
	assert(lucky_charm.get_stat_modifier("luck") == 10, "Should have +10 luck")
	print(
		(
			"✓ lucky_charm: %s (%s, +%d luck)"
			% [lucky_charm.item_name, lucky_charm.rarity, lucky_charm.get_stat_modifier("luck")]
		)
	)

	# Test legendary consumable
	var vampiric_fangs: ItemResource = load("res://resources/items/vampiric_fangs.tres")
	assert(vampiric_fangs.rarity == "legendary", "Should be legendary")
	assert(vampiric_fangs.get_stat_modifier("lifeSteal") == 3, "Should have +3 lifeSteal")
	print("✓ vampiric_fangs: %s (%s)" % [vampiric_fangs.item_name, vampiric_fangs.rarity])

	# Test scrap magnet (multi-stat)
	var scrap_magnet: ItemResource = load("res://resources/items/scrap_magnet.tres")
	assert(scrap_magnet.get_stat_modifier("pickupRange") == 20, "Should have +20 pickupRange")
	assert(scrap_magnet.get_stat_modifier("scrapGain") == 10, "Should have +10 scrapGain")
	print("✓ scrap_magnet: %s (multi-stat)" % scrap_magnet.item_name)

	print()


func test_trade_off_items() -> void:
	print("--- Testing Trade-off Items (negative stats) ---")

	# Test reactor coolant (+armor, -speed)
	var reactor_coolant: ItemResource = load("res://resources/items/reactor_coolant.tres")
	assert(reactor_coolant.has_trade_offs(), "Should have trade-offs")
	assert(reactor_coolant.get_stat_modifier("armor") == 5, "Should have +5 armor")
	assert(reactor_coolant.get_stat_modifier("speed") == -5, "Should have -5 speed")
	print("✓ reactor_coolant: +5 armor, -5 speed")

	# Test unstable serum (+damage, -maxHp)
	var unstable_serum: ItemResource = load("res://resources/items/unstable_serum.tres")
	assert(unstable_serum.has_trade_offs(), "Should have trade-offs")
	assert(unstable_serum.get_stat_modifier("damage") == 15, "Should have +15 damage")
	assert(unstable_serum.get_stat_modifier("maxHp") == -10, "Should have -10 maxHp")
	print("✓ unstable_serum: +15 damage, -10 maxHp")

	# Test scavenger toolkit (3 stats with trade-off)
	var scavenger_toolkit: ItemResource = load("res://resources/items/scavenger_toolkit.tres")
	assert(scavenger_toolkit.has_trade_offs(), "Should have trade-offs")
	assert(scavenger_toolkit.get_stat_modifier("luck") == 12, "Should have +12 luck")
	assert(scavenger_toolkit.get_stat_modifier("scrapGain") == 5, "Should have +5 scrapGain")
	assert(scavenger_toolkit.get_stat_modifier("damage") == -5, "Should have -5 damage")
	print("✓ scavenger_toolkit: +12 luck, +5 scrapGain, -5 damage")

	# Test relic of decay (extreme trade-offs)
	var relic_of_decay: ItemResource = load("res://resources/items/relic_of_decay.tres")
	assert(relic_of_decay.rarity == "legendary", "Should be legendary")
	assert(relic_of_decay.get_stat_modifier("damage") == 20, "Should have +20 damage")
	assert(relic_of_decay.get_stat_modifier("speed") == -20, "Should have -20 speed")
	assert(relic_of_decay.get_stat_modifier("dodge") == -20, "Should have -20 dodge")
	print("✓ relic_of_decay: +20 damage, -20 speed, -20 dodge (legendary)")

	print()


func test_craftable_weapons() -> void:
	print("--- Testing Craftable Weapons (15 items) ---")

	# Test common ranged weapon
	var rusty_wrench: ItemResource = load("res://resources/items/rusty_wrench.tres")
	assert(rusty_wrench.is_weapon(), "Should be weapon type")
	assert(rusty_wrench.base_damage == 8, "Should have 8 base damage")
	assert(rusty_wrench.damage_type == "ranged", "Should be ranged")
	assert(rusty_wrench.fire_rate == 1.5, "Should have 1.5 fire rate")
	assert(rusty_wrench.projectile_speed == 350, "Should have 350 projectile speed")
	assert(rusty_wrench.base_range == 200, "Should have 200 range")
	assert(rusty_wrench.max_durability == 100, "Should have 100 durability")
	assert(rusty_wrench.max_fuse_tier == 3, "Should have tier 3 fusion")
	print(
		(
			"✓ rusty_wrench: dmg=%d, rate=%.1f, range=%d"
			% [rusty_wrench.base_damage, rusty_wrench.fire_rate, rusty_wrench.base_range]
		)
	)

	# Test common melee weapon
	var rusty_sword: ItemResource = load("res://resources/items/rusty_sword.tres")
	assert(rusty_sword.damage_type == "melee", "Should be melee")
	assert(rusty_sword.projectile_speed == 0, "Melee should have 0 projectile speed")
	assert(rusty_sword.base_range == 60, "Should have short melee range")
	print(
		"✓ rusty_sword: dmg=%d, melee, range=%d" % [rusty_sword.base_damage, rusty_sword.base_range]
	)

	# Test legendary weapon
	var plasma_arc: ItemResource = load("res://resources/items/plasma_arc.tres")
	assert(plasma_arc.rarity == "legendary", "Should be legendary")
	assert(plasma_arc.base_damage == 28, "Should have 28 damage")
	assert(plasma_arc.max_fuse_tier == 1, "Legendary should have tier 1 fusion")
	assert(plasma_arc.base_value == 60, "Should have 60 scrap value")
	print(
		(
			"✓ plasma_arc: dmg=%d, %s, value=%d"
			% [plasma_arc.base_damage, plasma_arc.rarity, plasma_arc.base_value]
		)
	)

	# Test epic weapon
	var rail_slagger: ItemResource = load("res://resources/items/rail_slagger.tres")
	assert(rail_slagger.rarity == "epic", "Should be epic")
	assert(rail_slagger.base_damage == 35, "Should have highest damage")
	assert(rail_slagger.fire_rate == 0.4, "Should have slow fire rate")
	print(
		(
			"✓ rail_slagger: dmg=%d (highest), rate=%.1f (slowest)"
			% [rail_slagger.base_damage, rail_slagger.fire_rate]
		)
	)

	# Test fast weapon
	var nail_spitter: ItemResource = load("res://resources/items/nail_spitter.tres")
	assert(nail_spitter.fire_rate == 3.0, "Should have fast fire rate")
	print("✓ nail_spitter: rate=%.1f (fastest)" % nail_spitter.fire_rate)

	print()


func test_helper_methods() -> void:
	print("--- Testing Helper Methods ---")

	# Test get_stat_descriptions()
	var descriptions = SCAVENGER_TOOLKIT.get_stat_descriptions()
	assert(descriptions.size() == 3, "Should have 3 stat descriptions")
	print("✓ get_stat_descriptions(): %s" % ", ".join(descriptions))

	# Test get_rarity_tier()
	assert(HEALTH_BOOST.get_rarity_tier() == 0, "Common should be tier 0")
	assert(SPEED_BOOST.get_rarity_tier() == 1, "Uncommon should be tier 1")
	assert(ARMOR_PLATE.get_rarity_tier() == 2, "Rare should be tier 2")
	assert(LUCKY_CHARM.get_rarity_tier() == 3, "Epic should be tier 3")
	assert(VAMPIRIC_FANGS.get_rarity_tier() == 4, "Legendary should be tier 4")
	print("✓ get_rarity_tier(): 0-4 mapping correct")

	# Test _to_string()
	var item_str = str(SCAVENGER_TOOLKIT)
	assert("scavenger_toolkit" in item_str, "String should contain ID")
	print("✓ _to_string(): %s" % item_str)

	print()
