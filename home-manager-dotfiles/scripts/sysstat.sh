#!/bin/sh

# 1. Date & Clock
echo "Date & Time: $(date '+%Y-%m-%d %I:%M %p')"

# 2. Battery
if [ -d /sys/class/power_supply/BAT0 ]; then
    bat_cap=$(cat /sys/class/power_supply/BAT0/capacity)
    bat_stat=$(cat /sys/class/power_supply/BAT0/status)
    echo "Battery:     $bat_cap% ($bat_stat)"
else
    echo "Battery:     N/A"
fi

# 3. Connected Wi-Fi Name
if command -v nmcli >/dev/null 2>&1; then
    wifi_name=$(nmcli -t -f DEVICE,NAME connection show --active | grep "^wlo1:" | cut -d: -f2)
    if [ -n "$wifi_name" ]; then
        echo "Wi-Fi:       $wifi_name"
    else
        echo "Wi-Fi:       Disconnected"
    fi
else
    echo "Wi-Fi:       (nmcli not found)"
fi

# 4. Volume
if command -v wpctl >/dev/null 2>&1; then
    vol_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    vol_num=$(echo "$vol_info" | awk '{print $2 * 100"%"}')
    if echo "$vol_info" | grep -q "\[MUTED\]"; then
        echo "Volume:      $vol_num [MUTED]"
    else
        echo "Volume:      $vol_num"
    fi
else
    echo "Volume:      (wpctl not found)"
fi

# 5. Connected Bluetooth Status/Name
if command -v bluetoothctl >/dev/null 2>&1; then
    bt_device=$(bluetoothctl devices Connected | awk '{print substr($0, index($0,$3))}')
    if [ -n "$bt_device" ]; then
        echo "Bluetooth:   Connected to $bt_device"
    else
        echo "Bluetooth:   Disconnected"
    fi
else
    echo "Bluetooth:   (bluetoothctl not found)"
fi
