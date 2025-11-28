extends Node
## BankingService - Currency management synchronized with active character
##
## ARCHITECTURE (Week 18 Fix):
## Currency is stored PER-CHARACTER in CharacterService.characters[id].starting_currency
## BankingService is a "view" of the active character's currency.
##
## - On active_character_changed → Load character's currency into balances
## - On add_currency/subtract_currency → Write-through to CharacterService immediately
## - serialize/deserialize are NO-OPS (currency lives in CharacterService)
##
## This enables:
## - Per-character currency (core design principle)
## - Quantum Banking subscription feature (transfer between characters)
## - Consistent state between services

## User tier levels (matches TierService.ts and CharacterService)
enum UserTier { FREE, PREMIUM, SUBSCRIPTION }

## Currency types
enum CurrencyType { SCRAP, COMPONENTS, NANITES }


## Balance caps for each tier
class BalanceCaps:
	var per_character: int
	var player_total: int

	func _init(per_char: int, total: int):
		per_character = per_char
		player_total = total


## Emitted when any currency balance changes
signal currency_changed(type: CurrencyType, new_balance: int)

## Emitted when transaction fails
signal transaction_failed(reason: String)

## Emitted when state is loaded from character (replaces state_loaded)
signal character_currency_synced(character_id: String)

## Current balances (view of active character's currency)
var balances: Dictionary = {"scrap": 0, "components": 0, "nanites": 0}

## Current user tier (set by TierService, defaults to FREE)
var current_tier: UserTier = UserTier.FREE

## Transaction history (local only, not persisted)
var transaction_history: Array = []

## Track if we're initialized and connected to CharacterService
var _initialized: bool = false


func _ready() -> void:
	# Defer connection to ensure CharacterService is ready
	call_deferred("_connect_to_character_service")


## Connect to CharacterService signals
func _connect_to_character_service() -> void:
	if not is_instance_valid(CharacterService):
		GameLogger.error("[BankingService] CharacterService not available - currency sync disabled")
		return

	# Connect to active character changes
	if not CharacterService.active_character_changed.is_connected(_on_active_character_changed):
		CharacterService.active_character_changed.connect(_on_active_character_changed)

	# Also connect to state_loaded for initial load
	if not CharacterService.state_loaded.is_connected(_on_character_service_loaded):
		CharacterService.state_loaded.connect(_on_character_service_loaded)

	_initialized = true
	GameLogger.info("[BankingService] Connected to CharacterService for currency sync")

	# Sync with current active character if one exists
	var active_id = CharacterService.get_active_character_id()
	if not active_id.is_empty():
		_sync_from_character(active_id)


## Handle CharacterService state loaded (initial load from save)
func _on_character_service_loaded() -> void:
	var active_id = CharacterService.get_active_character_id()
	if not active_id.is_empty():
		_sync_from_character(active_id)


## Handle active character change - sync currency from new character
func _on_active_character_changed(character_id: String) -> void:
	_sync_from_character(character_id)


## Load currency from character into BankingService balances
func _sync_from_character(character_id: String) -> void:
	if character_id.is_empty():
		# No active character - reset to 0
		balances = {"scrap": 0, "components": 0, "nanites": 0}
		currency_changed.emit(CurrencyType.SCRAP, 0)
		currency_changed.emit(CurrencyType.COMPONENTS, 0)
		currency_changed.emit(CurrencyType.NANITES, 0)
		GameLogger.info("[BankingService] No active character - balances reset to 0")
		return

	var character = CharacterService.get_character(character_id)
	if character.is_empty():
		GameLogger.warning("[BankingService] Character not found for sync", {"id": character_id})
		return

	# Get currency from character (with defaults for old saves)
	var currency = character.get("starting_currency", {"scrap": 0, "components": 0, "nanites": 0})

	# Update balances
	balances["scrap"] = currency.get("scrap", 0)
	balances["components"] = currency.get("components", 0)
	balances["nanites"] = currency.get("nanites", 0)

	# Emit signals so UI updates
	currency_changed.emit(CurrencyType.SCRAP, balances["scrap"])
	currency_changed.emit(CurrencyType.COMPONENTS, balances["components"])
	currency_changed.emit(CurrencyType.NANITES, balances["nanites"])
	character_currency_synced.emit(character_id)

	GameLogger.info(
		"[BankingService] Synced currency from character",
		{
			"character_id": character_id,
			"scrap": balances["scrap"],
			"components": balances["components"],
			"nanites": balances["nanites"]
		}
	)


## Write current balances back to active character
func _sync_to_character() -> void:
	var character_id = CharacterService.get_active_character_id()
	if character_id.is_empty():
		GameLogger.warning("[BankingService] Cannot sync to character - no active character")
		return

	# Update character's starting_currency
	CharacterService.update_character(
		character_id,
		{
			"starting_currency":
			{
				"scrap": balances["scrap"],
				"components": balances["components"],
				"nanites": balances["nanites"]
			}
		}
	)


## Get balance caps for a user tier
## Based on BankingService.ts:64-83
func get_balance_caps(tier: UserTier) -> BalanceCaps:
	match tier:
		UserTier.PREMIUM:
			return BalanceCaps.new(10_000, 1_000_000)
		UserTier.SUBSCRIPTION:
			return BalanceCaps.new(100_000, 1_000_000)
		UserTier.FREE, _:
			return BalanceCaps.new(0, 0)


