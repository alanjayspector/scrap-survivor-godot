# Week 6: Health Enforcement System Improvements

**Status:** Planned
**Priority:** Implement alongside Week 6 main work
**Based On:** Week 5 learnings and challenges

## Overview

Week 5 revealed several gaps in our health enforcement system. While we caught 90% of issues, these improvements will help us catch the remaining edge cases and prevent future disruptions.

## Improvement Priority Matrix

| Validator | Priority | When to Implement | Effort | Impact |
|-----------|----------|-------------------|--------|--------|
| Native Class Name Checker | HIGH | Week 6 Day 1 | Low | High |
| Service API Consistency | MEDIUM | Week 6 Day 2 | Medium | High |
| Integration Test Requirement | MEDIUM | Week 6 Day 3 | Low | Medium |
| Autoload Static Checker | LOW | Week 6 Day 4 | Low | Low |
| Documentation Coverage | LOW | Week 6 Day 5 | Low | Low |

---

## 1. Native Class Name Checker

**Priority:** HIGH
**Implement:** Week 6 Day 1 (before any new code)

### Problem Statement

Week 5 Challenge #1: `class_name Logger` conflicted with Godot's native Logger class, causing cascading parse errors across entire codebase.

**Impact:** Broke all files that used logging, required emergency fix, wasted ~30 minutes debugging

### Solution

Create validator that checks custom `class_name` declarations against Godot's built-in classes.

### Implementation

**File:** `.system/validators/native_class_checker.py`

```python
#!/usr/bin/env python3
"""
Native Class Name Checker

Validates that custom class_name declarations don't conflict with Godot's
native classes. Prevents catastrophic parse errors.

Exit Codes:
  0 - All class names are safe
  1 - Conflicts detected (blocking)
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent

# Godot 4.x native classes that are commonly conflicted with
# Source: https://docs.godotengine.org/en/stable/classes/
GODOT_NATIVE_CLASSES = {
    # Core classes
    "Logger", "Object", "RefCounted", "Resource", "Node",
    "Control", "CanvasItem", "Node2D", "Node3D",

    # Common UI
    "Button", "Label", "Panel", "Container", "VBoxContainer", "HBoxContainer",
    "ScrollContainer", "TabContainer", "Window", "PopupMenu",

    # 2D
    "Sprite2D", "AnimatedSprite2D", "Camera2D", "TileMap", "CollisionShape2D",
    "Area2D", "CharacterBody2D", "RigidBody2D", "StaticBody2D",

    # 3D
    "Sprite3D", "Camera3D", "MeshInstance3D", "CollisionShape3D",
    "Area3D", "CharacterBody3D", "RigidBody3D", "StaticBody3D",

    # Resources
    "Texture", "Texture2D", "Image", "Font", "Material", "Shader",
    "Animation", "AudioStream", "PackedScene",

    # Input/Output
    "Input", "InputEvent", "File", "FileAccess", "Directory", "DirAccess",

    # Utilities
    "Timer", "Tween", "HTTPRequest", "JSON", "RandomNumberGenerator",
    "PackedByteArray", "PackedInt32Array", "PackedFloat32Array",

    # Signals/Scripting
    "Signal", "Callable", "Variant", "GDScript", "Script",

    # Math
    "Vector2", "Vector3", "Vector4", "Rect2", "AABB", "Transform2D", "Transform3D",
    "Quaternion", "Basis", "Plane", "Color",

    # Add more as needed...
}


def find_class_name_conflicts(file_path: Path) -> List[Tuple[int, str, str]]:
    """
    Find class_name declarations that conflict with Godot natives.

    Returns:
        List of (line_number, class_name, conflict_type) tuples
    """
    conflicts = []

    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        for line_num, line in enumerate(lines, start=1):
            # Match: class_name ClassName
            match = re.match(r'^\s*class_name\s+(\w+)', line)
            if match:
                class_name = match.group(1)

                if class_name in GODOT_NATIVE_CLASSES:
                    conflicts.append((line_num, class_name, "native_class"))

                # Also check for common typos/variants
                if class_name.lower() in {c.lower() for c in GODOT_NATIVE_CLASSES}:
                    correct_name = next(c for c in GODOT_NATIVE_CLASSES if c.lower() == class_name.lower())
                    if class_name != correct_name:
                        conflicts.append((line_num, class_name, f"case_mismatch:{correct_name}"))

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")

    return conflicts


def main():
    """Check all GDScript files for native class name conflicts."""

    print("Checking for native class name conflicts...")

    all_conflicts = []
    checked_files = 0

    # Check all .gd files in project
    for gd_file in PROJECT_ROOT.rglob("*.gd"):
        # Skip addons directory
        if "addons" in gd_file.parts:
            continue

        checked_files += 1
        conflicts = find_class_name_conflicts(gd_file)

        if conflicts:
            all_conflicts.append((gd_file, conflicts))

    # Report results
    if not all_conflicts:
        print(f"{GREEN}✅ No native class name conflicts found ({checked_files} files checked){NC}")
        return 0

    print(f"\n{RED}❌ Found {len(all_conflicts)} file(s) with native class name conflicts:{NC}\n")

    for file_path, conflicts in all_conflicts:
        rel_path = file_path.relative_to(PROJECT_ROOT)
        print(f"{RED}{rel_path}:{NC}")

        for line_num, class_name, conflict_type in conflicts:
            if conflict_type == "native_class":
                print(f"  Line {line_num}: class_name '{class_name}' conflicts with Godot native class")
                print(f"  {YELLOW}💡 Fix: Rename to '{class_name}Custom' or 'Game{class_name}'{NC}")
            elif conflict_type.startswith("case_mismatch:"):
                correct = conflict_type.split(":")[1]
                print(f"  Line {line_num}: class_name '{class_name}' may conflict (correct case: '{correct}')")
                print(f"  {YELLOW}💡 Fix: Use exact case '{correct}' or rename to avoid confusion{NC}")
        print()

    print(f"{RED}🚫 BLOCKED: Fix native class name conflicts before committing{NC}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
```

