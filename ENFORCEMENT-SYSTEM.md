# Enforcement System - Setup Complete ✅

The enforcement system has been fully configured for the Godot project with GDScript-specific validators and GitHub Actions.

---

## 📋 What's Configured

### ✅ Local Enforcement (Git Hooks)

**Pre-commit hook** (`.system/hooks/pre-commit`):
- Runs `gdlint` on all staged `.gd` files
- Runs `gdformat --check` to verify formatting
- Runs pattern validators (`.system/validators/check-patterns.sh`)
- Runs asset import validator (`.system/validators/check-imports.sh`)

**Commit message hook** (`.system/hooks/commit-msg`):
- Enforces conventional commit format
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`, `revert`

**Bypass (not recommended):**
```bash
git commit --no-verify
```

### ✅ CI/CD (GitHub Actions)

**Workflow 1: GDScript Lint** (`.github/workflows/gdscript-lint.yml`):
- Runs on push to `main`/`develop`
- Runs on PRs
- Executes `gdlint` and `gdformat --check`
- Fails if linting or formatting errors found

**Workflow 2: Pattern Validation** (`.github/workflows/pattern-validation.yml`):
- Runs on push to `main`/`develop`
- Runs on PRs
- Executes `.system/validators/check-patterns.sh`
- Checks naming conventions (snake_case for files, PascalCase for classes)
- Warns about missing type hints

**Workflow 3: Godot Export Test** (`.github/workflows/godot-export-test.yml`):
- Runs on push to `main`
- Runs on PRs (optional)
- Tests that project can be imported by Godot headless
- Validates `project.godot` exists
- Checks directory structure
- Prevents `.env` file leakage

### ✅ IDE Integration

**VS Code / Windsurf** (`.vscode/`):
- **settings.json**: GDScript formatting rules, LSP integration
- **tasks.json**: Quick access to validators via `Cmd+Shift+B`
- **extensions.json**: Recommended extensions (Godot Tools, Copilot)

**Available tasks:**
1. Lint GDScript Files
2. Format GDScript Files
3. Check GDScript Formatting
4. Validate GDScript Patterns
5. **Run All Checks** (default - runs 1, 3, 4)

**Run via:**
- Keyboard: `Cmd+Shift+B` → "Run All Checks"
- Command Palette: `Cmd+Shift+P` → "Tasks: Run Task"

---

## 🎯 Pattern Enforcement

### 1. Autoload Services (Singletons)

**Required:**
```gdscript
extends Node

class_name GameManager

@export var debug_mode: bool = false

func _ready() -> void:
    pass
```

**Violations:**
- ❌ Not extending `Node`
- ⚠️ Exported vars without type hints

### 2. Resource Scripts

**Required:**
```gdscript
extends Resource

class_name WeaponResource

@export var damage: float = 10.0
@export var fire_rate: float = 0.5
```

**Violations:**
- ❌ Not extending `Resource`
- ⚠️ Missing `class_name`

### 3. Service Pattern

**Required:**
```gdscript
extends Node

class_name AuthService

var supabase: SupabaseService

func _ready() -> void:
    supabase = get_node("/root/SupabaseService")

func sign_in(email: String, password: String) -> Dictionary:
    return await supabase.auth.sign_in(email, password)
```

**Violations:**
- ❌ Not extending `Node`
- ⚠️ Supabase services should reference SupabaseService

### 4. Naming Conventions

| Type | Pattern | Example | Enforced |
|------|---------|---------|----------|
| **File** | snake_case | `weapon_system.gd` | ✅ CI + Hook |
| **Class** | PascalCase | `class_name WeaponSystem` | ✅ CI + Hook |
| **Function** | snake_case | `func calculate_damage()` | ✅ gdlint |
| **Variable** | snake_case | `var current_wave: int` | ✅ gdlint |
| **Constant** | SCREAMING_SNAKE_CASE | `const MAX_WAVES = 50` | ✅ CI + Hook |
| **Signal** | snake_case | `signal health_changed` | ✅ CI + Hook |

### 5. Type Hints (Required)

**Required:**
```gdscript
func calculate_damage(base: float, modifier: float) -> float:
    return base * modifier

