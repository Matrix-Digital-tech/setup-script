#!/usr/bin/env bash
# scripts/git.sh — Git global config + GitHub authentication

print_prompt "Git user name: "
read -r GIT_NAME

print_prompt "Git email: "
read -r GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.autocrlf input
git config --global core.editor "code --wait"
git config --global fetch.prune true

# git-delta for better diffs
if command_exists delta; then
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.side-by-side true
  git config --global delta.line-numbers true
fi

# Aliases
git config --global alias.st "status"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.undo "reset HEAD~1 --mixed"
git config --global alias.aliases "config --get-regexp alias"

print_success "Git configured for $GIT_NAME <$GIT_EMAIL>"

# GitHub auth
print_info "Starting interactive GitHub authentication (browser will open)..."
gh auth login --web --git-protocol ssh

print_success "GitHub authentication complete"
