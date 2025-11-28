extends Node
## ShopService - Hub shop generation, purchases, and inventory management
##
## Week 18 Phase 5: Hub-based shop with time-based refresh (not wave-based)
##
## Responsibilities:
## - Generate shop inventory with weighted rarity
## - Handle purchases with currency validation
## - Manage timed shop refreshes (4-hour cycle)
## - Support empty-stock free refresh
## - Support character-specific discounts (Salvager)
## - Provide perk hooks for all operations
##
## Design Patterns:
## - Service Pattern: Manages shop state and operations
## - Observer Pattern: Signals for perk hooks
## - Strategy Pattern: Tier-based rarity weighting
##
## Location: Hub → Shop (per SHOPS-SYSTEM.md)
## See also: docs/game-design/systems/SHOPS-SYSTEM.md

## =============================================================================
## CONSTANTS
## =============================================================================

## Shop configuration
const SHOP_SIZE = 6
const REFRESH_INTERVAL_SECONDS = 14400  # 4 hours

## Rarity weights by user tier (matches SHOPS-SYSTEM.md)
## Format: { "tier": { "common": weight, "uncommon": weight, ... } }
const RARITY_WEIGHTS = {
	"free": {"common": 0.60, "uncommon": 0.30, "rare": 0.08, "epic": 0.015, "legendary": 0.005},
	"premium": {"common": 0.40, "uncommon": 0.35, "rare": 0.20, "epic": 0.04, "legendary": 0.01},
	"subscription":
	{"common": 0.30, "uncommon": 0.30, "rare": 0.30, "epic": 0.08, "legendary": 0.02}
}

## Item type distribution weights
const TYPE_WEIGHTS = {"weapon": 0.35, "armor": 0.30, "trinket": 0.25, "consumable": 0.10}

## =============================================================================
## SIGNALS (Perk Hooks)
## =============================================================================

## Emitted before shop generation - allows perks to modify
## Context: { user_tier, allow_generate, bonus_items }
signal shop_generate_pre(context: Dictionary)

## Emitted after shop generation
## Context: { user_tier, shop_items }
signal shop_generate_post(context: Dictionary)

## Emitted before purchase - allows perks to modify cost or block
## Context: { character_id, item_id, item, base_cost, final_cost, allow_purchase }
signal shop_purchase_pre(context: Dictionary)

## Emitted after successful purchase
## Context: { character_id, item_id, item, cost_paid }
signal shop_purchase_post(context: Dictionary)

## Emitted before reroll - allows perks to modify cost or block
## Context: { character_id, reroll_count, base_cost, final_cost, allow_reroll }
signal shop_reroll_pre(context: Dictionary)

## Emitted after successful reroll
## Context: { character_id, cost_paid, new_items }
signal shop_reroll_post(context: Dictionary)

## Emitted when shop refreshes (timed or reroll)
signal shop_refreshed(items: Array)

## Emitted when purchase fails
signal purchase_failed(reason: String)

## =============================================================================
## STATE
## =============================================================================

## Current shop inventory (array of item dictionaries)
var _shop_items: Array[Dictionary] = []

## Last refresh timestamp (unix time)
var _last_refresh_time: int = 0

## Current user tier for rarity weighting
var _current_user_tier: String = "free"

## =============================================================================
## INITIALIZATION
## =============================================================================


func _ready() -> void:
	# Generate initial shop
	generate_shop()
	GameLogger.info("ShopService initialized", {"shop_size": _shop_items.size()})


## =============================================================================
## SHOP GENERATION
## =============================================================================