var health: float = 100.0
var enemies: Array[Enemy] = []
```

**Violations:**
- ⚠️ Functions without `-> ReturnType` (warning in CI)
- ⚠️ Variables without `: Type` (warning in CI)

---

## 📚 Godot Best Practices & Community Wisdom

### Community Anti-Patterns Reference

**See [docs/godot-community-research.md](docs/godot-community-research.md)** for comprehensive coverage of:

**Critical Anti-Patterns to Avoid:**
- ❌ `get_parent()` chains → Use signals or `@onready` cached refs
- ❌ `get_node()` in `_process()` → Cache references in `_ready()`
- ❌ Excessive signal bubbling (>2 levels) → Use event manager autoload
- ❌ Missing type hints → Enable editor error detection
- ❌ `animation.play()` in `_process()` → Only trigger on state changes

**Performance Patterns:**
- ✅ Use `@onready` for node references (cache in `_ready()`)
- ✅ Signals over polling for events
- ✅ State machines over complex if/else trees
- ✅ Area2D signals over distance checks every frame

**Common Issues & Solutions:**
- Collision layer/mask confusion (Layer = where it IS, Mask = what it SEES)
- Jitter/stutter fixes (physics interpolation, tick rate)
- Memory leaks (use `queue_free()`, not `free()`)
- Animation flickering (texture filter settings, state-based triggering)

### Automated Anti-Pattern Detection

**The pre-commit hook now checks for:**
- ✅ `get_parent()` chains (warns if nested 2+ levels)
- ✅ `get_node()` in `_process()/_physics_process()` (suggests `@onready`)
- ✅ Missing `@onready` for node references
- ✅ Missing type hints on exported variables
- ✅ Animation playback in game loop without state checks

**Violations are:**
- ❌ **Errors** (block commit): Critical anti-patterns that cause bugs
- ⚠️ **Warnings** (don't block): Performance issues, best practice violations

### Official Documentation Navigation

**See [docs/godot-reference.md](docs/godot-reference.md)** for quick links to:
- GDScript syntax and style guide
- API reference for specific classes
- 2D/3D development tutorials
- Physics, UI, audio, and networking guides
- Performance optimization strategies
- Debugging tools and techniques

### Systematic Debugging Workflow

**When encountering an issue, follow this order:**

1. **Check [godot-community-research.md](docs/godot-community-research.md)** FIRST
   - Common Issues & Solutions section
   - 80% of problems have known community solutions

2. **Use Godot Debugger** (see [docs/godot/debugging-guide.md](docs/godot/debugging-guide.md))
   - Breakpoints and variable inspection
   - Profiler for performance issues

3. **Consult [godot-reference.md](docs/godot-reference.md)** for official docs
   - API reference for classes and methods
   - Deeper tutorial exploration

4. **Ask Community** (if above don't help)
   - Forum: https://forum.godotengine.org/
   - Reddit: r/godot
   - GitHub issues for bugs

### Why This Matters

**Community wisdom prevents:**
- 🐛 **Hidden bugs** from fragile `get_parent()` chains
- 🐌 **Performance issues** from polling instead of signals
- 💥 **Memory leaks** from improper node cleanup
- 😵 **Debugging nightmares** from unclear signal flow

**These patterns are automatically enforced** via validators, not just documented!

---

## ⚡ Performance Optimization Patterns

### Performance Patterns Reference

**See [docs/godot-performance-patterns.md](docs/godot-performance-patterns.md)** for comprehensive performance optimization guide covering:

**Object Pooling** (>50 entities/sec):
- When to pool vs instantiate (with thresholds)
- Enemy pool implementation (300+ enemies)
- Projectile pool implementation
- **Performance**: 40-80% FPS gain at 200+ entities

**Spatial Optimization** (300+ entities):
- Spatial hash vs quadtree decision matrix
- VisibleOnScreenNotifier2D usage
- Collision layer optimization (≤8 layers recommended)
- **Performance**: 30-50% faster collision detection

**Physics Optimization**:
- CharacterBody2D vs Area2D vs RigidBody2D (6x faster with CharacterBody)
- Collision shape complexity impact (CircleShape2D recommended)
- Physics tick rate vs visual framerate
- **Performance**: 10-15% gain with optimized layers

**Rendering Optimization**:
- GPU vs CPU particles decision (>50 particles/sec → GPU)
- MultiMesh for 100+ identical sprites (1 draw call vs 300)
- Texture atlas usage (3-4x memory reduction)
- **Performance**: 20-40% FPS gain on older hardware

**Script Optimization**:
- Static typing in tight loops (15-25% faster)
- Caching strategies beyond @onready
- Signal vs polling performance (35% faster with signals)
- **Frame Budget**: 3-5ms for scripts (10-13μs per entity at 300 enemies)

### Automated Performance Checks

**The pre-commit hook now checks for:**
- ❌ **BLOCKING**: Node instantiation in `_process()` → Use object pooling
- ⚠️ **WARNING**: `get_node()` in hot paths → Cache with @onready
- ⚠️ **WARNING**: Untyped loop variables → Add type hints for 15-25% gain
- ⚠️ **WARNING**: String concatenation in loops → Use % formatting
- ⚠️ **WARNING**: Excessive physics layers (>8) → 10-15% overhead

**Performance Thresholds**:
- Particle count > 1000: Warning
- Entities > 500: Warning
- Draw calls > 200: Warning
- Physics layers > 8: Warning
- Animation count > 100 per entity: Warning

### Target Performance Metrics

For survivor-like games with 300 entities at 60 FPS:

```
Frame Budget (16.67ms total):
├─ Physics: 6-8ms (CharacterBody2D, CircleShape2D)
├─ Scripts: 3-5ms (static typing, @onready caching)
├─ Rendering: 4-6ms (MultiMesh, GPU particles)
└─ Engine overhead: 1-2ms

