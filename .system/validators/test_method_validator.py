#!/usr/bin/env python3
"""
Test Method Validator

Validates that test files only call methods and signals that actually exist
in the service implementations. Prevents tests from calling non-existent APIs.

Runs during pre-commit to catch errors before they're committed.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent

# Service files to parse for API extraction
SERVICE_FILES = [
    "scripts/services/banking_service.gd",
    "scripts/services/shop_reroll_service.gd",
    "scripts/services/recycler_service.gd",
    "scripts/services/error_service.gd",
    "scripts/systems/save_system.gd",
    "scripts/systems/save_manager.gd",
]

# Test files to validate
TEST_FILES = [
    "scripts/tests/banking_service_test.gd",
    "scripts/tests/shop_reroll_service_test.gd",
    "scripts/tests/recycler_service_test.gd",
    "scripts/tests/service_integration_test.gd",
    "scripts/tests/save_system_test.gd",
    "scripts/tests/save_integration_test.gd",
]


class ServiceAPI:
    """Represents the public API of a service"""

    def __init__(self, name: str):
        self.name = name
        self.methods: Set[str] = set()
        self.signals: Set[str] = set()
        self.enums: Dict[str, Set[str]] = {}
        self.constants: Set[str] = set()
        self.properties: Set[str] = set()


def extract_service_api(file_path: Path) -> ServiceAPI:
    """Extract the public API from a service file"""

    service_name = file_path.stem
    # Convert snake_case to PascalCase for service name
    service_name = ''.join(word.capitalize() for word in service_name.split('_'))

    api = ServiceAPI(service_name)

    if not file_path.exists():
        return api

    content = file_path.read_text()
    lines = content.split('\n')

    # Track if we're inside an enum
    current_enum = None
    enum_values = set()

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Skip comments
        if stripped.startswith('#'):
            continue

        # Extract ALL methods (including private ones - tests can call them)
        method_match = re.match(r'func\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', stripped)
        if method_match:
            method_name = method_match.group(1)
            api.methods.add(method_name)

        # Extract signals
        signal_match = re.match(r'signal\s+([a-zA-Z][a-zA-Z0-9_]*)', stripped)
        if signal_match:
            api.signals.add(signal_match.group(1))

        # Extract enums
        enum_start = re.match(r'enum\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\{', stripped)
        if enum_start:
            current_enum = enum_start.group(1)
            enum_values = set()
            continue

        # Inside enum - extract values
        if current_enum:
            # Check for closing brace
            if '}' in stripped:
                api.enums[current_enum] = enum_values
                current_enum = None
                enum_values = set()
            else:
                # Extract enum value
                enum_value_match = re.match(r'([A-Z_][A-Z0-9_]*)', stripped)
                if enum_value_match:
                    enum_values.add(enum_value_match.group(1))

        # Extract constants
        const_match = re.match(r'const\s+([A-Z_][A-Z0-9_]*)\s*=', stripped)
        if const_match:
            api.constants.add(const_match.group(1))

        # Extract public properties (var without @export for now)
        var_match = re.match(r'var\s+([a-z_][a-z0-9_]*)\s*:', stripped)
        if var_match and not stripped.startswith('var _'):
            api.properties.add(var_match.group(1))

    return api


def find_method_calls(file_path: Path, service_apis: Dict[str, ServiceAPI]) -> List[Tuple[int, str, str, str]]:
    """
    Find all service method calls in a test file.
    Returns: List of (line_number, service_name, method_name, full_line)
    """

    if not file_path.exists():
        return []

    content = file_path.read_text()
    lines = content.split('\n')

    calls = []

    for i, line in enumerate(lines, start=1):
        # Find ServiceName.method_name() patterns
        for service_name in service_apis.keys():
            # Match: ServiceName.method_name(
            pattern = rf'{service_name}\.([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
            matches = re.finditer(pattern, line)
            for match in matches:
                method_name = match.group(1)
                calls.append((i, service_name, method_name, line.strip()))

    return calls


def find_signal_connections(file_path: Path, service_apis: Dict[str, ServiceAPI]) -> List[Tuple[int, str, str, str]]:
    """
    Find all signal connections in a test file.
    Returns: List of (line_number, service_name, signal_name, full_line)
    """

    if not file_path.exists():
        return []

    content = file_path.read_text()
    lines = content.split('\n')

    connections = []

    for i, line in enumerate(lines, start=1):
        # Find ServiceName.signal_name.connect( patterns
        for service_name in service_apis.keys():
            pattern = rf'{service_name}\.([a-zA-Z_][a-zA-Z0-9_]*)\.connect\s*\('
            matches = re.finditer(pattern, line)
            for match in matches:
                signal_name = match.group(1)
                connections.append((i, service_name, signal_name, line.strip()))

            # Also check for .disconnect(
            pattern = rf'{service_name}\.([a-zA-Z_][a-zA-Z0-9_]*)\.disconnect\s*\('
            matches = re.finditer(pattern, line)
            for match in matches:
                signal_name = match.group(1)
                connections.append((i, service_name, signal_name, line.strip()))

    return connections


def validate_test_file(test_file: Path, service_apis: Dict[str, ServiceAPI]) -> List[str]:
    """
    Validate a test file against service APIs.
    Returns: List of error messages
    """

    errors = []

    # Check method calls
    method_calls = find_method_calls(test_file, service_apis)
    for line_num, service_name, method_name, full_line in method_calls:
        api = service_apis.get(service_name)
        if api and method_name not in api.methods and method_name not in api.properties:
            errors.append(
                f"{test_file.name}:{line_num}: "
                f"Method '{method_name}' does not exist in {service_name}\n"
                f"  Line: {full_line}"
            )

    # Check signal connections
    signal_connections = find_signal_connections(test_file, service_apis)
    for line_num, service_name, signal_name, full_line in signal_connections:
        api = service_apis.get(service_name)
        if api and signal_name not in api.signals:
            errors.append(
                f"{test_file.name}:{line_num}: "
                f"Signal '{signal_name}' does not exist in {service_name}\n"
                f"  Line: {full_line}"
            )

    return errors


def main():
    """Main validation logic"""

    print("Validating test method calls against service APIs...")
    print()

    # Extract service APIs
    service_apis = {}
    for service_file in SERVICE_FILES:
        file_path = PROJECT_ROOT / service_file
        if file_path.exists():
            api = extract_service_api(file_path)
            service_apis[api.name] = api

    # Report discovered APIs
    print(f"Found {len(service_apis)} services:")
    for name, api in service_apis.items():
        print(f"  • {name}: {len(api.methods)} methods, {len(api.signals)} signals")
    print()

    # Validate each test file
    all_errors = []
    for test_file in TEST_FILES:
        file_path = PROJECT_ROOT / test_file
        if file_path.exists():
            errors = validate_test_file(file_path, service_apis)
            all_errors.extend(errors)

    # Report results
    if all_errors:
        print(f"{RED}❌ Test validation failed - found {len(all_errors)} issue(s):{NC}\n")
        for error in all_errors:
            print(f"{RED}{error}{NC}\n")

        print(f"{YELLOW}💡 Fix: Update tests to call methods that actually exist{NC}")
        print(f"{YELLOW}💡 Hint: Check the service implementation files for the correct API{NC}")
        return 1

    print(f"{GREEN}✅ All test method calls are valid{NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
