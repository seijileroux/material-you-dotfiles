#!/bin/bash

# command to open vscode
CODE_COMMAND_LOOP='
    while true; do
        path=$(fd -H -E .git -t f -t d | fzf \
            --prompt="Open in VS Code: " \
            --height=100% --reverse \
            --preview="bat --color=always --style=numbers {}" \
            --preview-window=right:50%:wrap)
        if [ -n "$path" ]; then
            code-oss --enable-proposed-api ms-toolsai.jupyter "$path" &
        else
            echo "Cancelled."
            exec zsh
        fi
    done
'
hyprctl dispatch workspace 1
hyprctl dispatch layoutmsg setlayout dwindle
sleep 0.1;
kitty &
hyprctl dispatch layoutmsg orientation right
sleep 0.1;
kitty --hold -e btop &
hyprctl dispatch layoutmsg orientation down
sleep 0.1;
kitty --hold -e sh -c "yazi" &
kitty --hold -e sh -c "$CODE_COMMAND_LOOP" &

