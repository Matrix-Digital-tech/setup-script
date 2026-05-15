#!/usr/bin/env bash
# audit.sh — inventory what's installed on this machine
# Run this on any machine, then share the output with Claude to find gaps
# in the setup script.
#
# Usage:
#   bash audit.sh              # prints to stdout
#   bash audit.sh > audit.txt  # saves to file (recommended for sharing)

set -euo pipefail

OS="$(uname)"
REPORT_DATE="$(date '+%Y-%m-%d %H:%M')"

hr() { echo ""; echo "────────────────────────────────────────"; }

echo "# Machine Audit Report"
echo "# Generated: $REPORT_DATE"
echo "# Hostname:  $(hostname)"
echo "# OS:        $OS $(uname -r)"

# ── macOS ─────────────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  echo "# macOS:     $(sw_vers -productVersion)"
  echo "# Chip:      $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown)"

  hr; echo "## Homebrew formulae"
  if command -v brew &>/dev/null; then
    brew list --formulae 2>/dev/null || echo "(none)"
  else
    echo "(homebrew not installed)"
  fi

  hr; echo "## Homebrew casks"
  if command -v brew &>/dev/null; then
    brew list --casks 2>/dev/null || echo "(none)"
  else
    echo "(homebrew not installed)"
  fi

  hr; echo "## /Applications"
  ls /Applications/ 2>/dev/null | sed 's/\.app$//' | sort || echo "(empty)"

  hr; echo "## npm globals"
  if command -v npm &>/dev/null; then
    npm list -g --depth=0 2>/dev/null | tail -n +2 || echo "(none)"
  else
    echo "(npm not installed)"
  fi

  hr; echo "## pip packages (user)"
  if command -v pip3 &>/dev/null; then
    pip3 list --user 2>/dev/null || echo "(none)"
  else
    echo "(pip3 not installed)"
  fi

  hr; echo "## uv tools"
  if command -v uv &>/dev/null; then
    uv tool list 2>/dev/null || echo "(none)"
  else
    echo "(uv not installed)"
  fi

  hr; echo "## Shell"
  echo "Default shell: $SHELL"
  echo "Zsh version:   $(zsh --version 2>/dev/null || echo not installed)"
  [[ -d ~/.oh-my-zsh ]] && echo "Oh My Zsh:     installed" || echo "Oh My Zsh:     not installed"
  command -v starship &>/dev/null && echo "Starship:      $(starship --version)" || echo "Starship:      not installed"

  hr; echo "## Key CLI tools"
  for tool in git gh aws docker fnm node npm uv go python3 rg fzf bat eza fd zoxide jq tldr delta gws claude opencode kion ollama; do
    if command -v "$tool" &>/dev/null; then
      version=$("$tool" --version 2>/dev/null | head -1 || echo "installed")
      printf "  %-12s %s\n" "$tool" "$version"
    else
      printf "  %-12s %s\n" "$tool" "(not installed)"
    fi
  done

  hr; echo "## macOS system info"
  echo "RAM:     $(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))GB"
  echo "Disk:    $(df -h / | awk 'NR==2 {print $4 " free of " $2}')"
  echo "Xcode CLI: $(xcode-select -p 2>/dev/null || echo 'not installed')"
fi

# ── Linux / Ubuntu ────────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  . /etc/os-release 2>/dev/null || true
  echo "# Distro:    ${PRETTY_NAME:-unknown}"

  hr; echo "## apt packages (manually installed)"
  apt-mark showmanual 2>/dev/null | sort || echo "(apt not available)"

  hr; echo "## snap packages"
  snap list 2>/dev/null || echo "(snap not available)"

  hr; echo "## npm globals"
  if command -v npm &>/dev/null; then
    npm list -g --depth=0 2>/dev/null | tail -n +2 || echo "(none)"
  else
    echo "(npm not installed)"
  fi

  hr; echo "## pip packages (user)"
  if command -v pip3 &>/dev/null; then
    pip3 list --user 2>/dev/null || echo "(none)"
  else
    echo "(pip3 not installed)"
  fi

  hr; echo "## uv tools"
  if command -v uv &>/dev/null; then
    uv tool list 2>/dev/null || echo "(none)"
  else
    echo "(uv not installed)"
  fi

  hr; echo "## Docker containers + images"
  if command -v docker &>/dev/null; then
    echo "--- containers ---"
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || echo "(none)"
    echo "--- images ---"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "(none)"
  else
    echo "(docker not installed)"
  fi

  hr; echo "## GPU"
  if command -v nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null || echo "(nvidia-smi error)"
  else
    echo "NVIDIA: not detected"
  fi
  lspci 2>/dev/null | grep -i "vga\|display\|3d" || echo "(lspci not available)"

  hr; echo "## Ollama models"
  if command -v ollama &>/dev/null; then
    ollama list 2>/dev/null || echo "(none)"
  else
    echo "(ollama not installed)"
  fi

  hr; echo "## Key CLI tools"
  for tool in git gh aws docker fnm node npm uv go python3 rg fzf bat eza fd zoxide jq tldr gws ollama aider; do
    if command -v "$tool" &>/dev/null; then
      version=$("$tool" --version 2>/dev/null | head -1 || echo "installed")
      printf "  %-12s %s\n" "$tool" "$version"
    else
      printf "  %-12s %s\n" "$tool" "(not installed)"
    fi
  done

  hr; echo "## System info"
  echo "RAM:     $(free -h | awk '/^Mem:/ {print $2}')"
  echo "Disk:    $(df -h / | awk 'NR==2 {print $4 " free of " $2}')"
  echo "CPU:     $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
  echo "Kernel:  $(uname -r)"
fi

hr
echo ""
echo "# Paste this output into Claude and ask:"
echo "# 'Compare this to my setup-script repo and flag anything worth adding'"
