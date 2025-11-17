extends Node
## BankingService - Local currency management
##
## Simplified version for Week 5 (no Supabase yet - that's Week 6).
## Implements:
## - Three currency types: Scrap (common), Components (Workshop), Nanites (Lab)
## - Tier-gating for premium features
## - Balance caps by tier
## - Transaction validation
##
## Based on TypeScript: packages/core/src/services/BankingService.ts

## User tier levels (matches TierService.ts)
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

## Emitted when state is loaded from save
signal state_loaded

## Current balances (local-first, will sync to Supabase in Week 6)
var balances: Dictionary = {"scrap": 0, "components": 0, "nanites": 0}

## Current user tier (set by TierService, defaults to FREE)
var current_tier: UserTier = UserTier.FREE

## Transaction history (local only for now)
var transaction_history: Array = []


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


## Add currency to balance
## Returns true if successful, false if rejected
func add_currency(type: CurrencyType, amount: int) -> bool:
	if amount <= 0:
		transaction_failed.emit("Amount must be positive")
		return false

	var type_str = _currency_type_to_string(type)
	var new_balance = balances[type_str] + amount

	# Check balance caps
	var caps = get_balance_caps(current_tier)

	# Components, Nanites, and Scrap all use the same per_character cap
	if type in [CurrencyType.SCRAP, CurrencyType.COMPONENTS, CurrencyType.NANITES]:
		if new_balance > caps.per_character:
			transaction_failed.emit(
				"Balance cap exceeded: %d (max: %d)" % [new_balance, caps.per_character]
			)
			return false

	# Update balance
	balances[type_str] = new_balance
	currency_changed.emit(type, new_balance)

	# Log transaction
	_log_transaction("add", type_str, amount, new_balance)

	GameLogger.info(
		"Currency added", {"type": type_str, "amount": amount, "new_balance": new_balance}
	)

	return true


## Subtract currency from balance
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


## Serialize service state to dictionary (Week 6)
func serialize() -> Dictionary:
	return {
		"version": 1,
		"balances": balances.duplicate(),
		"tier": current_tier,
		"transaction_history": transaction_history.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state from dictionary (Week 6)
func deserialize(data: Dictionary) -> void:
	if data.get("version", 0) != 1:
		GameLogger.warning("BankingService: Unknown save version", data)
		return

	# Restore balances with fallback for missing new currencies
	if data.has("balances"):
		balances = data.balances.duplicate()
		# Ensure new currencies exist (for backward compatibility)
		if not balances.has("components"):
			balances["components"] = 0
		if not balances.has("nanites"):
			balances["nanites"] = 0
	else:
		balances = {"scrap": 0, "components": 0, "nanites": 0}

	# Restore tier
	if data.has("tier"):
		current_tier = data.tier
	else:
		current_tier = UserTier.FREE

	# Restore transaction history (optional, may be omitted to save space)
	if data.has("transaction_history"):
		transaction_history = data.transaction_history.duplicate()
	else:
		transaction_history = []

	# Emit signals to notify UI
	currency_changed.emit(CurrencyType.SCRAP, balances.get("scrap", 0))
	currency_changed.emit(CurrencyType.COMPONENTS, balances.get("components", 0))
	currency_changed.emit(CurrencyType.NANITES, balances.get("nanites", 0))
	state_loaded.emit()

	GameLogger.info(
		"BankingService state loaded",
		{
			"scrap": balances.get("scrap", 0),
			"components": balances.get("components", 0),
			"nanites": balances.get("nanites", 0),
			"tier": current_tier
		}
	)


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
