#!/usr/bin/env bash
case "$1" in
  toggle)
    if warp-cli status | grep -q "Connected"; then
      warp-cli disconnect
    else
      warp-cli connect
    fi
    ;;
  status)
    if warp-cli status | grep -q "Connected"; then
      echo '{"text": "", "class": "connected", "tooltip": "VPN On"}'
    else
      echo '{"text": "", "class": "disconnected", "tooltip": "VPN off"}'
    fi
    ;;
esac

