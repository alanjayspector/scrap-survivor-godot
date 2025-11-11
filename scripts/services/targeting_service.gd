extends Node
## TargetingService - Enemy targeting and acquisition system
##
## Week 11 Phase 1: Auto-targeting for weapons
##
## Responsibilities:
## - Find nearest enemy within range for weapon targeting
## - Get all enemies in radius for area weapons
## - Filter by alive status and distance
##
## Based on: docs/migration/week11-implementation-plan.md (lines 54-65)

## Signals
signal target_acquired(enemy: Enemy, weapon_id: String)
signal target_lost(weapon_id: String)


## Initialize service
func _ready() -> void:
	GameLogger.info("TargetingService initialized")


## Get nearest living enemy within max_range
## Returns null if no valid enemy found
func get_nearest_enemy(position: Vector2, max_range: float) -> Enemy:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy: Enemy = null
	var nearest_distance: float = max_range + 1.0  # Start beyond max range

	for node in enemies:
		var enemy = node as Enemy
		if not enemy:
			continue

		# Skip dead enemies
		if not enemy.is_alive():
			continue

		# Calculate distance
		var distance = position.distance_to(enemy.global_position)

		# Check if within range and closer than current nearest
		if distance <= max_range and distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	return nearest_enemy


## Get all living enemies within radius
## Returns empty array if none found
func get_enemies_in_radius(position: Vector2, radius: float) -> Array[Enemy]:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemies_in_range: Array[Enemy] = []

	for node in enemies:
		var enemy = node as Enemy
		if not enemy:
			continue

		# Skip dead enemies
		if not enemy.is_alive():
			continue

		# Calculate distance
		var distance = position.distance_to(enemy.global_position)

		# Add if within radius
		if distance <= radius:
			enemies_in_range.append(enemy)

	return enemies_in_range


## Get all living enemies (no range filter)
func get_all_enemies() -> Array[Enemy]:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var living_enemies: Array[Enemy] = []

	for node in enemies:
		var enemy = node as Enemy
		if not enemy:
			continue

		# Skip dead enemies
		if not enemy.is_alive():
			continue

		living_enemies.append(enemy)

	return living_enemies


## Count living enemies
func get_enemy_count() -> int:
	return get_all_enemies().size()


## Check if any enemies exist within range
func has_enemies_in_range(position: Vector2, max_range: float) -> bool:
	return get_nearest_enemy(position, max_range) != null


## Reset service state (for testing)
func reset() -> void:
	# TargetingService is stateless - no state to reset
	# This method exists for service API consistency
	GameLogger.info("TargetingService reset (no state to clear)")


## Serialize service state to dictionary
func serialize() -> Dictionary:
	# TargetingService is stateless - no state to serialize
	return {}


## Restore service state from dictionary
func deserialize(_data: Dictionary) -> void:
	# TargetingService is stateless - no state to restore
	# _data parameter unused but required for service API consistency
	GameLogger.info("TargetingService deserialized (no state to restore)")
