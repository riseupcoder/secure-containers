podman run --rm \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-keepassxc.process \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e QT_QPA_PLATFORM=wayland \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro \
  -v $HOME/.containers/.keepassxc/.config/keepassxc:/home/user/.config/keepassxc:rw \
  -v $HOME/.containers/.keepassxc/vault:/home/user/vault:rw \
  --userns=keep-id \
  keepass
