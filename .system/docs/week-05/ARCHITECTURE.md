# Week 5 Architecture: Local-First Business Logic

**Status:** Implemented
**Last Updated:** Week 5 Day 5

## Design Philosophy

Week 5 implements core game economy services in a **local-first architecture**, prioritizing:

1. **Instant Response** - No network latency for core mechanics
2. **Offline-First** - Game works without internet connection
3. **Testability** - Pure functions and deterministic behavior
4. **Parity** - 100% feature match with legacy TypeScript Edge Functions

---

## Service Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Godot Autoloads                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │
│  │  Banking     │  │  Recycler    │  │  ShopReroll      │ │
│  │  Service     │  │  Service     │  │  Service         │ │
│  │              │  │              │  │                  │ │
│  │ • Scrap      │  │ • Dismantle  │  │ • Cost Calc      │ │
│  │ • Premium    │  │ • Luck Bonus │  │ • Daily Reset    │ │
│  │ • Tier Gates │  │ • Components │  │ • Preview        │ │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘ │
│         │                 │                    │           │
│         └─────────────────┴────────────────────┘           │
│                           │                                │
│                  ┌────────▼────────┐                       │
│                  │  In-Memory      │                       │
│                  │  State          │                       │
│                  │  (Week 5)       │                       │
│                  └─────────────────┘                       │
│                           │                                │
│                  ┌────────▼────────┐                       │
│                  │  Persistence    │                       │
│                  │  Layer          │                       │
│                  │  (Week 6)       │                       │
│                  └─────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### State Management

**Week 5 Approach:** In-memory only (ephemeral)

```gdscript
# BankingService - Mutable state
var balances: Dictionary = {"scrap": 0, "premium": 0}
var current_tier: UserTier = UserTier.FREE

# RecyclerService - Stateless (pure calculations)
# No persistent state needed

# ShopRerollService - Daily state
var _current_state: RerollState = RerollState.new()
```

**Week 6 Evolution:** Persistence layer

```gdscript
# Future: Save/load from Godot ConfigFile or JSON
func save_state() -> void:
    var save_data = {
        "balances": balances,
        "tier": current_tier,
        "version": 1
    }
    SaveSystem.write("banking_state", save_data)

func load_state() -> void:
    var save_data = SaveSystem.read("banking_state")
    if save_data:
        balances = save_data.balances
        current_tier = save_data.tier
```

---

## Service Details

### BankingService

**Purpose:** Manage player currency with tier-based restrictions

**State:**
```gdscript
var balances: Dictionary = {
    "scrap": 0,      # Earned through recycling (tier-gated)
    "premium": 0     # Purchased with real money
}
var current_tier: UserTier = UserTier.FREE
```

**Tier Gating:**

| Tier | Scrap Cap (per-char) | Scrap Cap (total) | Premium Cap |
|------|----------------------|-------------------|-------------|
| FREE | 0 | 0 | Unlimited |
| PREMIUM | 10,000 | 1,000,000 | Unlimited |
| SUBSCRIPTION | 100,000 | 1,000,000 | Unlimited |

**Design Rationale:**
- **Why 0 scrap for FREE?** Forces premium purchase to unlock recycling economy
- **Why separate per-char and total caps?** Per-char prevents farming on single character, total prevents multi-char farming
- **Why unlimited premium?** Players paid real money, no artificial limits

**API:**
```gdscript
# Query
func get_balance(type: CurrencyType) -> int
func get_balance_caps(tier: UserTier) -> BalanceCaps
func can_afford(type: CurrencyType, cost: int) -> bool

# Mutations
func add_currency(type: CurrencyType, amount: int) -> bool
func subtract_currency(type: CurrencyType, amount: int) -> bool

# Admin
func set_user_tier(new_tier: UserTier) -> void
func reset() -> void
```

**Signals:**
```gdscript
signal currency_added(type: CurrencyType, amount: int)
signal currency_subtracted(type: CurrencyType, amount: int)
signal balance_capped(type: CurrencyType, attempted: int, actual: int)
```

---

### RecyclerService

**Purpose:** Convert unwanted items into scrap and workshop components

**State:** None (stateless service, pure calculations)

**Formulas:**

**Scrap Calculation:**
```gdscript
scrap = SCRAP_BASE[rarity] * (1.5 if is_weapon else 1.0)
```

| Rarity | Base Scrap | Weapon Scrap |
|--------|-----------|--------------|
| COMMON | 12 | 18 |
| UNCOMMON | 20 | 30 |
| RARE | 35 | 53 |
| EPIC | 45 | 68 |
| LEGENDARY | 60 | 90 |

