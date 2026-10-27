#!/bin/bash

set -euo pipefail

readonly BROWSER_DIR="$ROOT_DIR/internet/browser"

BROWSER_IMAGES=(
    "$BROWSER_DIR/chromium-hardening/Containerfile-chromium:chromium"
    "$BROWSER_DIR/Containerfile-mullvad:mullvad"
#    "$BROWSER_DIR/Containerfile-torbrowser:torbrowser"
#    "$BROWSER_DIR/Containerfile-firefox:mozilla"
)

for image in "${BROWSER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" --build-arg CACHE_BUST=$(date +%s) \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done
