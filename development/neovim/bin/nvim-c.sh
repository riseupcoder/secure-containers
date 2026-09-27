podman run --rm -it \
  --read-only \
  --network=none \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.nvim-c/.config/nvim:/home/user/.config/nvim:rw,Z" \
  -v "$HOME/.containers/.nvim-c/.cache:/home/user/.cache:rw,Z" \
  -v "$HOME/.containers/.nvim-c/.local:/home/user/.local:rw,Z" \
  -v "$HOME/.containers/.nvim-c/projects:/home/user/projects:rw,Z" \
  -e TERM=xterm-256color \
  --userns=keep-id \
  nvim-c nvim
