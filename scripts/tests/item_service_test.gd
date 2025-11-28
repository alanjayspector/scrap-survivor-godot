extends GutTest
## Test script for ItemService using GUT framework
##
## USER STORY: "As a player, I want to see item information in the shop and
## inventory, so that I can make informed decisions about my build"
##
## Tests item loading, lookup, filtering, and validation.

class_name ItemServiceTest


func before_each() -> void:
	# Reset service state before each test
	ItemService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Item Loading and Count Tests
## User Story: "As a developer, I want items loaded from database"
## ============================================================================


func test_item_count_meets_minimum() -> void:
	# Arrange & Act
	var count = ItemService.get_item_count()

	# Assert - Week 18 Phase 1 requires 35+ items
	assert_gte(
		count,
		35,
		"Should have at least 35 items (10 weapons + 10 armor + 10 trinkets + 5 consumables)"
	)


func test_weapons_count() -> void:
	# Arrange & Act
	var weapons = ItemService.get_weapons()

	# Assert
	assert_eq(weapons.size(), 10, "Should have exactly 10 weapons")


func test_armor_count() -> void:
	# Arrange & Act
	var armor = ItemService.get_armor()

	# Assert
	assert_eq(armor.size(), 10, "Should have exactly 10 armor items")


func test_trinkets_count() -> void:
	# Arrange & Act
	var trinkets = ItemService.get_trinkets()

	# Assert
	assert_eq(trinkets.size(), 10, "Should have exactly 10 trinkets")


func test_consumables_count() -> void:
	# Arrange & Act
	var consumables = ItemService.get_consumables()

	# Assert
	assert_eq(consumables.size(), 5, "Should have exactly 5 consumables")


## ============================================================================
## SECTION 2: Item Existence and Lookup Tests
## User Story: "As a system, I need to verify items exist"
## ============================================================================


func test_item_exists_returns_true_for_valid_item() -> void:
	# Arrange & Act
	var exists = ItemService.item_exists("weapon_rusty_blade")

	# Assert
	assert_true(exists, "weapon_rusty_blade should exist")


func test_item_exists_returns_false_for_invalid_item() -> void:
	# Arrange & Act
	var exists = ItemService.item_exists("invalid_item_id")

	# Assert
	assert_false(exists, "Nonexistent item should return false")


func test_get_item_returns_valid_data() -> void:
	# Arrange & Act
	var item = ItemService.get_item("weapon_rusty_blade")

	# Assert
	assert_eq(item.id, "weapon_rusty_blade", "Should return correct ID")
	assert_eq(item.name, "Rusty Blade", "Should return correct name")
	assert_eq(item.type, "weapon", "Should be weapon type")
	assert_eq(item.rarity, "common", "Should be common rarity")
	assert_eq(item.base_price, 75, "Should have base price 75")
	assert_has(item, "stats", "Should have stats dictionary")
	assert_has(item, "stack_limit", "Should have stack_limit")
	assert_eq(item.weapon_type, "melee", "Should be melee weapon")


func test_get_item_returns_empty_for_invalid_item() -> void:
	# Arrange & Act
	var item = ItemService.get_item("invalid_item")

	# Assert
	assert_true(item.is_empty(), "Should return empty dictionary for invalid item")


func test_item_id_uses_type_prefix() -> void:
	# Arrange - Get various items
	var weapon = ItemService.get_item("weapon_plasma_pistol")
	var armor = ItemService.get_item("armor_scrap_vest")
	var trinket = ItemService.get_item("trinket_lucky_coin")
	var consumable = ItemService.get_item("consumable_repair_kit")

	# Assert - IDs should use type prefix convention
	assert_true(weapon.id.begins_with("weapon_"), "Weapon ID should start with weapon_")
	assert_true(armor.id.begins_with("armor_"), "Armor ID should start with armor_")
	assert_true(trinket.id.begins_with("trinket_"), "Trinket ID should start with trinket_")
	assert_true(
		consumable.id.begins_with("consumable_"), "Consumable ID should start with consumable_"
	)


## ============================================================================
## SECTION 3: Filtering Tests
## User Story: "As a shop, I need to filter items by type and rarity"
## ============================================================================


func test_get_items_by_type_weapon() -> void:
	# Arrange & Act
	var weapons = ItemService.get_items_by_type("weapon")

	# Assert
	assert_gt(weapons.size(), 0, "Should return weapons")
	for weapon in weapons:
		assert_eq(weapon.type, "weapon", "All items should be weapons")


