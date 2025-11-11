# GDScript Testing Patterns with GUT Framework
## Comprehensive Guide for Godot 4.5.1 Projects

---

## Table of Contents
1. [GUT Framework Fundamentals](#gut-framework-fundamentals)
2. [Test Structure & Lifecycle](#test-structure--lifecycle)
3. [Assertions Quick Reference](#assertions-quick-reference)
4. [Test Doubles: Stubs, Spies, and Mocks](#test-doubles-stubs-spies-and-mocks)
5. [Testing Autoload Services](#testing-autoload-services)
6. [Testing Scene-Based Systems](#testing-scene-based-systems)
7. [Testing UI Components](#testing-ui-components)
8. [Integration Testing Patterns](#integration-testing-patterns)
9. [Async & Signal Testing](#async--signal-testing)
10. [Test Organization & Structure](#test-organization--structure)
11. [Common Anti-Patterns & Fixes](#common-anti-patterns--fixes)
12. [Enforceable Patterns](#enforceable-patterns)
13. [Coverage & Performance](#coverage--performance)

---

## GUT Framework Fundamentals

### What is GUT?

GUT (Godot Unit Test) is a native GDScript testing framework for Godot 4.x that enables writing and running tests entirely within GDScript without C++ compilation. It integrates directly into the Godot editor and supports headless execution for CI/CD pipelines.

**Key Features:**
- Simple test syntax with familiar lifecycle hooks
- Comprehensive assertion library
- Test doubles (stubs, spies, mocks, partials)
- Parameterized tests
- Signal and async testing
- JUnit XML export for CI/CD
- Memory management utilities

### Installation (Godot 4.5.1)

1. Download GUT 9.5.0+ from Asset Library or [github.com/bitwes/Gut](https://github.com/bitwes/Gut)
2. Extract `addons/gut` folder into your project
3. Enable the plugin in Project Settings > Plugins
4. Restart Godot

### Running Tests

```gdscript
# From editor: GUT panel (Window > GUT)
# From CLI (headless):
godot --headless -s addons/gut/run_tests.gd -d

# CI/CD (GitHub Actions):
- run: godot --headless -s addons/gut/run_tests.gd
```

### Log Files for Debugging

**IMPORTANT**: When debugging gameplay issues, always check these log locations:

**Game Runtime Logs (macOS):**
```bash
# Application logs (GameLogger output)
~/Library/Application Support/Godot/app_userdata/Scrap Survivor/logs/scrap_survivor_YYYY-MM-DD.log

# Godot engine logs (print() statements)
~/Library/Application Support/Godot/app_userdata/Scrap Survivor/logs/godot.log
~/Library/Application Support/Godot/app_userdata/Scrap Survivor/logs/godotYYYY-MM-DDTHH.MM.SS.log
```

**Viewing Logs:**
```bash
# Latest game log
tail -100 ~/Library/Application\ Support/Godot/app_userdata/Scrap\ Survivor/logs/scrap_survivor_$(date +%Y-%m-%d).log

# Latest Godot engine log
tail -100 ~/Library/Application\ Support/Godot/app_userdata/Scrap\ Survivor/logs/godot.log

# Watch logs in real-time (run before starting game)
tail -f ~/Library/Application\ Support/Godot/app_userdata/Scrap\ Survivor/logs/godot.log
```

**Linux:**
```bash
~/.local/share/godot/app_userdata/Scrap Survivor/logs/
```

**Windows:**
```
%APPDATA%\Godot\app_userdata\Scrap Survivor\logs\
```

**Test Logs:**
- Headless test output: `test_run.log` (project root)
- Test results: `test_results.xml` (project root)

---

## Test Structure & Lifecycle

### Basic Test File Structure

```gdscript
# tests/services/banking_service_test.gd
extends GutTest

class_name BankingServiceTest

# Optional: Single-file fixture setup
var banking_service: BankingService
var player_data: Dictionary

# ============================================================================
# LIFECYCLE HOOKS
# ============================================================================

# Called once before ALL tests in this file
func before_all() -> void:
    # Heavy setup: Load resources, initialize singletons
    pass

# Called before EACH test
func before_each() -> void:
    # Reset state, create fresh test instances
    banking_service = BankingService.new()
    player_data = {
        "coins": 1000,
        "gems": 50
    }

# Called after EACH test
func after_each() -> void:
    # Clean up: Free nodes, disconnect signals
    if banking_service:
        banking_service.queue_free()

# Called once after ALL tests
func after_all() -> void:
    # Final cleanup
    pass

# ============================================================================
# TEST METHODS (MUST START WITH test_)
# ============================================================================

func test_player_gains_coins_from_reward() -> void:
    var initial_coins = player_data["coins"]
    banking_service.add_coins(100)
    
    assert_eq(banking_service.get_balance(), initial_coins + 100, 
              "Balance should increase by reward amount")

func test_insufficient_funds_prevents_purchase() -> void:
    var initial_coins = 50
    player_data["coins"] = initial_coins
    
    var purchase_success = banking_service.try_spend(100)
    
    assert_false(purchase_success, "Purchase should fail with insufficient coins")
    assert_eq(banking_service.get_balance(), initial_coins,
              "Balance unchanged after failed purchase")
```

### Lifecycle Execution Order

```
1. before_all()      â† Runs once, before all tests
2. before_each()     â† Runs before test 1
3. test_first()
4. after_each()
5. before_each()     â† Runs before test 2
6. test_second()
7. after_each()
... (repeat for each test)
8. after_all()       â† Runs once, after all tests
```

**Important:** Use `before_each()` and `after_each()` for test isolation. Only use `before_all()`/`after_all()` for expensive one-time setup.

---

## Assertions Quick Reference

| Assertion | Example | Purpose |
|-----------|---------|---------|
| `assert_eq` | `assert_eq(actual, expected, "msg")` | Value equality |
| `assert_ne` | `assert_ne(actual, unexpected, "msg")` | Value inequality |
| `assert_true` | `assert_true(condition, "msg")` | Boolean true |
| `assert_false` | `assert_false(condition, "msg")` | Boolean false |
| `assert_null` | `assert_null(value, "msg")` | Is null |
| `assert_not_null` | `assert_not_null(value, "msg")` | Not null |
| `assert_almost_eq` | `assert_almost_eq(actual, expected, tolerance)` | Floating-point |
| `assert_array_eq` | `assert_array_eq(actual, expected)` | Array contents |
| `assert_has` | `assert_has(container, item, "msg")` | Array/dict contains |
| `assert_does_not_have` | `assert_does_not_have(container, item)` | Array/dict missing |
| `assert_is_instance_of` | `assert_is_instance_of(obj, ClassName)` | Type check |
| `pass_test` | `pass_test("reason")` | Force pass (debugging) |
| `fail_test` | `fail_test("reason")` | Force fail (debugging) |

### Assertion Examples

```gdscript
func test_assertions_demo() -> void:
    var player_level = 5
    var inventory = ["sword", "shield", "potion"]
    var position = Vector2(10.5, 20.3)
    
    assert_eq(player_level, 5)
    assert_true(player_level > 0)
    assert_has(inventory, "sword", "Inventory should contain sword")
    assert_almost_eq(position.x, 10.5, 0.01)
    assert_is_instance_of(inventory, Array)
    
    # Custom failure message
    assert_ne(player_level, 1, 
              "Player level should not be 1. Current: %s" % player_level)
```

---

## Test Doubles: Stubs, Spies, and Mocks

Test doubles replace real dependencies, isolating the code under test.

### Stub vs Spy vs Mock

| Type | Purpose | Verifies | State |
|------|---------|----------|-------|
| **Stub** | Return preset values | Input/indirect input | Configured values |
| **Spy** | Record method calls | How methods called | Call history |
| **Mock** | Full replacement | Expectations before test | Pre-configured behavior |
| **Partial** | Keep real code | Some methods stubbed | Mix of real + fake |

### Creating Test Doubles

```gdscript
# tests/doubles/payment_processor_test.gd
extends GutTest

# Path to the script you want to double
const PAYMENT_PROCESSOR_PATH = "res://services/payment_processor.gd"

func test_full_double() -> void:
    # Full double: all methods are stubbed out by default
    var processor_double = double(PAYMENT_PROCESSOR_PATH)
    
    # Stub a method to return a value
    processor_double.stub_with_args("process_payment", 
                                     [100], true)  # Returns true when called with 100
    
    var result = processor_double.process_payment(100)
    assert_true(result, "Stubbed method should return true")

func test_partial_double() -> void:
    # Partial double: keeps real code, only stub specific methods
    var processor_double = double(PAYMENT_PROCESSOR_PATH).partial()
    
    # This method keeps its real implementation
    var validation_result = processor_double.validate_payment(150)
    
    # This method is stubbed
    processor_double.stub_with_args("charge_card", 
                                     [150, "visa"], false)
    
    var charge_result = processor_double.charge_card(150, "visa")
    assert_false(charge_result, "Stubbed method should return false")
```

### Spy Pattern: Recording Calls

```gdscript
extends GutTest

const INVENTORY_PATH = "res://systems/inventory.gd"

func test_spy_on_inventory() -> void:
    var inventory_double = double(INVENTORY_PATH)
    
    # Call methods on the spy
    inventory_double.add_item("health_potion", 5)
    inventory_double.add_item("mana_potion", 3)
    inventory_double.add_item("health_potion", 2)
    
    # Verify the spy recorded calls correctly
    assert_call_count(inventory_double, "add_item", 3, 
                     msg="add_item should be called 3 times")
    
    # Verify specific parameter match
    assert_call_count(inventory_double, "add_item", 1, ["health_potion", 5],
                     msg="add_item called once with health_potion, 5")
    
    # Get exact call count programmatically
    var call_count = get_call_count(inventory_double, "add_item")
    assert_eq(call_count, 3)
```

### Stubbing Methods with Arguments

```gdscript
extends GutTest

const DATABASE_PATH = "res://services/database.gd"

func test_stub_with_different_returns() -> void:
    var db_double = double(DATABASE_PATH)
    
    # Stub different returns based on arguments
    db_double.stub_with_args("fetch_player", 
                             [1], 
                             {"id": 1, "name": "Alice"})
    
    db_double.stub_with_args("fetch_player", 
                             [2], 
                             {"id": 2, "name": "Bob"})
    
    db_double.stub_with_args("fetch_player", 
                             [999], 
                             null)  # Not found
    
    var player1 = db_double.fetch_player(1)
    var player2 = db_double.fetch_player(2)
    var not_found = db_double.fetch_player(999)
    
    assert_eq(player1.name, "Alice")
    assert_eq(player2.name, "Bob")
    assert_null(not_found)
```

### Stubbing to Call Real Method (Partial Pattern)

```gdscript
func test_stub_to_call_real_method() -> void:
    var service_double = double("res://services/calculation.gd").partial()
    
    # Only stub the expensive database call
    service_double.stub_with_args("query_database", [], [])
    
    # The real calculation logic still runs
    var result = service_double.calculate_total(100)
    
    # Database was called (spying)
    assert_called(service_double, "query_database")
```

---

## Testing Autoload Services

Autoload singletons require special handling: reset state between tests to prevent pollution.

### Service Structure

```gdscript
# services/banking_service.gd (Autoload Singleton)
extends Node

class_name BankingService

signal balance_changed(new_balance: int)

var _balance: int = 0

func _ready() -> void:
    if not is_in_group("services"):
        add_to_group("services")

func add_coins(amount: int) -> void:
    _balance += amount
    balance_changed.emit(_balance)

func try_spend(amount: int) -> bool:
    if _balance < amount:
        return false
    
    _balance -= amount
    balance_changed.emit(_balance)
    return true

func get_balance() -> int:
    return _balance

func reset() -> void:
    _balance = 0
```

### Testing Autoload Services

```gdscript
# tests/services/banking_service_test.gd
extends GutTest

# Important: reference the autoload by its name
var banking: BankingService

func before_each() -> void:
    # Get the autoload singleton
    banking = BankingService
    
    # CRITICAL: Reset state to prevent test pollution
    banking.reset()
    
    # Clear signal connections if needed
    for signal_name in banking.get_signal_list():
        for connection in banking.get_signal_connection_list(signal_name):
            banking.disconnect(signal_name, connection.callable)

func test_add_coins() -> void:
    banking.add_coins(50)
    assert_eq(banking.get_balance(), 50)

func test_balance_persists_across_calls() -> void:
    banking.add_coins(100)
    var first_balance = banking.get_balance()
    
    banking.add_coins(50)
    var second_balance = banking.get_balance()
    
    assert_eq(first_balance, 100)
    assert_eq(second_balance, 150)

func test_insufficient_funds() -> void:
    banking.add_coins(50)
    var success = banking.try_spend(100)
    
    assert_false(success)
    assert_eq(banking.get_balance(), 50, 
              "Balance unchanged when spending fails")
```

### Mocking Autoload Dependencies

```gdscript
# services/shop_service.gd (depends on BankingService)
extends Node

class_name ShopService

var banking: BankingService
var inventory: InventoryService

func _ready() -> void:
    banking = BankingService
    inventory = InventoryService

func buy_item(item_id: int, cost: int) -> bool:
    if not banking.try_spend(cost):
        return false
    
    inventory.add_item(item_id, 1)
    return true

func get_balance() -> int:
    return banking.get_balance()
```

```gdscript
# tests/services/shop_service_test.gd
extends GutTest

const SHOP_SERVICE_PATH = "res://services/shop_service.gd"
const BANKING_PATH = "res://services/banking_service.gd"
const INVENTORY_PATH = "res://services/inventory_service.gd"

var shop_double
var banking_double
var inventory_double

func before_each() -> void:
    # Create doubles for dependencies
    banking_double = double(BANKING_PATH)
    inventory_double = double(INVENTORY_PATH)
    
    # Configure stub behavior
    banking_double.stub_with_args("try_spend", [100], true)
    inventory_double.stub_with_args("add_item", [1, 1], null)

func test_buy_item_success() -> void:
    # Create shop with mocked dependencies
    shop_double = double(SHOP_SERVICE_PATH)
    
    # Inject mocked services (shop must expose them)
    shop_double.banking = banking_double
    shop_double.inventory = inventory_double
    
    var success = shop_double.buy_item(1, 100)
    
    assert_true(success, "Buy should succeed with sufficient funds")
    assert_called(banking_double, "try_spend", 
                 msg="Banking service should be consulted")
    assert_called(inventory_double, "add_item",
                 msg="Inventory should be updated")

func test_buy_item_insufficient_funds() -> void:
    # Reconfigure stub for this test
    banking_double.stub_with_args("try_spend", [500], false)
    
    shop_double = double(SHOP_SERVICE_PATH)
    shop_double.banking = banking_double
    shop_double.inventory = inventory_double
    
    var success = shop_double.buy_item(1, 500)
    
    assert_false(success)
    assert_not_called(inventory_double, "add_item",
                     msg="Inventory unchanged when purchase fails")
```

### Testing Signal Emissions

```gdscript
# tests/services/banking_service_test.gd
extends GutTest

var banking: BankingService

func before_each() -> void:
    banking = BankingService
    banking.reset()

func test_balance_changed_signal_emitted() -> void:
    # Watch the signal
    watch_signals(banking)
    
    banking.add_coins(100)
    
    # Verify signal was emitted
    assert_signal_emitted(banking, "balance_changed",
                         msg="balance_changed signal should emit on add_coins")

func test_signal_emitted_with_correct_parameters() -> void:
    watch_signals(banking)
    
    banking.add_coins(100)
    
    # Verify signal parameters
    assert_signal_emitted_with_parameters(banking, "balance_changed", 
                                          [100],
                                          msg="Signal should emit with new balance")

func test_multiple_signals() -> void:
    watch_signals(banking)
    
    banking.add_coins(50)
    banking.add_coins(75)
    banking.try_spend(30)
    
    # Verify signal emitted 3 times
    assert_signal_emit_count(banking, "balance_changed", 3,
                            msg="Signal should emit for each balance change")
```

---

## Testing Scene-Based Systems

Scene-based gameplay systems require instantiation, node hierarchy testing, and proper cleanup.

### Scene Structure Example

```gdscript
# scenes/player/player.tscn
# Structure:
# Player (Node2D) [player.gd]
#   â”œâ”€â”€ AnimatedSprite2D
#   â”œâ”€â”€ CollisionShape2D
#   â””â”€â”€ HealthComponent (Node) [health_component.gd]

# scenes/player/player.gd
extends Node2D

class_name Player

var health_component: HealthComponent

func _ready() -> void:
    health_component = $HealthComponent

func take_damage(amount: int) -> void:
    health_component.reduce_health(amount)

func get_health() -> int:
    return health_component.get_health()

func is_alive() -> bool:
    return get_health() > 0
```

### Testing Scene Instantiation

```gdscript
# tests/scenes/player_test.gd
extends GutTest

const PLAYER_SCENE_PATH = "res://scenes/player/player.tscn"

var player_scene: PackedScene
var player: Player

func before_each() -> void:
    player_scene = load(PLAYER_SCENE_PATH)

func test_player_scene_loads() -> void:
    assert_not_null(player_scene, "Player scene should load")

func test_player_instantiates() -> void:
    player = player_scene.instantiate()
    
    assert_is_instance_of(player, Player)
    assert_not_null(player.health_component)

func test_player_in_tree() -> void:
    # Instantiate and add to scene tree
    player = add_child_autofree(player_scene.instantiate())
    
    # Wait for _ready to execute
    await get_tree().process_frame
    
    assert_true(player.is_inside_tree(), "Player should be in scene tree")
    assert_true(player.health_component.is_inside_tree(), 
               "Health component should be in tree")
```

### Testing Node Hierarchies

```gdscript
extends GutTest

const LEVEL_SCENE_PATH = "res://scenes/levels/level_01.tscn"

func test_level_node_structure() -> void:
    var level_scene = load(LEVEL_SCENE_PATH)
    var level = add_child_autofree(level_scene.instantiate())
    
    await get_tree().process_frame
    
    # Verify hierarchy structure
    assert_true(level.has_node("EnemySpawner"), 
               "Level should have EnemySpawner node")
    
    var enemy_spawner = level.get_node("EnemySpawner")
    assert_true(enemy_spawner.has_node("SpawnPoint1"),
               "Spawner should have SpawnPoint1")
    
    # Verify correct node types
    var ui_root = level.get_node_or_null("UILayer")
    assert_is_instance_of(ui_root, CanvasLayer,
                         "UILayer should be CanvasLayer")

func test_orphan_detection() -> void:
    # GUT automatically warns about orphaned nodes
    var player = add_child_autofree(preload(PLAYER_SCENE_PATH).instantiate())
    
    # This would trigger orphan warning without proper cleanup
    # GUT tracks orphans automatically

func test_queue_free_cleanup() -> void:
    var player = preload(PLAYER_SCENE_PATH).instantiate()
    player.queue_free()
    
    # Must wait for queue_free to process
    await wait_seconds(0.1)
    
    assert_no_new_orphans("No orphans after queue_free")
```

### Memory Management

```gdscript
extends GutTest

func test_autofree_automatic_cleanup() -> void:
    # autofree automatically calls free() after test
    var node = autofree(Node.new())
    assert_not_null(node)
    # Node freed automatically after test

func test_autoqfree_with_queue_free() -> void:
    # autoqfree calls queue_free() after test
    var node = autoqfree(Node.new())
    var parent = autoqfree(Node.new())
    
    parent.add_child(node)
    assert_true(node.is_inside_tree())
    
    # Nodes cleaned up automatically

func test_add_child_autofree() -> void:
    # Combines add_child + autofree
    var node = add_child_autofree(Node2D.new())
    
    assert_true(node.is_inside_tree(), "Should be in scene tree")
    # Freed automatically

func test_manual_orphan_check() -> void:
    # Check orphans manually if using queue_free
    var node = Node.new()
    node.queue_free()
    
    # Don't assert orphans immediately
    assert_new_orphans(1, "One orphan expected from queue_free")
    
    # Wait for queue_free to process
    await wait_seconds(0.1)
    assert_no_new_orphans("Orphans cleaned up after frame")
```

---

## Testing UI Components

UI components require simulating user interactions and verifying visual changes.

### Button Testing

```gdscript
# scenes/ui/shop_button.gd
extends Button

class_name ShopButton

signal shop_opened

func _ready() -> void:
    pressed.connect(_on_pressed)

func _on_pressed() -> void:
    shop_opened.emit()
```

```gdscript
# tests/ui/shop_button_test.gd
extends GutTest

const SHOP_BUTTON_PATH = "res://scenes/ui/shop_button.gd"

var button: ShopButton

func before_each() -> void:
    button = add_child_autofree(ShopButton.new())

func test_button_initializes() -> void:
    assert_not_null(button)
    assert_eq(button.button_pressed, false)

func test_button_press_emits_signal() -> void:
    watch_signals(button)
    
    # Simulate button press
    button.pressed.emit()
    
    assert_signal_emitted(button, "shop_opened")

func test_button_press_via_input_simulation() -> void:
    button.grab_focus()
    watch_signals(button)
    
    # Simulate input
    var input_event = InputEventAction.new()
    input_event.action = "ui_accept"
    input_event.pressed = true
    
    button.get_tree().input(input_event)
    
    # Allow input processing
    await wait_frames(1)
    
    assert_signal_emitted(button, "shop_opened")
```

### Input Validation Testing

```gdscript
# scenes/ui/coin_input.gd
extends LineEdit

class_name CoinInput

const MAX_COINS = 9999
const MIN_COINS = 1

signal amount_validated(amount: int)

func _ready() -> void:
    text_changed.connect(_on_text_changed)
    text = "0"

func _on_text_changed(new_text: String) -> void:
    if new_text.is_empty():
        return
    
    var amount = int(new_text) if new_text.is_valid_int() else 0
    amount = clampi(amount, MIN_COINS, MAX_COINS)
    
    if str(amount) != new_text:
        text = str(amount)
    else:
        amount_validated.emit(amount)

func get_amount() -> int:
    return int(text) if text.is_valid_int() else 0
```

```gdscript
# tests/ui/coin_input_test.gd
extends GutTest

const COIN_INPUT_PATH = "res://scenes/ui/coin_input.gd"

var coin_input: CoinInput

func before_each() -> void:
    coin_input = add_child_autofree(CoinInput.new())
    await get_tree().process_frame

func test_initializes_with_zero() -> void:
    assert_eq(coin_input.get_amount(), 0)

func test_accepts_valid_amount() -> void:
    watch_signals(coin_input)
    
    coin_input.text = "500"
    
    await wait_frames(1)
    
    assert_eq(coin_input.get_amount(), 500)

func test_clamps_to_max() -> void:
    coin_input.text = "99999"
    
    await wait_frames(1)
    
    assert_eq(coin_input.get_amount(), CoinInput.MAX_COINS)

func test_rejects_negative() -> void:
    coin_input.text = "-100"
    
    await wait_frames(1)
    
    assert_eq(coin_input.get_amount(), CoinInput.MIN_COINS)

func test_ignores_non_numeric() -> void:
    coin_input.text = "abc"
    
    await wait_frames(1)
    
    assert_eq(coin_input.get_amount(), 0)
```

### Modal/Popup Testing

```gdscript
extends GutTest

const CONFIRMATION_DIALOG_PATH = "res://scenes/ui/confirmation_dialog.tscn"

var dialog: ConfirmationDialog

func test_dialog_initially_hidden() -> void:
    dialog = add_child_autofree(load(CONFIRMATION_DIALOG_PATH).instantiate())
    
    assert_false(dialog.visible, "Dialog should be hidden initially")

func test_show_dialog() -> void:
    dialog = add_child_autofree(load(CONFIRMATION_DIALOG_PATH).instantiate())
    
    dialog.show_dialog("Confirm purchase?")
    
    assert_true(dialog.visible)
    assert_eq(dialog.get_message(), "Confirm purchase?")

func test_confirm_button_triggers_confirmed() -> void:
    dialog = add_child_autofree(load(CONFIRMATION_DIALOG_PATH).instantiate())
    watch_signals(dialog)
    
    dialog.show_dialog("Continue?")
    dialog.get_ok_button().pressed.emit()
    
    assert_signal_emitted(dialog, "confirmed")

func test_cancel_button_hides_dialog() -> void:
    dialog = add_child_autofree(load(CONFIRMATION_DIALOG_PATH).instantiate())
    
    dialog.show_dialog("Proceed?")
    assert_true(dialog.visible)
    
    dialog.get_cancel_button().pressed.emit()
    
    assert_false(dialog.visible)
```

---

## Integration Testing Patterns

Integration tests verify multiple systems working together.

### Multi-Service Integration

```gdscript
# tests/integration/save_integration_test.gd
extends GutTest

var banking: BankingService
var inventory: InventoryService
var save_manager: SaveManager

func before_each() -> void:
    banking = BankingService
    inventory = InventoryService
    save_manager = SaveManager
    
    # Reset all services
    banking.reset()
    inventory.reset()
    save_manager.clear()

func test_full_save_load_cycle() -> void:
    # Arrange: Set game state
    banking.add_coins(500)
    inventory.add_item("sword", 1)
    inventory.add_item("shield", 1)
    
    # Act: Save
    var save_data = {
        "balance": banking.get_balance(),
        "inventory": inventory.get_items()
    }
    save_manager.save_game(save_data)
    
    # Reset services
    banking.reset()
    inventory.clear()
    
    # Load
    var loaded_data = save_manager.load_game()
    banking.set_balance(loaded_data.balance)
    inventory.load_items(loaded_data.inventory)
    
    # Assert: Verify state restored
    assert_eq(banking.get_balance(), 500)
    assert_has(inventory.get_items(), "sword")
    assert_has(inventory.get_items(), "shield")

func test_concurrent_service_operations() -> void:
    # Multiple services operate simultaneously
    watch_signals(banking)
    watch_signals(inventory)
    
    banking.add_coins(100)
    inventory.add_item("potion", 5)
    banking.try_spend(50)
    inventory.use_item("potion", 1)
    
    # Both services processed independently
    assert_signal_emit_count(banking, "balance_changed", 2)
    assert_eq(banking.get_balance(), 50)
    assert_eq(inventory.get_item_count("potion"), 4)
```

### Save/Load Round-Trip Testing

```gdscript
extends GutTest

const SAVE_PATH = "user://test_save.dat"

var game_state: GameState
var save_system: SaveSystem

func before_each() -> void:
    game_state = GameState.new()
    save_system = SaveSystem.new(SAVE_PATH)

func after_each() -> void:
    # Clean up test files
    if ResourceLoader.exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)

func test_save_and_load_player_progress() -> void:
    # Setup initial state
    game_state.player_level = 5
    game_state.player_experience = 2500
    game_state.position = Vector2(100, 200)
    
    # Save
    save_system.save_state(game_state)
    assert_true(ResourceLoader.exists(SAVE_PATH), "Save file should exist")
    
    # Load into new state
    var loaded_state = save_system.load_state()
    
    # Verify
    assert_eq(loaded_state.player_level, 5)
    assert_eq(loaded_state.player_experience, 2500)
    assert_eq(loaded_state.position, Vector2(100, 200))

func test_complex_nested_data_preservation() -> void:
    var complex_data = {
        "player": {
            "stats": {
                "health": 100,
                "mana": 50
            },
            "inventory": ["sword", "shield", "potion"]
        },
        "world": {
            "enemies_defeated": 42,
            "quests": ["main_quest", "side_quest"]
        }
    }
    
    game_state.data = complex_data
    save_system.save_state(game_state)
    
    var loaded_state = save_system.load_state()
    
    assert_eq(loaded_state.data.player.stats.health, 100)
    assert_eq(loaded_state.data.player.inventory.size(), 3)
    assert_eq(loaded_state.data.world.enemies_defeated, 42)
```

### Event Flow Testing

```gdscript
extends GutTest

var event_bus: EventBus
var level_manager: LevelManager
var player: Player

func before_each() -> void:
    event_bus = EventBus.new()
    level_manager = LevelManager.new(event_bus)
    player = Player.new(event_bus)

func test_level_completion_event_flow() -> void:
    watch_signals(event_bus)
    
    # Player wins level
    player.complete_level()
    
    # Event propagates: player â†’ event_bus â†’ level_manager
    assert_signal_emitted(event_bus, "level_completed")
    
    # Level manager processes event
    await wait_frames(1)
    
    assert_true(level_manager.is_level_complete())
    assert_signal_emitted(event_bus, "show_victory_screen")

func test_death_event_cascade() -> void:
    watch_signals(event_bus)
    watch_signals(player)
    
    # Multiple systems react to player death
    player.die()
    
    assert_signal_emitted(event_bus, "player_died")
    assert_signal_emitted(level_manager, "restart_requested")
    
    # Subsequent spawning
    level_manager.restart()
    assert_true(player.is_alive())
```

### State Machine Testing

```gdscript
# systems/player_state.gd
extends Node

class_name PlayerState

signal state_changed(new_state: PlayerState)

enum STATE { IDLE, RUNNING, JUMPING, FALLING }

var current_state: STATE = STATE.IDLE

func transition_to(new_state: STATE) -> void:
    if current_state == new_state:
        return
    
    current_state = new_state
    state_changed.emit(self)

func enter_jump() -> void:
    if current_state == STATE.IDLE or current_state == STATE.RUNNING:
        transition_to(STATE.JUMPING)

func enter_fall() -> void:
    transition_to(STATE.FALLING)
```

```gdscript
# tests/integration/state_machine_test.gd
extends GutTest

var player_state: PlayerState

func before_each() -> void:
    player_state = add_child_autofree(PlayerState.new())

func test_valid_state_transitions() -> void:
    watch_signals(player_state)
    
    # IDLE â†’ JUMPING
    player_state.enter_jump()
    assert_eq(player_state.current_state, PlayerState.STATE.JUMPING)
    assert_signal_emitted(player_state, "state_changed")

func test_invalid_transition_ignored() -> void:
    watch_signals(player_state)
    
    # Try to jump while jumping (should be ignored)
    player_state.transition_to(PlayerState.STATE.JUMPING)
    player_state.enter_jump()
    
    # Signal should only emit once
    assert_signal_emit_count(player_state, "state_changed", 1)

func test_state_sequence() -> void:
    watch_signals(player_state)
    
    player_state.enter_jump()
    assert_eq(player_state.current_state, PlayerState.STATE.JUMPING)
    
    player_state.enter_fall()
    assert_eq(player_state.current_state, PlayerState.STATE.FALLING)
    
    # Verify state changed twice
    assert_signal_emit_count(player_state, "state_changed", 2)
```

---

## Async & Signal Testing

Async operations and signals require special handling in tests.

### Waiting for Signals

```gdscript
extends GutTest

var timer: Timer

func before_each() -> void:
    timer = add_child_autofree(Timer.new())

func test_wait_for_signal_success() -> void:
    timer.wait_time = 0.1
    timer.start()
    
    # Wait up to 1 second for timeout signal
    var signal_emitted = await wait_for_signal(timer.timeout, 1.0,
                                              "Timer should timeout")
    
    assert_true(signal_emitted, "Signal should have been emitted")

func test_wait_for_signal_timeout() -> void:
    timer.wait_time = 10.0
    timer.start()
    
    # Wait max 0.2 seconds
    var signal_emitted = await wait_for_signal(timer.timeout, 0.2,
                                              "Should timeout before timer fires")
    
    assert_false(signal_emitted, "Signal should not emit within wait time")
    
    timer.stop()
```

### Frame-Based Waiting

```gdscript
extends GutTest

var animated_sprite: AnimatedSprite2D

func before_each() -> void:
    animated_sprite = add_child_autofree(AnimatedSprite2D.new())

func test_wait_frames() -> void:
    # Wait for 3 process frames
    await wait_frames(3)
    
    # Assertions after frame delay
    assert_true(true, "Frames processed")

func test_wait_seconds() -> void:
    var start_time = Time.get_ticks_msec()
    
    # Wait 0.2 seconds
    await wait_seconds(0.2)
    
    var elapsed = Time.get_ticks_msec() - start_time
    assert_true(elapsed >= 200, "Should wait approximately 0.2 seconds")
```

### Complex Async Patterns

```gdscript
extends GutTest

var async_operation: AsyncOperation

func before_each() -> void:
    async_operation = AsyncOperation.new()

func test_multiple_signal_sequence() -> void:
    watch_signals(async_operation)
    
    async_operation.start_process()
    
    # Wait for progress signal
    var progress_fired = await wait_for_signal(async_operation.progress_updated, 1.0)
    assert_true(progress_fired, "Should report progress")
    
    # Wait for completion signal
    var complete_fired = await wait_for_signal(async_operation.operation_completed, 2.0)
    assert_true(complete_fired, "Should complete operation")
    
    assert_signal_emit_count(async_operation, "progress_updated", 3)
    assert_signal_emitted(async_operation, "operation_completed")

func test_signal_with_parameters_timeout() -> void:
    watch_signals(async_operation)
    
    async_operation.fetch_data("important_key")
    
    var fired = await wait_for_signal(async_operation.data_received, 2.0)
    
    if fired:
        assert_signal_emitted_with_parameters(async_operation, "data_received",
                                             ["important_key", true])
    else:
        fail_test("Operation timed out")
```

### Testing Animations with Await

```gdscript
extends GutTest

var tween_animation: TweenAnimation

func before_each() -> void:
    tween_animation = add_child_autofree(TweenAnimation.new())

func test_animation_completes() -> void:
    watch_signals(tween_animation)
    
    tween_animation.animate_position(Vector2(100, 100), 0.5)
    
    # Wait for animation to finish
    var completed = await wait_for_signal(tween_animation.animation_finished, 1.0)
    
    assert_true(completed, "Animation should complete")
    assert_eq(tween_animation.position, Vector2(100, 100))

func test_parallel_animations() -> void:
    watch_signals(tween_animation)
    
    # Start multiple animations simultaneously
    tween_animation.animate_position(Vector2(50, 50), 0.3)
    tween_animation.animate_scale(Vector2(2, 2), 0.3)
    
    var completed = await wait_for_signal(tween_animation.animation_finished, 1.0)
    
    assert_true(completed)
    assert_eq(tween_animation.position, Vector2(50, 50))
    assert_eq(tween_animation.scale, Vector2(2, 2))
```

---

## Test Organization & Structure

### Directory Structure

```
project/
â”œâ”€â”€ addons/
â”‚   â””â”€â”€ gut/                        # GUT framework
â”œâ”€â”€ scenes/
â”‚   â”œâ”€â”€ player/
â”‚   â”‚   â”œâ”€â”€ player.tscn
â”‚   â”‚   â””â”€â”€ player.gd
â”‚   â”œâ”€â”€ ui/
â”‚   â”‚   â”œâ”€â”€ main_menu.tscn
â”‚   â”‚   â””â”€â”€ shop_button.gd
â”‚   â””â”€â”€ levels/
â”‚       â””â”€â”€ level_01.tscn
â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ banking_service.gd         # Autoload
â”‚   â”œâ”€â”€ inventory_service.gd       # Autoload
â”‚   â””â”€â”€ save_system.gd
â”œâ”€â”€ systems/
â”‚   â”œâ”€â”€ state_machine.gd
â”‚   â””â”€â”€ event_bus.gd
â””â”€â”€ tests/
    â”œâ”€â”€ services/
    â”‚   â”œâ”€â”€ banking_service_test.gd
    â”‚   â”œâ”€â”€ inventory_service_test.gd
    â”‚   â””â”€â”€ save_system_test.gd
    â”œâ”€â”€ scenes/
    â”‚   â”œâ”€â”€ player_test.gd
    â”‚   â””â”€â”€ ui_test.gd
    â”œâ”€â”€ integration/
    â”‚   â”œâ”€â”€ save_integration_test.gd
    â”‚   â”œâ”€â”€ service_integration_test.gd
    â”‚   â””â”€â”€ state_machine_test.gd
    â””â”€â”€ doubles/                    # Test doubles
        â”œâ”€â”€ mock_payment_processor.gd
        â””â”€â”€ stub_database.gd
```

### Test Discovery & Naming Conventions

**Critical Requirements:**
- All test files must end with `_test.gd`
- All test functions must start with `test_`
- Place tests in `tests/` directory at project root
- GUT auto-discovers all files matching pattern

```gdscript
# âœ“ CORRECT
func test_player_takes_damage() -> void:
func test_save_system_handles_corrupted_files() -> void:
func test_inventory_persists_across_scenes() -> void:

# âœ— INCORRECT (won't run)
func test_player_damage() -> void:  # Missing complete context
func check_player_damage() -> void: # Doesn't start with test_
func player_damage_test() -> void:  # Wrong pattern
```

### Test Grouping by Feature

```gdscript
# tests/services/banking_service_test.gd
extends GutTest

class_name BankingServiceTest

# Group 1: Coin operations
func test_add_coins_increases_balance() -> void:
    pass

func test_add_zero_coins_no_change() -> void:
    pass

func test_negative_coins_rejected() -> void:
    pass

# Group 2: Purchase/spending
func test_spend_insufficient_funds() -> void:
    pass

func test_spend_exact_balance() -> void:
    pass

func test_spend_more_than_balance() -> void:
    pass

# Group 3: Signal emissions
func test_balance_changed_signal_on_add() -> void:
    pass

func test_balance_changed_signal_on_spend() -> void:
    pass
```

### Inner Test Classes (Advanced Organization)

```gdscript
extends GutTest

class_name ComplexServiceTest

# Base test setup
var service: ComplexService

func before_each() -> void:
    service = ComplexService.new()

# ============================================================================
# COIN OPERATIONS
# ============================================================================
class CoinOperations:
    extends GutTest
    
    var service: ComplexService
    
    func before_each() -> void:
        service = ComplexService.new()
    
    func test_add_coins() -> void:
        service.add_coins(50)
        assert_eq(service.get_balance(), 50)
    
    func test_subtract_coins() -> void:
        service.add_coins(100)
        service.subtract_coins(30)
        assert_eq(service.get_balance(), 70)

# ============================================================================
# INVENTORY OPERATIONS
# ============================================================================
class InventoryOperations:
    extends GutTest
    
    var service: ComplexService
    
    func before_each() -> void:
        service = ComplexService.new()
    
    func test_add_item() -> void:
        service.add_item("sword", 1)
        assert_true(service.has_item("sword"))
    
    func test_remove_item() -> void:
        service.add_item("sword", 2)
        service.remove_item("sword", 1)
        assert_eq(service.get_item_count("sword"), 1)
```

### Running Specific Tests

```bash
# Run all tests
godot --headless -s addons/gut/run_tests.gd

# Run specific test file
godot --headless -s addons/gut/run_tests.gd -d tests/services/banking_service_test.gd

# Run tests matching pattern
godot --headless -s addons/gut/run_tests.gd -f "*_test.gd"

# Run with output to file
godot --headless -s addons/gut/run_tests.gd > test_results.txt 2>&1

# Generate JUnit XML for CI/CD
godot --headless -s addons/gut/run_tests.gd --junit_output="test_results.xml"
```

---

## Common Anti-Patterns & Fixes

### Anti-Pattern 1: Test Interdependence

```gdscript
# âœ— WRONG: Tests depend on execution order
var total_coins = 0

func test_1_add_coins() -> void:
    total_coins += 100
    assert_eq(total_coins, 100)

func test_2_add_more_coins() -> void:
    # Depends on test_1 running first!
    total_coins += 50
    assert_eq(total_coins, 150)  # Fails if run alone

# âœ“ CORRECT: Each test is independent
func before_each() -> void:
    total_coins = 0

func test_add_coins() -> void:
    total_coins += 100
    assert_eq(total_coins, 100)

func test_add_more_coins() -> void:
    total_coins += 50
    assert_eq(total_coins, 50)  # Independent of other tests
```

### Anti-Pattern 2: Flaky Async Tests

```gdscript
# âœ— WRONG: Relies on hardcoded timing
func test_animation_completes() -> void:
    animation.play()
    await wait_seconds(0.5)  # What if animation is slower?
    assert_true(animation.is_finished())

# âœ“ CORRECT: Wait for actual signal/condition
func test_animation_completes() -> void:
    watch_signals(animation)
    animation.play()
    
    var completed = await wait_for_signal(animation.finished, 2.0,
                                          "Animation should complete")
    assert_true(completed, "Signal should have fired")
```

### Anti-Pattern 3: Over-Mocking

```gdscript
# âœ— WRONG: Mocks too much implementation detail
func test_save_data() -> void:
    var db_double = double(DATABASE_PATH)
    var fs_double = double(FILE_SYSTEM_PATH)
    var compression_double = double(COMPRESSION_PATH)
    
    # Testing mock behavior, not actual code
    db_double.stub_with_args("connect", [], true)
    fs_double.stub_with_args("write", [[]], true)
    compression_double.stub_with_args("compress", [{}], {})
    
    # Now what are we testing?

# âœ“ CORRECT: Test real logic with necessary mocks
func test_save_data() -> void:
    # Only mock external dependencies
    var file_system_double = double(FILE_SYSTEM_PATH)
    file_system_double.stub_with_args("write", [SAVE_PATH, "data"], true)
    
    var save_manager = SaveManager.new()
    save_manager.file_system = file_system_double
    
    # Test actual save logic
    var result = save_manager.save({"coins": 100})
    
    assert_true(result)
    assert_called(file_system_double, "write")
```

### Anti-Pattern 4: Slow Tests (>1 second each)

```gdscript
# âœ— WRONG: Unnecessary waits bloat test suite
func test_player_spawn() -> void:
    player.spawn()
    
    # Testing doesn't need full animation
    await wait_seconds(5)  # Animation plays completely
    
    assert_true(player.is_visible())

# âœ“ CORRECT: Mock or skip unnecessary delays
func test_player_spawn() -> void:
    player.spawn()
    
    # Only wait for actual logic
    await wait_frames(1)  # One frame for setup
    
    assert_true(player.is_visible())

# Alternative: Skip animation during tests
func before_each() -> void:
    # Disable slow animations during tests
    player.skip_animations = true
```

### Anti-Pattern 5: Testing Implementation vs Behavior

```gdscript
# âœ— WRONG: Tests internal implementation
func test_calculate_damage() -> void:
    var calculator = DamageCalculator.new()
    
    # Tests specific formula, not behavior
    var result = calculator._apply_armor_modifier(100, 50)
    assert_eq(result, 75)  # Breaks if formula changes
    
    result = calculator._apply_critical_modifier(100, true)
    assert_eq(result, 150)  # Tightly coupled to implementation

# âœ“ CORRECT: Tests public behavior
func test_calculate_damage() -> void:
    var attacker = Character.new()
    attacker.attack_power = 100
    
    var defender = Character.new()
    defender.armor = 50
    
    var damage = attacker.get_damage_against(defender)
    
    # Only assert the behavior, not implementation
    assert_true(damage > 0, "Should deal positive damage")
    assert_true(damage < 100, "Armor should reduce damage")
```

### Anti-Pattern 6: Singleton State Pollution

```gdscript
# âœ— WRONG: Singletons retain state across tests
func test_add_item() -> void:
    inventory.add_item("sword", 1)
    assert_eq(inventory.get_item_count("sword"), 1)

func test_item_count_starts_empty() -> void:
    # Fails because previous test added sword
    assert_eq(inventory.get_item_count("sword"), 0)

# âœ“ CORRECT: Reset state in before_each
func before_each() -> void:
    inventory = Inventory
    inventory.clear()  # Reset state
    inventory.get_tree().disconnect_all_signals()  # Clear connections

func test_add_item() -> void:
    inventory.add_item("sword", 1)
    assert_eq(inventory.get_item_count("sword"), 1)

func test_item_count_starts_empty() -> void:
    # Now passes: state reset before each test
    assert_eq(inventory.get_item_count("sword"), 0)
```

---

## Enforceable Patterns

### Required Test Structure Checklist

**Every test file must include:**

```gdscript
âœ“ extends GutTest
âœ“ class_name [ServiceName]Test
âœ“ before_each() for setup
âœ“ Proper cleanup (autofree/autoqfree)
âœ“ Descriptive test names (test_specific_behavior)
âœ“ At least one meaningful assertion per test
âœ“ No hardcoded delays (use wait_for_signal)
```

### Test Naming Convention Enforcement

```gdscript
# PATTERN: test_[object]_[action]_[expected_result]

âœ“ test_player_takes_damage_health_decreases
âœ“ test_inventory_add_item_count_increases
âœ“ test_save_system_corrupted_file_returns_error
âœ“ test_button_pressed_emits_clicked_signal

âœ— test_player (too vague)
âœ— test_does_it_work (unclear)
âœ— test1_test2 (uninformative)
âœ— check_player_damage (wrong prefix)
```

### Common Test Smells & Detection

| Smell | Detection | Fix |
|-------|-----------|-----|
| **Flaky** | Fails randomly, timing dependent | Use signals/conditions, not hardcoded waits |
| **Slow** | Single test >1 second | Remove unnecessary delays, mock slow ops |
| **Coupled** | Requires specific test order | Independent setup, reset state each test |
| **Over-mocked** | More mocks than real code | Only mock external dependencies |
| **Unclear** | Test name doesn't match behavior | Rename to test_[object]_[action]_[result] |
| **Duplicate** | Multiple tests check same thing | Combine or use parameterized tests |

### Severity Levels

**ERROR (Must Fix):**
- Test depends on execution order
- Test pollution between tests
- Hardcoded timing (>1 sec waits)
- Mocking concrete implementation details

**WARNING (Should Fix):**
- Test name unclear
- Multiple assertions testing different things
- Test slower than others
- Duplicated test logic

**INFO (Consider):**
- Test could be parameterized
- Test could use helper functions
- Similar tests could be grouped

---

## Parameterized Tests

Parameterized tests reduce duplication by running the same logic with different inputs.

### Basic Parameterized Test

```gdscript
extends GutTest

func test_damage_calculation(p = use_parameters([
    [10, 5, 5],      # [attacker_power, defender_armor, expected_damage]
    [50, 20, 30],
    [100, 50, 50],
    [25, 100, 0],    # Armor exceeds power
])) -> void:
    var attacker_power = p[0]
    var defender_armor = p[1]
    var expected_damage = p[2]
    
    var damage = max(0, attacker_power - defender_armor)
    
    assert_eq(damage, expected_damage,
             "Damage with power %d vs armor %d should be %d" % 
             [attacker_power, defender_armor, expected_damage])

# This generates 4 separate test runs with the parameters above
```

### Named Parameters for Clarity

```gdscript
extends GutTest

class TestData:
    var name: String
    var input: int
    var expected: int
    
    func _init(n: String, i: int, e: int) -> void:
        name = n
        input = i
        expected = e

func test_price_calculation(p = use_parameters([
    TestData.new("bronze_item", 10, 100),
    TestData.new("silver_item", 50, 500),
    TestData.new("gold_item", 100, 1000),
    TestData.new("free_item", 0, 0),
])) -> void:
    var price = p.input * 10
    
    assert_eq(price, p.expected,
             "Price for %s should be correct" % p.name)
```

### Complex Parameterized Scenarios

```gdscript
extends GutTest

func test_inventory_operations(p = use_parameters([
    # [action, item, quantity, should_succeed, expected_count]
    ["add", "sword", 1, true, 1],
    ["add", "sword", 5, true, 5],
    ["remove", "shield", 1, false, 0],  # Doesn't exist
    ["add", "potion", 10, true, 10],
    ["remove", "potion", 5, true, 5],
    ["remove", "potion", 10, false, 5],  # Removing more than available
])) -> void:
    var inventory = Inventory.new()
    
    var action = p[0]
    var item = p[1]
    var quantity = p[2]
    var should_succeed = p[3]
    var expected_count = p[4]
    
    var result: bool
    if action == "add":
        result = inventory.add_item(item, quantity)
    else:
        result = inventory.remove_item(item, quantity)
    
    assert_eq(result, should_succeed)
    assert_eq(inventory.get_item_count(item), expected_count)
```

---

## Coverage & Performance

### What Coverage Means in Godot

Coverage measures which lines/branches of code execute during tests. It's a tool to find gaps, not a quality metric.

**High coverage â‰  Good tests**
**Low coverage = Likely gaps**

### Critical Paths to Test

Priority testing order:

1. **Core Game Logic** (High Priority)
   - Damage calculations
   - Save/load systems
   - Resource management
   - Win/lose conditions

2. **Player Interactions** (High Priority)
   - Input handling
   - State transitions
   - Signal emissions

3. **Error Handling** (Medium Priority)
   - Invalid input validation
   - Resource loading failures
   - Network error recovery

4. **UI Behavior** (Medium Priority)
   - Button clicks
   - Form validation
   - Dialog flows

5. **Performance/Edge Cases** (Low Priority)
   - Large dataset handling
   - Boundary conditions
   - Memory leaks

### Testing Priorities Matrix

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Business Logic (Must Test)              â”‚
â”‚ - Game progression                      â”‚
â”‚ - Resource economy                      â”‚
â”‚ - Win/loss conditions                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ User Interactions (Should Test)         â”‚
â”‚ - Input handling                        â”‚
â”‚ - Signal emissions                      â”‚
â”‚ - State changes                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Error Cases (Could Test)                â”‚
â”‚ - Invalid inputs                        â”‚
â”‚ - Edge cases                            â”‚
â”‚ - Boundary conditions                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### When to Skip Tests

Skip tests for:
- Godot engine code (already tested)
- Third-party library functionality
- Visual/rendering code (hard to verify)
- Platform-specific code (test in CI/CD only)
- Animation playback timing (test signal, not frame count)

```gdscript
# DON'T TEST (engine code)
func test_node_position_via_set_position() -> void:
    var node = Node.new()
    node.position = Vector2(100, 100)
    # Don't test Godot's set_position implementation

# DO TEST (your logic)
func test_player_moves_to_target() -> void:
    var player = Player.new()
    player.move_to(Vector2(100, 100))
    assert_eq(player.get_target(), Vector2(100, 100))
```

### Performance Benchmarks

Guideline test execution times:

```
Unit Test:           < 0.1 seconds
Integration Test:    < 0.5 seconds
Full Suite:          < 10 seconds (all tests combined)
```

### Performance Assertions

```gdscript
extends GutTest

func test_operation_completes_quickly() -> void:
    var start_time = Time.get_ticks_msec()
    
    # Run operation
    perform_expensive_calculation()
    
    var elapsed = Time.get_ticks_msec() - start_time
    
    assert_true(elapsed < 100, 
               "Operation should complete in <100ms (took %dms)" % elapsed)

func test_large_dataset_handles_efficiently() -> void:
    var start_time = Time.get_ticks_msec()
    
    # Process 10000 items
    for i in range(10000):
        inventory.add_item("item_%d" % i, 1)
    
    var elapsed = Time.get_ticks_msec() - start_time
    
    assert_true(elapsed < 500,
               "Processing 10k items should be fast")
```

---

## Advanced Topics

### Testing Complex Dependencies

```gdscript
# When services depend on other services
extends GutTest

const SHOP_PATH = "res://services/shop.gd"
const BANKING_PATH = "res://services/banking.gd"

func test_shop_with_mock_banking() -> void:
    # Create mocks for all dependencies
    var banking_mock = double(BANKING_PATH)
    var shop = Shop.new()
    
    # Inject mocks into shop
    shop.banking = banking_mock
    
    # Configure mock behavior
    banking_mock.stub_with_args("try_spend", [100], true)
    
    # Test shop behavior with mocked dependency
    var purchase_success = shop.buy_item(1, 100)
    
    assert_true(purchase_success)
    assert_called(banking_mock, "try_spend")
```

### Testing Error Conditions

```gdscript
extends GutTest

func test_file_not_found_handling() -> void:
    var save_system = SaveSystem.new()
    
    # Try to load non-existent file
    var result = save_system.load_game("nonexistent.save")
    
    assert_null(result, "Should return null for missing file")
    assert_signal_emitted(save_system, "error_occurred")

func test_corrupted_save_file_recovery() -> void:
    # Create corrupted save file
    var corrupted_data = "invalid%%%corrupted"
    var save_file = FileAccess.open("user://corrupted.save", 
                                   FileAccess.WRITE)
    save_file.store_string(corrupted_data)
    
    var save_system = SaveSystem.new()
    var result = save_system.load_game("user://corrupted.save")
    
    assert_null(result, "Should handle corruption gracefully")
    
    # Cleanup
    DirAccess.remove_absolute("user://corrupted.save")
```

### Testing Resource Loading

```gdscript
extends GutTest

func test_scene_resource_loads() -> void:
    var scene_path = "res://scenes/player/player.tscn"
    
    var scene = load(scene_path)
    
    assert_not_null(scene, "Scene should load successfully")
    assert_is_instance_of(scene, PackedScene)

func test_invalid_resource_path_returns_null() -> void:
    var invalid_path = "res://nonexistent/scene.tscn"
    
    var scene = load(invalid_path)
    
    assert_null(scene, "Invalid path should return null")
```

---

## GUT CLI Reference

```bash
# Help
godot --headless -s addons/gut/run_tests.gd --help

# Run tests with verbose output
godot --headless -s addons/gut/run_tests.gd -v

# Run specific test file
godot --headless -s addons/gut/run_tests.gd -d tests/services/banking_service_test.gd

# Run tests matching pattern
godot --headless -s addons/gut/run_tests.gd -f "*integration*"

# Output to file
godot --headless -s addons/gut/run_tests.gd > results.txt

# JUnit XML output for CI/CD
godot --headless -s addons/gut/run_tests.gd --junit_output="tests.xml"

# List all tests without running
godot --headless -s addons/gut/run_tests.gd --list
```

---

## Conclusion & Best Practices Summary

### Before You Write Tests:
1. Understand what you're testing (unit vs integration)
2. Identify external dependencies that need mocking
3. Plan test isolation strategy
4. Design for fast execution

### While Writing Tests:
1. One assertion per test when possible (or one concept)
2. Use clear, descriptive names
3. Test behavior, not implementation
4. Reset state in `before_each()`
5. Use `autofree`/`autoqfree` for cleanup

### After Tests Pass:
1. Review for slow tests (>1 second)
2. Check for test interdependence
3. Look for over-mocking
4. Verify coverage on critical paths
5. Update documentation

### GUT Resources:
- GitHub: https://github.com/bitwes/Gut
- Documentation: https://gut.readthedocs.io/
- Asset Library: Search "GUT" in Godot 4.5
- Examples: See `addons/gut/examples/` folder

---

## Appendix: Quick Reference Templates

### Minimal Test Template

```gdscript
extends GutTest

var service: MyService

func before_each() -> void:
    service = MyService.new()

func test_basic_functionality() -> void:
    service.do_something()
    assert_true(service.is_done())
```

### Full Integration Test Template

```gdscript
extends GutTest

var service_a: ServiceA
var service_b: ServiceB
var event_bus: EventBus

func before_each() -> void:
    event_bus = EventBus.new()
    service_a = ServiceA.new()
    service_b = ServiceB.new()

func test_systems_work_together() -> void:
    watch_signals(event_bus)
    
    service_a.trigger_action()
    
    await wait_for_signal(event_bus.action_completed, 2.0)
    
    assert_true(service_b.processed_action())
```

### Scene Test Template

```gdscript
extends GutTest

const SCENE_PATH = "res://scenes/my_scene.tscn"

var scene_instance: Node

func before_each() -> void:
    var scene = load(SCENE_PATH)
    scene_instance = add_child_autofree(scene.instantiate())
    await get_tree().process_frame

func test_scene_setup() -> void:
    assert_not_null(scene_instance)
    # Add assertions
```

---

**Document Version:** 1.0 | **Godot Version:** 4.5.1 | **GUT Version:** 9.5.0+
