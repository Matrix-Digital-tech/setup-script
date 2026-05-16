# Section: npm — Global npm Tools

**Script:** `scripts/npm-globals.sh`
**Run directly:** `bash setup-mac.sh --section npm`

## What it does

Ensures Node.js is available via fnm, then installs the Google Workspace CLI (`gws`) globally. `gws` is used both as a standalone CLI and as an MCP server inside Claude Code.

## Step-by-step

### 1. Ensure Node is available

Checks whether `node` is on the PATH. If not (e.g. fnm was just installed but the shell hasn't been reloaded), it:

1. Evals `fnm env` to activate fnm in the current session
2. Installs the latest LTS Node version
3. Sets it as the default

If Node is already available, this step is skipped.

Prints the active Node and npm versions for confirmation.

### 2. Install gws (Google Workspace CLI)

```bash
npm install -g @googleworkspace/cli
```

`gws` is a CLI tool that gives you terminal access to your entire Google Workspace:

| Service | What you can do |
|---|---|
| **Drive** | Search, download, upload, share files |
| **Gmail** | Read, send, search email |
| **Calendar** | List events, create meetings |
| **Sheets** | Read and write spreadsheet data |
| **Docs** | Read and create documents |
| **Chat** | Send messages to spaces |
| **Admin** | Manage users and groups (admin accounts) |

**First-time authentication:**

```bash
gws auth
```

This opens a browser to complete OAuth with your Google account. Credentials are stored locally — you only need to do this once per machine.

**MCP mode** (used by the `claude` section):

```bash
gws mcp
```

Starts `gws` as an MCP server, making all Google Workspace tools available inside Claude Code via natural language.

## Idempotency

`npm install -g` upgrades to the latest version if already installed. Safe to re-run.
