#!/bin/bash
# Installation script for pls

set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*"
}

info() {
    echo -e "ℹ $*"
}

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."

    # Check for jq
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed."
        echo "  Install with: sudo pacman -S jq (Arch) or sudo apt install jq (Ubuntu)"
        exit 1
    fi
    success "jq found"

    # Check for curl
    if ! command -v curl &> /dev/null; then
        error "curl is required but not installed."
        echo "  Install with your package manager"
        exit 1
    fi
    success "curl found"

    # Check for ollama
    if ! command -v ollama &> /dev/null; then
        warning "ollama not found in PATH"
        echo "  Install from: https://ollama.ai"
        echo "  Or check if it's running as a service"
    else
        success "ollama found"
    fi
}

# Install the main engine
install_engine() {
    info "Installing pls-engine..."

    if [[ ! -f "bin/pls-engine" ]]; then
        error "bin/pls-engine not found. Are you in the correct directory?"
        exit 1
    fi

    # Copy to /usr/local/bin
    if sudo cp bin/pls-engine /usr/local/bin/; then
        sudo chmod +x /usr/local/bin/pls-engine
        success "pls-engine installed to /usr/local/bin/"
    else
        error "Failed to install pls-engine"
        exit 1
    fi
}

# Detect current shell
detect_shell() {
    local shell_name
    shell_name=$(basename "$SHELL")
    echo "$shell_name"
}

# Install shell integration
install_shell_integration() {
    local shell_name
    shell_name=$(detect_shell)

    info "Detected shell: $shell_name"

    case "$shell_name" in
        "fish")
            local config_file="$HOME/.config/fish/config.fish"
            if [[ -f "shell-integrations/fish.fish" ]]; then
                echo "" >> "$config_file"
                echo "# pls integration" >> "$config_file"
                cat shell-integrations/fish.fish >> "$config_file"
                success "Fish integration added to $config_file"
                warning "Run 'source ~/.config/fish/config.fish' to reload"
            fi
            ;;
        "bash")
            local config_file="$HOME/.bashrc"
            if [[ -f "shell-integrations/bash.sh" ]]; then
                echo "" >> "$config_file"
                echo "# pls integration" >> "$config_file"
                cat shell-integrations/bash.sh >> "$config_file"
                success "Bash integration added to $config_file"
                warning "Run 'source ~/.bashrc' to reload"
            fi
            ;;
        "zsh")
            local config_file="$HOME/.zshrc"
            if [[ -f "shell-integrations/zsh.sh" ]]; then
                echo "" >> "$config_file"
                echo "# pls integration" >> "$config_file"
                cat shell-integrations/zsh.sh >> "$config_file"
                success "Zsh integration added to $config_file"
                warning "Run 'source ~/.zshrc' to reload"
            fi
            ;;
        *)
            warning "Unknown shell: $shell_name"
            echo "  Please manually add the appropriate shell integration"
            ;;
    esac
}

# Create initial config
setup_config() {
    info "Setting up configuration..."

    local config_dir="$HOME/.config/pls"
    local config_file="$config_dir/config.json"

    mkdir -p "$config_dir"

    if [[ ! -f "$config_file" ]]; then
        if [[ -f "config/config.json.example" ]]; then
            # Remove comments from the example config to create valid JSON
            grep -v "^[[:space:]]*\/\/" config/config.json.example > "$config_file"
            success "Configuration created at $config_file"
        else
            warning "Example config not found, will be created on first run"
        fi
    else
        info "Configuration already exists at $config_file"
    fi
}

# Test installation
test_installation() {
    info "Testing installation..."

    if command -v pls-engine &> /dev/null; then
        success "pls-engine is in PATH"
    else
        error "pls-engine not found in PATH"
        exit 1
    fi

    # Test if ollama is reachable
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        success "Ollama is reachable"

        # Check for available models
        local models
        models=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")
        if [[ -n "$models" ]]; then
            success "Available models:"
            echo "$models" | sed 's/^/  /'
        else
            warning "No models found. Install one with: ollama pull codellama:13b"
        fi
    else
        warning "Ollama not reachable at localhost:11434"
        echo "  Make sure Ollama is running: ollama serve"
    fi
}

# Main installation flow
main() {
    echo "🚀 Installing pls - Natural Language Shell Commands"
    echo ""

    check_dependencies
    echo ""

    install_engine
    echo ""

    install_shell_integration
    echo ""

    setup_config
    echo ""

    test_installation
    echo ""

    success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your shell or run: source ~/.${shell_name}rc"
    echo "2. Make sure Ollama is running: ollama serve"
    echo "3. Install a model: ollama pull codellama:13b"
    echo "4. Try it: pls show me all running processes"
    echo ""
    echo "For configuration options, edit: ~/.config/pls/config.json"
}

main "$@"
