# Section: dotfiles — Personal Dotfiles via chezmoi

**Script:** `scripts/dotfiles.sh`
**Run directly:** `bash setup-mac.sh --section dotfiles`

## What it does

Applies your personal dotfiles from `Matrix-Digital-tech/dotfiles` using [chezmoi](https://chezmoi.io). On first run it initializes and applies. On subsequent runs it pulls and applies any changes.

## Step-by-step

### 1. Check for chezmoi

If `chezmoi` isn't installed (it's in the Brewfile — run the `brew` section first), the script warns and exits early.

### 2. First run — init and apply

If chezmoi hasn't been initialized on this machine (`~/.local/share/chezmoi` doesn't exist):

```bash
chezmoi init --apply Matrix-Digital-tech/dotfiles
```

This clones `Matrix-Digital-tech/dotfiles` to `~/.local/share/chezmoi/`, prompts for your name and email (stored locally in `~/.config/chezmoi/chezmoi.toml` — never committed), then applies all managed files to `~/`.

### 3. Subsequent runs — update

If chezmoi is already initialized:

```bash
chezmoi update
```

Pulls the latest changes from the dotfiles repo and re-applies.

## What gets applied

| Source file | Destination | Notes |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | Full shell config |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | Name/email injected from chezmoi config |
| `dot_ssh/config` | `~/.ssh/config` | 1Password SSH agent routing |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Prompt theme and layout |
| `dot_config/git/hooks/executable_pre-commit` | `~/.config/git/hooks/pre-commit` | gitleaks secret scanning hook |

## Day-to-day chezmoi usage

```bash
# Pull latest dotfiles and apply
chezmoi update

# Edit a managed file (opens in $EDITOR, applies changes on save)
chezmoi edit ~/.zshrc

# Preview what would change before applying
chezmoi diff

# Add a new file to chezmoi management
chezmoi add ~/.config/some-tool/config

# See which files chezmoi manages
chezmoi managed
```

## Machine-specific overrides

These files are sourced by `~/.zshrc` but are never tracked in the dotfiles repo:

- **`~/.zshrc.local`** — machine-specific shell config (different PATH entries, work-only aliases, etc.)
- **`~/.setup.local`** — extra install steps sourced at the end of `setup-mac.sh`

## Dotfiles repo

Source: [Matrix-Digital-tech/dotfiles](https://github.com/Matrix-Digital-tech/dotfiles) (private)

See that repo's README for the full multi-profile SSH setup guide and details on 1Password secret management within dotfiles.
