podman run --rm \
  --read-only \
  --security-opt no-new-privileges=true \
  --security-opt label=type:selinux-chromium.process \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -e GTK_A11Y=none \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro \
  -v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,Z \
  -v $HOME/.containers/.chromium/.cache:/home/user/.cache:rw \
  -v $HOME/.containers/.chromium/.config/chromium:/home/user/.config/chromium:rw \
  -v $HOME/.containers/.chromium/Downloads:/home/user/Downloads:rw \
  --userns=keep-id \
  --shm-size=4g \
  chromium
