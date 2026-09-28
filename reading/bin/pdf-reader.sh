podman run --rm -it \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-pdf.process \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro \
  -v /media/user:/media:ro \
  -v $HOME/.containers/.pdf/.config/glib-2.0/settings:/home/user/.config/glib-2.0/settings:rw,Z \
  -v "$HOME/.containers/.pdf/.config/nnn:/home/user/.config/nnn:rw,Z" \
  -v "$HOME/.containers/.pdf/.cache:/home/user/.cache:rw,Z" \
  --userns=keep-id \
  pdf-reader nnn
