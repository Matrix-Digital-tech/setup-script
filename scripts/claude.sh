#!/usr/bin/env bash
# scripts/claude.sh — Claude Code MCP configuration (Perplexity + Google Workspace)

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
  print_warning "~/.claude/settings.json not found"
  print_info "Install Claude Code first (brew install --cask claude-code), then re-run this section"
  return 0
fi

# ── Perplexity MCP ────────────────────────────────────────────────────────────
# Key is read from 1Password at runtime — never stored in settings.json as plain text.
print_info "Configuring Perplexity MCP (key read from 1Password at runtime)..."

python3 - "$CLAUDE_SETTINGS" << 'PYTHON'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault("mcpServers", {})["perplexity"] = {
    "command": "bash",
    "args": [
        "-c",
        "PERPLEXITY_API_KEY=$(op read 'op://Development/Perplexity/api_key') npx -y @anthropic-ai/mcp-server-perplexity"
    ]
}

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  Perplexity MCP configured — key read from 1Password at runtime")
PYTHON

print_success "Perplexity MCP server configured"
print_info "Gives Claude: perplexity_search, perplexity_ask, perplexity_research, perplexity_reason"
print_info "Prereq: store your key with: op item create --category=apikey --title=Perplexity --vault=Development api_key=pplx-..."

# ── Google Workspace (gws) MCP ────────────────────────────────────────────────
if command_exists gws; then
  python3 - "$CLAUDE_SETTINGS" << 'PYTHON'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)

mcp = cfg.setdefault("mcpServers", {})
if "googleworkspace" not in mcp:
    mcp["googleworkspace"] = {"command": "gws", "args": ["mcp"]}
    print("  Google Workspace MCP configured")
else:
    print("  Google Workspace MCP already configured")

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
PYTHON
  print_info "Run 'gws auth' to authenticate with Google on first use"
else
  print_warning "gws not found — run npm-globals.sh first, then re-run this section"
fi

print_success "Claude Code MCP configuration complete"