func test_get_items_by_type_armor() -> void:
	# Arrange & Act
	var armor = ItemService.get_items_by_type("armor")

	# Assert
	assert_gt(armor.size(), 0, "Should return armor")
	for item in armor:
		assert_eq(item.type, "armor", "All items should be armor")


func test_get_items_by_type_invalid_returns_empty() -> void:
	# Arrange & Act
	var items = ItemService.get_items_by_type("invalid_type")

	# Assert
	assert_eq(items.size(), 0, "Invalid type should return empty array")


func test_get_items_by_rarity_common() -> void:
	# Arrange & Act
	var items = ItemService.get_items_by_rarity("common")

	# Assert
	assert_gt(items.size(), 0, "Should return common items")
	for item in items:
		assert_eq(item.rarity, "common", "All items should be common rarity")


func test_get_items_by_rarity_epic() -> void:
	# Arrange & Act
	var items = ItemService.get_items_by_rarity("epic")

	# Assert
	assert_gt(items.size(), 0, "Should return epic items")
	for item in items:
		assert_eq(item.rarity, "epic", "All items should be epic rarity")


func test_get_items_by_rarity_invalid_returns_empty() -> void:
	# Arrange & Act
	var items = ItemService.get_items_by_rarity("mythic")

	# Assert
	assert_eq(items.size(), 0, "Invalid rarity should return empty array")


func test_get_items_by_type_and_rarity() -> void:
	# Arrange & Act
	var items = ItemService.get_items_by_type_and_rarity("weapon", "uncommon")

	# Assert
	assert_gt(items.size(), 0, "Should return uncommon weapons")
	for item in items:
		assert_eq(item.type, "weapon", "All items should be weapons")
		assert_eq(item.rarity, "uncommon", "All items should be uncommon")


## ============================================================================
## SECTION 4: Item Property Helper Tests
## User Story: "As a UI, I need quick access to item properties"
## ============================================================================


func test_get_item_name() -> void:
	# Arrange & Act
	var name = ItemService.get_item_name("weapon_plasma_pistol")

	# Assert
	assert_eq(name, "Plasma Pistol", "Should return display name")


func test_get_item_name_invalid_returns_unknown() -> void:
	# Arrange & Act
	var name = ItemService.get_item_name("invalid_item")

	# Assert
	assert_eq(name, "Unknown Item", "Invalid item should return 'Unknown Item'")


func test_get_item_type() -> void:
	# Arrange & Act
	var type = ItemService.get_item_type("armor_scrap_vest")

	# Assert
	assert_eq(type, "armor", "Should return 'armor' type")


func test_get_item_rarity() -> void:
	# Arrange & Act
	var rarity = ItemService.get_item_rarity("trinket_quantum_dice")

	# Assert
	assert_eq(rarity, "epic", "Quantum Dice should be epic rarity")


func test_get_item_price() -> void:
	# Arrange & Act
	var price = ItemService.get_item_price("weapon_rusty_blade")

	# Assert
	assert_eq(price, 75, "Rusty Blade should cost 75")


func test_get_item_stats() -> void:
	# Arrange & Act
	var stats = ItemService.get_item_stats("weapon_rusty_blade")

	# Assert
	assert_has(stats, "damage", "Should have damage stat")
	assert_eq(stats.damage, 15, "Damage should be 15")


func test_get_item_stack_limit() -> void:
	# Arrange & Act
	var common_limit = ItemService.get_item_stack_limit("weapon_rusty_blade")  # common
	var epic_limit = ItemService.get_item_stack_limit("weapon_shredder")  # epic

	# Assert
	assert_eq(common_limit, 5, "Common items should stack to 5")
	assert_eq(epic_limit, 2, "Epic items should stack to 2")


func test_is_weapon() -> void:
	# Arrange & Act
	var weapon_result = ItemService.is_weapon("weapon_rusty_blade")
	var armor_result = ItemService.is_weapon("armor_scrap_vest")

	# Assert
	assert_true(weapon_result, "Rusty Blade should be a weapon")
	assert_false(armor_result, "Scrap Vest should not be a weapon")


func test_get_weapon_type_melee() -> void:
	# Arrange & Act
	var weapon_type = ItemService.get_weapon_type("weapon_rusty_blade")

	# Assert
	assert_eq(weapon_type, "melee", "Rusty Blade should be melee")


