# VS Code & Windsurf Setup for Godot

Complete guide to using VS Code or Windsurf as your external editor for GDScript development.

---

## Quick Start

**Extensions already installed:**
- ✅ VS Code: `geequlim.godot-tools`
- ✅ Windsurf: `geequlim.godot-tools`

**VS Code settings already configured:**
- ✅ `.vscode/settings.json` with GDScript formatting rules
- ✅ `.vscode/extensions.json` with recommended extensions

---

## Configure Godot to Use Your Editor

Run this helper script:

```bash
cd ~/Developer/scrap-survivor
bash scripts/godot/configure-editor.sh
```

This will guide you through configuring Godot to open `.gd` files in your chosen editor.

**Or configure manually:**

1. Open Godot Editor
2. **Editor → Editor Settings**
3. Navigate to: **Text Editor → External**
4. Check: **☑ Use External Editor**

### For VS Code:

```
Exec Path: /Applications/Visual Studio Code.app/Contents/MacOS/Electron
Exec Flags: {project} --goto {file}:{line}:{col}
```

### For Windsurf:

```
Exec Path: /Applications/Windsurf.app/Contents/MacOS/Windsurf
Exec Flags: {project} --goto {file}:{line}:{col}
```

---

## Recommended Workflow

### 1. Keep Both Open

| Editor | Purpose |
|--------|---------|
| **Godot** | Scene editing, animation, running game (F5), asset import |
| **VS Code/Windsurf** | Writing GDScript with AI assistance |

### 2. Editing Flow

1. **In Godot:** Double-click a `.gd` file in FileSystem panel
2. **Opens in:** VS Code/Windsurf at the correct location
3. **Edit with AI:** Use Copilot, Cascade, or Claude Code
4. **Save:** Godot auto-reloads the script (no restart needed)

### 3. AI Tools Available

**In VS Code:**
- ✅ GitHub Copilot (inline suggestions)
- ✅ GitHub Copilot Chat
- ✅ Claude Code (via terminal: `claude "implement weapon system"`)
- ✅ Continue.dev
- ✅ Codeium

**In Windsurf:**
- ✅ Cascade AI (built-in, context-aware)
- ✅ GitHub Copilot (if installed)
- ✅ Claude Code (via terminal)

---

## GDScript Language Server (LSP)

The Godot Tools extension connects to Godot's built-in LSP for:

- ✅ Autocomplete (GDScript API)
- ✅ Go to definition
- ✅ Error checking
- ✅ Hover documentation
- ✅ Refactoring

**How it works:**

1. Godot Editor must be **running** with your project open
2. LSP server starts automatically on port `6005`
3. VS Code/Windsurf connects via WebSocket
4. You get full IDE features

**Troubleshooting:**

If autocomplete doesn't work:
1. Ensure Godot Editor is running
2. Check port in Godot: **Editor → Editor Settings → Network → Language Server**
3. Verify port in `.vscode/settings.json` matches (default: `6005`)

---

## Formatting & Linting

### Auto-format on Save

Already configured in `.vscode/settings.json`:

```json
"[gdscript]": {
  "editor.formatOnSave": true,
  "editor.tabSize": 4,
  "editor.insertSpaces": false
}
```

### Manual Formatting

**Via gdformat (recommended):**

```bash
# Format single file
gdformat scripts/autoload/game_manager.gd

# Format all scripts
gdformat scripts/

# Check without modifying
gdformat --check scripts/
```

**Via VS Code:**
- **Shift+Alt+F** (format document)
- **Right-click → Format Document**

### Linting

Pre-commit hook already configured to run `gdlint`:

```bash
# Manual lint check
gdlint --config .gdlintrc scripts/autoload/game_manager.gd

# Lint all scripts
gdlint --config .gdlintrc scripts/
```

---

## File Types

