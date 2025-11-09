# Godot Migration: Quick Start Guide

**First-week action items** for getting the Godot migration off the ground.

---

## Day 1: Repository Setup

### 1. Create Repository

```bash
cd ~/Developer
gh repo create scrap-survivor-godot --public --clone
cd scrap-survivor-godot

# Initialize README
echo "# Scrap Survivor - Godot 4" > README.md
echo "" >> README.md
echo "Roguelike survival game built with Godot 4.4" >> README.md
echo "" >> README.md
echo "Migrated from React+Phaser to native Godot engine for optimal mobile performance." >> README.md

git add README.md
git commit -m "Initial commit"
git push origin main
```

### 2. Create .gitignore

```bash
cat > .gitignore << 'EOF'
# Godot 4+ specific ignores
.godot/
.import/
export_presets.cfg

# Exported builds
builds/
*.x86_64
*.exe
*.pck
*.apk
*.ipa
*.dmg

# System files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
*.tmp

# Godot editor cache
.godot/editor/
.godot/imported/
.godot/uid_cache.bin

# Android
.gradle/
android/
EOF

git add .gitignore
git commit -m "Add Godot .gitignore"
git push
```

### 3. Create Initial Directory Structure

```bash
mkdir -p assets/{sprites,audio,icons,fonts}
mkdir -p assets/sprites/{weapons,enemies,items,ui,effects}
mkdir -p scripts/{autoload,services,entities,systems,ui,utils,tests,resources}
mkdir -p scenes/{game,ui,entities}
mkdir -p resources/{data,theme,weapons,enemies,items}
mkdir -p docs/{godot,core-architecture,lessons-learned,migration,development-guide}
mkdir -p .system/{hooks,validators,git,meta}

git add .
git commit -m "Create initial directory structure"
git push
```

---

## Day 2: Install Tools

### 1. Download and Install Godot 4.4

```bash
# Download from https://godotengine.org/download/
# Install to /Applications/Godot.app

# Verify installation
/Applications/Godot.app/Contents/MacOS/Godot --version
# Should output: 4.4.x.stable.official
```

### 2. Install gdtoolkit (Linter/Formatter)

```bash
# Install via pip
pip3 install "gdtoolkit==4.*"

# Verify installation
gdlint --version
gdformat --version

# Should output version 4.x.x
```

### 3. Configure VS Code

```bash
# Install Godot extension
code --install-extension geequlim.godot-tools

# Create VS Code settings (optional)
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "godot_tools.editor_path": "/Applications/Godot.app/Contents/MacOS/Godot",
  "files.associations": {
    "*.gd": "gdscript",
    "*.tscn": "godot-scene",
    "*.tres": "godot-resource"
  }
}
EOF
```

---

## Day 3: Godot Project Setup

### 1. Create Godot Project

```bash
cd ~/Developer/scrap-survivor-godot

# Open Godot
open -a Godot

# In Godot Project Manager:
# 1. Click "Import"
# 2. Select ~/Developer/scrap-survivor-godot
# 3. Import & Edit

# This creates project.godot file
```

### 2. Configure Project Settings

In Godot Editor:

**Display Settings:**
- Project → Project Settings → Display → Window
  - Width: 1920
  - Height: 1080
  - Mode: Windowed (for development)
  - Resizable: On

**Input Map:**
- Project → Project Settings → Input Map
- Add actions:
  - `move_left`: A, Left Arrow
  - `move_right`: D, Right Arrow
  - `move_up`: W, Up Arrow
  - `move_down`: S, Down Arrow
  - `fire`: Left Mouse Button, Touch
  - `pause`: Escape, P

**Rendering:**
- Project → Project Settings → Rendering
  - Renderer: Forward+ (default)
  - Anti-Aliasing: MSAA 2D: 2x

**Save project.godot** (File → Save or Cmd+S)

### 3. Install Supabase Addon

In Godot Editor:
1. AssetLib tab (top center)
2. Search "Supabase"
3. Find "Supabase API (4.x)"
4. Click Download → Install
5. Restart Godot when prompted

---

## Day 4: Migrate .system/ Enforcement

