#!/bin/bash

set -euo pipefail

readonly READING_DIR="$ROOT_DIR/reading"

readonly READING_IMAGES=(
    "$READING_DIR/Containerfile-ebook:ebook"
    "$READING_DIR/Containerfile-pdf:pdf-reader"
)

for image in "${READING_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
