#!/bin/bash

# Claude Code Web UI - Developer Installation Script for Mac
# This script installs all dependencies needed for development

set -e  # Exit on any error

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Clear screen for clean start
clear

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Claude Code Web UI Developer Setup (Mac)       ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "${YELLOW}This script will install all dependencies needed${NC}"
echo -e "${YELLOW}to run Claude Code Web UI from source code.${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get installed version
get_version() {
    local cmd=$1
    case $cmd in
        node)
            node --version 2>/dev/null | sed 's/v//' || echo "not installed"
            ;;
        npm)
            npm --version 2>/dev/null || echo "not installed"
            ;;
        deno)
            deno --version 2>/dev/null | head -n1 | awk '{print $2}' || echo "not installed"
            ;;
        claude)
            claude --version 2>/dev/null | head -n1 || echo "not installed"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script is designed for macOS only.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Running on macOS${NC}"
echo ""

# Check for Homebrew
echo -e "${BLUE}Checking for Homebrew...${NC}"
if ! command_exists brew; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    echo -e "${YELLOW}This is the package manager for macOS.${NC}"
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for M1 Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓ Homebrew installed${NC}"
else
    echo -e "${GREEN}✓ Homebrew found ($(brew --version | head -n1))${NC}"
fi
echo ""

# Check current versions
echo -e "${BLUE}Checking current installations...${NC}"
echo "  Node.js: $(get_version node)"
echo "  npm: $(get_version npm)"
echo "  Deno: $(get_version deno)"
echo "  Claude CLI: $(get_version claude)"
echo ""

# Install Node.js and npm
echo -e "${BLUE}Step 1: Installing/Updating Node.js and npm...${NC}"
if ! command_exists node || ! command_exists npm; then
    echo -e "${YELLOW}Installing Node.js (includes npm)...${NC}"
    brew install node
    echo -e "${GREEN}✓ Node.js and npm installed${NC}"
else
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt "18" ]; then
        echo -e "${YELLOW}Node.js version is too old. Updating...${NC}"
        brew upgrade node
        echo -e "${GREEN}✓ Node.js updated${NC}"
    else
        echo -e "${GREEN}✓ Node.js $(node --version) and npm $(npm --version) are installed${NC}"
    fi
fi
echo ""

# Install Deno
echo -e "${BLUE}Step 2: Installing/Updating Deno...${NC}"
if ! command_exists deno; then
    echo -e "${YELLOW}Installing Deno...${NC}"
    brew install deno
    echo -e "${GREEN}✓ Deno installed${NC}"
else
    echo -e "${GREEN}✓ Deno $(deno --version | head -n1) is installed${NC}"
    echo -e "${YELLOW}Checking for updates...${NC}"
    brew upgrade deno 2>/dev/null || true
fi
echo ""

# Check for Claude CLI
echo -e "${BLUE}Step 3: Checking Claude CLI...${NC}"
if ! command_exists claude; then
    echo -e "${RED}✗ Claude CLI not found${NC}"
    echo ""
    echo -e "${YELLOW}Claude CLI must be installed separately.${NC}"
    echo -e "${BLUE}To install:${NC}"
    echo "1. Visit: https://github.com/anthropics/claude-code"
    echo "2. Follow the installation instructions"
    echo "3. Run 'claude auth' to authenticate"
    echo ""
    read -p "Press Enter to continue without Claude CLI (you can install it later)..."
else
    echo -e "${GREEN}✓ Claude CLI found${NC}"
    
    # Check if Claude is authenticated
    if ! claude --version >/dev/null 2>&1; then
        echo -e "${YELLOW}Claude CLI may not be authenticated.${NC}"
        echo -e "${YELLOW}You may need to run: claude auth${NC}"
    fi
fi
echo ""

# Install Git (if not present)
echo -e "${BLUE}Step 4: Checking Git...${NC}"
if ! command_exists git; then
    echo -e "${YELLOW}Installing Git...${NC}"
    brew install git
    echo -e "${GREEN}✓ Git installed${NC}"
else
    echo -e "${GREEN}✓ Git $(git --version) is installed${NC}"
fi
echo ""

# Clone or update the repository
echo -e "${BLUE}Step 5: Setting up Claude Code Web UI source...${NC}"
PROJECT_DIR="$HOME/Projects/claude-code-webui"
mkdir -p "$HOME/Projects"

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Project directory already exists. Pulling latest changes...${NC}"
    cd "$PROJECT_DIR"
    git pull origin main || echo -e "${YELLOW}Could not pull updates (may have local changes)${NC}"
