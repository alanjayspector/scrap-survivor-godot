extends Node
## WeaponService - Weapon management with attack speed integration
##
## Week 9 Phase 1: Weapon system with melee/ranged types
##
## Responsibilities:
## - Weapon definitions (stats, types, tier requirements)
## - Weapon equipping with tier validation
## - Damage calculation with character stat bonuses
## - Cooldown calculation with attack speed integration
## - Weapon firing logic
##
## Based on: docs/migration/week9-implementation-plan.md (lines 66-134)

## User tier levels (matches CharacterService)
enum UserTier { FREE, PREMIUM, SUBSCRIPTION }

## Weapon types
enum WeaponType { MELEE, RANGED }

## Weapon definitions
const WEAPON_DEFINITIONS = {
	"rusty_blade":
	{
		"display_name": "Rusty Blade",
		"type": WeaponType.MELEE,
		"base_damage": 15,
		"cooldown": 0.5,  # 2 attacks per second
		"range": 50,  # Melee range (pixels)
		"projectile": null,
		"tier_required": UserTier.FREE
	},
	"plasma_pistol":
	{
		"display_name": "Plasma Pistol",
		"type": WeaponType.RANGED,
		"base_damage": 10,
		"cooldown": 0.8,  # 1.25 attacks per second
		"range": 300,  # Projectile range
		"projectile": "plasma_bolt",
		"projectile_speed": 400,
		"tier_required": UserTier.FREE
	},
	"steel_sword":
	{
		"display_name": "Steel Sword",
		"type": WeaponType.MELEE,
		"base_damage": 25,
		"cooldown": 0.6,
		"range": 60,
		"projectile": null,
		"tier_required": UserTier.PREMIUM
	},
	"shock_rifle":
	{
		"display_name": "Shock Rifle",
		"type": WeaponType.RANGED,
		"base_damage": 20,
		"cooldown": 1.0,
		"range": 400,
		"projectile": "shock_bolt",
		"projectile_speed": 500,
		"tier_required": UserTier.PREMIUM
	}
}

## Internal state
var current_tier: UserTier = UserTier.FREE
var equipped_weapons: Dictionary = {}  # character_id -> weapon_id
var weapon_cooldowns: Dictionary = {}  # weapon_instance_id -> time_remaining

## Signals
signal weapon_equipped(character_id: String, weapon_id: String)
signal weapon_fired(weapon_id: String, position: Vector2, direction: Vector2)
signal weapon_cooldown_ready(weapon_id: String)


## Initialize service
func _ready() -> void:
	GameLogger.info("WeaponService initialized", {"weapon_count": WEAPON_DEFINITIONS.size()})


## Update cooldowns each frame
func _process(delta: float) -> void:
	for weapon_instance_id in weapon_cooldowns.keys():
		weapon_cooldowns[weapon_instance_id] -= delta
		if weapon_cooldowns[weapon_instance_id] <= 0.0:
			weapon_cooldowns.erase(weapon_instance_id)
			weapon_cooldown_ready.emit(weapon_instance_id)


## Set user tier (for tier-based weapon restrictions)
func set_tier(tier: UserTier) -> void:
	current_tier = tier
	GameLogger.info("WeaponService tier updated", {"tier": tier})


## Get current user tier
func get_tier() -> UserTier:
	return current_tier


## Check if weapon exists
func weapon_exists(weapon_id: String) -> bool:
	return WEAPON_DEFINITIONS.has(weapon_id)


## Get weapon definition
func get_weapon(weapon_id: String) -> Dictionary:
	if not weapon_exists(weapon_id):
		GameLogger.warning("Weapon does not exist", {"weapon_id": weapon_id})
		return {}
	return WEAPON_DEFINITIONS[weapon_id]


## Equip weapon to character
func equip_weapon(character_id: String, weapon_id: String) -> bool:
	if character_id.is_empty():
		GameLogger.warning("Cannot equip weapon: character_id is empty")
		return false

	if not weapon_exists(weapon_id):
		GameLogger.warning("Cannot equip weapon: weapon does not exist", {"weapon_id": weapon_id})
		return false

	var weapon_def = WEAPON_DEFINITIONS[weapon_id]

	# Check tier requirement
	if weapon_def.tier_required > current_tier:
		GameLogger.warning(
			"Cannot equip weapon: tier requirement not met",
			{"required_tier": weapon_def.tier_required, "current_tier": current_tier}
		)
		return false

	# Equip weapon
	equipped_weapons[character_id] = weapon_id
	weapon_equipped.emit(character_id, weapon_id)

	GameLogger.info(
		"Weapon equipped",
		{"character_id": character_id, "weapon_id": weapon_id, "weapon": weapon_def.display_name}
	)

	return true


## Get equipped weapon for character
func get_equipped_weapon(character_id: String) -> String:
	return equipped_weapons.get(character_id, "")


