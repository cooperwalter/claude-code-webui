# Creating GitHub Releases

This guide explains how to create releases for Claude Code Web UI.

## Automated Release Process (Recommended)

Your repository already has a GitHub Actions workflow that automatically builds and releases binaries when you push a version tag.

### Step 1: Create and Push a Version Tag

```bash
# Make sure you're on the main branch with latest changes
git checkout main
git pull origin main

# Create a new version tag (following semantic versioning)
git tag v1.0.0

# Push the tag to GitHub
git push origin v1.0.0
```

### Step 2: GitHub Actions Takes Over

Once you push the tag, GitHub Actions will automatically:

1. Build the frontend (React app)
2. Build binaries for all platforms:
   - Linux x64
   - Linux ARM64
   - macOS x64 (Intel)
   - macOS ARM64 (Apple Silicon)
3. Create a GitHub release with all binaries attached
4. Generate release notes from commits

### Step 3: Monitor the Release

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Watch the "Release" workflow progress
4. Once complete, check the "Releases" page

## Manual Release Process

If you need to create a release manually:

### Option 1: Using GitHub Web Interface

1. Go to your repository on GitHub
2. Click "Releases" (right sidebar)
3. Click "Create a new release"
4. Choose a tag (create new or select existing)
5. Fill in release details:
   - Release title (e.g., "v1.0.0")
   - Description (what's new, breaking changes, etc.)
6. Upload binary files (if you've built them locally)
7. Click "Publish release"

### Option 2: Using GitHub CLI

```bash
# Create a release with GitHub CLI
gh release create v1.0.0 \
  --title "Release v1.0.0" \
  --notes "Initial release" \
  --draft

# Upload binaries
gh release upload v1.0.0 \
  backend/claude-code-webui-macos-arm64 \
  backend/claude-code-webui-macos-x64 \
  backend/claude-code-webui-linux-x64 \
  backend/claude-code-webui-linux-arm64

# Publish the release (remove draft status)
gh release edit v1.0.0 --draft=false
```

## Building Binaries Locally

If you need to build binaries manually:

```bash
# Build frontend first
cd frontend
npm install
npm run build

# Copy to backend
cd ..
cp -r frontend/dist backend/dist

# Build binaries
cd backend

# For macOS ARM64 (Apple Silicon)
deno compile \
  --allow-read \
  --allow-write \
  --allow-net \
  --allow-env \
  --allow-run \
  --target aarch64-apple-darwin \
  --output claude-code-webui-macos-arm64 \
  main.ts

# For macOS x64 (Intel)
deno compile \
  --allow-read \
  --allow-write \
  --allow-net \
  --allow-env \
  --allow-run \
  --target x86_64-apple-darwin \
  --output claude-code-webui-macos-x64 \
  main.ts

# For Linux x64
deno compile \
  --allow-read \
  --allow-write \
  --allow-net \
  --allow-env \
  --allow-run \
  --target x86_64-unknown-linux-gnu \
  --output claude-code-webui-linux-x64 \
  main.ts

# For Linux ARM64
deno compile \
  --allow-read \
  --allow-write \
  --allow-net \
  --allow-env \
  --allow-run \
  --target aarch64-unknown-linux-gnu \
  --output claude-code-webui-linux-arm64 \
  main.ts
```

## Version Numbering

Follow semantic versioning (SemVer):

- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.1.x): New features (backwards compatible)
- **PATCH** (x.x.1): Bug fixes (backwards compatible)

Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - Added new feature
- `v1.1.1` - Fixed a bug
- `v2.0.0` - Breaking change in API

## Quick First Release

To create your first release right now:

```bash
# Option 1: Trigger workflow manually (if no changes needed)
gh workflow run release.yml

# Option 2: Create and push a tag
git tag v0.1.0
git push origin v0.1.0
```

Then wait for the GitHub Actions workflow to complete and check the Releases page!