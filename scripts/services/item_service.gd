extends Node
## ItemService - Unified item data access service
##
## Week 18 Phase 1: Provides item definitions for shop, inventory, and combat systems
##
## Responsibilities:
## - Load and cache item definitions from ItemDatabase
## - Provide item lookup by ID
## - Filter items by type and rarity
## - Validate item existence and data integrity
##
## Design Patterns:
## - Repository Pattern: Single point of access for item data
## - Singleton: Accessed globally via autoload
##
## Based on: docs/migration/week18-plan.md (Phase 1)

## Valid item types (matches ItemDatabase.ItemType)
enum ItemType { WEAPON, ARMOR, TRINKET, CONSUMABLE }

## Valid rarities
const VALID_RARITIES = ["common", "uncommon", "rare", "epic", "legendary"]

## Valid item type strings
const VALID_TYPES = ["weapon", "armor", "trinket", "consumable"]

## Cached item database (loaded once at ready)
var _item_cache: Dictionary = {}

## Signals
signal items_loaded(count: int)


func _ready() -> void:
	_load_items()


## Load all items from ItemDatabase into cache
func _load_items() -> void:
	_item_cache = ItemDatabase.get_all_items()

	var count = _item_cache.size()
	items_loaded.emit(count)

	GameLogger.info(
		"ItemService initialized",
		{
			"item_count": count,
			"weapons": get_items_by_type("weapon").size(),
			"armor": get_items_by_type("armor").size(),
			"trinkets": get_items_by_type("trinket").size(),
			"consumables": get_items_by_type("consumable").size()
		}
	)


## =============================================================================
## ITEM LOOKUP METHODS
## =============================================================================


## Check if item exists
func item_exists(item_id: String) -> bool:
	return _item_cache.has(item_id)


## Get item by ID
## Returns item dictionary or empty dict if not found
func get_item(item_id: String) -> Dictionary:
	if not item_exists(item_id):
		GameLogger.warning("Item not found", {"item_id": item_id})
		return {}

	return _item_cache[item_id].duplicate(true)


## Get all items
## Returns dictionary of all items keyed by ID
func get_all_items() -> Dictionary:
	return _item_cache.duplicate(true)


## Get total item count
func get_item_count() -> int:
	return _item_cache.size()


## =============================================================================
## FILTERING METHODS
## =============================================================================


## Get items filtered by type
## type: "weapon", "armor", "trinket", "consumable"
func get_items_by_type(type: String) -> Array[Dictionary]:
	if not VALID_TYPES.has(type):
		GameLogger.warning("Invalid item type filter", {"type": type})
		return []

	var result: Array[Dictionary] = []
	for item in _item_cache.values():
		if item.get("type") == type:
			result.append(item.duplicate(true))

	return result


## Get items filtered by rarity
## rarity: "common", "uncommon", "rare", "epic", "legendary"
func get_items_by_rarity(rarity: String) -> Array[Dictionary]:
	if not VALID_RARITIES.has(rarity):
		GameLogger.warning("Invalid rarity filter", {"rarity": rarity})
		return []

	var result: Array[Dictionary] = []
	for item in _item_cache.values():
		if item.get("rarity") == rarity:
			result.append(item.duplicate(true))

	return result


## Get items filtered by both type and rarity
func get_items_by_type_and_rarity(type: String, rarity: String) -> Array[Dictionary]:
	if not VALID_TYPES.has(type):
		GameLogger.warning("Invalid item type filter", {"type": type})
		return []

	if not VALID_RARITIES.has(rarity):
		GameLogger.warning("Invalid rarity filter", {"rarity": rarity})
		return []

	var result: Array[Dictionary] = []
	for item in _item_cache.values():
		if item.get("type") == type and item.get("rarity") == rarity:
			result.append(item.duplicate(true))

	return result


## Get all weapon items
func get_weapons() -> Array[Dictionary]:
	return get_items_by_type("weapon")


