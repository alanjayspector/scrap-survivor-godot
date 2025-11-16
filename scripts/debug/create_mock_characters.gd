extends Node
## Debug Helper: Create 15 Mock Characters for Performance Testing
## Week 15 Phase 3: Game Designer recommendation
##
## Usage from debug console or attach to a button:
## var helper = preload("res://scripts/debug/create_mock_characters.gd").new()
## helper.create_mock_characters(15)


func create_mock_characters(count: int = 15) -> void:
	"""Create mock characters for roster performance testing"""
	GameLogger.warning("[DEBUG] Creating %d mock characters for performance testing" % count)

	# Ensure Premium tier for 15 character slots
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	var character_types = ["scavenger", "tank", "commando", "mutant"]
	var names = [
		"Alex",
		"Blake",
		"Casey",
		"Dakota",
		"Echo",
		"Finley",
		"Grey",
		"Harper",
		"Indigo",
		"Jordan",
		"Kai",
		"Lane",
		"Morgan",
		"Nova",
		"Onyx"
	]

	for i in range(min(count, names.size())):
		var character_type = character_types[i % character_types.size()]
		var character_name = names[i]

		var character_id = CharacterService.create_character(character_name, character_type)

		if not character_id.is_empty():
			# Add some random progression
			var xp = randi() % 500
			CharacterService.add_xp(character_id, xp)

			# Set random highest wave
			var character = CharacterService.get_character(character_id)
			character["highest_wave"] = randi() % 20
			character["total_kills"] = randi() % 500
			CharacterService.update_character(character_id, character)

			GameLogger.info(
				"[DEBUG] Created mock character",
				{"name": character_name, "type": character_type, "id": character_id}
			)

	# Save
	SaveManager.save_all_services()

	GameLogger.warning("[DEBUG] Created %d mock characters - restart to see in roster" % count)