## Unequip weapon from character
func unequip_weapon(character_id: String) -> void:
	if equipped_weapons.has(character_id):
		var weapon_id = equipped_weapons[character_id]
		equipped_weapons.erase(character_id)
		GameLogger.info("Weapon unequipped", {"character_id": character_id, "weapon_id": weapon_id})


## Calculate weapon damage with character stat bonuses
func get_weapon_damage(weapon_id: String, character_stats: Dictionary) -> float:
	if not weapon_exists(weapon_id):
		GameLogger.warning(
			"Cannot calculate damage: weapon does not exist", {"weapon_id": weapon_id}
		)
		return 0.0

	var weapon_def = WEAPON_DEFINITIONS[weapon_id]
	var base_damage = weapon_def.base_damage
	var character_damage = character_stats.get("damage", 0)

	# Apply weapon type bonus
	var bonus_damage = 0.0
	if weapon_def.type == WeaponType.MELEE:
		bonus_damage = character_stats.get("melee_damage", 0)
	elif weapon_def.type == WeaponType.RANGED:
		bonus_damage = character_stats.get("ranged_damage", 0)

	# Total damage = base weapon + character damage + type bonus
	var total_damage = base_damage + character_damage + bonus_damage

	return total_damage


## Calculate weapon cooldown with attack speed integration
## attack_speed stat reduces cooldown (e.g., 15 attack_speed = 15% cooldown reduction)
## Caps at 75% reduction to prevent instant attacks
func get_weapon_cooldown(weapon_id: String, attack_speed: float) -> float:
	if not weapon_exists(weapon_id):
		GameLogger.warning(
			"Cannot calculate cooldown: weapon does not exist", {"weapon_id": weapon_id}
		)
		return 1.0

	var weapon_def = WEAPON_DEFINITIONS[weapon_id]
	var base_cooldown = weapon_def.cooldown

	# Convert attack_speed to percentage (e.g., 15 -> 0.15)
	# Cap reduction at 75% (0.75)
	var reduction = clamp(attack_speed / 100.0, 0.0, 0.75)

	# Apply reduction
	var actual_cooldown = base_cooldown * (1.0 - reduction)

	return actual_cooldown


## Check if weapon can fire (cooldown ready)
func can_fire_weapon(weapon_instance_id: String) -> bool:
	return not weapon_cooldowns.has(weapon_instance_id)


## Fire weapon (starts cooldown)
func fire_weapon(
	weapon_id: String, weapon_instance_id: String, position: Vector2, direction: Vector2
) -> bool:
	if not weapon_exists(weapon_id):
		GameLogger.warning("Cannot fire weapon: weapon does not exist", {"weapon_id": weapon_id})
		return false

	if not can_fire_weapon(weapon_instance_id):
		# Weapon on cooldown
		return false

	# Start cooldown (use base cooldown, actual character attack speed handled elsewhere)
	var weapon_def = WEAPON_DEFINITIONS[weapon_id]
	weapon_cooldowns[weapon_instance_id] = weapon_def.cooldown

	# Emit signal
	weapon_fired.emit(weapon_id, position, direction)

	GameLogger.info(
		"Weapon fired",
		{
			"weapon_id": weapon_id,
			"position": position,
			"direction": direction,
			"cooldown": weapon_def.cooldown
		}
	)

	return true


## Get remaining cooldown time
func get_cooldown_remaining(weapon_instance_id: String) -> float:
	return weapon_cooldowns.get(weapon_instance_id, 0.0)


## Reset all cooldowns (useful for testing)
func reset_cooldowns() -> void:
	weapon_cooldowns.clear()
	GameLogger.info("All weapon cooldowns reset")


## Get all available weapons for tier
func get_available_weapons(tier: UserTier) -> Array:
	var available = []
	for weapon_id in WEAPON_DEFINITIONS.keys():
		var weapon_def = WEAPON_DEFINITIONS[weapon_id]
		if weapon_def.tier_required <= tier:
			available.append(weapon_id)
	return available


## Reset service state (for testing)
func reset() -> void:
	equipped_weapons.clear()
	weapon_cooldowns.clear()
	current_tier = UserTier.FREE
	GameLogger.info("WeaponService reset")


## Serialize service state to dictionary
func serialize() -> Dictionary:
	return {
		"current_tier": current_tier,
		"equipped_weapons": equipped_weapons,
		"weapon_cooldowns": weapon_cooldowns
	}


## Restore service state from dictionary
func deserialize(data: Dictionary) -> void:
	if data.has("current_tier"):
		current_tier = data.current_tier
	if data.has("equipped_weapons"):
		equipped_weapons = data.equipped_weapons
	if data.has("weapon_cooldowns"):
		weapon_cooldowns = data.weapon_cooldowns
	GameLogger.info("WeaponService deserialized")
