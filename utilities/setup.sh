#!/bin/bash

set -euo pipefail

readonly LOCAL_BIN="$HOME/.local/bin/"
readonly CDIR="$HOME/.containers" 
readonly MISC_DIR="$PWD/utilities"

###################################### Build image ############################################

CONTAINER_IMAGES=(
    "$MISC_DIR/rar/Containerfile-rar:extract-rar"
    "$MISC_DIR/git/Containerfile-git:github"
)

for image in "${CONTAINER_IMAGES[@]}"; do
    IFS=":" read -r file tag <<< "$image"

    echo "Building $tag image"

    podman build -f "$file" \
      --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
      -t "$tag"
done

###################################### Setup dirs ############################################

# git
mkdir -p "$CDIR/.git"

###################################### Setup bin files ########################################

install -m 700 "$MISC_DIR/bin/extract_rar.sh" "$LOCAL_BIN"
install -m 700 "$MISC_DIR/bin/github.sh" "$LOCAL_BIN"
