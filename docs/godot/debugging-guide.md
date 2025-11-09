# Godot Debugging Guide

Complete guide to debugging GDScript in Godot 4.5.1

---

## 🎯 Systematic Debugging Workflow

**When you encounter an issue, follow this order for fastest resolution:**

### 1. Check Community Research FIRST (80% of issues solved here)

**See [../godot-community-research.md](../godot-community-research.md)** for:

**Common Issues & Solutions:**
- Collision layer/mask confusion → "Layer = where it IS, Mask = what it SEES"
- Jitter/stutter in movement → Enable physics interpolation or increase tick rate
- Memory leaks in scenes → Use `queue_free()` not `free()`
- Sprite flickering → Set texture filter to NEAREST for pixel art
- Animation not triggering → Check state machine pattern, don't call `play()` every frame

**Critical Anti-Patterns (check your code for these):**
- `get_parent().get_parent()` chains → Refactor to signals or cached `@onready` refs
- `get_node()` in `_process()` → Cache in `_ready()` with `@onready`
- Missing type hints → Add `-> ReturnType` and `: Type` for better errors
- Polling every frame → Use Area2D signals or state change events

**Why check here first:** Community has debugged thousands of Godot projects. Your issue is likely documented with a solution.

---

### 2. Use Godot Built-in Debugger (this guide below)

If community research doesn't solve it:
- Set breakpoints and inspect variables
- Use profiler to find performance bottlenecks
- Check console for runtime errors

---

### 3. Consult Official Documentation

**See [../godot-reference.md](../godot-reference.md)** for quick links to:
- Class API reference (understand method signatures)
- Tutorial deep-dives (learn correct patterns)
- Performance optimization guides

---

### 4. Ask Community (last resort)

**If above steps don't help:**
- **Forum**: https://forum.godotengine.org/ (search first!)
- **Reddit**: r/godot (active community, quick responses)
- **GitHub Issues**: For confirmed bugs in Godot engine

**When asking, provide:**
- Godot version (4.4 stable, etc.)
- Minimal reproducible example
- What you've already tried (from steps 1-3 above)
- Expected vs actual behavior

---

## 🐛 Built-in Godot Debugger

Godot has a **powerful built-in debugger** that runs in the editor. It's similar to Chrome DevTools but for game development.

### Accessing the Debugger

1. **Open Godot Editor**
2. **Run your game** (F5)
3. **Debugger panel** opens at bottom of editor automatically

**Debugger tabs:**
- **Errors** - Runtime errors and warnings
- **Debugger** - Stack traces, breakpoints, variable inspection
- **Profiler** - Performance profiling
- **Network Profiler** - Network requests (Supabase calls)
- **Monitors** - FPS, memory, object count

---

## 🎯 Breakpoints

### Setting Breakpoints

**In Godot Editor:**
1. Open a `.gd` file in the built-in script editor
2. Click in the **gutter** (left of line numbers)
3. Red dot appears = breakpoint set
4. Run game (F5) → execution pauses at breakpoint

**In VS Code/Windsurf:**
- Set breakpoints as usual (click gutter)
- **BUT**: They only work if using Godot's external editor mode
- Godot must be running with `--remote-debug` flag

### Breakpoint Actions

When paused at breakpoint:
- **Step Over** (F10) - Execute current line, don't enter functions
- **Step Into** (F11) - Enter function calls
- **Step Out** (Shift+F11) - Exit current function
- **Continue** (F12) - Resume execution

---

## 🔍 Variable Inspection

### In Godot Debugger

When paused:
1. **Stack Frames** panel shows call stack
2. Click on a frame → see all variables in that scope
3. **Inspect** panel shows:
   - Local variables
   - Member variables (`self.*`)
   - Global autoload singletons

**Hover over variables** in code to see values.

### Print Debugging

**Basic print:**
```gdscript
print("Health: ", health)
# Output: Health: 100.0
```

**Formatted print:**
```gdscript
print("Player at (%d, %d)" % [position.x, position.y])
# Output: Player at (150, 200)
```

**Debug-only print:**
```gdscript
if OS.is_debug_build():
    print("Debug mode: Enemy spawned at ", position)
```

