podman run --rm -it \
  --read-only \
  --cap-drop=ALL \
   --net springboot-net \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.nvim-spring/.config/nvim/:/home/user/.config/nvim:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/.m2:/home/user/.m2:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/.gradle:/home/user/.gradle:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/.local:/home/user/.local:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/.cache:/home/user/.cache:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/projects:/projects:rw,z" \
  -w /projects \
  -e TERM=xterm-256color \
  --userns=keep-id \
  nvim-spring nvim
