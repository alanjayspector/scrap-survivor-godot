extends Node
## DropSystem - Drop generation and collection
##
## Week 9 Phase 4: Drop system with scavenging multiplier and XP awards
##
## Responsibilities:
## - Generate currency drops from enemy drop tables
## - Apply scavenging multiplier to drop amounts
## - Award XP to characters for kills
## - Handle auto-collect via aura (future: spawn visual pickups)
##
## Based on: docs/migration/week9-implementation-plan.md (lines 296-381)

## Signals
signal drops_generated(enemy_type: String, drops: Dictionary)
signal xp_awarded(character_id: String, xp: int, leveled_up: bool)
signal drops_collected(drops: Dictionary)


## Initialize system
func _ready() -> void:
	GameLogger.info("DropSystem initialized")


## Generate drops from enemy drop table
## Returns Dictionary of { currency_name: amount }
func generate_drops(enemy_type: String, character_scavenging: int) -> Dictionary:
	print(
		"[DropSystem] generate_drops() called for enemy_type: ",
		enemy_type,
		" scavenging: ",
		character_scavenging
	)

	# Get enemy definition
	var enemy_def = EnemyService.get_enemy_type(enemy_type)
	if enemy_def.is_empty():
		print("[DropSystem] ERROR: Invalid enemy type: ", enemy_type)
		GameLogger.warning("Cannot generate drops: invalid enemy type", {"enemy_type": enemy_type})
		return {}

	var drops = {}

	# Calculate scavenging multiplier (cap at +50%)
	var scavenge_mult = 1.0 + min(character_scavenging / 100.0, 0.5)
	print("[DropSystem] Scavenge multiplier: ", scavenge_mult)
	print("[DropSystem] Drop table: ", enemy_def.drop_table)

	# Roll each drop in the drop table
	for currency in enemy_def.drop_table.keys():
		var drop_def = enemy_def.drop_table[currency]
		print("[DropSystem] Rolling for ", currency, " chance: ", drop_def.chance)

		# Check if drop occurs (chance roll)
		var roll = randf()
		print("[DropSystem] Roll: ", roll, " vs ", drop_def.chance)
		if roll <= drop_def.chance:
			var amount = randi_range(drop_def.min, drop_def.max)
			var final_amount = int(amount * scavenge_mult)
			print("[DropSystem] Drop succeeded! Amount: ", amount, " Final: ", final_amount)
			# Only add non-zero drops to the dictionary
			if final_amount > 0:
				drops[currency] = final_amount
		else:
			print("[DropSystem] Drop failed")

	# Emit signal
	drops_generated.emit(enemy_type, drops)

	print("[DropSystem] Final drops: ", drops)
	GameLogger.info(
		"Drops generated",
		{
			"enemy_type": enemy_type,
			"drops": drops,
			"scavenging": character_scavenging,
			"multiplier": scavenge_mult
		}
	)

	return drops


## Award XP for kill
## Returns true if character leveled up
func award_xp_for_kill(character_id: String, enemy_type: String) -> bool:
	# Get enemy definition
	var enemy_def = EnemyService.get_enemy_type(enemy_type)
	if enemy_def.is_empty():
		GameLogger.warning("Cannot award XP: invalid enemy type", {"enemy_type": enemy_type})
		return false

	var xp_reward = enemy_def.xp_reward

	# Award XP to character (may trigger level up)
	var leveled_up = CharacterService.add_experience(character_id, xp_reward)

	# Emit signal
	xp_awarded.emit(character_id, xp_reward, leveled_up)

	if leveled_up:
		GameLogger.info(
			"Character leveled up from kill",
			{"character_id": character_id, "enemy_type": enemy_type, "xp_awarded": xp_reward}
		)
	else:
		GameLogger.info(
			"XP awarded for kill",
			{"character_id": character_id, "enemy_type": enemy_type, "xp": xp_reward}
		)

	return leveled_up


## Process enemy kill - generate drops and award XP
## Returns Dictionary with { "drops": {}, "xp_awarded": int, "leveled_up": bool }
func process_enemy_kill(
	character_id: String, enemy_type: String, character_scavenging: int
) -> Dictionary:
	# Generate drops
	var drops = generate_drops(enemy_type, character_scavenging)

	# Award XP
	var leveled_up = award_xp_for_kill(character_id, enemy_type)

	# Get XP amount
	var enemy_def = EnemyService.get_enemy_type(enemy_type)
	var xp_awarded = enemy_def.xp_reward if not enemy_def.is_empty() else 0

	return {"drops": drops, "xp_awarded": xp_awarded, "leveled_up": leveled_up}


