extends GutTest
## Test script for CharacterTypeDatabase and CharacterService character type integration
##
## USER STORY: "As a player, I want to choose from different character types
## with unique abilities, so that I can customize my playstyle"
##
## Tests character type definitions, slot limits, stat modifiers, and tier gating.

class_name CharacterTypeTest


func before_each() -> void:
	# Reset CharacterService state before each test
	CharacterService.reset()


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: CharacterTypeDatabase - Definition Count and Structure
## User Story: "As a developer, I want 6 character types defined"
## ============================================================================


func test_character_type_count_is_six() -> void:
	# Arrange & Act
	var count = CharacterTypeDatabase.get_type_count()

	# Assert
	assert_eq(count, 6, "Should have exactly 6 character types")


func test_all_six_types_exist() -> void:
	# Arrange - expected type IDs from spec
	var expected_types = [
		"scavenger", "rustbucket", "hotshot", "tinkerer", "salvager", "overclocked"
	]

	# Act & Assert
	for type_id in expected_types:
		assert_true(CharacterTypeDatabase.has_type(type_id), "Type '%s' should exist" % type_id)


func test_get_all_types_returns_dictionary() -> void:
	# Arrange & Act
	var all_types = CharacterTypeDatabase.get_all_types()

	# Assert
	assert_eq(all_types.size(), 6, "Should return 6 types")
	assert_true(all_types.has("scavenger"), "Should contain scavenger")
	assert_true(all_types.has("overclocked"), "Should contain overclocked")


func test_type_definitions_have_required_fields() -> void:
	# Arrange & Act
	var validation = CharacterTypeDatabase.validate_definitions()

	# Assert
	assert_true(
		validation.valid, "All type definitions should be valid: %s" % str(validation.errors)
	)


## ============================================================================
## SECTION 2: CharacterTypeDatabase - Tier Gating
## User Story: "As a FREE player, I want 3 character types unlocked"
## ============================================================================


func test_free_tier_has_three_types() -> void:
	# Arrange & Act
	var free_types = CharacterTypeDatabase.get_free_types()

	# Assert
	assert_eq(free_types.size(), 3, "FREE tier should have 3 character types")


func test_premium_tier_has_two_types() -> void:
	# Arrange & Act
	var premium_types = CharacterTypeDatabase.get_premium_types()

	# Assert
	assert_eq(premium_types.size(), 2, "PREMIUM tier should have 2 character types")


func test_subscription_tier_has_one_type() -> void:
	# Arrange & Act
	var sub_types = CharacterTypeDatabase.get_subscription_types()

	# Assert
	assert_eq(sub_types.size(), 1, "SUBSCRIPTION tier should have 1 character type")


func test_scavenger_is_free_tier() -> void:
	# Arrange & Act
	var tier = CharacterTypeDatabase.get_tier_required("scavenger")

	# Assert
	assert_eq(tier, CharacterTypeDatabase.Tier.FREE, "Scavenger should be FREE tier")


func test_tinkerer_is_premium_tier() -> void:
	# Arrange & Act
	var tier = CharacterTypeDatabase.get_tier_required("tinkerer")

	# Assert
	assert_eq(tier, CharacterTypeDatabase.Tier.PREMIUM, "Tinkerer should be PREMIUM tier")


func test_overclocked_is_subscription_tier() -> void:
	# Arrange & Act
	var tier = CharacterTypeDatabase.get_tier_required("overclocked")

	# Assert
	assert_eq(
		tier, CharacterTypeDatabase.Tier.SUBSCRIPTION, "Overclocked should be SUBSCRIPTION tier"
	)


func test_free_user_can_access_scavenger() -> void:
	# Arrange & Act
	var can_access = CharacterTypeDatabase.can_access_type(
		"scavenger", CharacterTypeDatabase.Tier.FREE
	)

	# Assert
	assert_true(can_access, "FREE user should access scavenger")


func test_free_user_cannot_access_tinkerer() -> void:
	# Arrange & Act
	var can_access = CharacterTypeDatabase.can_access_type(
		"tinkerer", CharacterTypeDatabase.Tier.FREE
	)

	# Assert
	assert_false(can_access, "FREE user should NOT access tinkerer")


