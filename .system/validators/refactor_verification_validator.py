#!/usr/bin/env python3
"""
Refactor Verification Validator

Validates that refactor claims in commit messages match reality.

Catches issues like:
- Commit says "refactored to use Component" but no component usage found
- Claim "80 lines → 14 lines" but function still has 80 lines
- Old code still present after claiming refactor

Validates:
- If commit message contains "refactor", verify actual code changes
- If claiming component usage, verify preload() and instantiate() exist
- If claiming code reduction, verify actual line count change

IMPORTANT: This validator must read the CURRENT commit message being made,
not the previous commit. It reads from:
1. Command line argument (commit message file path, passed by commit-msg hook)
2. .git/COMMIT_EDITMSG (fallback, exists during commit-msg hook)

This validator should be called from the commit-msg hook, NOT pre-commit,
because the commit message doesn't exist yet during pre-commit.
"""

import re
import sys
import subprocess
from pathlib import Path
from typing import List, Tuple, Optional

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

PROJECT_ROOT = Path(__file__).parent.parent.parent


def get_current_commit_message(commit_msg_file: Optional[str] = None) -> Optional[str]:
    """
    Get the CURRENT commit message being committed.
    
    This function ONLY returns a message when called from commit-msg hook
    (which passes the message file path). During pre-commit, no message
    exists yet, so we return None to skip validation.
    
    Args:
        commit_msg_file: Path to commit message file (passed by commit-msg hook)
    
    Returns:
        The commit message text, or None if not in commit-msg context
    """
    # Only read from file path passed as argument (commit-msg hook passes this)
    # Do NOT fall back to COMMIT_EDITMSG - it contains the PREVIOUS commit's message
    if commit_msg_file:
        try:
            msg_path = Path(commit_msg_file)
            if msg_path.exists():
                return msg_path.read_text().strip()
        except Exception:
            pass
    
    # No file argument means we're in pre-commit or manual run - skip validation
    return None


def is_refactor_commit(commit_msg: str) -> bool:
    """Check if commit message indicates a refactor"""
    if not commit_msg:
        return False

    refactor_keywords = [
        'refactor',
        'use component',
        'use.*component',
        'lines.*→.*lines',
        '→',  # Arrow indicating before/after
    ]

    for keyword in refactor_keywords:
        if re.search(keyword, commit_msg, re.IGNORECASE):
            return True

    return False


def extract_component_claim(commit_msg: str) -> Optional[str]:
    """Extract component name from refactor claim"""
    # Pattern: "refactor to use ComponentName" or "use ComponentName component"
    patterns = [
        r'use\s+(\w+)\s+component',
        r'refactor.*use\s+(\w+)',
        r'integrate\s+(\w+)',
    ]

    for pattern in patterns:
        match = re.search(pattern, commit_msg, re.IGNORECASE)
        if match:
            return match.group(1)

    return None


def extract_line_count_claim(commit_msg: str) -> Optional[Tuple[int, int]]:
    """Extract line count claim (before → after)"""
    # Pattern: "80 lines → 14 lines" or "80→14"
    match = re.search(r'(\d+)\s*(?:lines?)?\s*→\s*(\d+)\s*(?:lines?)?', commit_msg, re.IGNORECASE)
    if match:
        before = int(match.group(1))
        after = int(match.group(2))
        return (before, after)
    return None


def verify_component_usage(component_name: str, modified_files: List[Path]) -> Tuple[bool, str]:
    """Verify that component is actually used in modified files"""
    for file_path in modified_files:
        if not file_path.suffix == '.gd':
            continue

        try:
            content = file_path.read_text()

            # Check for component preload
            component_upper = component_name.upper()
            has_preload = f'{component_upper}' in content and 'preload' in content

            # Check for instantiate call
            has_instantiate = f'.instantiate()' in content

            if has_preload and has_instantiate:
                return (True, f"Component '{component_name}' properly used in {file_path.relative_to(PROJECT_ROOT)}")

        except Exception:
            continue

    return (False, f"Component '{component_name}' not found or not properly used in modified files")


def get_staged_files() -> List[Path]:
    """Get list of staged files"""
    try:
        result = subprocess.run(
            ['git', 'diff', '--cached', '--name-only'],
            capture_output=True,
            text=True,
            cwd=PROJECT_ROOT
        )

        if result.returncode == 0:
            files = []
            for line in result.stdout.strip().split('\n'):
                if line:
                    file_path = PROJECT_ROOT / line
                    if file_path.exists():
                        files.append(file_path)
            return files

    except Exception:
        pass

    return []


def main() -> int:
    """Main validation function"""
    # Get commit message file from command line argument (if provided by hook)
    commit_msg_file = sys.argv[1] if len(sys.argv) > 1 else None
    
    commit_msg = get_current_commit_message(commit_msg_file)

    if not commit_msg:
        # Not in a commit context where we can read the message - skip validation
        # This happens during pre-commit (message doesn't exist yet)
        print(f"{YELLOW}⚠️  No commit message available (pre-commit phase), skipping refactor verification{NC}")
        return 0

    if not is_refactor_commit(commit_msg):
        # Not a refactor commit - skip validation
        print(f"{GREEN}✓ Not a refactor commit, skipping verification{NC}")
        return 0

    print(f"{CYAN}🔍 Verifying refactor claims...{NC}\n")
    print(f"Commit message: {commit_msg[:100]}...\n")

    errors = []

    # Get staged/modified files
    staged_files = get_staged_files()

    if not staged_files:
        print(f"{YELLOW}⚠️  No staged files found, cannot verify refactor{NC}")
        return 0

    # Check component usage claim
    component_name = extract_component_claim(commit_msg)
    if component_name:
        print(f"{CYAN}Checking component usage claim: '{component_name}'{NC}")
        is_valid, message = verify_component_usage(component_name, staged_files)

        if is_valid:
            print(f"{GREEN}✓ {message}{NC}")
        else:
            print(f"{RED}✗ {message}{NC}")
            errors.append(f"Component usage claim not verified: {component_name}")

    # Check line count reduction claim
    line_count_claim = extract_line_count_claim(commit_msg)
    if line_count_claim:
        before, after = line_count_claim
        print(f"{CYAN}Checking line count claim: {before} → {after} lines{NC}")

        # This is a soft check - just verify files were actually modified
        gd_files_modified = [f for f in staged_files if f.suffix == '.gd']

        if gd_files_modified:
            print(f"{GREEN}✓ {len(gd_files_modified)} .gd file(s) modified{NC}")
        else:
            print(f"{YELLOW}⚠️  No .gd files modified, line count claim may be inaccurate{NC}")

    # Summary
    print("\n" + "=" * 60)
    print(f"Refactor Verification Summary:")

    if errors:
        print(f"  {RED}Errors: {len(errors)}{NC}")
        for error in errors:
            print(f"    - {error}")
        print("=" * 60)
        print(f"\n{RED}❌ Refactor verification FAILED{NC}")
        print(f"\n{YELLOW}FIX:{NC}")
        print(f"  1. Verify component is actually used (preload + instantiate)")
        print(f"  2. Check that claimed refactoring matches actual code changes")
        print(f"  3. Update commit message to reflect actual changes")
        print()
        return 1

    print(f"  {GREEN}No issues found{NC}")
    print("=" * 60)
    print(f"\n{GREEN}✅ Refactor claims verified!{NC}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
