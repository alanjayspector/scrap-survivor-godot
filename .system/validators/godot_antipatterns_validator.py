#!/usr/bin/env python3
"""
Godot Anti-Patterns Validator

Validates GDScript code against community-documented anti-patterns.
Based on research from docs/godot-community-research.md.

Checks for:
1. get_parent() chains (2+ levels deep) - fragile parent coupling
2. get_node() in _process()/_physics_process() - performance issue
3. Missing @onready for node references - missing optimization
4. Missing type hints on @export variables - unclear API
5. Animation playback in game loop - state management issue

Exit Codes:
  0 - No anti-patterns detected
  1 - Critical anti-patterns found (blocking)
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


class AntiPattern:
    """Represents a detected anti-pattern."""
    def __init__(self, line_num: int, pattern_type: str, details: str, severity: str = "warning"):
        self.line_num = line_num
        self.pattern_type = pattern_type
        self.details = details
        self.severity = severity  # "error" or "warning"


def check_get_parent_chains(lines: List[str]) -> List[AntiPattern]:
    """
    Detect get_parent() chains that are 2+ levels deep.

    Example violations:
    - get_parent().get_parent()
    - get_parent().get_parent().get_parent()
    """
    patterns = []

    for line_num, line in enumerate(lines, start=1):
        # Count occurrences of .get_parent() in the line
        get_parent_count = line.count('.get_parent()')

        if get_parent_count >= 2:
            patterns.append(AntiPattern(
                line_num=line_num,
                pattern_type="get_parent_chain",
                details=f"Found {get_parent_count} chained get_parent() calls",
                severity="error"
            ))

    return patterns


def check_get_node_in_process(content: str, lines: List[str]) -> List[AntiPattern]:
    """
    Detect get_node() calls inside _process() or _physics_process().

    These should be cached in _ready() with @onready instead.
    """
    patterns = []

    # Find _process and _physics_process function bodies
    process_funcs = []

    # Match function definitions
    func_pattern = r'^\s*func\s+(_process|_physics_process)\s*\([^)]*\)'

    i = 0
    while i < len(lines):
        line = lines[i]

        if re.match(func_pattern, line):
            # Found a process function, scan its body
            func_start = i + 1
            indent_level = len(line) - len(line.lstrip())

            # Find end of function (next line with same or less indentation that starts a new func/class/etc)
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

                # Check for get_node() in this line
                if 'get_node(' in current_line or '$' in current_line:
                    # Check if it's a get_node call (not just in a string or comment)
                    if not re.search(r'#.*get_node\(', current_line):  # Not in comment
                        patterns.append(AntiPattern(
                            line_num=j + 1,
                            pattern_type="get_node_in_process",
                            details="get_node() call in _process() or _physics_process()",
                            severity="warning"
                        ))

                j += 1

            i = j
        else:
            i += 1

    return patterns


def check_missing_onready(lines: List[str]) -> List[AntiPattern]:
    """
    Detect node references assigned in _ready() that should use @onready.

    Pattern: var in class scope assigned with get_node in _ready
    """
    patterns = []

    # Find var declarations without @onready that look like node references
    var_pattern = r'^\s*var\s+(\w+)\s*:\s*(Node|Node2D|Node3D|Control|CanvasItem|Sprite2D|AnimatedSprite2D|CollisionShape2D|Area2D|CharacterBody2D|Label|Button|Panel|Timer|AudioStreamPlayer\w*|Camera2D|Camera3D|TileMap|RigidBody2D|StaticBody2D|GPUParticles2D|CPUParticles2D|Line2D|Polygon2D|ColorRect|TextureRect|NinePatchRect|RichTextLabel|ItemList|Tree|TabContainer|ScrollContainer|VBoxContainer|HBoxContainer|GridContainer|MarginContainer|CenterContainer)'

    for line_num, line in enumerate(lines, start=1):
        # Check for var declarations with Node types but no @onready
        if re.search(var_pattern, line):
            # Check if previous line has @onready
            if line_num > 1:
                prev_line = lines[line_num - 2].strip()
                if prev_line == '@onready':
                    continue  # Has @onready, good!

            # Check if line itself has @onready
            if '@onready' in line:
                continue

            patterns.append(AntiPattern(
                line_num=line_num,
                pattern_type="missing_onready",
                details="Node-typed variable without @onready (should cache in ready)",
                severity="warning"
            ))

    return patterns


def check_export_without_type(lines: List[str]) -> List[AntiPattern]:
    """
    Detect @export variables without type hints.

    Example violations:
    - @export var health = 100

    Should be:
    - @export var health: int = 100
    """
    patterns = []

    for line_num, line in enumerate(lines, start=1):
        # Check for @export on this or previous line
        has_export = '@export' in line
        if line_num > 1 and '@export' in lines[line_num - 2]:
            has_export = True

        if has_export and 'var ' in line:
            # Check if it has a type hint (contains : after var name)
            var_match = re.search(r'var\s+(\w+)\s*([=:])', line)
            if var_match:
                separator = var_match.group(2)
                if separator == '=':
                    # Has assignment but no type hint
                    patterns.append(AntiPattern(
                        line_num=line_num,
                        pattern_type="export_without_type",
                        details="@export variable without type hint",
                        severity="warning"
                    ))

    return patterns


def check_animation_in_process(content: str, lines: List[str]) -> List[AntiPattern]:
    """
    Detect animation.play() calls inside _process() without state checks.

    This can cause animations to restart every frame.
    """
    patterns = []

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

                # Check for .play() calls (animation or audio)
                if '.play(' in current_line and 'animation' in current_line.lower():
                    # Check if it's guarded by a condition
                    # Look back a few lines for an if statement
                    is_guarded = False
                    for k in range(max(0, j - 3), j):
                        if 'if ' in lines[k] or 'elif ' in lines[k]:
                            is_guarded = True
                            break

                    if not is_guarded:
                        patterns.append(AntiPattern(
                            line_num=j + 1,
                            pattern_type="animation_in_process",
                            details="Animation play() in _process() without state guard",
                            severity="warning"
                        ))

                j += 1

            i = j
        else:
            i += 1

    return patterns


def validate_file(file_path: Path) -> List[AntiPattern]:
    """Run all anti-pattern checks on a GDScript file."""
    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        all_patterns = []

        # Run all checks
        all_patterns.extend(check_get_parent_chains(lines))
        all_patterns.extend(check_get_node_in_process(content, lines))
        all_patterns.extend(check_missing_onready(lines))
        all_patterns.extend(check_export_without_type(lines))
        all_patterns.extend(check_animation_in_process(content, lines))

        return all_patterns

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")
        return []


def main():
    """Check all GDScript files for anti-patterns."""

    print(f"{CYAN}Checking for Godot anti-patterns...{NC}")

    file_patterns: Dict[Path, List[AntiPattern]] = defaultdict(list)
    checked_files = 0
    error_count = 0
    warning_count = 0

    # Check all .gd files in project
    for gd_file in PROJECT_ROOT.rglob("*.gd"):
        # Skip addons directory
        if "addons" in gd_file.parts:
            continue

        # Skip test files (community anti-patterns don't apply to test code)
        if "_test.gd" in gd_file.name or "test_" in gd_file.name:
            continue

        checked_files += 1
        patterns = validate_file(gd_file)

        if patterns:
            file_patterns[gd_file] = patterns
            for pattern in patterns:
                if pattern.severity == "error":
                    error_count += 1
                else:
                    warning_count += 1

    # Report results
    if not file_patterns:
        print(f"{GREEN}✅ No anti-patterns detected ({checked_files} files checked){NC}")
        return 0

    # Show warnings
    if warning_count > 0:
        print(f"\n{YELLOW}⚠️  Found {warning_count} anti-pattern warning(s) in {len(file_patterns)} file(s):{NC}\n")

        for file_path in sorted(file_patterns.keys()):
            patterns = file_patterns[file_path]
            warning_patterns = [p for p in patterns if p.severity == "warning"]

            if warning_patterns:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{YELLOW}{rel_path}:{NC}")

                for pattern in warning_patterns:
                    print(f"  Line {pattern.line_num}: {pattern.details}")

                    # Provide fix suggestions
                    if pattern.pattern_type == "get_node_in_process":
                        print(f"  {CYAN}💡 Fix: Cache with @onready var node = $NodePath in class scope{NC}")
                    elif pattern.pattern_type == "missing_onready":
                        print(f"  {CYAN}💡 Fix: Add @onready decorator before the var declaration{NC}")
                    elif pattern.pattern_type == "export_without_type":
                        print(f"  {CYAN}💡 Fix: Add type hint: @export var name: Type = value{NC}")
                    elif pattern.pattern_type == "animation_in_process":
                        print(f"  {CYAN}💡 Fix: Use state machine or only call play() on state changes{NC}")

                print()

    # Show errors (blocking)
    if error_count > 0:
        print(f"\n{RED}❌ Found {error_count} critical anti-pattern(s):{NC}\n")

        for file_path in sorted(file_patterns.keys()):
            patterns = file_patterns[file_path]
            error_patterns = [p for p in patterns if p.severity == "error"]

            if error_patterns:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{RED}{rel_path}:{NC}")

                for pattern in error_patterns:
                    print(f"  Line {pattern.line_num}: {pattern.details}")

                    # Provide fix suggestions
                    if pattern.pattern_type == "get_parent_chain":
                        print(f"  {CYAN}💡 Fix: Use signals or pass references via ready(). See docs/godot-community-research.md{NC}")

                print()

        print(f"{RED}🚫 BLOCKED: Fix critical anti-patterns before committing{NC}")
        print(f"{CYAN}📚 See docs/godot-community-research.md for detailed explanations{NC}")
        return 1

    # Warnings only, don't block
    if warning_count > 0:
        print(f"{YELLOW}⚠️  Consider fixing warnings for better code quality{NC}")
        print(f"{CYAN}📚 See docs/godot-community-research.md for best practices{NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
