#!/usr/bin/env python3
"""
Test Quality Validator - Blocks commits with low-quality tests

Enforces:
- No assert_true(true) smoke tests
- Tests must have clear failure messages
- Tests must follow user story mapping (comment header required)
- Integration tests must use correct patterns

Usage:
    python3 test_quality_validator.py           # Strict mode (block on errors)
    python3 test_quality_validator.py --warn-only  # Warn mode (report but don't block)
"""

import argparse
import re
import sys
from pathlib import Path


class TestQualityValidator:
    def __init__(self, test_dir: Path, warn_only: bool = False):
        self.test_dir = test_dir
        self.warn_only = warn_only
        self.errors = []
        self.warnings = []

    def validate_all_tests(self) -> bool:
        """Validate all test files. Returns True if all pass."""
        test_files = list(self.test_dir.glob("*_test.gd"))

        if not test_files:
            print("❌ No test files found")
            return False

        all_valid = True
        for test_file in sorted(test_files):
            if not self.validate_test_file(test_file):
                all_valid = False

        return all_valid

    def validate_test_file(self, test_file: Path) -> bool:
        """Validate a single test file."""
        content = test_file.read_text()
        file_valid = True

        # Check 1: User story mapping (warn-only mode: make it a warning, not error)
        if not self._has_user_story(content):
            if self.warn_only:
                self.warnings.append(f"{test_file.name}: Missing USER STORY comment in header")
            else:
                self.errors.append(f"{test_file.name}: Missing USER STORY comment in header")
                file_valid = False

        # Check 2: No smoke tests allowed
        smoke_tests = self._find_smoke_tests(content)
        if smoke_tests:
            for test_name in smoke_tests:
                self.errors.append(f"{test_file.name}: Smoke test detected: {test_name}")
            file_valid = False

        # Check 3: Assertions must have failure messages
        missing_messages = self._find_assertions_without_messages(content)
        if missing_messages:
            for line_num, assertion in missing_messages:
                self.warnings.append(
                    f"{test_file.name}:{line_num}: Assertion missing failure message: {assertion}"
                )

        # Check 4: Integration tests must use correct payment pattern
        if "integration" in test_file.name.lower():
            incorrect_patterns = self._find_incorrect_payment_patterns(content)
            if incorrect_patterns:
                for line_num in incorrect_patterns:
                    self.errors.append(
                        f"{test_file.name}:{line_num}: "
                        "Incorrect payment pattern - must be: preview → pay → execute"
                    )
                file_valid = False

        return file_valid

    def _has_user_story(self, content: str) -> bool:
        """Check if file has USER STORY comment."""
        return "USER STORY:" in content or "User Story:" in content

    def _find_smoke_tests(self, content: str) -> list:
        """Find tests with assert_true(true) pattern."""
        smoke_tests = []
        lines = content.split('\n')
        current_test = None

        for i, line in enumerate(lines):
            if line.strip().startswith('func test_'):
                current_test = line.split('(')[0].replace('func ', '').strip()
            elif 'assert_true(true' in line and current_test:
                # Allow if it's a documented placeholder
                if i + 1 < len(lines) and 'placeholder' in lines[i].lower():
                    continue
                smoke_tests.append(current_test)
                current_test = None

        return smoke_tests

    def _find_assertions_without_messages(self, content: str) -> list:
        """Find assertions without clear failure messages."""
        missing = []
        lines = content.split('\n')

        # Assertions that require messages
        assertion_patterns = [
            r'assert_eq\([^,]+,\s*[^,]+\)\s*$',
            r'assert_true\([^,]+\)\s*$',
            r'assert_false\([^,]+\)\s*$',
            r'assert_gt\([^,]+,\s*[^,]+\)\s*$',
            r'assert_lt\([^,]+,\s*[^,]+\)\s*$',
        ]

        for i, line in enumerate(lines, 1):
            for pattern in assertion_patterns:
                if re.search(pattern, line.strip()):
                    # Check if it's in a comment explaining it
                    if not any(c in line for c in ['"', "'"]):
                        missing.append((i, line.strip()))

        return missing

    def _find_incorrect_payment_patterns(self, content: str) -> list:
        """Find execute_reroll() before subtract_currency() pattern."""
        incorrect = []
        lines = content.split('\n')

        for i, line in enumerate(lines, 1):
            if 'execute_reroll()' in line:
                # Look ahead for subtract_currency in next 5 lines
                for j in range(i, min(i + 5, len(lines))):
                    if 'subtract_currency' in lines[j]:
                        # execute_reroll came BEFORE subtract_currency = WRONG
                        incorrect.append(i)
                        break

        return incorrect

    def print_report(self) -> None:
        """Print validation report."""
        if not self.errors and not self.warnings:
            print("✅ All tests pass quality validation")
            return

        if self.errors:
            print("\n❌ Test Quality Errors (BLOCKING):")
            for error in self.errors:
                print(f"  • {error}")

        if self.warnings:
            print("\n⚠️  Test Quality Warnings:")
            for warning in self.warnings:
                print(f"  • {warning}")

        if self.errors:
            print("\n💡 Fix: See docs/test-file-template.md for examples")
            print("   Remove smoke tests, add user stories, use correct patterns")


def main():
    parser = argparse.ArgumentParser(description="Validate GDScript test quality")
    parser.add_argument(
        '--warn-only',
        action='store_true',
        help='Report issues as warnings only (do not block commit)'
    )
    args = parser.parse_args()

    test_dir = Path(__file__).parent.parent.parent / "scripts" / "tests"

    validator = TestQualityValidator(test_dir, warn_only=args.warn_only)
    all_valid = validator.validate_all_tests()
    validator.print_report()

    # In warn-only mode, always return 0 (success)
    if args.warn_only:
        return 0

    return 0 if all_valid else 1


if __name__ == "__main__":
    sys.exit(main())
