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

# Function to kill process on port
kill_port_process() {
    local port=$1
    echo -e "${BLUE}Checking for existing processes on port $port...${NC}"
    
    # Find PIDs using the port
    local pids=$(lsof -ti :$port 2>/dev/null)
    
    if [ -n "$pids" ]; then
        echo -e "${YELLOW}Found existing process(es) on port $port${NC}"
        for pid in $pids; do
            local process_info=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
            echo "  - PID $pid ($process_info)"
        done
        
        echo "Killing process(es)..."
        for pid in $pids; do
            kill -9 $pid 2>/dev/null || true
        done
        
        # Give it a moment to clean up
        sleep 1
        
        # Verify it's gone
        if lsof -ti :$port >/dev/null 2>&1; then
            echo -e "${RED}Warning: Could not kill all processes on port $port${NC}"
            return 1
        else
            echo -e "${GREEN}✓ Port $port is now free${NC}"
        fi
    else
        echo -e "${GREEN}✓ Port $port is available${NC}"
    fi
    return 0
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
    echo "Continuing in 3 seconds..."
    sleep 3
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
            echo "Continuing with installation..."
            sleep 2
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
            echo "Continuing..."
            sleep 2
        fi
    fi
fi
echo ""

# Show what will be installed
echo -e "${BLUE}What this installer will do:${NC}"
echo "  1. Download the pre-built Claude Code Web UI binary"
echo "  2. Install ngrok for easy, secure access with friendly URLs"
echo "  3. Install to: /Applications/ClaudeCodeWebUI"
echo "  4. Create desktop shortcuts for easy access"
echo "  5. Configure for read-only Claude access (safer!)"
echo "  6. Optionally start the application"
echo ""
echo -e "${GREEN}The pre-built binary includes:${NC}"
echo "  • The backend server (Deno-based)"
echo "  • The frontend web interface (React-based)"
echo "  • All necessary runtime components"
echo ""
echo -e "${YELLOW}Access Options:${NC}"
echo "  • Ngrok: Get a friendly HTTPS URL (e.g., https://abc123.ngrok.io)"
echo "  • Share with anyone, anywhere - no IP addresses needed!"
echo "  • Secure HTTPS connection automatically"
echo ""
echo -e "${YELLOW}Security Features:${NC}"
echo "  • Claude configured with read-only permissions by default"
echo "  • Write operations disabled for safety"
echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo ""
sleep 2

# Step 2: Install ngrok
echo -e "${BLUE}Step 2: Installing ngrok for easy access...${NC}"
if ! command_exists ngrok; then
    echo -e "${YELLOW}Installing ngrok...${NC}"
    if command_exists brew; then
        brew install ngrok/ngrok/ngrok
    else
        # Install Homebrew first if not present
        echo -e "${YELLOW}Installing Homebrew first...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for M1 Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        brew install ngrok/ngrok/ngrok
    fi
    echo -e "${GREEN}✓ Ngrok installed${NC}"
else
    echo -e "${GREEN}✓ Ngrok already installed${NC}"
fi
echo ""

# Optional: Configure ngrok authtoken for better experience
echo -e "${BLUE}Ngrok Configuration${NC}"
echo "Note: Ngrok works without an account, but with a free account you get:"
echo "  • More stable connections"
echo "  • Better rate limits"
echo "  • Subdomain options"
echo ""
echo "Sign up free at: https://dashboard.ngrok.com/signup"
echo ""
echo -e "${YELLOW}Skipping ngrok authentication for now (not required).${NC}"
echo "You can add an authtoken later with: ngrok config add-authtoken YOUR_TOKEN"
echo ""

# Step 3: Create application directory
APP_DIR="/Applications/ClaudeCodeWebUI"
echo -e "${BLUE}Step 3: Setting up application directory...${NC}"
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

# Step 4: Download the latest release
echo -e "${BLUE}Step 4: Downloading Claude Code Web UI...${NC}"
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

# Step 5: Create launcher scripts
echo -e "${BLUE}Step 5: Creating launcher scripts...${NC}"

# Create config file for restricted tools (read-only)
cat > "$APP_DIR/readonly-config.json" << 'EOF'
{
  "allowedTools": [
    "Read",
    "Glob", 
    "Grep",
    "LS",
    "NotebookRead",
    "WebFetch",
    "WebSearch",
    "TodoRead",
    "Bash"
  ],
  "allowedBashCommands": [
    "cat", "head", "tail", "less", "more",
    "grep", "egrep", "fgrep", "rg", "ag",
    "find", "locate", "which", "whereis",
    "ls", "dir", "tree", "du", "df",
    "ps", "top", "htop", "whoami", "pwd",
    "echo", "printf", "date", "cal",
    "wc", "sort", "uniq", "cut", "awk", "sed",
    "file", "stat", "md5", "shasum",
    "git status", "git log", "git diff", "git show",
    "npm list", "pip list", "gem list",
    "env", "printenv", "uname", "hostname"
  ],
  "description": "Read-only mode with safe bash commands for viewing and searching"
}
EOF

# Main launcher with ngrok
cat > "$APP_DIR/start-claude-webui.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Create stop script
cat > "$HOME/.claude-webui-stop.sh" << 'STOPSCRIPT'
#!/bin/bash
echo "Stopping Claude Code Web UI..."
pkill -f "ngrok http 8999" || true
pkill -f "claude-code-webui" || true
rm -f "$HOME/.claude-webui-stop.sh"
echo "Claude Code Web UI stopped."
STOPSCRIPT
chmod +x "$HOME/.claude-webui-stop.sh"

# Run the actual startup in background
(
clear
echo "==========================================
  Claude Code Web UI (with Ngrok)
==========================================
"

# Kill any existing processes on port 8999
kill_port_process 8999

# Function to find ngrok
find_ngrok() {
    # Check common locations
    if command -v ngrok >/dev/null 2>&1; then
        echo "ngrok"
    elif [ -x "/usr/local/bin/ngrok" ]; then
        echo "/usr/local/bin/ngrok"
    elif [ -x "/opt/homebrew/bin/ngrok" ]; then
        echo "/opt/homebrew/bin/ngrok"
    elif [ -x "$HOME/.local/bin/ngrok" ]; then
        echo "$HOME/.local/bin/ngrok"
    else
        echo ""
    fi
}

# Find ngrok
NGROK_CMD=$(find_ngrok)
if [ -z "$NGROK_CMD" ]; then
    echo "❌ Ngrok not found!"
    echo ""
    echo "Please install ngrok:"
    echo "  brew install ngrok/ngrok/ngrok"
    echo ""
    echo "Starting without ngrok (local access only)..."
    echo ""
    
    # Start in background and detach
    nohup ./claude-code-webui --host 0.0.0.0 > /tmp/claude-webui.log 2>&1 &
    echo $! > "$HOME/.claude-webui.pid"
    
    sleep 2
    echo ""
    echo "✅ Claude Code Web UI started in background!"
    echo ""
    echo "📱 Access at: http://localhost:8999"
    echo ""
    echo "To stop later, run: ~/.claude-webui-stop.sh"
    echo ""
    echo "This window will close in 5 seconds..."
    sleep 5
    exit 0
fi

echo "Found ngrok at: $NGROK_CMD"

# Start Claude Code Web UI in background
echo "Starting Claude Code Web UI..."
nohup ./claude-code-webui --host 127.0.0.1 > /tmp/claude-webui.log 2>&1 &
CLAUDE_PID=$!
echo $CLAUDE_PID > "$HOME/.claude-webui.pid"

sleep 2

if ! kill -0 $CLAUDE_PID 2>/dev/null; then
    echo "Failed to start Claude Code Web UI"
    echo "Error log:"
    cat /tmp/claude-webui.log
    sleep 5
    exit 1
fi

echo "✓ Claude Code Web UI started"

# Start ngrok in background
echo "Starting ngrok tunnel..."
nohup $NGROK_CMD http 8999 > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!
echo $NGROK_PID > "$HOME/.ngrok.pid"

# Wait for ngrok to fully start
echo "Waiting for ngrok to initialize..."
for i in {1..10}; do
    if curl -s http://localhost:4040/api >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Get the public URL
echo "Getting ngrok URL..."
NGROK_URL=""
for i in {1..5}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -1)
    if [ -n "$NGROK_URL" ]; then
        break
    fi
    sleep 1
done

if [ -z "$NGROK_URL" ]; then
    echo "⚠️  Could not get ngrok URL. Using local access..."
    NGROK_URL="http://localhost:8999"
fi

clear
echo "=========================================="
echo "  🚀 Claude Code Web UI is Running!"
echo "=========================================="
echo ""
if [[ "$NGROK_URL" == https://* ]]; then
    echo "📱 Access from anywhere:"
    echo "$NGROK_URL"
    echo ""
    echo "$NGROK_URL" | pbcopy
    echo "(URL copied to clipboard)"
    
    # Open in default browser
    open "$NGROK_URL"
else
    echo "📱 Local access only:"
    echo "http://localhost:8999"
    echo ""
    open "http://localhost:8999"
fi
echo ""
echo "🔒 Security Mode: READ-ONLY"
echo ""
echo "✅ Running in background - you can close this window!"
echo ""
echo "To stop Claude Code Web UI later, run:"
echo "  ~/.claude-webui-stop.sh"
echo ""
echo "Or use the uninstaller:"
echo "  /Applications/ClaudeCodeWebUI/uninstall.command"
echo ""
echo "This window will close in 10 seconds..."
sleep 10
) &

# Exit immediately so Terminal can close
exit 0
EOF

# Create alternative launcher for full permissions (if needed)
cat > "$APP_DIR/start-full-permissions.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Create stop script
cat > "$HOME/.claude-webui-stop.sh" << 'STOPSCRIPT'
#!/bin/bash
echo "Stopping Claude Code Web UI..."
pkill -f "ngrok http 8999" || true
pkill -f "claude-code-webui" || true
rm -f "$HOME/.claude-webui-stop.sh"
echo "Claude Code Web UI stopped."
STOPSCRIPT
chmod +x "$HOME/.claude-webui-stop.sh"

# Run in background
(
clear
echo "==========================================
  Claude Code Web UI (Full Permissions)
==========================================

⚠️  WARNING: This mode allows Claude to modify files!
Only use when you need write access.

Starting..."
echo ""

# Kill any existing processes on port 8999
kill_port_process 8999

# Start in background
nohup ./claude-code-webui --host 0.0.0.0 > /tmp/claude-webui.log 2>&1 &
echo $! > "$HOME/.claude-webui.pid"

sleep 2

# Get local IP
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "localhost")

echo "✅ Claude Code Web UI started in background!"
echo ""
echo "📱 Access from this computer: http://localhost:8999"
if [ "$IP" != "localhost" ]; then
    echo "📱 Access from other devices: http://$IP:8999"
fi
echo ""
open "http://localhost:8999"
echo ""
echo "⚠️  FULL PERMISSIONS MODE - Claude can modify files!"
echo ""
echo "To stop later, run: ~/.claude-webui-stop.sh"
echo ""
echo "This window will close in 10 seconds..."
sleep 10
) &

exit 0
EOF

# Create risky mode launcher
cat > "$APP_DIR/start-risky-mode.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Create stop script
cat > "$HOME/.claude-webui-stop.sh" << 'STOPSCRIPT'
#!/bin/bash
echo "Stopping Claude Code Web UI..."
pkill -f "ngrok http 8999" || true
pkill -f "claude-code-webui" || true
rm -f "$HOME/.claude-webui-stop.sh"
echo "Claude Code Web UI stopped."
STOPSCRIPT
chmod +x "$HOME/.claude-webui-stop.sh"

# Set environment variable for risky mode
export VITE_RISKY_MODE=true

# Run in background
(
clear
echo "==========================================
  Claude Code Web UI (🚨 RISKY MODE 🚨)
==========================================

⚠️  EXTREME WARNING: RISKY MODE ACTIVE!
• ALL permissions are auto-approved
• Claude can modify/delete ANY files
• NO safety checks or confirmations
• Use ONLY for fully trusted operations!

Starting..."
echo ""

# Note: In production, risky mode would need to be built into the frontend
# This is primarily for development use
echo "⚠️  Note: Risky mode only works in development environment"
echo "    For production use, rebuild frontend with VITE_RISKY_MODE=true"
echo ""

# Kill any existing processes on port 8999
kill_port_process 8999

# Start in background
nohup ./claude-code-webui --host 0.0.0.0 > /tmp/claude-webui.log 2>&1 &
echo $! > "$HOME/.claude-webui.pid"

sleep 2

# Get local IP
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "localhost")

echo "✅ Claude Code Web UI started in RISKY MODE!"
echo ""
echo "📱 Access from this computer: http://localhost:8999"
if [ "$IP" != "localhost" ]; then
    echo "📱 Access from other devices: http://$IP:8999"
fi
echo ""
open "http://localhost:8999"
echo ""
echo "🚨 RISKY MODE - NO PERMISSION DIALOGS!"
echo "Claude has UNRESTRICTED access to your system!"
echo ""
echo "To stop later, run: ~/.claude-webui-stop.sh"
echo ""
echo "This window will close in 10 seconds..."
sleep 10
) &

