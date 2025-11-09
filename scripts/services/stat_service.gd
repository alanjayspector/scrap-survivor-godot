class_name StatService
## Ported from TypeScript packages/core/src/services/statService.ts
## Handles all stat calculations and modifications


## Damage calculation formula: base + (strength * 0.5) + weapon_bonus
static func calculate_damage(base: float, strength: float, weapon_bonus: float = 0.0) -> float:
	return base + (strength * 0.5) + weapon_bonus


## Health calculation: base + (vitality * 2)
static func calculate_health(base: float, vitality: float) -> float:
	return base + (vitality * 2.0)


## Speed calculation: base + (agility * 0.25)
static func calculate_speed(base: float, agility: float) -> float:
	return base + (agility * 0.25)


## Applies stat modifiers safely with clamping
static func apply_stat_modifiers(base_stats: Dictionary, modifiers: Dictionary) -> Dictionary:
	var result = base_stats.duplicate()

	for stat in modifiers:
		if result.has(stat):
			result[stat] += modifiers[stat]

			# Clamp negative stats to 0 (except special cases like cooldown reduction)
			if not stat.begins_with("cooldown"):
				result[stat] = max(0, result[stat])

	return result


## Calculates armor damage reduction (2% per point, caps at 80%)
static func calculate_armor_reduction(armor: float) -> float:
	var reduction = armor * 0.02
	return clamp(reduction, 0.0, 0.8)


## Calculates dodge chance (1% per 10 agility, caps at 50%)
static func calculate_dodge_chance(agility: float) -> float:
	var chance = agility * 0.001
	return clamp(chance, 0.0, 0.5)


## Calculates critical chance (1% per 5 luck, caps at 30%)
static func calculate_crit_chance(luck: float) -> float:
	var chance = luck * 0.002
	return clamp(chance, 0.0, 0.3)


## Calculates life steal amount (converts percentage)
static func calculate_life_steal(amount: float, damage: float) -> float:
	return damage * (amount / 100.0)


## Reset service state (for testing)
func reset() -> void:
	# StatService is stateless (pure calculations), no reset needed
	pass


## Serialize service state to dictionary (Week 6)
func serialize() -> Dictionary:
	return {
		"version": 1,
		"note": "StatService is stateless (pure calculations)",
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state from dictionary (Week 6)
func deserialize(_data: Dictionary) -> void:
	# StatService is stateless, nothing to restore
	pass
