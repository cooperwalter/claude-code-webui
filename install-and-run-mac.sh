#!/bin/bash

# Claude Code Web UI - Easy Install & Run Script for Mac (M-series)
# This script will install everything needed and start the application

set -e  # Exit on any error

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Clear screen for clean start
clear

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  Claude Code Web UI Easy Installer  ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${GREEN}This installer will set up Claude Code Web UI${NC}"
echo -e "${GREEN}No additional dependencies needed - just Claude CLI!${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to download with progress
download_with_progress() {
    local url=$1
    local output=$2
    echo -e "${BLUE}Downloading Claude Code Web UI...${NC}"
    curl -# -L "$url" -o "$output"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script is designed for macOS only.${NC}"
    exit 1
fi

# Check if running on Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    echo -e "${YELLOW}Warning: This script is optimized for Apple Silicon (M-series) Macs.${NC}"
    echo -e "${YELLOW}You appear to be running on Intel. The script will continue but may not work optimally.${NC}"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
fi

echo -e "${GREEN}✓ Running on macOS (Apple Silicon)${NC}"
echo ""

# Step 1: Check for Claude CLI (THE ONLY DEPENDENCY!)
echo -e "${BLUE}Step 1: Checking for Claude CLI...${NC}"
if ! command_exists claude; then
    echo -e "${RED}✗ Claude CLI not found${NC}"
    echo ""
    echo -e "${YELLOW}Claude CLI is the ONLY requirement for Claude Code Web UI.${NC}"
    echo ""
    echo -e "${BLUE}To install Claude CLI:${NC}"
    echo "1. Visit: https://github.com/anthropics/claude-code"
    echo "2. Follow the installation instructions for your system"
    echo "3. Run 'claude auth' to authenticate"
    echo "4. Then run this installer again"
    echo ""
    echo -e "${YELLOW}Note: You do NOT need Node.js, npm, or any other tools!${NC}"
    echo -e "${YELLOW}The pre-built binary includes everything else.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Claude CLI found${NC}"
    
    # Check if Claude is authenticated by testing a simple command
    echo "Checking Claude authentication..."
    if ! claude --help >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Claude CLI needs authentication${NC}"
        echo ""
        echo -e "${BLUE}Let's set up Claude authentication now:${NC}"
        echo ""
        echo "You'll need your Anthropic API key from:"
        echo "https://console.anthropic.com/account/keys"
        echo ""
        echo -e "${YELLOW}Would you like to authenticate Claude now?${NC}"
        read -p "Press Y to authenticate, N to skip: " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}Running Claude authentication...${NC}"
            echo "Follow the prompts to enter your API key:"
            echo ""
            claude auth
            
            # Check if authentication succeeded
            if claude --help >/dev/null 2>&1; then
                echo ""
                echo -e "${GREEN}✓ Claude authentication successful!${NC}"
            else
                echo ""
                echo -e "${RED}Authentication may have failed.${NC}"
                echo -e "${YELLOW}You can try again later with: claude auth${NC}"
                echo ""
                read -p "Press Enter to continue with installation anyway..."
            fi
        else
            echo ""
            echo -e "${YELLOW}Skipping authentication for now.${NC}"
            echo -e "${YELLOW}You'll need to run 'claude auth' before using Claude Code Web UI.${NC}"
            echo ""
            read -p "Press Enter to continue..."
        fi
    else
        # Test if Claude can actually run commands (not just show help)
        if claude --version 2>&1 | grep -q "Claude"; then
            echo -e "${GREEN}✓ Claude is authenticated and ready${NC}"
        else
            echo -e "${YELLOW}⚠️  Claude may need re-authentication${NC}"
            echo ""
            echo "If you experience issues, try running: claude auth"
            echo ""
            read -p "Press Enter to continue..."
        fi
    fi
fi
echo ""

# Show what will be installed
echo -e "${BLUE}What this installer will do:${NC}"
echo "  1. Download the pre-built Claude Code Web UI binary"
echo "  2. Install it to: ~/Applications/ClaudeCodeWebUI"
echo "  3. Create a desktop shortcut for easy access"
echo "  4. Optionally start the application"
echo ""
echo -e "${GREEN}The pre-built binary includes:${NC}"
echo "  • The backend server (Deno-based)"
echo "  • The frontend web interface (React-based)"
echo "  • All necessary runtime components"
echo ""
echo -e "${YELLOW}No additional installations required!${NC}"
echo ""
read -p "Ready to proceed? Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 2: Create application directory
APP_DIR="/Applications/ClaudeCodeWebUI"
echo -e "${BLUE}Step 2: Setting up application directory...${NC}"
# Need sudo for global Applications folder
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}Application directory already exists. Updating...${NC}"
    sudo rm -rf "$APP_DIR"
fi
echo "Creating application directory (may require password)..."
sudo mkdir -p "$APP_DIR"
# Set permissions so we can write to it
sudo chown -R $(whoami):admin "$APP_DIR"
cd "$APP_DIR"
echo -e "${GREEN}✓ Created directory: $APP_DIR${NC}"
echo ""

# Step 3: Download the latest release
echo -e "${BLUE}Step 3: Downloading Claude Code Web UI...${NC}"
BINARY_NAME="claude-code-webui"
DOWNLOAD_URL="https://github.com/cooperwalter/claude-code-webui/releases/latest/download/claude-code-webui-macos-arm64"

