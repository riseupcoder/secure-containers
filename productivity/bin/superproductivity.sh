podman run --rm \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt label=type:selinux-superproductivity.process \
  --security-opt no-new-privileges \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -e GTK_A11Y=none \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro,Z \
  -v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,Z \
  -v $HOME/.containers/.superproductivity/.config/superproductivity:/home/user/.config/superProductivity:rw \
  -v $HOME/.containers/.superproductivity/.config/superproductivity:/home/user/.config/superProductivity/backups:rw \
  --userns=keep-id \
  superproductivity
