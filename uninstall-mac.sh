#!/bin/bash

# Claude Code Web UI - Uninstaller for Mac
# This script removes Claude Code Web UI from your system

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  Claude Code Web UI Uninstaller     ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Define paths
APP_DIR="/Applications/ClaudeCodeWebUI"
DESKTOP_SHORTCUT="$HOME/Desktop/Claude Code Web UI"

echo -e "${YELLOW}This will remove Claude Code Web UI from your system.${NC}"
echo ""
echo "The following will be removed:"
echo "  • Application directory: $APP_DIR"
echo "  • Desktop shortcut (if exists)"
echo ""
echo -e "${RED}This action cannot be undone.${NC}"
echo ""
read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    
    # Remove application directory (requires sudo)
    if [ -d "$APP_DIR" ]; then
        echo -e "${BLUE}Removing application directory (may require password)...${NC}"
        sudo rm -rf "$APP_DIR"
        echo -e "${GREEN}✓ Removed $APP_DIR${NC}"
    else
        echo -e "${YELLOW}Application directory not found${NC}"
    fi
    
    # Remove desktop shortcut (using AppleScript for aliases)
    echo -e "${BLUE}Removing desktop shortcut...${NC}"
    osascript -e 'tell application "Finder" to delete alias file "Claude Code Web UI" of desktop' 2>/dev/null || true
    echo -e "${GREEN}✓ Removed desktop shortcut${NC}"
    
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}   Uninstall Complete                ${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo "Claude Code Web UI has been removed from your system."
    echo ""
    echo -e "${BLUE}Note:${NC} This uninstaller does not remove:"
    echo "  • Claude CLI (which is needed for other Claude tools)"
    echo "  • Any project files you worked on"
    
else
    echo ""
    echo -e "${BLUE}Uninstall cancelled.${NC}"
fi

echo ""