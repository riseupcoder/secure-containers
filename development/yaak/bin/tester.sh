podman run --rm \
  --name tester \
  --read-only \
  --net springboot-net \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --security-opt label=type:selinux-yaak.process \
  --device=/dev/dri \
  --device=/dev/dri/renderD128 \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v /run/user/$(id -u)/$WAYLAND_DISPLAY:/run/user/$(id -u)/$WAYLAND_DISPLAY:ro \
  -v $HOME/.containers/.yaak/.config/app.yaak.desktop:/home/user/.config/app.yaak.desktop:rw \
  -v $HOME/.containers/.yaak/.cache:/home/user/.cache:rw \
  -v $HOME/.containers/.yaak/.local/share:/home/user/.local/share:rw \
  -v $HOME/.containers/.yaak/files:/home/user/files:ro \
  --userns=keep-id \
  tester
