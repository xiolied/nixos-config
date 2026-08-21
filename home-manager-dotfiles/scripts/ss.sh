#!/usr/bin/env bash

# screenshot.sh - Wayland screenshot: grim + slurp + wayfreeze + satty + libnotify

SCREENSHOT_DIR="$HOME/Screenshots"

if [ ! -d "$SCREENSHOT_DIR" ]; then
  notify-send -i "dialog-error" -t 3000 "Screenshot" "Directory missing: $SCREENSHOT_DIR"
  exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"

MODE="${1:-area}"

pkill -x slurp 2>/dev/null

_satty() {
  # No --fullscreen: satty opens as a normal window
  satty \
    --filename - \
    --output-filename "$FILE" \
    --early-exit \
    --disable-notifications \
    --copy-command "wl-copy"
}

_notify() {
  [ -f "$FILE" ] && notify-send -i "image-x-generic" -t 4000 "Screenshot saved" "$FILE"
}

case "$MODE" in
  area)
    SELECTION=$(slurp 2>/dev/null)

    if [ -z "$SELECTION" ]; then
      notify-send -i "dialog-error" -t 3000 "Screenshot" "Selection cancelled."
      exit 1
    fi

    W=$(echo "$SELECTION" | grep -oP '\d+(?=x)')
    H=$(echo "$SELECTION" | grep -oP '(?<=x)\d+')
    AREA=$(( W * H ))

    if [ "$AREA" -lt 20 ]; then
      CLICK_X=$(echo "$SELECTION" | grep -oP '^\d+')
      CLICK_Y=$(echo "$SELECTION" | grep -oP '(?<=,)\d+(?= )')

      if command -v hyprctl &>/dev/null; then
        SELECTION=$(hyprctl clients -j | python3 -c "
import sys, json
clients = json.load(sys.stdin)
cx, cy = $CLICK_X, $CLICK_Y
for c in clients:
    at = c['at']; sz = c['size']
    if at[0] <= cx <= at[0]+sz[0] and at[1] <= cy <= at[1]+sz[1]:
        print(f'{at[0]},{at[1]} {sz[0]}x{sz[1]}')
        break
" 2>/dev/null)
      fi

      [ -z "$SELECTION" ] && grim - | _satty && _notify && exit 0
    fi

    grim -g "$SELECTION" - | _satty
    ;;

  window)
    if command -v hyprctl &>/dev/null; then
      SELECTION=$(hyprctl activewindow -j | python3 -c "
import sys, json
w = json.load(sys.stdin)
at = w['at']; sz = w['size']
print(f'{at[0]},{at[1]} {sz[0]}x{sz[1]}')
")
    elif command -v swaymsg &>/dev/null; then
      SELECTION=$(swaymsg -t get_tree | python3 -c "
import sys, json
def find_focused(node):
    if node.get('focused'):
        r = node['rect']
        print(f\"{r['x']},{r['y']} {r['width']}x{r['height']}\")
        return True
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        if find_focused(child): return True
    return False
find_focused(json.load(sys.stdin))
")
    else
      notify-send -i "dialog-error" -t 3000 "Screenshot" "Window mode requires hyprctl or swaymsg."
      exit 1
    fi

    grim -g "$SELECTION" - | _satty
    ;;

  screen|output)
    grim - | _satty
    ;;

  *)
    echo "Usage: screenshot [area|window|screen]"
    exit 1
    ;;
esac

_notify