## Generate new shop inventory
## user_tier: "free", "premium", or "subscription" (affects rarity weights)
func generate_shop(user_tier: String = "free") -> Array[Dictionary]:
	_current_user_tier = user_tier if RARITY_WEIGHTS.has(user_tier) else "free"

	# Perk hook: shop_generate_pre
	var pre_context = {"user_tier": _current_user_tier, "allow_generate": true, "bonus_items": []}
	shop_generate_pre.emit(pre_context)

	if not pre_context.get("allow_generate", true):
		GameLogger.info("Shop generation blocked by perk")
		return _shop_items

	# Generate items
	var items: Array[Dictionary] = []

	for i in range(SHOP_SIZE):
		var rarity = _roll_rarity(_current_user_tier)
		var item_type = _roll_item_type()
		var item = _get_random_item_of_type_and_rarity(item_type, rarity)
		if not item.is_empty():
			items.append(item)

	# Add any bonus items from perks
	var bonus_items = pre_context.get("bonus_items", [])
	for bonus_item in bonus_items:
		if bonus_item is Dictionary and not bonus_item.is_empty():
			items.append(bonus_item)

	_shop_items = items
	_last_refresh_time = int(Time.get_unix_time_from_system())

	# Perk hook: shop_generate_post
	var post_context = {"user_tier": _current_user_tier, "shop_items": _shop_items.duplicate(true)}
	shop_generate_post.emit(post_context)
	shop_refreshed.emit(_shop_items)

	GameLogger.info(
		"Shop generated", {"user_tier": _current_user_tier, "item_count": _shop_items.size()}
	)

	return _shop_items


## Roll rarity based on user tier weights
func _roll_rarity(user_tier: String) -> String:
	var weights = RARITY_WEIGHTS.get(user_tier, RARITY_WEIGHTS.free)
	var roll = randf()
	var cumulative = 0.0

	for rarity in ["common", "uncommon", "rare", "epic", "legendary"]:
		cumulative += weights.get(rarity, 0.0)
		if roll < cumulative:
			return rarity

	return "common"  # Fallback


## Roll item type based on weights
func _roll_item_type() -> String:
	var roll = randf()
	var cumulative = 0.0

	for item_type in TYPE_WEIGHTS:
		cumulative += TYPE_WEIGHTS[item_type]
		if roll < cumulative:
			return item_type

	return "weapon"  # Fallback


## Get random item of specific type and rarity
func _get_random_item_of_type_and_rarity(item_type: String, rarity: String) -> Dictionary:
	var matching_items = ItemService.get_items_by_type_and_rarity(item_type, rarity)

	if matching_items.is_empty():
		# Fallback: try any item of that rarity
		matching_items = ItemService.get_items_by_rarity(rarity)

	if matching_items.is_empty():
		# Last fallback: any common item
		matching_items = ItemService.get_items_by_rarity("common")

	if matching_items.is_empty():
		GameLogger.warning("No items found for shop", {"type": item_type, "rarity": rarity})
		return {}

	var index = randi() % matching_items.size()
	return matching_items[index]


## =============================================================================
## SHOP ACCESS
## =============================================================================


## Get current shop inventory
func get_shop_items() -> Array[Dictionary]:
	return _shop_items.duplicate(true)


## Get specific item from shop by index
func get_shop_item(index: int) -> Dictionary:
	if index < 0 or index >= _shop_items.size():
		return {}
	return _shop_items[index].duplicate(true)


## Get shop item by item ID
func get_shop_item_by_id(item_id: String) -> Dictionary:
	for item in _shop_items:
		if item.get("id") == item_id:
			return item.duplicate(true)
	return {}


## Check if item is in current shop
func is_item_in_shop(item_id: String) -> bool:
	for item in _shop_items:
		if item.get("id") == item_id:
			return true
	return false


## Get time until next automatic refresh
func get_time_until_refresh() -> int:
	var current_time = int(Time.get_unix_time_from_system())
	var elapsed = current_time - _last_refresh_time
	var remaining = REFRESH_INTERVAL_SECONDS - elapsed
	return maxi(0, remaining)


## Check if shop should auto-refresh (time-based)
func should_refresh() -> bool:
	return get_time_until_refresh() <= 0


