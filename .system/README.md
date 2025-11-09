# Enforcement System for Godot

This directory contains the enforcement layer migrated from the React/TypeScript version and adapted for GDScript/Godot.

---

## 📁 Structure

```
.system/
├── git/                   # Git autonomy system (100% reusable)
│   ├── approval-system.ts
│   ├── audit-logger.ts
│   ├── autonomy-tiers.ts
│   └── run-audit-report.ts
├── hooks/                 # Git hooks (adapted for GDScript)
│   ├── pre-commit        # Runs gdlint + gdformat + pattern checks
│   └── commit-msg        # Validates conventional commits
├── validators/            # Pattern validators (GDScript-specific)
│   ├── check-patterns.sh # Main pattern validator
│   ├── patterns.ts       # Legacy TypeScript patterns (reference)
│   └── test-validator.ts # Legacy (reference)
├── meta/                  # Meta scripts (100% reusable)
└── logs/                  # Audit logs
```

---

## 🔧 What's Enforced

### 1. Pre-commit Hooks

**Location:** `.system/hooks/pre-commit`

**Runs automatically on `git commit`:**
- ✅ `gdlint` - GDScript linting
- ✅ `gdformat --check` - Formatting validation
- ✅ `check-patterns.sh` - Pattern enforcement

**Bypass (not recommended):**
```bash
git commit --no-verify
```

### 2. Commit Message Format

**Location:** `.system/hooks/commit-msg`

**Required format:**
```
<type>[optional scope]: <description>

Examples:
  feat: add enemy spawning system
  fix(player): correct movement speed calculation
  docs: update setup guide
```

**Valid types:**
- `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`, `revert`

### 3. GDScript Pattern Validation

**Location:** `.system/validators/check-patterns.sh`

**Enforces:**

#### Pattern 1: Autoload Services
```gdscript
# ✅ CORRECT
extends Node

class_name GameManager

var current_wave: int = 1

func _ready() -> void:
    pass
```

#### Pattern 2: Resource Scripts
```gdscript
# ✅ CORRECT
extends Resource

class_name WeaponResource

@export var damage: float = 10.0
@export var fire_rate: float = 0.5
```

#### Pattern 3: Service Pattern
```gdscript
# ✅ CORRECT (Supabase service)
extends Node

class_name AuthService

var supabase: SupabaseService

func _ready() -> void:
    supabase = get_node("/root/SupabaseService")
```

#### Pattern 4: Naming Conventions
```gdscript
# ✅ CORRECT

# Files: snake_case
# enemy_spawner.gd
# wave_system.gd

# Classes: PascalCase
class_name EnemySpawner
class_name WaveSystem

# Functions: snake_case
func calculate_damage(base: float) -> float:
    pass

# Variables: snake_case
var current_health: float = 100.0

# Constants: SCREAMING_SNAKE_CASE
const MAX_HEALTH: float = 100.0
const SPAWN_INTERVAL: float = 2.0
```

#### Pattern 5: Type Hints (Required)
```gdscript
# ✅ CORRECT
func calculate_damage(base: float, modifier: float) -> float:
    return base * modifier

var health: float = 100.0
var enemies: Array[Enemy] = []

# ❌ WRONG (missing types)
func calculate_damage(base, modifier):  # Missing -> float
    return base * modifier

var health = 100.0  # Missing : float
```

#### Pattern 6: Signal Naming
```gdscript
# ✅ CORRECT (snake_case, past tense recommended)
signal health_changed(new_health: float)
signal enemy_spawned(enemy: Enemy)
signal wave_completed(wave_number: int)

# Emit signals
health_changed.emit(50.0)
```

---

## 🚀 Usage

### Run Validators Manually

```bash
# Lint GDScript
gdlint --config .gdlintrc scripts/

# Format GDScript
gdformat scripts/

# Check formatting (no changes)
gdformat --check scripts/

# Validate patterns
bash .system/validators/check-patterns.sh
```

### VS Code Integration

**Run via Command Palette (Cmd+Shift+P):**
- "Tasks: Run Build Task" → Choose validator

**Run via Keyboard (Cmd+Shift+B):**
- Runs "Run All Checks" (lint + format + patterns)