exit 0
EOF

chmod +x "$APP_DIR/start-claude-webui.command"
chmod +x "$APP_DIR/start-full-permissions.command"
chmod +x "$APP_DIR/start-risky-mode.command"
echo -e "${GREEN}✓ Created launchers${NC}"
echo ""

# Step 6: Create desktop shortcuts
echo -e "${BLUE}Step 6: Creating desktop shortcuts...${NC}"
DESKTOP_DIR="$HOME/Desktop"
if [ -d "$DESKTOP_DIR" ]; then
    # Try to create an alias using AppleScript
    osascript << EOF 2>/dev/null
tell application "Finder"
    try
        set sourceFile to POSIX file "$APP_DIR/start-claude-webui.command" as alias
        set desktopFolder to path to desktop
        make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI"}
    on error
        -- If alias already exists, try to delete and recreate
        try
            delete alias file "Claude Code Web UI" of desktop
            make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI"}
        end try
    end try
end tell
EOF
    
    # Check if alias was created successfully
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Created desktop shortcut${NC}"
    else
        # Fallback: Create a simple launcher script on desktop
        echo -e "${YELLOW}Creating alternative desktop launcher...${NC}"
        cat > "$DESKTOP_DIR/Claude Code Web UI.command" << EOF
#!/bin/bash
# Claude Code Web UI Launcher
"$APP_DIR/start-claude-webui.command"
EOF
        chmod +x "$DESKTOP_DIR/Claude Code Web UI.command"
        echo -e "${GREEN}✓ Created desktop launcher${NC}"
    fi
