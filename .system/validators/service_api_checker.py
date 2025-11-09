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

# Required methods for all services (Week 5+)
REQUIRED_METHODS_WEEK_5 = {
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
        "signature": r"func deserialize\(\s*_?data:\s*Dictionary\s*\)\s*->\s*void:",
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
                # Group similar method names by base word
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
                services_with_methods = [f"{s}: {m}()" for s, m in methods]
                warnings.append(
                    f"  ⚠️  Inconsistent naming for '{base}' methods:\n" +
                    "\n".join(f"     - {swm}" for swm in services_with_methods) +
                    f"\n     💡 Consider standardizing to one name"
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
    # Week 6+ requires serialization
    has_save_system = (PROJECT_ROOT / "scripts/systems/save_system.gd").exists()
    required_methods = REQUIRED_METHODS_WEEK_5.copy()
    if has_save_system:
        required_methods.update(WEEK_6_METHODS)
        print(f"  Week 6+ detected: requiring serialization methods")

    # Check each service
    all_errors = []
    for service_file in service_files:
        errors = check_service_api(service_file, required_methods)
        if errors:
            all_errors.append((service_file, errors))

    # Check naming consistency (non-blocking warnings)
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
        print(f"\n{YELLOW}⚠️  Naming consistency warnings (non-blocking):{NC}\n")
        for warning in naming_warnings:
            print(warning)
        print()

    if all_errors:
        print(f"{RED}🚫 BLOCKED: Fix API consistency errors before committing{NC}")
        return 1

    if naming_warnings:
        print(f"{YELLOW}💡 Consider addressing naming warnings for consistency{NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
