# Section: git — Git Config + Commit Signing + GitHub Auth

**Script:** `scripts/git.sh`
**Run directly:** `bash setup-mac.sh --section git`

## What it does

Sets your global git identity and preferences, installs a gitleaks pre-commit hook to prevent secrets from being committed, enables SSH-based commit signing via 1Password, authenticates the GitHub CLI, and installs GitHub Copilot CLI.

## Step-by-step

### 1. Git identity

Prompts for your name and email, then sets them globally:

```
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

### 2. Global git preferences

| Setting | Value | Why |
|---|---|---|
| `init.defaultBranch` | `main` | New repos default to `main` |
| `pull.rebase` | `true` | Rebase instead of merge on pull |
| `core.autocrlf` | `input` | Normalize line endings on commit |
| `core.editor` | `code --wait` | VS Code as git editor |
| `fetch.prune` | `true` | Auto-remove deleted remote branches |

### 3. git-delta (better diffs)

If `delta` is installed (it is, via the Brewfile), configures it as the git pager:

- Side-by-side diffs with line numbers
- Syntax highlighting in diffs
- Navigate between diff sections with `n`/`N`

### 4. Git aliases

| Alias | Expands to |
|---|---|
| `git st` | `git status` |
| `git lg` | `git log --oneline --graph --decorate --all` |
| `git undo` | `git reset HEAD~1 --mixed` |
| `git aliases` | List all configured aliases |

### 5. gitleaks pre-commit hook

Writes a pre-commit hook to `~/.config/git/hooks/pre-commit` and sets `core.hooksPath` to that directory globally. The hook runs `gitleaks protect --staged --redact` before every commit on every repo on the machine, blocking commits that contain detected secrets.

To bypass in an emergency (not recommended):
```bash
git commit --no-verify
```

### 6. Commit signing via 1Password

Configures git to sign all commits and tags using your SSH key via 1Password's `op-ssh-sign` binary:

```
gpg.format        = ssh
gpg.ssh.program   = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
commit.gpgsign    = true
tag.gpgsign       = true
user.signingkey   = key::<contents of ~/.ssh/id_ed25519.pub>
```

Signed commits show a **Verified** badge on GitHub. The signing key is read from `~/.ssh/id_ed25519.pub` — run the `ssh` section first so the key exists.

### 7. GitHub CLI authentication

Runs `gh auth login --web --git-protocol ssh`, which opens a browser to complete OAuth authentication with GitHub. After this, `gh` commands work without a token and git operations use SSH.

### 8. GitHub Copilot CLI

Installs the `gh copilot` extension:

```bash
gh extension install github/gh-copilot
```

Adds two shell helpers (wired up in `.zshrc` via `gh copilot alias -- zsh`):

| Command | What it does |
|---|---|
| `ghcs <task>` | Suggests a shell command for the task |
| `ghce <command>` | Explains what a command does |

## Idempotency

Git config commands are always safe to re-run (they overwrite). The pre-commit hook is overwritten each time. `gh auth login` will skip if already authenticated. `gh extension install` skips if copilot is already installed.
