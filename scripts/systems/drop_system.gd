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
	# Get enemy definition
	var enemy_def = EnemyService.get_enemy_type(enemy_type)
	if enemy_def.is_empty():
		GameLogger.warning("Cannot generate drops: invalid enemy type", {"enemy_type": enemy_type})
		return {}

	var drops = {}

	# Calculate scavenging multiplier (cap at +50%)
	var scavenge_mult = 1.0 + min(character_scavenging / 100.0, 0.5)

	# Roll each drop in the drop table
	for currency in enemy_def.drop_table.keys():
		var drop_def = enemy_def.drop_table[currency]

		# Check if drop occurs (chance roll)
		if randf() <= drop_def.chance:
			var amount = randi_range(drop_def.min, drop_def.max)
			var final_amount = int(amount * scavenge_mult)
			drops[currency] = final_amount

	# Emit signal
	drops_generated.emit(enemy_type, drops)

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


## Spawn drop pickups (Week 10 - auto-collect for now, visual pickups in Week 11)
## For Week 10, immediately collect drops and add to BankingService
func spawn_drop_pickups(drops: Dictionary, position: Vector2) -> void:
	if drops.is_empty():
		return

	# Week 10: Auto-collect drops (no visual pickups yet)
	# Add currency directly to BankingService
	for currency in drops.keys():
		var amount = drops[currency]

		# Map currency strings to BankingService.CurrencyType enum
		# For now, map scrap/components/nanites all to SCRAP
		# TODO Week 11: Add components and nanites to BankingService
		var currency_type
		match currency:
			"scrap", "components", "nanites":
				currency_type = BankingService.CurrencyType.SCRAP
			"premium":
				currency_type = BankingService.CurrencyType.PREMIUM
			_:
				GameLogger.warning("Unknown currency type", {"currency": currency})
				continue

		BankingService.add_currency(currency_type, amount)

	# Emit drops collected signal
	drops_collected.emit(drops)

	GameLogger.debug("Drops auto-collected", {"drops": drops, "position": position})
