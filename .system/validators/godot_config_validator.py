#!/usr/bin/env python3
"""
Godot Configuration Validator

Validates that project.godot has required configuration matching the codebase.
This would have caught the missing autoloads and input actions.
"""

import sys
import re
import argparse
from pathlib import Path


class GodotConfigValidator:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.project_godot = project_root / "project.godot"
        self.errors = []
        self.warnings = []

    def validate(self) -> bool:
        """Run all validations. Returns True if all pass."""
        if not self.project_godot.exists():
            self.errors.append("project.godot not found")
            return False

        content = self.project_godot.read_text()

        self.check_autoloads(content)
        self.check_input_actions(content)
        self.check_required_sections(content)

        return len(self.errors) == 0

    def check_autoloads(self, content: str):
        """Verify all autoload services are registered."""
        # Find all files that should be autoloads
        autoload_dir = self.project_root / "scripts" / "autoload"
        service_dir = self.project_root / "scripts" / "services"

        expected_autoloads = {}

        # Check autoload directory
        if autoload_dir.exists():
            for gd_file in autoload_dir.glob("*.gd"):
                name = gd_file.stem
                # Convert snake_case to PascalCase for autoload name
                autoload_name = ''.join(word.capitalize() for word in name.split('_'))
                expected_autoloads[autoload_name] = gd_file.relative_to(self.project_root)

        # Check service directory for services that need to be autoloads
        # (ErrorService pattern - extends Node and is stateful)
        if service_dir.exists():
            for gd_file in service_dir.glob("*.gd"):
                gd_content = gd_file.read_text()
                # If it extends Node and is not a static class, it should be an autoload
                if 'extends Node' in gd_content and 'class_name' not in gd_content:
                    name = gd_file.stem
                    autoload_name = ''.join(word.capitalize() for word in name.split('_'))
                    expected_autoloads[autoload_name] = gd_file.relative_to(self.project_root)

        # Parse existing autoloads from project.godot
        autoload_section = re.search(r'\[autoload\](.*?)(?=\n\[|\Z)', content, re.DOTALL)

        if not autoload_section and expected_autoloads:
            self.errors.append(
                f"Missing [autoload] section but found {len(expected_autoloads)} services that need registration"
            )
            for name, path in expected_autoloads.items():
                self.errors.append(f"  - {name} should be: {name}=\"*res://{path}\"")
            return

        if autoload_section:
            autoload_content = autoload_section.group(1)
            registered = {}
            for line in autoload_content.split('\n'):
                line = line.strip()
                if '=' in line and not line.startswith('#'):
                    name, path = line.split('=', 1)
                    registered[name.strip()] = path.strip().strip('"')

            # Check for missing autoloads
            for name, expected_path in expected_autoloads.items():
                if name not in registered:
                    # Extract filename for hint
                    filename = expected_path.name
                    self.errors.append(
                        f"Autoload '{name}' not registered. Add: {name}=\"*res://{expected_path}\"\n"
                        f"  💡 Naming: snake_case files → PascalCase autoloads ({filename} → {name})"
                    )
                else:
                    # Verify path is correct
                    expected_res_path = f"*res://{expected_path}"
                    if registered[name] != expected_res_path:
                        self.warnings.append(
                            f"Autoload '{name}' path mismatch: {registered[name]} vs {expected_res_path}"
                        )

    def check_input_actions(self, content: str):
        """Verify input actions are configured if referenced in code."""
        # Scan player.gd and other entity files for Input.get_vector() calls
        required_actions = set()

        entities_dir = self.project_root / "scripts" / "entities"
        if entities_dir.exists():
            for gd_file in entities_dir.glob("*.gd"):
                gd_content = gd_file.read_text()

                # Find Input.get_vector() calls
                vector_calls = re.findall(
                    r'Input\.get_vector\(["\']([^"\']+)["\'],\s*["\']([^"\']+)["\'],\s*["\']([^"\']+)["\'],\s*["\']([^"\']+)["\']',
                    gd_content
                )
                for left, right, up, down in vector_calls:
                    required_actions.update([left, right, up, down])

                # Find Input.is_action_pressed() calls
                action_calls = re.findall(r'Input\.is_action_(?:pressed|just_pressed)\(["\']([^"\']+)["\']', gd_content)
                required_actions.update(action_calls)

        if not required_actions:
            return  # No input actions needed yet

        # Check if [input] section exists
        input_section = re.search(r'\[input\](.*?)(?=\n\[|\Z)', content, re.DOTALL)

        if not input_section:
            self.errors.append(
                f"Missing [input] section but code references {len(required_actions)} actions: {sorted(required_actions)}"
            )
            return

        # Check each required action is defined
        input_content = input_section.group(1)
        for action in required_actions:
            if f'{action}=' not in input_content and f'{action} =' not in input_content:
                self.errors.append(f"Input action '{action}' not configured but used in code")

    def check_required_sections(self, content: str):
        """Check for essential project.godot sections."""
        required_sections = ['application', 'display', 'rendering']

        for section in required_sections:
            if f'[{section}]' not in content:
                self.warnings.append(f"Missing [{section}] section (might be optional)")

    def report(self):
        """Print validation report."""
        if self.errors:
            print("\n❌ GODOT CONFIGURATION ERRORS:")
            for error in self.errors:
                print(f"  {error}")

        if self.warnings:
            print("\n⚠️  GODOT CONFIGURATION WARNINGS:")
            for warning in self.warnings:
                print(f"  {warning}")

        if not self.errors and not self.warnings:
            print("✅ Godot configuration valid")