## Get all armor items
func get_armor() -> Array[Dictionary]:
	return get_items_by_type("armor")


## Get all trinket items
func get_trinkets() -> Array[Dictionary]:
	return get_items_by_type("trinket")


## Get all consumable items
func get_consumables() -> Array[Dictionary]:
	return get_items_by_type("consumable")


## =============================================================================
## ITEM PROPERTY HELPERS
## =============================================================================


## Get item name (display-ready)
func get_item_name(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("name", "Unknown Item")


## Get item description
func get_item_description(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("description", "")


## Get item type
func get_item_type(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("type", "")


## Get item rarity
func get_item_rarity(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("rarity", "common")


## Get item base price
func get_item_price(item_id: String) -> int:
	var item = get_item(item_id)
	return item.get("base_price", 0)


## Get item stats dictionary
func get_item_stats(item_id: String) -> Dictionary:
	var item = get_item(item_id)
	return item.get("stats", {}).duplicate(true)


## Get item stack limit
func get_item_stack_limit(item_id: String) -> int:
	var item = get_item(item_id)
	return item.get("stack_limit", 1)


## Get rarity color for item
func get_item_rarity_color(item_id: String) -> Color:
	var rarity = get_item_rarity(item_id)
	return ItemDatabase.get_rarity_color(rarity)


## Check if item is a weapon
func is_weapon(item_id: String) -> bool:
	return get_item_type(item_id) == "weapon"


## Get weapon type (melee/ranged) for weapon items
func get_weapon_type(item_id: String) -> String:
	var item = get_item(item_id)
	if item.get("type") != "weapon":
		return ""
	return item.get("weapon_type", "")


## =============================================================================
## VALIDATION METHODS
## =============================================================================


## Validate item has required fields
## Returns array of missing field names (empty if valid)
func validate_item(item_id: String) -> Array[String]:
	var missing: Array[String] = []

	if not item_exists(item_id):
		missing.append("item_not_found")
		return missing

	var item = _item_cache[item_id]
	var required_fields = [
		"id", "name", "description", "type", "rarity", "base_price", "stats", "stack_limit"
	]

	for field in required_fields:
		if not item.has(field):
			missing.append(field)

	return missing


## Validate all items in database
## Returns dictionary of item_id -> missing_fields (empty if all valid)
func validate_all_items() -> Dictionary:
	var invalid_items = {}

	for item_id in _item_cache.keys():
		var missing = validate_item(item_id)
		if missing.size() > 0:
			invalid_items[item_id] = missing

	return invalid_items


## =============================================================================
## RARITY HELPERS
## =============================================================================


## Get rarity configuration
func get_rarity_config(rarity: String) -> Dictionary:
	return ItemDatabase.get_rarity_config(rarity)


## Get stack limit for rarity
func get_stack_limit_for_rarity(rarity: String) -> int:
	return ItemDatabase.get_stack_limit_for_rarity(rarity)


## Get rarity color
func get_rarity_color(rarity: String) -> Color:
	return ItemDatabase.get_rarity_color(rarity)


## Get all valid rarities
func get_valid_rarities() -> Array:
	return VALID_RARITIES.duplicate()


## Get all valid types
func get_valid_types() -> Array:
	return VALID_TYPES.duplicate()


## =============================================================================
## SERIALIZATION (for SaveManager compatibility)
## =============================================================================


## Serialize service state (ItemService is stateless, returns minimal data)
func serialize() -> Dictionary:
	return {
		"version": 1,
		"item_count": _item_cache.size(),
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state (ItemService reloads from database)
func deserialize(_data: Dictionary) -> void:
	# ItemService doesn't persist state - it always loads from ItemDatabase
	# This method exists for interface compatibility with other services
	_load_items()
	GameLogger.info("ItemService deserialized (reloaded from database)")


## Reset service state (reload from database)
func reset() -> void:
	_load_items()
	GameLogger.info("ItemService reset")
