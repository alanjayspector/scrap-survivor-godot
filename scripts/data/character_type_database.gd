extends RefCounted
class_name CharacterTypeDatabase
## CharacterTypeDatabase - Centralized character type definitions
##
## Week 18 Phase 2: Unified character type database for character creation
##
## Design Principles:
## - Single source of truth for all character type definitions
## - Stat modifiers match CharacterService.DEFAULT_BASE_STATS keys
## - Tier gating controls character access (FREE, PREMIUM, SUBSCRIPTION)
## - weapon_slots varies by type (4-6), inventory_slots is consistent (30)
##
## Based on: docs/game-design/systems/CHARACTER-SYSTEM.md

## Tier levels (must match CharacterService.UserTier)
enum Tier { FREE, PREMIUM, SUBSCRIPTION }

## Default inventory slots for all character types
const DEFAULT_INVENTORY_SLOTS = 30

## =============================================================================
## CHARACTER TYPE DEFINITIONS (6 types)
## Based on: docs/game-design/systems/CHARACTER-SYSTEM.md Section 2.2
## =============================================================================

const CHARACTER_TYPES = {
	# --- FREE TIER CHARACTERS (3 types) ---
	"scavenger":
	{
		"id": "scavenger",
		"display_name": "Scavenger",
		"description": "Knows where the good junk is. Economy-focused with enhanced pickup.",
		"tier_required": Tier.FREE,
		"weapon_slots": 6,
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers":
		{
			"scavenging": 10,  # +10% scrap (scrap_drop_bonus implemented as scavenging stat)
			"pickup_range": 15,  # +15 units pickup range
		},
		"special_mechanics":
		{
			"scrap_drop_bonus": 0.10,  # +10% scrap from all sources (consumed by DropService)
		},
		"starting_items": ["weapon_rusty_blade"],  # Basic melee weapon
		"color": Color(0.72, 0.53, 0.32),  # Dusty Brown/Orange
		"unlock_condition": "default",
	},
	"rustbucket":
	{
		"id": "rustbucket",
		"display_name": "Rustbucket",
		"description": "More patches than original parts. Tank with high survivability.",
		"tier_required": Tier.FREE,
		"weapon_slots": 4,  # -2 weapon slots (tradeoff)
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers":
		{
			"max_hp": 30,  # +30 Max HP
			"armor": 5,  # +5 Armor
		},
		"special_mechanics":
		{
			"speed_multiplier": 0.85,  # -15% movement speed (consumed by movement system)
		},
		"starting_items": ["weapon_rusty_blade", "armor_scrap_vest"],  # Melee + armor
		"color": Color(0.72, 0.40, 0.25),  # Rusty Orange/Red-Brown
		"unlock_condition": "default",
	},
	"hotshot":
	{
		"id": "hotshot",
		"display_name": "Hotshot",
		"description": "Burns bright, burns fast. Glass cannon with high damage output.",
		"tier_required": Tier.FREE,
		"weapon_slots": 6,
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers":
		{
			"crit_chance": 0.10,  # +10% crit chance
			"max_hp": -20,  # -20 Max HP (penalty)
		},
		"special_mechanics":
		{
			"damage_multiplier": 1.20,  # +20% all damage (consumed by combat system)
		},
		"starting_items": ["weapon_plasma_pistol"],  # Ranged weapon for damage dealer
		"color": Color(0.95, 0.55, 0.15),  # Flame Orange/Yellow
		"unlock_condition": "default",
	},
	# --- PREMIUM TIER CHARACTERS (2 types) ---
	"tinkerer":
	{
		"id": "tinkerer",
		"display_name": "Tinkerer",
		"description": "Can always fit one more gadget. Build variety specialist.",
		"tier_required": Tier.PREMIUM,
		"weapon_slots": 6,
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers": {},  # No direct stat modifiers
		"special_mechanics":
		{
			"stack_limit_bonus": 1,  # +1 to all stack limits (consumed by InventoryService)
			"damage_multiplier": 0.90,  # -10% damage (tradeoff)
		},
		"starting_items": ["weapon_plasma_pistol", "trinket_lucky_coin"],
		"color": Color(0.15, 0.65, 0.60),  # Teal/Copper
		"unlock_condition": "premium_purchase",
	},
	"salvager":
	{
		"id": "salvager",
		"display_name": "Salvager",
		"description": "Sees value in everything. Resource efficiency master.",
		"tier_required": Tier.PREMIUM,
		"weapon_slots": 5,  # -1 weapon slot (tradeoff)
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers": {},  # No direct stat modifiers
		"special_mechanics":
		{
			"component_yield_bonus": 0.50,  # +50% components from recycling
			"shop_discount": 0.25,  # 25% off all shop purchases
		},
		"starting_items": ["weapon_rusty_blade", "consumable_scrap_magnet"],
		"color": Color(0.35, 0.60, 0.30),  # Green/Brass
		"unlock_condition": "premium_purchase",
	},
	# --- SUBSCRIPTION TIER CHARACTERS (1 type) ---
	"overclocked":
	{
		"id": "overclocked",
		"display_name": "Overclocked",
		"description": "Pushed past factory specs. High risk, high reward.",
		"tier_required": Tier.SUBSCRIPTION,
		"weapon_slots": 6,
		"inventory_slots": DEFAULT_INVENTORY_SLOTS,
		"stat_modifiers":
		{
			"attack_speed": 25.0,  # +25% attack speed
		},
		"special_mechanics":
		{
			"damage_multiplier": 1.15,  # +15% damage
			"wave_hp_damage_pct": 0.05,  # Takes 5% Max HP damage per wave
		},
		"starting_items": ["weapon_arc_blaster", "consumable_combat_stims"],
		"color": Color(0.30, 0.60, 0.95),  # Electric Blue/White
		"unlock_condition": "subscription_active",
	},
}

