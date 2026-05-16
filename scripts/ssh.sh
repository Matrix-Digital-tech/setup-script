#!/usr/bin/env bash
# scripts/ssh.sh — SSH key generation + 1Password SSH agent + GitHub upload

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_CONFIG="$HOME/.ssh/config"
OP_AGENT_SOCKET="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# ── SSH key ───────────────────────────────────────────────────────────────────
if [[ ! -f "$SSH_KEY" ]]; then
  print_prompt "Email for SSH key (used as label — typically your git email): "
  read -r SSH_EMAIL </dev/tty
  ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY" -N ""
  print_success "SSH key generated: $SSH_KEY"
else
  print_info "SSH key already exists: $SSH_KEY — skipping generation"
fi

# ── 1Password SSH agent ───────────────────────────────────────────────────────
# Route all SSH through 1Password so private keys never sit on disk unencrypted.
if ! grep -q "1password\|IdentityAgent" "$SSH_CONFIG" 2>/dev/null; then
  cat >> "$SSH_CONFIG" << EOF

# 1Password SSH agent — route all SSH through 1Password
Host *
  IdentityAgent "$OP_AGENT_SOCKET"
EOF
  chmod 600 "$SSH_CONFIG"
  print_success "1Password SSH agent configured in ~/.ssh/config"
else
  print_info "SSH agent already configured in ~/.ssh/config — skipping"
fi

# ── Upload public key to GitHub ───────────────────────────────────────────────
if [[ -f "$SSH_KEY.pub" ]] && command_exists gh; then
  KEY_TITLE="$(scutil --get ComputerName 2>/dev/null || hostname) ($(date +%Y-%m-%d))"
  gh ssh-key add "$SSH_KEY.pub" --title "$KEY_TITLE" 2>/dev/null \
    && print_success "SSH public key uploaded to GitHub: $KEY_TITLE" \
    || print_info "SSH key may already exist on GitHub"
fi

print_success "SSH configuration complete"
print_info "Required: enable the SSH agent in 1Password → Settings → Developer → SSH Agent"
print_info "Keys stored in 1Password will automatically appear in the SSH agent"
