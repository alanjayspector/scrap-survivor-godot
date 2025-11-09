#!/usr/bin/env python3
"""
Documentation Validator

Checks that required documentation files exist per weekly action items.
This would have caught the missing architecture-decisions.md.
"""

import sys
from pathlib import Path


class DocumentationValidator:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.errors = []
        self.warnings = []

    def validate(self) -> bool:
        """Run all validations."""
        self.check_core_docs()
        self.check_godot_docs()

        return len(self.errors) == 0

    def check_core_docs(self):
        """Check for core documentation files."""
        required_docs = [
            ("README.md", "Project readme"),
            (".gitignore", "Git ignore file"),
        ]

        for filename, description in required_docs:
            filepath = self.project_root / filename
            if not filepath.exists():
                self.errors.append(f"Missing {description}: {filename}")

    def check_godot_docs(self):
        """Check for Godot-specific documentation."""
        godot_docs_dir = self.project_root / "docs" / "godot"

        if not godot_docs_dir.exists():
            self.warnings.append("docs/godot/ directory does not exist")
            return

        # Required docs per Week 1 Day 5
        required_docs = [
            ("setup-guide.md", "Setup guide"),
            ("gdscript-conventions.md", "GDScript conventions"),
            ("architecture-decisions.md", "Architecture decisions"),
        ]

        for filename, description in required_docs:
            filepath = godot_docs_dir / filename
            if not filepath.exists():
                self.errors.append(f"Missing {description}: docs/godot/{filename}")

    def report(self):
        """Print validation report."""
        if self.errors:
            print("\n❌ DOCUMENTATION VALIDATION ERRORS:")
            for error in self.errors:
                print(f"  {error}")

        if self.warnings:
            print("\n⚠️  DOCUMENTATION VALIDATION WARNINGS:")
            for warning in self.warnings:
                print(f"  {warning}")

        if not self.errors and not self.warnings:
            print("✅ Documentation valid")


def main():
    project_root = Path(__file__).parent.parent.parent

    validator = DocumentationValidator(project_root)
    success = validator.validate()
    validator.report()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