func test_premium_user_can_access_all_except_subscription() -> void:
	# Arrange & Act
	var can_access_scavenger = CharacterTypeDatabase.can_access_type(
		"scavenger", CharacterTypeDatabase.Tier.PREMIUM
	)
	var can_access_tinkerer = CharacterTypeDatabase.can_access_type(
		"tinkerer", CharacterTypeDatabase.Tier.PREMIUM
	)
	var can_access_overclocked = CharacterTypeDatabase.can_access_type(
		"overclocked", CharacterTypeDatabase.Tier.PREMIUM
	)

	# Assert
	assert_true(can_access_scavenger, "PREMIUM should access FREE types")
	assert_true(can_access_tinkerer, "PREMIUM should access PREMIUM types")
	assert_false(can_access_overclocked, "PREMIUM should NOT access SUBSCRIPTION types")


## ============================================================================
## SECTION 3: CharacterTypeDatabase - Weapon Slots
## User Story: "As a player, I want different weapon slots per type"
## ============================================================================


func test_scavenger_has_six_weapon_slots() -> void:
	# Arrange & Act
	var slots = CharacterTypeDatabase.get_weapon_slots("scavenger")

	# Assert
	assert_eq(slots, 6, "Scavenger should have 6 weapon slots")


func test_rustbucket_has_four_weapon_slots() -> void:
	# Arrange & Act
	var slots = CharacterTypeDatabase.get_weapon_slots("rustbucket")

	# Assert
	assert_eq(slots, 4, "Rustbucket should have 4 weapon slots (tank tradeoff)")


func test_salvager_has_five_weapon_slots() -> void:
	# Arrange & Act
	var slots = CharacterTypeDatabase.get_weapon_slots("salvager")

	# Assert
	assert_eq(slots, 5, "Salvager should have 5 weapon slots (resource tradeoff)")


func test_hotshot_has_six_weapon_slots() -> void:
	# Arrange & Act
	var slots = CharacterTypeDatabase.get_weapon_slots("hotshot")

	# Assert
	assert_eq(slots, 6, "Hotshot should have 6 weapon slots")


## ============================================================================
## SECTION 4: CharacterTypeDatabase - Inventory Slots
## User Story: "As a player, I want 30 inventory slots regardless of type"
## ============================================================================


func test_all_types_have_thirty_inventory_slots() -> void:
	# Arrange
	var type_ids = CharacterTypeDatabase.get_type_ids()

	# Act & Assert
	for type_id in type_ids:
		var slots = CharacterTypeDatabase.get_inventory_slots(type_id)
		assert_eq(slots, 30, "Type '%s' should have 30 inventory slots" % type_id)


func test_default_inventory_slots_constant() -> void:
	# Arrange & Act
	var default_slots = CharacterTypeDatabase.DEFAULT_INVENTORY_SLOTS

	# Assert
	assert_eq(default_slots, 30, "Default inventory slots should be 30")


## ============================================================================
## SECTION 5: CharacterTypeDatabase - Stat Modifiers
## User Story: "As a player, I want type bonuses applied to my character"
## ============================================================================


func test_scavenger_has_scavenging_bonus() -> void:
	# Arrange & Act
	var modifiers = CharacterTypeDatabase.get_stat_modifiers("scavenger")

	# Assert
	assert_true(modifiers.has("scavenging"), "Scavenger should have scavenging modifier")
	assert_eq(modifiers.scavenging, 10, "Scavenger should have +10 scavenging")


func test_rustbucket_has_tank_stats() -> void:
	# Arrange & Act
	var modifiers = CharacterTypeDatabase.get_stat_modifiers("rustbucket")

	# Assert
	assert_eq(modifiers.get("max_hp", 0), 30, "Rustbucket should have +30 max_hp")
	assert_eq(modifiers.get("armor", 0), 5, "Rustbucket should have +5 armor")


func test_hotshot_has_damage_tradeoff() -> void:
	# Arrange & Act
	var modifiers = CharacterTypeDatabase.get_stat_modifiers("hotshot")

	# Assert
	assert_eq(modifiers.get("crit_chance", 0), 0.10, "Hotshot should have +10% crit_chance")
	assert_eq(modifiers.get("max_hp", 0), -20, "Hotshot should have -20 max_hp penalty")


func test_overclocked_has_attack_speed_bonus() -> void:
	# Arrange & Act
	var modifiers = CharacterTypeDatabase.get_stat_modifiers("overclocked")

	# Assert
	assert_eq(modifiers.get("attack_speed", 0), 25.0, "Overclocked should have +25% attack_speed")


