#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Create PID directory if it doesn't exist
mkdir -p "$HOME/.claude-webui"

# Function to kill processes on specific port
kill_port_process() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        echo "Killing process on port $port (PID: $pid)..."
        kill -9 $pid 2>/dev/null || true
        sleep 1
    fi
}

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  Claude Code Web UI - Background Mode${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Check if pnpm is installed
if ! command -v pnpm >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: pnpm not found. Using npm instead.${NC}"
    NPM_CMD="npm"
else
    NPM_CMD="pnpm"
fi

# Kill any existing processes
echo "Cleaning up any existing processes..."
pkill -f "deno.*claude-code-webui" || true
pkill -f "vite.*--port 3333" || true
pkill -f "ngrok http.*3333" || true
kill_port_process 8999
kill_port_process 3333

# Remove old PID files
rm -f "$HOME/.claude-webui/"*.pid

echo ""
echo "Starting services in background..."
echo ""

# Start backend
echo -n "Starting backend server... "
nohup deno run --allow-all backend/main.ts > "$HOME/.claude-webui/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$HOME/.claude-webui/backend.pid"
echo -e "${GREEN}✓${NC} (PID: $BACKEND_PID)"

# Wait a moment for backend to start
sleep 2

# Start frontend
echo -n "Starting frontend server... "
cd frontend
nohup npm run dev > "$HOME/.claude-webui/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > "$HOME/.claude-webui/frontend.pid"
cd ..
echo -e "${GREEN}✓${NC} (PID: $FRONTEND_PID)"

# Wait for frontend to start
sleep 3

# Start ngrok
echo -n "Starting ngrok tunnel... "
nohup ngrok http --url=grouper-winning-weekly.ngrok-free.app 3333 --log stdout > "$HOME/.claude-webui/ngrok.log" 2>&1 &
NGROK_PID=$!
echo $NGROK_PID > "$HOME/.claude-webui/ngrok.pid"
echo -e "${GREEN}✓${NC} (PID: $NGROK_PID)"

# Wait for ngrok to establish connection
echo ""
echo "Waiting for ngrok tunnel to establish..."
sleep 5

# Try to get ngrok URL
NGROK_URL=""
for i in {1..10}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -1)
    if [ -n "$NGROK_URL" ]; then
        break
    fi
    sleep 1
done

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}  All services started successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "${BLUE}Access your application at:${NC}"
echo ""
if [ -n "$NGROK_URL" ]; then
    echo -e "  Public URL:  ${GREEN}$NGROK_URL${NC}"
    echo "$NGROK_URL" | pbcopy
    echo "  (URL copied to clipboard)"
else
    echo -e "  Public URL:  ${GREEN}https://grouper-winning-weekly.ngrok-free.app${NC}"
fi
echo -e "  Local URL:   ${GREEN}http://localhost:3333${NC}"
echo ""
echo -e "${BLUE}Service logs are being written to:${NC}"
echo "  Backend:  ~/.claude-webui/backend.log"
echo "  Frontend: ~/.claude-webui/frontend.log"
echo "  Ngrok:    ~/.claude-webui/ngrok.log"
echo ""
echo -e "${YELLOW}To stop all services later, run:${NC}"
echo "  ./scripts/stop-dev-public.sh"
echo ""
echo -e "${GREEN}You can now safely close this terminal!${NC}"
echo ""