### Integration

**Add to:** `.git/hooks/pre-commit`

```bash
# Check for native class name conflicts
echo "🔎 Checking for native class name conflicts..."
if ! python3 .system/validators/native_class_checker.py; then
    exit 1
fi
```

**Add to:** `.system/validators/test_validators.sh` (if exists)

```bash
python3 .system/validators/native_class_checker.py || exit 1
```

### Testing

```bash
# Create test file with conflict
echo 'class_name Logger' > test_conflict.gd

# Run validator (should fail)
python3 .system/validators/native_class_checker.py
# Expected: Exit 1, error message

# Fix conflict
echo 'class_name GameLogger' > test_conflict.gd

# Run validator (should pass)
python3 .system/validators/native_class_checker.py
# Expected: Exit 0, success message

# Cleanup
rm test_conflict.gd
```

---

## 2. Service API Consistency Checker

**Priority:** MEDIUM
**Implement:** Week 6 Day 2 (after persistence patterns emerge)

### Problem Statement

Week 5 had inconsistent service APIs:
- BankingService: `reset()`
- ShopRerollService: `reset_reroll_count()`
- Integration tests called `reset_balances()` (didn't exist)

**Impact:** Integration test failures, confusion about API patterns

### Solution

Enforce consistent API patterns across all services.

### Implementation

**File:** `.system/validators/service_api_checker.py`

```python
#!/usr/bin/env python3
"""
Service API Consistency Checker

Ensures all services implement required methods and follow consistent
naming patterns. Helps maintain predictable APIs across codebase.

Exit Codes:
  0 - All services implement required APIs
  1 - Missing or inconsistent APIs found
"""

import sys
import re
from pathlib import Path
from typing import Dict, List, Set

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
SERVICES_DIR = PROJECT_ROOT / "scripts/services"

# Required methods for all services
REQUIRED_METHODS = {
    "reset": {
        "signature": r"func reset\(\s*\)\s*->\s*void:",
        "description": "Reset service state (for testing)",
        "example": "func reset() -> void:",
    },
}

# Week 6+: Add serialization requirements
WEEK_6_METHODS = {
    "serialize": {
        "signature": r"func serialize\(\s*\)\s*->\s*Dictionary:",
        "description": "Serialize service state to dictionary",
        "example": "func serialize() -> Dictionary:",
    },
    "deserialize": {
        "signature": r"func deserialize\(\s*data:\s*Dictionary\s*\)\s*->\s*void:",
        "description": "Restore service state from dictionary",
        "example": "func deserialize(data: Dictionary) -> void:",
    },
}


def check_service_api(service_file: Path, required_methods: Dict) -> List[str]:
    """
    Check if service implements all required methods.

    Returns:
        List of error messages (empty if all good)
    """
    errors = []

    try:
        content = service_file.read_text(encoding='utf-8')

        for method_name, spec in required_methods.items():
            if not re.search(spec["signature"], content, re.MULTILINE):
                errors.append(
                    f"  ❌ Missing method '{method_name}': {spec['description']}\n"
                    f"     Example: {spec['example']}"
                )

    except Exception as e:
        errors.append(f"  ⚠️  Could not read file: {e}")

    return errors


def check_naming_consistency(service_files: List[Path]) -> List[str]:
    """
    Check for naming inconsistencies across services.

    Detects patterns like:
    - reset() vs reset_balances() vs reset_reroll_count()
    - get_state() vs get_current_state() vs current_state()
    """
    warnings = []

    # Extract all public method names from all services
    method_patterns = {}

    for service_file in service_files:
        try:
            content = service_file.read_text(encoding='utf-8')

            # Find all public methods (not starting with _)
            methods = re.findall(r'^func ([a-z][a-z0-9_]*)\(', content, re.MULTILINE)

            for method in methods:
                # Group similar method names
                base = method.split('_')[0]
                if base not in method_patterns:
                    method_patterns[base] = set()
                method_patterns[base].add((service_file.stem, method))

        except Exception:
            pass

    # Check for inconsistencies
    for base, methods in method_patterns.items():
        if len(methods) > 1:
            method_names = {m[1] for m in methods}
            if len(method_names) > 1:
                # Multiple variations of similar method
                services_with_methods = [f"{s}: {m}" for s, m in methods]
                warnings.append(
                    f"  ⚠️  Inconsistent naming for '{base}' methods:\n" +
                    "\n".join(f"     - {swm}" for swm in services_with_methods)
                )

    return warnings


def main():
    """Check all services for API consistency."""

    if not SERVICES_DIR.exists():
        print(f"{YELLOW}⚠️  Services directory not found: {SERVICES_DIR}{NC}")
        return 0

    service_files = sorted(SERVICES_DIR.glob("*_service.gd"))

    if not service_files:
        print(f"{YELLOW}⚠️  No service files found{NC}")
        return 0

    print(f"Checking service API consistency ({len(service_files)} services)...")

    # Determine which methods to require
    # TODO: Detect if we're in Week 6+ by checking for SaveSystem
    has_save_system = (PROJECT_ROOT / "scripts/systems/save_system.gd").exists()
    required_methods = REQUIRED_METHODS.copy()
    if has_save_system:
        required_methods.update(WEEK_6_METHODS)

    # Check each service
    all_errors = []
    for service_file in service_files:
        errors = check_service_api(service_file, required_methods)
        if errors:
            all_errors.append((service_file, errors))

    # Check naming consistency
    naming_warnings = check_naming_consistency(service_files)

    # Report results
    if not all_errors and not naming_warnings:
        print(f"{GREEN}✅ All services follow consistent API patterns{NC}")
        return 0

    if all_errors:
        print(f"\n{RED}❌ API consistency errors:{NC}\n")
        for service_file, errors in all_errors:
            print(f"{RED}{service_file.name}:{NC}")
            for error in errors:
                print(error)
            print()

    if naming_warnings:
        print(f"\n{YELLOW}⚠️  Naming consistency warnings:{NC}\n")
        for warning in naming_warnings:
            print(warning)
        print()

    if all_errors:
        print(f"{RED}🚫 BLOCKED: Fix API consistency errors before committing{NC}")
        return 1

    print(f"{YELLOW}💡 Consider addressing naming warnings for consistency{NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### Integration

**Add to:** `.git/hooks/pre-commit`

```bash
# Check service API consistency
echo "🔎 Checking service API consistency..."
if ! python3 .system/validators/service_api_checker.py; then
    exit 1
fi
```

---

## 3. Integration Test Requirement

**Priority:** MEDIUM
**Implement:** Week 6 Day 3 (after a few services exist)

### Problem Statement

Integration tests weren't created until Week 5 Day 4, after all 3 services were built. Should have been created incrementally as services were added.

**Impact:** No validation that services worked together until very end of week

### Solution

Automatically remind to create integration tests when 3+ services exist.

### Implementation

**File:** `.system/validators/integration_test_checker.py`

```python
#!/usr/bin/env python3
"""
Integration Test Requirement Checker

Reminds team to create integration tests when project has 3+ services.
Non-blocking reminder, not a hard requirement.

Exit Codes:
  0 - Always (non-blocking)
"""

import sys
from pathlib import Path

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
SERVICES_DIR = PROJECT_ROOT / "scripts/services"
TESTS_DIR = PROJECT_ROOT / "scripts/tests"


def main():
    """Check if integration tests exist when needed."""

    # Count services
    service_files = list(SERVICES_DIR.glob("*_service.gd"))
    service_count = len(service_files)

    # Count integration tests
    integration_tests = list(TESTS_DIR.glob("*integration_test.gd"))
    integration_count = len(integration_tests)

    # Reminder threshold: 3+ services should have integration tests
    if service_count >= 3 and integration_count == 0:
        print(f"\n{YELLOW}💡 Integration Test Reminder:{NC}")
        print(f"   Project has {service_count} services but no integration tests")
        print(f"   Consider creating: scripts/tests/service_integration_test.gd")
        print(f"   Benefits:")
        print(f"   - Validates services work together")
        print(f"   - Catches integration bugs early")
        print(f"   - Tests realistic user workflows")
        print(f"\n   {YELLOW}(Non-blocking reminder - continue if intentional){NC}\n")
        return 0

    if integration_count > 0:
        print(f"{GREEN}✅ Integration tests present ({integration_count} test(s)){NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### Integration

**Add to:** `.git/hooks/pre-commit` (non-blocking)

```bash
# Reminder for integration tests (non-blocking)
python3 .system/validators/integration_test_checker.py
```

---

## 4. Autoload Static Function Checker

**Priority:** LOW
**Implement:** Week 6 Day 4 (code cleanup day)

### Problem Statement

RecyclerService had static functions (`rarity_from_string`, `rarity_to_string`) that were called on the autoload instance, causing STATIC_CALLED_ON_INSTANCE warnings.

**Impact:** Minor - just warnings, but pollutes output

### Solution

Warn when autoload scripts contain static functions (usually incorrect).

### Implementation

**File:** `.system/validators/autoload_static_checker.py`

```python
#!/usr/bin/env python3
"""
Autoload Static Function Checker

Warns about static functions in autoload scripts. Since autoloads are
singletons, static functions are usually a mistake (should be instance methods).

Exit Codes:
  0 - No issues or warnings only (non-blocking)
"""

import sys
import re
from pathlib import Path
from typing import Dict, List

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
PROJECT_FILE = PROJECT_ROOT / "project.godot"


def parse_autoloads(project_file: Path) -> Dict[str, Path]:
    """
    Parse project.godot to find all autoload scripts.

    Returns:
        Dict mapping autoload_name -> script_path
    """
    autoloads = {}

    try:
        content = project_file.read_text(encoding='utf-8')

        # Find [autoload] section
        in_autoload_section = False
        for line in content.split('\n'):
            if line.strip() == '[autoload]':
                in_autoload_section = True
                continue

            if in_autoload_section:
                # Next section starts
                if line.startswith('['):
                    break

                # Parse: AutoloadName="*res://path/to/script.gd"
                match = re.match(r'(\w+)="?\*?res://(.+\.gd)"?', line.strip())
                if match:
                    autoload_name = match.group(1)
                    script_path = PROJECT_ROOT / match.group(2)
                    autoloads[autoload_name] = script_path

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not parse project.godot: {e}{NC}")

    return autoloads


def find_static_functions(script_path: Path) -> List[str]:
    """Find static function names in a script."""
    static_funcs = []

    try:
        content = script_path.read_text(encoding='utf-8')

        # Match: static func function_name(
        for match in re.finditer(r'static\s+func\s+(\w+)\s*\(', content):
            func_name = match.group(1)
            static_funcs.append(func_name)

    except Exception:
        pass

    return static_funcs


def main():
    """Check autoload scripts for static functions."""

    autoloads = parse_autoloads(PROJECT_FILE)

    if not autoloads:
        print(f"{YELLOW}⚠️  No autoloads found{NC}")
        return 0

    print(f"Checking autoload scripts for static functions ({len(autoloads)} autoloads)...")

    warnings = []

    for autoload_name, script_path in autoloads.items():
        if not script_path.exists():
            continue

        static_funcs = find_static_functions(script_path)

        if static_funcs:
            warnings.append((autoload_name, script_path, static_funcs))

    # Report results
    if not warnings:
        print(f"{GREEN}✅ No static functions in autoload scripts{NC}")
        return 0

    print(f"\n{YELLOW}⚠️  Found static functions in autoload scripts:{NC}\n")

    for autoload_name, script_path, static_funcs in warnings:
        rel_path = script_path.relative_to(PROJECT_ROOT)
        print(f"  {YELLOW}{autoload_name}{NC} ({rel_path}):")
        print(f"    Static functions: {', '.join(static_funcs)}")
        print(f"    {YELLOW}💡 Consider: Autoloads are singletons, static is usually incorrect{NC}")
        print(f"       Either remove 'static' or move to separate utility class")
        print()

    print(f"{YELLOW}(Non-blocking warnings - continue if intentional){NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### Integration

**Add to:** `.git/hooks/pre-commit` (non-blocking)

```bash
# Check autoload static functions (non-blocking)
python3 .system/validators/autoload_static_checker.py
```

---

## 5. Documentation Coverage Checker

**Priority:** LOW
**Implement:** Week 6 Day 5 (documentation day)

### Problem Statement

Week 5 documentation was created at the end (Day 5), not incrementally. Architectural decisions should be documented as they're made.

**Impact:** Risk of forgetting design rationale, harder to onboard new team members

### Solution

Non-blocking reminder to create weekly documentation.

### Implementation

**File:** `.system/validators/doc_coverage_checker.py`

```python
#!/usr/bin/env python3
"""
Documentation Coverage Checker

Reminds to create documentation for each week of work.
Encourages documenting architectural decisions as they're made.

Exit Codes:
  0 - Always (non-blocking reminder)
"""

import sys
import subprocess
from pathlib import Path
from datetime import datetime

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
DOCS_DIR = PROJECT_ROOT / ".system/docs"


def detect_current_week() -> int:
    """
    Detect current week number from git commits.

    Looks for commit messages like "Week 5" or "week-05" to determine
    which week we're currently working on.
    """
    try:
        # Get recent commit messages
        result = subprocess.run(
            ["git", "log", "--oneline", "-20"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return 0

        # Find highest week number in recent commits
        import re
        weeks = set()
        for line in result.stdout.split('\n'):
            # Match "Week 5" or "week-05"
            matches = re.findall(r'[Ww]eek[- ]?(\d+)', line)
            weeks.update(int(m) for m in matches)

        return max(weeks) if weeks else 0

    except Exception:
        return 0


def main():
    """Check for week documentation."""

    current_week = detect_current_week()

    if current_week == 0:
        # Can't detect week, skip check
        return 0

    week_dir = DOCS_DIR / f"week-{current_week:02d}"

    # Check for expected documentation files
    completion_doc = week_dir / "COMPLETION.md"
    architecture_doc = week_dir / "ARCHITECTURE.md"

    if completion_doc.exists() and architecture_doc.exists():
        print(f"{GREEN}✅ Week {current_week} documentation exists{NC}")
        return 0

    # Documentation missing or incomplete
    print(f"\n{YELLOW}📝 Documentation Reminder:{NC}")
    print(f"   Currently working on: Week {current_week}")

    if not week_dir.exists():
        print(f"   Missing: .system/docs/week-{current_week:02d}/ directory")
    else:
        if not completion_doc.exists():
            print(f"   Missing: week-{current_week:02d}/COMPLETION.md")
        if not architecture_doc.exists():
            print(f"   Missing: week-{current_week:02d}/ARCHITECTURE.md")

    print(f"\n   {YELLOW}💡 Consider creating documentation as you work:{NC}")
    print(f"   - COMPLETION.md: Daily progress, achievements, challenges")
    print(f"   - ARCHITECTURE.md: Design decisions, patterns, rationale")
    print(f"\n   Benefits:")
    print(f"   - Captures design rationale while fresh")
    print(f"   - Helps onboard new team members")
    print(f"   - Reference for future weeks")
    print(f"\n   {YELLOW}(Non-blocking reminder - create when ready){NC}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### Integration

**Add to:** `.git/hooks/pre-commit` (non-blocking, run weekly)

```bash
# Documentation reminder (non-blocking, runs once per day max)
LAST_DOC_CHECK=$(git config --get hooks.last-doc-check 2>/dev/null || echo "")
TODAY=$(date +%Y-%m-%d)

if [ "$LAST_DOC_CHECK" != "$TODAY" ]; then
    python3 .system/validators/doc_coverage_checker.py
    git config hooks.last-doc-check "$TODAY"
fi
```

---

## Implementation Schedule

### Week 6 Day 1: Foundation
- ✅ Implement Native Class Name Checker
- ✅ Add to pre-commit hooks
- ✅ Test with sample conflicts
- **Time estimate:** 30 minutes

### Week 6 Day 2: API Patterns
- ✅ Implement Service API Consistency Checker
- ✅ Add to pre-commit hooks
- ✅ Update all services to have `reset()` method
- ✅ Add `serialize()` and `deserialize()` stubs (Week 6 work)
- **Time estimate:** 45 minutes

### Week 6 Day 3: Integration Focus
- ✅ Implement Integration Test Requirement checker
- ✅ Add to pre-commit hooks (non-blocking)
- ✅ Update existing integration tests if needed
- **Time estimate:** 20 minutes

### Week 6 Day 4: Code Quality
- ✅ Implement Autoload Static Function Checker
- ✅ Add to pre-commit hooks (non-blocking)
- ✅ Fix any warnings in existing code
- **Time estimate:** 30 minutes

### Week 6 Day 5: Documentation
- ✅ Implement Documentation Coverage Checker
- ✅ Add to pre-commit hooks (non-blocking)
- ✅ Create Week 6 documentation
- **Time estimate:** 20 minutes

**Total Time Investment:** ~2.5 hours spread across Week 6

---

## Pre-Commit Hook Integration

### Updated `.git/hooks/pre-commit`

```bash
#!/bin/bash
# Pre-commit hook for scrap-survivor-godot
# Week 6: Enhanced health enforcement

set -e

echo "🔍 Running pre-commit checks..."

# ============================================================================
# BLOCKING CHECKS (must pass to commit)
# ============================================================================

# 1. Native class name conflicts (NEW - Week 6)
echo "🔎 Checking for native class name conflicts..."
if ! python3 .system/validators/native_class_checker.py; then
    exit 1
fi

# 2. GDScript linting (existing)
echo "Checking: $file"
if ! gdlint "$file"; then
    echo "❌ Linting failed"
    exit 1
fi

# 3. GDScript formatting (existing)
if ! gdformat --check "$file"; then
    echo "❌ Formatting check failed"
    exit 1
fi

# 4. Service API consistency (NEW - Week 6)
echo "🔎 Checking service API consistency..."
if ! python3 .system/validators/service_api_checker.py; then
    exit 1
fi

# ============================================================================
# NON-BLOCKING CHECKS (warnings only)
# ============================================================================

# 5. Integration test reminder (NEW - Week 6)
python3 .system/validators/integration_test_checker.py || true

# 6. Autoload static functions (NEW - Week 6)
python3 .system/validators/autoload_static_checker.py || true

# 7. Documentation coverage (NEW - Week 6)
LAST_DOC_CHECK=$(git config --get hooks.last-doc-check 2>/dev/null || echo "")
TODAY=$(date +%Y-%m-%d)
if [ "$LAST_DOC_CHECK" != "$TODAY" ]; then
    python3 .system/validators/doc_coverage_checker.py || true
    git config hooks.last-doc-check "$TODAY"
fi

# ============================================================================
# EXISTING VALIDATORS
# ============================================================================

# Test naming convention
python3 .system/validators/test_naming_validator.py || exit 1

# Godot configuration
python3 .system/validators/godot_config_validator.py || exit 1

# Run Godot tests (headless)
python3 .system/validators/godot_test_runner.py || exit 1

echo "✅ All checks passed"
```

---

## Success Metrics

### Quantitative
- **0 native class conflicts** detected post-implementation
- **100% service API consistency** across all services
- **Integration test coverage** for all service combinations
- **0 autoload static function warnings** in production code
- **Documentation created within 1 day** of architectural decisions

### Qualitative
- Faster onboarding for new team members (clear docs)
- Fewer "gotcha" moments from API inconsistencies
- Higher confidence in cross-service interactions
- Better architectural decision tracking

---

## Maintenance

### Adding New Validators
1. Create `.system/validators/new_validator.py`
2. Follow existing patterns (exit codes, ANSI colors)
3. Add to pre-commit hook (blocking or non-blocking)
4. Add to this document
5. Test with sample violations

### Updating Godot Native Classes
When Godot updates, refresh the native class list:

```bash
# Extract from Godot docs
curl https://docs.godotengine.org/en/stable/classes/index.html \
  | grep -oP 'class_\K\w+' \
  | sort -u \
  > native_classes.txt

# Update native_class_checker.py GODOT_NATIVE_CLASSES
```

### Weekly Review
Every week, review validator effectiveness:
- Did validators catch real issues?
- Any false positives?
- Any issues that slipped through?
- Adjust thresholds/patterns as needed

---

## Conclusion

These 5 health enforcement improvements will:
1. ✅ Prevent catastrophic conflicts (native class names)
2. ✅ Maintain consistent APIs across services
3. ✅ Encourage comprehensive testing (integration tests)
4. ✅ Reduce warning noise (autoload statics)
5. ✅ Preserve institutional knowledge (documentation)

**Total implementation time:** ~2.5 hours
**Expected ROI:** 10x (prevent hours of debugging)
**Maintenance cost:** Minimal (validators are self-contained)

Let's build a world-class health enforcement system! 🚀
