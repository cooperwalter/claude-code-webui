#!/bin/bash

# This script creates a macOS .app bundle that users can simply double-click
# Run this to generate "Install Claude Code Web UI.app"

set -e

echo "Creating macOS installer app..."

# Create app structure
APP_NAME="Install Claude Code Web UI"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean up any existing app
rm -rf "$APP_DIR"

# Create directories
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Create the main executable script
cat > "$MACOS_DIR/installer" << 'EOF'
#!/bin/bash

# Get the directory where this app is located
APP_PATH="$(cd "$(dirname "$0")/../../../" && pwd)"

# Use osascript to run Terminal with our install script
osascript << 'EOA'
tell application "Terminal"
    activate
    
    -- Create new window
    do script "clear; echo 'Starting Claude Code Web UI Installer...'; echo ''; curl -s https://raw.githubusercontent.com/cooperwalter/claude-code-webui/main/install-and-run-mac.sh | bash"
    
    -- Make sure Terminal stays in front
    activate
end tell
EOA
EOF

chmod +x "$MACOS_DIR/installer"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>installer</string>
    <key>CFBundleIdentifier</key>
    <string>com.claudecodewebui.installer</string>
    <key>CFBundleName</key>
    <string>Install Claude Code Web UI</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create a simple icon (using built-in Terminal icon for now)
# In a real scenario, you'd create a custom .icns file
cp /System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns "$RESOURCES_DIR/installer.icns" 2>/dev/null || true

echo "✅ Created $APP_DIR"
echo ""
echo "Users can now simply double-click '$APP_NAME.app' to install!"
echo ""
echo "To distribute this app:"
echo "1. Right-click the app and select 'Compress'"
echo "2. Share the resulting .zip file"
echo "3. Users unzip and double-click to install"