**Colored console output:**
```gdscript
print_rich("[color=yellow]Warning:[/color] Low health!")
print_rich("[color=red]Error:[/color] Connection failed")
print_rich("[color=green]Success:[/color] Loaded weapon")
```

**Stack trace:**
```gdscript
print_stack()  # Prints current call stack
```

---

## 📊 Profiler

### Performance Profiling

1. **Run game** (F5)
2. Open **Profiler** tab
3. Click **Start** to begin profiling
4. Play the game
5. Click **Stop**

**What it shows:**
- **Frame time** - Time per frame (should be < 16ms for 60 FPS)
- **Physics time** - Time spent in `_physics_process()`
- **Script time** - Time spent in GDScript
- **Function calls** - Which functions are slowest

**Hotspots:**
- Red = slow (> 5ms)
- Yellow = moderate (1-5ms)
- Green = fast (< 1ms)

### Memory Profiling

**Monitors tab shows:**
- **Objects** - How many nodes in scene tree
- **Resources** - Loaded assets (textures, sounds)
- **Memory** - RAM usage
- **Orphan resources** - Memory leaks (should be 0)

**Check for leaks:**
```gdscript
# In your game's cleanup code
if OS.is_debug_build():
    print("Orphan nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
```

---

## 🌐 Network Debugging (Supabase)

### Monitor Supabase Calls

**Network Profiler tab:**
- Shows all HTTP requests
- Request method, URL, status code
- Response time
- Payload size

**Manual logging:**
```gdscript
# In your SupabaseService wrapper
func _make_request(method: String, endpoint: String, data: Dictionary) -> Dictionary:
    if OS.is_debug_build():
        print_rich("[color=cyan]Supabase:[/color] %s %s" % [method, endpoint])
        print("Payload: ", JSON.stringify(data))

    var result = await supabase.request(method, endpoint, data)

    if OS.is_debug_build():
        print_rich("[color=green]Response:[/color] %d" % result.status_code)

    return result
```

---

## 🔧 Remote Debugging

### Debug on Mobile Device

**Setup:**
1. Build and install debug APK/IPA on device
2. Connect device to same WiFi as dev machine
3. In Godot: **Debug → Deploy with Remote Debug**
4. Enter device IP address
5. Run game on device

**Now you can:**
- See console output from device in Godot editor
- Set breakpoints in Godot editor
- Profile performance on actual hardware

**Find device IP:**
```bash
# Android
adb shell ip addr show wlan0

# iOS
Settings → WiFi → (i) → IP Address
```

### VS Code Remote Debugging

**Not officially supported** for GDScript, but you can use:

1. **Godot Editor as debugger** (recommended)
2. **Print debugging** with rich output
3. **Custom debug overlay** (create in-game debug panel)

---

## 🎮 In-Game Debug Overlay

### Create Debug Panel

**Example:**
```gdscript
# scripts/utils/debug_overlay.gd
extends CanvasLayer

@onready var label: Label = $Label

func _ready() -> void:
    if not OS.is_debug_build():
        queue_free()  # Remove in release builds

func _process(delta: float) -> void:
    var fps := Engine.get_frames_per_second()
    var memory := Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024
    var objects := Performance.get_monitor(Performance.OBJECT_COUNT)

    label.text = """
    FPS: %d
    Memory: %.1f MB
    Objects: %d
    Wave: %d
    Enemies: %d
    """ % [fps, memory, objects, GameManager.current_wave, get_tree().get_nodes_in_group("enemies").size()]
```

**Add to project:**
1. Create scene with `CanvasLayer` root
2. Add `Label` node
3. Attach script above
4. **Project → Project Settings → Autoload**
5. Add as singleton: `DebugOverlay`

---

## 🚨 Error Handling

### Try/Catch (GDScript doesn't have it)

**Use signals instead:**
```gdscript
signal operation_failed(error: String)

func risky_operation() -> void:
    var result = await supabase.auth.sign_in(email, password)

    if result.error:
        operation_failed.emit(result.error.message)
        return

    # Success path
    print("Signed in successfully")

# Connect in _ready()
operation_failed.connect(_on_operation_failed)

func _on_operation_failed(error: String) -> void:
    print_rich("[color=red]Error:[/color] ", error)
    # Show error UI
```

### Assert for Development

