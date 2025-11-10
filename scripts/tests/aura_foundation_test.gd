extends GutTest
## Test script for Aura System Foundation using GUT framework
##
## USER STORY: "As a player, I want each character type to have a unique aura
## that provides passive gameplay benefits, so that I can experience different
## playstyles with visual feedback"
##
## Week 7 Phase 3: Tests aura data structures, calculations, and persistence

class_name AuraFoundationTest

# Preload AuraVisual to avoid duplicate loads
const AuraVisual = preload("res://scripts/components/aura_visual.gd")


func before_each() -> void:
	# Reset service state before each test
	CharacterService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Aura Data Storage Tests
## User Story: "As a player, I want my character's aura data to be saved"
## ============================================================================


func test_aura_data_stored_in_character() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("TestChar", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_true(character.has("aura"), "Character should have aura data")
	assert_true(character.aura.has("type"), "Aura should have type field")
	assert_true(character.aura.has("enabled"), "Aura should have enabled field")
	assert_true(character.aura.has("level"), "Aura should have level field")


func test_aura_type_matches_character_type() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var scavenger_id = CharacterService.create_character("Scav", "scavenger")
	var scavenger = CharacterService.get_character(scavenger_id)

	# Assert
	assert_eq(scavenger.aura.type, "collect", "Scavenger should have collect aura")


func test_scavenger_has_collect_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var character_id = CharacterService.create_character("Scavenger", "scavenger")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, "collect", "Scavenger should have collect aura type")
	assert_true(character.aura.enabled, "Aura should be enabled by default")
	assert_eq(character.aura.level, 1, "Aura should start at level 1")


func test_tank_has_shield_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var character_id = CharacterService.create_character("Tank", "tank")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_eq(character.aura.type, "shield", "Tank should have shield aura type")
	assert_true(character.aura.enabled, "Aura should be enabled by default")


func test_commando_has_no_aura() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)

	# Act
	var character_id = CharacterService.create_character("Commando", "commando")
	var character = CharacterService.get_character(character_id)

	# Assert
	assert_null(character.aura.type, "Commando should have null aura type")


## ============================================================================
## SECTION 2: Aura Calculation Tests
## User Story: "As a player, I want resonance stat to increase my aura power"
## ============================================================================


func test_calculate_aura_power_with_resonance() -> void:
	# Act & Assert - Damage aura: base 5 + (resonance * 0.5)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", 0), 5.0, 0.01, "Damage with 0 resonance"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", 10),
		10.0,
		0.01,
		"Damage with 10 resonance (5 + 10*0.5)"
	)

	# Shield aura: base 2 + (resonance * 0.2)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", 0), 2.0, 0.01, "Shield with 0 resonance"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", 10),
		4.0,
		0.01,
		"Shield with 10 resonance (2 + 10*0.2)"
	)


func test_calculate_aura_power_for_all_types() -> void:
	# Arrange
	var resonance = 20

	# Act & Assert - Test all aura types
	assert_almost_eq(
		AuraTypes.calculate_aura_power("damage", resonance), 15.0, 0.01, "Damage: 5 + 20*0.5"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("knockback", resonance), 90.0, 0.01, "Knockback: 50 + 20*2.0"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("heal", resonance), 9.0, 0.01, "Heal: 3 + 20*0.3"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("collect", resonance), 2.0, 0.01, "Collect: 20*0.10"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("slow", resonance), 50.0, 0.01, "Slow: 30 + 20*1.0"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_power("shield", resonance), 6.0, 0.01, "Shield: 2 + 20*0.2"
	)


func test_calculate_aura_radius_from_pickup_range() -> void:
	# Act & Assert
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(100), 100.0, 0.01, "Radius matches pickup_range"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(150), 150.0, 0.01, "Radius scales with pickup_range"
	)
	assert_almost_eq(
		AuraTypes.calculate_aura_radius(200), 200.0, 0.01, "Radius = pickup_range * 1.0"
	)


func test_invalid_aura_type_returns_zero() -> void:
	# Act
	var power = AuraTypes.calculate_aura_power("invalid_type", 10)

	# Assert
	assert_eq(power, 0.0, "Invalid aura type should return 0 power")


## ============================================================================
## SECTION 3: Aura Persistence Tests
## User Story: "As a player, I want my character's aura to persist after save/load"
## ============================================================================


func test_aura_persists_after_save_load() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	var character_id = CharacterService.create_character("PersistTest", "tank")

	# Verify aura before save
	var character_before = CharacterService.get_character(character_id)
	assert_eq(character_before.aura.type, "shield", "Tank should have shield aura")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert - Verify aura after load
	var character_after = CharacterService.get_character(character_id)
	assert_eq(character_after.aura.type, "shield", "Aura type should persist after save/load")
	assert_true(character_after.aura.enabled, "Aura enabled state should persist")
	assert_eq(character_after.aura.level, 1, "Aura level should persist")


func test_multiple_characters_with_different_auras_persist() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	var scav_id = CharacterService.create_character("Scavenger", "scavenger")
	var tank_id = CharacterService.create_character("Tank", "tank")
	var cmd_id = CharacterService.create_character("Commando", "commando")

	# Act - Serialize and deserialize
	var saved_data = CharacterService.serialize()
	CharacterService.reset()
	CharacterService.deserialize(saved_data)

	# Assert - All aura types should persist correctly
	var scav = CharacterService.get_character(scav_id)
	var tank = CharacterService.get_character(tank_id)
	var cmd = CharacterService.get_character(cmd_id)

	assert_eq(scav.aura.type, "collect", "Scavenger aura should persist")
	assert_eq(tank.aura.type, "shield", "Tank aura should persist")
	assert_null(cmd.aura.type, "Commando null aura should persist")


