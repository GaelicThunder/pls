# pls integration for Bash
pls() {
    local user_prompt="$*"

    if [[ -z "$user_prompt" ]]; then
        echo "Usage: pls <your natural language command>" >&2
        return 1
    fi

    # Call engine
    local suggested_cmd
    suggested_cmd="$(pls-engine "$user_prompt" "bash")"

    if [[ -n "$suggested_cmd" ]]; then
        # Add to history
        history -s "$suggested_cmd"

        # Edit command with readline
        echo
        local final_cmd="$suggested_cmd"
        read -e -p $'\e[32m>\e[0m ' -i "$suggested_cmd" final_cmd

        if [[ -n "$final_cmd" ]]; then
            history -s "$final_cmd"
            eval "$final_cmd"
        fi
    else
        echo "Error: No command generated" >&2
        return 1
    fi
}