def explain():
    """Print explanation of validation rules"""
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║              Godot Configuration Validator - Rules Explained                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

📋 WHAT THIS VALIDATOR CHECKS:

1️⃣  Autoload Registration
   ────────────────────────────────────────────────────────────────────────────
   • All files in scripts/autoload/*.gd must be registered in [autoload] section
   • All services extending Node in scripts/services/*.gd need autoload registration

   Naming Convention:
     snake_case filenames → PascalCase autoload names
     Examples:
       hud_service.gd     → HudService
       game_state.gd      → GameState
       error_service.gd   → ErrorService

   Required Format:
     [autoload]
     ServiceName="*res://scripts/path/to/service.gd"

   Why This Matters:
     Missing autoloads cause "identifier not found" errors at runtime

2️⃣  Input Action Configuration
   ────────────────────────────────────────────────────────────────────────────
   • All Input.get_vector() calls must have corresponding [input] actions
   • All Input.is_action_pressed() calls need configured actions

   Example:
     Code:  Input.get_vector("move_left", "move_right", "move_up", "move_down")
     Needs: [input] section with move_left, move_right, move_up, move_down defined

   Why This Matters:
     Missing input actions crash the game when input is read

3️⃣  Required Sections
   ────────────────────────────────────────────────────────────────────────────
   • [application] - Project name, main scene, features
   • [display] - Window size, viewport settings
   • [rendering] - Rendering method, compression settings

   Why This Matters:
     Missing sections may cause undefined behavior

💡 COMMON ISSUES & FIXES:

   Issue: "Autoload 'HUDService' not registered"
   Fix:   Change to 'HudService' (PascalCase, not ACRONYM_CASE)

   Issue: "Input action 'move_left' not configured"
   Fix:   Add to [input] section in project.godot

   Issue: Path mismatch
   Fix:   Use exact path: "*res://scripts/autoload/service.gd"

🔧 USAGE:

   Normal run:     python3 godot_config_validator.py
   Show this help: python3 godot_config_validator.py --explain

📚 SEE ALSO:

   • docs/godot-service-architecture.md - Service patterns
   • docs/godot-community-research.md - Best practices
   • project.godot - Your project configuration

════════════════════════════════════════════════════════════════════════════════
""")


def main():
    parser = argparse.ArgumentParser(description='Validate Godot project configuration')
    parser.add_argument('--explain', action='store_true', help='Show detailed explanation of validation rules')
    args = parser.parse_args()

    if args.explain:
        explain()
        return 0

    project_root = Path(__file__).parent.parent.parent

    validator = GodotConfigValidator(project_root)
    success = validator.validate()
    validator.report()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
