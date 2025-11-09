#!/usr/bin/env python3
"""
Integration Test Requirement Checker

Reminds developers to create integration tests when the project has
multiple services that interact with each other.

Exit Codes:
  0 - Always (non-blocking warning only)
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

# Thresholds
MIN_SERVICES_FOR_INTEGRATION_TEST = 3


def count_services() -> int:
    """Count the number of service files in the project."""
    if not SERVICES_DIR.exists():
        return 0

    service_files = list(SERVICES_DIR.glob("*_service.gd"))
    return len(service_files)


def has_integration_tests() -> bool:
    """Check if integration tests exist."""
    if not TESTS_DIR.exists():
        return False

    # Look for files with "integration" in the name
    integration_tests = list(TESTS_DIR.glob("*integration*test.gd"))

    return len(integration_tests) > 0


def main():
    """Check if integration tests are needed and exist."""

    service_count = count_services()

    # Only check if we have enough services
    if service_count < MIN_SERVICES_FOR_INTEGRATION_TEST:
        # Not enough services yet
        return 0

    has_tests = has_integration_tests()

    if has_tests:
        print(f"{GREEN}✅ Integration tests found{NC}")
        return 0

    # Missing integration tests - non-blocking warning
    print(f"\n{YELLOW}⚠️  Integration test reminder:{NC}")
    print(f"   You have {service_count} services but no integration tests")
    print(f"   Integration tests verify that services work together correctly")
    print()
    print(f"   {YELLOW}💡 Recommended:{NC}")
    print(f"      Create scripts/tests/*_integration_test.gd")
    print(f"      Test cross-service interactions")
    print(f"      Example: save/load flow, service dependencies")
    print()
    print(f"   {YELLOW}Note: This is a reminder, not a blocking error{NC}")
    print()

    return 0  # Non-blocking


if __name__ == "__main__":
    sys.exit(main())
