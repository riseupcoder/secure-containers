#!/usr/bin/env bash

readonly BROWSER_DIR="$PWD/internet/browser"
readonly BROWSER_SECPOLICY_DIR="$BROWSER_DIR/sepolicy"

readonly BROWSER_IMAGES=(
    "$BROWSER_DIR/chromium-hardening/Containerfile-chromium:chromium"
    "$BROWSER_DIR/Containerfile-mullvad:mullvad"
#   "$BROWSER_DIR/Containerfile-torbrowser:torbrowser"
#   "$BROWSER_DIR/Containerfile-firefox:mozilla"
)

setup_browser_images() {
    local image
    local file
    local tag

    for image in "${BROWSER_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_browser_dirs() {

    # mullvad browser
    mkdir -p "$CDIR/.mullvad/.mullvad-browser"

    # chromium
    mkdir -p "$CDIR/.chromium"/.{config/chromium,cache} "$CDIR/.chromium/Downloads"

    # firefox 
    # mkdir -p "$CDIR/.firefox"/.{config/mozilla,cache} "$CDIR/.firefox/Downloads"
}

install_browser_bins() {
    install -m 700 "$BROWSER_DIR/bin/chromium.sh" "$LOCAL_BIN"
    install -m 700 "$BROWSER_DIR/bin/mullvad-browser.sh" "$LOCAL_BIN"
    # install -m 700 "$BROWSER_DIR/bin/firefox.sh" "$LOCAL_BIN"
    # install -m 700 "$BROWSER_DIR/bin/torbrowser.sh" "$LOCAL_BIN"
}

secpolicy_chromium() {
    install_selinux_policy "chromium_data" "$BROWSER_SECPOLICY_DIR/chromium"
    install_selinux_cil "$BROWSER_SECPOLICY_DIR/chromium/selinux-chromium.cil"
}

secpolicy_mullvadbrowser() {
    install_selinux_policy "mullvadbrowser_data" "$BROWSER_SECPOLICY_DIR/mullvad-browser"
    install_selinux_cil "$BROWSER_SECPOLICY_DIR/mullvad-browser/selinux-mullvadbrowser.cil"
}

secpolicy_firefox() {
    install_selinux_policy "firefox_data" "$BROWSER_SECPOLICY_DIR/firefox"
    install_selinux_cil "$BROWSER_SECPOLICY_DIR/firefox/selinux-firefox.cil"
}

install_browser_sepolicy() {
    secpolicy_chromium
    secpolicy_mullvadbrowser
    # secpolicy_firefox
}

setup_browser_environment() {
    setup_browser_images
    setup_browser_dirs
    install_browser_bins
}

