#!/bin/bash

set -euo pipefail

readonly PRODUCTIVITY_DIR="$ROOT_DIR/productivity"

readonly PRODUCTIVITY_IMAGES=(
    "$PRODUCTIVITY_DIR/Containerfile-superproductivity:superproductivity"
)

for image in "${PRODUCTIVITY_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
