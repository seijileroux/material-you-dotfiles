#!/bin/bash
wayfreeze &
PID=$!
sleep 0.1
REGION=$(slurp)
if [ -n "$REGION" ]; then
    TEMP_FILE="$HOME/.cache/temp-screenshot.png"
    TIMESTAMP=$(date +"%Y:%m:%d-%H:%M:%S:%3N")
    SAVE_PATH="$HOME/Pictures/Screenshots/${TIMESTAMP}.png"
    grim -g "$REGION" -t png "$TEMP_FILE"
    wl-copy -t image/png < "$TEMP_FILE"
    killall wayfreeze
    satty --filename "$TEMP_FILE" --output-filename "$SAVE_PATH" --copy-command "wl-copy -t image/png" --early-exit
    rm -f "$TEMP_FILE"
else
    notify-send "Cancelled Screenshot"
fi
kill $PID 2>/dev/null
wait $PID 2>/dev/null