```gdscript
func calculate_damage(base: float, armor: float) -> float:
    assert(base > 0, "Base damage must be positive")
    assert(armor >= 0, "Armor cannot be negative")

    return max(1, base - armor * 0.5)
```

**Asserts only fire in debug builds!**

---

## 📝 Logging Levels

### Create Logger Utility

```gdscript
# scripts/utils/logger.gd
extends Node

enum Level {
    DEBUG,
    INFO,
    WARN,
    ERROR
}

const COLORS = {
    Level.DEBUG: "gray",
    Level.INFO: "white",
    Level.WARN: "yellow",
    Level.ERROR: "red"
}

func log(message: String, level: Level = Level.INFO) -> void:
    if level == Level.DEBUG and not OS.is_debug_build():
        return  # Skip debug logs in release

    var color := COLORS[level]
    var prefix := Level.keys()[level]

    print_rich("[color=%s][%s][/color] %s" % [color, prefix, message])

func debug(message: String) -> void:
    log(message, Level.DEBUG)

func info(message: String) -> void:
    log(message, Level.INFO)

func warn(message: String) -> void:
    log(message, Level.WARN)

func error(message: String) -> void:
    log(message, Level.ERROR)
```

**Usage:**
```gdscript
Logger.debug("Player position: %v" % position)
Logger.info("Wave %d started" % wave_number)
Logger.warn("Low health: %d" % health)
Logger.error("Failed to connect to server")
```

---

## 🔍 Systematic Debugger (Migrated)

### Status

**From original repo** (`.system/meta/*.ts`):
- ✅ **Migrated** - TypeScript reference files
- ⏳ **Adaptation needed** - Convert to GDScript (Week 3-4)

**Original tools:**
- `health-monitor.ts` - System health checks
- `pattern-extractor.ts` - Pattern validation
- `source-of-truth.ts` - Single source of truth validation

**Godot equivalent (future):**
- Week 3-4: Port to GDScript autoload
- Create `SystemHealthMonitor` singleton
- Integrate with Godot debugger UI
- Log to `.system/logs/` as before

### Current Debugging Setup

**Available now:**
1. ✅ **Godot built-in debugger** - Breakpoints, stack traces, profiler
2. ✅ **Print debugging** - Rich console output
3. ✅ **Git hooks** - Pre-commit validation (catches issues early)
4. ✅ **GitHub Actions** - CI/CD validation
5. ✅ **Pattern validators** - `.system/validators/check-patterns.sh`

**Not yet available:**
- ⏳ Systematic health monitor (Week 3-4)
- ⏳ Automated drift detection (Week 3-4)
- ⏳ Pattern learning system (Week 8-10)

---

## 🎯 Debugging Workflow

### Recommended Flow

1. **Development:**
   - Write code in VS Code/Windsurf with Copilot/Cascade
   - Save → Godot auto-reloads script

2. **Testing:**
   - Press F5 in Godot to run
   - Watch console for print statements
   - Check debugger for errors

3. **Debugging:**
   - Set breakpoints in Godot script editor
   - Step through code
   - Inspect variables

4. **Profiling:**
   - Run profiler to find performance issues
   - Optimize hotspots
   - Verify FPS stays at 60

5. **Before Commit:**
   - Pre-commit hook runs automatically
   - Fixes any linting/formatting issues
   - Validates patterns

6. **After Push:**
   - GitHub Actions run
   - CI validates everything
   - Merge if green

---

## 📚 Resources

- **Godot Debugger Docs:** https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html
- **Profiling Guide:** https://docs.godotengine.org/en/stable/tutorials/performance/using_the_profiler.html
- **Remote Debugging:** https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html

---

## ✅ Quick Reference

| Task | Tool | Shortcut |
|------|------|----------|
| Run game | Godot | F5 |
| Set breakpoint | Godot | Click gutter |
| Step over | Godot | F10 |
| Step into | Godot | F11 |
| Continue | Godot | F12 |
| Print to console | Code | `print()` |
| Colored print | Code | `print_rich()` |
| Stack trace | Code | `print_stack()` |
| Profile performance | Godot | Profiler tab |
| Monitor memory | Godot | Monitors tab |
| Check network | Godot | Network Profiler |

---

**Godot's debugger is production-ready!** You have all the tools you need for systematic debugging. 🐛🔍
