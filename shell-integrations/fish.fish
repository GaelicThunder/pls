# pls integration for Fish shell
# Add this to your ~/.config/fish/config.fish

function pls
    # Get the current commandline content, excluding the 'pls ' prefix
    set -l user_prompt (commandline | sed 's/^pls //')

    if test -z "$user_prompt"
        echo "Usage: pls <your natural language command>"
        commandline -r ""
        return 1
    end

    # Clear the current line since we'll replace it
    commandline -r ""

    # Call the engine with Fish as the shell type
    set -l suggested_cmd (string trim -- (pls-engine "$user_prompt" "fish" 2>/dev/null))

    # Check if we got a valid command
    if test -n "$suggested_cmd"
        # Add the suggested command to shell history
        history add -- "$suggested_cmd"

        # Put the command in the commandline buffer for editing
        commandline -r "$suggested_cmd"

        # Place cursor at the end
        commandline -C (string length "$suggested_cmd")

        echo "" # New line for cleaner output
    else
        echo "Error: Failed to generate a command" >&2
        commandline -r ""
    end
end

# Optional: Add a key binding for quick access (Ctrl+P)
bind \cp 'commandline -i "pls "; commandline -f repaint'
