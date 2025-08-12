# pls integration for Zsh  
# Add this to your ~/.zshrc

pls() {
    local user_prompt="$*"

    if [[ -z "$user_prompt" ]]; then
        echo "Usage: pls <your natural language command>" >&2
        return 1
    fi

    # Call the engine with zsh as the shell type
    local suggested_cmd
    suggested_cmd=$(pls-engine "$user_prompt" "zsh" 2>/dev/null)

    if [[ -n "$suggested_cmd" ]]; then
        # Add to zsh history
        print -s "$suggested_cmd"

        # Use vared for editing (similar to original uwu)
        local final_cmd="$suggested_cmd"
        echo ""
        vared -p "$(print -P "%F{green}>%f ") " final_cmd

        if [[ -n "$final_cmd" ]]; then
            # Add final command to history and execute
            print -s "$final_cmd" 
            eval "$final_cmd"
        fi
    else
        echo "Error: Failed to generate a command" >&2
        return 1
    fi
}

# Optional: Add a key binding for quick access (Ctrl+P)
autoload -U edit-command-line
zle -N edit-command-line
pls-widget() {
    BUFFER="pls "
    CURSOR=$#BUFFER
}
zle -N pls-widget
bindkey '^P' pls-widget