## Spawn drop pickups as collectible entities
## Week 11 Phase 2: Visual pickups that player collects by walking over
func spawn_drop_pickups(drops: Dictionary, position: Vector2) -> void:
	print(
		"[DropSystem] spawn_drop_pickups() called with drops: ", drops, " at position: ", position
	)

	if drops.is_empty():
		print("[DropSystem] Drops empty, skipping spawn")
		return

	# Preload the DropPickup scene
	const DROP_PICKUP_SCENE = preload("res://scenes/entities/drop_pickup.tscn")
	print("[DropSystem] DropPickup scene loaded")

	# Find the Drops container in the current scene
	var drops_container = get_tree().get_first_node_in_group("drops_container")
	print("[DropSystem] drops_container from group: ", drops_container)

	if not drops_container:
		# Fallback: try to find by name in current scene
		var current_scene = get_tree().current_scene
		print("[DropSystem] Current scene: ", current_scene)
		if current_scene:
			drops_container = current_scene.get_node_or_null("Drops")
			print("[DropSystem] drops_container from node lookup: ", drops_container)

	if not drops_container:
		print("[DropSystem] ERROR: No drops container found!")
		GameLogger.warning("No drops container found, cannot spawn pickups")
		return

	print("[DropSystem] Drops container found: ", drops_container)

	# Spawn a pickup for each currency drop
	var drop_index = 0
	for currency in drops.keys():
		var amount = drops[currency]
		print("[DropSystem] Spawning pickup for ", currency, " x", amount)

		# Instantiate pickup
		var pickup = DROP_PICKUP_SCENE.instantiate()
		print("[DropSystem] Pickup instantiated: ", pickup)

		# Setup the pickup with currency type and amount
		pickup.setup(currency, amount)
		print("[DropSystem] Pickup setup complete")

		# Position with random offset to spread drops (Brotato-style)
		var offset_angle = randf() * TAU
		var offset_distance = randf_range(10, 30)
		var offset = Vector2(cos(offset_angle), sin(offset_angle)) * offset_distance
		pickup.global_position = position + offset
		print("[DropSystem] Pickup positioned at ", pickup.global_position)

		# Connect collected signal
		pickup.collected.connect(_on_drop_collected)
		print("[DropSystem] Pickup signal connected")

		# Defer add_child to avoid physics state changes during callback
		drops_container.call_deferred("add_child", pickup)
		print("[DropSystem] Pickup queued to be added to scene")

		drop_index += 1

	GameLogger.info(
		"Drop pickups spawned", {"drops": drops, "position": position, "count": drop_index}
	)


## Handle drop collection when player picks up a drop
func _on_drop_collected(currency_type: String, amount: int) -> void:
	print("[DropSystem] _on_drop_collected() called: ", currency_type, " x", amount)

	# Map currency strings to BankingService.CurrencyType enum
	var currency_enum
	match currency_type:
		"scrap":
			currency_enum = BankingService.CurrencyType.SCRAP
			print("[DropSystem] Mapped to SCRAP enum")
		"components":
			currency_enum = BankingService.CurrencyType.COMPONENTS
			print("[DropSystem] Mapped to COMPONENTS enum")
		"nanites":
			currency_enum = BankingService.CurrencyType.NANITES
			print("[DropSystem] Mapped to NANITES enum")
		"premium":
			currency_enum = BankingService.CurrencyType.PREMIUM
			print("[DropSystem] Mapped to PREMIUM enum")
		_:
			print("[DropSystem] ERROR: Unknown currency type: ", currency_type)
			GameLogger.warning("Unknown currency type collected", {"currency": currency_type})
			return

	# Add currency to player's bank
	print("[DropSystem] Adding ", amount, " to BankingService, type: ", currency_enum)
	BankingService.add_currency(currency_enum, amount)
	print("[DropSystem] Currency added to bank")

	# Emit signal
	var drops_dict = {currency_type: amount}
	drops_collected.emit(drops_dict)
	print("[DropSystem] drops_collected signal emitted")

	GameLogger.info("Drop collected", {"currency": currency_type, "amount": amount})
	print("[DropSystem] Drop collection complete")

	# TODO: Show floating text "+5 Scrap" (future polish)