## Check if shop is empty and trigger FREE refresh if so
## Returns: true if a refresh was triggered, false otherwise
## Per SHOPS-SYSTEM.md: empty stock = FREE auto-refresh
func check_empty_stock_refresh() -> bool:
	if not is_shop_empty():
		return false

	# Shop is empty - trigger free refresh
	GameLogger.info("Empty stock refresh triggered (free)")
	generate_shop(_current_user_tier)
	return true


## =============================================================================
## PURCHASES
## =============================================================================


## Purchase an item from the shop
## character_id: ID of character making purchase
## item_id: ID of item to purchase
## Returns: Purchased item dictionary, or empty dict on failure
func purchase_item(character_id: String, item_id: String) -> Dictionary:
	# Validate item is in shop
	var item = get_shop_item_by_id(item_id)
	if item.is_empty():
		purchase_failed.emit("Item not in shop")
		GameLogger.warning("Purchase failed: item not in shop", {"item_id": item_id})
		return {}

	# Calculate price with character discounts
	var base_price = item.get("base_price", 0)
	var final_price = calculate_purchase_price(character_id, base_price)

	# Perk hook: shop_purchase_pre
	var pre_context = {
		"character_id": character_id,
		"item_id": item_id,
		"item": item.duplicate(true),
		"base_cost": base_price,
		"final_cost": final_price,
		"allow_purchase": true
	}
	shop_purchase_pre.emit(pre_context)

	if not pre_context.get("allow_purchase", true):
		purchase_failed.emit("Purchase blocked by perk")
		GameLogger.info("Purchase blocked by perk", {"item_id": item_id})
		return {}

	# Use modified cost from perks
	final_price = pre_context.get("final_cost", final_price)

	# Validate currency
	var current_scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	if current_scrap < final_price:
		purchase_failed.emit("Insufficient scrap: need %d, have %d" % [final_price, current_scrap])
		GameLogger.warning(
			"Purchase failed: insufficient funds",
			{"item_id": item_id, "cost": final_price, "balance": current_scrap}
		)
		return {}

	# Deduct currency
	if not BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, final_price):
		purchase_failed.emit("Failed to deduct currency")
		return {}

	# Remove item from shop
	_remove_item_from_shop(item_id)

	# Perk hook: shop_purchase_post
	var post_context = {
		"character_id": character_id,
		"item_id": item_id,
		"item": item.duplicate(true),
		"cost_paid": final_price
	}
	shop_purchase_post.emit(post_context)

	GameLogger.info(
		"Purchase successful",
		{
			"character_id": character_id,
			"item_id": item_id,
			"item_name": item.get("name", "Unknown"),
			"cost": final_price
		}
	)

	return item


## Calculate purchase price with character discounts
## Supports shop_discount stat from Salvager (25% off)
func calculate_purchase_price(character_id: String, base_price: int) -> int:
	var discount = 0.0

	# Get character discount if CharacterService exists
	if character_id and CharacterService:
		var character = CharacterService.get_character(character_id)
		if character and character.has("stats"):
			discount = character.stats.get("shop_discount", 0.0)

	var discounted_price = int(base_price * (1.0 - discount))
	return maxi(1, discounted_price)  # Minimum 1 scrap


## Remove purchased item from shop
func _remove_item_from_shop(item_id: String) -> void:
	for i in range(_shop_items.size()):
		if _shop_items[i].get("id") == item_id:
			_shop_items.remove_at(i)
			return


## =============================================================================
## REROLLS
## =============================================================================


