class_name WeaponResource
extends Resource
## Weapon configuration resource for Scrap Survivor
##
## Defines weapon properties including damage, fire rate, and premium status.
## Created from weapons.json data exported from TypeScript source.

## Unique weapon identifier (e.g., "rusty_pistol")
@export var weapon_id: String = ""

## Display name shown in UI (e.g., "Rusty Pistol")
@export var weapon_name: String = ""

## Base damage per hit
@export var damage: int = 10

## Shots per second
@export var fire_rate: float = 1.0

## Projectile speed in pixels per second
@export var projectile_speed: int = 400

## Maximum range in pixels before projectile despawns
@export var weapon_range: int = 300

## Requires premium unlock to use
@export var is_premium: bool = false

## Rarity tier: common, uncommon, rare, epic, legendary
@export var rarity: String = "common"

## Sprite asset reference
@export var sprite: String = ""


func _to_string() -> String:
	return (
		"WeaponResource(%s: %s, damage=%d, fire_rate=%.1f)"
		% [weapon_id, weapon_name, damage, fire_rate]
	)


## Calculate damage per second
func get_dps() -> float:
	return damage * fire_rate


## Check if weapon is premium tier
func is_premium_weapon() -> bool:
	return is_premium


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