Per-Entity Budget: 10-15 microseconds
- Enemy AI: 8-10μs
- Collision: 2-3μs
- Animation: 1-2μs
- Movement: 1-2μs
```

### Quick Performance Wins

| Optimization | Threshold | Expected Gain | Difficulty |
|--------------|-----------|---------------|------------|
| Object pooling | >50 spawns/sec | 40-80% FPS | Easy |
| Spatial hash | 200+ entities | 30-50% faster | Medium |
| CharacterBody2D | All enemies | 6x vs RigidBody | Easy |
| GPU Particles | >50 particles/sec | 5-10x | Easy |
| Static typing | Hot paths | 15-25% faster | Easy |
| MultiMesh | 100+ sprites | 20-40% FPS | Medium |
| @onready caching | All node refs | 10x faster | Easy |
| CircleShape2D | Enemies | +15% vs polygon | Easy |

**These patterns are validated** in pre-commit hooks with concrete performance numbers!

---

## 🏗️ Service Architecture Patterns

### Service Architecture Reference

**See [docs/godot-service-architecture.md](docs/godot-service-architecture.md)** for comprehensive coverage of:

**Service Lifecycle Patterns:**
- Initialization order management (ServiceRegistry pattern)
- Ready vs manual initialization
- Cleanup and reset patterns
- Hot reload considerations

**Service Communication Patterns:**
- When to use signals vs direct calls
- Event bus pattern for cross-cutting concerns
- Avoiding circular dependencies
- Service discovery patterns

**Service State Management:**
- State serialization best practices (Resources vs Dictionary)
- Dirty flag patterns for optimization
- State validation before save/load
- Migration and versioning strategies

**Service Testing Patterns:**
- Unit testing with GdUnit4
- Mocking service dependencies
- Integration testing multi-service interactions
- Test doubles and service isolation

**API Design Patterns:**
- Naming conventions (get_ vs fetch_ vs retrieve_)
- Return types (Dictionary vs custom Resources)
- Error handling (bool + signal, enum, Result type)
- Async patterns with await

**Dependency Injection:**
- Setter injection (Godot-friendly)
- Service locator pattern
- Testing with dependency injection

**Common Service Anti-Patterns:**
- ❌ God services (too much responsibility → split into focused services)
- ❌ Chatty services (too many calls → aggregate data)
- ❌ Service leakage (exposing internals → encapsulate)
- ❌ State sync issues (multiple sources of truth → single source)

### Automated Architecture Checks

**The pre-commit hook now checks for:**
- ✅ Service naming convention (*_service.gd, extends Node)
- ⚠️ Direct autoload references (use ServiceRegistry.get_service())
- ⚠️ Service size limits (>500 lines warning, >700 error)
- ⚠️ Signal naming (past tense, *_started/*_finished)
- ⚠️ State management methods (validate_state(), reset_game_state())

**Violations are:**
- ❌ **Errors** (block commit): Missing extends Node, >700 lines
- ⚠️ **Warnings** (don't block): Direct autoloads, signal naming, missing validation

### Service Architecture Principles

| Principle | Pattern | Example |
|-----------|---------|---------|
| Single Responsibility | One service, one concern | InventoryService (items only) |
| Dependency Inversion | Use ServiceRegistry | `var bank = ServiceRegistry.get_service("BankingService")` |
| Interface Segregation | Minimal public API | Only expose necessary methods |
| Open/Closed | Extend via signals | Listen to service events, don't modify |
| State Validation | Always validate state | `validate_state() -> Array[String]` |

### Service Communication Decision Tree

```
Do you need immediate response?
├─ YES → Direct method call
│   ├─ Needs error handling? → Return bool/enum
│   └─ Result required? → Return value/Result type
│
└─ NO → Use signal
    ├─ Cross-service event? → EventBus signal
    ├─ Service-specific? → Service signal
    └─ Async operation? → Signal + await
```

### Quick Service Patterns

| Problem | Pattern | Code |
|---------|---------|------|
| Initialization order | ServiceRegistry + lookup | `ServiceRegistry.get_service("BankingService")` |
| Broadcasting events | Event bus signals | `EventBus.enemy_defeated.emit(id, reward)` |
| Complex state | Resource-based save | `ResourceSaver.save(state, path)` |
| Testing services | Dependency injection | `shop.set_banking_service(mock_banking)` |
| Error handling | Result type | `Result.ok(value)` or `Result.err(message)` |
| Async operations | Signal + await | `await save_completed` |

**These patterns are automatically enforced** via validators and documented with working examples!

---

## 🧪 Testing Patterns with GUT Framework

### Testing Patterns Reference

**See [docs/godot-testing-research.md](docs/godot-testing-research.md)** for comprehensive coverage of:

**GUT Framework Fundamentals:**
- Installation and setup for Godot 4.5.1
- Test structure & lifecycle (before_each, after_each, before_all, after_all)
- Assertions quick reference (assert_eq, assert_true, assert_signal_emitted, etc.)
- Running tests (editor, CLI, headless for CI/CD)

**Test Doubles:**
- Stubs (minimal implementation)
- Spies (track method calls)
- Mocks (verify interactions)
- Partial mocks (override specific methods)

**Testing Patterns:**
- Testing autoload services (singleton reset, state isolation)
- Testing scene-based systems (instantiation, node hierarchies)
- Testing UI components (button clicks, form validation)
- Integration testing (multi-service interactions, save/load round-trips)
- Async & signal testing (await, wait_for_signal)
- Parameterized tests (reduce duplication)

**Test Organization:**
- File naming: `*_test.gd`
- Method naming: `test_[object]_[action]_[expected_result]`
- Directory structure
- Test discovery patterns

**Common Test Anti-Patterns:**
- ❌ Flaky tests (timing-dependent → use signals/conditions)
- ❌ Slow tests (>1 second → remove delays, mock slow operations)
- ❌ Coupled tests (execution order dependent → independent setup)
- ❌ Over-mocked tests (more mocks than real code → only mock external deps)
- ❌ Hardcoded delays (>1 second waits → use wait_for_signal)

### Automated Test Quality Checks

**The pre-commit hook now checks for:**
- ⚠️ Test framework (suggests GUT migration for Node-based tests)
- ⚠️ Test naming convention (test_[object]_[action]_[result])
- ❌ Hardcoded delays (ERROR for >1 second, WARNING for shorter)
- ⚠️ Lifecycle hooks (before_each, after_each recommended)
- ⚠️ Assertions presence (at least one per test)
- ⚠️ Class name convention (*Test suffix)

**Violations are:**
- ❌ **Errors** (block commit): Hardcoded delays >1 second, invalid test method names
- ⚠️ **Warnings** (don't block): Missing GUT, vague test names, missing assertions

### Test Structure Requirements

```gdscript
# Recommended structure (GUT framework)
extends GutTest

