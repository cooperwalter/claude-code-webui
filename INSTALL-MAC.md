# 🍎 Easy Installation Guide for Mac Users

This guide will help you install and run Claude Code Web UI on your Mac in just a few minutes!

## 📋 What You Need

### For Regular Users (Pre-built Binary)
1. **A Mac computer** (preferably with Apple Silicon M1/M2/M3)
2. **Claude CLI installed** - The ONLY dependency!
   - Visit <https://github.com/anthropics/claude-code>
   - Follow their installation instructions
   - Run `claude auth` to log in

**That's it!** The pre-built binary includes everything else:
- ✅ Backend server (Deno runtime included)
- ✅ Frontend interface (pre-built and bundled)
- ✅ All necessary libraries and components

**You do NOT need**: Node.js, npm, Deno, or any other development tools!

### For Developers (Running from Source)
If you want to modify the code or contribute to development, see our [Developer Installation Guide](#developer-installation) at the bottom of this page.

## 🚀 Quick Install (Recommended)

We've created a simple script that does everything for you!

### Step 1: Download the installer

Open Terminal (you can find it in Applications > Utilities > Terminal) and run:

```bash
curl -O https://raw.githubusercontent.com/cooperwalter/claude-code-webui/main/install-and-run-mac.sh
```

### Step 2: Run the installer

```bash
bash install-and-run-mac.sh
```

The script will:

- ✅ Check if Claude CLI is installed
- ✅ Download Claude Code Web UI
- ✅ Set everything up
- ✅ Create a desktop shortcut
- ✅ Ask if you want to start the app

## 🎯 Using Claude Code Web UI

### Starting the Application

After installation, you can start Claude Code Web UI by:

1. **Double-clicking** the "Claude Code Web UI" icon on your desktop
2. **Or** opening Terminal and running:
   ```bash
   ~/Applications/ClaudeCodeWebUI/start-claude-webui.command
   ```

### What to Expect

1. A Terminal window will open showing the server is running
2. Your web browser will automatically open to `http://localhost:8080`
3. You'll see the Claude Code Web UI interface
4. Select a project directory to start chatting with Claude!

### Stopping the Application

To stop Claude Code Web UI:

- Close the Terminal window that's running the server
- Or press `Ctrl+C` in the Terminal window

## 🔧 Troubleshooting

### "Claude CLI not found"

- You need to install Claude CLI first
- Visit: https://github.com/anthropics/claude-code
- After installing, run the script again

### "Permission denied"

- Make sure you're running the script with `bash` as shown above
- If issues persist, try: `chmod +x install-and-run-mac.sh`

### Browser doesn't open automatically

- Manually open your browser and go to: `http://localhost:8080`

### Port 8080 is already in use

- Another application is using port 8080
- Stop that application or wait a moment and try again

## 📱 For Mobile Access

Want to use Claude Code Web UI from your iPhone or iPad while on the same network?

1. Find your Mac's IP address:
   - Apple Menu > System Settings > Network
   - Look for your IP (like 192.168.1.100)

2. Start Claude Code Web UI with network access:

   ```bash
   ~/Applications/ClaudeCodeWebUI/claude-code-webui --host 0.0.0.0
   ```

3. On your mobile device, open browser and go to:
   ```
   http://[your-mac-ip]:8080
   ```
   Example: `http://192.168.1.100:8080`

## 🆘 Need Help?

- Check the [main README](README.md) for more details
- Report issues at: https://github.com/cooperwalter/claude-code-webui/issues
- Join discussions at: https://github.com/cooperwalter/claude-code-webui/discussions

---

## 👨‍💻 Developer Installation

If you want to run Claude Code Web UI from source code or contribute to development, you'll need additional tools.

### Developer Dependencies

- Node.js 18+ and npm
- Deno
- Git
- Claude CLI

### Automated Developer Setup

We provide a script that installs all development dependencies:

```bash
curl -s https://raw.githubusercontent.com/cooperwalter/claude-code-webui/main/install-dev-mac.sh | bash
```

This script will:
- Install Homebrew (if needed)
- Install Node.js and npm
- Install Deno
- Install Git
- Clone the repository
- Install all project dependencies
- Create convenient development scripts

### Manual Developer Setup

If you prefer to set up manually:

```bash
# Install dependencies
brew install node deno git

# Clone the repository
git clone https://github.com/cooperwalter/claude-code-webui.git
cd claude-code-webui

# Install frontend dependencies
cd frontend && npm install

# Start development servers
cd ../backend && deno task dev  # Terminal 1
cd ../frontend && npm run dev   # Terminal 2
```

---

**Note**: This installer is designed for M-series Macs. Intel Mac users may need to download a different binary from the [releases page](https://github.com/cooperwalter/claude-code-webui/releases).
