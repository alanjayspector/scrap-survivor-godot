#!/usr/bin/env python3
"""
Test Naming Convention Validator

Validates that test files follow the *_test.gd naming convention for
future compatibility with GUT framework and consistency.

This is a NON-BLOCKING validator - it warns but doesn't fail the commit.
"""

import sys
from pathlib import Path

# ANSI colors
YELLOW = '\033[1;33m'
GREEN = '\033[0;32m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent
TEST_DIR = PROJECT_ROOT / "scripts" / "tests"


def check_test_naming():
    """
    Check that test files follow *_test.gd naming convention.
    Returns (warnings_found: bool, messages: list)
    """
    if not TEST_DIR.exists():
        return False, []

    warnings = []

    for test_file in TEST_DIR.glob("*.gd"):
        filename = test_file.name

        # Skip if already follows convention
        if filename.endswith("_test.gd"):
            continue

        # Check if this looks like a test file with wrong naming
        if filename.startswith("test_"):
            suggested_name = filename.replace("test_", "").replace(".gd", "_test.gd")
            warnings.append(
                f"  • {filename} should be named {suggested_name} (for GUT compatibility)"
            )

    return len(warnings) > 0, warnings


def main():
    """Run test naming validation."""
    has_warnings, warnings = check_test_naming()

    if has_warnings:
        print(f"{YELLOW}⚠️  Test naming convention warnings:{NC}")
        for warning in warnings:
            print(warning)
        print(f"\n{YELLOW}💡 Tip: Use *_test.gd pattern for future GUT framework compatibility{NC}")
        print(f"{YELLOW}   (This is a warning only - commit will proceed){NC}")
    else:
        print(f"{GREEN}✅ Test naming convention followed{NC}")

    # Always return 0 (non-blocking)
    return 0


if __name__ == "__main__":
    sys.exit(main())