class_name BankingServiceTest

var service: BankingService

func before_each() -> void:
    # Fresh instance for each test
    service = BankingService.new()

func after_each() -> void:
    # Cleanup
    service.queue_free()

func test_add_funds_increases_balance() -> void:
    service.add_funds(100)

    assert_eq(service.get_balance(), 100,
             "Adding 100 funds should increase balance to 100")

func test_withdraw_insufficient_funds_returns_false() -> void:
    var result = service.withdraw_funds(50)

    assert_false(result,
                "Withdrawing more than balance should return false")
```

### Test Naming Patterns

| Pattern | Example | Quality |
|---------|---------|---------|
| test_[object]_[action]_[result] | `test_player_takes_damage_health_decreases` | ✅ Good |
| test_[service]_[method]_[scenario] | `test_banking_add_funds_increases_balance` | ✅ Good |
| test_[feature]_[condition]_[behavior] | `test_shop_insufficient_funds_purchase_fails` | ✅ Good |
| test_[vague] | `test_player`, `test_basic`, `test1` | ❌ Bad |

### Test Smells Detection

| Smell | Example | Fix |
|-------|---------|-----|
| Hardcoded delay | `await get_tree().create_timer(1.0).timeout` | `await signal_name` or `wait_for_signal()` |
| Missing assertion | Test method with no assert_* call | Add at least one assertion |
| Vague name | `test_something` | `test_inventory_add_item_count_increases` |
| No lifecycle hooks | Tests without before_each/after_each | Add setup/cleanup methods |
| Over-coupling | Tests depend on execution order | Make tests independent |

---

## 🎨 Scene File & Component Integration Validation

### Scene File Validation Reference

**CRITICAL**: Scene files (.tscn) must have valid structure to instantiate correctly.

**Common issues**:
- 🐛 **Scene corruption**: Missing parent node specifications
- 💥 **Instantiation failures**: PackedScene.instantiate() returns null
- 🔄 **Dead code**: Components created but never used
- 📝 **False claims**: "Refactored to use component" but old code remains

**These are NOT detected by Godot editor** - Validation prevents runtime failures!

### Automated Scene & Component Checks

**The pre-commit hook now checks for:**

#### 1. Scene Structure Validator (BLOCKING)
**File**: `.system/validators/scene_structure_validator.py`

**Checks**:
- ✅ All child nodes have `parent="..."` specification
- ✅ No orphan nodes (nodes without parent, except root)
- ✅ Valid node hierarchy (no circular references)
- ✅ Scene can be parsed (valid format)

**Example violation caught**:
```
❌ ERROR: scenes/ui/character_card.tscn
   Line 9: HBoxContainer missing parent specification
   Expected: [node name="HBoxContainer" type="HBoxContainer" parent="."]
   Found: [node name="HBoxContainer" type="HBoxContainer"]
```

**Fix**: Open scene in Godot Editor and save, or manually add `parent="..."` to each child node

**Enforcement**: BLOCKING (prevents commit)

---

#### 2. Scene Instantiation Validator (BLOCKING)
**File**: `.system/validators/scene_instantiation_validator.py`

**Checks**:
- ✅ Scene file loads in headless Godot
- ✅ PackedScene.instantiate() returns non-null
- ✅ Instantiated scene has expected root type
- ✅ Script attached loads without errors

**Example violation caught**:
```
❌ ERROR: scenes/ui/character_card.tscn
   Instantiation FAILED - returns null
   Cause: Node HBoxContainer does not specify parent
