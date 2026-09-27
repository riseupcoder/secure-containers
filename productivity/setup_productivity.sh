#!/usr/bin/env bash

readonly PRODUCTIVITY_DIR="$PWD/productivity"
readonly PRODUCTIVITY_SECPOLICY_DIR="$PRODUCTIVITY_DIR/sepolicy"

readonly PRODUCTIVITY_IMAGES=(
    "$PRODUCTIVITY_DIR/Containerfile-superproductivity:superproductivity"
)

setup_productivity_images() {
    local image
    local file
    local tag

    for image in "${PRODUCTIVITY_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_superproductivity_dirs() {
    mkdir -p "$CDIR/.superproductivity/.config/superproductivity"
}

install_superproductivity_bin() {
    install -m 700 "$PRODUCTIVITY_DIR/bin/superproductivity.sh" "$LOCAL_BIN"
}

secpolicy_superproductivity() {
    install_selinux_policy "superproductivity_data" "$PRODUCTIVITY_SECPOLICY_DIR/superproductivity"

    install_selinux_cil "$PRODUCTIVITY_SECPOLICY_DIR/superproductivity/selinux-superproductivity.cil"
}

install_productivity_sepolicy() {
    secpolicy_superproductivity
}

setup_productivity_environment() {
    setup_productivity_images
    setup_superproductivity_dirs
    install_superproductivity_bin
}