## ============================================================================
## SECTION 4: Aura Type Definitions Tests
## User Story: "As a developer, I want all aura types to have proper definitions"
## ============================================================================


func test_all_aura_types_have_required_fields() -> void:
	# Arrange
	var required_fields = [
		"display_name",
		"description",
		"effect",
		"base_value",
		"scaling_stat",
		"radius_stat",
		"cooldown",
		"color"
	]

	# Act & Assert - Check each aura type
	for aura_key in AuraTypes.AURA_TYPES.keys():
		var aura_def = AuraTypes.AURA_TYPES[aura_key]

		for field in required_fields:
			assert_true(
				aura_def.has(field), "Aura type '%s' should have field '%s'" % [aura_key, field]
			)


## ============================================================================
## SECTION 5: Aura Visual Component Tests (Week 8 Phase 2)
## User Story: "As a player, I want to see particle effects for my character's aura"
## ============================================================================


func test_aura_visual_can_be_instantiated() -> void:
	# Arrange & Act
	var aura_visual = autofree(AuraVisual.new())

	# Assert
	assert_not_null(aura_visual, "AuraVisual should instantiate successfully")
	assert_eq(aura_visual.aura_type, "collect", "Should have default aura type")
	assert_eq(aura_visual.radius, 100.0, "Should have default radius")


func test_aura_visual_creates_child_nodes() -> void:
	# Arrange
	var aura_visual = AuraVisual.new()
	add_child_autofree(aura_visual)

	# Wait for _ready() to be called
	await wait_physics_frames(2)

	# Assert - Should have Line2D (ring) and GPUParticles2D
	var has_line2d = false
	var has_particles = false

	for child in aura_visual.get_children():
		if child is Line2D:
			has_line2d = true
		if child is GPUParticles2D:
			has_particles = true

	assert_true(has_line2d, "AuraVisual should create Line2D for ring visual")
	assert_true(has_particles, "AuraVisual should create GPUParticles2D for particle system")


func test_aura_visual_update_changes_parameters() -> void:
	# Arrange
	var aura_visual = AuraVisual.new()
	add_child_autofree(aura_visual)
	await wait_physics_frames(2)

	# Act - Update to damage aura with larger radius
	aura_visual.update_aura("damage", 150.0)
	await wait_physics_frames(2)

	# Assert
	assert_eq(aura_visual.aura_type, "damage", "Aura type should update")
	assert_eq(aura_visual.radius, 150.0, "Radius should update")
	assert_eq(
		aura_visual.color, AuraTypes.AURA_TYPES["damage"].color, "Color should match damage aura"
	)


func test_aura_visual_set_emitting() -> void:
	# Arrange
	var aura_visual = AuraVisual.new()
	add_child_autofree(aura_visual)
	await wait_physics_frames(2)

	# Act - Disable particles
	aura_visual.set_emitting(false)

	# Assert - Find GPUParticles2D and check emitting state
	var particles: GPUParticles2D = null
	for child in aura_visual.get_children():
		if child is GPUParticles2D:
			particles = child
			break

	assert_not_null(particles, "Should have GPUParticles2D child")
	assert_false(particles.emitting, "Particles should stop emitting")

	# Act - Re-enable particles
	aura_visual.set_emitting(true)

	# Assert
	assert_true(particles.emitting, "Particles should resume emitting")


func test_aura_visual_colors_match_aura_types() -> void:
	# Arrange
	var test_types = ["damage", "heal", "collect", "shield", "slow", "knockback"]

	# Act & Assert - Test each aura type
	for aura_type in test_types:
		var aura_visual = AuraVisual.new()
		add_child_autofree(aura_visual)
		await wait_physics_frames(1)

		aura_visual.update_aura(aura_type, 100.0)
		await wait_physics_frames(1)

		var expected_color = AuraTypes.AURA_TYPES[aura_type].color
		assert_eq(
			aura_visual.color,
			expected_color,
			"Aura visual color should match %s aura type" % aura_type
		)


func test_aura_visual_ring_has_correct_point_count() -> void:
	# Arrange
	var aura_visual = AuraVisual.new()
	add_child_autofree(aura_visual)
	await wait_physics_frames(2)

	# Act - Find the Line2D ring
	var ring: Line2D = null
	for child in aura_visual.get_children():
		if child is Line2D:
			ring = child
			break

	# Assert
	assert_not_null(ring, "Should have Line2D ring visual")
	assert_eq(ring.points.size(), 65, "Ring should have 65 points (64 segments + 1 to close)")


func test_mutant_has_damage_aura_visual() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	var mutant_id = CharacterService.create_character("MutantVisual", "mutant")
	var mutant = CharacterService.get_character(mutant_id)

	# Assert - Mutant should have damage aura
	assert_eq(mutant.aura.type, "damage", "Mutant should have damage aura")

	# Create visual for mutant aura
	var aura_visual = AuraVisual.new()
	add_child_autofree(aura_visual)

	# Calculate aura parameters from mutant stats
	var aura_power = AuraTypes.calculate_aura_power(mutant.aura.type, mutant.stats.resonance)
	var aura_radius = AuraTypes.calculate_aura_radius(mutant.stats.pickup_range)

	aura_visual.update_aura(mutant.aura.type, aura_radius)
	await wait_physics_frames(2)

	# Assert - Visual should be configured for damage aura
	assert_eq(aura_visual.aura_type, "damage", "Visual should show damage aura")
	assert_eq(
		aura_visual.color, AuraTypes.AURA_TYPES["damage"].color, "Should use damage aura color"
	)
	# Mutant has +10 resonance and +20 pickup_range, so radius should be 120
	assert_eq(aura_visual.radius, 120.0, "Mutant aura radius should be 120 (100 + 20)")
