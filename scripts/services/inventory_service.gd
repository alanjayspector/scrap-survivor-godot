extends Node

## InventoryService
##
## Manages character inventories, slot limits, stack limits, and auto-active stat calculation.
##
## @desc:
## - Stores item INSTANCES per character (with durability tracking)
## - Enforces slot limits (total and weapon slots)
## - Enforces stack limits by rarity
## - Aggregates stats from all owned items (auto-active)
## - Provides perk hooks for modification
##
## Data Model (v2 - with durability):
## _inventories = {
##     character_id: {
##         "items": [
##             {instance_id, item_id, durability: {current_hp, max_hp}},
##             ...
##         ],
##         "counts": {item_id: count}  # For stack limit checking
##     }
## }

# Signals
signal inventory_add_pre(context: Dictionary)
signal inventory_add_post(context: Dictionary)
signal inventory_remove_pre(context: Dictionary)
signal inventory_remove_post(context: Dictionary)
signal inventory_calculate_stats_pre(context: Dictionary)
signal inventory_calculate_stats_post(context: Dictionary)

# Constants
const DEFAULT_INVENTORY_SLOTS = 30
const DEFAULT_WEAPON_SLOTS = 6
const SAVE_VERSION = 2  # Incremented for instance-based storage

# Data Storage
var _inventories: Dictionary = {}
var _next_instance_id: int = 1


func _ready() -> void:
	pass


## Initialize inventory for a character
## Creates: items = list of instance dicts, counts = {item_id: count} cache
func initialize_inventory(character_id: String) -> void:
	if not _inventories.has(character_id):
		_inventories[character_id] = {"items": [], "counts": {}}


## Add an item to character inventory
## Returns the instance_id on success, empty string on failure
func add_item(character_id: String, item_id: String) -> String:
	# Ensure inventory exists
	if not _inventories.has(character_id):
		initialize_inventory(character_id)

	var item_def = ItemService.get_item(item_id)
	if not item_def:
		GameLogger.error(
			"Attempted to add invalid item ID", {"character_id": character_id, "item_id": item_id}
		)
		return ""

	# Context for pre-hook
	var context = {
		"character_id": character_id, "item_id": item_id, "allow_add": true, "bonus_items": []  # Perks can add extra items
	}

	inventory_add_pre.emit(context)

	if not context.allow_add:
		return ""

	# Validate limits
	if not _validate_slot_limit(character_id, item_def):
		return ""

	if not _validate_stack_limit(character_id, item_def):
		return ""

	# Add item instance
	var instance_id = _add_item_internal(character_id, item_id, item_def)

	# Handle bonus items from perks
	for bonus_id in context.bonus_items:
		# Recursively add bonus items (checking their own limits)
		add_item(character_id, bonus_id)

	# Context for post-hook
	var post_context = {
		"character_id": character_id,
		"item_id": item_id,
		"instance_id": instance_id,
		"new_count": _inventories[character_id]["counts"].get(item_id, 0)
	}

	inventory_add_post.emit(post_context)

	GameLogger.info(
		"Item added to inventory",
		{
			"character_id": character_id,
			"item_id": item_id,
			"instance_id": instance_id,
			"new_count": post_context.new_count
		}
	)
	return instance_id


## Legacy add_item that returns bool for backwards compatibility
## Use add_item() for new code to get instance_id
func add_item_bool(character_id: String, item_id: String) -> bool:
	return add_item(character_id, item_id) != ""


## Remove an item from character inventory by item_id (removes first instance)
## Returns true if successful, false if item not found or blocked
func remove_item(character_id: String, item_id: String) -> bool:
	if not _inventories.has(character_id) or not _inventories[character_id]["counts"].has(item_id):
		GameLogger.warning(
			"Cannot remove item: not in inventory",
			{"character_id": character_id, "item_id": item_id}
		)
		return false

	# Context for pre-hook
	var context = {"character_id": character_id, "item_id": item_id, "allow_remove": true}

	inventory_remove_pre.emit(context)

	if not context.allow_remove:
		return false

	# Remove item instance
	var removed_instance = _remove_item_internal(character_id, item_id)

	# Context for post-hook
	var post_context = {
		"character_id": character_id, "item_id": item_id, "removed_instance": removed_instance
	}

	inventory_remove_post.emit(post_context)

	GameLogger.info(
		"Item removed from inventory",
		{
			"character_id": character_id,
			"item_id": item_id,
			"instance_id": removed_instance.get("instance_id", "")
		}
	)
	return true


## Remove a specific item instance by instance_id
func remove_item_by_instance(character_id: String, instance_id: String) -> bool:
	if not _inventories.has(character_id):
		return false

	var inv = _inventories[character_id]
	for i in range(inv["items"].size()):
		var instance = inv["items"][i]
		if instance.get("instance_id") == instance_id:
			var item_id = instance.get("item_id", "")
			inv["items"].remove_at(i)

			# Update counts
			if inv["counts"].has(item_id):
				inv["counts"][item_id] -= 1
				if inv["counts"][item_id] <= 0:
					inv["counts"].erase(item_id)

			GameLogger.info(
				"Item instance removed",
				{"character_id": character_id, "instance_id": instance_id, "item_id": item_id}
			)
			return true

	return false


