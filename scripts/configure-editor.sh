#!/bin/bash
# Configure Godot to use VS Code or Windsurf as external editor

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Godot External Editor Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect Godot editor settings location
GODOT_SETTINGS_DIR="$HOME/Library/Application Support/Godot"
GODOT_CONFIG="$GODOT_SETTINGS_DIR/editor_settings-4.tres"

if [ ! -d "$GODOT_SETTINGS_DIR" ]; then
    echo -e "${YELLOW}⚠️  Godot settings directory not found${NC}"
    echo "Launch Godot at least once to create settings directory"
    echo "Then run this script again"
    exit 1
fi

echo "Choose your preferred external editor:"
echo ""
echo "1) VS Code (recommended for Copilot)"
echo "2) Windsurf (recommended for Cascade AI)"
echo "3) None (use Godot's built-in editor)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        EDITOR_NAME="VS Code"
        EDITOR_PATH="/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
        EXEC_FLAGS="{project} --goto {file}:{line}:{col}"
        ;;
    2)
        EDITOR_NAME="Windsurf"
        EDITOR_PATH="/Applications/Windsurf.app/Contents/MacOS/Windsurf"
        EXEC_FLAGS="{project} --goto {file}:{line}:{col}"
        ;;
    3)
        echo -e "${GREEN}✅ Will use Godot's built-in editor${NC}"
        echo ""
        echo "To enable external editor later, run this script again"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

# Check if editor exists
if [ ! -f "$EDITOR_PATH" ]; then
    echo -e "${RED}❌ $EDITOR_NAME not found at: $EDITOR_PATH${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}📝 Configuration:${NC}"
echo "  Editor: $EDITOR_NAME"
echo "  Path: $EDITOR_PATH"
echo "  Flags: $EXEC_FLAGS"
echo ""

# Create backup of existing settings
if [ -f "$GODOT_CONFIG" ]; then
    cp "$GODOT_CONFIG" "$GODOT_CONFIG.backup"
    echo -e "${GREEN}✅ Backed up existing settings${NC}"
fi

# Instructions for manual configuration
echo ""
echo -e "${YELLOW}⚠️  Manual Configuration Required${NC}"
echo ""
echo "Godot's editor settings file is binary. Please configure manually:"
echo ""
echo "1. Open Godot Editor"
echo "2. Go to: Editor → Editor Settings"
echo "3. Navigate to: Text Editor → External"
echo "4. Check: ☑ Use External Editor"
echo "5. Set Exec Path to:"
echo "   ${EDITOR_PATH}"
echo "6. Set Exec Flags to:"
echo "   ${EXEC_FLAGS}"
echo "7. Click 'Close'"
echo ""
echo -e "${CYAN}📋 Test it:${NC}"
echo "1. In Godot, double-click any .gd file"
echo "2. Should open in $EDITOR_NAME at the correct line"
echo ""

# Create a quick reference file
cat > "$HOME/Desktop/godot-editor-config.txt" << EOF
Godot External Editor Configuration for $EDITOR_NAME
═══════════════════════════════════════════════════

Editor → Editor Settings → Text Editor → External

☑ Use External Editor

Exec Path:
$EDITOR_PATH

Exec Flags:
$EXEC_FLAGS

═══════════════════════════════════════════════════
Quick test:
1. Open Godot
2. Double-click a .gd file in FileSystem panel
3. Should open in $EDITOR_NAME

Note: Changes take effect immediately (no restart needed)
EOF

echo -e "${GREEN}✅ Created reference file on Desktop: godot-editor-config.txt${NC}"
echo ""
echo "Happy coding! 🚀"
