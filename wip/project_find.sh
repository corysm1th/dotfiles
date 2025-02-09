#!/usr/bin/env bash

find_git_root() {
    local dir="$1"

    # If it's a file, get its parent directory
    if [[ -f "$dir" ]]; then
        dir=$(dirname "$dir")
    fi

    # Use git to find the root directory
    local git_root
    git_root=$(cd "$dir" && git rev-parse --show-toplevel 2>/dev/null)

    if [[ -n "$git_root" ]]; then
        basename "$git_root"
        return 0
    else
        echo ""
        return 0
    fi
}

SELECTED=$(\
    SEARCH_PATHS="${HOME}/go/src ${HOME}/src" \
    FZF_DEFAULT_COMMAND="fd -t f -t d . ${SEARCH_PATHS[@]}" \
    fzf --tmux center,80% --layout=reverse \
    --style=full \
    --preview "bat --style=numbers --color=always --line-range=:100 {}" \
    --preview-window=right:60% \
    --query "" --select-1 --exit-0 \
    --bind "ctrl-space:toggle-preview" \
    --bind "enter:accept" \
    --multi \
    --prompt "Find: ")

# Exit if nothing was selected
[[ -z "$SELECTED" ]] && exit 0

# Extract project folder name
PROJECT_NAME=$(find_git_root $SELECTED)

[[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$(basename $SELECTED)"

tmux -u new -A -s $PROJECT_NAME

