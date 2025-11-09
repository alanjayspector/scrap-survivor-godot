#!/usr/bin/env python3
"""
Resource Validator

Validates that .tres resources match JSON source data.
This would have caught missing resources or mismatches.
"""

import json
import sys
from pathlib import Path


class ResourceValidator:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.errors = []
        self.warnings = []

    def validate(self) -> bool:
        """Run all validations."""
        self.check_weapons()
        self.check_enemies()
        self.check_items()

        return len(self.errors) == 0

    def check_weapons(self):
        """Verify weapon .tres files match weapons.json."""
        json_file = self.project_root / "resources" / "data" / "weapons.json"
        tres_dir = self.project_root / "resources" / "weapons"

        if not json_file.exists():
            return  # Not created yet

        with open(json_file) as f:
            weapons = json.load(f)

        expected_count = len(weapons)
        expected_ids = {w['id'] for w in weapons}

        if not tres_dir.exists():
            if expected_count > 0:
                self.errors.append(
                    f"resources/weapons/ directory missing but weapons.json has {expected_count} weapons"
                )
            return

        tres_files = list(tres_dir.glob("*.tres"))
        actual_count = len(tres_files)

        if actual_count != expected_count:
            self.errors.append(
                f"Weapon count mismatch: {actual_count} .tres files vs {expected_count} in JSON"
            )

        # Check each expected weapon has a .tres file
        for weapon_id in expected_ids:
            tres_file = tres_dir / f"{weapon_id}.tres"
            if not tres_file.exists():
                self.errors.append(f"Missing weapon resource: {weapon_id}.tres")

    def check_enemies(self):
        """Verify enemy .tres files match enemies.json."""
        json_file = self.project_root / "resources" / "data" / "enemies.json"
        tres_dir = self.project_root / "resources" / "enemies"

        if not json_file.exists():
            return

        with open(json_file) as f:
            enemies = json.load(f)

        expected_count = len(enemies)
        expected_ids = {e['id'] for e in enemies}

        if not tres_dir.exists():
            if expected_count > 0:
                self.errors.append(
                    f"resources/enemies/ directory missing but enemies.json has {expected_count} enemies"
                )
            return

        tres_files = list(tres_dir.glob("*.tres"))
        actual_count = len(tres_files)

        if actual_count != expected_count:
            self.errors.append(
                f"Enemy count mismatch: {actual_count} .tres files vs {expected_count} in JSON"
            )

        for enemy_id in expected_ids:
            tres_file = tres_dir / f"{enemy_id}.tres"
            if not tres_file.exists():
                self.errors.append(f"Missing enemy resource: {enemy_id}.tres")

    def check_items(self):
        """Verify item .tres files match items.json."""
        json_file = self.project_root / "resources" / "data" / "items.json"
        tres_dir = self.project_root / "resources" / "items"

        if not json_file.exists():
            return

        with open(json_file) as f:
            items = json.load(f)

        expected_count = len(items)
        expected_ids = {i['id'] for i in items}

        if not tres_dir.exists():
            if expected_count > 0:
                self.errors.append(
                    f"resources/items/ directory missing but items.json has {expected_count} items"
                )
            return

        tres_files = list(tres_dir.glob("*.tres"))
        actual_count = len(tres_files)

        if actual_count != expected_count:
            self.errors.append(
                f"Item count mismatch: {actual_count} .tres files vs {expected_count} in JSON"
            )

        for item_id in expected_ids:
            tres_file = tres_dir / f"{item_id}.tres"
            if not tres_file.exists():
                self.errors.append(f"Missing item resource: {item_id}.tres")

    def report(self):
        """Print validation report."""
        if self.errors:
            print("\n❌ RESOURCE VALIDATION ERRORS:")
            for error in self.errors:
                print(f"  {error}")

        if self.warnings:
            print("\n⚠️  RESOURCE VALIDATION WARNINGS:")
            for warning in self.warnings:
                print(f"  {warning}")

        if not self.errors and not self.warnings:
            print("✅ Resources valid")


def main():
    project_root = Path(__file__).parent.parent.parent

    validator = ResourceValidator(project_root)
    success = validator.validate()
    validator.report()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
