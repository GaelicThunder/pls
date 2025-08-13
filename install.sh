#!/usr/bin/env bash

set -euo pipefail

GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RED="\033[0;31m"; NC="\033[0m"
ok(){ echo -e "${GREEN}✓${NC} $*"; }
warn(){ echo -e "${YELLOW}⚠${NC} $*"; }
err(){ echo -e "${RED}✗${NC} $*"; }
info(){ echo "ℹ $*"; }

want_reload=1
forced_shell="${PLS_SHELL:-}"

usage() {
  cat <<EOF
Usage: ./install.sh [--shell fish|bash|zsh] [--no-reload]
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --shell) forced_shell="$2"; shift 2 ;;
    --no-reload) want_reload=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

detect_shell() {
  # 1) forced via CLI/ENV
  if [[ -n "${forced_shell}" ]]; then
    echo "${forced_shell}"; return 0
  fi

  # 2) Check if current process is an interactive shell with TTY
  local tty
  tty="$(ps -o tty= -p $$ 2>/dev/null | awk '{print $1}')"
  if [[ -n "$tty" && "$tty" != "?" ]]; then
    local comm
    comm="$(ps -o comm= -t "$tty" 2>/dev/null | head -n1 | awk '{print tolower($0)}')"
    case "$comm" in
      *fish*) echo "fish"; return 0 ;;
      *zsh*)  echo "zsh";  return 0 ;;
      *bash*) echo "bash"; return 0 ;;
    esac
  fi

  # 3) Walk parent processes to find an interactive shell
  local p="$$"
  for _ in $(seq 1 8); do
    p="$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')"
    [[ -z "$p" ]] && break
    local comm
    comm="$(ps -o comm= -p "$p" 2>/dev/null | awk '{print tolower($0)}')"
    case "$comm" in
      *fish*) echo "fish"; return 0 ;;
      *zsh*)  echo "zsh";  return 0 ;;
      *bash*) echo "bash"; return 0 ;;
    esac
  done

  # 4) Fallback to $SHELL
  if [[ -n "${SHELL:-}" ]]; then
    case "$(basename "$SHELL" | tr '[:upper:]' '[:lower:]')" in
      fish) echo "fish"; return 0 ;;
      zsh)  echo "zsh";  return 0 ;;
      bash) echo "bash"; return 0 ;;
    esac
  fi

  # 5) Ultimate fallback
  echo "bash"
}

check_deps() {
  info "Checking dependencies..."
  command -v jq >/dev/null && ok "jq found" || { err "jq missing"; exit 1; }
  command -v curl >/dev/null && ok "curl found" || { err "curl missing"; exit 1; }
  if command -v ollama >/dev/null; then ok "ollama found"; else warn "ollama not found in PATH"; fi
}

install_engine() {
  info "Installing pls-engine..."
  [[ -f "bin/pls-engine" ]] || { err "bin/pls-engine not found (run from repo root)"; exit 1; }
  sudo cp bin/pls-engine /usr/local/bin/
  sudo chmod +x /usr/local/bin/pls-engine
  ok "pls-engine installed to /usr/local/bin/"
}

append_once() {
  # $1=file, $2=marker, $3=content
  local file="$1" marker="$2" content="$3"
  touch "$file"
  if ! grep -q "$marker" "$file"; then
    {
      echo ""
      echo "$marker"
      echo "$content"
    } >> "$file"
  fi
}

integrate_fish() {
  local cfg="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$cfg")"
  append_once "$cfg" "# pls integration" "$(cat shell-integrations/fish.fish)"
  ok "Fish integration added to $cfg"
  if [[ $want_reload -eq 1 ]] && command -v fish >/dev/null; then
    if fish -c "source $cfg" >/dev/null 2>&1; then ok "Fish config reloaded"; else warn "Could not auto-reload Fish"; fi
  fi
}

integrate_bash() {
  local cfg="$HOME/.bashrc"
  append_once "$cfg" "# pls integration" "$(cat shell-integrations/bash.sh)"
  ok "Bash integration added to $cfg"
  if [[ $want_reload -eq 1 ]] && command -v bash >/dev/null; then
    if bash -lc "source $cfg" >/dev/null 2>&1; then ok "Bash config reloaded"; else warn "Could not auto-reload Bash"; fi
  fi
}

integrate_zsh() {
  local cfg="$HOME/.zshrc"
  append_once "$cfg" "# pls integration" "$(cat shell-integrations/zsh.sh)"
  ok "Zsh integration added to $cfg"
  if [[ $want_reload -eq 1 ]] && command -v zsh >/dev/null; then
    if zsh -lc "source $cfg" >/dev/null 2>&1; then ok "Zsh config reloaded"; else warn "Could not auto-reload Zsh"; fi
  fi
}

install_integration() {
  local sh
  sh="$(detect_shell)"
  info "Detected interactive shell: $sh"
  case "$sh" in
    fish) integrate_fish ;;
    zsh)  integrate_zsh ;;
    bash) integrate_bash ;;
    *) warn "Unknown shell '$sh' — falling back to Bash"; integrate_bash ;;
  esac
}

setup_config() {
  info "Setting up configuration..."
  local dir="$HOME/.config/pls"
  local file="$dir/config.json"
  mkdir -p "$dir"
  if [[ ! -f "$file" ]]; then
    if [[ -f "config/config.json.example" ]]; then
      # strip comments // to produce valid JSON if present
      sed '/^[[:space:]]*\/\//d' config/config.json.example > "$file"
      ok "Configuration created at $file"
    else
      warn "Example config missing; engine will create defaults on first run"
    fi
  else
    info "Configuration already exists at $file"
  fi
}

test_install() {
  info "Testing installation..."
  command -v /usr/local/bin/pls-engine >/dev/null && ok "pls-engine is in PATH" || { err "pls-engine not found"; exit 1; }
  if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    ok "Ollama is reachable"
  else
    warn "Ollama not reachable at localhost:11434 (run: ollama serve)"
  fi
}

main() {
  echo "🚀 Installing pls - Natural Language Shell Commands"
  echo ""
  check_deps; echo ""
  install_engine; echo ""
  install_integration; echo ""
  setup_config; echo ""
  test_install; echo ""
  ok "Installation complete!"
  echo ""
  echo "Next steps:"
  echo "1) Open a new $([[ -n "${forced_shell}" ]] && echo "${forced_shell}" || detect_shell) tab or reload the shell"
  echo "2) Ensure Ollama is running: ollama serve"
  echo "3) Pull a model if needed: ollama pull gemma3:4b"
  echo "4) Try: pls list all docker containers"
}
main "$@"
