#!/usr/bin/env bash
# setup-ubuntu.sh — Ubuntu LTS AI/ML development server setup (24.04+)
#
# Based on: Cowork AI Server Build documentation (Assembly-and-OS-Guide.md,
#           LLM-Home-Build-Final.md, Agentic_DataML_Dev_Stack_Guide.md)
#
# Usage:
#   bash setup-ubuntu.sh           # interactive — asks before each section
#   bash setup-ubuntu.sh --all     # run all sections

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# ── Guard ─────────────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Linux" ]] || ! command_exists apt; then
  print_error "This script requires Ubuntu/Debian (apt). Use setup-mac.sh for macOS."
  exit 1
fi

print_header "Ubuntu AI/ML Developer Setup"
UBUNTU_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
print_info "Target: Ubuntu $UBUNTU_CODENAME — AI-enabled development server"
echo ""

# ── Hardware detection ────────────────────────────────────────────────────────
HAS_NVIDIA=false
HAS_INTEL_ARC=false

if lspci 2>/dev/null | grep -qi nvidia; then
  HAS_NVIDIA=true
  print_info "NVIDIA GPU detected"
fi
if lspci 2>/dev/null | grep -qi "Intel.*Arc\|Intel.*Xe\|Battlemage\|Alchemist"; then
  HAS_INTEL_ARC=true
  print_info "Intel Arc GPU detected"
fi

# ── Argument parsing ──────────────────────────────────────────────────────────
RUN_ALL=false
[[ "${1:-}" == "--all" ]] && RUN_ALL=true

run_section() {
  local label="$1"
  local fn="$2"
  if $RUN_ALL || ask "Run: $label?"; then
    print_header "$label"
    $fn
  else
    print_info "Skipping: $label"
  fi
}

# ── Section: Base system ──────────────────────────────────────────────────────
section_base() {
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y \
    build-essential curl wget git zsh tmux htop unzip \
    fzf ripgrep fd-find bat jq \
    ca-certificates gnupg lsb-release software-properties-common \
    python3 python3-pip python3-venv \
    postgresql postgresql-contrib redis-server

  # bat ships as batcat on Ubuntu — alias it
  if ! command_exists bat && command_exists batcat; then
    mkdir -p ~/.local/bin
    ln -sf "$(which batcat)" ~/.local/bin/bat
  fi

  # Start DB services
  sudo systemctl enable postgresql redis-server
  sudo systemctl start  postgresql redis-server

  # gitleaks — install latest binary from GitHub releases
  if ! command_exists gitleaks; then
    print_info "Installing gitleaks..."
    GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    ARCH=$(dpkg --print-architecture)
    [[ "$ARCH" == "amd64" ]] && GL_ARCH="x64" || GL_ARCH="arm64"
    curl -sSfL \
      "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GL_ARCH}.tar.gz" \
      | sudo tar -xz -C /usr/local/bin gitleaks
  fi

  # Wire up gitleaks as a global pre-commit hook
  HOOKS_DIR="$HOME/.config/git/hooks"
  mkdir -p "$HOOKS_DIR"
  cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
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
  print_success "gitleaks installed and wired up as a global pre-commit hook"

  print_success "Base packages + PostgreSQL + Redis installed"
}

# ── Section: Zsh + shell tools ────────────────────────────────────────────────
section_zsh() {
  # Oh My Zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  # Starship prompt
  curl -sS https://starship.rs/install.sh | sh -s -- --yes

  # zoxide
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  # eza (modern ls)
  sudo apt install -y gpg
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list
  sudo apt update && sudo apt install -y eza

  # Set zsh as default shell
  chsh -s "$(which zsh)"

  # Generate .zshrc for Ubuntu
  cat > "$HOME/.zshrc.new" << 'ZSHRC'
# ~/.zshrc — Ubuntu AI/ML server

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)
source "$ZSH/oh-my-zsh.sh"

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fnm env --use-on-cd --shell zsh 2>/dev/null)"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"

alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -la'
alias cat='bat --paging=never'
alias find='fdfind'

# Intel oneAPI (Arc Pro GPU)
# source /opt/intel/oneapi/setvars.sh 2>/dev/null || true

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
ZSHRC

  print_success "Zsh + Oh My Zsh + Starship + zoxide + eza installed"
  print_info "Log out and back in for shell change. Review ~/.zshrc.new."
}

# ── Section: Git + GitHub CLI ─────────────────────────────────────────────────
section_git() {
  print_prompt "Git user name: "
  read -r GIT_NAME
  print_prompt "Git email: "
  read -r GIT_EMAIL

  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global init.defaultBranch main
  git config --global pull.rebase true

  # GitHub CLI
  if ! command_exists gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" | \
      sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install -y gh
  fi

  gh auth login --web --git-protocol ssh
  print_success "Git + GitHub CLI configured"
}

