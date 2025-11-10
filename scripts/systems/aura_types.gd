extends Node
## Aura type definitions - describes aura behavior
## Full implementation Week 8, data structures Week 7

## Aura type definitions with scaling and visual properties
const AURA_TYPES = {
	"damage":
	{
		"display_name": "Damage Aura",
		"description": "Deals damage to nearby enemies",
		"effect": "deal_damage",
		"base_value": 5,
		"scaling_stat": "resonance",  # 5 + (resonance * 0.5)
		"radius_stat": "pickup_range",
		"cooldown": 1.0,  # Pulse once per second
		"color": Color(1, 0, 0, 0.3)  # Red, semi-transparent
	},
	"knockback":
	{
		"display_name": "Knockback Aura",
		"description": "Pushes enemies away from you",
		"effect": "push_enemies",
		"base_value": 50,  # Force amount
		"scaling_stat": "resonance",  # 50 + (resonance * 2)
		"radius_stat": "pickup_range",
		"cooldown": 0.5,
		"color": Color(1, 0.5, 0, 0.3)  # Orange
	},
	"heal":
	{
		"display_name": "Healing Aura",
		"description": "Heals nearby minions",
		"effect": "heal_minions",
		"base_value": 3,  # HP per pulse
		"scaling_stat": "resonance",  # 3 + (resonance * 0.3)
		"radius_stat": "pickup_range",
		"cooldown": 2.0,
		"color": Color(0, 1, 0, 0.3)  # Green
	},
	"collect":
	{
		"display_name": "Collection Aura",
		"description": "Auto-collects nearby currency and items",
		"effect": "auto_pickup",
		"base_value": 0,
		"scaling_stat": "resonance",  # Pickup speed = resonance * 10%
		"radius_stat": "pickup_range",
		"cooldown": 0.1,  # Check frequently
		"color": Color(1, 1, 0, 0.3)  # Yellow
	},
	"slow":
	{
		"display_name": "Slow Aura",
		"description": "Slows enemy movement speed",
		"effect": "slow_enemies",
		"base_value": 30,  # 30% slow
		"scaling_stat": "resonance",  # 30% + (resonance * 1%)
		"radius_stat": "pickup_range",
		"cooldown": 0.5,
		"color": Color(0, 0.5, 1, 0.3)  # Blue
	},
	"shield":
	{
		"display_name": "Shield Aura",
		"description": "Grants temporary armor while in radius",
		"effect": "grant_temp_armor",
		"base_value": 2,  # +2 armor bonus
		"scaling_stat": "resonance",  # 2 + (resonance * 0.2)
		"radius_stat": "pickup_range",
		"cooldown": 0.0,  # Always active
		"color": Color(0, 1, 1, 0.3)  # Cyan
	}
}


## Calculate aura power based on resonance
func calculate_aura_power(aura_type: String, resonance: int) -> float:
	if not AURA_TYPES.has(aura_type):
		return 0.0

	var aura_def = AURA_TYPES[aura_type]
	var base = aura_def.base_value
	var power = base

	# Different scaling per type
	match aura_type:
		"damage":
			power = base + (resonance * 0.5)
		"knockback":
			power = base + (resonance * 2.0)
		"heal":
			power = base + (resonance * 0.3)
		"collect":
			power = resonance * 0.10  # 10% speed per point
		"slow":
			power = base + (resonance * 1.0)
		"shield":
			power = base + (resonance * 0.2)

	return power


## Calculate aura radius based on pickup_range
func calculate_aura_radius(pickup_range: int) -> float:
	# Aura radius = pickup_range * 1.0 (same as pickup range)
	return float(pickup_range)
