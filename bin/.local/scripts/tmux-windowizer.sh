#!/usr/bin/env bash

# Select directory with fzf if not provided as an argument
selected="${1:-$(find -L ~/.config ~/Code -mindepth 1 -maxdepth 2 -type d | fzf)}"
[ -z "$selected" ] && exit 0  # Exit if no directory is selected

window_name=$(basename "$selected" | tr . _)

# Start tmux if not already running
if [ -z "$TMUX" ]; then
    # Start a new session with a generic name, setting only the window name
    tmux new-session -A -n "$window_name" -c "$selected"
else
    # Create a new window with the selected directory name
    tmux new-window -n "$window_name" -c "$selected"
    tmux select-window -t "$window_name"
fi
