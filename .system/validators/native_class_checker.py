#!/usr/bin/env python3
"""
Native Class Name Checker

Validates that custom class_name declarations don't conflict with Godot's
native classes. Prevents catastrophic parse errors like the Logger incident
from Week 5.

Exit Codes:
  0 - All class names are safe
  1 - Conflicts detected (blocking)
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent

# Godot 4.x native classes that are commonly conflicted with
# Source: https://docs.godotengine.org/en/stable/classes/
GODOT_NATIVE_CLASSES = {
    # Core classes
    "Logger", "Object", "RefCounted", "Resource", "Node",
    "Control", "CanvasItem", "Node2D", "Node3D",

    # Common UI
    "Button", "Label", "Panel", "Container", "VBoxContainer", "HBoxContainer",
    "ScrollContainer", "TabContainer", "Window", "PopupMenu", "LineEdit",
    "TextEdit", "RichTextLabel", "CheckBox", "SpinBox", "Slider",

    # 2D
    "Sprite2D", "AnimatedSprite2D", "Camera2D", "TileMap", "CollisionShape2D",
    "Area2D", "CharacterBody2D", "RigidBody2D", "StaticBody2D", "KinematicBody2D",
    "VisibleOnScreenNotifier2D", "Line2D", "Polygon2D",

    # 3D
    "Sprite3D", "Camera3D", "MeshInstance3D", "CollisionShape3D",
    "Area3D", "CharacterBody3D", "RigidBody3D", "StaticBody3D",
    "DirectionalLight3D", "OmniLight3D", "SpotLight3D",

    # Resources
    "Texture", "Texture2D", "Image", "Font", "Material", "Shader",
    "Animation", "AudioStream", "PackedScene", "Theme", "StyleBox",
    "Gradient", "Curve", "Mesh",

    # Input/Output
    "Input", "InputEvent", "InputEventKey", "InputEventMouse",
    "File", "FileAccess", "Directory", "DirAccess", "ConfigFile",

    # Utilities
    "Timer", "Tween", "HTTPRequest", "JSON", "RandomNumberGenerator",
    "PackedByteArray", "PackedInt32Array", "PackedFloat32Array",
    "PackedVector2Array", "PackedVector3Array", "PackedColorArray",

    # Signals/Scripting
    "Signal", "Callable", "Variant", "GDScript", "Script", "ScriptExtension",

    # Math
    "Vector2", "Vector3", "Vector4", "Rect2", "AABB", "Transform2D", "Transform3D",
    "Quaternion", "Basis", "Plane", "Color", "Vector2i", "Vector3i",

    # Data structures
    "Array", "Dictionary", "String", "StringName",

    # Physics
    "PhysicsBody2D", "PhysicsBody3D", "CollisionObject2D", "CollisionObject3D",

    # Audio
    "AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D",

    # Particles
    "GPUParticles2D", "GPUParticles3D", "CPUParticles2D", "CPUParticles3D",

    # Navigation
    "NavigationAgent2D", "NavigationAgent3D", "NavigationRegion2D", "NavigationRegion3D",
}


def find_class_name_conflicts(file_path: Path) -> List[Tuple[int, str, str]]:
    """
    Find class_name declarations that conflict with Godot natives.

    Returns:
        List of (line_number, class_name, conflict_type) tuples
    """
    conflicts = []

    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        for line_num, line in enumerate(lines, start=1):
            # Match: class_name ClassName
            match = re.match(r'^\s*class_name\s+(\w+)', line)
            if match:
                class_name = match.group(1)

                if class_name in GODOT_NATIVE_CLASSES:
                    conflicts.append((line_num, class_name, "native_class"))

                # Also check for common typos/variants (case-insensitive)
                class_name_lower = class_name.lower()
                for native in GODOT_NATIVE_CLASSES:
                    if native.lower() == class_name_lower and native != class_name:
                        conflicts.append((line_num, class_name, f"case_mismatch:{native}"))
                        break

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")

    return conflicts


def main():
    """Check all GDScript files for native class name conflicts."""

    print("Checking for native class name conflicts...")

    all_conflicts = []
    checked_files = 0

    # Check all .gd files in project
    for gd_file in PROJECT_ROOT.rglob("*.gd"):
        # Skip addons directory
        if "addons" in gd_file.parts:
            continue

        checked_files += 1
        conflicts = find_class_name_conflicts(gd_file)

        if conflicts:
            all_conflicts.append((gd_file, conflicts))

    # Report results
    if not all_conflicts:
        print(f"{GREEN}✅ No native class name conflicts found ({checked_files} files checked){NC}")
        return 0

    print(f"\n{RED}❌ Found {len(all_conflicts)} file(s) with native class name conflicts:{NC}\n")

    for file_path, conflicts in all_conflicts:
        rel_path = file_path.relative_to(PROJECT_ROOT)
        print(f"{RED}{rel_path}:{NC}")

        for line_num, class_name, conflict_type in conflicts:
            if conflict_type == "native_class":
                print(f"  Line {line_num}: class_name '{class_name}' conflicts with Godot native class")
                print(f"  {YELLOW}💡 Fix: Rename to '{class_name}Custom' or 'Game{class_name}'{NC}")
            elif conflict_type.startswith("case_mismatch:"):
                correct = conflict_type.split(":")[1]
                print(f"  Line {line_num}: class_name '{class_name}' may conflict (correct case: '{correct}')")
                print(f"  {YELLOW}💡 Fix: Use exact case '{correct}' or rename to avoid confusion{NC}")
        print()

    print(f"{RED}🚫 BLOCKED: Fix native class name conflicts before committing{NC}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