```

**Fix**: Run scene_structure_validator.py first, then verify scene opens in Godot Editor

**Enforcement**: BLOCKING (prevents commit)

---

#### 3. Component Usage Validator (BLOCKING)
**File**: `.system/validators/component_usage_validator.py`

**Checks**:
- ✅ If scene is preloaded, verify .instantiate() call exists
- ✅ Warn if component created but never used (dead code)
- ✅ Detect preload without usage

**Example violations caught**:
```
⚠️  WARNING: scenes/ui/my_component.tscn
    Component exists but never used in codebase
    ACTION: Either use the component or delete it

❌ ERROR: scenes/ui/other_component.tscn
   Component preloaded but never instantiated
   Preloaded in: scripts/ui/parent.gd
   ERROR: No .instantiate() call found
```

**Fix**: Add `.instantiate()` call or remove unused preload/component

**Enforcement**: ERROR if preloaded but not used, WARNING if unused component

---

#### 4. Refactor Verification Validator (BLOCKING on refactor commits)
**File**: `.system/validators/refactor_verification_validator.py`

**Checks**:
- ✅ If commit message contains "refactor"/"use component", verify code changes
- ✅ If claiming component usage, verify preload() + instantiate() exist
- ✅ If claiming code reduction, verify .gd files modified

**Example violation caught**:
```
❌ ERROR: Commit claims "refactored to use CharacterCard component"
   Component 'CharacterCard' not found or not properly used in modified files
   FIX: Complete the refactor or update commit message
```

**Fix**: Complete the refactor or update commit message to reflect partial completion

**Enforcement**: BLOCKING on commits with refactor-related keywords

---

### Scene File Best Practices

**Scene Creation**:
1. ✅ **ALWAYS** create scenes via Godot editor (File → New Scene)
2. ❌ **NEVER** hand-edit .tscn files without opening in editor after
3. ✅ If manual edit required → Open in Godot editor immediately to validate

**Scene Structure**:
```
[node name="Root" type="PanelContainer"]        # Root - no parent

[node name="Child" type="HBoxContainer" parent="."]  # Child of root

[node name="GrandChild" type="Label" parent="Child"]  # Child of Child
```

**Component Integration**:
```gdscript
# Create component (via Godot editor)
# ↓
# Preload in parent script
const COMPONENT_SCENE = preload("res://scenes/ui/component.tscn")
# ↓
# Instantiate when needed
var instance = COMPONENT_SCENE.instantiate()
# ↓
# Setup and use
instance.setup(data)
add_child(instance)
```

**Refactoring to Components**:
1. Create component scene (via editor)
2. Add component script
3. Preload in parent
4. Replace manual UI code with instantiate() calls
5. Delete old manual UI generation code
6. Test instantiation
7. Commit with clear message

**Common Mistakes**:

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Missing parent specs | Scene won't instantiate | Run scene_structure_validator.py |
| Preload without use | Dead code, memory waste | Remove preload or add instantiate() |
| Claimed refactor incomplete | Old code still present | Complete refactor or update message |
| Manual .tscn edit | Scene corruption | Always use Godot editor |

---

### Current Test Framework

**Note**: This project currently uses simple Node-based tests with basic `assert()` calls. The test patterns validator provides helpful suggestions for migrating to GUT framework, but doesn't block commits. GUT framework provides:
- Better test structure (lifecycle hooks)
- Rich assertion library (assert_eq, assert_true, assert_signal_emitted)
- Test doubles (mocks, spies, stubs)
- Parameterized tests
- Better CI/CD integration

**These patterns are validated** but non-blocking to allow gradual GUT migration!

### Test Validation Workflow

**Validator**: `.system/validators/godot_test_runner.py`

The test runner implements a **strict verification strategy** to prevent committing code when test status is unknown.

#### Test Result Caching

**Files Generated:**
- `test_results.txt` - Structured test summary (timestamp, passed, failed, total, status)
- `test_run.log` - Full GUT output for debugging and real-time monitoring
- `test_results.xml` - JUnit XML format for CI/CD integration

**Result Format** (test_results.txt):
```
timestamp: 2025-11-10 14:32:15
passed: 393
failed: 0
total: 393
status: PASS
```

**Freshness Threshold**: 5 minutes

#### Validation Scenarios

**Scenario 1: Godot Closed**
```bash
git commit -m "feat: add new feature"
# → Runs tests in headless mode
# → Writes test_results.txt and test_run.log
# → Commit succeeds if tests pass
```

**Scenario 2: Godot Open + Fresh Results (< 5 minutes)**
```bash
# You run tests in Godot Editor at 14:30
# Tests pass, files written: test_results.txt, test_run.log

git commit -m "fix: correct bug"
# At 14:32 (2 minutes later):
# → Detects Godot is running
# → Checks test_results.txt freshness
# → Age: 2 minutes (< 5 minute threshold)
# → ✅ Trusts cached results
# → Commit succeeds
```

**Scenario 3: Godot Open + Stale Results (> 5 minutes)**
```bash
# Last test run: 14:00
# Current time: 14:10 (10 minutes later)