### 1. Copy .system Directory

```bash
cd ~/Developer/scrap-survivor
cp -r .system ~/Developer/scrap-survivor-godot/

cd ~/Developer/scrap-survivor-godot
```

### 2. Adapt Git Hooks

**Update pre-commit hook:**

```bash
cat > .system/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for Godot project

echo "Running pre-commit checks..."

# Run gdlint on all .gd files
if command -v gdlint &> /dev/null; then
    echo "Linting GDScript files..."
    gdlint scripts/ --config .gdlintrc
    if [ $? -ne 0 ]; then
        echo "❌ GDScript linting failed"
        exit 1
    fi
else
    echo "⚠️  gdlint not found, skipping lint check"
fi

# Run gdformat check (no auto-fix, just verify)
if command -v gdformat &> /dev/null; then
    echo "Checking GDScript formatting..."
    gdformat --check scripts/
    if [ $? -ne 0 ]; then
        echo "❌ GDScript formatting check failed"
        echo "Run: gdformat scripts/"
        exit 1
    fi
else
    echo "⚠️  gdformat not found, skipping format check"
fi

# Run pattern validators (if you have them)
if [ -f ".system/validators/check-patterns.sh" ]; then
    echo "Running pattern validators..."
    .system/validators/check-patterns.sh
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x .system/hooks/pre-commit
```

**Create .gdlintrc:**

```bash
cat > .gdlintrc << 'EOF'
[MASTER]
class-name=true
function-name=true
variable-names=true

[FORMAT]
max-line-length=100
indent-size=4
EOF
```

**Install hook:**

```bash
# Link to git hooks directory
ln -sf ../../.system/hooks/pre-commit .git/hooks/pre-commit
```

### 3. Keep Git Autonomy System

The `.system/git/` directory works as-is (language-agnostic). No changes needed.

**Verify:**
```bash
ls -la .system/git/
# Should show audit log files and scripts
```

---

## Day 5: Documentation Migration

### 1. Copy Priority Documentation

```bash
cd ~/Developer/scrap-survivor

# Copy architecture docs
cp docs/core-architecture/monetization-architecture.md \
   ~/Developer/scrap-survivor-godot/docs/core-architecture/

cp docs/core-architecture/PATTERN-CATALOG.md \
   ~/Developer/scrap-survivor-godot/docs/core-architecture/

# Copy all lessons learned
cp -r docs/lessons-learned/ \
   ~/Developer/scrap-survivor-godot/docs/

# Copy commit guidelines
mkdir -p ~/Developer/scrap-survivor-godot/docs/development-guide
cp docs/development-guide/commit-guidelines.md \
   ~/Developer/scrap-survivor-godot/docs/development-guide/
```

### 2. Create Godot-Specific Docs

**Setup guide:**

```bash
cd ~/Developer/scrap-survivor-godot

cat > docs/godot/setup-guide.md << 'EOF'
# Godot 4 Setup Guide

## Prerequisites

- macOS (M4 Max)
- Godot 4.4+
- Python 3.x (for gdtoolkit)
- VS Code (recommended)

## Installation

1. **Download Godot 4.4:**
   - Visit https://godotengine.org/download/
   - Download macOS version
   - Install to /Applications/Godot.app

2. **Install gdtoolkit:**
   ```bash
   pip3 install "gdtoolkit==4.*"
   ```

3. **Clone repository:**
   ```bash
   gh repo clone scrap-survivor-godot
   cd scrap-survivor-godot
   ```

4. **Open in Godot:**
   ```bash
   open -a Godot
   # Import project from Godot Project Manager
   ```

## Editor Configuration

### Recommended Settings

- **Editor → Editor Settings → Text Editor → Indent:**
  - Type: Tabs
  - Size: 4

- **Editor → Editor Settings → Text Editor → Behavior:**
  - Auto reload scripts on external change: On

- **Editor → Editor Settings → Network → Remote Filesystem:**
  - Enable for external editing support

### Extensions

**VS Code:**
- Godot Tools (geequlim.godot-tools)

## First Run

1. Open Godot
2. Import project
3. Wait for initial import (may take 1-2 minutes)
4. Press F5 to run (should show blank screen - normal for empty project)

## Troubleshooting

**"Project import failed":**
- Ensure project.godot exists in root directory
- Try re-importing from Project Manager

**"gdlint command not found":**
- Check Python PATH: `which python3`
- Reinstall gdtoolkit: `pip3 install --upgrade "gdtoolkit==4.*"`

**"Supabase addon not working":**
- Restart Godot after installing addon
- Check addons/supabase/ directory exists
- Enable in Project → Project Settings → Plugins
EOF
```

