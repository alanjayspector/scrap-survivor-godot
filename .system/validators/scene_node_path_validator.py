#!/usr/bin/env python3
"""
Scene Node Path Validator

Validates that @onready variable node paths in .gd scripts match the actual
node hierarchy in corresponding .tscn scene files.

Catches errors like:
  @onready var label: Label = $VictoryLabel
when the actual node path is $Content/VictoryLabel

Runs during pre-commit to catch scene/script mismatches before they're committed.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


class SceneNode:
    """Represents a node in the scene tree"""
    def __init__(self, name: str, parent: str = "."):
        self.name = name
        self.parent = parent
        self.children: List['SceneNode'] = []

    def get_path(self) -> str:
        """Get the full node path from root"""
        if self.parent == ".":
            return self.name
        # Build path by walking up parent chain
        return f"{self.parent}/{self.name}" if self.parent else self.name


def discover_scene_files() -> List[Path]:
    """Auto-discover all .tscn scene files"""
    scene_files = []
    scenes_dir = PROJECT_ROOT / "scenes"
    if scenes_dir.exists():
        scene_files.extend(scenes_dir.rglob("*.tscn"))
    return sorted(scene_files)


def parse_scene_file(scene_path: Path) -> Tuple[Optional[str], Dict[str, SceneNode]]:
    """
    Parse .tscn file to extract:
    - Script path attached to root node
    - Node hierarchy (name -> parent mapping)

    Returns: (script_path, node_dict)
    """
    script_path = None
    nodes: Dict[str, SceneNode] = {}
    parent_map: Dict[str, str] = {}  # node_name -> parent_name

    try:
        content = scene_path.read_text()

        # Find script attached to root node
        # Format: [node name="Root"] followed by script = ExtResource(...)
        root_node_match = re.search(r'\[node name="([^"]+)"[^\]]*\]\s*script\s*=\s*ExtResource\("([^"]+)"\)', content)
        if root_node_match:
            script_id = root_node_match.group(2)
            # Find the actual script path from ExtResource
            ext_resource_match = re.search(
                rf'\[ext_resource type="Script" path="([^"]+)" id="{re.escape(script_id)}"\]',
                content
            )
            if ext_resource_match:
                script_path = ext_resource_match.group(1)

        # Parse all nodes in the scene
        # Format: [node name="NodeName" type="NodeType" parent="ParentName"]
        # Note: First node has no parent (is the root), others may have parent="." or parent="NodeName"
        node_pattern = r'\[node name="([^"]+)"[^\]]*\]'
        is_first_node = True

        for match in re.finditer(node_pattern, content):
            node_name = match.group(1)
            node_block = match.group(0)

            # Extract parent attribute if it exists
            parent_match = re.search(r'parent="([^"]+)"', node_block)

            if is_first_node:
                # First node is always the root
                parent_name = None  # Root has no parent
                is_first_node = False
            elif parent_match:
                parent_name = parent_match.group(1)
            else:
                # No parent attribute means it's a child of root
                parent_name = "."

            nodes[node_name] = SceneNode(node_name, parent_name if parent_name else ".")
            parent_map[node_name] = parent_name if parent_name else "."

        # Find the root node (first node in the file, parent will be ".")
        root_node_name = None
        for node_name, node in nodes.items():
            if node.parent == ".":
                root_node_name = node_name
                break

        # Build parent-child relationships
        for node_name, node in nodes.items():
            parent_name = parent_map.get(node_name, ".")

            if parent_name == "." and node_name != root_node_name:
                # This is a child of the root
                if root_node_name and root_node_name in nodes:
                    nodes[root_node_name].children.append(node)
            elif parent_name != "." and parent_name in nodes:
                # This is a child of another named node
                nodes[parent_name].children.append(node)

        return script_path, nodes

    except Exception as e:
        print(f"{RED}Error parsing scene {scene_path}: {e}{NC}")
        return None, {}


def build_path_map(nodes: Dict[str, SceneNode]) -> Dict[str, str]:
    """
    Build a map of node paths from root.
    Returns: {full_path -> node_name}

    Example: {"Content/VictoryLabel": "VictoryLabel"}

    Note: In GDScript, $NodeName is relative to the scene root, so we don't
    include the root node name in paths. E.g., $UI/WaveComplete, not $Wasteland/UI/WaveComplete
    """
    path_map: Dict[str, str] = {}

    def walk_node(node: SceneNode, current_path: str = "", is_root: bool = False):
        # Add this node (skip root node name in path)
        if is_root:
            # Root node: don't add to path, just walk children
            for child in node.children:
                walk_node(child, "", False)
        else:
            if current_path:
                full_path = f"{current_path}/{node.name}"
            else:
                full_path = node.name

            path_map[full_path] = node.name

            # Walk children
            for child in node.children:
                walk_node(child, full_path, False)

    # Find root node (parent == ".")
    for node in nodes.values():
        if node.parent == ".":
            walk_node(node, "", True)
            break  # Only one root

    return path_map


def parse_script_onready_paths(script_path: Path) -> List[Tuple[int, str, str]]:
    """
    Parse .gd script for @onready references with $NodePath.

    Returns: [(line_number, variable_name, node_path)]

    Example: [(7, "victory_label", "Content/VictoryLabel")]
    """
    onready_refs = []

    try:
        lines = script_path.read_text().split('\n')

        # Pattern: @onready var name: Type = $Path/To/Node
        pattern = r'@onready\s+var\s+(\w+):\s*\w+\s*=\s*\$([^\s]+)'

        for i, line in enumerate(lines, start=1):
            match = re.search(pattern, line)
            if match:
                var_name = match.group(1)
                node_path = match.group(2)
                onready_refs.append((i, var_name, node_path))

        return onready_refs

    except Exception as e:
        print(f"{RED}Error parsing script {script_path}: {e}{NC}")
        return []


def validate_scene_script_pair(scene_path: Path, script_path: Path, nodes: Dict[str, SceneNode]) -> List[str]:
    """
    Validate that all @onready $NodePath references in the script
    actually exist in the scene.

    Returns: List of error messages
    """
    errors = []

    # Build path map
    path_map = build_path_map(nodes)

    # Get all valid paths (including direct node names)
    valid_paths = set(path_map.keys())
    valid_paths.update(nodes.keys())  # Also allow direct node names

    # Parse script for @onready references
    onready_refs = parse_script_onready_paths(script_path)

    for line_num, var_name, node_path in onready_refs:
        if node_path not in valid_paths:
            # Try to suggest a correction
            suggestion = find_closest_path(node_path, valid_paths)

            error_msg = f"  Line {line_num}: @onready var {var_name} references ${node_path} but this path does not exist in {scene_path.name}"
            if suggestion:
                error_msg += f"\n    {CYAN}💡 Did you mean: ${suggestion}{NC}"

            errors.append(error_msg)

    return errors


def find_closest_path(target: str, valid_paths: Set[str]) -> Optional[str]:
    """Find the closest matching path using simple heuristics"""
    target_parts = target.split('/')
    target_name = target_parts[-1]  # Last part of the path

    # Look for paths ending with the same node name
    candidates = [p for p in valid_paths if p.endswith(target_name)]

    if candidates:
        # Return the shortest matching path
        return min(candidates, key=len)

    return None


def main():
    print(f"{CYAN}Validating scene node paths...{NC}\n")

    scene_files = discover_scene_files()

    if not scene_files:
        print(f"{YELLOW}⚠️  No scene files found{NC}")
        return 0

    total_errors = []
    checked_count = 0

    for scene_path in scene_files:
        script_path_str, nodes = parse_scene_file(scene_path)

        if not script_path_str:
            # Scene doesn't have a script attached, skip
            continue

        # Convert script path to absolute
        # Format: res://path/to/script.gd -> PROJECT_ROOT/path/to/script.gd
        script_rel_path = script_path_str.replace("res://", "")
        script_path = PROJECT_ROOT / script_rel_path

        if not script_path.exists():
            print(f"{YELLOW}⚠️  Script not found: {script_path_str} for scene {scene_path.name}{NC}")
            continue

        # Validate this scene/script pair
        errors = validate_scene_script_pair(scene_path, script_path, nodes)

        if errors:
            print(f"{RED}❌ Scene/script mismatch in {scene_path.relative_to(PROJECT_ROOT)}:{NC}")
            for error in errors:
                print(error)
            print()
            total_errors.extend(errors)

        checked_count += 1

    print(f"Checked {checked_count} scene(s) with scripts")

    if total_errors:
        print(f"\n{RED}❌ Found {len(total_errors)} node path error(s){NC}")
        return 1
    else:
        print(f"{GREEN}✅ All scene node paths are valid{NC}")
        return 0


if __name__ == "__main__":
    sys.exit(main())