## Reroll shop inventory
## character_id: ID of character doing reroll (for potential discounts)
## Returns: New shop items, or empty array on failure
func reroll_shop(character_id: String = "") -> Array[Dictionary]:
	# Get reroll preview from ShopRerollService
	var preview = ShopRerollService.get_reroll_preview()
	var base_cost = preview.cost
	var final_cost = _calculate_reroll_cost(character_id, base_cost)

	# Perk hook: shop_reroll_pre
	var pre_context = {
		"character_id": character_id,
		"reroll_count": preview.reroll_count,
		"base_cost": base_cost,
		"final_cost": final_cost,
		"allow_reroll": true
	}
	shop_reroll_pre.emit(pre_context)

	if not pre_context.get("allow_reroll", true):
		purchase_failed.emit("Reroll blocked by perk")
		GameLogger.info("Reroll blocked by perk")
		return []

	# Use modified cost from perks
	final_cost = pre_context.get("final_cost", final_cost)

	# Validate currency
	var current_scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	if current_scrap < final_cost:
		purchase_failed.emit(
			"Insufficient scrap for reroll: need %d, have %d" % [final_cost, current_scrap]
		)
		return []

	# Deduct currency
	if not BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, final_cost):
		purchase_failed.emit("Failed to deduct reroll cost")
		return []

	# Execute reroll (increment counter)
	ShopRerollService.execute_reroll()

	# Generate new shop
	var new_items = generate_shop(_current_user_tier)

	# Perk hook: shop_reroll_post
	var post_context = {
		"character_id": character_id,
		"cost_paid": final_cost,
		"new_items": new_items.duplicate(true)
	}
	shop_reroll_post.emit(post_context)

	GameLogger.info(
		"Shop rerolled",
		{"character_id": character_id, "cost": final_cost, "new_item_count": new_items.size()}
	)

	return new_items


## Calculate reroll cost with tier discounts
## Premium: 25% off, Subscription: 50% off
func _calculate_reroll_cost(_character_id: String, base_cost: int) -> int:
	var multiplier = 1.0

	# Tier-based discounts
	match _current_user_tier:
		"premium":
			multiplier = 0.75  # 25% discount
		"subscription":
			multiplier = 0.50  # 50% discount

	return maxi(1, int(base_cost * multiplier))


## Get current reroll cost (for UI display)
func get_reroll_cost(character_id: String = "") -> int:
	var preview = ShopRerollService.get_reroll_preview()
	return _calculate_reroll_cost(character_id, preview.cost)


## Get reroll count for today
func get_reroll_count() -> int:
	return ShopRerollService.get_reroll_count()


## =============================================================================
## STATE MANAGEMENT
## =============================================================================


## Set current user tier (called when tier changes)
func set_user_tier(tier: String) -> void:
	if RARITY_WEIGHTS.has(tier):
		_current_user_tier = tier
	else:
		_current_user_tier = "free"


## Get current shop size
func get_shop_size() -> int:
	return _shop_items.size()


## Check if shop is empty
func is_shop_empty() -> bool:
	return _shop_items.is_empty()


## =============================================================================
## SERIALIZATION
## =============================================================================


## Serialize service state
func serialize() -> Dictionary:
	return {
		"version": 2,
		"shop_items": _shop_items.duplicate(true),
		"last_refresh_time": _last_refresh_time,
		"current_user_tier": _current_user_tier,
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state
## Supports v1 (wave-based) and v2 (hub-based) formats
func deserialize(data: Dictionary) -> void:
	var version = data.get("version", 0)
	if version < 1 or version > 2:
		GameLogger.warning("ShopService: Unknown save version", {"version": version})
		return

	# Restore state
	if data.has("shop_items"):
		_shop_items.clear()
		for item in data.shop_items:
			_shop_items.append(item)

	_last_refresh_time = data.get("last_refresh_time", 0)
	_current_user_tier = data.get("current_user_tier", "free")

	# Check if shop should auto-refresh
	if should_refresh():
		GameLogger.info("Shop auto-refreshing after load (time elapsed)")
		generate_shop(_current_user_tier)
	else:
		GameLogger.info(
			"ShopService state loaded",
			{"item_count": _shop_items.size(), "tier": _current_user_tier}
		)


## Reset service state
func reset() -> void:
	_shop_items.clear()
	_last_refresh_time = 0
	_current_user_tier = "free"
	generate_shop("free")
	GameLogger.info("ShopService reset")
