#!/bin/bash

# Kill existing polybar instances
killall -q polybar

# Wait for processes to terminate
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo "---" | tee -a /tmp/polybar.log

# Launch polybar on each connected monitor
for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ "$monitor" = "DP-2" ]; then
        MONITOR=$monitor polybar main 2>&1 | tee -a /tmp/polybar.log & disown
    else
        MONITOR=$monitor polybar secondary 2>&1 | tee -a /tmp/polybar.log & disown
    fi
done

echo "Polybar launched on all connected monitors..."

