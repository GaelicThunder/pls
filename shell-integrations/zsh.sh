# pls integration for Zsh

pls() {
    local user_prompt="$*"

    if [[ -z "$user_prompt" ]]; then
        echo "Usage: pls <your natural language command>" >&2
        return 1
    fi

    # Call engine
    local suggested_cmd
    suggested_cmd="$(pls-engine "$user_prompt" "zsh")"

    if [[ -n "$suggested_cmd" ]]; then
        # Add to Zsh history
        print -s -- "$suggested_cmd"

        # Edit with vared
        echo
        local final_cmd="$suggested_cmd"
        vared -p "$(print -P '%F{green}>%f ')" final_cmd

        if [[ -n "$final_cmd" ]]; then
            print -s -- "$final_cmd"
            eval "$final_cmd"
        fi
    else
        echo "Error: No command generated" >&2
        return 1
    fi
}
