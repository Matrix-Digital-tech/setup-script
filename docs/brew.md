# Section: brew — Homebrew + Packages

**Script:** `scripts/brew.sh`
**Run directly:** `bash setup-mac.sh --section brew`

## What it does

Installs Homebrew (if not already present) and uses it to install every tool, language runtime, and app defined in the `Brewfile`.

## Step-by-step

### 1. Install Homebrew

Checks whether `brew` is available. If not, downloads and runs the official Homebrew installer from `brew.sh`. After installation, immediately evals the Homebrew shell environment so `brew` is on the PATH for the rest of the script — handles both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) paths.

If Homebrew is already installed, runs `brew update --quiet` to refresh package definitions before installing.

### 2. Install packages from Brewfile

Runs `brew bundle --file=Brewfile`. Homebrew Bundle reads the `Brewfile` and installs every listed package, skipping anything already installed. The `Brewfile` is the single source of truth for every macOS tool — adding something here is all it takes to include it in future setups.

See the [Brewfile reference](#brewfile-contents) below for what's installed.

### 3. fzf key bindings

Runs the fzf post-install script to enable `Ctrl+R` (history search), `Ctrl+T` (file search), and `Alt+C` (directory jump) in the terminal. These are opt-in and not enabled by default when fzf is installed via Homebrew.

### 4. Database service reminder

Prints the commands to start/stop PostgreSQL 16 and Redis. Services are **not** auto-started — run them only when you need them:

```bash
brew services start postgresql@16 && brew services start redis
brew services stop postgresql@16  && brew services stop redis
brew services list
```

### 5. Manual install note

Prints a reminder for tools that have no Homebrew cask:

- **OpenWhispr** — local voice dictation: https://openwhispr.com/download

## Brewfile contents

| Category | Tools |
|---|---|
| Fonts | Meslo LG Nerd Font |
| Shell & Terminal | fzf, zoxide, eza, bat, fd, tldr, jq, git-delta, starship, terminal-notifier |
| Git | git, gh (GitHub CLI) |
| Languages | fnm (Node), uv (Python), go |
| Security | gnupg, pinentry-mac, 1password-cli (cask), gitleaks, 1password (cask) |
| Cloud & DevOps | awscli |
| Databases | postgresql@16, redis |
| CLI Utilities | ripgrep, rlwrap, direnv, chezmoi |
| Editors | VS Code (cask), Zed (cask) |
| AI Tools | claude-code (cask), lm-studio (cask) |
| Desktop Apps | docker, notion, google-chrome, slack, figma, rectangle, raycast, ghostty |

## Idempotency

`brew bundle` skips packages that are already installed. Running this section multiple times is safe.

## Troubleshooting

| Error | Fix |
|---|---|
| `Error: Invalid option: --no-lock` | Update Homebrew: `brew update` then re-run |
| `tap ... deprecated` | Safe to ignore — taps are now built into Homebrew 4.x |
| `formula is unreadable` | The package may have moved from formula to cask — check with `brew info <name>` |
