# Developer Setup Scripts

Modular setup scripts for AI-enabled product management and development.

## Getting started

**Fresh Mac?** Run this first — it installs git and the build tools Homebrew needs (no full Xcode download required):

```bash
xcode-select --install
```

A dialog will pop up asking to install Command Line Developer Tools — click **Install** and wait for it to finish (~5 minutes). Then clone and run:

```bash
git clone https://github.com/Matrix-Digital-tech/setup-script.git
cd setup-script
bash setup-mac.sh       # macOS
bash setup-ubuntu.sh    # Ubuntu
```

The `brew` section installs the latest Homebrew git, which replaces the system one. By the end of setup you'll have a fully up-to-date git.

**Setting up an existing machine?** Run `audit.sh` first to inventory what's already installed, then paste the output into a Claude Code session in this repo to compare against the Brewfile and scripts. See the [Auditing a machine](#auditing-a-machine) section for details.

---

## Machines supported

| Script | Target |
|---|---|
| `setup-mac.sh` | macOS (Apple Silicon or Intel) |
| `setup-ubuntu.sh` | Ubuntu LTS 24.04+ (headless server or desktop) |

## Structure

```
setup-script/
├── setup-mac.sh              # macOS entry point
├── setup-ubuntu.sh           # Ubuntu AI/ML entry point
├── Brewfile                  # All macOS packages (source of truth)
├── scripts/
│   ├── utils.sh              # Shared helpers (print_*, ask, command_exists)
│   ├── brew.sh               # Homebrew + Brewfile install
│   ├── shell.sh              # Oh My Zsh + plugins + .zshrc template
│   ├── ssh.sh                # SSH key generation + 1Password SSH agent
│   ├── git.sh                # Git global config + commit signing + GitHub auth
│   ├── macos-defaults.sh     # macOS system preferences (defaults write)
│   ├── npm-globals.sh        # Global npm tools (gws, etc.)
│   └── claude.sh             # Claude Code MCP config (Perplexity + gws)
└── templates/
    └── zshrc.template        # .zshrc template (output → ~/.zshrc.new)
```

## macOS Setup

```bash
# Interactive — asks before each section
bash setup-mac.sh

# Run everything
bash setup-mac.sh --all

# Run specific sections
bash setup-mac.sh --section brew --section shell
```

| Section | Description | Docs |
|---|---|---|
| `brew` | Installs Homebrew and all packages, apps, and fonts from the Brewfile | [→ details](docs/brew.md) |
| `shell` | Installs Oh My Zsh + plugins and generates `~/.zshrc.new` from the project template | [→ details](docs/shell.md) |
| `ssh` | Generates an ed25519 SSH key, configures the 1Password SSH agent, and uploads the public key to GitHub | [→ details](docs/ssh.md) |
| `git` | Sets global git config, installs the gitleaks pre-commit hook, enables SSH commit signing via 1Password, authenticates the GitHub CLI, and installs GitHub Copilot CLI | [→ details](docs/git.md) |
| `defaults` | Applies macOS system preferences for Finder, keyboard, Dock, screenshots, and trackpad | [→ details](docs/defaults.md) |
| `npm` | Ensures Node via fnm, installs the Google Workspace CLI (`gws`) globally | [→ details](docs/npm.md) |
| `claude` | Sets Claude Code to the latest update channel and registers Perplexity and Google Workspace MCP servers | [→ details](docs/claude.md) |
| `dotfiles` | Applies personal dotfiles from `Matrix-Digital-tech/dotfiles` via chezmoi | [→ details](docs/dotfiles.md) |

### What gets installed (macOS)

**Shell & Terminal:** Oh My Zsh, Starship, fzf, zoxide, eza, bat, fd, tldr, jq, git-delta, direnv, Meslo Nerd Font

**Editors:** VS Code, Zed

**AI Tools:** Claude Code, LM Studio, Perplexity MCP (in Claude Code), gws MCP (Google Workspace), GitHub Copilot CLI

**Languages:** fnm (Node version manager), uv (Python), Go

**Cloud & DevOps:** AWS CLI, gh CLI, Docker Desktop, 1Password + CLI

**SSH & Signing:** SSH key (ed25519) generated and uploaded to GitHub, 1Password SSH agent configured, git commit signing via SSH/1Password

