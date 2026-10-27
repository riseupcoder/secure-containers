#!/bin/bash

set -euo pipefail

readonly MISC_DIR="$ROOT_DIR/utilities"

readonly MISC_IMAGES=(
    "$MISC_DIR/launcher/Containerfile-fuzzel:fuzzel"
    "$MISC_DIR/git/Containerfile-git:github"
#    "$MISC_DIR/rar/Containerfile-rar:extract-rar"
)

for image in "${MISC_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