**Configured in:** `.vscode/tasks.json`

### Windsurf Integration

Same as VS Code - uses `.vscode/tasks.json`

---

## 📊 Git Autonomy System

**Location:** `.system/git/`

**Status:** TypeScript files (reference only for now)

**What it does:**
- Tracks AI autonomy levels (bronze → silver → gold → platinum)
- Logs all git operations
- Approval system for risky operations
- Audit reporting

**Migration plan:** Convert to GDScript in Week 3 (optional)

---

## 🔄 Pattern Validator Details

### Autoload Pattern

**Checks:**
- ✅ File extends `Node`
- ✅ Exported variables have type hints
- ⚠️  Warnings for missing type hints

**Example violation:**
```gdscript
# ❌ WRONG
extends RefCounted  # Should be Node

var game_state  # Missing type hint
```

### Resource Pattern

**Checks:**
- ✅ File extends `Resource`
- ⚠️  Should have `class_name`

**Example violation:**
```gdscript
# ❌ WRONG
extends Node  # Should be Resource
```

### Service Pattern

**Checks:**
- ✅ File extends `Node`
- ⚠️  Supabase services should reference SupabaseService

**Example:**
```gdscript
# ✅ CORRECT
extends Node

var supabase: SupabaseService

func _ready() -> void:
    supabase = get_node("/root/SupabaseService")

func sign_in(email: String, password: String) -> Dictionary:
    return await supabase.auth.sign_in(email, password)
```

### Naming Convention Checks

| Type | Pattern | Example |
|------|---------|---------|
| **File** | snake_case | `weapon_system.gd` |
| **Class** | PascalCase | `class_name WeaponSystem` |
| **Function** | snake_case | `func calculate_damage()` |
| **Variable** | snake_case | `var current_wave: int` |
| **Constant** | SCREAMING_SNAKE_CASE | `const MAX_WAVES = 50` |
| **Signal** | snake_case | `signal health_changed` |

---

## ⚙️ Configuration Files

### .gdlintrc

**Location:** Project root

**Enforces:**
- Class naming (PascalCase)
- Function naming (snake_case)
- Variable naming (snake_case)
- Constant naming (SCREAMING_SNAKE_CASE)
- Max line length (100)
- Indentation (tabs, 4 spaces)

### .vscode/settings.json

**Enforces:**
- Format on save
- Tabs (not spaces)
- 100 character ruler
- GDScript LSP integration

### .vscode/tasks.json

**Provides:**
- Lint task
- Format task
- Check formatting task
- Pattern validation task
- "Run All Checks" (default build task)

---

## 🐛 Troubleshooting

### Pre-commit hook not running

**Check:**
```bash
ls -la .git/hooks/pre-commit
# Should be symlink to ../../.system/hooks/pre-commit
```

**Fix:**
```bash
ln -sf ../../.system/hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../.system/hooks/commit-msg .git/hooks/commit-msg
```

### Pattern validator fails

**Common issues:**
1. **No GDScript files yet** - Normal for new project
2. **Filename not snake_case** - Rename file
3. **Missing type hints** - Add `: Type` and `-> ReturnType`
4. **Wrong class naming** - Use PascalCase for `class_name`

### VS Code tasks not working

**Check:**
```bash
# Ensure gdtoolkit is installed
gdlint --version  # Should show 4.x.x
gdformat --version

# If not installed
pip3 install "gdtoolkit==4.*"
```

---

## 📚 Resources

- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **gdtoolkit:** https://github.com/Scony/godot-gdscript-toolkit
- **Conventional Commits:** https://www.conventionalcommits.org/

---

## 🔮 Future Enhancements

**Week 3-4 (optional):**
- Port git autonomy system to GDScript
- Add automated pattern learning
- Integration with Godot editor (plugin)
- Performance profiling validators

**Week 8-10 (optional):**
- Scene pattern validators (node structure)
- Resource pattern validators (.tres files)
- Animation naming conventions
- Shader best practices

---

**The enforcement system is ready!** 🎮🔒

Pre-commit hooks will run automatically on every commit, ensuring code quality and consistency.