**Databases:** PostgreSQL 16, Redis

**Desktop Apps:** Notion, 1Password, Google Chrome, Slack, Figma, Rectangle, Raycast, Ghostty

**Manual installs (no cask):**
- [OpenWhispr](https://openwhispr.com/download) — local voice dictation

**npm globals:** `gws` (Google Workspace CLI — Drive, Gmail, Calendar, Sheets, Docs, Chat)

### After running

**1. Merge the generated shell config**

The script writes a new config to `~/.zshrc.new` — it never overwrites your existing `~/.zshrc`. Review and merge it:

```bash
# See what's different
diff ~/.zshrc ~/.zshrc.new

# Option A — append the new config to your existing one
cat ~/.zshrc.new >> ~/.zshrc

# Option B — replace entirely (if starting fresh)
cp ~/.zshrc ~/.zshrc.backup
cp ~/.zshrc.new ~/.zshrc
```

**2. Reload your shell**

```bash
source ~/.zshrc
# or open a new terminal window
```

**3. Enable 1Password SSH agent**

Open 1Password → **Settings → Developer → SSH Agent** and toggle it on. This activates the agent socket that `~/.ssh/config` and `SSH_AUTH_SOCK` point to.

**4. Finish authentication**

```bash
gws auth        # Google Workspace CLI (Drive, Gmail, Calendar, etc.)
gh auth login   # GitHub (if you skipped the git section)
```

**5. Add your Perplexity API key to 1Password**

Store the key in 1Password, then the `.zshrc` template reads it automatically at shell startup via the `op` CLI — no plain text keys in config files.

```bash
# Store once in 1Password (replace with your actual key)
op item create --category=apikey --title="Perplexity" --vault=Development api_key=pplx-...

# Verify the path works
op read 'op://Development/Perplexity/api_key'
```

### Multiple GitHub profiles (personal + work + CMS)

The setup script generates one SSH key for your primary profile. If you have multiple GitHub accounts — e.g. personal (`github.com`), work (`github.com`), and CMS (`github.cms.gov`) — each needs its own key, because GitHub won't allow the same public key on two accounts on the same host.

**1. Generate a key per profile**

```bash
ssh-keygen -t ed25519 -C "you@personal.com" -f ~/.ssh/id_ed25519_personal -N ""
ssh-keygen -t ed25519 -C "you@work.com"     -f ~/.ssh/id_ed25519_work     -N ""
ssh-keygen -t ed25519 -C "you@cms.gov"      -f ~/.ssh/id_ed25519_cms      -N ""
```

Store each private key in 1Password (drag the file into a new SSH Key item). Once stored, you can delete the private key files from disk — 1Password's SSH agent serves them automatically.

**2. Upload each public key to the right GitHub account**

```bash
gh auth login                                          # authenticate as personal first
gh ssh-key add ~/.ssh/id_ed25519_personal.pub --title "Personal key"

gh auth login --hostname github.cms.gov               # then CMS
gh ssh-key add ~/.ssh/id_ed25519_cms.pub --title "CMS key" --hostname github.cms.gov
```

For the work account, log in to github.com as the work user and upload `id_ed25519_work.pub` via Settings → SSH keys.

**3. Add host aliases to `~/.ssh/config`**

Replace the generic `Host *` block the setup script wrote with per-profile entries:

```
# Personal GitHub
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal.pub
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Work GitHub
Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work.pub
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# CMS GitHub Enterprise
Host github.cms.gov
  HostName github.cms.gov
  User git
  IdentityFile ~/.ssh/id_ed25519_cms.pub
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Note: `IdentityFile` points to the `.pub` file — 1Password holds the private key and signs via the agent socket.

**4. Clone using the host alias**

```bash
git clone git@github-personal:porta-antiporta/repo.git
git clone git@github-work:Matrix-Digital-tech/repo.git
git clone git@github.cms.gov:org/repo.git              # uses actual hostname, no alias needed
```

For existing repos, update the remote:

```bash
git remote set-url origin git@github-work:Matrix-Digital-tech/repo.git
```

### Local overrides

- `~/.setup.local` — sourced at the end of setup. Add machine-specific install steps here without touching the repo.
- `~/.zshrc.local` — sourced at the end of `~/.zshrc`. Add machine-specific shell config here.

---

## Ubuntu Setup

```bash
bash setup-ubuntu.sh
```

Interactive — prompts before each section. Auto-detects NVIDIA and Intel Arc GPUs.

### What gets installed (Ubuntu)

**Tested on:** Ubuntu 24.04 LTS (Noble) and 26.04 LTS. Uses `$VERSION_CODENAME` throughout — no hardcoded release names.

**Base:** zsh, Oh My Zsh, Starship, zoxide, eza, ripgrep, fzf, bat, fd, jq, tmux

**Git:** git, GitHub CLI (`gh`)

**Languages:** Node (fnm), Python (uv)

**Databases:** PostgreSQL, Redis

**Docker:** Docker Engine + Compose

**GPU (auto-detected):**
- NVIDIA: Driver 570+ blacklist helper, CUDA path setup
- Intel Arc Pro: Intel GPU compute runtime + oneAPI Base Toolkit (SYCL for llama.cpp)

**AI Inference:**
- Ollama (primary — RTX GPU, CUDA)
- vLLM (concurrent multi-agent inference, NVIDIA only)
- llama.cpp SYCL backend (Intel Arc, manual build — instructions printed)

**Web UI:** Open WebUI via Docker (http://localhost:3000)

**Agentic Coding:** Aider, OpenHands

**RAG Pipeline:** LangChain, ChromaDB, Qdrant, LlamaIndex, sentence-transformers

**ML Stack:** JupyterLab, pandas, polars, scikit-learn, PyTorch, MLflow, DVC, FastAPI, Prefect, Ruff, Unsloth

**Google Workspace:** `gws` CLI — same as macOS

**RGB:** OpenRGB (for ARGB fan/lighting control — Redragon, MSI AIO, etc.)

### NVIDIA driver note

RTX 5090 (Blackwell) requires driver 570+ with Open Kernel Modules. The script blacklists nouveau and prints instructions. Manual driver download from nvidia.com required. Full instructions: `Cowork/Assembly-and-OS-Guide.md Phase 10`.

---

## Secret scanning

Two-layer protection against accidentally committing or pushing secrets.

**Layer 1 — gitleaks (local, pre-commit)**

Installed automatically by the setup scripts (Homebrew on macOS, binary on Ubuntu). Blocks any commit that contains a detected secret before it ever touches git history.

```bash
# Runs automatically on every git commit — no action needed

# Manual scan of any repo at any time
gitleaks detect --source . --redact

# Scan git history (useful on existing repos)
gitleaks detect --source . --redact --log-opts="HEAD~50..HEAD"
```

To temporarily bypass (not recommended):
```bash
git commit --no-verify
```

**Layer 2 — GitHub Secret Scanning (remote)**

GitHub scans every push and alerts you — or blocks the push entirely — if a secret pattern is detected. Free for public repos; available on private repos with GitHub Advanced Security.

Enable it for the Matrix-Digital-tech org:
1. Go to: **https://github.com/organizations/Matrix-Digital-tech/settings/security_analysis**
2. Enable **Secret scanning** and **Push protection**

Push protection means GitHub will block the push at the remote, even if the local hook was bypassed.

---

## Auditing a machine

Run `audit.sh` on any machine to generate an inventory of everything installed. Useful for finding tools on an existing machine that should be added to the setup script.

```bash
# Clone the repo first (or just download audit.sh directly)
git clone https://github.com/Matrix-Digital-tech/setup-script.git
cd setup-script

# Run and save output to a file
bash audit.sh > audit.txt

# Or pipe directly to your clipboard (macOS)
bash audit.sh | pbcopy
```

Then paste the output into a Claude Code session in this repo and ask:
> "Compare this audit output to the Brewfile and setup scripts — flag anything worth adding"

The audit covers: Homebrew formulae + casks, `/Applications`, npm globals, pip packages, uv tools, key CLI tools, GPU info, Docker containers, and Ollama models.

---

## Recommended models (Ollama)

| Model | Size | Use |
|---|---|---|
| `qwen3-coder:30b` | ~17GB | Primary coding/agent model |
| `llama3.3:70b` | ~40GB | Heavy reasoning |
| `nomic-embed-text` | small | Embeddings for RAG |
