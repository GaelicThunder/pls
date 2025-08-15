# pls integration for Zsh

pls() {
    local debug_flag=""
    local -a prompt_parts

    for arg in "$@"; do
        if [[ "$arg" == "--debug" ]]; then
            debug_flag="--debug"
        elif [[ "$arg" == "--version" || "$arg" == "-v" ]]; then
            debug_flag="$arg"
        else
            prompt_parts+=("$arg")
        fi
    done

    if [[ ${#prompt_parts[@]} -eq 0 ]]; then
        echo "Usage: pls [--debug | --version] <your natural language command>" >&2
        return 1
    fi

    local user_prompt="${(j: :)prompt_parts}"

    local suggested_cmd
    suggested_cmd="$(pls-engine "$debug_flag" "$user_prompt" "zsh")"

    if [[ -n "$suggested_cmd" ]]; then
        print -s -- "$suggested_cmd"

        echo
        local final_cmd="$suggested_cmd"
        vared -p "$(print -P '%F{green}>%f ')" final_cmd

        if [[ -n "$final_cmd" ]]; then
            print -s -- "$final_cmd"
            eval "$final_cmd"
        fi
    else
        return 0
    fi
}
