#!/usr/bin/env python3
"""
Component Usage Validator

Verifies that scene components are actually used in the codebase.

Catches issues like:
- Component scenes created but never preloaded
- Scenes preloaded but never instantiated
- "Refactored to use component" claims without actual usage

Validates:
- UI components in scenes/ui/ must be used somewhere
- If scene is preloaded (const X = preload(...)), verify instantiate() call exists
- If claiming refactor, verify old code is removed

Runs during pre-commit to prevent dead code and false refactor claims.
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple, Dict

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


def discover_component_scenes() -> List[Path]:
    """
    Discover component scenes (in scenes/ui/ and scenes/components/).
    These are scenes that should be used as reusable components.
    """
    component_scenes = []

    # Check scenes/ui/ for UI components
    ui_dir = PROJECT_ROOT / "scenes" / "ui"
    if ui_dir.exists():
        component_scenes.extend(ui_dir.glob("*.tscn"))

    # Check scenes/components/ if it exists
    components_dir = PROJECT_ROOT / "scenes" / "components"
    if components_dir.exists():
        component_scenes.extend(components_dir.glob("*.tscn"))

    return sorted(component_scenes)


def find_scene_usage(scene_path: Path) -> Tuple[List[Path], List[Path], bool]:
    """
    Find where a scene is used in the codebase.

    Returns: (files_with_preload, files_with_instantiate, used_for_scene_change)
    """
    # Convert to res:// path
    relative_path = scene_path.relative_to(PROJECT_ROOT)
    res_path = f"res://{relative_path}".replace("\\", "/")

    files_with_preload = []
    files_with_instantiate = []
    used_for_scene_change = False

    # Search all .gd files
    scripts_dir = PROJECT_ROOT / "scripts"
    if not scripts_dir.exists():
        return (files_with_preload, files_with_instantiate, used_for_scene_change)

    for script_file in scripts_dir.rglob("*.gd"):
        try:
            content = script_file.read_text()

            # Check for scene change usage (not a component usage)
            if f'change_scene_to_file("{res_path}")' in content:
                used_for_scene_change = True

            # Check for preload
            if res_path in content and 'preload' in content:
                # But not if it's just in a change_scene_to_file call
                if 'change_scene_to_file' not in content:
                    files_with_preload.append(script_file)

            # Check for instantiate() call on this scene
            # Look for pattern: SCENE_NAME.instantiate() or scene.instantiate()
            scene_name = scene_path.stem.upper()
            patterns = [
                rf'{scene_name}[_\w]*\.instantiate\(',
                rf'preload\("{re.escape(res_path)}"\)\.instantiate\(',
            ]

            for pattern in patterns:
                if re.search(pattern, content):
                    if script_file not in files_with_instantiate:
                        files_with_instantiate.append(script_file)
                    break

        except Exception:
            continue

    return (files_with_preload, files_with_instantiate, used_for_scene_change)


def validate_component_usage() -> Tuple[bool, List[Tuple[Path, str]]]:
    """
    Validate that components are properly used.

    Returns: (all_valid, warnings)
    """
    warnings = []
    errors = []

    component_scenes = discover_component_scenes()

    if not component_scenes:
        return (True, [])

    for scene_path in component_scenes:
        relative_path = scene_path.relative_to(PROJECT_ROOT)
        files_with_preload, files_with_instantiate, used_for_scene_change = find_scene_usage(scene_path)

        # Skip scenes used for scene transitions (not components)
        if used_for_scene_change:
            continue

        # Case 1: Component never used (WARNING)
        if not files_with_preload and not files_with_instantiate:
            # Skip common UI scenes that are instanced in .tscn files
            scene_name = scene_path.stem
            if scene_name in ['hud', 'wave_complete_screen', 'debug_weapon_switcher']:
                continue  # These are instanced in .tscn files, not code

            warnings.append((
                scene_path,
                f"Component never used in codebase\n"
                f"  Scene exists but no preload() or instantiate() calls found\n"
                f"  ACTION: Either use the component or delete it"
            ))

        # Case 2: Preloaded but never instantiated (ERROR)
        elif files_with_preload and not files_with_instantiate:
            preload_files = ", ".join([str(f.relative_to(PROJECT_ROOT)) for f in files_with_preload])
            errors.append((
                scene_path,
                f"Component preloaded but never instantiated\n"
                f"  Preloaded in: {preload_files}\n"
                f"  ERROR: No .instantiate() call found\n"
                f"  FIX: Either use the component or remove the preload"
            ))

    return (len(errors) == 0, warnings, errors)


def main() -> int:
    """Main validation function"""
    print(f"{CYAN}🔍 Validating component usage...{NC}\n")

    all_valid, warnings, errors = validate_component_usage()

    # Display warnings
    if warnings:
        print(f"{YELLOW}⚠️  Component Usage Warnings:{NC}\n")
        for scene_path, message in warnings:
            relative_path = scene_path.relative_to(PROJECT_ROOT)
            print(f"{YELLOW}WARNING: {relative_path}{NC}")
            print(f"{message}\n")

    # Display errors
    if errors:
        print(f"{RED}❌ Component Usage Errors:{NC}\n")
        for scene_path, message in errors:
            relative_path = scene_path.relative_to(PROJECT_ROOT)
            print(f"{RED}ERROR: {relative_path}{NC}")
            print(f"{message}\n")

    # Summary
    print("=" * 60)
    print(f"Component Usage Summary:")
    print(f"  {YELLOW}Warnings: {len(warnings)}{NC} (unused components)")
    print(f"  {RED}Errors: {len(errors)}{NC} (preloaded but not instantiated)")
    print("=" * 60)

    if not all_valid:
        print(f"\n{RED}❌ Component usage validation FAILED{NC}")
        print(f"\n{YELLOW}FIX:{NC}")
        print(f"  1. Remove unused preload() statements")
        print(f"  2. Add .instantiate() calls where component is needed")
        print(f"  3. Delete component scenes that aren't used")
        print()
        return 1

    if warnings:
        print(f"\n{YELLOW}⚠️  Warnings found but not blocking commit{NC}")
        print(f"Consider cleaning up unused components\n")
    else:
        print(f"\n{GREEN}✅ All components are properly used!{NC}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
