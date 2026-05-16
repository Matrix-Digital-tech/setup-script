# Section: ssh — SSH Key + 1Password Agent

**Script:** `scripts/ssh.sh`
**Run directly:** `bash setup-mac.sh --section ssh`

## What it does

Generates an SSH key, configures 1Password as the SSH agent so private keys never sit unencrypted on disk, and uploads the public key to GitHub.

## Step-by-step

### 1. Create ~/.ssh directory

Ensures `~/.ssh` exists with correct permissions (`700`).

### 2. Generate SSH key

Checks for `~/.ssh/id_ed25519`. If not present, prompts for an email address (used as the key label — typically your git email), then generates an ed25519 key pair with no passphrase. The private key is protected by 1Password in the next step instead.

If a key already exists, this step is skipped.

### 3. Configure 1Password SSH agent

Appends a `Host *` block to `~/.ssh/config` (if not already present) that routes all SSH connections through 1Password's agent socket:

```
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

This means 1Password holds and signs with private keys rather than the raw key file on disk. The `SSH_AUTH_SOCK` environment variable in `~/.zshrc` also points to the same socket (conditionally — only set if the socket exists, i.e., 1Password is running).

**Required:** After running this section, open **1Password → Settings → Developer → SSH Agent** and toggle it on.

### 4. Upload public key to GitHub

Runs `gh ssh-key add ~/.ssh/id_ed25519.pub` to register the public key on your GitHub account. The key title is set to your machine name + date (e.g. `MacBook Pro (2026-05-16)`). Skips silently if the key already exists on GitHub.

## Multiple GitHub profiles

This section sets up a single key for your primary profile. If you have multiple GitHub accounts (personal, work, CMS), each needs its own key. See the [multi-profile SSH guide](../README.md#multiple-github-profiles-personal--work--cms) in the README.

## Idempotency

Safe to re-run. Key generation and `~/.ssh/config` edits are skipped if already in place.
