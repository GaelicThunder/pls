# pls integration for Fish shell

function pls --description "Natural language to shell command via Ollama"
    set -l debug_flag ""
    set -l version_flag ""
    set -l prompt_parts
    for arg in $argv
        if test "$arg" = "--debug"
            set debug_flag "--debug"
        else if test "$arg" = "--version" -o "$arg" = "-v"
            set version_flag "$arg"
        else
            set -a prompt_parts $arg
        end
    end

    if test -n "$version_flag" -a (count $prompt_parts) -eq 0
        pls-engine "$version_flag"
        return 0
    end

    if test (count $prompt_parts) -eq 0
        echo "Usage: pls [--debug | --version] <your natural language command>" >&2
        return 1
    end

    set -l user_prompt (string join " " $prompt_parts)

    set -l suggested_cmd (pls-engine $debug_flag "$user_prompt" "fish")

    if test -n "$suggested_cmd"
        commandline -r ""
        commandline -- "$suggested_cmd"
        echo
    else
        return 0
    end
end
