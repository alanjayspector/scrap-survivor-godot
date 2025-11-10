#!/usr/bin/env python3
"""
Service Architecture Validator

Validates GDScript services against architecture patterns from docs/godot-service-architecture.md.

Checks for:
1. Service naming convention (*_service.gd, extends Node)
2. No direct autoload references (use ServiceRegistry)
3. Service size limits (500-700 warning, 700+ error)
4. Signal naming (past tense, *_started/*_finished pattern)
5. State management methods (validate_state(), reset_game_state())

Exit Codes:
  0 - No architecture issues detected
  1 - Critical architecture issues found (blocking)
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple, Dict
from collections import defaultdict

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


class ArchitectureIssue:
    """Represents a detected architecture issue."""
    def __init__(self, line_num: int, issue_type: str, details: str, severity: str = "warning"):
        self.line_num = line_num
        self.issue_type = issue_type
        self.details = details
        self.severity = severity  # "error" or "warning"


def check_service_naming_convention(file_path: Path, content: str) -> List[ArchitectureIssue]:
    """
    Check if service files follow naming convention: *_service.gd and extend Node.
    """
    issues = []

    # Only check files in services/ directory
    if "services" not in file_path.parts or not file_path.name.endswith(".gd"):
        return issues

    # Skip test files
    if "_test.gd" in file_path.name or "test_" in file_path.name:
        return issues

    # Check naming convention: *_service.gd
    if not file_path.name.endswith("_service.gd"):
        # Special exceptions
        if file_path.name not in ["service_registry.gd", "event_bus.gd", "base_service.gd"]:
            issues.append(ArchitectureIssue(
                line_num=1,
                issue_type="service_naming",
                details=f"Service file should be named *_service.gd (got {file_path.name})",
                severity="warning"
            ))

    # Check extends Node
    if not re.search(r'^\s*extends\s+Node\s*$', content, re.MULTILINE):
        issues.append(ArchitectureIssue(
            line_num=1,
            issue_type="service_base_class",
            details="Service should extend Node",
            severity="error"
        ))

    return issues


def check_no_direct_autoload_references(file_path: Path, content: str, lines: List[str]) -> List[ArchitectureIssue]:
    """
    Detect direct autoload references (should use ServiceRegistry.get_service()).

    Exceptions:
    - ServiceRegistry itself
    - EventBus (allowed for cross-cutting concerns)
    - Within service's own file
    """
    issues = []

    # Skip non-GDScript files
    if not file_path.name.endswith(".gd"):
        return issues

    # Allowed autloads (global event bus, registry)
    ALLOWED_AUTOLOADS = {"ServiceRegistry", "EventBus"}

    # Service names to check for (these should use registry)
    SERVICE_PATTERNS = [
        r'\bBankingService\.',
        r'\bStatService\.',
        r'\bRecyclerService\.',
        r'\bShopRerollService\.',
        r'\bSaveManager\.',
        r'\bSaveSystem\.',
        r'\bErrorService\.',
    ]

    # Skip if this IS one of the service files (can reference self)
    service_name_from_file = file_path.stem.replace("_", " ").title().replace(" ", "")

    for line_num, line in enumerate(lines, start=1):
        # Skip comments
        if line.strip().startswith('#'):
            continue

        for pattern in SERVICE_PATTERNS:
            match = re.search(pattern, line)
            if match:
                service_ref = match.group(0).replace('.', '')

                # Skip if this is the service's own file
                if service_ref.lower() in file_path.name.lower():
                    continue

                # Skip if it's in a comment
                if '#' in line and line.index('#') < match.start():
                    continue

                issues.append(ArchitectureIssue(
                    line_num=line_num,
                    issue_type="direct_autoload_reference",
                    details=f"Direct autoload reference: {service_ref}",
                    severity="warning"
                ))

    return issues


def check_service_size_limit(file_path: Path, lines: List[str]) -> List[ArchitectureIssue]:
    """
    Check service file size limits.

    WARNING: 500-700 lines
    ERROR: 700+ lines
    """
    issues = []

    # Only check service files
    if not file_path.name.endswith("_service.gd"):
        return issues

    # Skip test files
    if "_test.gd" in file_path.name or "test_" in file_path.name:
        return issues

    line_count = len(lines)

    if line_count > 700:
        issues.append(ArchitectureIssue(
            line_num=1,
            issue_type="service_size",
            details=f"Service is {line_count} lines (max 700) - consider splitting",
            severity="error"
        ))
    elif line_count > 500:
        issues.append(ArchitectureIssue(
            line_num=1,
            issue_type="service_size",
            details=f"Service is {line_count} lines (recommend < 500)",
            severity="warning"
        ))

    return issues


def check_signal_naming_convention(content: str, lines: List[str]) -> List[ArchitectureIssue]:
    """
    Validate signal naming follows past-tense convention.

    Patterns:
    - Process signals: *_started, *_finished
    - Event signals: past tense (e.g., balance_changed, transaction_processed)
    """
    issues = []

    # Find all signal declarations
    signal_pattern = r'^\s*signal\s+(\w+)'

    for line_num, line in enumerate(lines, start=1):
        match = re.match(signal_pattern, line)
        if not match:
            continue

        signal_name = match.group(1)

        # Check for present tense verbs (bad practice)
        PRESENT_TENSE_PREFIXES = ["add", "update", "set", "remove", "load", "save", "initialize", "create", "delete"]

        for prefix in PRESENT_TENSE_PREFIXES:
            if signal_name.startswith(prefix + "_") and not signal_name.endswith("ed"):
                issues.append(ArchitectureIssue(
                    line_num=line_num,
                    issue_type="signal_naming",
                    details=f"Signal '{signal_name}' uses present tense (should be past: {signal_name}d)",
                    severity="warning"
                ))
                break

    return issues


def check_state_management_methods(file_path: Path, content: str) -> List[ArchitectureIssue]:
    """
    Services with @export state should have validate_state() and reset_game_state().
    """
    issues = []

    # Only check service files
    if not file_path.name.endswith("_service.gd"):
        return issues

    # Skip test files
    if "_test.gd" in file_path.name or "test_" in file_path.name:
        return issues

    # Check if service has @export vars (persistent state)
    has_export = "@export" in content

    if not has_export:
        return issues  # No persistent state, validation not required

    # Check for validation method
    has_validate = bool(re.search(r'func\s+(validate_state|_validate_state)\s*\(', content))

    # Check for reset method
    has_reset = bool(re.search(r'func\s+(reset_game_state|_reset_game_state|reset)\s*\(', content))

    if not has_validate:
        issues.append(ArchitectureIssue(
            line_num=1,
            issue_type="missing_validate_method",
            details="Service with @export state should have validate_state() method",
            severity="warning"
        ))

    if not has_reset:
        issues.append(ArchitectureIssue(
            line_num=1,
            issue_type="missing_reset_method",
            details="Service with @export state should have reset_game_state() or reset() method",
            severity="warning"
        ))

    return issues


def validate_file(file_path: Path) -> List[ArchitectureIssue]:
    """Run all architecture checks on a file."""
    try:
        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        all_issues = []

        # Run all checks
        all_issues.extend(check_service_naming_convention(file_path, content))
        all_issues.extend(check_no_direct_autoload_references(file_path, content, lines))
        all_issues.extend(check_service_size_limit(file_path, lines))
        all_issues.extend(check_signal_naming_convention(content, lines))
        all_issues.extend(check_state_management_methods(file_path, content))

        return all_issues

    except Exception as e:
        print(f"{YELLOW}⚠️  Could not read {file_path}: {e}{NC}")
        return []


def main():
    """Check all GDScript service files for architecture issues."""

    print(f"{CYAN}Checking for service architecture issues...{NC}")

    file_issues: Dict[Path, List[ArchitectureIssue]] = defaultdict(list)
    checked_files = 0
    error_count = 0
    warning_count = 0

    # Check all .gd files in services/ directory
    services_dir = PROJECT_ROOT / "services"

    if not services_dir.exists():
        print(f"{GREEN}✅ No services directory found (skipping){NC}")
        return 0

    for file in services_dir.rglob("*.gd"):
        # Skip test files
        if "_test.gd" in file.name or "test_" in file.name:
            continue

        checked_files += 1
        issues = validate_file(file)

        if issues:
            file_issues[file] = issues
            for issue in issues:
                if issue.severity == "error":
                    error_count += 1
                else:
                    warning_count += 1

    # Report results
    if not file_issues:
        print(f"{GREEN}✅ No service architecture issues detected ({checked_files} files checked){NC}")
        return 0

    # Show warnings
    if warning_count > 0:
        print(f"\n{YELLOW}⚠️  Found {warning_count} service architecture warning(s) in {len(file_issues)} file(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            warning_issues = [i for i in issues if i.severity == "warning"]

            if warning_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{YELLOW}{rel_path}:{NC}")

                for issue in warning_issues:
                    if issue.line_num > 1:
                        print(f"  Line {issue.line_num}: {issue.details}")
                    else:
                        print(f"  {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "direct_autoload_reference":
                        print(f"  {CYAN}💡 Fix: Use ServiceRegistry.get_service(\"ServiceName\"){NC}")
                    elif issue.issue_type == "service_naming":
                        print(f"  {CYAN}💡 Fix: Rename to *_service.gd{NC}")
                    elif issue.issue_type == "service_size":
                        print(f"  {CYAN}💡 Fix: Split into multiple services (Single Responsibility){NC}")
                    elif issue.issue_type == "signal_naming":
                        print(f"  {CYAN}💡 Fix: Use past tense (e.g., balance_changed, not balance_change){NC}")
                    elif issue.issue_type == "missing_validate_method":
                        print(f"  {CYAN}💡 Fix: Add func validate_state() -> Array[String]{NC}")
                    elif issue.issue_type == "missing_reset_method":
                        print(f"  {CYAN}💡 Fix: Add func reset_game_state() -> void{NC}")

                print()

    # Show errors (blocking)
    if error_count > 0:
        print(f"\n{RED}❌ Found {error_count} critical service architecture issue(s):{NC}\n")

        for file_path in sorted(file_issues.keys()):
            issues = file_issues[file_path]
            error_issues = [i for i in issues if i.severity == "error"]

            if error_issues:
                rel_path = file_path.relative_to(PROJECT_ROOT)
                print(f"{RED}{rel_path}:{NC}")

                for issue in error_issues:
                    if issue.line_num > 1:
                        print(f"  Line {issue.line_num}: {issue.details}")
                    else:
                        print(f"  {issue.details}")

                    # Provide fix suggestions
                    if issue.issue_type == "service_base_class":
                        print(f"  {CYAN}💡 Fix: Change to 'extends Node'{NC}")
                    elif issue.issue_type == "service_size":
                        print(f"  {CYAN}💡 Fix: Refactor into smaller services (god service anti-pattern){NC}")

                print()

        print(f"{RED}🚫 BLOCKED: Fix critical architecture issues before committing{NC}")
        print(f"{CYAN}📚 See docs/godot-service-architecture.md for patterns and examples{NC}")
        return 1

    # Warnings only, don't block
    if warning_count > 0:
        print(f"{YELLOW}⚠️  Consider fixing warnings for better architecture{NC}")
        print(f"{CYAN}📚 See docs/godot-service-architecture.md for patterns and examples{NC}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