**GDScript conventions:**

```bash
cat > docs/godot/gdscript-conventions.md << 'EOF'
# GDScript Coding Conventions

Based on official Godot style guide with project-specific additions.

## Naming Conventions

### Files and Folders
- **snake_case** for all files and folders
- Examples: `player.gd`, `enemy_spawner.gd`, `weapon_system.gd`

### Classes
- **PascalCase** for class names
- Match file name but in PascalCase
- Examples:
  ```gdscript
  class_name Player
  class_name EnemySpawner
  class_name WeaponSystem
  ```

### Variables
- **snake_case** for variables
- Prefix private variables with `_`
- Examples:
  ```gdscript
  var current_health: float
  var max_speed: float
  var _internal_timer: float
  ```

### Functions
- **snake_case** for function names
- Use verb_noun pattern when possible
- Examples:
  ```gdscript
  func calculate_damage() -> float:
  func spawn_enemy(type: String):
  func _on_button_pressed():  # Private callback
  ```

### Constants
- **SCREAMING_SNAKE_CASE**
- Examples:
  ```gdscript
  const MAX_HEALTH = 100
  const PLAYER_SPEED = 200.0
  const DAMAGE_MULTIPLIER = 1.5
  ```

### Signals
- **snake_case**
- Use past tense for events
- Examples:
  ```gdscript
  signal health_changed(current: float, max: float)
  signal enemy_died(enemy: Enemy)
  signal wave_completed(wave_number: int)
  ```

### Enums
- **PascalCase** for enum name
- **SCREAMING_SNAKE_CASE** for values
- Examples:
  ```gdscript
  enum EnemyType {
      SHAMBLER,
      RUNNER,
      JUGGERNAUT
  }

  enum DamageType {
      PHYSICAL,
      ENERGY,
      POISON
  }
  ```

## Code Structure

### Class Declaration Order

```gdscript
class_name MyClass
extends Node2D

# 1. Signals
signal something_happened()

# 2. Enums
enum State {
    IDLE,
    MOVING,
    ATTACKING
}

# 3. Constants
const MAX_VALUE = 100

# 4. Exported variables
@export var speed: float = 200.0
@export var health: int = 100

# 5. Public variables
var current_state: State = State.IDLE

# 6. Private variables
var _internal_timer: float = 0.0

# 7. Onready variables
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# 8. Lifecycle methods (_ready, _process, _physics_process, etc.)
func _ready():
    pass

func _process(delta):
    pass

# 9. Public methods
func take_damage(amount: float):
    pass

# 10. Private methods
func _update_state():
    pass

# 11. Signal callbacks
func _on_button_pressed():
    pass
```

## Type Hints

**Always use type hints:**

```gdscript
# ✅ Good
func calculate_damage(base: float, modifier: float) -> float:
    return base * modifier

var health: float = 100.0
var enemies: Array[Enemy] = []

# ❌ Bad (no type hints)
func calculate_damage(base, modifier):
    return base * modifier

var health = 100.0
var enemies = []
```

## Documentation

**Use doc comments for public APIs:**

```gdscript
## Calculates damage after applying armor reduction.
##
## The damage is reduced based on the target's armor value using
## the formula: damage = base_damage - (armor * 0.5)
##
## @param base_damage: Raw damage before armor reduction
## @param armor_value: Target's armor stat (0-100)
## @return: Final damage after reduction (minimum 1)
func calculate_damage(base_damage: float, armor_value: float) -> float:
    return max(1, base_damage - armor_value * 0.5)
