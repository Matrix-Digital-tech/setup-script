# Section: shell — Oh My Zsh + .zshrc Template

**Script:** `scripts/shell.sh`
**Run directly:** `bash setup-mac.sh --section shell`

## What it does

Installs Oh My Zsh, three community plugins, and generates a new `.zshrc` from the project template. It never overwrites your existing `~/.zshrc` — it writes to `~/.zshrc.new` so you can review and merge at your own pace.

## Step-by-step

### 1. Install Oh My Zsh

Checks for `~/.oh-my-zsh`. If not present, downloads and runs the official Oh My Zsh installer with:
- `RUNZSH=no` — doesn't immediately restart the shell mid-script
- `CHSH=no` — doesn't change the default shell (you can do that manually with `chsh -s $(which zsh)`)

### 2. Install plugins

Clones three plugins into `~/.oh-my-zsh/custom/plugins/` (idempotent — skips if already present):

| Plugin | What it adds |
|---|---|
| `zsh-autosuggestions` | Ghost-text suggestions as you type based on history |
| `zsh-syntax-highlighting` | Real-time command highlighting (green = valid, red = invalid) |
| `zsh-completions` | Extended tab-completion for many more commands |

Additional plugins enabled in the generated `.zshrc` (built into Oh My Zsh — no install needed): `git`, `fzf`, `gh`, `docker`, `aws`, `node`, `python`.

### 3. Generate ~/.zshrc.new

Processes `templates/zshrc.template` with `sed` to replace the `{{DATE}}` placeholder with today's date, then writes the result to `~/.zshrc.new`.

The template includes:

- **Homebrew** shell env (Apple Silicon + Intel path detection)
- **Oh My Zsh** with the plugin list above
- **Starship** prompt (`eval "$(starship init zsh)"`)
- **fnm** — Node version management on `cd`
- **uv** — Python tool PATH (`~/.local/bin`)
- **zoxide** — smart `cd` with frecency ranking
- **direnv** — per-project `.envrc` auto-loading
- **1Password SSH agent** — `SSH_AUTH_SOCK` set if the agent socket exists
- **fzf** — key bindings and `fd`-powered default command
- **PostgreSQL** — `pg_dump`, `psql` etc. on PATH via `brew --prefix`
- **Modern CLI aliases** — `ls`→eza, `cat`→bat, `find`→fd
- **Git aliases** — `gs`, `gl`, `gd`
- **GitHub Copilot CLI** — `ghcs` (suggest) and `ghce` (explain) shell aliases
- **API keys** — read from 1Password at shell startup, never stored as plain text
- **Project-specific config** — CMS, Verdance, Matrix Digital aliases and functions (at the bottom)
- **Local overrides** — sources `~/.zshrc.local` if it exists

## After running

```bash
# See what's new
diff ~/.zshrc ~/.zshrc.new | less

# Option A — append to existing
cat ~/.zshrc.new >> ~/.zshrc

# Option B — replace entirely (back up first)
cp ~/.zshrc ~/.zshrc.backup && cp ~/.zshrc.new ~/.zshrc

# Reload
source ~/.zshrc
```

## Idempotency

Safe to re-run. Oh My Zsh and plugins are skipped if already installed. `~/.zshrc.new` is overwritten with a fresh copy each time.
