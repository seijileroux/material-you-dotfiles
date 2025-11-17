#!/bin/bash
hyprctl dispatch workspace 1
hyprctl dispatch layoutmsg setlayout dwindle
sleep 0.1;
kitty &
hyprctl dispatch layoutmsg orientation right
sleep 0.1;
kitty -e sh -c "while true; do btop; sleep 0.1; done" &
hyprctl dispatch layoutmsg orientation down
sleep 0.1;
kitty -e sh -c "while true; do yazi; sleep 0.1; done" &
kitty -e sh -c "while true; do ~/.config/waybar/scripts/code-launcher.sh; sleep 0.1; done"  &
