#!/usr/bin/env bash
# scripts/dotfiles.sh — apply personal dotfiles via chezmoi

if ! command_exists chezmoi; then
  print_warning "chezmoi not found — run the brew section first, then re-run this section"
  return 0
fi

DOTFILES_REPO="Matrix-Digital-tech/dotfiles"

if [[ -d "$HOME/.local/share/chezmoi/.git" ]]; then
  print_info "chezmoi already initialized — pulling latest changes..."
  chezmoi update
else
  print_info "Initializing dotfiles from $DOTFILES_REPO..."
  chezmoi init --apply --ssh "$DOTFILES_REPO"
fi

print_success "Dotfiles applied"
print_info "Edit managed files with: chezmoi edit ~/.zshrc"
print_info "Pull future changes with: chezmoi update"
