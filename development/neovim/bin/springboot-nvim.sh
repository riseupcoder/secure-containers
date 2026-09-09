podman run -it --rm \
  --name spring \
  --read-only \
  --net springboot-net \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.nvim-spring/.config/nvim/:/home/user/.config/nvim:Z" \
  -v "$HOME/.containers/.nvim-spring/.m2:/home/user/.m2:Z" \
  -v "$HOME/.containers/.nvim-spring/.local:/home/user/.local:Z" \
  -v "$HOME/.containers/.nvim-spring/.cache:/home/user/.cache:Z" \
  -v "$HOME/.containers/.nvim-spring/projects:/projects:Z" \
  -w /projects \
  -e TERM=xterm-256color \
  --userns=keep-id \
  nvim-spring nvim
