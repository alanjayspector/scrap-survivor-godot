#!/usr/bin/env python3
"""
Test Patterns Validator

Validates GDScript test files against patterns from docs/godot-testing-research.md.
Based on GUT framework best practices for Godot 4.5.1.

Checks for:
1. Required test structure (extends GutTest, class_name)
2. Test naming convention (test_[object]_[action]_[expected_result])
3. Hardcoded delays (ERROR for >1 second waits)
4. Lifecycle hooks (before_each, after_each)
5. Assertions presence (at least one per test)

Exit Codes:
  0 - No test pattern issues detected
  1 - Critical test pattern issues found (blocking)
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple, Dict
from collections import defaultdict

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


class TestPatternIssue:
    """Represents a detected test pattern issue."""
    def __init__(self, line_num: int, issue_type: str, details: str, severity: str = "warning"):
        self.line_num = line_num
        self.issue_type = issue_type
        self.details = details
        self.severity = severity  # "error" or "warning"


def check_test_structure(file_path: Path, content: str) -> List[TestPatternIssue]:
    """
    Check if test file has required structure:
    - extends GutTest (recommended for GUT framework)
    - class_name [ServiceName]Test
    """
    issues = []

    # Only check test files
    if not file_path.name.endswith("_test.gd"):
        return issues

    # Check extends GutTest (WARNING since GUT adoption is optional)
    if not re.search(r'^\s*extends\s+GutTest\s*$', content, re.MULTILINE):
        # Check if using basic Node-based tests
        if re.search(r'^\s*extends\s+Node\s*$', content, re.MULTILINE):
            issues.append(TestPatternIssue(
                line_num=1,
                issue_type="not_using_gut",
                details="Test file extends Node (consider migrating to GUT framework)",
                severity="warning"
            ))
        else:
            issues.append(TestPatternIssue(
                line_num=1,
                issue_type="missing_guttest_extension",
                details="Test file should extend GutTest or Node",
                severity="warning"
            ))

    # Check class_name present (skip for editor_only tests to avoid conflicts)
    is_editor_only = "editor_only" in str(file_path)
    class_name_match = re.search(r'^\s*class_name\s+(\w+)', content, re.MULTILINE)
    if not class_name_match and not is_editor_only:
        issues.append(TestPatternIssue(
            line_num=1,
            issue_type="missing_class_name",
            details="Test file should have class_name declaration",
            severity="warning"
        ))
    elif class_name_match:
        # Check class_name follows convention (*Test)
        class_name = class_name_match.group(1)
        if not class_name.endswith("Test"):
            issues.append(TestPatternIssue(
                line_num=1,
                issue_type="class_name_convention",
                details=f"Test class_name should end with 'Test' (got {class_name})",
                severity="warning"
            ))

    return issues


def check_test_naming_convention(content: str, lines: List[str]) -> List[TestPatternIssue]:
    """
    Check test method names follow convention: test_[object]_[action]_[expected_result]

    Good: test_player_takes_damage_health_decreases
    Bad: test_player, test1, check_something
    """
    issues = []

    # Find all test methods
    test_method_pattern = r'^\s*func\s+(test_\w+)\s*\('

    for line_num, line in enumerate(lines, start=1):
        match = re.match(test_method_pattern, line)
        if not match:
            continue

        test_name = match.group(1)

        # Check 1: Starts with "test_"
        if not test_name.startswith("test_"):
            issues.append(TestPatternIssue(
                line_num=line_num,
                issue_type="test_naming",
                details=f"Test method '{test_name}' should start with 'test_'",
                severity="error"
            ))
            continue

        # Check 2: Has descriptive name (at least 3 parts: test_object_action_result)
        # Count underscores to gauge descriptiveness
        underscore_count = test_name.count('_')

        if underscore_count < 2:  # test_something (too vague)
            issues.append(TestPatternIssue(
                line_num=line_num,
                issue_type="test_naming_vague",
                details=f"Test name '{test_name}' too vague (use: test_[object]_[action]_[result])",
                severity="warning"
            ))

        # Check 3: Avoid generic names
        GENERIC_NAMES = ["test_it_works", "test_basic", "test_example", "test_1", "test_2"]
        if test_name.lower() in GENERIC_NAMES:
            issues.append(TestPatternIssue(
                line_num=line_num,
                issue_type="test_naming_generic",
                details=f"Test name '{test_name}' is too generic",
                severity="warning"
            ))

    return issues


def check_hardcoded_delays(content: str, lines: List[str]) -> List[TestPatternIssue]:
    """
    Detect hardcoded delays, especially >1 second waits.

    ERROR: await get_tree().create_timer(1.0+).timeout
    WARNING: Any create_timer usage (suggest wait_for_signal)
    """
    issues = []

    # Pattern: await get_tree().create_timer(X).timeout
    timer_pattern = r'await\s+get_tree\(\)\.create_timer\s*\(\s*([\d.]+)\s*\)\.timeout'

    for line_num, line in enumerate(lines, start=1):
        # Skip comments
        if line.strip().startswith('#'):
            continue

        match = re.search(timer_pattern, line)
        if match:
            delay_value = float(match.group(1))

            if delay_value >= 1.0:
                issues.append(TestPatternIssue(
                    line_num=line_num,
                    issue_type="hardcoded_delay",
                    details=f"Hardcoded delay {delay_value}s (use wait_for_signal instead)",
                    severity="error"
                ))
            else:
                issues.append(TestPatternIssue(
                    line_num=line_num,
                    issue_type="hardcoded_delay_short",
                    details=f"Hardcoded delay {delay_value}s (prefer wait_for_signal for reliability)",
                    severity="warning"
                ))

    return issues


def check_lifecycle_hooks(content: str) -> List[TestPatternIssue]:
    """
    Check for presence of lifecycle hooks (before_each, after_each).

    WARNING if before_each missing (setup recommended)
    INFO if after_each missing (cleanup recommended)
    """
    issues = []

    has_before_each = bool(re.search(r'func\s+before_each\s*\(', content))
    has_after_each = bool(re.search(r'func\s+after_each\s*\(', content))

    if not has_before_each:
        issues.append(TestPatternIssue(
            line_num=1,
            issue_type="missing_before_each",
            details="Test file should have before_each() for setup",
            severity="warning"
        ))

    if not has_after_each:
        issues.append(TestPatternIssue(
            line_num=1,
            issue_type="missing_after_each",
            details="Test file should have after_each() for cleanup",
            severity="warning"
        ))

    return issues


def check_assertions_presence(content: str, lines: List[str]) -> List[TestPatternIssue]:
    """
    Check that test methods have at least one assertion.

    WARNING if test method has no assert_* calls
    """
    issues = []

    # Find all test methods
    test_methods = []
    test_method_pattern = r'^\s*func\s+(test_\w+)\s*\('

    i = 0
    while i < len(lines):
        line = lines[i]
        match = re.match(test_method_pattern, line)

        if match:
            test_name = match.group(1)
            test_start = i + 1
            indent_level = len(line) - len(line.lstrip())

            # Find method body
            j = test_start
            method_body = []
            while j < len(lines):
                current_line = lines[j]

                # Skip empty lines and comments
                if not current_line.strip() or current_line.strip().startswith('#'):
                    j += 1
                    continue

                current_indent = len(current_line) - len(current_line.lstrip())

                # If we hit same or lower indentation with a new declaration, method ended
                if current_indent <= indent_level and re.match(r'^\s*(func|class|signal|var|const|enum)\s', current_line):
                    break

                method_body.append(current_line)
                j += 1

            test_methods.append((test_name, i + 1, '\n'.join(method_body)))
            i = j
        else:
            i += 1

    # Check each test method for assertions
    ASSERTION_PATTERNS = [
        # Basic GDScript assertions
        r'\bassert\(',
        # GUT framework assertions - Comparison
        r'assert_eq\(',
        r'assert_ne\(',
        r'assert_almost_eq\(',  # Floating point comparisons
        r'assert_almost_ne\(',
        r'assert_gt\(',
        r'assert_lt\(',
        r'assert_gte\(',
        r'assert_lte\(',
        r'assert_between\(',
        # GUT framework assertions - Boolean/Null
        r'assert_true\(',
        r'assert_false\(',
        r'assert_null\(',
        r'assert_not_null\(',
        # GUT framework assertions - Collections
        r'assert_has\(',
        r'assert_does_not_have\(',
        # GUT framework assertions - Strings
        r'assert_string_contains\(',
        r'assert_string_starts_with\(',
        r'assert_string_ends_with\(',
        # GUT framework assertions - Signals (complete set)
        # Reference: docs/godot-gut-framework-validation.md
        # GUT 9.0+ signal assertions verified from official docs
        r'assert_signal_emitted\(',
        r'assert_signal_not_emitted\(',  # Added - was causing false positives
        r'assert_signal_emit_count\(',
        r'assert_signal_emitted_with_parameters\(',
        r'assert_has_signal\(',
        # GUT framework assertions - Method calls
        r'assert_called\(',
        r'assert_not_called\(',
    ]

    for test_name, line_num, body in test_methods:
        # Check if test uses pending() - this is a valid GUT framework method
        # for marking tests as intentionally disabled/skipped
        # Reference: docs/godot-gut-framework-validation.md
        # GUT 9.0+: pending(text="") marks test as pending, not a failure
        if re.search(r'\bpending\(', body):
            continue  # Skip - pending tests are intentionally incomplete

        has_assertion = any(re.search(pattern, body) for pattern in ASSERTION_PATTERNS)

        if not has_assertion:
            issues.append(TestPatternIssue(
                line_num=line_num,
                issue_type="missing_assertion",
                details=f"Test '{test_name}' has no assertions",
                severity="warning"
            ))

    return issues


def check_memory_management(content: str, lines: List[str]) -> List[TestPatternIssue]:
    """
    Check for proper memory management in tests:
    - Node/CharacterBody2D/Player instances should be freed with .free() not .queue_free()
    - Tests creating instances should have cleanup in after_each() or test method
    - Watch for orphaned instances (created but never freed)
    - GUT framework: add_child_autofree() is valid (automatically frees nodes)
    """
    issues = []

    # Pattern 1: Find all instance creations of Node-based classes
    instance_creations = []
    for line_num, line in enumerate(lines, 1):
        # Match patterns like: var player = Player.new()
        match = re.search(r'var\s+(\w+)\s*=\s*(Player|Enemy|CharacterBody2D|Node2D|Node|Control)\.new\(\)', line)
        if match:
            var_name = match.group(1)
            class_name = match.group(2)
            instance_creations.append((line_num, var_name, class_name))

    # Pattern 2: Check if instances are freed
    for create_line, var_name, class_name in instance_creations:
        # Look for .free() or .queue_free() calls for this variable
        freed_with_free = any(f"{var_name}.free()" in line for line in lines)
        freed_with_queue_free = any(f"{var_name}.queue_free()" in line for line in lines)
        # GUT framework: add_child_autofree() automatically frees the node
        # Pattern: add_child_autofree(var_name) - node is passed to autofree
        # Reference: docs/godot-testing-research.md:686 - add_child_autofree() is recommended pattern
        freed_with_autofree = any(f"add_child_autofree({var_name})" in line for line in lines)

        if not freed_with_free and not freed_with_queue_free and not freed_with_autofree:
            issues.append(TestPatternIssue(
                line_num=create_line,
                issue_type="missing_free",
                details=f"Variable '{var_name}' ({class_name}) created but never freed - potential memory leak",
                severity="warning"
            ))
        elif freed_with_queue_free and not freed_with_free:
            # Find the line where queue_free() is used
            queue_free_line = next((i+1 for i, line in enumerate(lines) if f"{var_name}.queue_free()" in line), create_line)
            issues.append(TestPatternIssue(
                line_num=queue_free_line,
                issue_type="queue_free_in_test",
                details=f"Use '{var_name}.free()' instead of '.queue_free()' in tests (immediate vs deferred)",
                severity="warning"
            ))

    # Pattern 3: Check for after_each() cleanup
    has_after_each = re.search(r'func\s+after_each\s*\(\s*\)', content)
    if instance_creations and not has_after_each:
        issues.append(TestPatternIssue(
            line_num=1,
            issue_type="missing_after_each_cleanup",
            details="Tests create instances but lack after_each() for cleanup",
            severity="warning"
        ))

    return issues


def validate_file(file_path: Path) -> List[TestPatternIssue]:
    """Run all test pattern checks on a file."""
    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        all_issues = []

        # Run all checks
        all_issues.extend(check_test_structure(file_path, content))
        all_issues.extend(check_test_naming_convention(content, lines))
        all_issues.extend(check_hardcoded_delays(content, lines))
        all_issues.extend(check_lifecycle_hooks(content))
        all_issues.extend(check_assertions_presence(content, lines))
        all_issues.extend(check_memory_management(content, lines))

        return all_issues

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")
        return []


def main():
    """Check all test files for pattern issues."""

    print(f"{CYAN}Checking for test pattern issues...{NC}")

    file_issues: Dict[Path, List[TestPatternIssue]] = defaultdict(list)
    checked_files = 0
    error_count = 0
    warning_count = 0

    # Check all *_test.gd files
    for file in PROJECT_ROOT.rglob("*_test.gd"):
        # Skip files in addons
        if "addons" in file.parts:
            continue

        checked_files += 1
        issues = validate_file(file)

        if issues:
            file_issues[file] = issues
            for issue in issues:
                if issue.severity == "error":
                    error_count += 1
                else:
                    warning_count += 1

    # Report results
    if not file_issues:
        print(f"{GREEN}✅ No test pattern issues detected ({checked_files} test files checked){NC}")
        return 0

    # Show warnings
    if warning_count > 0:
        print(f"\n{YELLOW}⚠️  Found {warning_count} test pattern warning(s) in {len(file_issues)} file(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            warning_issues = [i for i in issues if i.severity == "warning"]

            if warning_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{YELLOW}{rel_path}:{NC}")

                for issue in warning_issues:
                    if issue.line_num > 1:
                        print(f"  Line {issue.line_num}: {issue.details}")
                    else:
                        print(f"  {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "test_naming_vague":
                        print(f"  {CYAN}💡 Fix: Use pattern test_[object]_[action]_[expected_result]{NC}")
                    elif issue.issue_type == "test_naming_generic":
                        print(f"  {CYAN}💡 Fix: Be specific about what behavior is being tested{NC}")
                    elif issue.issue_type == "hardcoded_delay_short":
                        print(f"  {CYAN}💡 Fix: Use await signal_name or gut.wait_for_signal(){NC}")
                    elif issue.issue_type == "missing_before_each":
                        print(f"  {CYAN}💡 Fix: Add func before_each() -> void for test setup{NC}")
                    elif issue.issue_type == "missing_after_each":
                        print(f"  {CYAN}💡 Fix: Add func after_each() -> void for cleanup{NC}")
                    elif issue.issue_type == "missing_assertion":
                        print(f"  {CYAN}💡 Fix: Add at least one assert_* call to verify behavior{NC}")
                    elif issue.issue_type == "missing_class_name":
                        print(f"  {CYAN}💡 Fix: Add class_name [ServiceName]Test{NC}")
                    elif issue.issue_type == "class_name_convention":
                        print(f"  {CYAN}💡 Fix: Rename class to end with 'Test'{NC}")

                print()

    # Show errors (blocking)
    if error_count > 0:
        print(f"\n{RED}❌ Found {error_count} critical test pattern issue(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            error_issues = [i for i in issues if i.severity == "error"]

            if error_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{RED}{rel_path}:{NC}")

                for issue in error_issues:
                    if issue.line_num > 1:
                        print(f"  Line {issue.line_num}: {issue.details}")
                    else:
                        print(f"  {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "not_using_gut":
                        print(f"  {CYAN}💡 Info: GUT framework provides better test structure and assertions{NC}")
                        print(f"  {CYAN}   See docs/godot-testing-research.md for GUT migration guide{NC}")
                    elif issue.issue_type == "missing_guttest_extension":
                        print(f"  {CYAN}💡 Fix: Change to 'extends GutTest' or 'extends Node'{NC}")
                    elif issue.issue_type == "hardcoded_delay":
                        print(f"  {CYAN}💡 Fix: Replace with await signal_name or wait for conditions{NC}")
                        print(f"  {CYAN}   Reason: Hardcoded delays make tests flaky and slow{NC}")
                    elif issue.issue_type == "test_naming":
                        print(f"  {CYAN}💡 Fix: Method name must start with 'test_'{NC}")

                print()

        print(f"{RED}🚫 BLOCKED: Fix critical test pattern issues before committing{NC}")
        print(f"{CYAN}📚 See docs/godot-testing-research.md for testing best practices{NC}")
        return 1

    # Warnings only, don't block
    if warning_count > 0:
        print(f"{YELLOW}⚠️  Consider fixing warnings for better test quality{NC}")
        print(f"{CYAN}📚 See docs/godot-testing-research.md for testing best practices{NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
