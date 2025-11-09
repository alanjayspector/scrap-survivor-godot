#!/usr/bin/env python3
"""
User Story Validator

Ensures integration tests properly reference user stories for traceability.
Validates that all user stories have corresponding tests and reports coverage gaps.

Usage:
  - Add user stories to docs/user-stories.md
  - Reference stories in integration tests with: ## USER_STORY: <story_id>
  - Validator tracks coverage and reports untested stories

Runs during pre-commit as a non-blocking reminder.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


def discover_integration_tests() -> List[Path]:
    """Auto-discover integration test files"""
    test_files = []

    # Find all *integration*_test.gd files
    tests_dir = PROJECT_ROOT / "scripts" / "tests"
    if tests_dir.exists():
        test_files.extend(tests_dir.glob("*integration*_test.gd"))

    return sorted(test_files)


def parse_user_stories_catalog() -> Dict[str, str]:
    """
    Parse user stories from docs/user-stories.md
    Returns: Dict[story_id, story_description]

    Expected format:
    ## US-001: User Story Title
    Description here...
    """
    catalog_path = PROJECT_ROOT / "docs" / "user-stories.md"
    stories = {}

    if not catalog_path.exists():
        return stories

    content = catalog_path.read_text()
    lines = content.split('\n')

    for line in lines:
        # Match: ## US-XXX: Title
        match = re.match(r'^##\s+(US-\d+):\s+(.+)$', line)
        if match:
            story_id = match.group(1)
            story_title = match.group(2)
            stories[story_id] = story_title

    return stories


def extract_user_story_references(test_file: Path) -> List[Tuple[int, str]]:
    """
    Extract user story references from test file
    Returns: List of (line_number, story_id)

    Expected format:
    ## USER_STORY: US-001
    or
    ## USER_STORY: US-001, US-002, US-003
    """
    references = []

    if not test_file.exists():
        return references

    content = test_file.read_text()
    lines = content.split('\n')

    for i, line in enumerate(lines, start=1):
        # Match: ## USER_STORY: US-XXX or ## USER_STORY: US-XXX, US-YYY
        match = re.match(r'^##\s+USER_STORY:\s+(.+)$', line.strip())
        if match:
            story_ids_str = match.group(1)
            # Split by comma and strip whitespace
            story_ids = [s.strip() for s in story_ids_str.split(',')]
            for story_id in story_ids:
                # Validate format: US-XXX
                if re.match(r'^US-\d+$', story_id):
                    references.append((i, story_id))

    return references


def validate_user_story_coverage() -> Tuple[List[str], List[str], List[str]]:
    """
    Validate user story test coverage
    Returns: (errors, warnings, info_messages)
    """
    errors = []
    warnings = []
    info = []

    # Parse user story catalog
    catalog = parse_user_stories_catalog()

    # Track which stories have tests
    tested_stories: Set[str] = set()
    test_coverage: Dict[str, List[str]] = {}  # story_id -> list of test files

    # Find integration tests
    integration_tests = discover_integration_tests()

    if not integration_tests:
        info.append("No integration tests found (*integration*_test.gd)")
        return errors, warnings, info

    # Extract story references from each test
    for test_file in integration_tests:
        references = extract_user_story_references(test_file)

        if not references:
            warnings.append(
                f"{test_file.name}: No USER_STORY references found\n"
                f"  💡 Add '## USER_STORY: US-XXX' comments to link tests to stories"
            )

        for line_num, story_id in references:
            tested_stories.add(story_id)

            if story_id not in test_coverage:
                test_coverage[story_id] = []
            test_coverage[story_id].append(test_file.name)

            # Verify story exists in catalog
            if catalog and story_id not in catalog:
                warnings.append(
                    f"{test_file.name}:{line_num}: "
                    f"Story '{story_id}' referenced but not found in docs/user-stories.md"
                )

    # Report catalog coverage
    if catalog:
        untested_stories = set(catalog.keys()) - tested_stories

        if untested_stories:
            warnings.append(
                f"\n{YELLOW}📋 Untested user stories ({len(untested_stories)}/{len(catalog)}):{NC}"
            )
            for story_id in sorted(untested_stories):
                warnings.append(f"  • {story_id}: {catalog[story_id]}")

        # Report tested stories
        if tested_stories:
            info.append(f"\n{GREEN}✓ Tested user stories ({len(tested_stories)}/{len(catalog)}):{NC}")
            for story_id in sorted(tested_stories):
                test_files = test_coverage[story_id]
                info.append(f"  • {story_id}: tested by {', '.join(test_files)}")

    return errors, warnings, info


def main():
    """Main validation logic"""

    print("Validating user story test coverage...")
    print()

    errors, warnings, info = validate_user_story_coverage()

    # Report results
    if errors:
        print(f"{RED}❌ User story validation failed:{NC}\n")
        for error in errors:
            print(f"{RED}{error}{NC}\n")
        return 1

    if warnings:
        print(f"{YELLOW}⚠️  User story coverage warnings:{NC}\n")
        for warning in warnings:
            print(f"{YELLOW}{warning}{NC}")
        print()

    if info:
        for msg in info:
            print(msg)
        print()

    # Check if user-stories.md exists
    catalog_path = PROJECT_ROOT / "docs" / "user-stories.md"
    if not catalog_path.exists():
        print(f"{BLUE}💡 Tip: Create docs/user-stories.md to track user stories{NC}")
        print(f"{BLUE}   Format:{NC}")
        print(f"{BLUE}     ## US-001: Story Title{NC}")
        print(f"{BLUE}     Story description...{NC}")
        print()

    print(f"{GREEN}✅ User story validation complete{NC}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
