#!/bin/bash
# Git hook bypass detector
# Purpose: Warn when attempting to use --no-verify or similar bypass flags
#
# Installation (OPTIONAL):
# Add to your ~/.bashrc, ~/.zshrc, or shell profile:
#   source /path/to/scrap-survivor-godot/scripts/check-no-verify.sh
#
# This creates a wrapper around the git command that warns before bypassing hooks

git() {
    # Check if user is attempting to bypass hooks
    if [[ "$*" == *"--no-verify"* ]] || \
       [[ "$*" == *"--no-gpg-sign"* ]] || \
       [[ "$*" == *"--no-post-rewrite"* ]]; then

        echo ""
        echo "⚠️  ============================================"
        echo "⚠️  WARNING: Attempting to bypass git hooks!"
        echo "⚠️  ============================================"
        echo ""
        echo "❌ This is FORBIDDEN per docs/DEVELOPMENT-RULES.md"
        echo ""
        echo "💡 Instead, you should:"
        echo "   1. Read the error message from the hook"
        echo "   2. Fix the actual issue (linting, formatting, tests)"
        echo "   3. Re-attempt the commit WITHOUT --no-verify"
        echo ""
        echo "📚 See: docs/DEVELOPMENT-RULES.md for complete rules"
        echo ""

        # Prompt for confirmation
        read -p "Are you ABSOLUTELY SURE you want to bypass hooks? (type 'yes' to proceed): " confirm

        if [[ "$confirm" != "yes" ]]; then
            echo "❌ Aborted - fix the validation errors instead"
            return 1
        fi

        echo "⚠️  Proceeding with bypass (this will be logged)"
        echo "[$(date)] Bypassed hooks: git $*" >> .git/bypass-log.txt
    fi

    # Execute the actual git command
    command git "$@"
}

echo "✅ Git bypass detector loaded (warns on --no-verify usage)"
