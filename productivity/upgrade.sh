#!/bin/bash

set -euo pipefail

readonly MM_DIR="$PWD/productivity"

readonly CONTAINER_IMAGES=(
    "$PRODUCTIVITY_DIR/Containerfile-superproductivity:superproductivity"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