| Extension | Description | Edit Where |
|-----------|-------------|------------|
| `.gd` | GDScript source | VS Code/Windsurf |
| `.tscn` | Scene (text format) | Godot (can view in editor) |
| `.tres` | Resource (text format) | Godot (can view in editor) |
| `.import` | Import metadata | Auto-generated (don't edit) |
| `.gdshader` | Shader code | VS Code or Godot |

**Note:** `.tscn` and `.tres` files are technically text (INI-like format), but editing them manually is error-prone. Use Godot's visual editor.

---

## Keyboard Shortcuts

### In Godot Editor

| Shortcut | Action |
|----------|--------|
| **F5** | Run project |
| **F6** | Run current scene |
| **Ctrl+D** | Duplicate node/line |
| **Ctrl+Shift+D** | Delete line |
| **Ctrl+/** | Toggle comment |

### In VS Code/Windsurf

| Shortcut | Action |
|----------|--------|
| **Cmd+P** | Quick open file |
| **Cmd+Shift+P** | Command palette |
| **F12** | Go to definition (LSP) |
| **Shift+F12** | Find references |
| **Cmd+.** | Quick fix |
| **Ctrl+Space** | Trigger autocomplete |

---

## Project Structure

When working in VS Code/Windsurf, you'll see:

```
scrap-survivor-godot/
├── .vscode/              # VS Code settings
│   ├── settings.json     # GDScript formatting rules
│   └── extensions.json   # Recommended extensions
├── .godot/               # Godot cache (hidden in VS Code)
├── scripts/
│   ├── autoload/         # Global singletons (like services)
│   ├── entities/         # Player, enemies, items
│   ├── systems/          # Wave system, spawning, etc.
│   ├── services/         # Supabase, auth, analytics
│   └── utils/            # Helper functions
├── scenes/
│   ├── game/             # Main game scene
│   ├── ui/               # Menus, HUD
│   └── entities/         # Prefabs (player, enemies)
├── resources/
│   ├── data/             # JSON configs (weapons, items)
│   ├── weapons/          # Weapon .tres resources
│   └── enemies/          # Enemy .tres resources
└── project.godot         # Godot project file
```

---

## GDScript vs TypeScript Cheatsheet

Help Copilot/Cascade understand GDScript:

| TypeScript | GDScript |
|------------|----------|
| `const x = 5` | `const X = 5` (constants are UPPERCASE) |
| `let x = 5` | `var x = 5` |
| `function foo() {}` | `func foo():` |
| `class Foo {}` | `class_name Foo extends Node` |
| `this.` | `self.` (rarely needed) |
| `async/await` | `await signal_name` |
| `===` | `==` (no triple-equals) |
| `!==` | `!=` |
| `&&` | `and` |
| `\|\|` | `or` |
| `!` | `not` |
| `null` | `null` |
| `undefined` | N/A (use `null`) |
| `import X from Y` | N/A (autoload or preload) |
| `export` | `@export` (decorator) |

**Type hints:**

```gdscript
# TypeScript
function calculateDamage(base: number, armor: number): number {}

# GDScript
func calculate_damage(base: float, armor: float) -> float:
    return base - armor * 0.5
```

---

## Tips for AI Coding Assistance

### When Using Copilot/Cascade:

1. **Add type hints everywhere** - helps AI understand context
2. **Use descriptive variable names** - better suggestions
3. **Write doc comments** - AI learns your patterns
4. **Start with function signature** - AI completes the body

**Example:**

```gdscript
## Spawns an enemy at a random position off-screen.
##
## @param enemy_type: Type of enemy to spawn (e.g., "scrap_shambler")
## @param wave_number: Current wave (affects stats)
## @return: The spawned enemy node
func spawn_enemy(enemy_type: String, wave_number: int) -> Enemy:
    # Copilot will suggest the implementation here
```

### When Using Claude Code (Terminal):

```bash
# From scrap-survivor-godot directory
claude "convert this TypeScript service to GDScript: [paste code]"
claude "implement the weapon system with damage calculation and cooldowns"
claude "review scripts/systems/wave_system.gd for performance issues"
claude "add error handling to scripts/services/supabase_service.gd"
```

---

## Common Issues

### Issue: Autocomplete not working

**Solution:**
1. Ensure Godot Editor is **running** with project open
2. Check LSP connection in VS Code status bar (bottom-right)
3. Restart VS Code LSP: **Cmd+Shift+P → "Reload Window"**

### Issue: Double-click in Godot doesn't open VS Code

**Solution:**
1. Verify editor settings: **Editor → Editor Settings → Text Editor → External**
2. Check "Use External Editor" is enabled
3. Verify Exec Path is correct

### Issue: Format on save not working

**Solution:**
1. Install `gdtoolkit`: `pip3 install "gdtoolkit==4.*"`
2. Verify `.vscode/settings.json` has `"editor.formatOnSave": true`
3. Restart VS Code

### Issue: AI doesn't understand GDScript syntax

**Solution:**
Add this to your prompt/chat:

> I'm using GDScript (Godot 4.4). It's Python-like with static typing.
> Use `func`, `var`, `const`, type hints like `: int`, and `->` for return types.

---

## Next Steps

1. **Open project in your editor:**
   ```bash
   cd ~/Developer/scrap-survivor-godot
   code .  # VS Code
   # or
   windsurf .  # Windsurf
   ```

2. **Configure Godot:**
   ```bash
   bash ../scrap-survivor/scripts/godot/configure-editor.sh
   ```

3. **Test the integration:**
   - Open Godot
   - Double-click a `.gd` file
   - Should open in VS Code/Windsurf

4. **Start coding with AI assistance!**

---

## Resources

- **Godot Tools Extension:** https://github.com/godotengine/godot-vscode-plugin
- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **GDScript Reference:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
- **gdtoolkit (linter/formatter):** https://github.com/Scony/godot-gdscript-toolkit

---

**You're all set!** 🎮🚀

Start writing GDScript with full AI assistance in your preferred editor.