## ============================================================================
## SECTION 6: CharacterTypeDatabase - Special Mechanics
## User Story: "As a player, I want unique type abilities"
## ============================================================================


func test_scavenger_has_scrap_drop_bonus() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("scavenger")

	# Assert
	assert_eq(
		mechanics.get("scrap_drop_bonus", 0), 0.10, "Scavenger should have +10% scrap drop bonus"
	)


func test_rustbucket_has_speed_penalty() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("rustbucket")

	# Assert
	assert_eq(mechanics.get("speed_multiplier", 1.0), 0.85, "Rustbucket should have -15% speed")


func test_hotshot_has_damage_multiplier() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("hotshot")

	# Assert
	assert_eq(mechanics.get("damage_multiplier", 1.0), 1.20, "Hotshot should have +20% damage")


func test_tinkerer_has_stack_limit_bonus() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("tinkerer")

	# Assert
	assert_eq(mechanics.get("stack_limit_bonus", 0), 1, "Tinkerer should have +1 stack limit")


func test_salvager_has_component_yield_bonus() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("salvager")

	# Assert
	assert_eq(
		mechanics.get("component_yield_bonus", 0), 0.50, "Salvager should have +50% component yield"
	)
	assert_eq(mechanics.get("shop_discount", 0), 0.25, "Salvager should have 25% shop discount")


func test_overclocked_has_hp_damage_per_wave() -> void:
	# Arrange & Act
	var mechanics = CharacterTypeDatabase.get_special_mechanics("overclocked")

	# Assert
	assert_eq(
		mechanics.get("wave_hp_damage_pct", 0), 0.05, "Overclocked should take 5% HP per wave"
	)
	assert_eq(mechanics.get("damage_multiplier", 1.0), 1.15, "Overclocked should have +15% damage")


## ============================================================================
## SECTION 7: CharacterTypeDatabase - Starting Items
## User Story: "As a player, I want starting items when I create a character"
## ============================================================================


func test_scavenger_starts_with_rusty_blade() -> void:
	# Arrange & Act
	var items = CharacterTypeDatabase.get_starting_items("scavenger")

	# Assert
	assert_true(items.has("weapon_rusty_blade"), "Scavenger should start with rusty blade")


func test_rustbucket_starts_with_armor() -> void:
	# Arrange & Act
	var items = CharacterTypeDatabase.get_starting_items("rustbucket")

	# Assert
	assert_true(items.has("armor_scrap_vest"), "Rustbucket should start with armor")


func test_hotshot_starts_with_ranged_weapon() -> void:
	# Arrange & Act
	var items = CharacterTypeDatabase.get_starting_items("hotshot")

	# Assert
	assert_true(items.has("weapon_plasma_pistol"), "Hotshot should start with plasma pistol")


func test_tinkerer_starts_with_trinket() -> void:
	# Arrange & Act
	var items = CharacterTypeDatabase.get_starting_items("tinkerer")

	# Assert
	assert_true(items.has("trinket_lucky_coin"), "Tinkerer should start with lucky coin")


func test_overclocked_starts_with_uncommon_weapon() -> void:
	# Arrange & Act
	var items = CharacterTypeDatabase.get_starting_items("overclocked")

	# Assert
	assert_true(items.has("weapon_arc_blaster"), "Overclocked should start with arc blaster")


## ============================================================================
## SECTION 8: CharacterTypeDatabase - Display Properties
## User Story: "As a player, I want to see type information"
## ============================================================================


func test_display_name_returns_formatted_name() -> void:
	# Arrange & Act
	var name = CharacterTypeDatabase.get_display_name("scavenger")

	# Assert
	assert_eq(name, "Scavenger", "Display name should be capitalized")


func test_description_is_not_empty() -> void:
	# Arrange
	var type_ids = CharacterTypeDatabase.get_type_ids()

	# Act & Assert
	for type_id in type_ids:
		var desc = CharacterTypeDatabase.get_description(type_id)
		assert_false(desc.is_empty(), "Type '%s' should have a description" % type_id)


func test_color_is_not_white() -> void:
	# Arrange - Each type should have a distinctive color
	var type_ids = CharacterTypeDatabase.get_type_ids()

	# Act & Assert
	for type_id in type_ids:
		var color = CharacterTypeDatabase.get_color(type_id)
		assert_ne(color, Color.WHITE, "Type '%s' should have a custom color" % type_id)


