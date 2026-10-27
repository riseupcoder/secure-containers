#!/bin/bash

set -euo pipefail

readonly SECURITY_DIR="$ROOT_DIR/security"

readonly SECURITY_IMAGES=(
    "$SECURITY_DIR/Containerfile-keepassxc:keepass"
)

for image in "${SECURITY_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