**Component Drop Chance:**
```gdscript
# Base chances by rarity
COMMON:     0%
UNCOMMON:   40%
RARE:       65%
EPIC:       75%
LEGENDARY:  85%

# Luck bonus: +2.5% per 10 luck, capped at +25%
luck_bonus = min(0.25, luck * 0.0025)
final_chance = min(0.95, base_chance + luck_bonus)
```

**Component Quantity:**
```gdscript
# Base components by rarity
UNCOMMON:   1-2
RARE:       2-3
EPIC:       3-4
LEGENDARY:  4-5

# Luck bonus: +1 component per 120 luck
luck_bonus = floor(luck / 120)
final_components = base_components + luck_bonus
```

**Design Rationale:**
- **Why weapon multiplier?** Weapons are more valuable in gameplay, should yield more scrap
- **Why luck-based components?** Creates player incentive to invest in luck stat
- **Why cap luck bonus at +25%?** Prevents 100% drop rates, maintains scarcity
- **Why 120 luck per component?** Balanced around typical endgame luck values (240-360)

**API:**
```gdscript
# Preview (no RNG)
func preview_dismantle(input: DismantleInput) -> DismantlePreview

# Execute (with RNG)
func dismantle_item(input: DismantleInput) -> DismantleOutcome

# Helpers
static func rarity_from_string(s: String) -> ItemRarity
static func rarity_to_string(r: ItemRarity) -> String
```

**Signals:**
```gdscript
signal item_dismantled(template_id: String, outcome: DismantleOutcome)
```

---

### ShopRerollService

**Purpose:** Calculate progressive costs for shop refreshes, reset daily

**State:**
```gdscript
var _current_state: RerollState = RerollState.new()

class RerollState:
    var game_day: String    # "YYYY-MM-DD"
    var reroll_count: int   # Resets at midnight
```

**Cost Formula:**
```gdscript
cost = BASE_COST * (COST_MULTIPLIER ^ reroll_count)
cost = 50 * (2 ^ reroll_count)
```

**Cost Progression:**

| Count | Formula | Cost |
|-------|---------|------|
| 0 | 50 × 2⁰ | 50 |
| 1 | 50 × 2¹ | 100 |
| 2 | 50 × 2² | 200 |
| 3 | 50 × 2³ | 400 |
| 5 | 50 × 2⁵ | 1,600 |
| 10 | 50 × 2¹⁰ | 51,200 |
| 15 | 50 × 2¹⁵ | 1,638,400 |

**Design Rationale:**
- **Why exponential?** Discourages excessive rerolling, creates meaningful choice
- **Why base 50?** Low enough for first reroll, high enough to feel impactful
- **Why 2x multiplier?** Doubles each time, clear exponential growth
- **Why daily reset?** Encourages daily engagement, prevents permanent penalty
- **Why cap at 99?** Safety limit to prevent integer overflow (2⁹⁹ is huge)

**Daily Reset:**
```gdscript
func _get_game_day() -> String:
    var time = Time.get_datetime_dict_from_system()
    return "%04d-%02d-%02d" % [time.year, time.month, time.day]

# Auto-reset when day changes
if _current_state.game_day != today:
    _reset_for_new_day(today)
```

**API:**
```gdscript
# Query
func get_reroll_preview() -> RerollPreview
func get_reroll_count() -> int

# Mutations
func execute_reroll() -> RerollExecution

# Admin
func reset_reroll_count() -> void
```

**Signals:**
```gdscript
signal reroll_executed(execution: RerollExecution)
signal reroll_count_reset(game_day: String)
```

---

## Design Patterns

### 1. Autoload Singleton Pattern

**Usage:** All services are Godot autoloads

```ini
# project.godot
[autoload]
BankingService="*res://scripts/services/banking_service.gd"
RecyclerService="*res://scripts/services/recycler_service.gd"
ShopRerollService="*res://scripts/services/shop_reroll_service.gd"
```

**Benefits:**
- ✅ Global access from any script
- ✅ Single source of truth
- ✅ Automatic initialization
- ✅ No manual dependency injection

**Tradeoffs:**
- ⚠️ Global state (must be careful with mutations)
- ⚠️ Harder to unit test in isolation (use reset() functions)

**Testing Strategy:**
```gdscript
func _ready() -> void:
    # Always reset state before tests
    BankingService.reset()
    ShopRerollService.reset_reroll_count()

    # Run tests with clean slate
    test_banking_operations()
```

---

### 2. Preview-Execute Pattern

**Usage:** RecyclerService and ShopRerollService

**Purpose:** Let players see outcome before committing

```gdscript
# Preview (deterministic, no side effects)
var preview = RecyclerService.preview_dismantle(input)
print("You will get: %d scrap" % preview.scrap_granted)

# Execute (with RNG, modifies state)
var outcome = RecyclerService.dismantle_item(input)
print("You got: %d scrap, %d components" % [outcome.scrap_granted, outcome.components_granted])
```

