# .system/ - Project Health Enforcement

This directory contains automated validators and hooks that enforce project standards and catch configuration issues early.

## Purpose

The Weeks 1-4 validation revealed that while code implementation was correct, critical Godot-specific configuration was missing. This enforcement system now validates:

1. **Code Quality** (GDScript linting and formatting)
2. **Configuration Correctness** (project.godot settings)
3. **Data Integrity** (resource files match JSON sources)
4. **Documentation Completeness** (required docs exist)

## Structure

```
.system/
├── hooks/
│   └── pre-commit           # Git pre-commit hook (runs all validators)
├── validators/
│   ├── godot_config_validator.py    # Validates project.godot configuration
│   ├── resource_validator.py        # Validates .tres files match JSON
│   └── documentation_validator.py   # Validates required docs exist
├── git/                     # Git automation utilities
├── logs/                    # Validation logs
├── meta/                    # Project metadata
└── README.md               # This file
```

## Validators

### 1. Godot Configuration Validator

**What it catches:**
- ✅ Missing autoload registrations (would have caught CRIT-1)
- ✅ Missing input action mappings (would have caught CRIT-2)
- ✅ Autoload path mismatches
- ✅ Input actions referenced in code but not configured

**Run manually:**
```bash
python3 .system/validators/godot_config_validator.py
```

**What it does:**
1. Scans `scripts/autoload/` for services that need registration
2. Scans `scripts/services/` for Node-based services
3. Scans entity code for `Input.get_vector()` and `Input.is_action_*()` calls
4. Validates project.godot has corresponding [autoload] and [input] entries

### 2. Resource Validator

**What it catches:**
- ✅ Missing .tres files for items in JSON
- ✅ Count mismatches (e.g., 23 weapons in JSON but only 20 .tres files)
- ✅ Resource directories missing

**Run manually:**
```bash
python3 .system/validators/resource_validator.py
```

**What it does:**
1. Reads weapons.json, items.json, enemies.json
2. Counts expected resources
3. Verifies .tres files exist for each ID
4. Reports mismatches

### 3. Documentation Validator

**What it catches:**
- ✅ Missing required documentation files (would have caught MOD-1)
- ✅ Empty docs/godot/ directory
- ✅ Missing core project files

**Run manually:**
```bash
python3 .system/validators/documentation_validator.py
```

**What it does:**
1. Checks for README.md, .gitignore
2. Validates docs/godot/ required files exist per Week 1 Day 5

## Pre-commit Hook

The pre-commit hook runs automatically on `git commit` and validates:

1. **GDScript files** (if any .gd files staged):
   - gdlint (style and correctness)
   - gdformat (formatting)

2. **Project configuration** (always):
   - Godot config validator
   - Resource validator
   - Documentation validator

**Installation:**
The hook is symlinked during Week 1 Day 4:
```bash
ln -sf ../../.system/hooks/pre-commit .git/hooks/pre-commit
```

**Bypassing (emergency only):**
```bash
git commit --no-verify
```

## What This Would Have Caught

From the Weeks 1-4 validation:

| Issue | Severity | Validator | When |
|-------|----------|-----------|------|
| Missing autoload registration | CRITICAL | godot_config_validator | Week 4 commit |
| Missing input actions | CRITICAL | godot_config_validator | Week 1 commit |
| Missing architecture-decisions.md | MODERATE | documentation_validator | Week 1 Day 5 commit |
| .tres count mismatch | MODERATE | resource_validator | Week 3 commits |

## Evolution

This system will evolve with the project:

- **Week 5+**: Validate service dependencies
- **Week 8+**: Validate scene structure
- **Week 14+**: Run automated tests in hook
- **Week 16+**: Validate export configurations

## Philosophy

**Fail fast, fail early.**

It's better to catch a missing configuration at commit time than discover it hours later when testing. The validators are designed to:

1. ✅ Be fast (< 1 second total)
2. ✅ Give clear error messages
3. ✅ Auto-run on commit
4. ✅ Be easy to run manually
5. ✅ Never give false positives

## Lessons Learned

From the validation exercise:

1. **File existence ≠ Working configuration** - Must validate setup
2. **Code correctness ≠ Runtime correctness** - Must validate configuration
3. **Manual testing is not enough** - Automate validations
4. **Catch issues at commit time** - Not hours later

## References

- Validation Report: `docs/VALIDATION-REPORT.md`
- Weekly Action Items: `docs/godot-weekly-action-items.md`
