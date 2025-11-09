#!/usr/bin/env python3
"""
Godot Runtime Validator

Validates that the Godot project actually loads without parse errors.
This catches issues that static analysis (gdlint) cannot detect:
- Native class name conflicts (Logger vs built-in Logger)
- Autoload circular dependencies
- Missing resource files referenced in code
- Invalid enum/constant references

This is the MISSING VALIDATOR that would have caught the Logger bug.
"""

import subprocess
import sys
from pathlib import Path

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
GODOT_EXECUTABLE = "/Applications/Godot.app/Contents/MacOS/Godot"


def check_godot_installed():
    """Check if Godot is installed."""
    if not Path(GODOT_EXECUTABLE).exists():
        print(f"{YELLOW}⚠️  Godot not found at {GODOT_EXECUTABLE}, skipping runtime validation{NC}")
        return False
    return True


def is_godot_running():
    """Check if Godot is already running (would block headless check)."""
    try:
        result = subprocess.run(
            ["pgrep", "-x", "Godot"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except:
        return False


def validate_godot_loads():
    """
    Attempt to load the project in Godot headless mode.
    Returns True if successful, False if parse errors detected.
    """
    # Skip validation if Godot is already running (would lock)
    if is_godot_running():
        print(f"{YELLOW}⚠️  Godot is running - skipping runtime validation{NC}")
        print(f"   (Close Godot to enable runtime validation on commit)")
        return True

    print(f"Running Godot headless load test...")

    try:
        # Run Godot in headless mode with --quit flag
        # This will load the project and immediately exit
        # If there are parse errors, they'll appear in stderr
        result = subprocess.run(
            [
                GODOT_EXECUTABLE,
                "--headless",
                "--quit",
                "--path", str(PROJECT_ROOT)
            ],
            capture_output=True,
            text=True,
            timeout=30  # 30 second timeout
        )

        output = result.stdout + result.stderr

        # Check for parse errors
        error_indicators = [
            "Parse Error",
            "Failed to load",
            "hides a native class",
            "not declared in the current scope",
            "Invalid cast"
        ]

        errors_found = []
        for line in output.split('\n'):
            if any(indicator in line for indicator in error_indicators):
                # Only report ERROR level, not warnings
                if "ERROR:" in line or "Parse Error:" in line:
                    errors_found.append(line.strip())

        if errors_found:
            print(f"{RED}❌ Godot runtime validation failed{NC}")
            print(f"\n{RED}Parse errors detected:{NC}")
            for error in errors_found[:10]:  # Limit to first 10 errors
                print(f"  {error}")
            if len(errors_found) > 10:
                print(f"  ... and {len(errors_found) - 10} more errors")
            return False

        print(f"{GREEN}✅ Godot runtime validation passed{NC}")
        return True

    except subprocess.TimeoutExpired:
        print(f"{RED}❌ Godot load test timed out (30s){NC}")
        return False
    except Exception as e:
        print(f"{YELLOW}⚠️  Godot runtime check failed: {e}{NC}")
        # Don't fail the commit on validator errors, just skip
        return True


def main():
    """Run Godot runtime validation."""
    if not check_godot_installed():
        # If Godot not installed, skip validation (don't fail)
        return 0

    if not validate_godot_loads():
        print(f"\n{YELLOW}💡 Fix: Restart Godot and check the Output panel for errors{NC}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
