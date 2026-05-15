#!/usr/bin/env bash
# scripts/npm-globals.sh — Global npm tools

# Ensure Node is available via fnm
if ! command_exists node; then
  print_info "Node not found — installing LTS via fnm..."
  eval "$(fnm env --shell bash)"
  fnm install --lts
  fnm use lts-latest
  fnm default lts-latest
fi

print_info "Node $(node --version) / npm $(npm --version)"

# ── Google Workspace CLI ──────────────────────────────────────────────────────
print_info "Installing gws (Google Workspace CLI)..."
npm install -g @googleworkspace/cli
print_success "gws installed — run 'gws auth' to authenticate"
print_info "Covers: Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin"
print_info "MCP mode: gws mcp  (works with Claude Desktop, VS Code)"

print_success "npm globals installed"