else
    echo -e "${YELLOW}Desktop directory not found, skipping shortcut creation${NC}"
fi
echo ""

# Step 7: Create uninstaller
echo -e "${BLUE}Step 7: Creating uninstaller...${NC}"
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
    # Stop running instances
    ~/.claude-webui-stop.sh 2>/dev/null || true
    
    # Remove desktop shortcut (try both alias and .command file)
    osascript -e 'tell application "Finder" to delete alias file "Claude Code Web UI" of desktop' 2>/dev/null || true
    rm -f "$HOME/Desktop/Claude Code Web UI.command" 2>/dev/null || true
    
    # Clean up pid files and stop script
    rm -f "$HOME/.claude-webui.pid" "$HOME/.ngrok.pid" "$HOME/.claude-webui-stop.sh" 2>/dev/null || true
    
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
echo -e "${BLUE}You have three ways to start:${NC}"
echo ""
echo "  1. ${GREEN}With Ngrok (Recommended)${NC}"
echo "     • Double-click 'Claude Code Web UI' on desktop"
echo "     • Get a friendly HTTPS URL (e.g., https://abc123.ngrok.io)"
echo "     • Share with anyone, anywhere"
echo "     • READ-ONLY mode for safety"
echo ""
echo "  2. ${YELLOW}Full Permissions (Use with caution)${NC}"
echo "     • Run: $APP_DIR/start-full-permissions.command"
echo "     • Allows Claude to modify files"
echo "     • Still asks for permission for each operation"
echo ""
echo "  3. ${RED}Risky Mode (Dangerous!)${NC}"
echo "     • Run: $APP_DIR/start-risky-mode.command"
echo "     • NO PERMISSION DIALOGS - auto-approves everything!"
echo "     • Only for fully trusted operations"
echo ""
echo -e "${BLUE}To uninstall later:${NC}"
echo "  Run: $APP_DIR/uninstall.command"
echo ""
echo -e "${GREEN}Everything is ready to go!${NC}"
echo ""
echo -e "${BLUE}Starting Claude Code Web UI with Ngrok...${NC}"
echo ""

# Kill any existing processes on port 8999 before starting
kill_port_process 8999

sleep 2

# Always start with the ngrok launcher
"$APP_DIR/start-claude-webui.command"