## Get all item instances in character inventory
## Returns array of instance dictionaries
func get_inventory(character_id: String) -> Array:
	if not _inventories.has(character_id):
		return []
	return _inventories[character_id]["items"].duplicate(true)


## Get just item IDs (for backwards compatibility and simple iteration)
func get_item_ids(character_id: String) -> Array[String]:
	var result: Array[String] = []
	if not _inventories.has(character_id):
		return result

	for instance in _inventories[character_id]["items"]:
		result.append(instance.get("item_id", ""))

	return result


## Get a specific item instance by instance_id
func get_instance(character_id: String, instance_id: String) -> Dictionary:
	if not _inventories.has(character_id):
		return {}

	for instance in _inventories[character_id]["items"]:
		if instance.get("instance_id") == instance_id:
			return instance.duplicate(true)

	return {}


## Get item count for a specific item_id
func get_item_count(character_id: String, item_id: String) -> int:
	if not _inventories.has(character_id):
		return 0
	return _inventories[character_id]["counts"].get(item_id, 0)


## Calculate aggregated stats from all items
func calculate_stats(character_id: String) -> Dictionary:
	var aggregated_stats = {}

	if not _inventories.has(character_id):
		return aggregated_stats

	var items = _inventories[character_id]["items"]

	# Sum up base stats from items
	for instance in items:
		var item_id = instance.get("item_id", "")
		var item_def = ItemService.get_item(item_id)
		if not item_def or not item_def.has("stats"):
			continue

		for stat_key in item_def.stats:
			var value = item_def.stats[stat_key]
			if aggregated_stats.has(stat_key):
				aggregated_stats[stat_key] += value
			else:
				aggregated_stats[stat_key] = value

	# Context for pre-hook (modification)
	var context = {
		"character_id": character_id,
		"base_stats": aggregated_stats.duplicate(),
		"final_stats": aggregated_stats  # Perks modify this in-place
	}

	inventory_calculate_stats_pre.emit(context)

	# Context for post-hook (logging/reaction)
	var post_context = {
		"character_id": character_id, "final_stats": context.final_stats.duplicate()
	}

	inventory_calculate_stats_post.emit(post_context)

	return context.final_stats


## =============================================================================
## DURABILITY METHODS (Placeholder - full implementation in Week 19+)
## =============================================================================


## Apply durability damage to an item instance
## Returns true if item survived, false if destroyed
func apply_durability_damage(character_id: String, instance_id: String, damage: int) -> bool:
	if not _inventories.has(character_id):
		return false

	for instance in _inventories[character_id]["items"]:
		if instance.get("instance_id") == instance_id:
			var durability = instance.get("durability", {})
			var current_hp = durability.get("current_hp", 0)
			current_hp -= damage

			if current_hp <= 0:
				# Item destroyed
				remove_item_by_instance(character_id, instance_id)
				GameLogger.info(
					"Item destroyed (durability)",
					{
						"character_id": character_id,
						"instance_id": instance_id,
						"item_id": instance.get("item_id", "")
					}
				)
				return false

			instance["durability"]["current_hp"] = current_hp
			return true

	return false


## Repair an item instance
func repair_item(character_id: String, instance_id: String, heal_amount: int) -> void:
	if not _inventories.has(character_id):
		return

	for instance in _inventories[character_id]["items"]:
		if instance.get("instance_id") == instance_id:
			var durability = instance.get("durability", {})
			var current_hp = durability.get("current_hp", 0)
			var max_hp = durability.get("max_hp", 100)
			instance["durability"]["current_hp"] = mini(current_hp + heal_amount, max_hp)
			return


## Get durability percentage for an item instance
func get_durability_percent(character_id: String, instance_id: String) -> float:
	var instance = get_instance(character_id, instance_id)
	if instance.is_empty():
		return 0.0

	var durability = instance.get("durability", {})
	var current_hp = durability.get("current_hp", 0)
	var max_hp = durability.get("max_hp", 1)
	return float(current_hp) / float(max_hp)


## =============================================================================
## INTERNAL HELPERS
## =============================================================================


func _add_item_internal(character_id: String, item_id: String, item_def: Dictionary) -> String:
	var inv = _inventories[character_id]

	# Generate unique instance ID
	var instance_id = "inst_%d" % _next_instance_id
	_next_instance_id += 1

	# Get base durability from rarity
	var rarity = item_def.get("rarity", "common")
	var base_durability = ItemDatabase.get_base_durability_for_rarity(rarity)

	# Create item instance
	var instance = {
		"instance_id": instance_id,
		"item_id": item_id,
		"durability": {"current_hp": base_durability, "max_hp": base_durability}
	}

	inv["items"].append(instance)

	# Update counts cache
	if inv["counts"].has(item_id):
		inv["counts"][item_id] += 1
	else:
		inv["counts"][item_id] = 1

	return instance_id


