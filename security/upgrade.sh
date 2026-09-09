#!/bin/bash

set -euo pipefail

readonly SEC_DIR="$PWD/security" 

CONTAINER_IMAGES=(
    "$SEC_DIR/Containerfile-keepassxc:keepass"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
