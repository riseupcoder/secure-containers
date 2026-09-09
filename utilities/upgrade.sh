#!/bin/bash

set -euo pipefail

readonly MISC_DIR="$PWD/utilities"

CONTAINER_IMAGES=(
    "$MISC_DIR/rar/Containerfile-rar:extract-rar"
    "$MISC_DIR/git/Containerfile-github:github"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