```

## Project-Specific Patterns

### Autoload Access

```gdscript
# ✅ Good - direct access to autoload
func add_currency(amount: int):
    BankingService.add_currency("scrap", amount)

# ❌ Bad - storing reference
var banking_service
func _ready():
    banking_service = get_node("/root/BankingService")
```

### Signal Connections

```gdscript
# ✅ Good - use callable syntax
func _ready():
    button.pressed.connect(_on_button_pressed)
    enemy.died.connect(_on_enemy_died)

# ❌ Bad - old string syntax (Godot 3)
func _ready():
    button.connect("pressed", self, "_on_button_pressed")
```

### Resource Loading

```gdscript
# ✅ Good - preload for always-needed resources
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")

# ✅ Good - load for conditional resources
func spawn_enemy(type: String):
    var enemy_scene = load("res://scenes/enemies/" + type + ".tscn")
```

## References

- Official Godot Style Guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- GDScript documentation: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
EOF
```

### 3. Commit Documentation

```bash
cd ~/Developer/scrap-survivor-godot

git add docs/
git commit -m "docs: Add Godot setup guide and coding conventions

- Migrated architecture docs from React repo
- Migrated lessons learned
- Added Godot-specific setup guide
- Added GDScript coding conventions
"
git push
```

---

## Week 1 Checklist

By end of Week 1, you should have:

- [x] scrap-survivor-godot repository created on GitHub
- [x] .gitignore configured for Godot
- [x] Directory structure created
- [x] Godot 4.4 installed
- [x] gdtoolkit installed and working
- [x] VS Code configured with Godot extension
- [x] Godot project initialized (project.godot exists)
- [x] Project settings configured (display, input map, rendering)
- [x] Supabase addon installed
- [x] .system/ directory migrated
- [x] Git hooks configured (gdlint pre-commit)
- [x] Priority documentation migrated
- [x] Godot-specific docs created

**Verification:**

```bash
cd ~/Developer/scrap-survivor-godot

# Check git status
git status
# Should be on main branch, clean working directory

# Check Godot project
ls project.godot
# Should exist

# Check gdtoolkit
gdlint --version
gdformat --version

# Check docs
ls docs/godot/
# Should show setup-guide.md, gdscript-conventions.md

# Open in Godot
open -a Godot
# Import project, should open without errors
```

---

## Next: Week 2 - Configuration Migration

See [GODOT-MIGRATION-PLAN.md](./GODOT-MIGRATION-PLAN.md) Phase 1 for Week 2 tasks.

**Key tasks:**
- Export weapons/items/enemies from TypeScript to JSON
- Create custom resource classes
- Convert JSON to .tres resources

**Preparation:**

```bash
# Create export script in scrap-survivor repo
cd ~/Developer/scrap-survivor
touch scripts/export-configs.js
# (See full implementation in migration plan)
```

---

## Troubleshooting

### Godot won't import project

**Solution:**
```bash
cd ~/Developer/scrap-survivor-godot

# Create minimal project.godot
cat > project.godot << 'EOF'
; Engine configuration file.

[application]

config/name="Scrap Survivor"
config/version="0.1.0"
config/features=PackedStringArray("4.4")

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080

[rendering]

renderer/rendering_method="forward_plus"
EOF

# Try importing again
```

### gdlint not working in pre-commit hook

**Solution:**
```bash
# Find gdlint path
which gdlint

# Update hook shebang to use correct Python
# If gdlint is in /usr/local/bin, hook should work
# If in ~/Library/Python/3.x/bin, add to PATH:

echo 'export PATH="$HOME/Library/Python/3.11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Supabase addon not showing in editor

**Solution:**
1. Check addon installed: `ls addons/supabase/`
2. Enable in: Project → Project Settings → Plugins
3. Restart Godot
4. If still not working, reinstall from AssetLib

---

## Resources

- **Godot Documentation:** https://docs.godotengine.org/en/stable/
- **GDQuest (Tutorials):** https://www.gdquest.com/
- **Godot Community:** https://godotengine.org/community
- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Supabase-Godot Addon:** https://github.com/supabase-community/godot-engine.supabase
