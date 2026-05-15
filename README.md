# Developer Setup Scripts

Modular setup scripts for AI-enabled product management and development.

## Machines supported

| Script | Target |
|---|---|
| `setup-mac.sh` | macOS (Apple Silicon or Intel) |
| `setup-ubuntu.sh` | Ubuntu LTS 24.04+ (headless server or desktop) |

## Structure

```
setup-script/
├── setup-mac.sh              # macOS entry point
├── setup-ubuntu.sh           # Ubuntu AI/ML entry point
├── Brewfile                  # All macOS packages (source of truth)
├── scripts/
│   ├── utils.sh              # Shared helpers (print_*, ask, command_exists)
│   ├── brew.sh               # Homebrew + Brewfile install
│   ├── shell.sh              # Oh My Zsh + plugins + .zshrc template
│   ├── git.sh                # Git global config + GitHub auth
│   ├── macos-defaults.sh     # macOS system preferences (defaults write)
│   ├── npm-globals.sh        # Global npm tools (gws, etc.)
│   └── claude.sh             # Claude Code MCP config (Perplexity + gws)
└── templates/
    └── zshrc.template        # .zshrc template (output → ~/.zshrc.new)
```

## macOS Setup

```bash
# Interactive — asks before each section
bash setup-mac.sh

# Run everything
bash setup-mac.sh --all

# Run specific sections
bash setup-mac.sh --section brew --section shell
```

Available sections: `brew`, `shell`, `git`, `defaults`, `npm`, `claude`

### What gets installed (macOS)

**Shell & Terminal:** Oh My Zsh, Starship, fzf, zoxide, eza, bat, fd, tldr, jq, git-delta, Meslo Nerd Font

**Editors:** VS Code, Zed

**AI Tools:** Claude Code, LM Studio, Perplexity MCP (in Claude Code), gws MCP (Google Workspace)

**Languages:** fnm (Node version manager), uv (Python), Go

**Cloud & DevOps:** AWS CLI, gh CLI, Docker Desktop, 1Password + CLI

**Databases:** PostgreSQL 16, Redis

**Desktop Apps:** Notion, 1Password, Google Chrome, Slack, Figma, Rectangle, Raycast, Ghostty

**Manual installs (no cask):**
- [OpenWhispr](https://openwhispr.com/download) — local voice dictation

**npm globals:** `gws` (Google Workspace CLI — Drive, Gmail, Calendar, Sheets, Docs, Chat)

### After running

1. Merge shell config: `diff ~/.zshrc ~/.zshrc.new`
2. Restart terminal or `source ~/.zshrc`
3. Authenticate Google Workspace CLI: `gws auth`
4. Add Perplexity API key to `~/.zshrc.local`: `export PERPLEXITY_API_KEY=pplx-...`

### Local overrides

Create `~/.setup.local` for machine-specific config. It's sourced at the end of setup and is not committed to this repo. Create `~/.zshrc.local` for shell overrides — it's sourced at the end of the generated `.zshrc`.

---

## Ubuntu Setup

```bash
bash setup-ubuntu.sh
```

Interactive — prompts before each section. Auto-detects NVIDIA and Intel Arc GPUs.

### What gets installed (Ubuntu)

**Tested on:** Ubuntu 24.04 LTS (Noble) and 26.04 LTS. Uses `$VERSION_CODENAME` throughout — no hardcoded release names.

**Base:** zsh, Oh My Zsh, Starship, zoxide, eza, ripgrep, fzf, bat, fd, jq, tmux

**Git:** git, GitHub CLI (`gh`)

**Languages:** Node (fnm), Python (uv)

**Databases:** PostgreSQL, Redis

**Docker:** Docker Engine + Compose

**GPU (auto-detected):**
- NVIDIA: Driver 570+ blacklist helper, CUDA path setup
- Intel Arc Pro: Intel GPU compute runtime + oneAPI Base Toolkit (SYCL for llama.cpp)

**AI Inference:**
- Ollama (primary — RTX GPU, CUDA)
- vLLM (concurrent multi-agent inference, NVIDIA only)
- llama.cpp SYCL backend (Intel Arc, manual build — instructions printed)

**Web UI:** Open WebUI via Docker (http://localhost:3000)

**Agentic Coding:** Aider, OpenHands

**RAG Pipeline:** LangChain, ChromaDB, Qdrant, LlamaIndex, sentence-transformers

**ML Stack:** JupyterLab, pandas, polars, scikit-learn, PyTorch, MLflow, DVC, FastAPI, Prefect, Ruff, Unsloth

**Google Workspace:** `gws` CLI — same as macOS

**RGB:** OpenRGB (for ARGB fan/lighting control — Redragon, MSI AIO, etc.)

### NVIDIA driver note

RTX 5090 (Blackwell) requires driver 570+ with Open Kernel Modules. The script blacklists nouveau and prints instructions. Manual driver download from nvidia.com required. Full instructions: `Cowork/Assembly-and-OS-Guide.md Phase 10`.

---

## Recommended models (Ollama)

| Model | Size | Use |
|---|---|---|
| `qwen3-coder:30b` | ~17GB | Primary coding/agent model |
| `llama3.3:70b` | ~40GB | Heavy reasoning |
| `nomic-embed-text` | small | Embeddings for RAG |
