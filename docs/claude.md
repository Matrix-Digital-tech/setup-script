# Section: claude — Claude Code Configuration

**Script:** `scripts/claude.sh`
**Run directly:** `bash setup-mac.sh --section claude`

## What it does

Configures Claude Code by writing to `~/.claude/settings.json`. Sets the update channel to `latest`, and registers two MCP (Model Context Protocol) servers — Perplexity for web search and Google Workspace for Drive, Gmail, Calendar, and more.

Claude Code must already be installed (via the `brew` section) before this runs.

## Step-by-step

### 1. Update channel

Sets `autoUpdatesChannel` to `"latest"` so Claude Code automatically updates to the newest release rather than waiting for stable:

```json
{ "autoUpdatesChannel": "latest" }
```

### 2. Perplexity MCP server

Registers a Perplexity MCP server that Claude Code can call during conversations for real-time web search and deep research. The API key is **never stored in `settings.json`** — it's read from 1Password at the moment Claude Code launches the server:

```json
"perplexity": {
  "command": "bash",
  "args": ["-c", "PERPLEXITY_API_KEY=$(op read 'op://Development/Perplexity/api_key') npx -y @anthropic-ai/mcp-server-perplexity"]
}
```

Tools this enables inside Claude Code:

| Tool | What it does |
|---|---|
| `perplexity_search` | Fast web search with citations |
| `perplexity_ask` | AI-answered questions with sources |
| `perplexity_research` | Deep multi-source investigation |
| `perplexity_reason` | Step-by-step reasoning with web grounding |

**Prerequisite:** store your Perplexity API key in 1Password before running:

```bash
op item create --category=apikey --title="Perplexity" --vault=Development api_key=pplx-...
```

### 3. Google Workspace MCP server

Registers `gws` as an MCP server (only if `gws` is installed — run the `npm` section first):

```json
"googleworkspace": {
  "command": "gws",
  "args": ["mcp"]
}
```

This makes Drive, Gmail, Calendar, Sheets, Docs, and Chat available to Claude Code as tools. Run `gws auth` to authenticate on first use.

## Settings file

All configuration is written to `~/.claude/settings.json` using Python's `json` module to safely merge with existing settings — existing keys are preserved.

## Idempotency

Safe to re-run. The Perplexity MCP entry is always written (overwritten with the current config). The Google Workspace entry is only written if it doesn't already exist.
