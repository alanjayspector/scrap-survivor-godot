#!/bin/bash
# Git wrapper to prevent banned flag usage
# Place early in PATH to intercept git commands

# Detect banned flags BEFORE executing
BANNED_FLAGS=(
    "--no-verify"
    "--force"
    "-f"
    "--amend"
    "--skip-ci"
    "--no-gpg-sign"
)

# Only check certain dangerous commands
DANGEROUS_COMMANDS=("commit" "push" "rebase" "reset")

# Get the actual git binary path (not this wrapper)
REAL_GIT=$(command -v git | grep -v "$(dirname "$0")")
if [ -z "$REAL_GIT" ]; then
    REAL_GIT="/usr/bin/git"
fi

# Check if this is a dangerous command
IS_DANGEROUS=false
for cmd in "${DANGEROUS_COMMANDS[@]}"; do
    if [[ " $@ " =~ " $cmd " ]]; then
        IS_DANGEROUS=true
        break
    fi
done

# If not dangerous, just pass through
if [ "$IS_DANGEROUS" = false ]; then
    exec "$REAL_GIT" "$@"
    exit $?
fi

# Check for banned flags
FOUND_BANNED=""
for flag in "${BANNED_FLAGS[@]}"; do
    if [[ " $@ " =~ " $flag " ]]; then
        FOUND_BANNED="$flag"
        break
    fi
done

# If banned flag detected, block and alert
if [ -n "$FOUND_BANNED" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚨 BANNED FLAG DETECTED: $FOUND_BANNED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Command attempted: git $@"
    echo ""
    echo "This flag violates .system/CLAUDE_RULES.md"
    echo ""
    echo "⚠️  CLAUDE: You MUST now:"
    echo "    1. Re-read .system/CLAUDE_RULES.md"
    echo "    2. Announce to user what you were about to do"
    echo "    3. Wait for explicit approval"
    echo ""
    echo "Required reading: .system/CLAUDE_RULES.md (lines 22, 29)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

# No banned flags, execute normally
exec "$REAL_GIT" "$@"
