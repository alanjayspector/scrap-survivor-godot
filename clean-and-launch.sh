#!/bin/bash
# Clean Godot caches and launch editor
# Usage: ./clean-and-launch.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🧹 Cleaning Godot cache..."
if [ -d ".godot" ]; then
    rm -rf .godot/
    echo "✓ Deleted .godot/"
else
    echo "  (no .godot/ found, skipping)"
fi

echo ""
echo "🚀 Launching Godot..."

# Try common Godot 4 locations on macOS
if [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    open -a "Godot" "$PROJECT_DIR/project.godot"
elif [ -f "/Applications/Godot_v4.3-stable.app/Contents/MacOS/Godot" ]; then
    open -a "Godot_v4.3-stable" "$PROJECT_DIR/project.godot"
elif [ -f "/Applications/Godot_v4.2.2-stable.app/Contents/MacOS/Godot" ]; then
    open -a "Godot_v4.2.2-stable" "$PROJECT_DIR/project.godot"
else
    # Fallback: try to open any Godot app
    if open -a "Godot" "$PROJECT_DIR/project.godot" 2>/dev/null; then
        echo "✓ Launched Godot"
    else
        echo "❌ Could not find Godot installation"
        echo "   Please launch Godot manually from /Applications/"
        exit 1
    fi
fi

echo ""
echo "✓ Done! Wait for Godot to finish reimporting before exporting."