## ============================================================================
## SECTION 9: CharacterService - Character Creation with Types
## User Story: "As a player, I want to create characters of different types"
## ============================================================================


func test_create_scavenger_succeeds() -> void:
	# Arrange & Act
	var char_id = CharacterService.create_character("TestScav", "scavenger")

	# Assert
	assert_false(char_id.is_empty(), "Should create scavenger successfully")


func test_create_character_applies_stat_modifiers() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestScav", "scavenger")

	# Act
	var character = CharacterService.get_character(char_id)

	# Assert - Scavenger has +10 scavenging, +15 pickup_range
	assert_eq(character.stats.scavenging, 10, "Scavenger should have 10 scavenging (base 0 + 10)")
	assert_eq(
		character.stats.pickup_range, 115, "Scavenger should have 115 pickup_range (base 100 + 15)"
	)


func test_create_rustbucket_applies_tank_stats() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestRust", "rustbucket")

	# Act
	var character = CharacterService.get_character(char_id)

	# Assert - Rustbucket has +30 max_hp, +5 armor
	assert_eq(character.stats.max_hp, 130, "Rustbucket should have 130 max_hp (base 100 + 30)")
	assert_eq(character.stats.armor, 5, "Rustbucket should have 5 armor (base 0 + 5)")


func test_create_hotshot_applies_glass_cannon_stats() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestHot", "hotshot")

	# Act
	var character = CharacterService.get_character(char_id)

	# Assert - Hotshot has +10% crit, -20 max_hp
	assert_almost_eq(
		character.stats.crit_chance, 0.15, 0.001, "Hotshot should have 0.15 crit (base 0.05 + 0.10)"
	)
	assert_eq(character.stats.max_hp, 80, "Hotshot should have 80 max_hp (base 100 - 20)")


func test_create_character_sets_weapon_slots() -> void:
	# Arrange
	var scav_id = CharacterService.create_character("TestScav", "scavenger")
	var rust_id = CharacterService.create_character("TestRust", "rustbucket")

	# Act
	var scav_slots = CharacterService.get_weapon_slots(scav_id)
	var rust_slots = CharacterService.get_weapon_slots(rust_id)

	# Assert
	assert_eq(scav_slots, 6, "Scavenger should have 6 weapon slots")
	assert_eq(rust_slots, 4, "Rustbucket should have 4 weapon slots")


func test_create_character_sets_inventory_slots() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestChar", "scavenger")

	# Act
	var slots = CharacterService.get_inventory_slots(char_id)

	# Assert
	assert_eq(slots, 30, "Character should have 30 inventory slots")


func test_create_character_stores_special_mechanics() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestRust", "rustbucket")

	# Act
	var mechanics = CharacterService.get_special_mechanics(char_id)

	# Assert
	assert_eq(
		mechanics.get("speed_multiplier", 1.0), 0.85, "Should store speed_multiplier mechanic"
	)


func test_create_character_includes_starting_items_in_post_context() -> void:
	# Arrange - We'll capture the post context via signal
	var captured_contexts = []
	var capture_callback = func(context: Dictionary):
		captured_contexts.append(context.duplicate(true))

	CharacterService.character_create_post.connect(capture_callback)

	# Act
	CharacterService.create_character("TestScav", "scavenger")

	# Cleanup
	CharacterService.character_create_post.disconnect(capture_callback)

	# Assert
	assert_eq(captured_contexts.size(), 1, "Should have captured one post context")
	var context = captured_contexts[0] if captured_contexts.size() > 0 else {}
	assert_true(context.has("starting_items"), "Post context should include starting_items")
	# starting_items is an Array, use 'in' operator or .has()
	var starting_items = context.get("starting_items", [])
	assert_true(
		"weapon_rusty_blade" in starting_items,
		"Starting items should include rusty blade for scavenger"
	)


## ============================================================================
## SECTION 10: CharacterService - Tier Gating Integration
## User Story: "As a FREE player, I cannot create PREMIUM characters"
## ============================================================================


func test_free_tier_cannot_create_tinkerer() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var char_id = CharacterService.create_character("TestTink", "tinkerer")

	# Assert
	assert_eq(char_id, "", "FREE tier should not create tinkerer")


func test_premium_tier_can_create_tinkerer() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var char_id = CharacterService.create_character("TestTink", "tinkerer")

	# Assert
	assert_false(char_id.is_empty(), "PREMIUM tier should create tinkerer")


