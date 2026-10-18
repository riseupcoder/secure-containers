foot -e podman run -it --rm \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.nvim-go/.config/nvim:/home/user/.config/nvim:rw,Z" \
  -v "$HOME/.containers/.nvim-go/.local:/home/user/.local:rw,Z" \
  -v "$HOME/.containers/.nvim-go/.cache:/home/user/.cache:rw,Z" \
  -v "$HOME/.containers/.nvim-go/projects:/projects:rw,Z" \
  -w /projects \
  -e TERM=xterm-256color \
  --userns=keep-id \
  nvim-golang nvim
