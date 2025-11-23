#!/usr/bin/env python3
"""
Parent-First Protocol Validator
Checks GDScript files for violations of the Godot 4 Parent-First Protocol.

CRITICAL: All dynamic UI node creation must follow Parent-First Protocol to prevent iOS SIGKILL.

Violation Pattern:
    var node = Control.new()
    node.property = value  # ❌ Configure BEFORE parenting
    parent.add_child(node)

Correct Pattern:
    var node = Control.new()
    parent.add_child(node)  # ✅ Parent FIRST
    node.layout_mode = 2
    node.property = value  # ✅ Configure AFTER parenting

This validator performs basic pattern detection to catch common violations.
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple


class ParentFirstViolation:
    def __init__(self, file_path: str, line_num: int, line_content: str, reason: str):
        self.file_path = file_path
        self.line_num = line_num
        self.line_content = line_content.strip()
        self.reason = reason

    def __str__(self):
        return f"{self.file_path}:{self.line_num} - {self.reason}\n  {self.line_content}"


def check_file(file_path: Path) -> List[ParentFirstViolation]:
    """Check a single GDScript file for Parent-First Protocol violations."""
    violations = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)
        return violations

    # Track variable assignments and configuration
    # Format: {var_name: {'created_line': int, 'configured_before_parent': bool, 'parented_line': int}}
    tracked_vars = {}

    for i, line in enumerate(lines, start=1):
        stripped = line.strip()

        # Skip comments and empty lines
        if not stripped or stripped.startswith('#'):
            continue

        # Pattern 1: Variable created with .new()
        # var node = VBoxContainer.new()
        new_match = re.search(r'var\s+(\w+)\s*=\s*(\w+)\.new\(\)', stripped)
        if new_match:
            var_name = new_match.group(1)
            node_type = new_match.group(2)
            # Only track Control node types
            if node_type in ['Control', 'Button', 'Label', 'Panel', 'VBoxContainer',
                            'HBoxContainer', 'GridContainer', 'MarginContainer',
                            'ScrollContainer', 'PanelContainer', 'ColorRect',
                            'TextureRect', 'HSeparator', 'VSeparator']:
                tracked_vars[var_name] = {
                    'created_line': i,
                    'node_type': node_type,
                    'configured_before_parent': False,
                    'parented_line': None
                }

        # Pattern 2: Configuration before parenting
        # node.some_property = value
        # node.method_call(...)
        for var_name in list(tracked_vars.keys()):
            if tracked_vars[var_name]['parented_line'] is None:  # Not yet parented
                # Check for property assignment or method call
                config_pattern = re.search(rf'\b{var_name}\.([\w_]+)\s*[=\(]', stripped)
                if config_pattern:
                    property_or_method = config_pattern.group(1)
                    # Ignore add_child calls (that's parenting children TO this node, which is OK)
                    if property_or_method != 'add_child':
                        tracked_vars[var_name]['configured_before_parent'] = True

        # Pattern 3: Parenting the variable
        # parent.add_child(node)
        for var_name in list(tracked_vars.keys()):
            if tracked_vars[var_name]['parented_line'] is None:  # Not yet parented
                parent_pattern = re.search(rf'\.add_child\(\s*{var_name}\s*\)', stripped)
                if parent_pattern:
                    tracked_vars[var_name]['parented_line'] = i

                    # Check if it was configured before parenting
                    if tracked_vars[var_name]['configured_before_parent']:
                        violations.append(ParentFirstViolation(
                            str(file_path),
                            tracked_vars[var_name]['created_line'],
                            f"var {var_name} = {tracked_vars[var_name]['node_type']}.new()",
                            f"Node configured before parenting (parented at line {i}). "
                            f"VIOLATION: Properties set between creation and add_child() call."
                        ))

    return violations


def main():
    """Run Parent-First Protocol validation on all GDScript files in scripts/ui/"""
    root_dir = Path(__file__).parent.parent.parent
    ui_dir = root_dir / 'scripts' / 'ui'

    if not ui_dir.exists():
        print(f"Error: UI directory not found: {ui_dir}", file=sys.stderr)
        return 1

    print("Parent-First Protocol Validator")
    print("=" * 60)
    print(f"Scanning: {ui_dir}")
    print()

    all_violations = []
    files_checked = 0

    for gd_file in ui_dir.rglob('*.gd'):
        files_checked += 1
        violations = check_file(gd_file)
        all_violations.extend(violations)

    print(f"Files checked: {files_checked}")
    print(f"Violations found: {len(all_violations)}")
    print()

    if all_violations:
        print("VIOLATIONS DETECTED:")
        print("=" * 60)
        for violation in all_violations:
            print(violation)
            print()
        print("=" * 60)
        print()
        print("To fix violations:")
        print("1. Move all property assignments AFTER add_child() call")
        print("2. Set layout_mode = 2 immediately after add_child()")
        print("3. Configure other properties after layout_mode")
        print()
        return 1
    else:
        print("✅ No Parent-First Protocol violations detected!")
        print()
        return 0


if __name__ == '__main__':
    sys.exit(main())
