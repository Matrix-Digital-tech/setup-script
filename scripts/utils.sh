#!/usr/bin/env bash
# scripts/utils.sh — shared helper functions

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

print_header()  { echo -e "\n${BOLD}${BLUE}==> $1${RESET}"; }
print_success() { echo -e "${GREEN}✓ $1${RESET}"; }
print_info()    { echo -e "  ${BLUE}$1${RESET}"; }
print_warning() { echo -e "  ${YELLOW}⚠ $1${RESET}"; }
print_error()   { echo -e "${RED}✗ $1${RESET}" >&2; }
print_prompt()  { echo -e "\n${BOLD}${YELLOW}  ▶ $1${RESET}"; }

command_exists() { command -v "$1" &>/dev/null; }

ask() {
  local prompt="$1"
  echo ""
  echo -e "${BOLD}${YELLOW}  ▶ $prompt [y/N]${RESET} "
  read -r answer </dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}
