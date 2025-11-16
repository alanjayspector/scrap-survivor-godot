extends Node
## HudService - Central HUD update service using signals
##
## Week 10 Phase 3: Signal-driven HUD updates for HP, XP, wave, and currency
##
## Responsibilities:
## - Connect to Player, CharacterService, DropSystem, and BankingService signals
## - Emit standardized HUD update signals
## - Manage wave state updates
## - Provide centralized HUD state management
##
## Based on: docs/migration/week10-implementation-plan.md (lines 407-464)

## HUD update signals
signal hp_changed(current: float, max_value: float)
signal xp_changed(current: int, required: int, level: int)
signal wave_changed(wave: int)
signal wave_timer_updated(time_remaining: float)  # Week 14 Phase 2
signal currency_changed(currency_type: String, amount: int, new_total: int)

## Player reference (set by game scene)
var player: Player = null

## Current wave tracking
var current_wave: int = 1


func _ready() -> void:
	# Connect to CharacterService signals
	if CharacterService:
		CharacterService.character_level_up_post.connect(_on_character_level_up_post)

	# Connect to DropSystem signals
	if DropSystem:
		DropSystem.drops_collected.connect(_on_drops_collected)
		DropSystem.xp_awarded.connect(_on_xp_awarded)

	# Connect to BankingService signals
	if BankingService:
		BankingService.currency_changed.connect(_on_banking_currency_changed)

	GameLogger.info("HudService initialized")


## Set the active player and connect to their signals
func set_player(player_node: Player) -> void:
	# Disconnect from previous player if exists
	if player and is_instance_valid(player):
		if player.player_damaged.is_connected(_on_player_damaged):
			player.player_damaged.disconnect(_on_player_damaged)
		if player.player_healed.is_connected(_on_player_healed):
			player.player_healed.disconnect(_on_player_healed)
		if player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.disconnect(_on_player_health_changed)

	# Set new player
	player = player_node

	if not player or not is_instance_valid(player):
		GameLogger.warning("HudService: Cannot set invalid player")
		return

	# Connect to new player signals
	player.player_damaged.connect(_on_player_damaged)
	player.player_healed.connect(_on_player_healed)
	player.health_changed.connect(_on_player_health_changed)

	# Emit initial HP state
	var max_hp = player.stats.get("max_hp", 100)
	hp_changed.emit(player.current_hp, max_hp)

	# Emit initial XP state if character exists
	if not player.character_id.is_empty():
		var character = CharacterService.get_character(player.character_id)
		if character:
			var current_xp = character.get("experience", 0)
			var level = character.get("level", 1)
			var xp_to_next = level * CharacterService.XP_PER_LEVEL
			xp_changed.emit(current_xp, xp_to_next, level)

	GameLogger.info("HudService: Player connected", {"character_id": player.character_id})


## Update the current wave number
func update_wave(wave: int) -> void:
	current_wave = wave
	wave_changed.emit(wave)
	GameLogger.info("HudService: Wave updated", {"wave": wave})


## Update wave timer (Week 14 Phase 2)
func update_wave_timer(time_remaining: float) -> void:
	"""Update wave timer countdown in HUD

	Args:
		time_remaining: Seconds remaining in wave (0.0 = CLEANUP phase)
	"""
	wave_timer_updated.emit(time_remaining)


## Signal Handlers - Player


func _on_player_damaged(current_hp: float, max_hp: float) -> void:
	hp_changed.emit(current_hp, max_hp)


func _on_player_healed(current_hp: float, max_hp: float) -> void:
	hp_changed.emit(current_hp, max_hp)


func _on_player_health_changed(current_hp: float, max_hp: float) -> void:
	hp_changed.emit(current_hp, max_hp)


## Signal Handlers - CharacterService


func _on_character_level_up_post(context: Dictionary) -> void:
	var character_id = context.get("character_id", "")
	var new_level = context.get("new_level", 1)

	# Only update if this is the active player's character
	if player and player.character_id == character_id:
		# Get updated character data
		var character = CharacterService.get_character(character_id)
		if character:
			var current_xp = character.get("experience", 0)
			var xp_to_next = new_level * CharacterService.XP_PER_LEVEL
			xp_changed.emit(current_xp, xp_to_next, new_level)

			GameLogger.debug(
				"HudService: Character leveled up",
				{"character_id": character_id, "level": new_level}
			)
		else:
			GameLogger.error(
				"HudService: Could not get character data", {"character_id": character_id}
			)


func _on_xp_awarded(character_id: String, xp_amount: int, leveled_up: bool) -> void:
	# Only update if this is the active player's character
	if player and player.character_id == character_id:
		# Get updated character data
		var character = CharacterService.get_character(character_id)
		if character:
			var current_xp = character.get("experience", 0)
			var level = character.get("level", 1)
			var xp_to_next = level * CharacterService.XP_PER_LEVEL
			xp_changed.emit(current_xp, xp_to_next, level)

			GameLogger.debug(
				"HudService: XP awarded",
				{"character_id": character_id, "xp": xp_amount, "leveled_up": leveled_up}
			)


## Signal Handlers - DropSystem


func _on_drops_collected(drops: Dictionary) -> void:
	# Emit currency change for each currency type collected
	for currency in drops.keys():
		var amount = drops[currency]

		# Get current total from BankingService
		# For now, we'll emit the amount collected (UI will track totals)
		var new_total = _get_currency_total(currency)

		currency_changed.emit(currency, amount, new_total)

		GameLogger.debug("HudService: Currency collected", {"currency": currency, "amount": amount})


## Signal Handlers - BankingService


func _on_banking_currency_changed(type: int, new_balance: int) -> void:
	# Convert BankingService.CurrencyType enum to string
	var currency_type_str: String
	match type:
		BankingService.CurrencyType.SCRAP:
			currency_type_str = "scrap"
		BankingService.CurrencyType.PREMIUM:
			currency_type_str = "premium"
		BankingService.CurrencyType.COMPONENTS:
			currency_type_str = "components"
		BankingService.CurrencyType.NANITES:
			currency_type_str = "nanites"
		_:
			currency_type_str = "unknown"

	# Emit with delta of 0 (we don't know the delta from this signal)
	currency_changed.emit(currency_type_str, 0, new_balance)

	GameLogger.debug(
		"HudService: Banking currency changed", {"type": currency_type_str, "balance": new_balance}
	)


## Helper Functions


func _get_currency_total(currency: String) -> int:
	"""Get the current total for a currency type"""
	# Map currency strings to BankingService balance
	match currency:
		"scrap":
			return BankingService.balances.get("scrap", 0)
		"premium":
			return BankingService.balances.get("premium", 0)
		"components":
			return BankingService.balances.get("components", 0)
		"nanites":
			return BankingService.balances.get("nanites", 0)
		_:
			return 0


## Public API for getting current state


func get_current_hp() -> Dictionary:
	"""Get current HP state as {current, max}"""
	if player and is_instance_valid(player):
		return {"current": player.current_hp, "max": player.stats.get("max_hp", 100)}
	return {"current": 0, "max": 100}


func get_current_xp() -> Dictionary:
	"""Get current XP state as {current, required, level}"""
	if player and is_instance_valid(player) and not player.character_id.is_empty():
		var character = CharacterService.get_character(player.character_id)
		if character:
			var level = character.get("level", 1)
			return {
				"current": character.get("experience", 0),
				"required": level * CharacterService.XP_PER_LEVEL,
				"level": level
			}
	return {"current": 0, "required": 100, "level": 1}


func get_current_wave() -> int:
	"""Get current wave number"""
	return current_wave