# ── Section: Node (fnm) + gws ─────────────────────────────────────────────────
section_node() {
  curl -fsSL https://fnm.vercel.app/install | bash
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env)"
  fnm install --lts && fnm use lts-latest && fnm default lts-latest
  npm install -g @googleworkspace/cli
  print_success "Node LTS + gws CLI installed — run 'gws auth' to authenticate"
}

# ── Section: Python (uv) ──────────────────────────────────────────────────────
section_python() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  print_success "uv installed — python package manager"
  print_info "Usage: uv init project && uv add pandas scikit-learn mlflow"
}

# ── Section: Docker ───────────────────────────────────────────────────────────
section_docker() {
  if command_exists docker; then
    print_info "Docker already installed"
    return
  fi

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  sudo usermod -aG docker "$USER"
  print_success "Docker installed — log out/in for group permissions"
}

# ── Section: NVIDIA driver + CUDA ─────────────────────────────────────────────
section_nvidia() {
  if ! $HAS_NVIDIA; then
    print_warning "No NVIDIA GPU detected — skipping"
    return
  fi

  print_info "NVIDIA setup for RTX 5090 (Blackwell) requires driver 570+ with Open Kernel Modules"
  print_info "Reference: Cowork/Assembly-and-OS-Guide.md Phase 10"
  echo ""

  # Blacklist nouveau
  if ! grep -q "blacklist nouveau" /etc/modprobe.d/blacklist-nouveau.conf 2>/dev/null; then
    print_info "Blacklisting nouveau driver..."
    echo "blacklist nouveau"         | sudo tee    /etc/modprobe.d/blacklist-nouveau.conf
    echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
    sudo update-initramfs -u
    print_warning "Reboot required before installing NVIDIA driver"
    print_info "After reboot, download driver 570+ from https://www.nvidia.com/Download/index.aspx"
    print_info "Then run: sudo systemctl isolate multi-user.target"
    print_info "          sudo ./NVIDIA-Linux-x86_64-570.*.run   (select: Open kernel modules)"
  else
    print_info "nouveau already blacklisted"
  fi

  if command_exists nvidia-smi; then
    print_success "nvidia-smi found: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
    # Add CUDA paths if not already present
    grep -q "cuda/bin" ~/.zshrc.local 2>/dev/null || {
      echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.zshrc.local
      echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}' >> ~/.zshrc.local
    }
  else
    print_warning "nvidia-smi not found — complete manual driver install first"
  fi
}

# ── Section: Intel Arc Pro (oneAPI + SYCL) ────────────────────────────────────
section_intel_arc() {
  if ! $HAS_INTEL_ARC; then
    print_warning "No Intel Arc GPU detected — skipping"
    return
  fi

  print_info "Installing Intel Arc Pro compute stack (oneAPI + SYCL)..."

  # Intel GPU compute runtime
  wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    sudo gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] \
    https://repositories.intel.com/gpu/ubuntu $UBUNTU_CODENAME unified" | \
    sudo tee /etc/apt/sources.list.d/intel-gpu-"$UBUNTU_CODENAME".list
  sudo apt update
  sudo apt install -y intel-opencl-icd intel-level-zero-gpu level-zero \
    intel-media-va-driver-non-free libmfx1 libmfxgen1

  # Intel oneAPI Base Toolkit
  wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    sudo gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] \
    https://apt.repos.intel.com/oneapi all main" | \
    sudo tee /etc/apt/sources.list.d/oneAPI.list
  sudo apt update
  sudo apt install -y intel-oneapi-dpcpp-cpp intel-oneapi-mkl-devel

  print_success "Intel Arc compute stack installed"
  print_info "Verify: source /opt/intel/oneapi/setvars.sh && sycl-ls"
  print_info ""
  print_info "To build llama.cpp for Arc Pro (SYCL backend):"
  print_info "  git clone https://github.com/ggerganov/llama.cpp"
  print_info "  source /opt/intel/oneapi/setvars.sh"
  print_info "  cmake -B build -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx"
  print_info "  cmake --build build --config Release -j\$(nproc)"
}

# ── Section: Ollama ───────────────────────────────────────────────────────────
section_ollama() {
  if command_exists ollama; then
    print_info "Ollama already installed — $(ollama --version)"
  else
    print_info "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl enable ollama
    sudo systemctl start ollama
  fi

  print_success "Ollama installed and running"

  if ask "Pull recommended models now? (qwen3-coder:30b, nomic-embed-text)"; then
    ollama pull nomic-embed-text
    print_info "Pulling qwen3-coder:30b (~17GB)..."
    ollama pull qwen3-coder:30b
    if ask "Pull llama3.3:70b for heavy reasoning? (~40GB)"; then
      ollama pull llama3.3:70b
    fi
  fi
}

# ── Section: Open WebUI ───────────────────────────────────────────────────────
section_open_webui() {
  if ! command_exists docker; then
    print_warning "Docker not installed — run Docker section first"
    return
  fi

  if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^open-webui$"; then
    print_info "Open WebUI container already exists"
    docker start open-webui 2>/dev/null || true
  else
    docker run -d \
      --name open-webui \
      --restart always \
      -p 3000:8080 \
      -v open-webui:/app/backend/data \
      --add-host=host.docker.internal:host-gateway \
      ghcr.io/open-webui/open-webui:main
  fi

  print_success "Open WebUI available at http://localhost:3000"
}

