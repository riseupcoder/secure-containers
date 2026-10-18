#!/bin/bash

podman stop -t 2 fuzzel 2>/dev/null
podman rm fuzzel 2>/dev/null

apps=$(ls "$HOME/.local/bin/" | sed 's/\.sh$//' | sort)

selection=$(echo "$apps" | podman run --rm -i \
  --name fuzzel \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-fuzzel.process \
  -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/user/1000/$WAYLAND_DISPLAY" \
  -v "$HOME/.containers/.fuzzel/.config/fuzzel/fuzzel.ini:/home/user/.config/fuzzel/fuzzel.ini:ro" \
  --userns=keep-id \
  fuzzel \
  fuzzel --dmenu)

if [ -n "$selection" ]; then
  "$HOME/.local/bin/$selection.sh"
fi   
