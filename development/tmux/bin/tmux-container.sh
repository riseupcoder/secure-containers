podman run --rm -it  \
  --name spring \
  --read-only \
  --net springboot-net \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.tmux/.config/tmux/tmux.conf:/home/user/.config/tmux/tmux.conf:ro,Z" \
  -v "$HOME/.containers/.tmux/.local/bin/run-service.sh:/home/user/.local/bin/run-service.sh:ro,Z" \
  -v "$HOME/.containers/.tmux/.local/bin/project-picker.sh:/home/user/.local/bin/project-picker.sh:ro,Z" \
  -v "$HOME/.containers/.tmux/.local/bin/spring-dev.sh:/home/user/.local/bin/spring-dev.sh:ro,Z" \
  -v "$HOME/.containers/.tmux/.m2:/home/user/.m2:rw,Z" \
  -v "$HOME/.containers/.tmux/.gradle:/home/user/.gradle:rw,Z" \
  -v "$HOME/.containers/.tmux/.cache:/home/user/.cache:rw,Z" \
  -v "$HOME/.containers/.nvim-spring/projects:/projects:rw,z" \
  -w /projects \
  -e TERM=xterm-256color \
  --userns=keep-id \
  tmux-container sh
