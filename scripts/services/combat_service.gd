extends Node
## CombatService - Combat damage calculation and application
##
## Week 9 Phase 3: Combat integration with stat modifiers
##
## Responsibilities:
## - Calculate weapon damage with character stat bonuses
## - Apply damage to enemies with death handling
## - Calculate aura damage with resonance scaling
## - Apply aura damage to nearby enemies
## - Integrate CharacterService, WeaponService, and EnemyService
##
## Based on: docs/migration/week9-implementation-plan.md (lines 206-294)

## Signals
signal damage_dealt(enemy_id: String, damage: float, killed: bool)
signal aura_damage_dealt(enemy_ids: Array, damage: float)


## Initialize service
func _ready() -> void:
	GameLogger.info("CombatService initialized")


## Calculate weapon damage with character stat bonuses
## Combines weapon base damage + character damage + type-specific bonus
func calculate_damage(weapon_id: String, character_stats: Dictionary) -> float:
	# Use WeaponService to calculate damage with bonuses
	return WeaponService.get_weapon_damage(weapon_id, character_stats)


## Apply damage to enemy
## Returns { "killed": bool, "remaining_hp": float, "drops": Dictionary }
func apply_damage_to_enemy(enemy_id: String, damage: float) -> Dictionary:
	# Check if enemy exists
	var enemy = EnemyService.get_enemy(enemy_id)
	if enemy.is_empty():
		GameLogger.warning("Cannot apply damage: enemy does not exist", {"enemy_id": enemy_id})
		return {"killed": false, "remaining_hp": 0.0}

	# Damage the enemy
	var killed = EnemyService.damage_enemy(enemy_id, damage)

	# Emit signal
	damage_dealt.emit(enemy_id, damage, killed)

	# If killed, get drops
	if killed:
		var drop_data = EnemyService.kill_enemy(enemy_id)
		return {"killed": true, "drops": drop_data}

	# Still alive
	var updated_enemy = EnemyService.get_enemy(enemy_id)
	return {"killed": false, "remaining_hp": updated_enemy.current_hp}


## Calculate aura damage based on resonance stat
func calculate_aura_damage(character_stats: Dictionary) -> float:
	var resonance = character_stats.get("resonance", 0)
	return AuraTypes.calculate_aura_power("damage", resonance)


## Apply aura damage to all enemies within radius
## Returns array of { "enemy_id": String, "result": Dictionary }
func apply_aura_damage_to_nearby_enemies(
	character_pos: Vector2, aura_radius: float, damage: float
) -> Array:
	# Find enemies within aura radius
	var enemies_in_range = EnemyService.get_enemies_in_radius(character_pos, aura_radius)

	if enemies_in_range.is_empty():
		return []

	var damaged_enemies = []

	# Apply damage to each enemy
	for enemy_id in enemies_in_range:
		var result = apply_damage_to_enemy(enemy_id, damage)
		damaged_enemies.append({"enemy_id": enemy_id, "result": result})

	# Emit signal
	aura_damage_dealt.emit(enemies_in_range, damage)

	GameLogger.info(
		"Aura damage applied",
		{"enemies_hit": enemies_in_range.size(), "damage": damage, "radius": aura_radius}
	)

	return damaged_enemies


## Calculate total damage for weapon attack (used by UI/feedback systems)
func get_weapon_attack_damage(weapon_id: String, character_id: String) -> float:
	# Get character stats
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.warning(
			"Cannot calculate weapon damage: character not found", {"character_id": character_id}
		)
		return 0.0

	# Calculate damage
	return calculate_damage(weapon_id, character.stats)


## Apply weapon attack to enemy
func apply_weapon_attack(weapon_id: String, character_id: String, enemy_id: String) -> Dictionary:
	# Get damage
	var damage = get_weapon_attack_damage(weapon_id, character_id)

	if damage <= 0.0:
		return {"killed": false, "damage": 0.0}

	# Apply damage
	var result = apply_damage_to_enemy(enemy_id, damage)
	result["damage"] = damage

	return result


## Apply aura damage tick (called each frame for damage auras)
func apply_aura_damage_tick(character_id: String, delta: float) -> Array:
	# Get character data
	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		return []

	# Check if character has damage aura
	if character.aura.type != "damage":
		return []

	# Calculate aura damage (damage per second)
	var damage_per_second = calculate_aura_damage(character.stats)
	var damage_this_tick = damage_per_second * delta

	# Calculate aura radius
	var aura_radius = AuraTypes.calculate_aura_radius(character.stats.pickup_range)

	# Get character position (would come from game scene in actual use)
	# For testing, we'll use EnemyService.player_position if available
	var character_pos = Vector2.ZERO

	# Apply aura damage
	return apply_aura_damage_to_nearby_enemies(character_pos, aura_radius, damage_this_tick)


## Reset service state (for testing)
func reset() -> void:
	# CombatService is stateless - nothing to reset
	pass


## Serialize service state to dictionary
func serialize() -> Dictionary:
	# CombatService is stateless - return empty dict
	return {}


## Restore service state from dictionary
func deserialize(_data: Dictionary) -> void:
	# CombatService is stateless - nothing to restore
	pass
