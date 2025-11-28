extends GutTest
## Test script for InventoryService using GUT framework
##
## USER STORY: "As a player, I want my items stored in an inventory with limits"
##
## Week 18 Phase 4: Tests inventory management, slot limits, stack limits,
## auto-active stat calculation, perk hooks, and durability placeholder.

class_name InventoryServiceTest

var _character_id = "test_char_1"
var _mock_item_sword = {
	"id": "weapon_rusty_blade",
	"type": "weapon",
	"rarity": "common",
	"stack_limit": 5,
	"stats": {"damage": 10}
}
var _mock_item_armor = {
	"id": "armor_scrap_vest",
	"type": "armor",
	"rarity": "common",
	"stack_limit": 5,
	"stats": {"armor": 5}
}
var _mock_item_legendary = {
	"id": "weapon_excalibur",
	"type": "weapon",
	"rarity": "legendary",
	"stack_limit": 1,
	"stats": {"damage": 100}
}


func before_each():
	# Reset InventoryService state
	InventoryService._inventories.clear()
	InventoryService._next_instance_id = 1

	# Inject mock items into ItemService cache
	# We access the private _item_cache directly for testing purposes
	# IMPORTANT: Use duplicate() to prevent test pollution from modifications
	ItemService._item_cache["weapon_rusty_blade"] = _mock_item_sword.duplicate(true)
	ItemService._item_cache["armor_scrap_vest"] = _mock_item_armor.duplicate(true)
	ItemService._item_cache["weapon_excalibur"] = _mock_item_legendary.duplicate(true)

	# Inject mock character into CharacterService
	CharacterService.characters[_character_id] = {
		"id": _character_id, "inventory_slots": 10, "weapon_slots": 2
	}


func after_each():
	# Cleanup injected data
	ItemService._item_cache.erase("weapon_rusty_blade")
	ItemService._item_cache.erase("armor_scrap_vest")
	ItemService._item_cache.erase("weapon_excalibur")
	CharacterService.characters.erase(_character_id)

	# Disconnect all signals to prevent test pollution
	for conn in InventoryService.inventory_add_pre.get_connections():
		InventoryService.inventory_add_pre.disconnect(conn.callable)
	for conn in InventoryService.inventory_add_post.get_connections():
		InventoryService.inventory_add_post.disconnect(conn.callable)
	for conn in InventoryService.inventory_calculate_stats_pre.get_connections():
		InventoryService.inventory_calculate_stats_pre.disconnect(conn.callable)
	for conn in InventoryService.inventory_calculate_stats_post.get_connections():
		InventoryService.inventory_calculate_stats_post.disconnect(conn.callable)


func test_add_item_success():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")
	assert_ne(instance_id, "", "Should return instance_id on success")
	assert_true(instance_id.begins_with("inst_"), "Instance ID should have correct prefix")

	var inv = InventoryService.get_inventory(_character_id)
	assert_eq(inv.size(), 1, "Inventory should have 1 item")
	assert_eq(inv[0].item_id, "weapon_rusty_blade", "Item ID should match")
	assert_true(inv[0].has("durability"), "Instance should have durability")
	assert_eq(inv[0].durability.current_hp, 100, "Common item should have 100 HP")
	assert_eq(inv[0].durability.max_hp, 100, "Common item should have 100 max HP")


func test_add_item_durability_by_rarity():
	# Test that durability varies by rarity
	InventoryService.add_item(_character_id, "weapon_rusty_blade")  # common = 100
	InventoryService.add_item(_character_id, "weapon_excalibur")  # legendary = 1600

	var inv = InventoryService.get_inventory(_character_id)
	var common_item = inv[0]
	var legendary_item = inv[1]

	assert_eq(common_item.durability.max_hp, 100, "Common should have 100 HP")
	assert_eq(legendary_item.durability.max_hp, 1600, "Legendary should have 1600 HP")


func test_remove_item_success():
	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	var result = InventoryService.remove_item(_character_id, "weapon_rusty_blade")
	assert_true(result, "Should remove item successfully")

	var inv = InventoryService.get_inventory(_character_id)
	assert_eq(inv.size(), 0, "Inventory should be empty")


func test_get_item_ids():
	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	InventoryService.add_item(_character_id, "armor_scrap_vest")

	var ids = InventoryService.get_item_ids(_character_id)
	assert_eq(ids.size(), 2, "Should have 2 item IDs")
	assert_true("weapon_rusty_blade" in ids, "Should contain sword")
	assert_true("armor_scrap_vest" in ids, "Should contain armor")


