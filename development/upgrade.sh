#!/bin/bash

set -euo pipefail

readonly DEV_DIR="$PWD/development"

CONTAINER_IMAGES=(
    "$DEV_DIR/jetbrains/Containerfile-idea:idea"
    "$DEV_DIR/yaak/Containerfile-tester:tester"
    "$DEV_DIR/neovim/Containerfile-database:nvim-database"
    "$DEV_DIR/neovim/Containerfile-c:nvim-c"
    "$DEV_DIR/neovim/Containerfile-springboot:nvim-spring"
    "$DEV_DIR/tmux/Containerfile-tmux:tmux-container"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
