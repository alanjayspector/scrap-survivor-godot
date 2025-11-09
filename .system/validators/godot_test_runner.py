#!/usr/bin/env python3
"""
Godot Test Runner

Automatically runs Godot test scenes in headless mode and validates output.
Runs during pre-commit to catch test failures before they're committed.

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
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
GODOT_EXECUTABLE = "/Applications/Godot.app/Contents/MacOS/Godot"

# Test scenes to run (following *_test.tscn naming convention)
TEST_SCENES = [
    "scenes/tests/banking_service_test.tscn",
    # Add more test scenes here as they're created
]


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


def run_test_scene(scene_path: str) -> tuple[bool, str]:
    """
    Run a single test scene in Godot headless mode.
    Returns (success: bool, output: str)
    """
    try:
        result = subprocess.run(
            [
                GODOT_EXECUTABLE,
                "--headless",
                "--path", str(PROJECT_ROOT),
                scene_path
            ],
            capture_output=True,
            text=True,
            timeout=10  # 10 second timeout per test
        )

        output = result.stdout + result.stderr

        # Check for test success indicators
        # Tests print "=== All [Service] Tests Complete ===" when successful
        if "Tests Complete" in output and "✓" in output:
            return True, output

        # Check for errors or assertion failures
        if "ERROR:" in output or "Assertion failed" in output:
            return False, output

        # If we get here, test ran but output is unclear
        return False, output

    except subprocess.TimeoutExpired:
        return False, f"Test timed out after 10 seconds"
    except Exception as e:
        return False, f"Failed to run test: {e}"


def main():
    """Run all test scenes and report results."""

    # Skip if Godot is running
    if is_godot_running():
        print(f"{YELLOW}⚠️  Godot is running - skipping automated tests{NC}")
        print(f"   Run tests manually in Godot, or close Godot to enable automated testing")
        return 0

    print(f"Running Godot tests in headless mode...")

    all_passed = True
    results = []

    for scene_path in TEST_SCENES:
        scene_name = Path(scene_path).stem
        print(f"  Testing {scene_name}...", end=" ")

        success, output = run_test_scene(scene_path)

        if success:
            print(f"{GREEN}✓{NC}")
            results.append((scene_name, True, None))
        else:
            print(f"{RED}✗{NC}")
            results.append((scene_name, False, output))
            all_passed = False

    # Print summary
    print()
    if all_passed:
        print(f"{GREEN}✅ All tests passed ({len(TEST_SCENES)} scenes){NC}")
        return 0
    else:
        print(f"{RED}❌ Some tests failed:{NC}")
        for scene_name, success, output in results:
            if not success:
                print(f"\n{RED}Failed: {scene_name}{NC}")
                # Print first few lines of output to help debug
                if output:
                    lines = output.split('\n')[:20]
                    for line in lines:
                        if line.strip():
                            print(f"  {line}")
        print(f"\n{YELLOW}💡 Fix: Run the test in Godot to see full output{NC}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
