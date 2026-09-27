#!/usr/bin/env bash

readonly SECURITY_DIR="$PWD/security"
readonly SECURITY_SECPOLICY_DIR="$SECURITY_DIR/sepolicy"

readonly SECURITY_IMAGES=(
    "$SECURITY_DIR/Containerfile-keepassxc:keepass"
)

setup_security_images() {
    local image
    local file
    local tag

    for image in "${SECURITY_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_keepassxc_dirs() {
    mkdir -p "$CDIR/.keepassxc/.config/keepassxc"
    mkdir -p "$CDIR/.keepassxc/vault"
}

install_security_bins() {
    install -m 700 "$SECURITY_DIR/bin/keepassxc.sh" "$LOCAL_BIN"
}

secpolicy_keepassxc() {
    install_selinux_policy "keepassxc_data" "$SECURITY_SECPOLICY_DIR/keepassxc"

    install_selinux_cil "$SECURITY_SECPOLICY_DIR/keepassxc/selinux-keepassxc.cil"
}

install_security_sepolicy() {
    secpolicy_keepassxc
}

setup_security_environment() {
    setup_security_images
    setup_keepassxc_dirs
    install_security_bins
}

