#!/bin/bash

if [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
    # on battery
    swayidle - w \
        timeout 300 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"'
fi
