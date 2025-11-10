#!/usr/bin/env python3
"""
Godot Test Runner (GUT Framework)

Runs GUT tests in headless mode during pre-commit to catch test failures.

Uses GUT (Godot Unit Test) framework for proper test isolation, assertions,
and lifecycle hooks. Replaces manual test scene orchestration.

Only runs when Godot is NOT already open (to avoid project lock).
"""

import subprocess
import sys
from pathlib import Path
import re

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
GODOT_EXECUTABLE = "/Applications/Godot.app/Contents/MacOS/Godot"

# GUT CLI script path
GUT_CLI_SCRIPT = "res://addons/gut/gut_cmdln.gd"

# Test directory (GUT will discover all *_test.gd files)
TEST_DIR = "res://scripts/tests/"


def is_godot_running():
    """Check if Godot is already running (would block headless tests)."""
    try:
        result = subprocess.run(
            ["pgrep", "-x", "Godot"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except:
        return False


def run_gut_tests() -> tuple[bool, str, dict]:
    """
    Run all GUT tests in headless mode.
    Returns (success: bool, output: str, stats: dict)
    """
    try:
        # First, run Godot in editor mode briefly to scan and register all class_name scripts
        # This ensures custom Resource classes like WeaponResource are available in headless mode
        scan_result = subprocess.run(
            [
                GODOT_EXECUTABLE,
                "--headless",
                "--editor",
                "--path", str(PROJECT_ROOT),
                "--quit"
            ],
            capture_output=True,
            text=True,
            timeout=30
        )

        # Now run the actual tests with classes properly registered
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
            text=True,
            timeout=60  # 60 second timeout for all tests
        )

        output = result.stdout + result.stderr

        # Parse GUT output for test statistics
        # GUT prints: "X of Y tests passed"
        stats = {"passed": 0, "failed": 0, "total": 0}

        # Look for GUT's summary line
        passed_match = re.search(r'(\d+)\s+of\s+(\d+)\s+tests?\s+passed', output)
        if passed_match:
            stats["passed"] = int(passed_match.group(1))
            stats["total"] = int(passed_match.group(2))
            stats["failed"] = stats["total"] - stats["passed"]

        # Check for "Nothing was run" (no tests found - OK during migration)
        # GUT outputs this with ANSI codes, so check for substring
        nothing_ran = "Nothing was run" in output or "ERROR]:  Nothing was run" in output

        # Check for success
        # - All tests passed, OR
        # - No tests found (during GUT migration phase)
        success = (result.returncode == 0 and stats["failed"] == 0) or nothing_ran

        return success, output, stats

    except subprocess.TimeoutExpired:
        return False, "Tests timed out after 60 seconds", {"passed": 0, "failed": 0, "total": 0}
    except Exception as e:
        return False, f"Failed to run tests: {e}", {"passed": 0, "failed": 0, "total": 0}


def main():
    """Run all GUT tests and report results."""

    # Skip if Godot is running
    if is_godot_running():
        print(f"{YELLOW}⚠️  Godot is running - skipping automated tests{NC}")
        print(f"   Run tests manually in Godot, or close Godot to enable automated testing")
        return 0

    print(f"{CYAN}Running GUT tests in headless mode...{NC}")

    success, output, stats = run_gut_tests()

    # Print summary
    print()
    if success:
        if stats['total'] == 0:
            print(f"{YELLOW}⚠️  No GUT tests found (0 test files extend GutTest){NC}")
            print(f"   {CYAN}This is expected during GUT migration (Phase 1 setup complete){NC}")
            print(f"   {CYAN}Next: Migrate test files to extend GutTest (see GUT-MIGRATION.md){NC}")
        else:
            print(f"{GREEN}✅ All tests passed ({stats['passed']}/{stats['total']}){NC}")
        return 0
    else:
        print(f"{RED}❌ {stats['failed']} of {stats['total']} tests failed{NC}")
        print()

        # Print relevant failure output
        # Look for test failure indicators in GUT output
        lines = output.split('\n')
        in_failure_section = False

        for line in lines:
            # Detect failure markers in GUT output
            if 'FAILED' in line or 'ERROR' in line or 'Assertion failed' in line:
                in_failure_section = True

            # Print failure-related lines
            if in_failure_section or re.search(r'test_\w+.*FAILED', line):
                if line.strip():
                    print(f"  {line}")

        print(f"\n{YELLOW}💡 Fix: Run tests in Godot editor with GUT panel (bottom panel){NC}")
        print(f"{CYAN}   Or run: godot --headless -s {GUT_CLI_SCRIPT} -gdir={TEST_DIR} -gexit{NC}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
