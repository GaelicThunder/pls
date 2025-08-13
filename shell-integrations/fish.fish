# pls integration for Fish shell

function pls --description "Natural language to shell command via Ollama"
    if test (count $argv) -eq 0
        echo "Usage: pls <your natural language command>"
        return 1
    end

    # Join all arguments into a single prompt
    set -l user_prompt "$argv"

    # Call engine - it prints info to stderr and command to stdout
    set -l suggested_cmd (pls-engine "$user_prompt" "fish")

    if test -n "$suggested_cmd"
        commandline -r ''
        commandline -- "$suggested_cmd"
    else
        echo "Error: No command generated" >&2
        return 1
    end
end
