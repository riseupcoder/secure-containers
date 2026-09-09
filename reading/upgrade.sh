#!/bin/bash

set -euo pipefail

readonly DOC_DIR="$PWD/reading"

CONTAINER_IMAGES=(
    "$DOC_DIR/Containerfile-ebook:ebook"
    "$DOC_DIR/Containerfile-pdf:pdf-reader"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
