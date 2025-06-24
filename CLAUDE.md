# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Code Web UI

A web-based interface for the `claude` command line tool that provides streaming responses in a chat interface.

## Common Development Commands

### Quick Start
```bash
# Install all dependencies (first time only)
npm install
cd frontend && npm install && cd ..

# Start both backend and frontend together
npm run dev

# Or use make commands
make dev-backend  # Terminal 1
make dev-frontend # Terminal 2

# Run all quality checks before committing
make check

# Run individual checks
make format      # Format code
make lint        # Run linters
make typecheck   # Type check
make test        # Run tests
```

### Risky Mode (Development Only)
```bash
# Start in risky mode - auto-approves ALL permissions
npm run dev:risky

# WARNING: Only use for trusted operations!
# Claude will have full write access without asking
```

### Testing Commands
```bash
# Run all tests
make test

# Run tests in watch mode
cd frontend && npm run test:watch

# Run tests with coverage
cd frontend && npm run test:coverage

# Run a specific test file
cd frontend && npm test src/components/ChatPage.test.tsx
```

### Building
```bash
# Build frontend
make build-frontend

# Build backend binary (includes frontend)
make build-backend

# The binary will be at: backend/claude-code-webui
```

## High-Level Architecture

### Three-Layer Structure
```
┌─────────────────────────────────────────────────────────┐
│                     Frontend (React)                     │
│  - User Interface: Chat, Project Selection, Permissions  │
│  - State Management: Hooks-based modular architecture    │
│  - Streaming: Real-time message processing              │
└─────────────────────▲───────────────────────────────────┘
                      │ HTTP/SSE
┌─────────────────────▼───────────────────────────────────┐
│                    Backend (Deno)                        │
│  - REST API: /api/chat, /api/projects, /api/abort      │
│  - Claude SDK Integration: Executes claude commands     │
│  - Streaming: SSE for real-time responses              │
└─────────────────────▲───────────────────────────────────┘
                      │ TypeScript Types
┌─────────────────────▼───────────────────────────────────┐
│                   Shared Types                           │
│  - StreamResponse, ChatRequest, ProjectsResponse        │
│  - Type safety across frontend/backend boundary         │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Patterns

1. **Streaming Architecture**: Backend streams raw Claude JSON responses via Server-Sent Events (SSE), frontend parses and displays them in real-time.

2. **Hook Composition**: Frontend uses specialized hooks that compose together:
   - `useClaudeStreaming` → Main interface hook
   - `useChatState` + `usePermissions` + `useAbortController` → Core functionality
   - `useStreamParser` + `useMessageProcessor` + `useToolHandling` → Message processing

3. **Session Management**: Automatic conversation continuity using Claude SDK's session IDs, extracted from streaming messages and passed in subsequent requests.

4. **Request Lifecycle**: Each request has a unique ID for tracking and abortion, with proper cleanup on component unmount or user cancellation.

## Code Quality

This project uses automated quality checks to ensure consistent code standards:

- **Lefthook**: Git hooks manager that runs `make check` before every commit
- **Quality Commands**: Use `make check` to run all quality checks manually  
- **CI/CD**: GitHub Actions runs the same quality checks on every push

The pre-commit hook prevents commits with formatting, linting, or test failures.

### Setup for New Contributors

1. **Install Lefthook**: 
   ```bash
   # macOS
   brew install lefthook
   
   # Or download from https://github.com/evilmartians/lefthook/releases
   ```

2. **Install hooks**:
   ```bash
   lefthook install
   ```

3. **Verify setup**:
   ```bash
   lefthook run pre-commit
   ```

## Backend (Deno)

- **Location**: `backend/`
- **Main entry**: `backend/main.ts`
- **CLI parsing**: `backend/args.ts` using Cliffy framework
- **Port**: 8999 (configurable via CLI argument or PORT environment variable)
- **Technology**: Deno with TypeScript + Hono framework

### API Endpoints

- `GET /api/projects` - Retrieves list of available project directories
- `POST /api/chat` - Accepts chat messages and returns streaming responses
  - Request: `{ message: string, sessionId?: string, requestId: string, allowedTools?: string[], workingDirectory?: string }`
- `POST /api/abort/:requestId` - Aborts an ongoing request by request ID
- `/*` - Serves static frontend files (in single binary mode)

### Claude SDK Integration

The backend uses `@anthropic-ai/claude-code` SDK (v1.0.33) to execute claude commands with:
- Streaming JSON output format
- Verbose mode for detailed information
- Session resume capability for conversation continuity
- Working directory support for project-specific context

## Frontend (React)

- **Location**: `frontend/`
- **Main entry**: `frontend/src/main.tsx`
- **Routing**: `frontend/src/App.tsx` with React Router
- **Port**: 3000 (configurable via `--port` CLI argument to `npm run dev`)
- **Technology**: Vite + React + SWC + TypeScript + TailwindCSS

### Component Architecture

```
components/
├── ChatPage.tsx           # Main chat interface
├── ProjectSelector.tsx    # Project directory selection
├── MessageComponents.tsx  # Message display components
├── PermissionDialog.tsx   # Tool permission handling
├── chat/                  # Chat-specific components
└── messages/              # Message display utilities
```

### Hook Architecture

```
hooks/
├── useClaudeStreaming.ts  # Main streaming interface
├── chat/
│   ├── useChatState.ts    # Message and session state
│   ├── usePermissions.ts  # Permission dialog logic
│   └── useAbortController.ts # Request cancellation
└── streaming/
    ├── useStreamParser.ts     # Parse SSE stream
    ├── useMessageProcessor.ts # Process SDK messages
    └── useToolHandling.ts     # Handle tool messages
```

## Claude Code SDK Message Types

### SDK Message Structure
```typescript
// System message - fields directly on object
{ type: "system", cwd: string, tools: Tool[], ... }

// Assistant message - content nested under message.content
{ type: "assistant", message: { content: Array<TextContent | ToolUseContent> } }

// Result message - has subtype field
{ type: "result", subtype: "success" | "error_max_turns" | "error_during_execution" }
```

### Type Narrowing Pattern
```typescript
// Always use Extract for type safety
const systemMsg = sdkMessage as Extract<SDKMessage, { type: "system" }>;
const assistantMsg = sdkMessage as Extract<SDKMessage, { type: "assistant" }>;
```

## Port Configuration

Create a `.env` file in the project root:
```bash
PORT=9000  # Both backend and frontend will use this
```

## Claude Code Dependency Management

Both frontend and backend use **fixed versions** to ensure consistency:

- **Frontend**: `frontend/package.json` - `"@anthropic-ai/claude-code": "1.0.33"`
- **Backend**: `backend/deno.json` imports - `"@anthropic-ai/claude-code": "npm:@anthropic-ai/claude-code@1.0.33"`

### Version Update Procedure

```bash
# 1. Update frontend/package.json version
# 2. Update backend/deno.json imports version
# 3. Run updates
cd frontend && npm install
cd ../backend && rm deno.lock && deno cache main.ts
cd .. && make check
```

## Development Workflow

### Pull Request Process

1. Create feature branch: `git checkout -b feature/your-feature-name`
2. Make changes (Lefthook runs `make check` on commit)
3. Create PR with appropriate labels and checkboxes:
   ```bash
   gh pr create --title "Your PR Title" \
     --label "feature,documentation" \
     --body "Brief description"
   ```

### PR Labels

- 🐛 `bug` - Bug fixes
- ✨ `feature` - New features
- 💥 `breaking` - Breaking changes
- 📚 `documentation` - Documentation updates
- ⚡ `performance` - Performance improvements
- 🔨 `refactor` - Code refactoring
- 🧪 `test` - Testing updates
- 🔧 `chore` - Maintenance tasks

### Release Process

1. Feature PRs merged → tagpr creates/updates release PR
2. Add version labels: `major`, `minor`, or none (patch)
3. Merge release PR → tag created → binaries built

### Viewing Copilot Review Comments

```bash
# Copilot inline comments aren't shown in gh pr view
gh api repos/cooperwalter/claude-code-webui/pulls/PR_NUMBER/comments
```

## Project Structure

```
├── backend/           # Deno backend server
│   ├── deno.json     # Deno configuration
│   ├── main.ts       # Server implementation
│   └── args.ts       # CLI argument parsing
├── frontend/         # React frontend
│   ├── src/
│   │   ├── hooks/    # Business logic hooks
│   │   ├── components/ # UI components
│   │   ├── utils/    # Utility functions
│   │   └── types.ts  # Frontend types
│   └── vite.config.ts
├── shared/           # Shared TypeScript types
│   └── types.ts
├── Makefile         # Build commands
└── .env.example     # Environment template
```

## Key Design Decisions

1. **Raw JSON Streaming**: Backend passes Claude responses unmodified for frontend flexibility
2. **Modular Architecture**: Separation of concerns with hooks, components, and utilities
3. **Session Continuity**: Automatic conversation context preservation
4. **Request Management**: Unique IDs for tracking and cancellation
5. **Type Safety**: Shared types ensure consistency across stack
6. **Single Binary**: Frontend bundled into backend for easy distribution

**Important**: Always run commands from the project root directory. When navigating to subdirectories, use full paths to avoid getting lost.