## Check if user has access to Banking feature
## Based on BankingService.ts:88-97
func has_access() -> bool:
	# Free tier blocked from banking
	return current_tier != UserTier.FREE


## Add currency to balance (with write-through to CharacterService)
## Returns true if successful, false if rejected
func add_currency(type: CurrencyType, amount: int) -> bool:
	if amount <= 0:
		transaction_failed.emit("Amount must be positive")
		return false

	var type_str = _currency_type_to_string(type)
	var new_balance = balances[type_str] + amount

	# Check balance caps (only for Premium+ tiers)
	var caps = get_balance_caps(current_tier)
	if caps.per_character > 0 and new_balance > caps.per_character:
		transaction_failed.emit(
			"Balance cap exceeded: %d (max: %d)" % [new_balance, caps.per_character]
		)
		return false

	# Update balance
	balances[type_str] = new_balance
	currency_changed.emit(type, new_balance)

	# Write-through to CharacterService
	_sync_to_character()

	# Log transaction
	_log_transaction("add", type_str, amount, new_balance)

	GameLogger.info(
		"Currency added", {"type": type_str, "amount": amount, "new_balance": new_balance}
	)

	return true


## Subtract currency from balance (with write-through to CharacterService)
## Returns true if successful, false if rejected (insufficient funds)
func subtract_currency(type: CurrencyType, amount: int) -> bool:
	if amount <= 0:
		transaction_failed.emit("Amount must be positive")
		return false

	var type_str = _currency_type_to_string(type)
	var current_balance = balances[type_str]

	# Check sufficient funds
	if current_balance < amount:
		transaction_failed.emit("Insufficient funds: have %d, need %d" % [current_balance, amount])
		return false

	# Update balance
	var new_balance = current_balance - amount
	balances[type_str] = new_balance
	currency_changed.emit(type, new_balance)

	# Write-through to CharacterService
	_sync_to_character()

	# Log transaction
	_log_transaction("subtract", type_str, amount, new_balance)

	GameLogger.info(
		"Currency subtracted", {"type": type_str, "amount": amount, "new_balance": new_balance}
	)

	return true


## Get current balance for currency type
func get_balance(type: CurrencyType) -> int:
	var type_str = _currency_type_to_string(type)
	return balances[type_str]


## Set user tier (called by TierService or for testing)
func set_tier(tier: UserTier) -> void:
	current_tier = tier
	GameLogger.info("User tier set", {"tier": tier})


## Get current user tier
func get_tier() -> UserTier:
	return current_tier


## Get transaction history
func get_transaction_history() -> Array:
	return transaction_history.duplicate()


## Reset all balances (for testing or new game)
func reset() -> void:
	balances = {"scrap": 0, "components": 0, "nanites": 0}
	transaction_history.clear()
	current_tier = UserTier.FREE
	currency_changed.emit(CurrencyType.SCRAP, 0)
	currency_changed.emit(CurrencyType.COMPONENTS, 0)
	currency_changed.emit(CurrencyType.NANITES, 0)
	GameLogger.info("Banking service reset")


## Serialize service state to dictionary
## NO-OP: Currency is stored in CharacterService, not here
## Kept for backward compatibility with SaveManager
func serialize() -> Dictionary:
	return {
		"version": 2,  # Version 2 = currency in CharacterService
		"tier": current_tier,
		"timestamp": Time.get_unix_time_from_system(),
		# Note: balances NOT saved here - they live in CharacterService
	}


## Deserialize service state from dictionary
## NO-OP for balances: Currency is loaded from CharacterService via signal
## Only restores tier for backward compatibility
func deserialize(data: Dictionary) -> void:
	var version = data.get("version", 1)

	# Restore tier
	if data.has("tier"):
		current_tier = data.tier
	else:
		current_tier = UserTier.FREE

	# Version 1 (old saves): Had balances stored here
	# We ignore them - CharacterService is the source of truth
	# The _on_active_character_changed signal will sync the correct values

	if version == 1 and data.has("balances"):
		(
			GameLogger
			. info(
				"[BankingService] Ignoring v1 saved balances - using CharacterService as source of truth"
			)
		)

	GameLogger.info("[BankingService] Deserialized (tier only)", {"tier": current_tier})


## Private: Log a transaction
func _log_transaction(action: String, type: String, amount: int, balance_after: int) -> void:
	var transaction = {
		"timestamp": Time.get_ticks_msec(),
		"action": action,
		"type": type,
		"amount": amount,
		"balance_after": balance_after
	}
	transaction_history.append(transaction)

	# Keep only last 100 transactions
	if transaction_history.size() > 100:
		transaction_history.pop_front()


## Private: Convert CurrencyType enum to string key
func _currency_type_to_string(type: CurrencyType) -> String:
	match type:
		CurrencyType.SCRAP:
			return "scrap"
		CurrencyType.COMPONENTS:
			return "components"
		CurrencyType.NANITES:
			return "nanites"
		_:
			push_error("Unknown currency type: %d" % type)
			return "scrap"  # Fallback
