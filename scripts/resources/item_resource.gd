class_name ItemResource
extends Resource
## Item configuration resource for Scrap Survivor
##
## Defines item properties including type, rarity, and stat modifiers.
## Supports upgrades, consumables, and craftable weapons.
## Created from items.json data exported from TypeScript source.

## Unique item identifier (e.g., "health_boost")
@export var item_id: String = ""

## Display name shown in UI (e.g., "Scrap-Stitched Vitals")
@export var item_name: String = ""

## Item description for tooltips
@export_multiline var description: String = ""

## Item type: upgrade, item, or weapon
@export_enum("upgrade", "item", "weapon") var item_type: String = "item"

## Rarity tier: common, uncommon, rare, epic, legendary
@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity: String = "common"

## Stat modifiers (stored as Dictionary for flexibility)
## Supports: maxHp, damage, speed, armor, luck, lifeSteal, scrapGain, dodge
## Can have negative values for trade-off items
@export var stat_modifiers: Dictionary = {}

## Weapon-specific properties (only for item_type="weapon")
@export_group("Weapon Properties")

## Base weapon damage (for craftable weapons)
@export var base_damage: int = 0

## Damage type: ranged or melee
@export_enum("ranged", "melee") var damage_type: String = "ranged"

## Fire rate in shots per second
@export var fire_rate: float = 0.0

## Projectile speed in pixels per second
@export var projectile_speed: int = 0

## Maximum weapon range in pixels
@export var base_range: int = 0

## Maximum durability (for degrading weapons)
@export var max_durability: int = 0

## Maximum fusion tier
@export var max_fuse_tier: int = 1

## Base scrap value
@export var base_value: int = 0


func _to_string() -> String:
	return "ItemResource(%s: %s, type=%s, rarity=%s)" % [item_id, item_name, item_type, rarity]


## Check if item is an upgrade (permanent stat improvement)
func is_upgrade() -> bool:
	return item_type == "upgrade"


## Check if item is consumable
func is_consumable() -> bool:
	return item_type == "item"


## Check if item is a craftable weapon
func is_weapon() -> bool:
	return item_type == "weapon"


## Get a specific stat modifier value (returns 0 if not present)
func get_stat_modifier(stat_name: String) -> float:
	if stat_modifiers.has(stat_name):
		return float(stat_modifiers[stat_name])
	return 0.0


## Check if this is a trade-off item (has negative stats)
func has_trade_offs() -> bool:
	for value in stat_modifiers.values():
		if float(value) < 0:
			return true
	return false


## Get all stat modifiers as formatted strings (for UI display)
func get_stat_descriptions() -> Array[String]:
	var descriptions: Array[String] = []

	for stat_name in stat_modifiers.keys():
		var value = stat_modifiers[stat_name]
		var sign = "+" if float(value) > 0 else ""
		descriptions.append("%s%s %s" % [sign, value, stat_name])

	return descriptions


## Get rarity tier as enum value (for sorting/filtering)
func get_rarity_tier() -> int:
	match rarity:
		"common":
			return 0
		"uncommon":
			return 1
		"rare":
			return 2
		"epic":
			return 3
		"legendary":
			return 4
		_:
			return 0
