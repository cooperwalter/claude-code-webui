# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Code Web UI

A web-based interface for the `claude` command line tool that provides streaming responses in a chat interface.

## Memories

- There is no such thing as a portfolio report
- Always say "Knowledge Base" instead of "KB"

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

[Rest of the file remains unchanged...]