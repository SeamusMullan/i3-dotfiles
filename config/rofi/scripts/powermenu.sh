#!/bin/bash

# Power menu options
options="⏻ Shutdown\n⏾ Suspend\n⟲ Reboot\n⇠ Logout\n🔒 Lock"

# Show rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ~/.cache/wal/colors-rofi-dark.rasi)

case $chosen in
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "⏾ Suspend")
        systemctl suspend
        ;;
    "⟲ Reboot")
        systemctl reboot
        ;;
    "⇠ Logout")
        i3-msg exit
        ;;
    "🔒 Lock")
        i3lock -c 000000  # or your preferred lock command
        ;;
esac
