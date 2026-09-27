#!/usr/bin/env bash

readonly DEV_DIR="$PWD/development"
readonly SEC_DIR="$DEV_DIR/sepolicy"
readonly IDEA_DIR="$CDIR/.idea"

readonly CONTAINER_IMAGES=(
    "$DEV_DIR/jetbrains/Containerfile-idea:idea"
    "$DEV_DIR/yaak/Containerfile-tester:tester"
    "$DEV_DIR/neovim/Containerfile-database:nvim-database"
    "$DEV_DIR/neovim/Containerfile-c:nvim-c"
)

setup_dev_images() {
    local image
    local file
    local tag

    for image in "${CONTAINER_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_dev_networks() {
    podman network create sql-network 2>/dev/null || true
    podman network create springboot-net 2>/dev/null || true
}

setup_dev_dirs() {
    # jetbrains
    mkdir -p "$IDEA_DIR"/.{config,cache,local,java,m2,jdks,gradle} "$IDEA_DIR/projects"

    mkdir -p "$CDIR/.yaak"/.{config/app.yaak.desktop,cache,local/share} "$CDIR/.yaak/files"

    # neovim
    mkdir -p "$CDIR/.nvim-database"/.{cache,local,config} "$CDIR/.nvim-database/sql"
    mkdir -p "$CDIR/.nvim-c"/.{cache,local,config} "$CDIR/.nvim-c/projects"
}

install_dev_bins() {
    install -m 700 "$DEV_DIR/neovim/bin/sql-nvim.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/neovim/bin/nvim-c.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/jetbrains/bin/idea.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/yaak/bin/tester.sh" "$LOCAL_BIN"
}

setup_dev_config() {
    install -m 400 "$DEV_DIR/jetbrains/config/ideavimrc" "$IDEA_DIR/.ideavimrc"
}

secpolicy_idea() {
    install_selinux_policy "idea_data" "$SEC_DIR/idea"
    install_selinux_cil "$SEC_DIR/idea/selinux-idea.cil"
}

secpolicy_yaak() {
    install_selinux_policy "yaak_data" "$SEC_DIR/yaak"
    install_selinux_cil "$SEC_DIR/yaak/selinux-yaak.cil"
}

install_dev_sepolicy() {
    secpolicy_idea
    secpolicy_yaak
}

setup_dev_environment() {
    setup_dev_images
    setup_dev_networks
    setup_dev_dirs
    setup_dev_config
    install_dev_bins
}
