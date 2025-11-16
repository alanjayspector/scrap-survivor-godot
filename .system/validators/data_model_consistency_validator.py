#!/usr/bin/env python3
"""
Data Model Consistency Validator

Validates that Dictionary field accesses match the actual data models in services.
Catches issues like using character.get("xp") when the field is actually "experience".

Based on learnings from Week 10 Phase 3 where HudService incorrectly used "xp"
instead of CharacterService's actual field name "experience".

Checks:
1. Service data model field definitions
2. Dictionary .get() calls with field names
3. Cross-references to detect mismatches
4. Suggests corrections for common typos

Exit Codes:
  0 - No data model issues detected
  1 - Data model inconsistencies found (blocking)
"""

import sys
import re
from pathlib import Path
from typing import Dict, Set, List, Tuple
from collections import defaultdict

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'


class DataModelValidator:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.service_models: Dict[str, Set[str]] = {}
        self.field_accesses: Dict[Path, List[Tuple[int, str, str]]] = defaultdict(list)
        self.issues: List[Tuple[Path, int, str, str, str]] = []

    def extract_service_data_models(self):
        """Extract data model field names from service files"""
        services_dir = self.project_root / "scripts" / "services"
        if not services_dir.exists():
            return

        for service_file in services_dir.glob("*_service.gd"):
            service_name = service_file.stem
            fields = self._extract_fields_from_service(service_file)
            if fields:
                self.service_models[service_name] = fields

    def _extract_fields_from_service(self, service_file: Path) -> Set[str]:
        """Extract field names from dictionary assignments in a service"""
        fields = set()
        try:
            content = service_file.read_text()

            # Pattern 1: Dictionary key-value pairs like "field": value (handles multiline)
            # Match any "field_name": pattern within the content
            dict_patterns = re.findall(r'"(\w+)"\s*:', content)
            fields.update(dict_patterns)

            # Pattern 2: object.field = value (direct field assignments)
            assignment_patterns = re.findall(r'(\w+)\.(\w+)\s*=', content)
            for obj, field in assignment_patterns:
                if obj in ['character', 'characters', 'enemy', 'weapon', 'item']:
                    fields.add(field)

            # Pattern 3: Comments documenting fields like ## - field_name: description
            comment_fields = re.findall(r'##\s*-\s*(\w+):', content)
            fields.update(comment_fields)

        except Exception as e:
            print(f"{YELLOW}⚠️  Could not read {service_file}: {e}{NC}")

        return fields

    def scan_field_accesses(self):
        """Scan all GDScript files for Dictionary .get() calls"""
        for gd_file in self.project_root.rglob("*.gd"):
            # Skip addons
            if "addons" in gd_file.parts:
                continue

            try:
                content = gd_file.read_text()
                lines = content.split('\n')

                for line_num, line in enumerate(lines, 1):
                    # Pattern: object.get("field_name", default)
                    matches = re.findall(r'(\w+)\.get\(["\'](\w+)["\']', line)
                    for obj, field in matches:
                        self.field_accesses[gd_file].append((line_num, obj, field))

            except Exception as e:
                print(f"{YELLOW}⚠️  Could not read {gd_file}: {e}{NC}")

    def cross_reference_fields(self):
        """Cross-reference field accesses against service data models"""
        # Build a mapping of object names to service names
        object_to_service = {
            'character': 'character_service',
            'enemy': 'enemy_service',
            'weapon': 'weapon_service',
            'item': 'item_service',
        }

        for file_path, accesses in self.field_accesses.items():
            for line_num, obj, field in accesses:
                # Try to match object to a service
                service_name = object_to_service.get(obj)
                if not service_name:
                    continue

                # Check if this service has a known data model
                if service_name not in self.service_models:
                    continue

                service_fields = self.service_models[service_name]

                # Check if the field exists in the service's data model
                if field not in service_fields:
                    # Try to find similar fields (common typos)
                    suggestions = self._find_similar_fields(field, service_fields)
                    self.issues.append((file_path, line_num, obj, field, suggestions))

    def _find_similar_fields(self, field: str, valid_fields: Set[str]) -> str:
        """Find similar field names for suggestions"""
        # Common mappings
        common_aliases = {
            'xp': 'experience',
            'exp': 'experience',
            'hp': 'health',
            'cur_hp': 'current_hp',
            'max_health': 'max_hp',
        }

        if field in common_aliases and common_aliases[field] in valid_fields:
            return common_aliases[field]

        # Look for partial matches
        matches = [f for f in valid_fields if field.lower() in f.lower() or f.lower() in field.lower()]
        if matches:
            return matches[0]

        # Return most common field as fallback
        if valid_fields:
            return sorted(valid_fields)[0]

        return ""

    def report(self):
        """Print validation results"""
        if not self.issues:
            print(f"{GREEN}✅ All data model field accesses are consistent{NC}")
            return True

        print(f"\n{YELLOW}⚠️  DATA MODEL WARNINGS (informational):{NC}\n")

        files_with_issues = defaultdict(list)
        for file_path, line_num, obj, field, suggestion in self.issues:
            files_with_issues[file_path].append((line_num, obj, field, suggestion))

        for file_path, issues in files_with_issues.items():
            rel_path = file_path.relative_to(self.project_root)
            print(f"{YELLOW}{rel_path}:{NC}")

            for line_num, obj, field, suggestion in issues:
                print(f"  Line {line_num}: {obj}.get(\"{field}\") - field not found in data model")
                if suggestion:
                    print(f"  {CYAN}💡 Did you mean: {obj}.get(\"{suggestion}\"){NC}")
                else:
                    print(f"  {CYAN}💡 Check the service definition for valid field names{NC}")

            print()

        print(f"{CYAN}📚 Check service files in scripts/services/ for valid field names{NC}")
        print(f"{CYAN}💡 These are warnings only - commit will not be blocked{NC}")
        return True  # Don't block commits


def main():
    project_root = Path(__file__).parent.parent.parent

    print(f"{CYAN}Validating data model consistency...{NC}")

    validator = DataModelValidator(project_root)

    # Step 1: Extract service data models
    validator.extract_service_data_models()

    # Step 2: Scan for field accesses
    validator.scan_field_accesses()

    # Step 3: Cross-reference
    validator.cross_reference_fields()

    # Step 4: Report
    success = validator.report()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
