#!/bin/bash

set -euo pipefail

readonly MM_DIR="$PWD/multimedia"

CONTAINER_IMAGES=(
    "$MM_DIR/Containerfile-mpv:mpv"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
