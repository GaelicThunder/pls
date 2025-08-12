# pls integration for Bash
# Add this to your ~/.bashrc

pls() {
    local user_prompt="$*"

    if [[ -z "$user_prompt" ]]; then
        echo "Usage: pls <your natural language command>" >&2
        return 1
    fi

    # Call the engine with bash as the shell type
    local suggested_cmd
    suggested_cmd=$(pls-engine "$user_prompt" "bash" 2>/dev/null)

    if [[ -n "$suggested_cmd" ]]; then
        # Add to bash history
        history -s "$suggested_cmd"

        # Use read with pre-filled command for editing
        echo ""
        read -e -p "$(echo -e "\033[32m>\033[0m ") " -i "$suggested_cmd" final_cmd

        if [[ -n "$final_cmd" ]]; then
            # Add the final command to history and execute
            history -s "$final_cmd"
            eval "$final_cmd"
        fi
    else
        echo "Error: Failed to generate a command" >&2
        return 1
    fi
}

# Optional: Add a key binding for quick access (Ctrl+P)
bind -x '"\C-p": echo -n "pls "; read -e line; pls $line'
