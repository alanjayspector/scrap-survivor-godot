# Service Architecture Patterns for Godot 4.5.1 (GDScript)

> **Target Audience**: Senior developers familiar with service architecture transitioning to Godot. **Version**: Godot 4.5.1, GDScript. **Platforms**: Mac M4, iOS, Android, HTML5

---

## Table of Contents

1. [Service Lifecycle Patterns](#service-lifecycle-patterns)
2. [Service Communication Patterns](#service-communication-patterns)
3. [Service State Management](#service-state-management)
4. [Service Testing Patterns](#service-testing-patterns)
5. [API Design Patterns](#api-design-patterns)
6. [Dependency Injection](#dependency-injection)
7. [Common Service Anti-Patterns](#common-service-anti-patterns)
8. [Enforceable Patterns](#enforceable-patterns)
9. [Quick Reference](#quick-reference)

---

## Service Lifecycle Patterns

### AutoLoad Fundamentals

In Godot, services are typically implemented as autoload (singleton) nodes. AutoLoads are nodes that load before any scene and persist throughout the game lifetime.

**Key Characteristics:**
- Always added to the scene tree root before other scenes load
- Accessed globally without `get_node()` calls
- Execute `_ready()` before any scene nodes
- Loaded in registration order (visible in Project Settings > AutoLoad)

**Registering an AutoLoad Service:**

```gdscript
# Project Settings > AutoLoad tab
# Name: BankingService
# Path: res://services/banking_service.gd
```

### Initialization Order Management

**Problem:** Services have dependencies on other services. Declaration order in AutoLoad settings determines initialization sequence.

**Solution Pattern - Service Registry:**

```gdscript
# services/service_registry.gd
# AUTOLOAD FIRST (order position: 1)
extends Node
class_name ServiceRegistry

static var _services: Dictionary = {}

static func register(service_name: String, service: Node) -> void:
	if service_name in _services:
		push_error("Service already registered: %s" % service_name)
		return
	_services[service_name] = service

static func get_service(service_name: String) -> Node:
	if not service_name in _services:
		push_error("Service not found: %s" % service_name)
		return null
	return _services[service_name]

static func get_all_services() -> Array:
	return _services.values()
```

**Dependent Service Initialization:**

```gdscript
# services/banking_service.gd
extends Node
class_name BankingService

var _recycler_service: RecyclerService
var _stat_service: StatService
var _is_initialized: bool = false

signal initialized

func _ready() -> void:
	# Manual lookup in registry (safer than autoload reference)
	_recycler_service = ServiceRegistry.get_service("RecyclerService")
	_stat_service = ServiceRegistry.get_service("StatService")
	
	if not _recycler_service or not _stat_service:
		push_error("BankingService: Required services not initialized")
		return
	
	_initialize()

func _initialize() -> void:
	_is_initialized = true
	initialized.emit()

func is_ready() -> bool:
	return _is_initialized
```

**AutoLoad Registration Order (Project Settings):**

1. ServiceRegistry (base)
2. ErrorService (logging foundation)
3. SaveSystem (state persistence)
4. StatService (game data)
5. RecyclerService (pool management)
6. ShopRerollService (depends on StatService, RecyclerService)
7. BankingService (depends on RecyclerService, StatService)
8. SaveManager (depends on multiple services)

### Ready vs Manual Initialization

**Pattern: Deferred Initialization Check**

```gdscript
# Use this pattern for services with complex dependencies
extends Node
class_name MyService

var _initialized: bool = false

func _ready() -> void:
	# Don't initialize yet if dependencies aren't ready
	await get_tree().process_frame
	_perform_initialization()

func _perform_initialization() -> void:
	if _initialized:
		return
	
	# Safe to call service methods here
	_initialized = true

func get_value() -> Variant:
	if not _initialized:
		push_error("Service not initialized")
		return null
	return _get_internal_value()
```

**When to use manual initialization:**

- Services with circular dependency potential
- Services that need configuration before use
- Optional services that initialize conditionally

### Cleanup and Reset Patterns

**Service Cleanup on Scene Change:**

```gdscript
# services/base_service.gd
extends Node
class_name BaseService

var _is_shutting_down: bool = false

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# Services shouldn't be cleaned when scenes change
	# But track when main scene unloads
	pass

func shutdown() -> void:
	"""Called when game exits or hard reset needed."""
	_is_shutting_down = true
	_cleanup_internal_state()
	queue_free()

func reset_game_state() -> void:
	"""Reset service state for new game/level without destroying service."""
	_cleanup_internal_state()
	_reinitialize_defaults()

func _cleanup_internal_state() -> void:
	pass

func _reinitialize_defaults() -> void:
	pass
```

**Usage in game controller:**

```gdscript
# game_manager.gd
extends Node

func start_new_game() -> void:
	# Reset all services without destroying them
	for service in ServiceRegistry.get_all_services():
		if service.has_method("reset_game_state"):
			service.reset_game_state()

func quit_game() -> void:
	for service in ServiceRegistry.get_all_services():
		if service.has_method("shutdown"):
			service.shutdown()
```

### Hot Reload Considerations

**Problem:** Godot 4.5 supports script hot-reloading, but autoload state may be inconsistent.

**Solution - State Preservation Flag:**

```gdscript
# services/banking_service.gd
extends Node
class_name BankingService

var _player_balance: int = 0
var _transaction_history: Array = []

var _is_hot_reloaded: bool = false

func _ready() -> void:
	# Check if we're recovering from hot reload
	if _is_hot_reloaded:
		_restore_from_hot_reload()
		_is_hot_reloaded = false
	else:
		_initialize_fresh()

func _initialize_fresh() -> void:
	_player_balance = 0
	_transaction_history = []

func _restore_from_hot_reload() -> void:
	# Data persists in class-level vars, just validate state
	if _validate_state():
		push_warning("BankingService state valid after hot reload")
	else:
		_initialize_fresh()

func _validate_state() -> bool:
	return _player_balance >= 0 and _transaction_history is Array
```

**For persistent hot-reload state across scenes:**

```gdscript
# Use Resources stored as @onready or manually cached
@onready var _persistent_data: PersistentGameState = load("res://data/current_session.tres")

func _ready() -> void:
	if _persistent_data == null:
		_persistent_data = PersistentGameState.new()
	_load_from_persistent()
```

---

## Service Communication Patterns

### When to Use Signals vs Direct Calls

**Direct Calls:** Use when you need an immediate response or guarantee of execution.

```gdscript
# Direct call - gets result immediately
var balance = BankingService.get_balance()
BankingService.add_transaction(100)

# Advantages:
# - Synchronous, predictable
# - Easy to test
# - Type-safe return values
# - Fails visibly if service unavailable

# Disadvantages:
# - Creates hard dependency
# - Couples caller to service implementation
# - Can chain into callback hell with async operations
```

**Decision Matrix:**

| Scenario | Pattern | Reason |
|----------|---------|--------|
| Query current state | Direct call | Data immediately available, O(1) lookup |
| State change confirmation needed | Direct call with return | Validate operation succeeded |
| Event broadcast (multiple listeners) | Signal | Multiple systems need notification |
| Asynchronous operation (load, network) | Signal + await | Non-blocking, enables concurrent operations |
| Cross-layer communication (UI â†” Game â†” Save) | Event bus signal | Decouples layers, reduces coupling |
| Error handling required | Direct call + error handling | Errors need immediate attention |

### Signals for Event Broadcasting

**Pattern: Service signals for unidirectional notification**

```gdscript
# services/banking_service.gd
extends Node
class_name BankingService

signal transaction_processed(amount: int, new_balance: int)
signal insufficient_funds(requested: int, available: int)
signal balance_changed(new_balance: int)

var _balance: int = 0

func add_funds(amount: int) -> bool:
	if amount <= 0:
		return false
	
	_balance += amount
	transaction_processed.emit(amount, _balance)
	balance_changed.emit(_balance)
	return true

func withdraw_funds(amount: int) -> bool:
	if amount > _balance:
		insufficient_funds.emit(amount, _balance)
		return false
	
	_balance -= amount
	transaction_processed.emit(-amount, _balance)
	balance_changed.emit(_balance)
	return true

func get_balance() -> int:
	return _balance
```

**Connecting to service signals:**

```gdscript
# ui/wallet_display.gd
extends Control

@onready var balance_label: Label = $VBoxContainer/BalanceLabel

func _ready() -> void:
	# Connect service signal to local handler
	BankingService.balance_changed.connect(_on_balance_changed)
	# Update immediately
	_on_balance_changed(BankingService.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	balance_label.text = "Balance: $%d" % new_balance

func _exit_tree() -> void:
	# Disconnect when node leaves tree (important!)
	if BankingService.balance_changed.is_connected(_on_balance_changed):
		BankingService.balance_changed.disconnect(_on_balance_changed)
```

### Event Bus Pattern

**When to use:** Cross-cutting concerns that multiple unrelated systems need to know about.

```gdscript
# services/event_bus.gd
# AUTOLOAD: EventBus
extends Node
class_name EventBus

# Game flow events
signal game_started
signal game_paused
signal game_resumed
signal game_over(reason: String)
signal level_completed(level_id: int, score: int)

# Gameplay events
signal enemy_spawned(enemy_id: int)
signal enemy_defeated(enemy_id: int, reward: int)
signal player_damaged(damage: int, source: String)

# Analytics events
signal player_action(action_name: String, metadata: Dictionary)
```

**Usage - Multiple consumers:**

```gdscript
# Gameplay system
func _on_enemy_defeated(enemy_id: int) -> void:
	EventBus.enemy_defeated.emit(enemy_id, 50)
	# Multiple systems react:
	# - BankingService adds reward
	# - StatService tracks kill count
	# - AnalyticsService logs event
	# - EffectService plays particle effect
	# All without coupling to each other
```

**Constraints (important for Godot):**

- Use event bus **sparingly** for truly decoupled events only
- For service-to-service communication, prefer direct calls
- Document all events in event bus clearly
- Use consistent naming (`*_started`, `*_finished`, `*_changed`)
- Connections are silent failures - test signal connections carefully

### Avoiding Circular Dependencies

**Problem:** Service A needs Service B, Service B needs Service A.

**Solution 1: Introduce Interface/Observer**

```gdscript
# Bad: Circular dependency
# BankingService needs ShopService (to check prices)
# ShopService needs BankingService (to check balance)

# Good: Use intermediate interface
# services/purchasable.gd
class_name Purchasable

signal purchase_attempted(buyer_id: int, amount: int)
signal purchase_completed(buyer_id: int)

func can_afford(amount: int) -> bool:
	pass
```

```gdscript
# services/shop_service.gd
extends Node
class_name ShopService

func attempt_purchase(purchaser: Purchasable, item_id: int) -> bool:
	var price = _get_item_price(item_id)
	
	if purchaser.can_afford(price):
		purchaser.purchase_completed.emit(purchaser)
		return true
	
	return false
```

**Solution 2: Defer to Event Bus**

```gdscript
# services/banking_service.gd
func _ready() -> void:
	# Listen for shop requests instead of shop calling us
	EventBus.purchase_requested.connect(_on_purchase_requested)

func _on_purchase_requested(item_id: int, item_price: int) -> void:
	if _can_withdraw(item_price):
		_withdraw(item_price)
		EventBus.purchase_confirmed.emit(item_id)
	else:
		EventBus.purchase_declined.emit(item_id, "insufficient_funds")
```

**Solution 3: Dependency Inversion**

```gdscript
# Inject shared dependency instead of cross-referencing
# services/economy_service.gd (new intermediate layer)
extends Node
class_name EconomyService

var banking_service: BankingService
var shop_service: ShopService

func _ready() -> void:
	banking_service = ServiceRegistry.get_service("BankingService")
	shop_service = ServiceRegistry.get_service("ShopService")
	
	# Wire up their interactions
	shop_service.set_banking_service(banking_service)

# In project settings, load EconomyService AFTER both services
```

### Service Discovery Patterns

**Basic Service Locator (via registry):**

```gdscript
# Avoid hardcoding autoload names
# BAD:
var balance = BankingService.get_balance()

# GOOD:
var banking = ServiceRegistry.get_service("BankingService")
if banking:
	var balance = banking.get_balance()
else:
	push_error("BankingService not available")
```

**Named Service Access:**

```gdscript
# services/service_registry.gd - Enhanced version
extends Node
class_name ServiceRegistry

static var _services: Dictionary = {}
static var _service_aliases: Dictionary = {
	"bank": "BankingService",
	"shop": "ShopService",
	"stats": "StatService",
}

static func get_service(service_name: String) -> Node:
	# Check aliases first
	if service_name in _service_aliases:
		service_name = _service_aliases[service_name]
	
	if not service_name in _services:
		push_error("Service not found: %s" % service_name)
		return null
	
	return _services[service_name]

static func list_services() -> Dictionary:
	return _services.duplicate()
```

---

## Service State Management

### State Serialization Best Practices

**Pattern: Export with Type Safety**

```gdscript
# Godot 4.5 - Use @export with type annotations
# services/banking_service.gd
extends Node
class_name BankingService

# These persist in save files
@export var player_balance: int = 0
@export var total_spent: int = 0
@export var transaction_count: int = 0

# Runtime-only state (don't serialize)
var _current_session_balance: int = 0
var _pending_transactions: Array = []

func _to_dict() -> Dictionary:
	"""Convert service state to serializable dict."""
	return {
		"player_balance": player_balance,
		"total_spent": total_spent,
		"transaction_count": transaction_count,
	}

func _from_dict(data: Dictionary) -> void:
	"""Restore service state from dict."""
	player_balance = data.get("player_balance", 0)
	total_spent = data.get("total_spent", 0)
	transaction_count = data.get("transaction_count", 0)
```

**Using Resources for Complex State:**

```gdscript
# services/game_state_service.gd
extends Node
class_name GameStateService

class GameStateData:
	extends Resource
	
	@export var player_level: int = 1
	@export var experience: int = 0
	@export var unlocked_items: Array[String] = []
	@export var completed_quests: Array[int] = []
	
	func validate() -> bool:
		return player_level > 0 and experience >= 0

var _state: GameStateData

func _ready() -> void:
	_state = GameStateData.new()

func save_to_file(path: String) -> bool:
	if not _state.validate():
		push_error("Invalid state before save")
		return false
	
	var error = ResourceSaver.save(_state, path)
	return error == OK

func load_from_file(path: String) -> bool:
	if not ResourceLoader.exists(path):
		push_error("Save file not found: %s" % path)
		return false
	
	_state = ResourceLoader.load(path)
	return _state != null and _state.validate()
```

### Dirty Flag Patterns

**Optimize serialization by tracking changed state:**

```gdscript
# services/stat_service.gd
extends Node
class_name StatService

class Stats:
	var health: int = 100
	var mana: int = 50
	var experience: int = 0
	
	var _is_dirty: bool = false
	
	func modify_health(delta: int) -> void:
		health = max(0, health + delta)
		_is_dirty = true
	
	func modify_mana(delta: int) -> void:
		mana = max(0, mana + delta)
		_is_dirty = true
	
	func is_dirty() -> bool:
		return _is_dirty
	
	func clear_dirty_flag() -> void:
		_is_dirty = false

var _player_stats: Stats = Stats.new()

func get_dirty_stats() -> Dictionary:
	"""Only return changed stats."""
	if _player_stats.is_dirty():
		var dirty_data = {
			"health": _player_stats.health,
			"mana": _player_stats.mana,
			"experience": _player_stats.experience,
		}
		_player_stats.clear_dirty_flag()
		return dirty_data
	return {}
```

### State Validation

**Prevent invalid state propagation:**

```gdscript
# services/banking_service.gd
extends Node
class_name BankingService

var _balance: int = 0

func validate_state() -> Array[String]:
	"""Return array of validation errors (empty if valid)."""
	var errors: Array[String] = []
	
	if _balance < 0:
		errors.append("Balance cannot be negative: %d" % _balance)
	
	if _balance > 999999999:
		errors.append("Balance exceeds max: %d" % _balance)
	
	return errors

func set_balance(new_balance: int) -> bool:
	_balance = new_balance
	
	var validation_errors = validate_state()
	if not validation_errors.is_empty():
		push_error("Invalid state: %s" % validation_errors)
		_balance = 0  # Revert to safe state
		return false
	
	return true

func restore_from_save(save_data: Dictionary) -> bool:
	"""Restore and validate in one operation."""
	var old_balance = _balance
	_balance = save_data.get("balance", 0)
	
	if not validate_state().is_empty():
		_balance = old_balance
		return false
	
	return true
```

### Migration and Versioning

**Handle save file format changes:**

```gdscript
# services/save_manager.gd
extends Node
class_name SaveManager

const SAVE_VERSION: int = 3

class SaveData:
	extends Resource
	
	@export var version: int = SAVE_VERSION
	@export var created_time: int = 0
	@export var player_data: Dictionary = {}

func load_save(path: String) -> bool:
	if not ResourceLoader.exists(path):
		return false
	
	var save_data: SaveData = ResourceLoader.load(path)
	
	if not save_data:
		return false
	
	# Migrate old versions
	if save_data.version < SAVE_VERSION:
		if not _migrate_save_data(save_data):
			return false
	
	_apply_loaded_data(save_data)
	return true

func _migrate_save_data(save_data: SaveData) -> bool:
	match save_data.version:
		1:
			# Migrate from v1 to v2
			_migrate_v1_to_v2(save_data)
			save_data.version = 2
			fallthrough
		2:
			# Migrate from v2 to v3
			_migrate_v2_to_v3(save_data)
			save_data.version = 3
			fallthrough
		3:
			# Current version
			return true
	
	return save_data.version == SAVE_VERSION

func _migrate_v1_to_v2(save_data: SaveData) -> void:
	# Add new field with default
	if not "playtime" in save_data.player_data:
		save_data.player_data["playtime"] = 0

func _migrate_v2_to_v3(save_data: SaveData) -> void:
	# Restructure old format
	var old_stats = save_data.player_data.get("stats", {})
	if not "character_level" in old_stats:
		save_data.player_data["character_level"] = 1
```

---

## Service Testing Patterns

### Unit Testing Services with GdUnit4

**Setup GdUnit4:**

```bash
# Install addon from AssetLib or:
# https://github.com/MikeSchulze/gdUnit4
```

**Test structure:**

```gdscript
# tests/services/test_banking_service.gd
class_name TestBankingService
extends GdUnitTestSuite

func test_balance_calculation() -> void:
	var service = BankingService.new()
	service._ready()
	
	assert_int(service.get_balance()).is_equal(0)

func test_add_funds() -> void:
	var service = BankingService.new()
	service._ready()
	
	var success = service.add_funds(100)
	
	assert_bool(success).is_true()
	assert_int(service.get_balance()).is_equal(100)

func test_insufficient_funds() -> void:
	var service = BankingService.new()
	service._ready()
	
	var success = service.withdraw_funds(50)
	
	assert_bool(success).is_false()
	assert_int(service.get_balance()).is_equal(0)

func test_signal_emitted_on_withdrawal() -> void:
	var service = BankingService.new()
	service._ready()
	
	service.add_funds(100)
	
	var signal_watcher = watch_signals(service)
	service.withdraw_funds(50)
	
	signal_watcher.assert_signal_emitted("balance_changed")
```

### Mocking Service Dependencies

**Pattern: Dependency injection for testing**

```gdscript
# services/shop_service.gd
extends Node
class_name ShopService

var _banking_service: BankingService

func set_banking_service(service: BankingService) -> void:
	_banking_service = service

func _ready() -> void:
	if not _banking_service:
		_banking_service = ServiceRegistry.get_service("BankingService")

func purchase_item(item_id: int, price: int) -> bool:
	if not _banking_service:
		push_error("Banking service not available")
		return false
	
	return _banking_service.withdraw_funds(price)
```

**Test with mock:**

```gdscript
# tests/services/test_shop_service.gd
class_name TestShopService
extends GdUnitTestSuite

class MockBankingService:
	extends BankingService
	
	var withdraw_calls: int = 0
	var last_withdraw_amount: int = 0
	
	func withdraw_funds(amount: int) -> bool:
		withdraw_calls += 1
		last_withdraw_amount = amount
		return true

func test_shop_calls_banking_service() -> void:
	var shop = ShopService.new()
	var mock_banking = MockBankingService.new()
	
	shop.set_banking_service(mock_banking)
	
	var success = shop.purchase_item(1, 100)
	
	assert_bool(success).is_true()
	assert_int(mock_banking.withdraw_calls).is_equal(1)
	assert_int(mock_banking.last_withdraw_amount).is_equal(100)
```

### Integration Testing

**Test service interactions:**

```gdscript
# tests/services/test_banking_stat_integration.gd
class_name TestBankingStatIntegration
extends GdUnitTestSuite

func test_stat_changes_affect_banking_limits() -> void:
	# Setup both services
	var banking = BankingService.new()
	var stat = StatService.new()
	
	banking._ready()
	stat._ready()
	
	# In real scenario, banking would query stat for limits
	var max_balance = stat.get_max_balance_for_level(stat.get_player_level())
	
	banking.set_max_balance(max_balance)
	banking.add_funds(50)
	
	assert_int(banking.get_balance()).is_equal(50)

func test_services_share_state_correctly() -> void:
	# Ensure services don't override each other's state
	var banking = BankingService.new()
	var recycler = RecyclerService.new()
	
	banking._ready()
	recycler._ready()
	
	banking.add_funds(100)
	recycler.acquire_pool_item()
	
	assert_int(banking.get_balance()).is_equal(100)
	assert_bool(recycler.has_available_items()).is_true()
```

### Test Doubles and Stubs

**Stub pattern - minimal service**

```gdscript
# Test stub for services not yet implemented
class StubAnalyticsService:
	extends Node
	class_name StubAnalyticsService
	
	var tracked_events: Array = []
	
	func track_event(event_name: String, metadata: Dictionary = {}) -> void:
		tracked_events.append({
			"name": event_name,
			"data": metadata,
			"time": Time.get_ticks_msec()
		})
	
	func get_event_count() -> int:
		return tracked_events.size()
	
	func clear_events() -> void:
		tracked_events.clear()

# Usage in tests
var analytics = StubAnalyticsService.new()
var service = MyServiceThatUsesAnalytics.new()
service.set_analytics_service(analytics)

# Test that service logs correct events
service.perform_action()
assert_int(analytics.get_event_count()).is_equal(1)
```

### Service Isolation Techniques

**Isolate service under test:**

```gdscript
# tests/services/test_stat_service_isolated.gd
class_name TestStatServiceIsolated
extends GdUnitTestSuite

var test_service: StatService

func before_each() -> void:
	test_service = StatService.new()
	# Don't call _ready() - manually init what you need
	test_service._initialize_defaults()

func after_each() -> void:
	test_service.queue_free()

func test_stat_modification_in_isolation() -> void:
	test_service.set_health(100)
	test_service.take_damage(30)
	
	assert_int(test_service.get_health()).is_equal(70)
	# Only testing StatService logic, no dependencies

func test_validate_state_after_extreme_values() -> void:
	test_service.set_health(-999)
	var errors = test_service.validate_state()
	
	assert_bool(errors.is_empty()).is_false()
	assert_string(errors[0]).contains("negative")
```

---

## API Design Patterns

### Naming Conventions

**Method prefix conventions (Godot standard):**

| Prefix | Use Case | Example | Complexity | When Used |
|--------|----------|---------|-----------|-----------|
| `get_` | Simple property access | `get_balance()` | O(1) | Data stored in memory, immediate retrieval |
| `fetch_` | Complex retrieval | `fetch_equipped_items()` | O(n) | Multiple lookups or filtering required |
| `retrieve_` | Remote/external fetch | `retrieve_save_file()` | High | Network, disk, or 3rd party API calls |
| `calculate_` | Computed values | `calculate_total_damage()` | O(n) or O(nÂ²) | Requires computation from multiple sources |
| `is_` / `can_` | Boolean checks | `is_alive()`, `can_afford()` | O(1) | Simple state checks |
| `has_` | Presence check | `has_item(id)` | O(n) | Checking for membership in collection |

**Consistent naming:**

```gdscript
# Good: Clear intent from method name
func get_balance() -> int:
	return _balance

func fetch_inventory_items() -> Array:
	# Filter and sort - suggests complexity
	return _inventory.filter(func(item): return item.visible).sort()

func calculate_total_damage() -> float:
	# Aggregates from multiple sources
	return _base_damage + _weapon_bonus + _buff_modifier

func is_player_alive() -> bool:
	return _health > 0

func can_afford_item(price: int) -> bool:
	return _balance >= price

# Bad: Inconsistent, unclear intent
func balance() -> int:
	pass

func get_items() -> Array:
	# Too vague - is it filtered? Why get vs fetch?
	pass

func damage() -> float:
	# Unclear if it's a getter or calculator
	pass
```

### Return Types - Dictionary vs Custom Resources

**When to use Dictionary:**

```gdscript
# For simple, loosely-typed data
func get_player_stats() -> Dictionary:
	return {
		"level": 10,
		"experience": 5000,
		"skills": ["fireball", "heal"],
	}

# Usage accepts any dictionary
var stats = get_player_stats()
```

**When to use Custom Resource:**

```gdscript
# For structured, typed data with validation
class_name PlayerStats
extends Resource

@export var level: int = 1
@export var experience: int = 0
@export var skills: Array[String] = []

func validate() -> bool:
	return level > 0 and experience >= 0

func save_to_file(path: String) -> bool:
	if not validate():
		return false
	return ResourceSaver.save(self, path) == OK

# Usage - type-safe
var stats: PlayerStats = load("res://data/player.tres")
stats.level = 20
```

**Decision matrix:**

| Data Type | Use Dictionary | Use Resource |
|-----------|---|---|
| Simple config (< 5 fields) | âœ“ |  |
| Needs persistence to .tres | | âœ“ |
| Needs validation | | âœ“ |
| Passed to many functions | âœ“ |  |
| Returned from API (stable) | | âœ“ |
| Temporary computed data | âœ“ |  |
| Serialization required | | âœ“ |

### Error Handling Patterns

**Pattern 1: Return bool + signal**

```gdscript
# services/banking_service.gd
signal insufficient_funds(requested: int, available: int)

func withdraw_funds(amount: int) -> bool:
	if amount > _balance:
		insufficient_funds.emit(amount, _balance)
		return false
	
	_balance -= amount
	return true

# Usage
if not BankingService.withdraw_funds(100):
	# Handle error
	print("Transaction failed")
```

**Pattern 2: Return error type enum**

```gdscript
enum SaveError {
	OK,
	FILE_NOT_FOUND,
	INVALID_DATA,
	PERMISSION_DENIED,
}

func save_game(path: String) -> SaveError:
	if not _state.validate():
		return SaveError.INVALID_DATA
	
	var error = ResourceSaver.save(_state, path)
	if error != OK:
		return SaveError.PERMISSION_DENIED
	
	return SaveError.OK

# Usage with match
var result = SaveManager.save_game("user://save1.tres")
match result:
	SaveError.OK:
		print("Saved!")
	SaveError.INVALID_DATA:
		print("State corrupted")
	SaveError.PERMISSION_DENIED:
		print("Cannot write to disk")
```

**Pattern 3: Result type (Either pattern)**

```gdscript
# utils/result.gd
class_name Result

class Success:
	var value: Variant
	
	func _init(val: Variant) -> void:
		value = val

class Error:
	var error_message: String
	
	func _init(msg: String) -> void:
		error_message = msg

static func ok(value: Variant) -> Result:
	return Success.new(value)

static func err(message: String) -> Result:
	return Error.new(message)

# services/shop_service.gd
func purchase_item(item_id: int) -> Result:
	var price = _get_item_price(item_id)
	
	if not BankingService.can_afford(price):
		return Result.err("Insufficient funds")
	
	if not _item_exists(item_id):
		return Result.err("Item not found")
	
	BankingService.withdraw_funds(price)
	return Result.ok({"item_id": item_id})

# Usage - type-safe error handling
var result = ShopService.purchase_item(123)
if result is Result.Success:
	print("Purchased: ", result.value)
elif result is Result.Error:
	print("Failed: ", result.error_message)
```

### Async Patterns with Await

**Pattern: Async operations with signals**

```gdscript
# services/save_manager.gd
signal save_completed(success: bool)
signal save_progress(percent: float)

func save_game_async(path: String) -> void:
	await _async_save(path)

func _async_save(path: String) -> void:
	save_progress.emit(0.0)
	
	await get_tree().process_frame
	
	# Simulate async work (in reality: file I/O, network)
	for i in range(1, 11):
		await get_tree().create_timer(0.1).timeout
		save_progress.emit(i * 10.0)
	
	save_completed.emit(true)

# Usage
func _ready() -> void:
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.save_game_async("user://game.save")

func _on_save_completed(success: bool) -> void:
	print("Save operation %s" % ("succeeded" if success else "failed"))
```

**Pattern: Await without signals (using Timer)**

```gdscript
func load_level_async(level_id: int) -> void:
	print("Loading level...")
	
	await get_tree().create_timer(2.0).timeout  # Simulate loading
	
	_load_level(level_id)
	print("Level loaded!")

# Usage in main flow
func _ready() -> void:
	await load_level_async(1)
	# Continues only after level is loaded
	print("Ready to play")
```

---

## Dependency Injection

### Constructor Injection vs Setter Injection

**Setter Injection (Godot-friendly):**

```gdscript
# services/shop_service.gd
extends Node
class_name ShopService

var _banking_service: BankingService = null
var _stat_service: StatService = null

func set_banking_service(service: BankingService) -> void:
	_banking_service = service

func set_stat_service(service: StatService) -> void:
	_stat_service = service

func _ready() -> void:
	# Fallback if not injected
	if not _banking_service:
		_banking_service = ServiceRegistry.get_service("BankingService")
	if not _stat_service:
		_stat_service = ServiceRegistry.get_service("StatService")

# Advantages for Godot:
# - Compatible with autoload
# - Easy to test (inject mocks)
# - Graceful fallback
```

**Constructor Injection (less common in Godot):**

```gdscript
# Only for non-autoload services
class_name PurchaseHandler

var _banking_service: BankingService
var _shop_service: ShopService

func _init(banking: BankingService, shop: ShopService) -> void:
	_banking_service = banking
	_shop_service = shop

# Usage
var handler = PurchaseHandler.new(
	ServiceRegistry.get_service("BankingService"),
	ServiceRegistry.get_service("ShopService")
)

# Disadvantages for autoload services:
# - Can't be called from _ready automatically
# - Complicates Godot's node lifecycle
```

### Service Locator Pattern Implementation

**Improved service registry:**

```gdscript
# services/service_locator.gd
extends Node
class_name ServiceLocator

static var _instance: ServiceLocator
static var _services: Dictionary = {}
static var _interfaces: Dictionary = {}

static func _get_instance() -> ServiceLocator:
	if not _instance:
		_instance = ServiceLocator.new()
		_instance.name = "ServiceLocator"
	return _instance

static func register(service_key: String, service: Node) -> void:
	_services[service_key] = service
	push_warning("Registered service: %s" % service_key)

static func get_service(service_key: String) -> Variant:
	if not service_key in _services:
		push_error("Service not found: %s" % service_key)
		return null
	return _services[service_key]

static func register_interface(interface_name: String, implementation: Node) -> void:
	_interfaces[interface_name] = implementation

static func get_interface(interface_name: String) -> Variant:
	if not interface_name in _interfaces:
		push_error("Interface not found: %s" % interface_name)
		return null
	return _interfaces[interface_name]

static func unregister(service_key: String) -> void:
	_services.erase(service_key)

static func clear_all() -> void:
	_services.clear()
	_interfaces.clear()

static func debug_print_services() -> void:
	print("=== Registered Services ===")
	for key in _services:
		print("  - %s: %s" % [key, _services[key].get_class()])
	print("=== Registered Interfaces ===")
	for key in _interfaces:
		print("  - %s: %s" % [key, _interfaces[key].get_class()])
```

### Testing with Dependency Injection

**Test setup with injected services:**

```gdscript
# tests/services/test_with_di.gd
class_name TestWithDependencyInjection
extends GdUnitTestSuite

var test_banking: BankingService
var test_shop: ShopService
var mock_stat: MockStatService

func before_each() -> void:
	test_banking = BankingService.new()
	test_banking._ready()
	
	mock_stat = MockStatService.new()
	
	test_shop = ShopService.new()
	test_shop.set_banking_service(test_banking)
	test_shop.set_stat_service(mock_stat)
	test_shop._ready()

func test_purchase_with_injected_mocks() -> void:
	test_banking.add_funds(500)
	mock_stat.set_player_level(5)
	
	var success = test_shop.purchase_premium_item(100)
	
	assert_bool(success).is_true()
	assert_int(test_banking.get_balance()).is_equal(400)
```

---

## Common Service Anti-Patterns

### God Services (Too Much Responsibility)

**Anti-pattern: Service does everything**

```gdscript
# BAD: GameService is a god object
extends Node
class_name GameService

func handle_player_input() -> void: pass
func update_physics() -> void: pass
func manage_inventory() -> void: pass
func handle_combat() -> void: pass
func manage_save_files() -> void: pass
func run_ui_logic() -> void: pass
func manage_audio() -> void: pass
func spawn_enemies() -> void: pass
func handle_networking() -> void: pass
# 50 more methods...

# Problems:
# - Tests are huge and fragile
# - Impossible to reuse in different projects
# - Changes cascade everywhere
# - Concurrency issues (one service doing everything)
```

**Solution: Separate concerns**

```gdscript
# GOOD: Single responsibility
extends Node
class_name InventoryService

@export var max_items: int = 20
var _items: Array[InventoryItem] = []

signal item_added(item: InventoryItem)
signal item_removed(item: InventoryItem)

func add_item(item: InventoryItem) -> bool:
	if _items.size() >= max_items:
		return false
	
	_items.append(item)
	item_added.emit(item)
	return true

func remove_item(item: InventoryItem) -> bool:
	var index = _items.find(item)
	if index == -1:
		return false
	
	_items.remove_at(index)
	item_removed.emit(item)
	return true

func get_items_by_type(type: String) -> Array:
	return _items.filter(func(item): return item.type == type)

# Each service: < 200 lines, single purpose
```

**Refactoring checklist:**
- Does service name include "Manager" or "Controller"? (red flag)
- Does service handle multiple unrelated domains?
- Are tests > 500 lines?
- Can you describe service purpose in one sentence?

### Chatty Services (Too Many Calls)

**Anti-pattern: Excessive back-and-forth**

```gdscript
# BAD: Client makes 10 calls for one logical operation
var item = ShopService.get_item(item_id)
var price = ShopService.get_item_price(item_id)
var description = ShopService.get_item_description(item_id)
var icon = ShopService.get_item_icon(item_id)
var tags = ShopService.get_item_tags(item_id)
var level_req = ShopService.get_item_level_requirement(item_id)
var is_available = ShopService.is_item_available(item_id)
var stock = ShopService.get_item_stock(item_id)

# Performance issue: 8 separate lookups
# Coupling issue: Client knows all these details
```

**Solution: Aggregate data**

```gdscript
# GOOD: One call for complete item data
class ItemData:
	var id: int
	var name: String
	var price: int
	var description: String
	var icon_path: String
	var tags: Array[String]
	var level_requirement: int
	var available: bool
	var stock: int

func get_item_data(item_id: int) -> ItemData:
	# All lookups happen inside service
	var item = ItemData.new()
	item.id = item_id
	item.name = _get_item_name(item_id)
	item.price = _get_item_price(item_id)
	# ... all fields loaded in one call
	return item

# Usage: One call, all data
var item_data = ShopService.get_item_data(item_id)
```

### Service Leakage (Exposing Implementation)

**Anti-pattern: Service exposes internal structure**

```gdscript
# BAD: Client knows about internal dict structure
var items = InventoryService.get_items_dict()
for key in items:
	var item = items[key]
	print(item["_internal_id"], item["_quantity"])

# Problems:
# - Client code breaks if we refactor internals
# - Hard to add validation or logging
# - Impossible to make thread-safe
```

**Solution: Encapsulate internals**

```gdscript
# GOOD: Service controls access
class InventoryService:
	var _items: Dictionary = {}
	
	func get_items() -> Array:
		# Return safe copy, not internal dict
		return _items.values()
	
	func get_item_quantity(item_id: int) -> int:
		var item = _items.get(item_id)
		return item.quantity if item else 0
	
	func add_quantity(item_id: int, amount: int) -> bool:
		if item_id not in _items:
			return false
		
		_items[item_id].quantity += amount
		return true

# Client only knows public interface
var items = InventoryService.get_items()
for item in items:
	print(item.name, ": ", InventoryService.get_item_quantity(item.id))
```

### State Synchronization Issues

**Anti-pattern: Multiple services with conflicting state**

```gdscript
# BAD: BankingService and UIService have separate balance copies
# They fall out of sync after some operations

extends Node
class_name UIService

var _displayed_balance: int = 0  # Stale copy!

func _ready() -> void:
	# Connected once, might miss updates
	BankingService.balance_changed.connect(_on_balance_updated)
	_on_balance_updated(BankingService.get_balance())

func _on_balance_updated(balance: int) -> void:
	_displayed_balance = balance

# Problem: If UI service disconnects/reloads, no updates
# Multiple truth sources lead to bugs
```

**Solution: Single source of truth**

```gdscript
# GOOD: UI queries service state on demand
extends Control
class_name UIService

@onready var balance_label: Label = $BalanceLabel

func _ready() -> void:
	BankingService.balance_changed.connect(_on_balance_changed)
	_update_display()

func _on_balance_changed(_balance: int) -> void:
	_update_display()

func _update_display() -> void:
	# Always read from source of truth
	balance_label.text = "$ %d" % BankingService.get_balance()

# If service state changes, UI is always consistent
# No stale data, no sync issues
```

---

## Enforceable Patterns

Enforce these patterns via pre-commit hooks and CI/CD scripts.

### Service Naming Convention

**Pattern Rule:** Service files must be named `*_service.gd` and extend `Node`.

**Python validator:**

```python
#!/usr/bin/env python3
import os
import re
import sys

def check_service_naming():
	errors = []
	services_dir = "res://services"
	
	if not os.path.exists(services_dir):
		return True
	
	for filename in os.listdir(services_dir):
		if not filename.endswith(".gd"):
			continue
		
		# Check naming convention
		if not re.match(r"^[a-z_]+_service\.gd$", filename):
			errors.append(f"Service file not named *_service.gd: {filename}")
		
		# Check extends Node
		filepath = os.path.join(services_dir, filename)
		with open(filepath, 'r') as f:
			content = f.read(500)
			if "extends Node" not in content:
				errors.append(f"Service {filename} doesn't extend Node")
	
	if errors:
		print("\n".join(errors))
		return False
	
	return True

if __name__ == "__main__":
	sys.exit(0 if check_service_naming() else 1)
```

### No Direct Autoload References

**Pattern Rule:** Don't reference autoload singletons directly. Use ServiceRegistry.

**Regex detector:**

```python
#!/usr/bin/env python3
import re
import sys

# These are acceptable references
ALLOWED_AUTLOADS = {"ServiceRegistry", "EventBus"}

BAD_PATTERNS = [
	r"\bBankingService\.",
	r"\bStatService\.",
	r"\bRecyclerService\.",
	r"\bShopRerollService\.",
]

def check_no_autoload_references(filepath):
	if not filepath.endswith(".gd"):
		return True
	
	with open(filepath, 'r') as f:
		content = f.read()
	
	errors = []
	
	for pattern in BAD_PATTERNS:
		matches = re.finditer(pattern, content)
		for match in matches:
			line_num = content[:match.start()].count('\n') + 1
			errors.append(f"{filepath}:{line_num} - Direct autoload reference: {match.group(0)}")
	
	if errors:
		for error in errors:
			print(error)
		return False
	
	return True

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Usage: check_autoload.py <filepath>")
		sys.exit(1)
	
	success = check_no_autoload_references(sys.argv[1])
	sys.exit(0 if success else 1)
```

### Service Size Limit

**Pattern Rule:** Service files should not exceed 500 lines (excluding tests).

**Severity:** WARNING for 500-700 lines, ERROR for 700+.

```python
#!/usr/bin/env python3
import sys

def check_service_size(filepath):
	if not filepath.endswith("_service.gd") or "test" in filepath:
		return True, None
	
	with open(filepath, 'r') as f:
		lines = f.readlines()
	
	line_count = len(lines)
	
	if line_count > 700:
		return False, f"ERROR: {filepath} is {line_count} lines (max 700)"
	elif line_count > 500:
		return True, f"WARNING: {filepath} is {line_count} lines (recommend < 500)"
	
	return True, None

if __name__ == "__main__":
	if len(sys.argv) < 2:
		sys.exit(1)
	
	success, message = check_service_size(sys.argv[1])
	
	if message:
		print(message)
	
	sys.exit(0 if success else 1)
```

### Enforce Signal Naming

**Pattern Rule:** Service signals must use past tense and follow `*_started` / `*_finished` pattern for processes.

```python
#!/usr/bin/env python3
import re
import sys

def check_signal_names(filepath):
	if not filepath.endswith("_service.gd"):
		return True
	
	with open(filepath, 'r') as f:
		content = f.read()
	
	# Find all signal declarations
	signal_pattern = r"signal\s+(\w+)"
	signals = re.findall(signal_pattern, content)
	
	errors = []
	
	for signal_name in signals:
		# Check if uses present tense (bad)
		if re.match(r"^(add|update|set|remove|load|save|initialize)_", signal_name):
			errors.append(f"Signal '{signal_name}' uses present tense (should be past: {signal_name}d)")
		
		# Check process signals follow pattern
		if "_started" in signal_name or "_finished" in signal_name:
			continue  # Good pattern
		
		# All other signals should be past tense
		if not re.match(r"^.*([aeiou]d|ed)$", signal_name):
			# Allow some specific names
			if signal_name not in ["updated", "changed", "cleared", "processed"]:
				errors.append(f"Signal '{signal_name}' might not follow past-tense convention")
	
	if errors:
		for error in errors:
			print(f"{filepath}: {error}")
		return False
	
	return True

if __name__ == "__main__":
	if len(sys.argv) < 2:
		sys.exit(1)
	
	success = check_signal_names(sys.argv[1])
	sys.exit(0 if success else 1)
```

### Validate State Methods

**Pattern Rule:** Services with persistent state should have `validate_state()` and `reset_game_state()` methods.

```python
#!/usr/bin/env python3
import re
import sys

def check_state_management(filepath):
	if not filepath.endswith("_service.gd") or "test" in filepath:
		return True
	
	with open(filepath, 'r') as f:
		content = f.read()
	
	# Services with @export vars (persistent state)
	has_export = "@export" in content
	
	if not has_export:
		return True  # No persistent state
	
	# Check for validation method
	has_validate = "func validate_state" in content or "func _validate_state" in content
	
	# Check for reset method
	has_reset = "func reset_game_state" in content or "func _reset_game_state" in content or "func reset(" in content
	
	errors = []
	
	if not has_validate:
		errors.append(f"Service with @export state must have validate_state() method")
	
	if not has_reset:
		errors.append(f"Service with @export state must have reset_game_state() method")
	
	if errors:
		for error in errors:
			print(f"{filepath}: {error}")
		return False
	
	return True

if __name__ == "__main__":
	if len(sys.argv) < 2:
		sys.exit(1)
	
	success = check_state_management(sys.argv[1])
	sys.exit(0 if success else 1)
```

### Pre-commit Hook Installation

**.git/hooks/pre-commit**

```bash
#!/bin/bash

PYTHON_SCRIPTS=(
	"scripts/check_service_naming.py"
	"scripts/check_no_autoload_refs.py"
	"scripts/check_service_size.py"
	"scripts/check_signal_names.py"
	"scripts/check_state_management.py"
)

ERROR_COUNT=0

for file in $(git diff --cached --name-only); do
	if [[ $file == *.gd ]]; then
		for script in "${PYTHON_SCRIPTS[@]}"; do
			if ! python3 "$script" "$file"; then
				((ERROR_COUNT++))
			fi
		done
	fi
done

if [ $ERROR_COUNT -gt 0 ]; then
	echo "Pre-commit checks failed: $ERROR_COUNT error(s)"
	exit 1
fi

exit 0
```

---

## Quick Reference

### Service Lifecycle Quick Start

| Phase | Method | Purpose | Node in Tree |
|-------|--------|---------|--------------|
| Definition | Class declaration | Define service class | No |
| Registration | Project Settings > AutoLoad | Add to game | No |
| Loading | Engine initialization | Godot creates instance | Yes (root) |
| Ready | `_ready()` | Initialize, fetch deps | Yes (root) |
| Runtime | Methods/signals | Normal operation | Yes (root) |
| Shutdown | `shutdown()` | Cleanup | Yes â†’ No |

### Service Communication Decision Tree

```
Do you need immediate response?
â”œâ”€ YES â†’ Direct method call
â”‚   â”œâ”€ Needs error handling? â†’ Return bool/enum
â”‚   â””â”€ Result required? â†’ Return value/Result type
â”‚
â””â”€ NO â†’ Use signal
    â”œâ”€ Cross-service event? â†’ EventBus signal
    â”œâ”€ Service-specific? â†’ Service signal
    â””â”€ Async operation? â†’ Signal + await
```

### API Naming Quick Reference

| Operation | Method Name | Example | Return Type |
|-----------|------------|---------|-------------|
| Access property | `get_*` | `get_balance()` | Direct value |
| Find/search | `find_*` or `get_*` | `find_item(name)` | Item or null |
| Fetch remote | `fetch_*` | `fetch_user_data()` | Promise/Signal |
| Retrieve/load | `retrieve_*` | `retrieve_save()` | Resource |
| Compute value | `calculate_*` | `calculate_damage()` | Computed value |
| Check state | `is_*`, `can_*`, `has_*` | `is_alive()` | bool |
| Modify state | `set_*`, `add_*` | `add_funds()` | bool (success) |

### Testing Checklist

- [ ] Unit tests for all public methods
- [ ] Integration tests for service dependencies
- [ ] Mocks for external services
- [ ] State validation tests
- [ ] Error path tests
- [ ] Signal connection tests (await signals)
- [ ] Serialization/deserialization tests
- [ ] Isolation tests (no real dependencies)

### Common Patterns Summary

| Problem | Pattern | Location |
|---------|---------|----------|
| Managing initialization order | Service registry + lookup | Base initialization |
| Broadcasting events | Event bus (signals) | Autoload singleton |
| Complex state | Resource-based save system | SaveSystem service |
| Dependency management | Setter injection + fallback | Service `_ready()` |
| Error handling | Return enum + signal | Service methods |
| Async operations | Signal + await | Dedicated async methods |
| Testing services | Mock + dependency injection | Test setup |
| Preventing god objects | Single responsibility | Architecture review |
| Avoiding circular deps | Event bus or registry | Design phase |

---

## Godot Documentation References

- [AutoLoad / Singletons](https://docs.godotengine.org/en/stable/tutorials/misc/autoload.html)
- [Signals](https://docs.godotengine.org/en/stable/tutorials/inputs/signals.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/style_guide.html)
- [Saving/Loading](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
- [Resources](https://docs.godotengine.org/en/stable/tutorials/io/using_3d_characters/using_3d_characters.html)

**Tools Referenced:**
- GdUnit4: https://github.com/MikeSchulze/gdUnit4
- Pre-commit Framework: https://pre-commit.com/

---

## Example: Complete Service Implementation

```gdscript
# services/shop_service.gd
extends Node
class_name ShopService

# Dependencies (injected or auto-loaded)
var _banking_service: BankingService
var _stat_service: StatService

# Signals
signal purchase_successful(item_id: int, price: int)
signal purchase_failed(item_id: int, reason: String)

# Persistent state
@export var reroll_count: int = 0
@export var available_items: Array[int] = []

# Runtime state (not serialized)
var _is_initialized: bool = false

signal initialized


func _ready() -> void:
	# Dependency injection - order-independent
	_banking_service = ServiceRegistry.get_service("BankingService")
	_stat_service = ServiceRegistry.get_service("StatService")
	
	if not _banking_service or not _stat_service:
		push_error("ShopService: Required services unavailable")
		return
	
	_initialize()


func _initialize() -> void:
	# Load shop data
	available_items = [1, 2, 5, 7]  # Item IDs
	_is_initialized = true
	initialized.emit()


func purchase_item(item_id: int) -> bool:
	if not _is_initialized:
		purchase_failed.emit(item_id, "Service not ready")
		return false
	
	if item_id not in available_items:
		purchase_failed.emit(item_id, "Item not available")
		return false
	
	var price = _get_item_price(item_id)
	var level_req = _get_item_level_requirement(item_id)
	
	# Validate purchase conditions
	if _stat_service.get_player_level() < level_req:
		purchase_failed.emit(item_id, "Level requirement not met")
		return false
	
	# Attempt transaction
	if not _banking_service.withdraw_funds(price):
		purchase_failed.emit(item_id, "Insufficient funds")
		return false
	
	purchase_successful.emit(item_id, price)
	return true


func get_item_data(item_id: int) -> Dictionary:
	if item_id not in available_items:
		return {}
	
	return {
		"id": item_id,
		"price": _get_item_price(item_id),
		"level_req": _get_item_level_requirement(item_id),
	}


func validate_state() -> Array[String]:
	var errors: Array[String] = []
	
	if reroll_count < 0:
		errors.append("Negative reroll count")
	
	for item_id in available_items:
		if item_id <= 0:
			errors.append("Invalid item ID in available_items")
	
	return errors


func reset_game_state() -> void:
	reroll_count = 0
	available_items = [1, 2, 5, 7]


func _get_item_price(item_id: int) -> int:
	match item_id:
		1: return 100
		2: return 200
		5: return 500
		7: return 1000
		_: return 0


func _get_item_level_requirement(item_id: int) -> int:
	match item_id:
		1: return 1
		2: return 3
		5: return 5
		7: return 10
		_: return 0
```

This markdown file provides production-ready patterns for senior developers. All code examples are specific to Godot 4.5.1 GDScript and designed for scalable, testable service architecture.