**Benefits:**
- ✅ Player knows expected value before action
- ✅ Reduces "feel bad" moments from bad RNG
- ✅ Enables UI to show ranges ("12-18 scrap possible")

**Implementation:**
```gdscript
func preview_dismantle(input: DismantleInput) -> DismantlePreview:
    # Calculate ranges without RNG
    return DismantlePreview.new(
        scrap_granted,
        components_min,
        components_max,
        components_chance
    )

func dismantle_item(input: DismantleInput) -> DismantleOutcome:
    # Actually roll RNG
    var scrap = _calculate_scrap(input.rarity, input.is_weapon)
    var components = _roll_components(input.rarity, input.luck)

    item_dismantled.emit(input.template_id, outcome)
    return outcome
```

---

### 3. Signal-Based Events

**Usage:** All services emit signals for state changes

**Purpose:** Decouple services from UI and analytics

```gdscript
# Service emits event
BankingService.currency_added.emit(CurrencyType.SCRAP, 100)

# UI listens and updates
BankingService.currency_added.connect(_on_currency_added)

func _on_currency_added(type: CurrencyType, amount: int) -> void:
    if type == BankingService.CurrencyType.SCRAP:
        scrap_label.text = str(BankingService.get_balance(type))
        play_coin_sound()
```

**Benefits:**
- ✅ UI doesn't need to poll for changes
- ✅ Multiple listeners can react to same event
- ✅ Easy to add analytics without touching service code
- ✅ Testable (can connect to test functions)

**Testing Strategy:**
```gdscript
func test_signals() -> void:
    var events = []

    BankingService.currency_added.connect(
        func(type, amount):
            events.append({"type": type, "amount": amount})
    )

    BankingService.add_currency(BankingService.CurrencyType.SCRAP, 50)

    assert(events.size() == 1)
    assert(events[0].amount == 50)
```

---

### 4. Data Class Pattern

**Usage:** All services use inner classes for structured data

**Purpose:** Type-safe data transfer, clear API contracts

```gdscript
# Input classes
class DismantleInput:
    var template_id: String
    var rarity: ItemRarity
    var is_weapon: bool
    var luck: int

# Output classes
class DismantleOutcome:
    var scrap_granted: int
    var components_granted: int
    var components_list: Array[String]
```

