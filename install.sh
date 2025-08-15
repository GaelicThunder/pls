#!/usr/bin/env bash

set -euo pipefail

GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"

ok(){ echo -e "${GREEN}✓${NC} $*"; }
warn(){ echo -e "${YELLOW}⚠${NC} $*"; }
err(){ echo -e "${RED}✗${NC} $*"; }
info(){ echo "ℹ $*"; }

update_shell_config() {
  local config_file="$1"
  local integration_file="$2"
  local start_marker="# pls integration start"
  local end_marker="# pls integration end"

  mkdir -p "$(dirname "$config_file")"
  touch "$config_file"

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { in_block = 1; next }
    $0 == end { in_block = 0; next }
    !in_block { print }
  ' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"

  local content; content=$(cat "$integration_file")
  {
    echo ""
    echo "$start_marker"
    echo "$content"
    echo "$end_marker"
  } >> "$config_file"
  
  ok "Integration updated for $config_file"
}

modify_configs() {
  info "Updating shell configurations..."

  update_shell_config "$HOME/.bashrc" "shell-integrations/bash.sh"
  update_shell_config "$HOME/.zshrc" "shell-integrations/zsh.sh"
  update_shell_config "$HOME/.config/fish/config.fish" "shell-integrations/fish.fish"

  echo
  info "Attempting to reload shells..."
  if command -v bash >/dev/null; then bash -lc "source $HOME/.bashrc" >/dev/null 2>&1 && ok "Bash reloaded" || warn "Could not reload Bash"; fi
  if command -v zsh &>/dev/null && [[ -f "$HOME/.zshrc" ]]; then zsh -lc "source $HOME/.zshrc" >/dev/null 2>&1 && ok "Zsh reloaded" || warn "Could not reload Zsh"; fi
  if command -v fish &>/dev/null; then fish -c "source $HOME/.config/fish/config.fish" >/dev/null 2>&1 && ok "Fish reloaded" || warn "Could not reload Fish"; fi
}

main() {
  echo "🚀 Installing/Updating pls - Natural Language Shell Commands"
  echo ""
  
  info "Checking dependencies..."
  command -v jq >/dev/null && ok "jq found" || { err "jq missing"; exit 1; }
  command -v curl >/dev/null && ok "curl found" || { err "curl missing"; exit 1; }
  echo ""

  info "Installing pls-engine..."
  [[ -f "bin/pls-engine" ]] || { err "bin/pls-engine not found (run from repo root)"; exit 1; }
  sudo cp bin/pls-engine /usr/local/bin/
  sudo chmod +x /usr/local/bin/pls-engine
  ok "pls-engine installed to /usr/local/bin/"
  echo ""

  modify_configs
  echo ""
  
  info "Setup complete!"
  echo "Please open a new terminal or reload your shell to use the updated 'pls' command."
}

main "$@"
