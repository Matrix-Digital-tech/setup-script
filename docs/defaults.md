# Section: defaults — macOS System Preferences

**Script:** `scripts/macos-defaults.sh`
**Run directly:** `bash setup-mac.sh --section defaults`

## What it does

Applies a curated set of macOS system preferences via `defaults write` — the same values you'd set manually through System Settings, but automated and reproducible.

Finder and Dock are restarted at the end to apply changes immediately. Some settings (keyboard repeat, trackpad) require a logout or restart to take full effect.

## Settings applied

### Finder

| Setting | Value |
|---|---|
| Show all file extensions | On |
| Show hidden files (dotfiles) | On |
| Show path bar | On |
| Show status bar | On |
| Default view | List view |
| Default search scope | Current folder only |
| New window target | Home directory |
| Write `.DS_Store` on network drives | Off |
| Write `.DS_Store` on USB drives | Off |

### Keyboard

| Setting | Value |
|---|---|
| Key repeat rate | Fast (2) |
| Delay until repeat | Short (15) |
| Auto-correct spelling | Off |
| Auto-capitalize | Off |
| Smart dashes | Off |
| Smart quotes | Off |
| Auto period on double-space | Off |

Disabling auto-correct and smart quotes prevents macOS from mangling code and terminal commands you type.

### Dock

| Setting | Value |
|---|---|
| Auto-hide | On |
| Auto-hide animation speed | Fast (0.3s) |
| Show recent apps | Off |
| Minimize to app icon | On |
| Icon size | 48px |

### Screenshots

| Setting | Value |
|---|---|
| Save location | `~/Desktop/Screenshots` |
| Format | PNG |
| Drop shadow | Off |

### Trackpad

| Setting | Value |
|---|---|
| Tap to click | On |

### Activity Monitor

| Setting | Value |
|---|---|
| Show all processes | On (not just user processes) |

### TextEdit

| Setting | Value |
|---|---|
| Default format | Plain text (not Rich Text) |

### Save & Print panels

| Setting | Value |
|---|---|
| Save panel | Expanded by default |
| Print panel | Expanded by default |

### Miscellaneous

| Setting | Value |
|---|---|
| Quarantine warning for downloaded apps | Disabled |
| Battery percentage in menu bar | Shown |

## Notes

- `killall Finder` and `killall Dock` are called at the end — your Finder and Dock will briefly restart
- All settings are reversible — `defaults delete <domain> <key>` removes any individual setting
- A full logout/restart is recommended after running this section
