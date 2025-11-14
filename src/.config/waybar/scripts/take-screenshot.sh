#!/bin/bash
wayfreeze &
PID=$!
sleep 0.1
REGION=$(slurp)
if [ -n "$REGION" ]; then
    grim -g "$REGION" -t png - | wl-copy -t image/png
    notify-send "Screenshot copied to clipboard"
else
    notify-send "Cancelled Screenshot"
fi
kill $PID 2>/dev/null
wait $PID 2>/dev/null