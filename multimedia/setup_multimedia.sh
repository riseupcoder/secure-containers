#!/usr/bin/env bash

readonly MM_DIR="$PWD/multimedia"
readonly MM_SECPOLICY_DIR="$MM_DIR/sepolicy"

readonly MM_IMAGES=(
    "$MM_DIR/Containerfile-mpv:mpv"
)

setup_multimedia_images() {
    local image
    local file
    local tag

    for image in "${MM_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_mpv_dirs() {
    mkdir -p "$CDIR/.mpv"/.{config/glib-2.0,local/share/fonts}

    cp -r "$MM_DIR/config/mpv" "$CDIR/.mpv/.config"
    cp "$CDIR/.mpv/.config/mpv/fonts/NetflixSansMedium.ttf" "$CDIR/.mpv/.local/share/fonts/"
}

install_mpv_bin() {
    install -m 700 "$MM_DIR/bin/mpv.sh" "$LOCAL_BIN"
}

secpolicy_mpv() {
    install_selinux_policy "mpv_data" "$MM_SECPOLICY_DIR/mpv"
    install_selinux_cil "$MM_SECPOLICY_DIR/mpv/selinux-mpv.cil"
}

install_multimedia_sepolicy() {
    secpolicy_mpv
}

setup_multimedia_environment() {
    setup_multimedia_images
    setup_mpv_dirs
    install_mpv_bin
}