**Benefits:**
- ✅ Type safety (can't mix up parameter order)
- ✅ Self-documenting (clear what data is needed)
- ✅ Easy to extend (add fields without breaking old code)
- ✅ Testable (can construct test inputs easily)

**Example:**
```gdscript
# Clear intent
var input = RecyclerService.DismantleInput.new(
    "rusty_sword",
    RecyclerService.ItemRarity.RARE,
    true,  # is_weapon
    150    # luck
)

# vs unclear function call
dismantle_item("rusty_sword", 2, true, 150)  # What is 2? What is 150?
```

---

## Integration Points

### Service → Service Communication

**Current:** Direct function calls (services are globally accessible)

```gdscript
# Example: Player rerolls shop
var preview = ShopRerollService.get_reroll_preview()

if BankingService.can_afford(BankingService.CurrencyType.SCRAP, preview.cost):
    var execution = ShopRerollService.execute_reroll()
    BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, execution.charged_cost)
    refresh_shop()
```

**Future (Week 7+):** Event-driven with mediator pattern

```gdscript
# ShopService coordinates between services
class ShopService:
    func reroll_shop() -> RerollResult:
        var preview = ShopRerollService.get_reroll_preview()

        if not BankingService.can_afford(CurrencyType.SCRAP, preview.cost):
            return RerollResult.new(false, "insufficient_funds")

        var execution = ShopRerollService.execute_reroll()
        var paid = BankingService.subtract_currency(CurrencyType.SCRAP, execution.charged_cost)

        if paid:
            shop_rerolled.emit(execution)
            return RerollResult.new(true, "success")
```

---

### UI → Service Communication

**Pattern:** UI calls service functions, listens to signals

```gdscript
# UI Script
extends Control

@onready var scrap_label = $ScrapLabel
@onready var reroll_button = $RerollButton

func _ready() -> void:
    # Subscribe to events
    BankingService.currency_added.connect(_on_currency_changed)
    BankingService.currency_subtracted.connect(_on_currency_changed)
    ShopRerollService.reroll_executed.connect(_on_reroll_executed)

    # Initialize UI
    _update_ui()

func _on_reroll_button_pressed() -> void:
    var preview = ShopRerollService.get_reroll_preview()

    if BankingService.can_afford(BankingService.CurrencyType.SCRAP, preview.cost):
        var execution = ShopRerollService.execute_reroll()
        BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, execution.charged_cost)
        # UI will update via signal

func _on_currency_changed(_type, _amount) -> void:
    _update_ui()

func _update_ui() -> void:
    var preview = ShopRerollService.get_reroll_preview()
    scrap_label.text = str(BankingService.get_balance(BankingService.CurrencyType.SCRAP))
    reroll_button.text = "Reroll (%d scrap)" % preview.cost
    reroll_button.disabled = not BankingService.can_afford(BankingService.CurrencyType.SCRAP, preview.cost)
```

---

## Testing Architecture

### Test Structure

All tests follow the same pattern:

```gdscript
extends Node

func _ready() -> void:
    print("=== Service Test ===")

    # Run test functions
    test_feature_1()
    test_feature_2()
    test_edge_cases()

    print("=== Tests Complete ===")

    # Exit for headless mode
    get_tree().quit()

func test_feature_1() -> void:
    print("--- Testing Feature 1 ---")

    # Reset state
    Service.reset()

    # Setup
    var input = Service.Input.new(...)

    # Execute
    var result = Service.do_something(input)

    # Assert
    assert(result.value == expected, "Error message")
    print("✓ Test passed")
```

### Assertion Strategy

**Use descriptive error messages:**
```gdscript
# Good
assert(balance == 50, "Balance should be 50 after adding 50 scrap")

# Bad
assert(balance == 50)
```

**Test both success and failure paths:**
```gdscript
func test_tier_gating() -> void:
    BankingService.set_user_tier(BankingService.UserTier.FREE)

    # Should fail for FREE tier
    var result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
    assert(not result, "FREE tier should reject scrap")

    # Should succeed for PREMIUM tier
    BankingService.set_user_tier(BankingService.UserTier.PREMIUM)
    result = BankingService.add_currency(BankingService.CurrencyType.SCRAP, 100)
    assert(result, "PREMIUM tier should accept scrap")
```

### Integration Test Philosophy

**Unit tests:** Test individual service functions in isolation
**Integration tests:** Test realistic workflows across multiple services

```gdscript
# Integration test: Complete gameplay loop
func test_realistic_gameplay_loop() -> void:
    # Setup: Premium player
    BankingService.set_user_tier(BankingService.UserTier.PREMIUM)
    BankingService.add_currency(BankingService.CurrencyType.PREMIUM, 1000)

    # Action 1: Dismantle items to earn scrap
    for i in range(5):
        var input = RecyclerService.DismantleInput.new(...)
        var outcome = RecyclerService.dismantle_item(input)
        BankingService.add_currency(BankingService.CurrencyType.SCRAP, outcome.scrap_granted)

    # Action 2: Reroll shop until out of scrap
    while true:
        var preview = ShopRerollService.get_reroll_preview()
        if not BankingService.can_afford(BankingService.CurrencyType.SCRAP, preview.cost):
            break
        var execution = ShopRerollService.execute_reroll()
        BankingService.subtract_currency(BankingService.CurrencyType.SCRAP, execution.charged_cost)

    # Assert: Verify final state matches expected
    assert(BankingService.get_balance(BankingService.CurrencyType.SCRAP) < 200)
```

---

## Performance Considerations

### Memory Footprint

**Current (Week 5):**
- BankingService: ~200 bytes (2 ints + enum)
- RecyclerService: 0 bytes (stateless)
- ShopRerollService: ~100 bytes (string + int)
- **Total:** ~300 bytes for all services

**Future (Week 6+):**
- Save files: ~5-10 KB per player (JSON/binary)
- Cache layer: Variable based on player inventory

### CPU Performance

**All operations are O(1) or O(n) where n is small:**
- Currency operations: O(1) dictionary lookup
- Dismantle calculation: O(1) formulas
- Reroll cost: O(1) power calculation

**No performance bottlenecks expected** until Week 7+ (multiplayer sync)

---

## Future Enhancements (Week 6+)

### Week 6: Persistence

```gdscript
# Save system integration
func save_game() -> void:
    var save_data = {
        "banking": BankingService.serialize(),
        "shop_reroll": ShopRerollService.serialize(),
        "version": 1
    }
    SaveSystem.write("player_state", save_data)

func load_game() -> void:
    var save_data = SaveSystem.read("player_state")
    if save_data:
        BankingService.deserialize(save_data.banking)
        ShopRerollService.deserialize(save_data.shop_reroll)
```

### Week 7+: Multiplayer Sync

```gdscript
# Sync to Supabase (optional)
func sync_to_cloud() -> void:
    var data = BankingService.serialize()
    await SupabaseClient.upsert("player_currency", data)
```

---

## Conclusion

Week 5's architecture prioritizes:
1. **Simplicity** - Pure GDScript, no external dependencies
2. **Testability** - Deterministic, easy to reset state
3. **Maintainability** - Clear patterns, well-documented
4. **Performance** - O(1) operations, minimal memory

This foundation enables rapid iteration in Week 6+ while maintaining code quality and test coverage.
