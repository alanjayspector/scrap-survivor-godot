# Enforcement System - Setup Complete ✅

The enforcement system has been fully configured for the Godot project with GDScript-specific validators and GitHub Actions.

---

## 📋 What's Configured

### ✅ Local Enforcement (Git Hooks)

**Pre-commit hook** (`.system/hooks/pre-commit`):
- Runs `gdlint` on all staged `.gd` files
- Runs `gdformat --check` to verify formatting
- Runs pattern validators (`.system/validators/check-patterns.sh`)

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

# Run all checks (same as Cmd+Shift+B in VS Code)
gdlint --config .gdlintrc scripts/ && \
gdformat --check scripts/ && \
bash .system/validators/check-patterns.sh
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

- ✅ Git hooks run on every commit
- ✅ CI runs on every push/PR
- ✅ IDE integration for quick validation
- ✅ GDScript-specific pattern enforcement
- ✅ All configured for Godot project structure

**No stale references** - TypeScript files in `.system/` are clearly marked as reference only. All active enforcement uses GDScript-specific tools.

---

**Questions?** See `.system/README.md` for detailed pattern documentation.
