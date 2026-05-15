#!/usr/bin/env bash
# scripts/claude.sh — Claude Code MCP configuration (Perplexity + Google Workspace)

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
  print_warning "~/.claude/settings.json not found"
  print_info "Install Claude Code first (brew install --cask claude-code), then re-run this section"
  return 0
fi

# ── Perplexity MCP ────────────────────────────────────────────────────────────
print_prompt "Enter your Perplexity API key (Enter to skip): "
read -r PERPLEXITY_KEY

if [[ -n "$PERPLEXITY_KEY" ]]; then
  python3 - "$CLAUDE_SETTINGS" "$PERPLEXITY_KEY" << 'PYTHON'
import json, sys

path, key = sys.argv[1], sys.argv[2]
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault("mcpServers", {})["perplexity"] = {
    "command": "npx",
    "args": ["-y", "@anthropic-ai/mcp-server-perplexity"],
    "env": {"PERPLEXITY_API_KEY": key}
}

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  Perplexity MCP configured")
PYTHON
  print_success "Perplexity MCP server added to Claude Code"
  print_info "Gives Claude: perplexity_search, perplexity_ask, perplexity_research, perplexity_reason"
else
  print_info "Skipped — add manually to ~/.claude/settings.json:"
  print_info '  "mcpServers": { "perplexity": { "command": "npx", "args": ["-y", "@anthropic-ai/mcp-server-perplexity"], "env": { "PERPLEXITY_API_KEY": "pplx-..." } } }'
fi

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
