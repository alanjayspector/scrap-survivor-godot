# Godot Headless Mode Custom Resource Class Loading - Complete CI/CD Guide

## Quick Start (TL;DR)

For most projects, add this single command before your test/export commands:

```bash
godot --headless --editor --quit-after 2
```

This generates the script class cache in ~1-2 seconds, enabling custom Resource classes to work in headless mode.

**Why this works:** Godot needs 2 frame cycles to complete deferred import operations. See [Godot Issue #77508](https://github.com/godotengine/godot/issues/77508) for technical details.

---

## Problem Overview

When running Godot in headless mode for CI/CD testing with custom Resource classes that use `class_name`, the engine fails to find and load these classes, resulting in errors like:

```
ERROR: Cannot get class 'WeaponResource'.
ERROR: res://resources/weapons/rusty_pistol.tres:5 - Parse Error: Can't create sub resource of type 'WeaponResource'.
ERROR: Failed loading resource: res://resources/weapons/rusty_pistol.tres.
```

The root cause is that headless mode doesn't properly generate or update the `.godot/global_script_class_cache.cfg` file that contains the mapping of all global script classes in your project.

---

## Technical Root Cause

In Godot 4.x, the script class cache system works as follows:

1. **Script Class Discovery**: When the Godot editor loads, it scans all GDScript files with `class_name` declarations
2. **Cache Generation**: Results are stored in `.godot/global_script_class_cache.cfg`
3. **Import Process**: This cache file must be generated before any Resources or exports can properly resolve custom classes
4. **Headless Limitation**: The `--headless` flag alone bypasses the normal editor initialization that triggers this scanning process
5. **Timing Issue**: Using `--quit` or `--quit-after 1` exits too quickly before deferred import operations complete

### Key Discovery (Issue #77508)

The Godot team identified that resource import happens after `call_deferred()` or in spawned threads. This means:

- `--quit` exits immediately (before import completes) ❌
- `--quit-after 1` exits after 1 frame (still too early) ❌
- `--quit-after 2` waits 2 frames (allows deferred operations to finish) ✅

**Reference:** [Godot Issue #77508 - Resource import fails with --quit](https://github.com/godotengine/godot/issues/77508)

---

## Solution Strategies (Ranked by Effectiveness)

### Strategy 1: Editor Initialization Phase with --quit-after 2 (Recommended)

This is the most reliable and fastest approach for CI/CD pipelines.

**Implementation:**

```bash
# Step 1: Generate cache (takes ~1-2 seconds)
godot --headless --editor --quit-after 2

# Step 2: Run your tests or export
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests
```

**Key Points:**

- `--headless`: Run without GUI
- `--editor`: Initialize editor subsystems (required for class scanning)
- `--quit-after 2`: Wait exactly 2 frame cycles for import threads to complete

**GitHub Actions Example:**

```yaml
name: Godot Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.3.1

      - name: Generate script class cache
        run: godot --headless --editor --quit-after 2

      - name: Run GUT tests
        run: godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests
```

**Pros:**
- Extremely fast (~1-2 seconds)
- Works reliably regardless of project size
- No version control of generated files needed
- Completely automated

**Cons:**
- Requires Godot 4.x (cache system changed from 3.x)
- Adds one extra step to CI pipeline

---

### Strategy 2: Git-Track the Cache File

Good for projects where Strategy 1 doesn't work or as a backup.

**Implementation:**

1. Modify `.gitignore` to allow the cache file:

```gitignore
/.godot/**/*.*
!/.godot/global_script_class_cache.cfg
```

2. Generate the cache locally:

```bash
# Open editor in headless mode
godot --headless --editor --quit-after 2
```

3. Commit the generated file:

```bash
git add .godot/global_script_class_cache.cfg
git commit -m "Add global script class cache for CI"
```

4. In CI, the file will already be present when the headless process runs

**Pros:**
- Simple and straightforward
- Works with all Godot 4.x versions
- Zero CI overhead (no generation step needed)
- Guaranteed to work

**Cons:**
- Cache file needs manual regeneration when new `class_name` scripts are added
- Version control contains generated file (not ideal for purists)
- Can cause merge conflicts in team environments

**Reference:** [Godot Issue #75684 - Cache not generated in headless exports](https://github.com/godotengine/godot/issues/75684)

---

### Strategy 3: GUT Framework Cache Updater (Advanced)

For projects using the GUT testing framework.

**Implementation:**

```bash
# Generate cache using GUT's built-in utility
godot --headless -s addons/gut/cli/global_script_class_cache_updater.gd

# Then run tests
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests
```

**Pros:**
- Purpose-built for GUT framework
- More control over the scanning process
- Doesn't require `--editor` flag overhead

**Cons:**
- Only works if using GUT framework
- Requires GUT to be installed and up-to-date
- Unofficial solution (maintained by GUT, not Godot core)

---

### Strategy 4: GdUnit4 Testing Framework with CI Action

If you're using GdUnit4 for testing, use their official GitHub Action:

```yaml
- uses: MikeSchulze/gdunit4-action@v1
  with:
    godot-version: '4.3.1'
    paths: 'res://tests'
```

This action automatically:
- Downloads Godot
- Generates the script class cache
- Runs your tests
- Reports results

**Pros:**
- Battle-tested for CI
- Automatic cache handling
- Built-in test reporting

**Cons:**
- Only for GdUnit4 framework
- Less flexibility for custom workflows

---

## Known Limitation: Runtime Directory Scanning + Dynamic Loading

**Important:** Even with a properly generated cache, dynamically iterating directories and loading resources may still fail in headless mode:

```gdscript
# This pattern is problematic in headless mode:
func test_all_weapons_load():
    var dir = DirAccess.open("res://resources/weapons/")
    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(".tres"):
            var weapon: WeaponResource = load("res://resources/weapons/" + file_name)  # ❌ May still fail
            assert_not_null(weapon)
        file_name = dir.get_next()
```

### Why This Fails

The `load()` function at runtime in headless mode doesn't always respect the cache file for dynamically constructed paths. The resource loader may attempt to instantiate the class before the cache is fully integrated into the runtime.

### Solution: Use Preloaded Arrays

```gdscript
# Preload all resources as constants at parse time
const ALL_WEAPONS = [
    preload("res://resources/weapons/rusty_pistol.tres"),
    preload("res://resources/weapons/void_cannon.tres"),
    preload("res://resources/weapons/plasma_cutter.tres"),
    # ... etc
]

func test_all_weapons_load():
    for weapon in ALL_WEAPONS:
        assert_not_null(weapon, "Weapon should load")
        assert_gt(weapon.get_dps(), 0.0, "Should have positive DPS")
```

**Why This Works:**

- `preload()` happens at parse time, not runtime
- Godot's parser has full access to the project structure
- Resources are embedded into the script bytecode
- No dynamic path resolution required

### Alternative: Preload Resource Script

For cases where you must use `load()`, at minimum preload the Resource class script:

```gdscript
# Force the Resource class to be registered
const _WEAPON_RESOURCE_SCRIPT = preload("res://scripts/resources/weapon_resource.gd")

# Now runtime load() has a better chance of working
func test_weapon_loads():
    var weapon: WeaponResource = load("res://resources/weapons/rusty_pistol.tres")
    assert_not_null(weapon)
```

This isn't guaranteed to work in all cases, but improves reliability.

---

## Complete CI/CD Pipeline Example

### Pre-commit Hook for Local Testing

```python
#!/usr/bin/env python3
# .system/validators/godot_test_runner.py

import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
GODOT_EXECUTABLE = "/Applications/Godot.app/Contents/MacOS/Godot"  # Adjust for your platform
GUT_CLI_SCRIPT = "res://addons/gut/gut_cmdln.gd"
TEST_DIR = "res://scripts/tests/"

def run_gut_tests():
    """Run all GUT tests in headless mode with proper class registration."""

    # Step 1: Generate script class cache (2 frames is sufficient)
    print("Generating script class cache...")
    scan_result = subprocess.run(
        [
            GODOT_EXECUTABLE,
            "--headless",
            "--editor",
            "--path", str(PROJECT_ROOT),
            "--quit-after", "2"  # Critical: wait 2 frames for import threads
        ],
        capture_output=True,
        timeout=60
    )

    # Step 2: Verify cache was created
    cache_path = PROJECT_ROOT / ".godot" / "global_script_class_cache.cfg"
    if not cache_path.exists():
        print("ERROR: Cache file not created!")
        return False

    print("✓ Cache created successfully")

    # Step 3: Run tests with cache available
    print("Running tests...")
    result = subprocess.run(
        [
            GODOT_EXECUTABLE,
            "--headless",
            "--path", str(PROJECT_ROOT),
            "-s", GUT_CLI_SCRIPT,
            f"-gdir={TEST_DIR}",
            "-gexit"
        ],
        capture_output=True,
        timeout=60
    )

    return result.returncode == 0

if __name__ == "__main__":
    import sys
    sys.exit(0 if run_gut_tests() else 1)
```

### GitHub Actions Workflow (Complete Example)

```yaml
name: Godot CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        godot-version: ['4.2.2', '4.3.1']

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v2
        with:
          version: ${{ matrix.godot-version }}
          use-mono: false

      - name: Generate script class cache
        run: godot --headless --editor --quit-after 2
        timeout-minutes: 2

      - name: Verify cache was created
        run: |
          if [ ! -f ".godot/global_script_class_cache.cfg" ]; then
            echo "ERROR: Cache file not found!"
            exit 1
          fi
          echo "✓ Cache file exists"

      - name: Run unit tests
        run: godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
        timeout-minutes: 5

      - name: Export release build
        if: github.ref == 'refs/heads/main'
        run: godot --headless --export-release "Linux/X11" ./builds/game.x86_64

      - name: Upload artifact
        if: success() && github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v3
        with:
          name: godot-build-${{ matrix.godot-version }}
          path: ./builds/
```

### Local Development Workflow

```bash
#!/bin/bash
# scripts/run-tests.sh - Run full test suite locally

set -e

echo "=== Godot Test Suite ==="

# Step 1: Generate cache
echo "Generating script class cache..."
godot --headless --editor --quit-after 2

# Step 2: Verify cache
if [ ! -f ".godot/global_script_class_cache.cfg" ]; then
    echo "ERROR: Cache file not created!"
    exit 1
fi
echo "✓ Cache created"

# Step 3: Run tests
echo "Running tests..."
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://scripts/tests/ -gexit

echo "=== All Tests Passed ==="
```

---

## Best Practices for Custom Resources in CI

1. **Always use `class_name`** - Never rely on script path references for custom Resources
2. **Use `preload()` for test resources** - Avoid `load()` with dynamic paths in tests when possible
3. **Preload resource class scripts** - At minimum, `const _CLASS = preload("res://path/to/resource.gd")`
4. **Avoid parameter-based `_init()`** - Use zero-parameter initialization or setters for Resources
5. **Use `--quit-after 2` not higher values** - More frames doesn't help and wastes time
6. **Always include `--editor` flag** - Required for script class scanning even in headless mode
7. **Add timeout protection** - Wrap all headless commands with timeouts (e.g., 2 minutes max)
8. **Verify cache in CI** - Add explicit check that cache file was created
9. **Test locally first** - Run the exact CI commands locally before pushing
10. **Document class dependencies** - Comment which Resource classes extend which base classes

---

## Testing Custom Resource Loading in Headless Mode

### Minimal Test Case (Using Preload Pattern)

```gdscript
# res://tests/test_resource_loading.gd
extends GutTest

class_name TestResourceLoading

# Preload the Resource class script (required for headless)
const _CUSTOM_RESOURCE_SCRIPT = preload("res://scripts/resources/custom_resource.gd")

# Preload actual resource (most reliable)
const TEST_RESOURCE = preload("res://resources/test_custom_resource.tres")

func test_custom_resource_loads():
    assert_not_null(TEST_RESOURCE, "Resource should load successfully")
    assert_true(TEST_RESOURCE is CustomResource, "Should be correct class type")

func test_custom_resource_properties():
    assert_eq(TEST_RESOURCE.data, "expected_value")
    assert_eq(TEST_RESOURCE.number, 42)

# If you MUST use dynamic load(), preload the script first
func test_dynamic_load_with_preloaded_script():
    var resource = load("res://resources/test_custom_resource.tres") as CustomResource
    assert_not_null(resource, "Dynamic load should work with preloaded script")
```

### Verify Cache Generation Script

```gdscript
# res://scripts/utils/verify_cache.gd
extends Node

func _enter_tree():
    var cache_file = ".godot/global_script_class_cache.cfg"

    if not FileAccess.file_exists(cache_file):
        printerr("ERROR: Cache file not found at: ", cache_file)
        get_tree().quit(1)
        return

    var cache = FileAccess.open(cache_file, FileAccess.READ)
    var content = cache.get_as_text()
    cache.close()

    # Check for specific class names
    var required_classes = ["WeaponResource", "EnemyResource", "ItemResource"]
    var missing_classes = []

    for class_name in required_classes:
        if class_name not in content:
            missing_classes.append(class_name)

    if missing_classes.size() > 0:
        printerr("ERROR: Missing classes in cache: ", missing_classes)
        print("Cache contents preview:")
        print(content.substr(0, 500))  # Print first 500 chars
        get_tree().quit(1)
        return

    print("✓ Cache verification passed - all required classes found")
    get_tree().quit(0)
```

Run this verification in CI:

```yaml
- name: Verify cache contents
  run: godot --headless -s res://scripts/utils/verify_cache.gd
```

---

## Debugging Checklist

If custom Resources still aren't loading in headless mode, check these in order:

- [ ] **Cache file exists**: Verify `.godot/global_script_class_cache.cfg` is present
- [ ] **Cache has your classes**: `grep "YourClassName" .godot/global_script_class_cache.cfg`
- [ ] **Using `--editor` flag**: Must include `--editor` in cache generation command
- [ ] **Using `--quit-after 2`**: Not `--quit`, not `--quit-after 1`, exactly `2`
- [ ] **No syntax errors**: Check all Resource scripts compile without errors
- [ ] **Proper base class**: Resource scripts use `extends Resource` or valid Resource parent
- [ ] **`class_name` at top**: Ensure `class_name` declaration is before `extends`
- [ ] **Preload resource script**: Add `const _SCRIPT = preload("res://path/to/resource.gd")`
- [ ] **Prefer `preload()` over `load()`**: Use preloaded constants for test resources
- [ ] **Check paths use `res://`**: All resource paths must use the `res://` prefix
- [ ] **No circular dependencies**: Check for circular class inheritance chains
- [ ] **Try in GUI mode**: Open project normally once to verify resources load in editor

---

## Common Errors and Solutions

### Error: "Cannot get class 'CustomResource'"

**Cause:** Script class cache not generated or incomplete.

**Solution:**
```bash
# Run cache generation with proper flags
godot --headless --editor --quit-after 2

# Verify cache was created
ls -la .godot/global_script_class_cache.cfg
```

### Error: "Parse Error: Can't create sub resource of type"

**Cause:** Resource's base class not found in cache.

**Solution:**
1. Check that the Resource class script has `class_name` declaration
2. Ensure base classes are loaded before derived classes
3. Preload the resource class script in your test file:
```gdscript
const _RESOURCE_SCRIPT = preload("res://scripts/resources/your_resource.gd")
```

### Error: "Failed loading resource: res://path/to/resource.tres"

**Cause:** Dynamic `load()` failing even with cache present.

**Solution:** Use `preload()` instead of `load()`:
```gdscript
# Instead of:
var resource = load("res://path/to/resource.tres")  # ❌

# Use:
const RESOURCE = preload("res://path/to/resource.tres")  # ✅
```

---

## Summary Table

| Strategy | Setup Time | CI Time | Reliability | Maintenance | Notes |
|----------|-----------|---------|-------------|-------------|-------|
| `--quit-after 2` | Low | ~2 sec | Highest | None | **Recommended** |
| Git-track cache | Low | 0 sec | High | Manual updates | Good backup strategy |
| GUT cache updater | Medium | ~3 sec | High | GUT updates | Framework-specific |
| GdUnit4 Action | Low | ~5 sec | Highest | None | Only for GdUnit4 |

**Recommendation:**
1. **Start here:** Strategy 1 (`--quit-after 2`) for all new projects
2. **Use preload pattern** for test resources to avoid dynamic loading issues
3. **Fallback:** Strategy 2 (git-track) if your CI environment has issues
4. **Framework users:** Use Strategy 3 or 4 if already using GUT/GdUnit4

---

## References

- [Godot Issue #77508](https://github.com/godotengine/godot/issues/77508) - Resource import fails with --quit (timing issue)
- [Godot Issue #75684](https://github.com/godotengine/godot/issues/75684) - Cache not generated in headless exports
- [Godot Issue #71521](https://github.com/godotengine/godot/issues/71521) - Headless export fails if project never opened
- [GUT Testing Framework](https://github.com/bitwes/Gut) - Godot Unit Testing framework
- [GdUnit4 Framework](https://github.com/MikeSchulze/gdUnit4) - Alternative testing framework

---

## Changelog

- **2025-01**: Updated with `--quit-after 2` timing fix from Issue #77508
- **2025-01**: Added preload pattern workaround for dynamic loading
- **2025-01**: Clarified `--editor` flag requirement
- **2024-12**: Initial documentation based on Issue #75684

---

*This guide is based on real-world CI/CD implementation and extensive testing with Godot 4.2-4.3. Last updated: January 2025.*
