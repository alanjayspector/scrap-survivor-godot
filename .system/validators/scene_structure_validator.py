#!/usr/bin/env python3
"""
Scene Structure Validator

Validates that .tscn scene files have proper structure:
- All child nodes specify parent="..." attribute
- No orphan nodes (except root)
- Valid node hierarchy

Catches errors like:
  [node name="Child" type="HBoxContainer"]
when it should be:
  [node name="Child" type="HBoxContainer" parent="."]

Runs during pre-commit to catch scene file corruption before it's committed.
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


def discover_scene_files() -> List[Path]:
    """Auto-discover all .tscn scene files"""
    scene_files = []
    scenes_dir = PROJECT_ROOT / "scenes"
    if scenes_dir.exists():
        scene_files.extend(scenes_dir.rglob("*.tscn"))
    return sorted(scene_files)


def validate_scene_structure(scene_path: Path) -> Tuple[bool, List[str]]:
    """
    Validate scene file structure.

    Returns: (is_valid, error_messages)
    """
    errors = []

    try:
        content = scene_path.read_text()
        lines = content.split('\n')

        # Track if we've seen the root node
        root_node = None
        line_num = 0

        for i, line in enumerate(lines, 1):
            # Match node definitions: [node name="NodeName" type="NodeType" ...]
            node_match = re.match(r'\[node name="([^"]+)"\s+type="([^"]+)"([^\]]*)\]', line)

            if node_match:
                node_name = node_match.group(1)
                node_type = node_match.group(2)
                attributes = node_match.group(3)

                # First node is the root
                if root_node is None:
                    root_node = node_name
                    # Root should NOT have parent attribute
                    if 'parent=' in attributes:
                        errors.append(
                            f"Line {i}: Root node '{node_name}' should not have parent attribute\n"
                            f"  Found: {line.strip()}\n"
                            f"  Expected: [node name=\"{node_name}\" type=\"{node_type}\"]"
                        )
                else:
                    # All child nodes MUST have parent attribute
                    if 'parent=' not in attributes:
                        errors.append(
                            f"Line {i}: Child node '{node_name}' missing parent specification\n"
                            f"  Found: {line.strip()}\n"
                            f"  Expected: [node name=\"{node_name}\" type=\"{node_type}\" parent=\"...\"]"
                        )

                line_num = i

        # Verify we found at least one node
        if root_node is None:
            errors.append("No nodes found in scene file - file may be corrupted")

        return (len(errors) == 0, errors)

    except Exception as e:
        errors.append(f"Failed to parse scene file: {str(e)}")
        return (False, errors)


def main() -> int:
    """Main validation function"""
    print(f"{CYAN}🔍 Validating scene file structure...{NC}\n")

    scene_files = discover_scene_files()

    if not scene_files:
        print(f"{YELLOW}⚠️  No scene files found in scenes/ directory{NC}")
        return 0

    total_files = len(scene_files)
    valid_files = 0
    invalid_files = 0

    all_errors = []

    for scene_path in scene_files:
        relative_path = scene_path.relative_to(PROJECT_ROOT)
        is_valid, errors = validate_scene_structure(scene_path)

        if is_valid:
            valid_files += 1
            print(f"{GREEN}✅ Valid: {relative_path}{NC}")
        else:
            invalid_files += 1
            print(f"{RED}❌ Invalid: {relative_path}{NC}")
            for error in errors:
                print(f"{RED}   {error}{NC}")
            all_errors.append((relative_path, errors))
            print()

    # Summary
    print("\n" + "=" * 60)
    print(f"Scene Structure Validation Summary:")
    print(f"  Total files: {total_files}")
    print(f"  {GREEN}Valid: {valid_files}{NC}")
    print(f"  {RED}Invalid: {invalid_files}{NC}")
    print("=" * 60)

    if invalid_files > 0:
        print(f"\n{RED}❌ Scene structure validation FAILED{NC}\n")
        print(f"{YELLOW}FIX:{NC}")
        print(f"  1. Open scene in Godot Editor")
        print(f"  2. Verify all nodes appear correctly in Scene tree")
        print(f"  3. Save scene from editor (this fixes parent specifications)")
        print(f"  4. Or manually add parent=\"...\" to each child node")
        print()
        print(f"{YELLOW}Example fix for missing parent:{NC}")
        print(f"  Before: [node name=\"Child\" type=\"HBoxContainer\"]")
        print(f"  After:  [node name=\"Child\" type=\"HBoxContainer\" parent=\".\"]")
        print()
        return 1

    print(f"\n{GREEN}✅ All scene files have valid structure!{NC}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