git commit -m "feat: add feature"
# → Detects Godot is running
# → Checks test_results.txt freshness
# → Age: 10 minutes (> 5 minute threshold)
# → ❌ Fails with instructions:
#
#   ❌ Cannot verify tests: Godot is running AND no fresh results
#
#   Fix Option 1: Run tests in Godot Editor (GUT panel)
#                 This updates test_results.txt and test_run.log
#
#   Fix Option 2: Close Godot and retry commit
#                 Tests will run automatically in headless mode
#
#   Bypass (NOT recommended): git commit --no-verify
```

**Scenario 4: Godot Open + No Results**
```bash
# No test_results.txt file exists

git commit -m "feat: add feature"
# → Detects Godot is running
# → No test_results.txt found
# → ❌ Fails with instructions (same as Scenario 3)
```

**Scenario 5: Cached Tests Failing**
```bash
# Last test run: 14:32 (2 minutes ago)
# Status: FAIL (3 tests failing)

git commit -m "fix: attempt to fix bug"
# → Detects Godot is running
# → Checks test_results.txt freshness
# → Age: 2 minutes (fresh)
# → ❌ Fails because cached tests show failures:
#
#   ❌ Cached tests show 3 failure(s)
#   Fix tests and rerun in Godot Editor
#   Or view failures: cat test_run.log
```

#### Real-Time Test Monitoring

**While tests are running in Godot Editor**, you can monitor progress:

```bash
# Watch test output in real-time
tail -f test_run.log

