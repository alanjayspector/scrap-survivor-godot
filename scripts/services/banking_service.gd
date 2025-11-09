extends Node
## BankingService - Local currency management
##
## Simplified version for Week 5 (no Supabase yet - that's Week 6).
## Implements:
## - Scrap and premium currency tracking
## - Tier-gating for premium features
## - Balance caps by tier
## - Transaction validation
##
## Based on TypeScript: packages/core/src/services/BankingService.ts

## User tier levels (matches TierService.ts)
enum UserTier { FREE, PREMIUM, SUBSCRIPTION }

## Currency types
enum CurrencyType { SCRAP, PREMIUM }


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

## Current balances (local-first, will sync to Supabase in Week 6)
var balances: Dictionary = {"scrap": 0, "premium": 0}

## Current user tier (set by TierService, defaults to FREE)
var current_tier: UserTier = UserTier.FREE

## Transaction history (local only for now)
var transaction_history: Array = []


## Get balance caps for a user tier
## Based on BankingService.ts:64-83
static func get_balance_caps(tier: UserTier) -> BalanceCaps:
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

	var type_str = "scrap" if type == CurrencyType.SCRAP else "premium"
	var new_balance = balances[type_str] + amount

	# Check balance caps
	var caps = get_balance_caps(current_tier)

	if type == CurrencyType.SCRAP:
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

	Logger.info("Currency added", {"type": type_str, "amount": amount, "new_balance": new_balance})

	return true


## Subtract currency from balance
## Returns true if successful, false if rejected (insufficient funds)
func subtract_currency(type: CurrencyType, amount: int) -> bool:
	if amount <= 0:
		transaction_failed.emit("Amount must be positive")
		return false

	var type_str = "scrap" if type == CurrencyType.SCRAP else "premium"
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

	Logger.info(
		"Currency subtracted", {"type": type_str, "amount": amount, "new_balance": new_balance}
	)

	return true


## Get current balance for currency type
func get_balance(type: CurrencyType) -> int:
	var type_str = "scrap" if type == CurrencyType.SCRAP else "premium"
	return balances[type_str]


## Set user tier (called by TierService or for testing)
func set_tier(tier: UserTier) -> void:
	current_tier = tier
	Logger.info("User tier set", {"tier": tier})


## Get transaction history
func get_transaction_history() -> Array:
	return transaction_history.duplicate()


## Reset all balances (for testing or new game)
func reset() -> void:
	balances = {"scrap": 0, "premium": 0}
	transaction_history.clear()
	currency_changed.emit(CurrencyType.SCRAP, 0)
	currency_changed.emit(CurrencyType.PREMIUM, 0)
	Logger.info("Banking service reset")


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
