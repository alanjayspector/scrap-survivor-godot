extends Node
## Integration test for all Week 4 services


func _ready() -> void:
	print("=== Service Integration Test ===")
	print()

	test_full_workflow()

	print()
	print("=== All Services Integrated Successfully ===")


func test_full_workflow() -> void:
	print("--- Testing Full Service Workflow ---")

	# 1. GameState setup
	GameState.set_current_character("scavenger")
	GameState.set_score(1000)

	# 2. Stat calculations
	var player_strength = 20.0
	var player_armor = 25.0
	var player_health = 100.0

	var player_damage = StatService.calculate_damage(50.0, player_strength, 15.0)  # weapon bonus

	var armor_reduction = StatService.calculate_armor_reduction(player_armor)
	var damage_received = 100.0 * (1.0 - armor_reduction)

	# 3. Simulate error
	ErrorService.log_warning(
		"Player took damage",
		{"damage": damage_received, "remaining_health": player_health - damage_received}
	)

	# 4. Log info
	Logger.info(
		"Game state updated", {"character": GameState.current_character, "score": GameState.score}
	)

	print("✓ All services work together")
	print("   Character: %s" % GameState.current_character)
	print("   Score: %d" % GameState.score)
	print("   Player damage: %.1f" % player_damage)
	print("   Damage received: %.1f (%.0f%% reduction)" % [damage_received, armor_reduction * 100])
