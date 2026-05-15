# Brewfile — all macOS packages for AI-enabled dev setup
# Run: brew bundle --file=Brewfile
# Install via setup-mac.sh or directly: brew bundle

tap "homebrew/bundle"
tap "homebrew/cask-fonts"

# ── Fonts ─────────────────────────────────────────────────────────────────────
cask "font-meslo-lg-nerd-font"

# ── Shell & Terminal ──────────────────────────────────────────────────────────
brew "fzf"
brew "zoxide"
brew "eza"
brew "bat"
brew "fd"
brew "tldr"
brew "jq"
brew "git-delta"
brew "starship"
brew "terminal-notifier"

# ── Git ───────────────────────────────────────────────────────────────────────
brew "git"
brew "gh"

# ── Languages & Runtimes ──────────────────────────────────────────────────────
brew "fnm"          # Node version manager (replaces raw node install)
brew "uv"           # Python package manager (replaces pip/pyenv/poetry)
brew "go"

# ── Security ──────────────────────────────────────────────────────────────────
brew "gnupg"
brew "pinentry-mac"
brew "1password-cli"
brew "gitleaks"       # secret scanning — pre-commit hook + manual scans
cask "1password"

# ── Cloud & DevOps ────────────────────────────────────────────────────────────
brew "awscli"

# ── Databases (local dev) ─────────────────────────────────────────────────────
brew "postgresql@16"
brew "redis"

# ── CLI Utilities ─────────────────────────────────────────────────────────────
brew "ripgrep"
brew "rlwrap"
brew "direnv"          # per-project env vars via .envrc files
brew "chezmoi"         # dotfiles manager

# ── Editors & IDEs ────────────────────────────────────────────────────────────
cask "visual-studio-code"
cask "zed"

# ── AI Tools ──────────────────────────────────────────────────────────────────
cask "claude-code"
cask "lm-studio"

# ── Desktop Apps ──────────────────────────────────────────────────────────────
cask "docker"
cask "notion"
cask "google-chrome"
cask "slack"
cask "figma"
cask "rectangle"
cask "raycast"
cask "ghostty"

# NOTE: The following require manual install (no cask available):
#   - OpenWhispr:  https://openwhispr.com/download
#   - Perplexity:  https://perplexity.ai (web app — no desktop installer)
#   - opencode:    installed separately via npm/binary
