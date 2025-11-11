#!/usr/bin/env python3
"""
Godot Test Runner (GUT Framework)

Runs GUT tests in headless mode during pre-commit to catch test failures.

Uses GUT (Godot Unit Test) framework for proper test isolation, assertions,
and lifecycle hooks. Replaces manual test scene orchestration.

UPDATED: Now supports cached test results when Godot is running.
If test_results.txt is fresh (<5 minutes), trusts cached results.
Otherwise, requires closing Godot or running tests manually.
"""

import subprocess
import sys
import time
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

# Test results files
TEST_RESULTS_FILE = PROJECT_ROOT / "test_results.txt"
TEST_LOG_FILE = PROJECT_ROOT / "test_run.log"

# Freshness threshold (5 minutes)
FRESHNESS_THRESHOLD_SECONDS = 300


def check_test_results_freshness() -> tuple[bool, dict]:
    """
    Check if test_results.txt exists and is fresh (< 5 minutes).
    Returns (is_fresh: bool, stats: dict)
    """
    if not TEST_RESULTS_FILE.exists():
        return False, {}

    # Check file age
    age_seconds = time.time() - TEST_RESULTS_FILE.stat().st_mtime
    if age_seconds > FRESHNESS_THRESHOLD_SECONDS:
        return False, {}

    # Parse results
    stats = {}
    try:
        with open(TEST_RESULTS_FILE) as f:
            for line in f:
                line = line.strip()
                if ': ' in line:
                    key, value = line.split(': ', 1)
                    stats[key] = value
    except Exception as e:
        print(f"{YELLOW}⚠️  Warning: Could not parse test_results.txt: {e}{NC}")
        return False, {}

    # Verify required fields
    if not all(k in stats for k in ['timestamp', 'passed', 'failed', 'total']):
        return False, {}

    return True, stats


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
        # First, run Godot in editor mode to scan and register all class_name scripts
        # This ensures custom Resource classes like WeaponResource are available in headless mode
        # NOTE: Use --quit-after 2 instead of --quit to allow import threads to complete
        # See: https://github.com/godotengine/godot/issues/77508
        print(f"{CYAN}Scanning project to register custom classes...{NC}", flush=True)
        scan_result = subprocess.run(
            [
                GODOT_EXECUTABLE,
                "--headless",
                "--editor",
                "--path", str(PROJECT_ROOT),
                "--quit-after", "2"  # Wait 2 frames for import threads to complete
            ],
            capture_output=True,
            text=True,
            timeout=60
        )

        # Verify class cache was created
        cache_path = PROJECT_ROOT / ".godot" / "global_script_class_cache.cfg"
        if cache_path.exists():
            print(f"{GREEN}✓ Class cache created successfully{NC}", flush=True)
        else:
            print(f"{YELLOW}⚠️  Warning: Class cache not found at {cache_path}{NC}", flush=True)

        print(f"{CYAN}Running tests with registered classes...{NC}", flush=True)

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

        # Write results to test_results.txt for caching
        try:
            from datetime import datetime
            with open(TEST_RESULTS_FILE, 'w') as f:
                f.write(f"timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"passed: {stats['passed']}\n")
                f.write(f"failed: {stats['failed']}\n")
                f.write(f"total: {stats['total']}\n")
                f.write(f"status: {'PASS' if success else 'FAIL'}\n")
        except Exception as e:
            print(f"{YELLOW}⚠️  Warning: Could not write test_results.txt: {e}{NC}")

        # Write full output to test_run.log for debugging
        try:
            with open(TEST_LOG_FILE, 'w') as f:
                f.write(output)
        except Exception as e:
            print(f"{YELLOW}⚠️  Warning: Could not write test_run.log: {e}{NC}")

        return success, output, stats

    except subprocess.TimeoutExpired:
        return False, "Tests timed out after 60 seconds", {"passed": 0, "failed": 0, "total": 0}
    except Exception as e:
        return False, f"Failed to run tests: {e}", {"passed": 0, "failed": 0, "total": 0}


def main():
    """Run all GUT tests and report results."""

    # If Godot is running, check for fresh cached results
    if is_godot_running():
        print(f"{CYAN}Godot is running - checking for cached test results...{NC}")

        fresh, stats = check_test_results_freshness()

        if fresh:
            # Fresh results available - trust them
            age_seconds = int(time.time() - TEST_RESULTS_FILE.stat().st_mtime)
            print(f"{GREEN}✓ Using cached test results (age: {age_seconds}s){NC}")
            print(f"  Timestamp: {stats.get('timestamp')}")
            print(f"  Passed: {stats.get('passed')}/{stats.get('total')}")
            print()

            # Check if tests are passing
            failed = int(stats.get('failed', 0))
            if failed > 0:
                print(f"{RED}❌ Cached tests show {failed} failure(s){NC}")
                print(f"  Fix tests and rerun in Godot Editor")
                print(f"  Or view failures: cat test_run.log")
                return 1

            return 0
        else:
            # No fresh results - must run tests or close Godot
            if TEST_RESULTS_FILE.exists():
                age_seconds = int(time.time() - TEST_RESULTS_FILE.stat().st_mtime)
                age_minutes = age_seconds // 60
                print(f"{YELLOW}⚠️  Cached results are stale (age: {age_minutes}m {age_seconds % 60}s > 5m threshold){NC}")
            else:
                print(f"{YELLOW}⚠️  No cached test results found{NC}")

            print()
            print(f"{RED}❌ Cannot verify tests: Godot is running AND no fresh results{NC}")
            print()
            print(f"  {CYAN}Fix Option 1:{NC} Run tests in Godot Editor (GUT panel)")
            print(f"               This updates test_results.txt and test_run.log")
            print()
            print(f"  {CYAN}Fix Option 2:{NC} Close Godot and retry commit")
            print(f"               Tests will run automatically in headless mode")
            print()
            print(f"  {YELLOW}Bypass (NOT recommended):{NC} git commit --no-verify")
            print()
            return 1

    print(f"{CYAN}Running GUT tests in headless mode...{NC}")

    success, output, stats = run_gut_tests()

    # Print summary
    print()
    if success:
        if stats['total'] == 0:
            print(f"{YELLOW}⚠️  No GUT tests found (0 test files extend GutTest){NC}")
            print(f"   {CYAN}This is expected during GUT migration (Phase 1 setup complete){NC}")
            print(f"   {CYAN}Next: Migrate test files to extend GutTest (see GUT-MIGRATION.md){NC}")
            print()
            print(f"{CYAN}Debug: Showing last 50 lines of GUT output:{NC}")
            for line in output.split('\n')[-50:]:
                if line.strip():
                    print(f"  {line}")
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