func test_get_weapon_type_ranged() -> void:
	# Arrange & Act
	var weapon_type = ItemService.get_weapon_type("weapon_plasma_pistol")

	# Assert
	assert_eq(weapon_type, "ranged", "Plasma Pistol should be ranged")


func test_get_weapon_type_non_weapon_returns_empty() -> void:
	# Arrange & Act
	var weapon_type = ItemService.get_weapon_type("armor_scrap_vest")

	# Assert
	assert_eq(weapon_type, "", "Non-weapon should return empty string")


## ============================================================================
## SECTION 5: Rarity Configuration Tests
## User Story: "As a shop, I need rarity information for pricing and display"
## ============================================================================


func test_get_rarity_config_common() -> void:
	# Arrange & Act
	var config = ItemService.get_rarity_config("common")

	# Assert
	assert_has(config, "stack_limit", "Should have stack_limit")
	assert_has(config, "price_min", "Should have price_min")
	assert_has(config, "price_max", "Should have price_max")
	assert_has(config, "color", "Should have color")
	assert_eq(config.stack_limit, 5, "Common stack limit should be 5")


func test_get_rarity_config_legendary() -> void:
	# Arrange & Act
	var config = ItemService.get_rarity_config("legendary")

	# Assert
	assert_eq(config.stack_limit, 1, "Legendary stack limit should be 1")
	assert_gte(config.price_min, 1500, "Legendary price min should be >= 1500")


func test_get_stack_limit_for_rarity() -> void:
	# Arrange & Act
	var common = ItemService.get_stack_limit_for_rarity("common")
	var uncommon = ItemService.get_stack_limit_for_rarity("uncommon")
	var rare = ItemService.get_stack_limit_for_rarity("rare")
	var epic = ItemService.get_stack_limit_for_rarity("epic")
	var legendary = ItemService.get_stack_limit_for_rarity("legendary")

	# Assert - Stack limits decrease with rarity
	assert_eq(common, 5, "Common: 5")
	assert_eq(uncommon, 4, "Uncommon: 4")
	assert_eq(rare, 3, "Rare: 3")
	assert_eq(epic, 2, "Epic: 2")
	assert_eq(legendary, 1, "Legendary: 1")


func test_get_rarity_color() -> void:
	# Arrange & Act
	var common_color = ItemService.get_rarity_color("common")
	var legendary_color = ItemService.get_rarity_color("legendary")

	# Assert - Colors should be different
	assert_ne(common_color, legendary_color, "Common and Legendary colors should differ")


func test_get_valid_rarities() -> void:
	# Arrange & Act
	var rarities = ItemService.get_valid_rarities()

	# Assert
	assert_eq(rarities.size(), 5, "Should have 5 rarities")
	assert_has(rarities, "common", "Should have common")
	assert_has(rarities, "legendary", "Should have legendary")


func test_get_valid_types() -> void:
	# Arrange & Act
	var types = ItemService.get_valid_types()

	# Assert
	assert_eq(types.size(), 4, "Should have 4 types")
	assert_has(types, "weapon", "Should have weapon")
	assert_has(types, "armor", "Should have armor")
	assert_has(types, "trinket", "Should have trinket")
	assert_has(types, "consumable", "Should have consumable")


## ============================================================================
## SECTION 6: Validation Tests
## User Story: "As a developer, I need to verify data integrity"
## ============================================================================


func test_validate_item_valid() -> void:
	# Arrange & Act
	var missing = ItemService.validate_item("weapon_rusty_blade")

	# Assert
	assert_eq(missing.size(), 0, "Valid item should have no missing fields")


func test_validate_item_not_found() -> void:
	# Arrange & Act
	var missing = ItemService.validate_item("invalid_item")

	# Assert
	assert_has(missing, "item_not_found", "Should indicate item not found")


func test_validate_all_items() -> void:
	# Arrange & Act
	var invalid = ItemService.validate_all_items()

	# Assert - All items in database should be valid
	assert_eq(invalid.size(), 0, "All items should be valid (no missing fields)")


## ============================================================================
## SECTION 7: Stats Validation Tests (CharacterService compatibility)
## User Story: "As a combat system, item stats must match character stats"
## ============================================================================


