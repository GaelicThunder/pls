# pls integration for Bash

pls() {
    local debug_flag=""
    local version_flag=""
    local prompt_parts=()

    for arg in "$@"; do
        if [[ "$arg" == "--debug" ]]; then
            debug_flag="--debug"
        elif [[ "$arg" == "--version" || "$arg" == "-v" ]]; then
            version_flag="$arg"
        else
            prompt_parts+=("$arg")
        fi
    done

    if [[ -n "$version_flag" && ${#prompt_parts[@]} -eq 0 ]]; then
        pls-engine "$version_flag"
        return 0
    fi

    if [ ${#prompt_parts[@]} -eq 0 ]; then
        echo "Usage: pls [--debug | --version] <your natural language command>" >&2
        return 1
    fi

    local user_prompt="${prompt_parts[*]}"
    local suggested_cmd
    
    if [[ -n "$debug_flag" ]]; then
        suggested_cmd="$(pls-engine "$debug_flag" "$user_prompt" "bash")"
    else
        suggested_cmd="$(pls-engine "$user_prompt" "bash")"
    fi

    if [[ -n "$suggested_cmd" ]]; then
        history -s "$suggested_cmd"
        echo
        local final_cmd="$suggested_cmd"
        read -e -p $'\e[32m>\e[0m ' -i "$suggested_cmd" final_cmd
        if [[ -n "$final_cmd" ]]; then
            history -s "$final_cmd"
            eval "$final_cmd"
        fi
    else
        return 0
    fi
}
