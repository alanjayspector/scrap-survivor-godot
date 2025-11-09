# Godot Pre-Commit Testing Guide

## Problem
Need to automate Godot tests in pre-commit hooks while keeping the editor open during development. Godot locks the project file when the editor is open, making concurrent instances seem impossible.

## Solution Overview
Run tests via headless Godot instances in separate processes. Headless instances can access projects in read-only mode without conflicting with the editor.

## Recommended Approach: GUT Framework

### Setup
1. Install GUT addon in your Godot project (via Godot Asset Library or copy to `addons/gut/`)
2. Create test files in `res://test/` directory using `*_test.gd` naming convention
3. Create `.git/hooks/pre-commit` script

### Pre-Commit Hook Script
```bash
#!/bin/sh

if godot -d -s --path project addons/gut/gut_cmdln.gd -gdir=res://test/ -gprefix="" -gsuffix="_test.gd" -gexit
then
    echo "Tests passed"
else
    cat <<EOF
Unit tests failed. Commit aborted.
EOF
    exit 1
fi
```

**Make executable:** `chmod +x .git/hooks/pre-commit`

### Command Flags Explained
- `-d`: Daemon mode (no editor window)
- `-s`: Run script
- `--path project`: Path to your Godot project
- `-gdir=res://test/`: Test directory
- `-gprefix=""`: No prefix filter
- `-gsuffix="_test.gd"`: Only run files ending in _test.gd
- `-gexit`: Exit after tests complete (CRITICAL)

## Modern Alternative: GdUnit4

### Advantages
- Better CI/CD integration
- HTML report generation
- JUnit XML export
- Explicit headless mode support

### Command
```bash
godot --headless -s addons/gdunit4/runner/GdUnitCommandLineRunner.gd
```

## Addressing Project Lock Issues

### Why It Works
- Editor locks project for writing when open
- Headless instances access project in read-only mode
- No exclusive lock conflict occurs

### If Lock Issues Persist: Solutions

#### Option 1: Temporary Copy
Create symbolic link or copy of project specifically for pre-commit testing

#### Option 2: Editor Headless Warm-up
```bash
godot --editor --headless res://SomeScene.tscn
godot -d -s addons/gut/gut_cmdln.gd ...
```

#### Option 3: Server Export Template
Build dedicated server/headless export template for testing. Separate binary won't conflict with editor.

## Workflow Integration

### With VS Code + Godot Editor
1. Keep editor open for graphics/testing
2. Run pre-commit hook on every commit
3. Headless tests run in background without interference
4. Bypass with: `git commit --no-verify -m "message"`

### Project Structure
```
project/
├── .git/hooks/
│   └── pre-commit
├── project.godot
├── src/
│   └── game_code.gd
├── addons/
│   ├── gut/
│   └── gdunit4/
└── test/
    └── *_test.gd
```

## Advanced: Pre-commit Framework (Python)

For standardized hook management across team:

### `.pre-commit-config.yaml` Example
```yaml
repos:
  - repo: local
    hooks:
      - id: godot-tests
        name: Godot Tests
        entry: .git/hooks/pre-commit-godot
        language: script
        stages: [commit]
```

## Critical Implementation Details

### Must-Have Flags
- **`-gexit`**: Ensures process terminates after tests (prevents hook hanging)
- **`-d`**: Daemon mode prevents window from appearing
- **`-s`**: Script mode runs test runner

### Test File Naming
GUT looks for files matching pattern: `*_test.gd`

### Example Test File
```gdscript
extends GutTest

func test_example():
    assert_true(true)

func test_calculation():
    var result = 2 + 2
    assert_eq(result, 4)
```

## Troubleshooting

### Hook Not Running
- Verify executable: `ls -la .git/hooks/pre-commit`
- Should show `x` permission: `chmod +x .git/hooks/pre-commit`

### Tests Pass Locally But Fail in Hook
- Check working directory path in hook script
- Verify GUT addon path is correct relative to project root

### Process Hangs
- Ensure `-gexit` flag is present
- Check for infinite loops in test code
- Add timeout to hook script if necessary

### Lock Conflicts
- Verify editor is not modifying files during test run
- Use read-only mode if available: `godot --read-only ...`
- Consider separate test project copy for CI

## Multiple Instance Testing

For advanced scenarios (multiplayer/networking tests):

```bash
# Run multiple Godot instances via separate commands
godot -d -s --path project1 addons/gut/gut_cmdln.gd -gdir=res://test/ -gexit &
godot -d -s --path project2 addons/gut/gut_cmdln.gd -gdir=res://test/ -gexit &
wait
```

## Performance Tips

1. **Exclude heavy scenes**: Only load test dependencies, not full game
2. **Use lightweight test runners**: GUT/GdUnit4 designed for speed
3. **Cache resources**: Pre-load static assets if tests reuse them
4. **Parallel execution**: Run multiple test suites in parallel with background processes

## Integration with Development Flow

### Development Cycle
1. Write/modify code in VS Code
2. Test in Godot editor (play mode)
3. Commit changes
4. Pre-commit hook automatically runs headless tests
5. Commit proceeds if tests pass

### Bypass When Needed
```bash
git commit --no-verify -m "Work in progress"
```

## Resources

- GUT Documentation: https://gut.readthedocs.io
- GdUnit4: https://godotengine.org/asset-library/4.x/plugin/6925
- Godot Testing Guide: https://docs.godotengine.org/en/stable/tutorials/testing/unit_testing.html

---

## Our Current Implementation (Week 5)

We've built a **custom scene-based testing system** that works well for our needs:

### What We Built
- Test scenes in `scenes/tests/*_test.tscn`
- Test scripts in `scripts/tests/*_test.gd`
- Python wrapper: `.system/validators/godot_test_runner.py`
- Pre-commit integration via `.system/hooks/pre-commit`
- Naming convention: `*_test.gd` (GUT-compatible for future migration)

### When to Consider GUT/GdUnit4
- **Week 8+**: When setting up CI/CD (JUnit XML export valuable)
- **Test suite grows**: 20+ test files benefit from auto-discovery
- **Team expansion**: Framework provides standardization
- **Reporting needs**: HTML reports for stakeholders

### Current Advantages
- No external dependencies
- Easy to understand for Godot beginners
- Already working reliably
- Simple output parsing

### Migration Path
If we adopt GUT later:
1. Test files already follow `*_test.gd` convention ✓
2. Convert assertions from `assert()` to `assert_eq()`, etc.
3. Update test runner to call GUT cmdline
4. Gain HTML reports, better assertions, test discovery