# Check current test status
cat test_results.txt
```

This allows visibility into test execution without blocking the editor.

#### Why This Approach

**Problem**: Previous behavior returned success when Godot was running without actually running tests, leading to false confidence that "all tests are passing."

**Solution**:
1. **Strict validation** - Never claim success without proof
2. **Result caching** - Trust recent test runs to avoid redundant execution
3. **Clear instructions** - Guide developers to fix the situation
4. **Real-time visibility** - Enable monitoring of test progress

**Benefits**:
- ✅ No false positives ("tests passing" without verification)
- ✅ Fast commits when tests recently run (< 5 minutes)
- ✅ Clear error messages with actionable fixes
- ✅ Real-time test monitoring via log files
- ✅ Strict enforcement by default, bypass available if needed

---

## 🎨 Asset Import Validation

### Asset Import Reference

**See [docs/godot-import-research.md](docs/godot-import-research.md)** for comprehensive import optimization guide covering:

**Texture Import Settings:**
- Compression modes (Lossless, Lossy, VRAM Compressed)
- Platform-specific overrides (iOS, Android, HTML5, Desktop)
- Filter modes (Nearest for pixel art, Linear for smooth graphics)
- Mipmap settings (generally disabled for 2D)
- Size limits and power-of-2 considerations

**Audio Import Settings:**
- Format recommendations (OGG Vorbis for music, WAV/OGG for SFX)
- Sample rate guidance (44kHz standard, 22kHz acceptable for SFX)
- Compression bitrates (128kbps music, 96kbps SFX)
- Streaming vs preloaded strategies

**Memory Budget Management:**
- Texture memory estimation formulas
- Atlas consolidation strategies
- Lazy loading patterns
- Target budgets for mobile (20-30 MB per level)

### Automated Import Checks

**The pre-commit hook now checks for:**
- ❌ **BLOCKING**: Pixel art using VRAM compression (compress/mode != 0)
- ❌ **BLOCKING**: Detect 3D enabled on sprites (causes auto-recompression)
- ❌ **BLOCKING**: Sprite sheets >2 MB (performance issue)
- ❌ **BLOCKING**: MP3 audio files (use OGG Vorbis instead)
- ⚠️ **WARNING**: Mipmaps enabled on pixel art (blurs pixels)
- ⚠️ **WARNING**: Music tracks >8 MB (compress to 128kbps)
- ⚠️ **WARNING**: SFX files >1 MB (use compression)
- ⚠️ **WARNING**: Asset naming violations (should use snake_case)

**Violations are:**
- ❌ **Errors** (block commit): Critical import misconfigurations, oversized assets, wrong formats
- ⚠️ **Warnings** (don't block): Size optimization opportunities, naming conventions

### Import Configuration Requirements

**2D Sprites (Pixel Art):**
```
Compress > Mode: Lossless (0)
Detect 3D: Disabled (0)
Mipmaps > Generate: No (false)
Filter: Nearest (set globally in project settings)
Repeat/Clamp: Clamp
```

**Why this matters:**
- VRAM compression applies lossy algorithms causing color banding and blur
- Detect 3D auto-converts sprites to VRAM compressed on 3D detection
- Mipmaps add memory overhead and blur pixel art
- Linear filtering causes blurry pixel edges

**Audio (Music/SFX):**
```
Format: OGG Vorbis (NOT MP3)
Music: 128 kbps, 44 kHz, stereo
SFX: 96 kbps, 44 kHz, mono (or WAV for short <2s)
```

**Why this matters:**
- MP3 has licensing/patent concerns across platforms
- OGG Vorbis is open-source, smaller, and streaming-friendly
- Proper bitrates balance quality and file size

**File Size Limits:**
- Sprite sheet: ≤2 MB (mobile memory constraints)
- Tileset atlas: ≤1 MB (frequently loaded)
- Music track: ≤8 MB (streaming overhead)
- UI texture: ≤500 KB (always in memory)

**Why this matters:**
- Mobile devices have 256-512 MB VRAM budgets
- Oversized textures cause memory spikes and crashes
- Web exports must download all assets (loading time critical)

### Asset Naming Convention

**Pattern:** `[category]_[entity]_[variant].[format]`

**Examples:**
- ✅ `characters_player_idle.png`
- ✅ `ui_button_hover.png`
- ✅ `music_level_01_main.ogg`
- ✅ `sfx_jump_01.wav`
- ✅ `enemies_goblin_walk.png`
- ❌ `PlayerSprite.png` (PascalCase not allowed)
- ❌ `random-sprite.png` (no category)
- ❌ `IMG_1234.png` (not descriptive)

**Why this matters:**
- Consistent naming enables automated validation
- Category prefixes organize assets by system
- Snake_case matches GDScript conventions
- Searchability and maintainability

### Platform-Specific Import Considerations

**iOS (ASTC compression):**
- Max texture: 4096×4096
- Compression: ASTC preferred, ETC2 fallback
- Target: 20-30 MB VRAM per level

**Android (ETC2/ASTC compression):**
- Max texture: 4096×4096
- Compression: ETC2 (API 19+), ASTC (API 23+)
- Target: 15-20 MB VRAM (older devices)

**HTML5/WebGL (no VRAM compression):**
- Max texture: 2048×2048 (browser limits)
- Compression: Lossless only (VRAM formats ignored)
- File size critical: Assets downloaded on load

**Desktop (Mac M4):**
- Max texture: 8192×8192
- Compression: S3TC/BPTC or ASTC
- Less restrictive but consistency recommended

### Common Import Mistakes

**Mistake 1: Wrong Compression for Pixel Art**
- **Problem:** Blurry or color-shifted sprites
- **Cause:** VRAM compression (ETC2, ASTC, S3TC)
- **Fix:** Set `Compress > Mode: Lossless` and `Detect 3D: Disabled`

**Mistake 2: Oversized Textures**
- **Problem:** Memory spikes on mobile
- **Solution:** Break large sprites into smaller atlases (max 1024×1024)

**Mistake 3: Unnecessary Mipmaps**
- **Problem:** Increased memory, performance drops
- **When needed:** Camera zoom-out with aliasing (rare in 2D)
- **Fix:** Set `Mipmaps > Generate: No` for all 2D sprites

**Mistake 4: Missing Platform Overrides**
- **Problem:** Wrong compression on mobile, bloated APKs
- **Fix:** Set platform-specific overrides (iOS: ASTC, Android: ETC2, Web: Lossless)

**Mistake 5: Using MP3 Audio**
- **Problem:** Licensing concerns, larger file sizes
- **Fix:** Convert to OGG Vorbis (music 128kbps, SFX 96kbps)

### Validation Script

**Location:** `.system/validators/check-imports.sh`

**What it checks:**
- Parses `.import` files for compression settings
- Validates file sizes against thresholds
- Checks audio format (rejects MP3)
- Validates naming conventions (snake_case, category prefixes)
- Reports errors (blocking) and warnings (informational)

**Run manually:**
```bash
bash .system/validators/check-imports.sh
```

**Runs automatically:**
- On every commit (via pre-commit hook)
- In CI/CD pipeline (GitHub Actions)

### Why Asset Import Validation Matters

**Silent failures that only appear in production:**
- 🐛 **Visual bugs**: Blurry pixel art from VRAM compression (only visible after export)
- 📱 **Mobile crashes**: Oversized textures exceed VRAM limits (device-specific)
- 🌐 **Web bloat**: Unoptimized assets increase download time (users abandon)
- 🎵 **Audio issues**: MP3 licensing violations (platform rejection)
- 💾 **Memory spikes**: Uncompressed textures loaded all at once (OOM crashes)

**These are NOT detected by Godot editor** - Validation prevents production issues!

### Quick Reference Import Settings Table

| Asset Type | Compression | Detect 3D | Mipmaps | Filter | Max Size |
|---|---|---|---|---|---|
| 2D Sprite (Pixel Art) | Lossless (0) | Disabled (0) | No | Nearest | 2 MB |
| Tilemap Atlas | Lossless (0) | Disabled (0) | No | Nearest | 1 MB |
| UI Texture | Lossless (0) | Disabled (0) | No | Nearest | 500 KB |
| Particle Texture | VRAM/Lossless | Disabled | Yes | Linear | 1 MB |
| Music (OGG) | N/A | N/A | N/A | N/A | 8 MB |
| SFX (WAV/OGG) | N/A | N/A | N/A | N/A | 1 MB |

---

## 🚀 Usage

### Run Validators Locally

```bash
# From project root

# Lint all GDScript
gdlint --config .gdlintrc scripts/

# Format all GDScript
gdformat scripts/

# Check formatting (no changes)
gdformat --check scripts/

# Validate patterns
bash .system/validators/check-patterns.sh

# Validate asset imports
bash .system/validators/check-imports.sh

