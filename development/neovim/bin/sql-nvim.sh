podman run --rm \
  --read-only \
  --network sql-network \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v "$HOME/.containers/.nvim-database/.config/nvim:/home/user/.config/nvim:Z" \
  -v "$HOME/.containers/.nvim-database/.cache:/home/user/.cache:Z" \
  -v "$HOME/.containers/.nvim-database/.local:/home/user/.local:Z" \
  -v "$HOME/.containers/.nvim-database/sql:/home/user/sql:Z" \
  -e TERM=xterm-256color \
  --userns=keep-id \
  nvim-database nvim