func _remove_item_internal(character_id: String, item_id: String) -> Dictionary:
	var inv = _inventories[character_id]
	var removed_instance = {}

	# Find and remove first instance with matching item_id
	for i in range(inv["items"].size()):
		var instance = inv["items"][i]
		if instance.get("item_id") == item_id:
			removed_instance = instance.duplicate(true)
			inv["items"].remove_at(i)
			break

	# Update counts
	if inv["counts"].has(item_id):
		inv["counts"][item_id] -= 1
		if inv["counts"][item_id] <= 0:
			inv["counts"].erase(item_id)

	return removed_instance


func _validate_slot_limit(character_id: String, item_def: Dictionary) -> bool:
	var inv = _inventories[character_id]
	var current_total = inv["items"].size()

	# Get limits from CharacterService (or defaults)
	var char_data = CharacterService.get_character(character_id)
	var total_slots = DEFAULT_INVENTORY_SLOTS
	var weapon_slots = DEFAULT_WEAPON_SLOTS

	if char_data:
		total_slots = char_data.get("inventory_slots", DEFAULT_INVENTORY_SLOTS)
		weapon_slots = char_data.get("weapon_slots", DEFAULT_WEAPON_SLOTS)

	# Check total slots
	if current_total >= total_slots:
		GameLogger.info(
			"Total slot limit reached",
			{"character_id": character_id, "current": current_total, "limit": total_slots}
		)
		return false

	# Check weapon slots if item is a weapon
	if item_def.get("type") == "weapon":
		var current_weapons = 0
		for instance in inv["items"]:
			var inst_item_id = instance.get("item_id", "")
			var def = ItemService.get_item(inst_item_id)
			if def and def.get("type") == "weapon":
				current_weapons += 1

		if current_weapons >= weapon_slots:
			GameLogger.info(
				"Weapon slot limit reached",
				{"character_id": character_id, "current": current_weapons, "limit": weapon_slots}
			)
			return false

	return true


func _validate_stack_limit(character_id: String, item_def: Dictionary) -> bool:
	var inv = _inventories[character_id]
	var item_id = item_def.get("id")
	var current_count = inv["counts"].get(item_id, 0)

	# Get base stack limit from item definition (default based on rarity)
	var base_limit = item_def.get("stack_limit", 999)

	# Apply character bonuses (Tinkerer: +1 to all stack limits)
	var char_data = CharacterService.get_character(character_id)
	var stack_bonus = 0
	if char_data and char_data.has("stats"):
		stack_bonus = char_data.stats.get("stack_limit_bonus", 0)

	var final_limit = base_limit + stack_bonus

	if current_count >= final_limit:
		GameLogger.info(
			"Stack limit reached",
			{
				"character_id": character_id,
				"item_id": item_id,
				"current": current_count,
				"limit": final_limit
			}
		)
		return false

	return true


## =============================================================================
## PERSISTENCE
## =============================================================================


## Serialize service state
func serialize() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"inventories": _inventories.duplicate(true),
		"next_instance_id": _next_instance_id,
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state
func deserialize(data: Dictionary) -> void:
	var version = data.get("version", 0)

	if version == 1:
		# Migrate from v1 (string IDs) to v2 (instances)
		_migrate_v1_to_v2(data)
	elif version == SAVE_VERSION:
		# Current version
		if data.has("inventories"):
			_inventories = data.inventories.duplicate(true)
		_next_instance_id = data.get("next_instance_id", 1)
	else:
		GameLogger.warning("InventoryService: Unknown save version", {"version": version})
		return

	var total_items = 0
	for char_id in _inventories:
		total_items += _inventories[char_id]["items"].size()

	GameLogger.info(
		"InventoryService state loaded",
		{"character_count": _inventories.size(), "total_items": total_items, "version": version}
	)


## Migrate v1 data (item IDs as strings) to v2 (item instances with durability)
func _migrate_v1_to_v2(data: Dictionary) -> void:
	GameLogger.info("Migrating InventoryService data from v1 to v2")

	_inventories.clear()
	_next_instance_id = 1

	var old_inventories = data.get("inventories", {})
	for char_id in old_inventories:
		initialize_inventory(char_id)
		var old_inv = old_inventories[char_id]
		var old_items = old_inv.get("items", [])

		for item in old_items:
			# In v1, items was an array of strings (item_ids)
			if item is String:
				var item_def = ItemService.get_item(item)
				if item_def:
					_add_item_internal(char_id, item, item_def)
			# In case it's already a dictionary (partial migration)
			elif item is Dictionary and item.has("item_id"):
				var item_id = item.get("item_id")
				var item_def = ItemService.get_item(item_id)
				if item_def:
					# Preserve existing durability if present
					var instance_id = _add_item_internal(char_id, item_id, item_def)
					if item.has("durability"):
						for inst in _inventories[char_id]["items"]:
							if inst.get("instance_id") == instance_id:
								inst["durability"] = item.get("durability")
								break


## Reset service state (for testing or new game)
func reset() -> void:
	_inventories.clear()
	_next_instance_id = 1
	GameLogger.info("InventoryService reset")