func test_all_item_stats_are_valid_character_stats() -> void:
	# Arrange - Get valid stat keys from CharacterService
	var valid_stats = [
		"max_hp",
		"hp_regen",
		"life_steal",
		"armor",
		"damage",
		"melee_damage",
		"ranged_damage",
		"attack_speed",
		"crit_chance",
		"resonance",
		"dodge",
		"speed",
		"luck",
		"pickup_range",
		"scavenging"
	]

	# Act - Check all items
	var all_items = ItemService.get_all_items()
	var invalid_stats: Dictionary = {}

	for item_id in all_items.keys():
		var item = all_items[item_id]
		var item_stats = item.get("stats", {})
		for stat_key in item_stats.keys():
			if not valid_stats.has(stat_key):
				if not invalid_stats.has(item_id):
					invalid_stats[item_id] = []
				invalid_stats[item_id].append(stat_key)

	# Assert
	assert_eq(
		invalid_stats.size(),
		0,
		"All item stats should be valid CharacterService stats. Invalid: %s" % str(invalid_stats)
	)


func test_weapon_items_have_damage_stats() -> void:
	# Arrange & Act
	var weapons = ItemService.get_weapons()
	var weapons_without_damage = []

	for weapon in weapons:
		var stats = weapon.get("stats", {})
		var has_damage = (
			stats.has("damage") or stats.has("melee_damage") or stats.has("ranged_damage")
		)
		if not has_damage:
			weapons_without_damage.append(weapon.id)

	# Assert
	assert_eq(weapons_without_damage.size(), 0, "All weapons should have some damage stat")


func test_armor_items_have_defensive_stats() -> void:
	# Arrange & Act
	var armor = ItemService.get_armor()
	var armor_without_defense = []

	for item in armor:
		var stats = item.get("stats", {})
		var has_defense = (
			stats.has("armor") or stats.has("max_hp") or stats.has("dodge") or stats.has("hp_regen")
		)
		if not has_defense:
			armor_without_defense.append(item.id)

	# Assert
	assert_eq(armor_without_defense.size(), 0, "All armor should have some defensive stat")


## ============================================================================
## SECTION 8: Price Range Validation Tests
## User Story: "As an economy system, prices must match rarity ranges"
## ============================================================================


func test_common_items_in_price_range() -> void:
	# Arrange
	var config = ItemService.get_rarity_config("common")
	var min_price = config.price_min
	var max_price = config.price_max

	# Act
	var items = ItemService.get_items_by_rarity("common")
	var out_of_range = []

	for item in items:
		var price = item.get("base_price", 0)
		if price < min_price or price > max_price:
			out_of_range.append({"id": item.id, "price": price, "range": [min_price, max_price]})

	# Assert
	assert_eq(
		out_of_range.size(),
		0,
		(
			"All common items should be in price range %d-%d. Out of range: %s"
			% [min_price, max_price, str(out_of_range)]
		)
	)


func test_epic_items_in_price_range() -> void:
	# Arrange
	var config = ItemService.get_rarity_config("epic")
	var min_price = config.price_min
	var max_price = config.price_max

	# Act
	var items = ItemService.get_items_by_rarity("epic")
	var out_of_range = []

	for item in items:
		var price = item.get("base_price", 0)
		if price < min_price or price > max_price:
			out_of_range.append({"id": item.id, "price": price, "range": [min_price, max_price]})

	# Assert
	assert_eq(
		out_of_range.size(),
		0,
		(
			"All epic items should be in price range %d-%d. Out of range: %s"
			% [min_price, max_price, str(out_of_range)]
		)
	)


## ============================================================================
## SECTION 9: Serialization Tests
## User Story: "As a save system, ItemService must support serialization"
## ============================================================================


func test_serialize_returns_dictionary() -> void:
	# Arrange & Act
	var data = ItemService.serialize()

	# Assert
	assert_typeof(data, TYPE_DICTIONARY, "Serialize should return dictionary")
	assert_has(data, "version", "Should have version")
	assert_has(data, "item_count", "Should have item_count")


func test_deserialize_reloads_items() -> void:
	# Arrange
	var initial_count = ItemService.get_item_count()

	# Act
	ItemService.deserialize({})
	var after_count = ItemService.get_item_count()

	# Assert - Should have same count after deserialize
	assert_eq(after_count, initial_count, "Item count should be same after deserialize")


func test_reset_reloads_items() -> void:
	# Arrange
	var initial_count = ItemService.get_item_count()

	# Act
	ItemService.reset()
	var after_count = ItemService.get_item_count()

	# Assert
	assert_eq(after_count, initial_count, "Item count should be same after reset")
