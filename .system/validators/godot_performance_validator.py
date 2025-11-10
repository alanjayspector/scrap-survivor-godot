#!/usr/bin/env python3
"""
Godot Performance Validator

Validates GDScript code against performance patterns from docs/godot-performance-patterns.md.
Based on research for survivor-like games with 300+ entities targeting 60 FPS.

Checks for:
1. Node instantiation in _process()/_physics_process() (BLOCKING)
2. get_node() calls in hot paths (WARNING)
3. Excessive physics layers (WARNING)
4. Untyped loops (WARNING)
5. String concatenation in loops (WARNING)

Exit Codes:
  0 - No performance issues detected
  1 - Critical performance issues found (blocking)
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


class PerformanceIssue:
    """Represents a detected performance issue."""
    def __init__(self, line_num: int, issue_type: str, details: str, severity: str = "warning"):
        self.line_num = line_num
        self.issue_type = issue_type
        self.details = details
        self.severity = severity  # "error" or "warning"


def check_node_instantiation_in_process(content: str, lines: List[str]) -> List[PerformanceIssue]:
    """
    Detect Node.new() or instantiate() calls inside _process() or _physics_process().

    This causes frame stutters and should use object pooling instead.
    """
    issues = []

    # Find _process and _physics_process function bodies
    func_pattern = r'^\s*func\s+(_process|_physics_process)\s*\([^)]*\)'

    i = 0
    while i < len(lines):
        line = lines[i]

        if re.match(func_pattern, line):
            # Found a process function, scan its body
            func_start = i + 1
            indent_level = len(line) - len(line.lstrip())

            j = func_start
            while j < len(lines):
                current_line = lines[j]

                # Skip empty lines and comments
                if not current_line.strip() or current_line.strip().startswith('#'):
                    j += 1
                    continue

                current_indent = len(current_line) - len(current_line.lstrip())

                # If we hit same or lower indentation with a new declaration, function ended
                if current_indent <= indent_level and re.match(r'^\s*(func|class|signal|var|const|enum)\s', current_line):
                    break

                # Check for Node.new() or .instantiate()
                if 'Node.new()' in current_line or 'Node2D.new()' in current_line or '.instantiate()' in current_line:
                    # Make sure it's not in a comment
                    if not re.search(r'#.*\.instantiate\(', current_line):
                        issues.append(PerformanceIssue(
                            line_num=j + 1,
                            issue_type="node_instantiation_in_process",
                            details="Node instantiation in _process() causes frame stutters",
                            severity="error"
                        ))

                j += 1

            i = j
        else:
            i += 1

    return issues


def check_get_node_in_hot_paths(content: str, lines: List[str]) -> List[PerformanceIssue]:
    """
    Detect get_node() calls inside _process(), _physics_process(), or loops.

    These should be cached with @onready.
    """
    issues = []

    # Find hot path functions
    func_pattern = r'^\s*func\s+(_process|_physics_process|_input|_unhandled_input)\s*\([^)]*\)'

    i = 0
    while i < len(lines):
        line = lines[i]

        if re.match(func_pattern, line):
            # Found a hot path function, scan its body
            func_start = i + 1
            indent_level = len(line) - len(line.lstrip())

            j = func_start
            while j < len(lines):
                current_line = lines[j]

                # Skip empty lines and comments
                if not current_line.strip() or current_line.strip().startswith('#'):
                    j += 1
                    continue

                current_indent = len(current_line) - len(current_line.lstrip())

                # If we hit same or lower indentation with a new declaration, function ended
                if current_indent <= indent_level and re.match(r'^\s*(func|class|signal|var|const|enum)\s', current_line):
                    break

                # Check for get_node() or $ operator (shorthand for get_node)
                if 'get_node(' in current_line or re.search(r'\$[A-Z]', current_line):
                    # Make sure it's not in a comment
                    if not re.search(r'#.*get_node\(', current_line):
                        issues.append(PerformanceIssue(
                            line_num=j + 1,
                            issue_type="get_node_in_hot_path",
                            details="get_node() in hot path (should use @onready)",
                            severity="warning"
                        ))

                j += 1

            i = j
        else:
            i += 1

    return issues


def check_untyped_loops(lines: List[str]) -> List[PerformanceIssue]:
    """
    Detect for/while loops with untyped iterator variables.

    Static typing provides 15-25% performance improvement in tight loops.
    """
    issues = []

    for line_num, line in enumerate(lines, start=1):
        # Check for 'for item in collection:' without type hint
        for_match = re.search(r'for\s+(\w+)\s+in\s+', line)
        if for_match:
            var_name = for_match.group(1)
            # Check if there's a type hint (contains :)
            if ':' not in line:
                issues.append(PerformanceIssue(
                    line_num=line_num,
                    issue_type="untyped_loop",
                    details=f"Loop variable '{var_name}' has no type hint",
                    severity="warning"
                ))

    return issues


def check_string_concatenation_in_loops(content: str, lines: List[str]) -> List[PerformanceIssue]:
    """
    Detect string concatenation (+ operator) inside loops.

    This allocates new strings per concatenation; use string formatting instead.
    """
    issues = []

    # Find loops
    i = 0
    while i < len(lines):
        line = lines[i]

        # Check for loop start
        if re.match(r'^\s*(for|while)\s+', line):
            loop_start = i + 1
            indent_level = len(line) - len(line.lstrip())

            j = loop_start
            while j < len(lines):
                current_line = lines[j]

                # Skip empty lines and comments
                if not current_line.strip() or current_line.strip().startswith('#'):
                    j += 1
                    continue

                current_indent = len(current_line) - len(current_line.lstrip())

                # If we hit same or lower indentation, loop ended
                if current_indent <= indent_level:
                    break

                # Check for string concatenation with +
                # Look for patterns like "string" + var or var + "string"
                if re.search(r'["\']\s*\+|"\s*\+\s*', current_line):
                    issues.append(PerformanceIssue(
                        line_num=j + 1,
                        issue_type="string_concat_in_loop",
                        details="String concatenation in loop (use % formatting)",
                        severity="warning"
                    ))

                j += 1

            i = j
        else:
            i += 1

    return issues


def check_excessive_physics_layers(file_path: Path) -> List[PerformanceIssue]:
    """
    Check if scene uses more than 8 physics layers.

    Research shows 8+ layers cause 10-15% performance overhead.
    """
    issues = []

    # Only check .tscn files
    if file_path.suffix != '.tscn':
        return issues

    try:
        content = file_path.read_text(encoding='utf-8')

        # Count unique collision_layer and collision_mask values
        layer_matches = re.findall(r'collision_layer\s*=\s*(\d+)', content)
        mask_matches = re.findall(r'collision_mask\s*=\s*(\d+)', content)

        all_layers = set()
        for match in layer_matches + mask_matches:
            layer_value = int(match)
            # Count which bits are set (which layers are used)
            for bit in range(32):
                if layer_value & (1 << bit):
                    all_layers.add(bit + 1)

        if len(all_layers) > 8:
            issues.append(PerformanceIssue(
                line_num=1,
                issue_type="excessive_physics_layers",
                details=f"Using {len(all_layers)} physics layers (recommended: ≤8)",
                severity="warning"
            ))

    except Exception as e:
        pass  # Skip if can't parse

    return issues


def validate_file(file_path: Path) -> List[PerformanceIssue]:
    """Run all performance checks on a file."""
    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        all_issues = []

        # Only run script checks on .gd files
        if file_path.suffix == '.gd':
            all_issues.extend(check_node_instantiation_in_process(content, lines))
            all_issues.extend(check_get_node_in_hot_paths(content, lines))
            all_issues.extend(check_untyped_loops(lines))
            all_issues.extend(check_string_concatenation_in_loops(content, lines))

        # Run scene checks on .tscn files
        if file_path.suffix == '.tscn':
            all_issues.extend(check_excessive_physics_layers(file_path))

        return all_issues

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")
        return []


def main():
    """Check all GDScript and scene files for performance issues."""

    print(f"{CYAN}Checking for Godot performance anti-patterns...{NC}")

    file_issues: Dict[Path, List[PerformanceIssue]] = defaultdict(list)
    checked_files = 0
    error_count = 0
    warning_count = 0

    # Check all .gd and .tscn files in project
    for pattern in ['*.gd', '*.tscn']:
        for file in PROJECT_ROOT.rglob(pattern):
            # Skip addons directory
            if "addons" in file.parts:
                continue

            # Skip test files for .gd
            if file.suffix == '.gd' and ("_test.gd" in file.name or "test_" in file.name):
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
        print(f"{GREEN}✅ No performance issues detected ({checked_files} files checked){NC}")
        return 0

    # Show warnings
    if warning_count > 0:
        print(f"\n{YELLOW}⚠️  Found {warning_count} performance warning(s) in {len(file_issues)} file(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            warning_issues = [i for i in issues if i.severity == "warning"]

            if warning_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{YELLOW}{rel_path}:{NC}")

                for issue in warning_issues:
                    print(f"  Line {issue.line_num}: {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "get_node_in_hot_path":
                        print(f"  {CYAN}💡 Fix: Cache with @onready var node = $NodePath{NC}")
                    elif issue.issue_type == "untyped_loop":
                        print(f"  {CYAN}💡 Fix: Add type hint: for item: Type in collection{NC}")
                    elif issue.issue_type == "string_concat_in_loop":
                        print(f"  {CYAN}💡 Fix: Use formatting: 'Text: %s' % value{NC}")
                    elif issue.issue_type == "excessive_physics_layers":
                        print(f"  {CYAN}💡 Fix: Consolidate to ≤8 layers for better performance{NC}")

                print()

    # Show errors (blocking)
    if error_count > 0:
        print(f"\n{RED}❌ Found {error_count} critical performance issue(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            error_issues = [i for i in issues if i.severity == "error"]

            if error_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{RED}{rel_path}:{NC}")

                for issue in error_issues:
                    print(f"  Line {issue.line_num}: {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "node_instantiation_in_process":
                        print(f"  {CYAN}💡 Fix: Use object pooling. See docs/godot-performance-patterns.md{NC}")

                print()

        print(f"{RED}🚫 BLOCKED: Fix critical performance issues before committing{NC}")
        print(f"{CYAN}📚 See docs/godot-performance-patterns.md for optimization strategies{NC}")
        return 1

    # Warnings only, don't block
    if warning_count > 0:
        print(f"{YELLOW}⚠️  Consider fixing warnings for better performance (15-80% FPS gains possible){NC}")
        print(f"{CYAN}📚 See docs/godot-performance-patterns.md for detailed benchmarks{NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
