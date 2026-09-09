podman run --rm \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-foliate.process \
  -v /media/user:/media:ro,z \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro,Z \
  -v $HOME/.containers/.foliate/.config/foliate:/home/user/.config/glib-2.0/settings:rw \
  -v $HOME/.containers/.foliate/.local/share/foliate:/home/user/.local/share/com.github.johnfactotum.Foliate:rw \
  -v $HOME/.containers/.foliate/.local/share/foliate:/home/user/.local/share/com.github.johnfactotum.Foliate:rw \
  --userns=keep-id \
  ebook foliate
