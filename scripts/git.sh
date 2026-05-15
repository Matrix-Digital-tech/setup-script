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

# ── gitleaks pre-commit hook ──────────────────────────────────────────────────
if command_exists gitleaks; then
  HOOKS_DIR="$(git config --global core.hooksPath 2>/dev/null || echo "$HOME/.config/git/hooks")"
  mkdir -p "$HOOKS_DIR"

  cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
# gitleaks — scan staged files for secrets before every commit
if command -v gitleaks &>/dev/null; then
  gitleaks protect --staged --redact --no-banner -q
  if [[ $? -ne 0 ]]; then
    echo ""
    echo "  gitleaks: potential secret detected in staged files."
    echo "  Review the output above, remove the secret, then commit again."
    echo "  To skip this check (not recommended): git commit --no-verify"
    exit 1
  fi
fi
HOOK

  chmod +x "$HOOKS_DIR/pre-commit"
  git config --global core.hooksPath "$HOOKS_DIR"
  print_success "gitleaks pre-commit hook installed — scans every commit for secrets"
  print_info "Manual scan of any repo: gitleaks detect --source . --redact"
else
  print_warning "gitleaks not found — run the brew section first, then re-run git section"
fi

# ── Commit signing (SSH via 1Password) ───────────────────────────────────────
OP_SSH_SIGN="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
if [[ -f "$OP_SSH_SIGN" ]]; then
  git config --global gpg.format ssh
  git config --global gpg.ssh.program "$OP_SSH_SIGN"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  # Use the local SSH public key as the signing key if it exists
  if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    git config --global user.signingkey "key::$(cat "$HOME/.ssh/id_ed25519.pub")"
    print_success "Commit signing enabled — key: ~/.ssh/id_ed25519.pub via 1Password"
  else
    print_success "Commit signing enabled — run the ssh section first to set the signing key"
    print_info "Then: git config --global user.signingkey 'key::$(cat ~/.ssh/id_ed25519.pub)'"
  fi
  print_info "Store your SSH key in 1Password so it's used as both auth + signing key"
else
  print_warning "1Password not found — install it first (brew section), then re-run git section"
fi

# ── GitHub auth ───────────────────────────────────────────────────────────────
print_info "Starting interactive GitHub authentication (browser will open)..."
gh auth login --web --git-protocol ssh

# ── GitHub Copilot CLI ────────────────────────────────────────────────────────
print_info "Installing GitHub Copilot CLI extension..."
gh extension install github/gh-copilot 2>/dev/null \
  && print_success "GitHub Copilot CLI installed — try: gh copilot suggest 'list files by size'" \
  || print_info "gh copilot already installed"

print_success "GitHub authentication complete"
print_info "Tip: enable GitHub Secret Scanning on your org at:"
print_info "  https://github.com/organizations/Matrix-Digital-tech/settings/security_analysis"
