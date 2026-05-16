#!/usr/bin/env bash
# scripts/brew.sh — Install Homebrew and all packages via Brewfile

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Install Homebrew
if ! command_exists brew; then
  print_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH — Apple Silicon (/opt/homebrew) or Intel (/usr/local)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  print_info "Homebrew already installed — updating..."
  brew update --quiet
fi

# Install from Brewfile
print_info "Installing packages from Brewfile (skips already-installed)..."
brew bundle --file="$REPO_ROOT/Brewfile"

# fzf key bindings + shell completion
if command_exists fzf; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
fi

# Start services
brew services start postgresql@16 2>/dev/null || true
brew services start redis 2>/dev/null || true

# Manual installs (no cask)
print_header "Manual installs (no Homebrew cask)"
print_info "OpenWhispr — open source local voice dictation:"
print_info "  Download: https://openwhispr.com/download"
echo ""

print_success "Homebrew packages installed"