# Run all checks (same as Cmd+Shift+B in VS Code)
gdlint --config .gdlintrc scripts/ && \
gdformat --check scripts/ && \
bash .system/validators/check-patterns.sh && \
bash .system/validators/check-imports.sh
```

### Configure External Editor

```bash
# From project root
bash scripts/configure-editor.sh
```

This will guide you through configuring Godot to open `.gd` files in VS Code or Windsurf.

---

## 📊 GitHub Actions Status

**All workflows are active and will run automatically on:**
- Push to `main` or `develop`
- Pull requests to `main` or `develop`
- Manual trigger (workflow_dispatch)

**View status:**
- https://github.com/YOUR_USERNAME/scrap-survivor-godot/actions

**Badges (add to README.md):**
```markdown
![GDScript Lint](https://github.com/YOUR_USERNAME/scrap-survivor-godot/actions/workflows/gdscript-lint.yml/badge.svg)
![Pattern Validation](https://github.com/YOUR_USERNAME/scrap-survivor-godot/actions/workflows/pattern-validation.yml/badge.svg)
![Godot Export Test](https://github.com/YOUR_USERNAME/scrap-survivor-godot/actions/workflows/godot-export-test.yml/badge.svg)
```

---

## 🔄 Differences from TypeScript Enforcement

### Migrated (Adapted for GDScript):

✅ **Git hooks** - Now run `gdlint` instead of `eslint`
✅ **Pattern validators** - Rewritten in bash for GDScript patterns
✅ **Commit message validation** - Same conventional commits format
✅ **CI/CD workflows** - Adapted for `gdtoolkit` instead of npm scripts
✅ **IDE integration** - VS Code tasks for GDScript tools

### Not Yet Migrated (TypeScript files remain as reference):

⏳ **Git autonomy system** (`.system/git/*.ts`)
- Status: Reference only
- Migration: Week 3-4 (optional)
- Would need to be converted to GDScript or bash

⏳ **Validator sync scripts** (`.system/validators/*.ts`)
- Status: Reference only
- Migration: Manual patterns in `check-patterns.sh` cover same ground

⏳ **Metrics collection**
- Status: Not needed yet (no npm scripts to monitor)
- Migration: Week 8-10 if desired (Godot-specific metrics)

### New for Godot:

🆕 **Godot export test** - Validates project can be imported/exported
🆕 **GDScript-specific patterns** - Autoload, Resource, Service patterns
🆕 **Scene validation** (future) - Will validate `.tscn` structure in Week 8+

---

## 📝 Directory Structure

```
.system/
├── README.md                      # This file
├── git/                           # Git autonomy (TypeScript - reference)
│   ├── approval-system.ts
│   ├── audit-logger.ts
│   ├── autonomy-tiers.ts
│   └── run-audit-report.ts
├── hooks/                         # Git hooks (active)
│   ├── pre-commit                # Runs gdlint + gdformat + patterns
│   └── commit-msg                # Validates conventional commits
├── validators/                    # Pattern validators
│   ├── check-patterns.sh         # GDScript pattern validator (active)
│   ├── patterns.ts               # TypeScript patterns (reference)
│   └── test-validator.ts         # TypeScript validator (reference)
├── meta/                          # Meta scripts (reference)
└── logs/                          # Audit logs

.github/workflows/
├── gdscript-lint.yml             # Lint + format check
├── pattern-validation.yml        # Pattern enforcement
└── godot-export-test.yml         # Project export test

.vscode/
├── settings.json                 # GDScript formatting + LSP
├── tasks.json                    # Quick access to validators
└── extensions.json               # Recommended extensions
```

---

## 🐛 Troubleshooting

### Git hooks not running

**Check:**
```bash
ls -la .git/hooks/pre-commit
# Should be symlink to ../../.system/hooks/pre-commit
```

**Fix:**
```bash
ln -sf ../../.system/hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../.system/hooks/commit-msg .git/hooks/commit-msg
chmod +x .system/hooks/*
```

### CI failing with "gdlint not found"

**Expected** - GitHub Actions will install `gdtoolkit` automatically.

If it fails, check `.github/workflows/gdscript-lint.yml` has:
```yaml
- name: Install gdtoolkit
  run: pip install "gdtoolkit==4.*"
```

### Pattern validator reports stale violations

**Issue:** Validator references old TypeScript structure.

**Fix:** The new `check-patterns.sh` is Godot-specific. Old `.ts` files are reference only.

### VS Code tasks not found

**Check:**
```bash
ls -la .vscode/tasks.json
```

**Fix:** File should exist. If not, copy from another Godot project or recreate.

---

## 🎓 Learning Resources

- **Conventional Commits:** https://www.conventionalcommits.org/
- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **gdtoolkit:** https://github.com/Scony/godot-gdscript-toolkit
- **GitHub Actions:** https://docs.github.com/en/actions

---

## ✅ Summary

**The enforcement system is fully operational and Godot-specific!**

- ✅ Git hooks run on every commit (code + assets)
- ✅ CI runs on every push/PR
- ✅ IDE integration for quick validation
- ✅ GDScript-specific pattern enforcement
- ✅ Asset import validation (compression, format, size)
- ✅ All configured for Godot project structure

**No stale references** - TypeScript files in `.system/` are clearly marked as reference only. All active enforcement uses GDScript-specific tools.

---

**Questions?** See `.system/README.md` for detailed pattern documentation.
