#!/usr/bin/env bash
# scripts/shell.sh — Oh My Zsh + plugins + .zshrc template

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC_OUT="$HOME/.zshrc.new"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  print_info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  print_info "Oh My Zsh already installed"
fi

# Plugins
install_plugin() {
  local name="$1" url="$2"
  if [[ ! -d "$ZSH_CUSTOM/plugins/$name" ]]; then
    print_info "Installing $name..."
    git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
  else
    print_info "$name already installed"
  fi
}

install_plugin "zsh-autosuggestions"   "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
install_plugin "zsh-completions"       "https://github.com/zsh-users/zsh-completions"

# Generate .zshrc from template
print_info "Generating $ZSHRC_OUT from template..."
sed "s/{{DATE}}/$(date '+%Y-%m-%d')/" "$REPO_ROOT/templates/zshrc.template" > "$ZSHRC_OUT"

print_success "Shell setup complete"
print_info "Review the generated config and merge it into ~/.zshrc:"
print_info "  diff ~/.zshrc ~/.zshrc.new | less"
print_info "  cat ~/.zshrc.new >> ~/.zshrc   # or merge manually"
