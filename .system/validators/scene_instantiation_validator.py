#!/usr/bin/env python3
"""
Scene Instantiation Validator

Tests that .tscn scene files can actually be instantiated in Godot.
Catches issues like:
- Corrupted scene files
- Missing parent specifications
- Invalid node references
- Script errors that prevent instantiation

Uses Godot in headless mode to verify:
- PackedScene.instantiate() returns non-null
- Scene loads without errors

Runs during pre-commit to catch instantiation failures before they're committed.
"""

import os
import re
import sys
import subprocess
import tempfile
from pathlib import Path
from typing import List, Tuple

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


def find_godot_binary() -> str:
    """Find Godot binary (same logic as godot_test_runner.py)"""
    # Check environment variable first
    godot_path = os.environ.get('GODOT_BIN')
    if godot_path and os.path.exists(godot_path):
        return godot_path

    # Common macOS locations
    common_paths = [
        '/Applications/Godot.app/Contents/MacOS/Godot',
        '/Applications/Godot_mono.app/Contents/MacOS/Godot',
        os.path.expanduser('~/Applications/Godot.app/Contents/MacOS/Godot'),
    ]

    for path in common_paths:
        if os.path.exists(path):
            return path

    raise FileNotFoundError(
        "Godot binary not found. Set GODOT_BIN environment variable or install Godot to /Applications/"
    )


def discover_scene_files() -> List[Path]:
    """Auto-discover all .tscn scene files (excluding test scenes)"""
    scene_files = []
    scenes_dir = PROJECT_ROOT / "scenes"

    if scenes_dir.exists():
        for scene_file in scenes_dir.rglob("*.tscn"):
            # Skip test scenes (they might have special requirements)
            if "tests/" not in str(scene_file):
                scene_files.append(scene_file)

    return sorted(scene_files)


def create_instantiation_test_script(scene_paths: List[Path]) -> str:
    """
    Create a GDScript that tests instantiation of all scenes.

    Returns: GDScript code as string
    """
    script_lines = [
        "extends SceneTree",
        "",
        "func _init():",
        "\tprint('[InstantiationTest] Starting scene instantiation tests')",
        "\tvar failed_scenes = []",
        "",
    ]

    for scene_path in scene_paths:
        # Convert absolute path to res:// path
        relative_path = scene_path.relative_to(PROJECT_ROOT)
        res_path = f"res://{relative_path}".replace("\\", "/")

        # Generate test code for this scene
        script_lines.append(f"\t# Test: {relative_path}")
        script_lines.append(f"\tvar scene_{scene_path.stem} = load(\"{res_path}\")")
        script_lines.append(f"\tif scene_{scene_path.stem} == null:")
        script_lines.append(f"\t\tprint('[InstantiationTest] FAILED: Could not load {res_path}')")
        script_lines.append(f"\t\tfailed_scenes.append('{res_path}')")
        script_lines.append(f"\telse:")
        script_lines.append(f"\t\tvar instance = scene_{scene_path.stem}.instantiate()")
        script_lines.append(f"\t\tif instance == null:")
        script_lines.append(f"\t\t\tprint('[InstantiationTest] FAILED: {res_path} - instantiate() returned null')")
        script_lines.append(f"\t\t\tfailed_scenes.append('{res_path}')")
        script_lines.append(f"\t\telse:")
        script_lines.append(f"\t\t\tprint('[InstantiationTest] PASSED: {res_path}')")
        script_lines.append(f"\t\t\tinstance.free()")
        script_lines.append("")

    # Print summary
    script_lines.append("\tif failed_scenes.size() > 0:")
    script_lines.append("\t\tprint('[InstantiationTest] SUMMARY: ' + str(failed_scenes.size()) + ' scene(s) failed')")
    script_lines.append("\t\tfor scene in failed_scenes:")
    script_lines.append("\t\t\tprint('[InstantiationTest] FAILED: ' + scene)")
    script_lines.append("\t\tquit(1)")
    script_lines.append("\telse:")
    script_lines.append("\t\tprint('[InstantiationTest] SUMMARY: All scenes instantiated successfully')")
    script_lines.append("\t\tquit(0)")

    return "\n".join(script_lines)


def test_scene_instantiation(godot_bin: str, scene_files: List[Path]) -> Tuple[bool, List[str]]:
    """
    Test that all scenes can be instantiated.

    Returns: (all_passed, failed_scenes)
    """
    # Create temporary test script
    test_script = create_instantiation_test_script(scene_files)

    with tempfile.NamedTemporaryFile(mode='w', suffix='.gd', delete=False) as f:
        f.write(test_script)
        temp_script_path = f.name

    try:
        # Run Godot with the test script
        cmd = [
            godot_bin,
            '--headless',
            '--script',
            temp_script_path,
            '--path',
            str(PROJECT_ROOT)
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60
        )

        # Parse output to find failed scenes
        failed_scenes = []
        for line in result.stdout.split('\n'):
            if '[InstantiationTest] FAILED:' in line:
                # Extract scene path from failure message
                match = re.search(r'FAILED: (.+)$', line)
                if match:
                    failed_scenes.append(match.group(1).strip())

        return (result.returncode == 0, failed_scenes)

    finally:
        # Clean up temporary file
        if os.path.exists(temp_script_path):
            os.remove(temp_script_path)


def main() -> int:
    """Main validation function"""
    print(f"{CYAN}🔍 Testing scene instantiation...{NC}\n")

    # Find Godot
    try:
        godot_bin = find_godot_binary()
        print(f"{GREEN}✓ Found Godot: {godot_bin}{NC}\n")
    except FileNotFoundError as e:
        print(f"{RED}❌ {str(e)}{NC}")
        return 1

    # Discover scenes
    scene_files = discover_scene_files()

    if not scene_files:
        print(f"{YELLOW}⚠️  No scene files found{NC}")
        return 0

    print(f"Testing {len(scene_files)} scene(s)...\n")

    # Test instantiation
    all_passed, failed_scenes = test_scene_instantiation(godot_bin, scene_files)

    # Summary
    print("\n" + "=" * 60)
    print(f"Scene Instantiation Summary:")
    print(f"  Total scenes: {len(scene_files)}")
    print(f"  {GREEN}Passed: {len(scene_files) - len(failed_scenes)}{NC}")
    print(f"  {RED}Failed: {len(failed_scenes)}{NC}")
    print("=" * 60)

    if not all_passed:
        print(f"\n{RED}❌ Scene instantiation validation FAILED{NC}\n")
        print(f"{YELLOW}Failed scenes:{NC}")
        for scene_path in failed_scenes:
            print(f"  {RED}✗{NC} {scene_path}")
        print()
        print(f"{YELLOW}FIX:{NC}")
        print(f"  1. Check scene structure with: python3 .system/validators/scene_structure_validator.py")
        print(f"  2. Open scene in Godot Editor and verify it loads without errors")
        print(f"  3. Check for missing parent specifications in .tscn file")
        print(f"  4. Verify attached scripts don't have syntax errors")
        print()
        return 1

    print(f"\n{GREEN}✅ All scenes can be instantiated!{NC}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
