podman run --rm \
  --read-only \
  --security-opt no-new-privileges=true \
  --security-opt label=type:container_runtime_t \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro \
  -v /run/user/$(id -u)/pipewire-0:/run/user/$(id -u)/pipewire-0:ro,Z \
  -v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,Z \
  -v $HOME/.containers/.torbrowser:/home/user/tor-browser:rw,Z \
  --userns=keep-id \
  torbrowser
