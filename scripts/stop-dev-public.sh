#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===========================================${NC}"
echo -e "${YELLOW}  Stopping Claude Code Web UI Services${NC}"
echo -e "${YELLOW}===========================================${NC}"
echo ""

# Function to stop a service by PID file
stop_service() {
    local service_name=$1
    local pid_file="$HOME/.claude-webui/$2.pid"
    
    if [ -f "$pid_file" ]; then
        PID=$(cat "$pid_file")
        if kill -0 $PID 2>/dev/null; then
            echo -n "Stopping $service_name (PID: $PID)... "
            kill $PID 2>/dev/null
            # Give it a moment to shutdown gracefully
            sleep 1
            # Force kill if still running
            if kill -0 $PID 2>/dev/null; then
                kill -9 $PID 2>/dev/null
            fi
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}$service_name not running (stale PID file)${NC}"
        fi
        rm -f "$pid_file"
    else
        echo -e "${YELLOW}$service_name PID file not found${NC}"
    fi
}

# Stop all services
stop_service "Ngrok tunnel" "ngrok"
stop_service "Frontend server" "frontend"
stop_service "Backend server" "backend"

# Also kill by process name as backup
echo ""
echo "Cleaning up any remaining processes..."
pkill -f "ngrok http.*3333" 2>/dev/null || true
pkill -f "vite.*--port 3333" 2>/dev/null || true
pkill -f "deno.*claude-code-webui" 2>/dev/null || true

# Clean up log files (optional - comment out if you want to keep logs)
echo ""
echo -n "Cleaning up log files... "
rm -f "$HOME/.claude-webui/"*.log
echo -e "${GREEN}✓${NC}"

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}  All services stopped successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""