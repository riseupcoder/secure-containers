#!/bin/bash

set -euo pipefail

readonly MISC_DIR="$ROOT_DIR/utilities"
readonly MISC_SEC_DIR="$MISC_DIR/sepolicy"

readonly MISC_IMAGES=(
    "$MISC_DIR/launcher/Containerfile-fuzzel:fuzzel"
    "$MISC_DIR/git/Containerfile-git:github"
#    "$MISC_DIR/rar/Containerfile-rar:extract-rar"
)

setup_util_images() {

    for image in "${MISC_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        echo "Building $tag image"

        podman build -f "$file" \
          --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
          -t "$tag"
    done
}

setup_dirs() {

    # git
    mkdir -p "$CDIR/.git"

    # fuzzel
    mkdir -p "$CDIR/.fuzzel/.config/fuzzel"
}

setup_config() {
    # fuzzel
    install -m 400 "$MISC_DIR/launcher/config/fuzzel/fuzzel.ini" "$CDIR/.fuzzel/.config/fuzzel/"
}

install_util_bins() {
    install -m 700 "$MISC_DIR/bin/github.sh" "$LOCAL_BIN"
    install -m 700 "$MISC_DIR/bin/fuzzel.sh" "$LOCAL_BIN"
    # install -m 700 "$MISC_DIR/bin/extract_rar.sh" "$LOCAL_BIN"
}

secpolicy_fuzzel() {
    install_selinux_policy "fuzzel_data" "$MISC_SEC_DIR/fuzzel"
    install_selinux_cil "$MISC_SEC_DIR/fuzzel/selinux-fuzzel.cil"
}

install_util_sepolicy() {
    secpolicy_fuzzel
}

setup_util_environment() {
    setup_util_images
    setup_dirs
    setup_config
    install_util_bins
}
