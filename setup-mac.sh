#!/usr/bin/env bash
# setup-mac.sh — macOS developer setup for AI-enabled product management & development
#
# Usage:
#   bash setup-mac.sh           # interactive — asks before each section
#   bash setup-mac.sh --all     # run all sections without prompting
#   bash setup-mac.sh --section brew --section shell   # run specific sections

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# ── Guard ─────────────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  print_error "This script is for macOS only. Use setup-ubuntu.sh for Linux."
  exit 1
fi

print_header "macOS Developer Setup"
print_info "AI-enabled product management and development"
print_info "Machine: $(scutil --get ComputerName 2>/dev/null || hostname)"
echo ""

# ── Xcode CLI Tools (required for git, brew, etc.) ───────────────────────────
if ! xcode-select -p &>/dev/null; then
  print_info "Installing Xcode Command Line Tools..."
  xcode-select --install
  print_info "Follow the installer prompt, then re-run this script."
  exit 0
fi

# ── Argument parsing ──────────────────────────────────────────────────────────
RUN_ALL=false
ONLY_SECTIONS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)     RUN_ALL=true; shift ;;
    --section) ONLY_SECTIONS+=("$2"); shift 2 ;;
    *)         shift ;;
  esac
done

# ── Section runner ────────────────────────────────────────────────────────────
run_section() {
  local label="$1"
  local script="$2"
  local key="${3:-$label}"  # optional short key for --section matching

  local should_run=false

  if $RUN_ALL; then
    should_run=true
  elif [[ ${#ONLY_SECTIONS[@]} -gt 0 ]]; then
    for s in "${ONLY_SECTIONS[@]}"; do
      [[ "$s" == "$key" ]] && should_run=true && break
    done
  else
    ask "Run: $label?" && should_run=true
  fi

  if $should_run; then
    print_header "$label"
    # shellcheck source=/dev/null
    source "$script"
  else
    print_info "Skipping: $label"
  fi
}

# ── Sections ──────────────────────────────────────────────────────────────────
run_section "Homebrew + packages (Brewfile)"        "$SCRIPT_DIR/scripts/brew.sh"          "brew"
run_section "Shell — Oh My Zsh + .zshrc template"  "$SCRIPT_DIR/scripts/shell.sh"         "shell"
run_section "Git config + GitHub auth"              "$SCRIPT_DIR/scripts/git.sh"           "git"
run_section "macOS system defaults"                 "$SCRIPT_DIR/scripts/macos-defaults.sh" "defaults"
run_section "npm globals (gws + tools)"             "$SCRIPT_DIR/scripts/npm-globals.sh"   "npm"
run_section "Claude Code MCP (Perplexity + gws)"    "$SCRIPT_DIR/scripts/claude.sh"        "claude"

# ── Local override hook ───────────────────────────────────────────────────────
if [[ -f "$HOME/.setup.local" ]]; then
  print_header "Local overrides (~/.setup.local)"
  # shellcheck source=/dev/null
  source "$HOME/.setup.local"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
print_header "Setup complete"
print_info "Next steps:"
echo "  1. Merge shell config:  diff ~/.zshrc ~/.zshrc.new"
echo "  2. Restart terminal or: source ~/.zshrc"
echo "  3. Authenticate gws:    gws auth"
echo "  4. Add Perplexity key:  echo 'export PERPLEXITY_API_KEY=pplx-...' >> ~/.zshrc.local"
echo "  5. OpenWhispr:          https://openwhispr.com/download"
echo ""
echo "  Create ~/.setup.local for machine-specific overrides (not committed to git)"
