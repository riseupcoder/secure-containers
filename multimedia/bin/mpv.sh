podman run --rm -it \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-mpv.process \
  -v /media/user:/media:ro,z \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -e RADV_PERFTEST=video_decode \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro,Z \
  -v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,Z \
  -v $HOME/.containers/.mpv/.config:/home/user/.config:ro \
  -v $HOME/.containers/.mpv/.config/glib-2.0:/home/user/.config/glib-2.0/:rw \
  -v $HOME/.containers/.mpv/.local/share:/home/user/.local/share/:ro \
  --userns=keep-id \
  mpv sh
