class_name EnemyResource
extends Resource
## Enemy type configuration resource for Scrap Survivor
##
## Defines enemy properties including base stats and wave scaling.
## Created from enemies.json data exported from TypeScript source.

## Unique enemy identifier (e.g., "basic", "fast", "tank")
@export var enemy_id: String = ""

## Display name shown in UI (e.g., "Scrap Shambler")
@export var enemy_name: String = ""

## Hex color for visual representation (e.g., "#ff0000" for red)
@export var color: Color = Color.WHITE

## Visual size in pixels (width/height for square sprites)
@export var size: int = 20

## Base health points (scaled by wave)
@export var base_hp: int = 20

## Base movement speed in pixels per second (scaled by wave)
@export var base_speed: int = 30

## Base contact damage (scaled by wave)
@export var base_damage: int = 5

## Base scrap value dropped on death (scaled by wave)
@export var base_value: int = 5

## Spawn weight for weighted random selection (out of 100)
@export var spawn_weight: int = 60

## Item drop probability (0.0 to 1.0)
@export var drop_chance: float = 0.3


func _to_string() -> String:
	return "EnemyResource(%s: %s, hp=%d, speed=%d)" % [enemy_id, enemy_name, base_hp, base_speed]


## Calculate scaled stats for a given wave number
## Uses formulas from TypeScript source (enemies.ts:86-109):
## - HP: +25% per wave
## - Speed: +5% per wave
## - Damage: +10% per wave
## - Value: +20% per wave
func get_scaled_stats(wave: int) -> Dictionary:
	var hp_scale = 1.0 + (wave - 1) * 0.25
	var speed_scale = 1.0 + (wave - 1) * 0.05
	var damage_scale = 1.0 + (wave - 1) * 0.10
	var value_scale = 1.0 + (wave - 1) * 0.20

	return {
		"hp": int(base_hp * hp_scale),
		"speed": int(base_speed * speed_scale),
		"damage": int(base_damage * damage_scale),
		"value": int(base_value * value_scale)
	}


## Get spawn weight as percentage (for display purposes)
func get_spawn_percentage() -> float:
	return spawn_weight  # Assumes total weights sum to 100


## Check if this enemy type should drop an item (based on drop_chance)
func should_drop_item() -> bool:
	return randf() <= drop_chance