# ── Section: vLLM ────────────────────────────────────────────────────────────
section_vllm() {
  if ! $HAS_NVIDIA; then
    print_warning "vLLM requires NVIDIA GPU — skipping"
    return
  fi

  print_info "Installing vLLM (concurrent multi-agent inference)..."
  pip install vllm
  print_success "vLLM installed"
  print_info "Usage: python -m vllm.entrypoints.openai.api_server --model Qwen/Qwen2.5-Coder-32B-Instruct"
}

# ── Section: Agentic coding stack ─────────────────────────────────────────────
section_agentic() {
  # Aider (lightweight terminal agent)
  pip install aider-chat
  print_success "Aider installed — point at local Ollama: aider --openai-api-base http://localhost:11434/v1 --model ollama/qwen3-coder:30b"

  # OpenHands (full agentic system via Docker)
  if ask "Pull OpenHands Docker image? (~2GB)"; then
    docker pull ghcr.io/all-hands-ai/openhands:main
    print_success "OpenHands ready"
    print_info "Start: docker run -it -p 3001:3000 --add-host host.docker.internal:host-gateway ghcr.io/all-hands-ai/openhands:main"
  fi
}

# ── Section: RAG pipeline ─────────────────────────────────────────────────────
section_rag() {
  print_info "Installing RAG pipeline: LangChain + ChromaDB + Qdrant + LlamaIndex..."
  pip install \
    langchain langchain-community langchain-openai \
    chromadb qdrant-client \
    llama-index \
    sentence-transformers
  print_success "RAG stack installed"
}

# ── Section: ML / data science stack ─────────────────────────────────────────
section_ml() {
  print_info "Installing ML/data science tools..."
  pip install \
    jupyterlab \
    pandas polars \
    scikit-learn \
    mlflow \
    dvc "dvc[s3]" \
    fastapi uvicorn pydantic \
    prefect \
    ruff pytest httpx \
    unsloth

  # PyTorch — CUDA build if NVIDIA present, CPU otherwise
  if $HAS_NVIDIA && command_exists nvcc; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
  else
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
  fi

  print_success "ML stack installed (Jupyter, pandas/polars, sklearn, PyTorch, MLflow, DVC, FastAPI, Prefect)"
}

# ── Section: OpenRGB ──────────────────────────────────────────────────────────
section_openrgb() {
  print_info "Installing OpenRGB (ARGB fan/lighting control)..."
  sudo add-apt-repository -y ppa:thopiekar/openrgb
  sudo apt update && sudo apt install -y openrgb
  sudo usermod -aG i2c "$USER"
  print_success "OpenRGB installed — log out/in, then run: openrgb --detect"
}

# ── Run sections ──────────────────────────────────────────────────────────────
run_section "Base packages + PostgreSQL + Redis" section_base
run_section "Zsh + Oh My Zsh + Starship"         section_zsh
run_section "Git config + GitHub CLI"             section_git
run_section "Node.js (fnm) + gws CLI"             section_node
run_section "Python (uv)"                         section_python
run_section "Docker"                              section_docker
$HAS_NVIDIA    && run_section "NVIDIA driver + CUDA"           section_nvidia
$HAS_INTEL_ARC && run_section "Intel Arc Pro (oneAPI + SYCL)"  section_intel_arc
run_section "Ollama (local LLM inference)"        section_ollama
run_section "Open WebUI (browser interface)"      section_open_webui
$HAS_NVIDIA    && run_section "vLLM (concurrent inference)"    section_vllm
run_section "Agentic stack (Aider + OpenHands)"   section_agentic
run_section "RAG pipeline (LangChain + ChromaDB)" section_rag
run_section "ML/data science stack (Jupyter + PyTorch + MLflow)" section_ml
run_section "OpenRGB (ARGB lighting control)"     section_openrgb

# ── Local override hook ───────────────────────────────────────────────────────
if [[ -f "$HOME/.setup.local" ]]; then
  print_header "Local overrides (~/.setup.local)"
  # shellcheck source=/dev/null
  source "$HOME/.setup.local"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
print_header "Ubuntu AI/ML setup complete"
print_info "Next steps:"
echo "  1. Log out and back in (shell change + Docker/i2c groups)"
echo "  2. Authenticate gws:       gws auth"
echo "  3. Check Ollama:           ollama list"
echo "  4. Open WebUI:             http://localhost:3000"
echo "  5. Merge shell config:     diff ~/.zshrc ~/.zshrc.new"
$HAS_NVIDIA    && echo "  6. NVIDIA driver:          See Cowork/Assembly-and-OS-Guide.md Phase 10"
$HAS_INTEL_ARC && echo "  7. Verify Arc Pro:         source /opt/intel/oneapi/setvars.sh && sycl-ls"