# Check if releases exist
echo "Checking for available releases..."
if ! curl -s -f -I "$DOWNLOAD_URL" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  No releases found on GitHub yet.${NC}"
    echo ""
    echo -e "${BLUE}This appears to be a new repository without releases.${NC}"
    echo ""
    echo "To create a release:"
    echo "  1. Push a version tag: git tag v1.0.0 && git push origin v1.0.0"
    echo "  2. GitHub Actions will automatically build and release"
    echo "  3. Run this installer again after the release is created"
    echo ""
    echo "For manual release creation, see: RELEASE.md"
    echo ""
    echo -e "${YELLOW}Alternative: Use the developer installation${NC}"
    echo "Run: curl -s https://raw.githubusercontent.com/cooperwalter/claude-code-webui/main/install-dev-mac.sh | bash"
    exit 1
fi

# Remove old binary if exists
if [ -f "$BINARY_NAME" ]; then
    rm "$BINARY_NAME"
fi

# Download with progress bar
download_with_progress "$DOWNLOAD_URL" "$BINARY_NAME"

# Verify download succeeded and file is valid
if [ ! -f "$BINARY_NAME" ]; then
    echo -e "${RED}✗ Download failed - file not found${NC}"
    exit 1
fi

# Check if it's actually a binary (not an HTML error page)
if file "$BINARY_NAME" | grep -q "HTML"; then
    echo -e "${RED}✗ Download failed - received HTML instead of binary${NC}"
    echo -e "${YELLOW}This usually means the release doesn't exist yet.${NC}"
    rm "$BINARY_NAME"
    exit 1
fi

# Make it executable
chmod +x "$BINARY_NAME"
echo -e "${GREEN}✓ Downloaded and prepared Claude Code Web UI${NC}"
echo ""

# Step 4: Create a simple launcher script
echo -e "${BLUE}Step 4: Creating launcher...${NC}"
cat > "$APP_DIR/start-claude-webui.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
clear
echo "==========================================
  Claude Code Web UI
==========================================

The application will open in your default browser at:
http://localhost:8999

To stop the application:
- Press Ctrl+C in this window
- Or close this window

Starting..."
echo ""
./claude-code-webui
EOF

chmod +x "$APP_DIR/start-claude-webui.command"
echo -e "${GREEN}✓ Created launcher${NC}"
echo ""

# Step 5: Create desktop shortcut
echo -e "${BLUE}Step 5: Creating desktop shortcut...${NC}"
DESKTOP_DIR="$HOME/Desktop"
if [ -d "$DESKTOP_DIR" ]; then
    # Create an alias (not a symlink) for better macOS compatibility
    osascript << EOF
tell application "Finder"
    try
        set sourceFile to POSIX file "$APP_DIR/start-claude-webui.command" as alias
        set desktopFolder to path to desktop
        make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI"}
    on error
        -- If alias already exists, delete and recreate
        try
            delete alias file "Claude Code Web UI" of desktop
            make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI"}
        end try
    end try
end tell
EOF
    echo -e "${GREEN}✓ Created desktop shortcut${NC}"
else
    echo -e "${YELLOW}Desktop directory not found, skipping shortcut creation${NC}"
fi
echo ""

# Step 6: Create uninstaller
echo -e "${BLUE}Step 6: Creating uninstaller...${NC}"
cat > "$APP_DIR/uninstall.command" << 'EOF'
#!/bin/bash
clear
echo "Claude Code Web UI Uninstaller"
echo "=============================="
echo ""
echo "This will remove:"
echo "  • Claude Code Web UI application from /Applications"
echo "  • Desktop shortcut"
echo ""
echo "This will NOT remove:"
echo "  • Claude CLI (needed for other tools)"
echo "  • Any of your project files"
echo ""
read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove desktop shortcut using AppleScript
    osascript -e 'tell application "Finder" to delete alias file "Claude Code Web UI" of desktop' 2>/dev/null || true
    
    # Remove application directory (requires sudo)
    echo "Removing application (may require password)..."
    sudo rm -rf "/Applications/ClaudeCodeWebUI"
    
    echo ""
    echo "Claude Code Web UI has been uninstalled."
else
    echo "Uninstall cancelled."
fi
EOF

chmod +x "$APP_DIR/uninstall.command"
echo -e "${GREEN}✓ Created uninstaller${NC}"
echo ""

# Final summary
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}     Installation Complete! 🎉       ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${BLUE}Claude Code Web UI has been installed to:${NC}"
echo "  $APP_DIR"
echo ""
echo -e "${BLUE}You can start it in the future by:${NC}"
echo "  1. Double-clicking 'Claude Code Web UI' on your desktop"
echo "  2. Or running: $APP_DIR/start-claude-webui.command"
echo ""
echo -e "${BLUE}To uninstall later:${NC}"
echo "  Run: $APP_DIR/uninstall.command"
echo ""
echo -e "${GREEN}No additional setup required!${NC}"
echo -e "${GREEN}The application includes everything it needs.${NC}"
echo ""
echo -e "${YELLOW}Would you like to start Claude Code Web UI now?${NC}"
read -p "Press Y to start, or any other key to exit: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Starting Claude Code Web UI...${NC}"
    echo -e "${YELLOW}Opening in your browser at: http://localhost:8999${NC}"
    echo -e "${YELLOW}To stop: Press Ctrl+C or close this window${NC}"
    echo ""
    
    # Start the application
    cd "$APP_DIR"
    ./claude-code-webui
else
    echo ""
    echo -e "${GREEN}Setup complete! You can start Claude Code Web UI anytime from your desktop.${NC}"
fi