func test_stack_limit_enforcement():
	# Increase weapon slots for this test to allow 5 swords
	CharacterService.characters[_character_id]["weapon_slots"] = 10

	# Add 5 swords (limit is 5)
	for i in range(5):
		var result = InventoryService.add_item(_character_id, "weapon_rusty_blade")
		assert_ne(result, "", "Should add sword %d" % (i + 1))

	# Try adding 6th sword
	var result = InventoryService.add_item(_character_id, "weapon_rusty_blade")
	assert_eq(result, "", "Should block 6th sword (stack limit)")


func test_legendary_stack_limit():
	# Add 1 legendary (limit is 1)
	var result1 = InventoryService.add_item(_character_id, "weapon_excalibur")
	assert_ne(result1, "", "Should add first legendary")

	# Try adding 2nd legendary
	var result2 = InventoryService.add_item(_character_id, "weapon_excalibur")
	assert_eq(result2, "", "Should block 2nd legendary")


func test_weapon_slot_limit():
	# Limit is 2 weapons (default in before_each)
	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	InventoryService.add_item(_character_id, "weapon_rusty_blade")

	# Try adding 3rd weapon
	var result = InventoryService.add_item(_character_id, "weapon_excalibur")
	assert_eq(result, "", "Should block 3rd weapon (slot limit)")

	# Should still be able to add armor (not a weapon)
	var armor_result = InventoryService.add_item(_character_id, "armor_scrap_vest")
	assert_ne(armor_result, "", "Should allow armor even if weapon slots full")


func test_total_slot_limit():
	# Increase stack limit for armor to allow 8 of them
	ItemService._item_cache["armor_scrap_vest"]["stack_limit"] = 10

	# Limit is 10 total
	# Fill with 2 weapons + 8 armor
	for i in range(2):
		InventoryService.add_item(_character_id, "weapon_rusty_blade")
	for i in range(8):
		InventoryService.add_item(_character_id, "armor_scrap_vest")

	assert_eq(InventoryService.get_inventory(_character_id).size(), 10, "Should have 10 items")

	# Try adding 11th item
	var result = InventoryService.add_item(_character_id, "armor_scrap_vest")
	assert_eq(result, "", "Should block 11th item (total slot limit)")


func test_calculate_stats():
	InventoryService.add_item(_character_id, "weapon_rusty_blade")  # +10 damage
	InventoryService.add_item(_character_id, "armor_scrap_vest")  # +5 armor

	var stats = InventoryService.calculate_stats(_character_id)
	assert_eq(stats.get("damage", 0), 10, "Should have 10 damage")
	assert_eq(stats.get("armor", 0), 5, "Should have 5 armor")


func test_calculate_stats_hook():
	InventoryService.add_item(_character_id, "weapon_rusty_blade")  # +10 damage

	# Connect to hook to modify stats
	InventoryService.inventory_calculate_stats_pre.connect(
		func(ctx):
			ctx.final_stats["damage"] += 5  # Add bonus 5 damage
			ctx.final_stats["bonus_stat"] = 100
	)

	var stats = InventoryService.calculate_stats(_character_id)
	assert_eq(stats.get("damage", 0), 15, "Should have 15 damage (10 base + 5 hook)")
	assert_eq(stats.get("bonus_stat", 0), 100, "Should have bonus stat from hook")


func test_add_item_hook_pre_block():
	# Hook blocks addition
	InventoryService.inventory_add_pre.connect(func(ctx): ctx.allow_add = false)

	var result = InventoryService.add_item(_character_id, "weapon_rusty_blade")
	assert_eq(result, "", "Should be blocked by hook")
	assert_eq(InventoryService.get_inventory(_character_id).size(), 0)


func test_add_item_hook_bonus():
	# Hook adds bonus item
	InventoryService.inventory_add_pre.connect(
		func(ctx):
			if ctx.item_id == "weapon_rusty_blade":
				ctx.bonus_items.append("armor_scrap_vest")
	)

	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	var inv = InventoryService.get_inventory(_character_id)

	assert_eq(inv.size(), 2, "Should have 2 items (1 added + 1 bonus)")
	var item_ids = InventoryService.get_item_ids(_character_id)
	assert_true("weapon_rusty_blade" in item_ids)
	assert_true("armor_scrap_vest" in item_ids)


func test_persistence():
	# Setup initial state
	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	InventoryService.add_item(_character_id, "armor_scrap_vest")

	# Serialize
	var data = InventoryService.serialize()
	assert_eq(data.version, 2, "Should be version 2")

	# Clear state (simulate restart)
	InventoryService._inventories.clear()
	InventoryService._next_instance_id = 1
	assert_eq(
		InventoryService.get_inventory(_character_id).size(),
		0,
		"Inventory should be empty after clear"
	)

	# Deserialize
	InventoryService.deserialize(data)

	# Verify restoration
	var inv = InventoryService.get_inventory(_character_id)
	assert_eq(inv.size(), 2, "Inventory should be restored")
	var item_ids = InventoryService.get_item_ids(_character_id)
	assert_true("weapon_rusty_blade" in item_ids)
	assert_true("armor_scrap_vest" in item_ids)

	# Verify durability was preserved
	assert_true(inv[0].has("durability"), "Durability should be preserved")