func test_premium_tier_cannot_create_overclocked() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var char_id = CharacterService.create_character("TestOver", "overclocked")

	# Assert
	assert_eq(char_id, "", "PREMIUM tier should not create overclocked")


func test_subscription_tier_can_create_all_types() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	var type_ids = CharacterTypeDatabase.get_type_ids()

	# Act & Assert
	for type_id in type_ids:
		var char_id = CharacterService.create_character("Test_%s" % type_id, type_id)
		assert_false(char_id.is_empty(), "SUBSCRIPTION tier should create '%s'" % type_id)


func test_get_available_character_types_for_free() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act
	var available = CharacterService.get_available_character_types()

	# Assert
	assert_eq(available.size(), 3, "FREE tier should have 3 available types")
	assert_true(available.has("scavenger"), "Should include scavenger")
	assert_true(available.has("rustbucket"), "Should include rustbucket")
	assert_true(available.has("hotshot"), "Should include hotshot")


func test_get_available_character_types_for_premium() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)

	# Act
	var available = CharacterService.get_available_character_types()

	# Assert
	assert_eq(available.size(), 5, "PREMIUM tier should have 5 available types")
	assert_true(available.has("tinkerer"), "Should include tinkerer")
	assert_true(available.has("salvager"), "Should include salvager")


func test_can_create_character_type_check() -> void:
	# Arrange
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Act & Assert
	assert_true(
		CharacterService.can_create_character_type("scavenger"), "FREE should create scavenger"
	)
	assert_false(
		CharacterService.can_create_character_type("tinkerer"), "FREE should not create tinkerer"
	)


## ============================================================================
## SECTION 11: CharacterService - Special Mechanic Helpers
## User Story: "As a developer, I want easy access to character mechanics"
## ============================================================================


func test_has_special_mechanic_returns_true() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestScav", "scavenger")

	# Act & Assert
	assert_true(
		CharacterService.has_special_mechanic(char_id, "scrap_drop_bonus"),
		"Scavenger should have scrap_drop_bonus mechanic"
	)


func test_has_special_mechanic_returns_false() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestScav", "scavenger")

	# Act & Assert
	assert_false(
		CharacterService.has_special_mechanic(char_id, "shop_discount"),
		"Scavenger should not have shop_discount mechanic"
	)


func test_get_special_mechanic_returns_value() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestSalv", "salvager")
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	char_id = CharacterService.create_character("TestSalv", "salvager")

	# Act
	var discount = CharacterService.get_special_mechanic(char_id, "shop_discount", 0)

	# Assert
	assert_eq(discount, 0.25, "Should return 25% shop discount")


func test_get_special_mechanic_returns_default() -> void:
	# Arrange
	var char_id = CharacterService.create_character("TestScav", "scavenger")

	# Act
	var value = CharacterService.get_special_mechanic(char_id, "nonexistent", 999)

	# Assert
	assert_eq(value, 999, "Should return default value for nonexistent mechanic")


## ============================================================================
## SECTION 12: Edge Cases and Error Handling
## User Story: "As a developer, I want robust error handling"
## ============================================================================


func test_invalid_type_returns_empty_dict() -> void:
	# Arrange & Act
	var type_data = CharacterTypeDatabase.get_type("invalid_type")

	# Assert
	assert_true(type_data.is_empty(), "Invalid type should return empty dictionary")


func test_create_invalid_type_fails() -> void:
	# Arrange & Act
	var char_id = CharacterService.create_character("Test", "invalid_type")

	# Assert
	assert_eq(char_id, "", "Should fail to create with invalid type")


func test_get_weapon_slots_invalid_character() -> void:
	# Arrange & Act
	var slots = CharacterService.get_weapon_slots("invalid_id")

	# Assert
	assert_eq(slots, 6, "Invalid character should return default 6 weapon slots")


func test_get_inventory_slots_invalid_character() -> void:
	# Arrange & Act
	var slots = CharacterService.get_inventory_slots("invalid_id")

	# Assert
	assert_eq(slots, 30, "Invalid character should return default 30 inventory slots")


func test_get_special_mechanics_invalid_character() -> void:
	# Arrange & Act
	var mechanics = CharacterService.get_special_mechanics("invalid_id")

	# Assert
	assert_true(mechanics.is_empty(), "Invalid character should return empty mechanics")
