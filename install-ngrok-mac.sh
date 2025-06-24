#!/bin/bash

# Claude Code Web UI - Ngrok Integration Script for Mac
# This script sets up ngrok for easy, secure remote access

set -e  # Exit on any error

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  Ngrok Setup for Claude Code Web UI ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${GREEN}This will set up ngrok for easy access with a friendly URL${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if ngrok is installed
echo -e "${BLUE}Checking for ngrok...${NC}"
if ! command_exists ngrok; then
    echo -e "${YELLOW}Ngrok not found. Installing...${NC}"
    
    # Install via Homebrew
    if command_exists brew; then
        brew install ngrok/ngrok/ngrok
    else
        echo -e "${RED}Homebrew not found. Installing ngrok manually...${NC}"
        # Download ngrok for Mac ARM64
        curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip -o ngrok.zip
        unzip ngrok.zip
        sudo mv ngrok /usr/local/bin/
        rm ngrok.zip
    fi
    
    echo -e "${GREEN}✓ Ngrok installed${NC}"
else
    echo -e "${GREEN}✓ Ngrok found${NC}"
fi
echo ""

# Check if ngrok is authenticated
echo -e "${BLUE}Checking ngrok authentication...${NC}"
if ! ngrok config check >/dev/null 2>&1; then
    echo -e "${YELLOW}Ngrok needs authentication for better features${NC}"
    echo ""
    echo "With a free ngrok account you get:"
    echo "  • Persistent subdomain (same URL every time)"
    echo "  • Better connection stability"
    echo "  • HTTPS encryption"
    echo ""
    echo "1. Sign up free at: https://dashboard.ngrok.com/signup"
    echo "2. Get your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo ""
    echo -e "${YELLOW}Would you like to add your ngrok authtoken now?${NC}"
    read -p "Press Y to add token, N to skip: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Paste your authtoken here: " NGROK_TOKEN
        ngrok config add-authtoken "$NGROK_TOKEN"
        echo -e "${GREEN}✓ Ngrok authenticated${NC}"
    else
        echo -e "${YELLOW}Skipping authentication. You'll get a random URL each time.${NC}"
    fi
else
    echo -e "${GREEN}✓ Ngrok is authenticated${NC}"
fi
echo ""

# Create ngrok launcher
echo -e "${BLUE}Creating ngrok launcher...${NC}"
LAUNCHER_PATH="/Applications/ClaudeCodeWebUI/start-with-ngrok.command"

cat > "$LAUNCHER_PATH" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
clear

echo "=========================================="
echo "  Claude Code Web UI with Ngrok"
echo "=========================================="
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down..."
    # Kill ngrok
    pkill -f "ngrok http 8999" || true
    # Kill claude-code-webui
    pkill -f "claude-code-webui" || true
    exit 0
}

# Set up trap for cleanup
trap cleanup INT TERM EXIT

# Start Claude Code Web UI in background
echo "Starting Claude Code Web UI..."
./claude-code-webui --host 127.0.0.1 > /tmp/claude-webui.log 2>&1 &
CLAUDE_PID=$!

# Wait for it to start
sleep 2

# Check if it started successfully
if ! kill -0 $CLAUDE_PID 2>/dev/null; then
    echo "Failed to start Claude Code Web UI"
    cat /tmp/claude-webui.log
    exit 1
fi

echo "✓ Claude Code Web UI started"
echo ""

# Start ngrok
echo "Starting ngrok tunnel..."
ngrok http 8999 --log-level=info --log=stdout > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for ngrok to start and extract URL
echo "Waiting for ngrok URL..."
sleep 3

# Get the public URL from ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -1)

if [ -z "$NGROK_URL" ]; then
    echo "Failed to get ngrok URL. Trying again..."
    sleep 2
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -1)
fi

if [ -z "$NGROK_URL" ]; then
    echo "Could not establish ngrok tunnel"
    echo "Ngrok log:"
    cat /tmp/ngrok.log
    exit 1
fi

echo ""
echo "=========================================="
echo -e "\033[0;32m✓ Claude Code Web UI is ready!\033[0m"
echo "=========================================="
echo ""
echo -e "\033[1;33mAccess from anywhere:\033[0m"
echo -e "\033[1;34m$NGROK_URL\033[0m"
echo ""
echo "Share this URL with anyone to give them access"
echo "(No IP addresses or port numbers needed!)"
echo ""
echo -e "\033[0;33mLocal access:\033[0m http://localhost:8999"
echo -e "\033[0;33mNgrok dashboard:\033[0m http://localhost:4040"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Copy URL to clipboard
echo "$NGROK_URL" | pbcopy
echo "(URL copied to clipboard)"
echo ""

# Keep script running
wait $CLAUDE_PID
EOF

chmod +x "$LAUNCHER_PATH"
echo -e "${GREEN}✓ Created ngrok launcher${NC}"
echo ""

# Create desktop shortcut for ngrok version
echo -e "${BLUE}Creating desktop shortcut...${NC}"
osascript << EOF
tell application "Finder"
    try
        set sourceFile to POSIX file "$LAUNCHER_PATH" as alias
        set desktopFolder to path to desktop
        make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI (Ngrok)"}
    on error
        -- If alias already exists, delete and recreate
        try
            delete alias file "Claude Code Web UI (Ngrok)" of desktop
            make alias file at desktopFolder to sourceFile with properties {name:"Claude Code Web UI (Ngrok)"}
        end try
    end try
end tell
EOF
echo -e "${GREEN}✓ Created desktop shortcut${NC}"
echo ""

# Final instructions
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}     Setup Complete! 🎉              ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${BLUE}You now have two ways to start Claude Code Web UI:${NC}"
echo ""
echo "1. ${GREEN}Local Network Access${NC} (original)"
echo "   - Double-click 'Claude Code Web UI'"
echo "   - Access via IP address on local network"
echo ""
echo "2. ${GREEN}Ngrok Access${NC} (new!)"
echo "   - Double-click 'Claude Code Web UI (Ngrok)'"
echo "   - Get a friendly HTTPS URL like: https://abc123.ngrok.io"
echo "   - Share with anyone, anywhere"
echo "   - URL is automatically copied to clipboard"
echo ""
echo -e "${YELLOW}Security Notes:${NC}"
echo "- Ngrok URLs are public (anyone with the URL can access)"
echo "- Free ngrok gives you a new URL each session"
echo "- Sign up for ngrok to get a persistent subdomain"
echo ""
echo -e "${YELLOW}Would you like to test the ngrok version now?${NC}"
read -p "Press Y to start, or any other key to exit: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    "$LAUNCHER_PATH"
else
    echo ""
    echo -e "${GREEN}Setup complete! Use the desktop shortcuts to start.${NC}"
fi