else
    echo -e "${YELLOW}Cloning Claude Code Web UI repository...${NC}"
    cd "$HOME/Projects"
    git clone https://github.com/cooperwalter/claude-code-webui.git
    cd "$PROJECT_DIR"
fi
echo -e "${GREEN}✓ Source code ready at: $PROJECT_DIR${NC}"
echo ""

# Install frontend dependencies
echo -e "${BLUE}Step 6: Installing frontend dependencies...${NC}"
cd "$PROJECT_DIR/frontend"
npm install
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
echo ""

# Cache Deno dependencies
echo -e "${BLUE}Step 7: Caching backend dependencies...${NC}"
cd "$PROJECT_DIR/backend"
deno cache main.ts
echo -e "${GREEN}✓ Backend dependencies cached${NC}"
echo ""

# Create convenience scripts
echo -e "${BLUE}Step 8: Creating convenience scripts...${NC}"
cd "$PROJECT_DIR"

# Create start script
cat > "start-dev.sh" << 'EOF'
#!/bin/bash
# Start both frontend and backend in development mode

echo "Starting Claude Code Web UI in development mode..."
echo ""
echo "Opening two terminal tabs:"
echo "  1. Backend (Deno) - Port 8080"
echo "  2. Frontend (Vite) - Port 3000"
echo ""

# Function to open new terminal tab and run command
open_terminal_tab() {
    osascript <<EOD
        tell application "Terminal"
            tell application "System Events" to keystroke "t" using command down
            delay 0.5
            do script "$1" in front window
        end tell
EOD
}

# Start backend in new tab
open_terminal_tab "cd '$PWD/backend' && deno task dev"

# Wait a moment for backend to start
sleep 2

# Start frontend in new tab
open_terminal_tab "cd '$PWD/frontend' && npm run dev"

echo "Development servers are starting..."
echo ""
echo "Backend API: http://localhost:8080"
echo "Frontend UI: http://localhost:3000"
echo ""
echo "To stop the servers, close the Terminal tabs or press Ctrl+C in each."
EOF

chmod +x start-dev.sh

# Create build script
cat > "build-all.sh" << 'EOF'
#!/bin/bash
# Build the complete application

echo "Building Claude Code Web UI..."
echo ""

# Build frontend
echo "Building frontend..."
cd frontend
npm run build
cd ..

# Build backend binary
echo "Building backend binary..."
make build-backend

echo ""
echo "Build complete!"
echo "Binary available at: backend/claude-code-webui"
EOF

chmod +x build-all.sh

echo -e "${GREEN}✓ Created convenience scripts${NC}"
echo ""

# Create desktop shortcut for development
echo -e "${BLUE}Step 9: Creating desktop shortcut...${NC}"
DESKTOP_DIR="$HOME/Desktop"
if [ -d "$DESKTOP_DIR" ]; then
    cat > "$DESKTOP_DIR/Claude Code Web UI (Dev).command" << EOF
#!/bin/bash
cd "$PROJECT_DIR"
./start-dev.sh
EOF
    chmod +x "$DESKTOP_DIR/Claude Code Web UI (Dev).command"
    echo -e "${GREEN}✓ Created desktop shortcut for development${NC}"
fi
echo ""

# Final summary
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}     Developer Setup Complete! 🎉                ${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo -e "${BLUE}All dependencies installed:${NC}"
echo "  ✓ Node.js: $(node --version)"
echo "  ✓ npm: $(npm --version)"
echo "  ✓ Deno: $(deno --version | head -n1)"
echo "  ✓ Git: $(git --version | awk '{print $3}')"
if command_exists claude; then
    echo "  ✓ Claude CLI: installed"
else
    echo "  ⚠ Claude CLI: not installed (install separately)"
fi
echo ""
echo -e "${BLUE}Project location:${NC}"
echo "  $PROJECT_DIR"
echo ""
echo -e "${BLUE}Quick commands:${NC}"
echo "  Start development: ./start-dev.sh"
echo "  Build application: ./build-all.sh"
echo "  Run quality checks: make check"
echo ""
echo -e "${BLUE}Or use desktop shortcut:${NC}"
echo "  'Claude Code Web UI (Dev)' on your desktop"
echo ""
echo -e "${YELLOW}Would you like to start the development servers now?${NC}"
read -p "Press Y to start, or any other key to exit: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$PROJECT_DIR"
    ./start-dev.sh
else
    echo ""
    echo -e "${GREEN}Setup complete! Happy coding! 🚀${NC}"
fi