## =============================================================================
## ACCESSOR FUNCTIONS
## =============================================================================


## Get all character types as a dictionary
static func get_all_types() -> Dictionary:
	return CHARACTER_TYPES.duplicate(true)


## Get character type by ID
## Returns empty dictionary if not found
static func get_type(type_id: String) -> Dictionary:
	if CHARACTER_TYPES.has(type_id):
		return CHARACTER_TYPES[type_id].duplicate(true)
	return {}


## Get character type count
static func get_type_count() -> int:
	return CHARACTER_TYPES.size()


## Check if type exists
static func has_type(type_id: String) -> bool:
	return CHARACTER_TYPES.has(type_id)


## Get all type IDs
static func get_type_ids() -> Array:
	return CHARACTER_TYPES.keys()


## =============================================================================
## FILTERING FUNCTIONS
## =============================================================================


## Get types available for a specific tier
## Returns array of type dictionaries
static func get_types_for_tier(tier: int) -> Array:
	var result = []
	for type_data in CHARACTER_TYPES.values():
		if type_data.tier_required <= tier:
			result.append(type_data.duplicate(true))
	return result


## Get types requiring exactly a specific tier
## Returns array of type dictionaries
static func get_types_requiring_tier(tier: int) -> Array:
	var result = []
	for type_data in CHARACTER_TYPES.values():
		if type_data.tier_required == tier:
			result.append(type_data.duplicate(true))
	return result


## Get FREE tier types
static func get_free_types() -> Array:
	return get_types_requiring_tier(Tier.FREE)


## Get PREMIUM tier types
static func get_premium_types() -> Array:
	return get_types_requiring_tier(Tier.PREMIUM)


## Get SUBSCRIPTION tier types
static func get_subscription_types() -> Array:
	return get_types_requiring_tier(Tier.SUBSCRIPTION)


## =============================================================================
## SLOT FUNCTIONS
## =============================================================================


## Get weapon slots for a character type
## Returns 6 as default if type not found
static func get_weapon_slots(type_id: String) -> int:
	var type_data = get_type(type_id)
	return type_data.get("weapon_slots", 6)


## Get inventory slots for a character type
## Returns DEFAULT_INVENTORY_SLOTS if type not found
static func get_inventory_slots(type_id: String) -> int:
	var type_data = get_type(type_id)
	return type_data.get("inventory_slots", DEFAULT_INVENTORY_SLOTS)


## =============================================================================
## STAT MODIFIER FUNCTIONS
## =============================================================================


## Get stat modifiers for a character type
## Returns empty dictionary if type not found
static func get_stat_modifiers(type_id: String) -> Dictionary:
	var type_data = get_type(type_id)
	return type_data.get("stat_modifiers", {}).duplicate(true)


## Get special mechanics for a character type
## Returns empty dictionary if type not found
static func get_special_mechanics(type_id: String) -> Dictionary:
	var type_data = get_type(type_id)
	return type_data.get("special_mechanics", {}).duplicate(true)


## =============================================================================
## STARTING ITEMS FUNCTIONS
## =============================================================================


## Get starting items for a character type
## Returns empty array if type not found
static func get_starting_items(type_id: String) -> Array:
	var type_data = get_type(type_id)
	return type_data.get("starting_items", []).duplicate()


## =============================================================================
## DISPLAY FUNCTIONS
## =============================================================================


## Get display name for a character type
static func get_display_name(type_id: String) -> String:
	var type_data = get_type(type_id)
	return type_data.get("display_name", type_id.capitalize())


## Get description for a character type
static func get_description(type_id: String) -> String:
	var type_data = get_type(type_id)
	return type_data.get("description", "")


## Get color for a character type
static func get_color(type_id: String) -> Color:
	var type_data = get_type(type_id)
	return type_data.get("color", Color.WHITE)


## Get tier required for a character type
static func get_tier_required(type_id: String) -> int:
	var type_data = get_type(type_id)
	return type_data.get("tier_required", Tier.FREE)


## =============================================================================
## VALIDATION FUNCTIONS
## =============================================================================


## Check if a tier can access a character type
static func can_access_type(type_id: String, user_tier: int) -> bool:
	var tier_required = get_tier_required(type_id)
	return user_tier >= tier_required


## Validate all character type definitions have required fields
static func validate_definitions() -> Dictionary:
	var errors = []
	var required_fields = [
		"id",
		"display_name",
		"description",
		"tier_required",
		"weapon_slots",
		"inventory_slots",
		"stat_modifiers",
		"special_mechanics",
		"starting_items",
		"color",
		"unlock_condition",
	]

	for type_id in CHARACTER_TYPES.keys():
		var type_data = CHARACTER_TYPES[type_id]
		for field in required_fields:
			if not type_data.has(field):
				errors.append("Type '%s' missing field '%s'" % [type_id, field])

		# Validate ID matches key
		if type_data.get("id", "") != type_id:
			errors.append("Type '%s' has mismatched ID '%s'" % [type_id, type_data.get("id", "")])

		# Validate weapon_slots range
		var weapon_slots = type_data.get("weapon_slots", 0)
		if weapon_slots < 1 or weapon_slots > 10:
			errors.append("Type '%s' has invalid weapon_slots: %d" % [type_id, weapon_slots])

	return {"valid": errors.is_empty(), "errors": errors}