func test_persistence_v1_migration():
	# Create v1 format data (string IDs instead of instances)
	var v1_data = {
		"version": 1,
		"inventories":
		{
			_character_id:
			{
				"items": ["weapon_rusty_blade", "armor_scrap_vest"],
				"counts": {"weapon_rusty_blade": 1, "armor_scrap_vest": 1}
			}
		}
	}

	# Deserialize (should migrate)
	InventoryService.deserialize(v1_data)

	# Verify migration
	var inv = InventoryService.get_inventory(_character_id)
	assert_eq(inv.size(), 2, "Should have 2 items after migration")
	assert_true(inv[0].has("instance_id"), "Should have instance_id after migration")
	assert_true(inv[0].has("durability"), "Should have durability after migration")


func test_tinkerer_stack_limit_bonus():
	# Tinkerer has stack_limit_bonus: 1, allowing 6 common items instead of 5
	var tinkerer_id = "test_tinkerer"
	CharacterService.characters[tinkerer_id] = {
		"id": tinkerer_id,
		"inventory_slots": 30,
		"weapon_slots": 10,
		"stats": {"stack_limit_bonus": 1}  # Tinkerer bonus
	}

	# Add 5 armor (normal limit for common)
	for i in range(5):
		var result = InventoryService.add_item(tinkerer_id, "armor_scrap_vest")
		assert_ne(result, "", "Should add armor %d" % (i + 1))

	# Tinkerer can add a 6th (base 5 + 1 bonus)
	var result = InventoryService.add_item(tinkerer_id, "armor_scrap_vest")
	assert_ne(result, "", "Tinkerer should be able to add 6th armor (stack bonus)")

	# But not a 7th
	var blocked = InventoryService.add_item(tinkerer_id, "armor_scrap_vest")
	assert_eq(blocked, "", "Should block 7th armor even for Tinkerer")

	# Cleanup
	CharacterService.characters.erase(tinkerer_id)


func test_reset():
	# Setup some state
	InventoryService.add_item(_character_id, "weapon_rusty_blade")
	assert_eq(InventoryService.get_inventory(_character_id).size(), 1)

	# Reset
	InventoryService.reset()

	# Verify cleared
	assert_eq(
		InventoryService.get_inventory(_character_id).size(),
		0,
		"Inventory should be empty after reset"
	)
	assert_eq(InventoryService._next_instance_id, 1, "Instance ID counter should reset")


func test_durability_damage():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")

	# Apply damage
	var survived = InventoryService.apply_durability_damage(_character_id, instance_id, 30)
	assert_true(survived, "Item should survive 30 damage")

	# Check durability
	var percent = InventoryService.get_durability_percent(_character_id, instance_id)
	assert_almost_eq(percent, 0.7, 0.01, "Should be at 70% durability")


func test_durability_destroy():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")

	# Apply fatal damage
	var survived = InventoryService.apply_durability_damage(_character_id, instance_id, 150)
	assert_false(survived, "Item should be destroyed")

	# Verify item removed
	assert_eq(
		InventoryService.get_inventory(_character_id).size(),
		0,
		"Item should be removed from inventory"
	)


func test_repair_item():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")

	# Damage item
	InventoryService.apply_durability_damage(_character_id, instance_id, 50)

	# Repair item
	InventoryService.repair_item(_character_id, instance_id, 30)

	# Check durability (was 50, now 80)
	var percent = InventoryService.get_durability_percent(_character_id, instance_id)
	assert_almost_eq(percent, 0.8, 0.01, "Should be at 80% durability after repair")


func test_repair_item_cap():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")

	# Damage slightly
	InventoryService.apply_durability_damage(_character_id, instance_id, 10)

	# Over-repair
	InventoryService.repair_item(_character_id, instance_id, 100)

	# Should be capped at 100%
	var percent = InventoryService.get_durability_percent(_character_id, instance_id)
	assert_almost_eq(percent, 1.0, 0.01, "Should be capped at 100%")


func test_remove_item_by_instance():
	var instance_id = InventoryService.add_item(_character_id, "weapon_rusty_blade")
	InventoryService.add_item(_character_id, "weapon_rusty_blade")  # Add second

	# Remove specific instance
	var result = InventoryService.remove_item_by_instance(_character_id, instance_id)
	assert_true(result, "Should remove specific instance")

	# Should have 1 remaining
	assert_eq(InventoryService.get_inventory(_character_id).size(), 1)
	assert_eq(InventoryService.get_item_count(_character_id, "weapon_rusty_blade"), 1)
