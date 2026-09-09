podman run --rm \
  --read-only \
  --security-opt no-new-privileges=true \
  --security-opt label=type:selinux-mullvadbrowser.process \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e MOZ_ENABLE_WAYLAND=1 \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro,Z \
  -v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,Z \
  -v "$HOME/.containers/.mullvad/.mullvad-browser:/home/user/.mullvad-browser:rw" \
  --userns=keep-id \
  --shm-size=2g \
  mullvad mullvad-browser
