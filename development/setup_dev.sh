#!/usr/bin/env bash

readonly DEV_DIR="$PWD/development"
readonly SEC_DIR="$DEV_DIR/sepolicy"
readonly IDEA_DIR="$CDIR/.idea"

readonly CONTAINER_IMAGES=(
    "$DEV_DIR/jetbrains/Containerfile-idea:idea"
    "$DEV_DIR/yaak/Containerfile-tester:tester"
    "$DEV_DIR/neovim/Containerfile-database:nvim-database"
    "$DEV_DIR/neovim/Containerfile-c:nvim-c"
    "$DEV_DIR/neovim/Containerfile-springboot:nvim-spring"
    "$DEV_DIR/tmux/Containerfile-tmux:tmux-container"
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
    podman network create springboot-net
}

setup_dev_dirs() {

    # jetbrains
    mkdir -p "$IDEA_DIR"/.{config,cache,local,java,m2,jdks,gradle} "$IDEA_DIR/projects"

    # tester
    mkdir -p "$CDIR/.yaak"/.{config/app.yaak.desktop,cache,local/share} "$CDIR/.yaak/files"

    # neovim
    mkdir -p "$CDIR/.nvim-database"/.{cache,local,config} "$CDIR/.nvim-database/sql"
    mkdir -p "$CDIR/.nvim-c"/.{cache,local,config} "$CDIR/.nvim-c/projects"

    # tmux
    mkdir -p "$CDIR/.tmux"/.{cache,local/bin,m2,gradle,config/tmux}

    # springboot neovim
    mkdir -p "$CDIR/.nvim-spring"/.{cache,local/share/java/jdtls,config,m2,gradle,models} "$CDIR/.nvim-spring/projects"
    
}

install_dev_bins() {
    install -m 700 "$DEV_DIR/neovim/bin/sql-nvim.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/neovim/bin/nvim-c.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/neovim/bin/springboot-nvim.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/jetbrains/bin/idea.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/yaak/bin/tester.sh" "$LOCAL_BIN"
    install -m 700 "$DEV_DIR/tmux/bin/tmux-container.sh" "$LOCAL_BIN"
}

setup_dev_config() {

    # intellij idea
    install -m 400 "$DEV_DIR/jetbrains/config/ideavimrc" "$IDEA_DIR/.ideavimrc"

    # tmux
    install -m 400 "$DEV_DIR/tmux/config/tmux.conf" "$CDIR/.tmux/.config/tmux"

    echo "org.gradle.jvmargs=-Xmx512m -XX:MaxMetaspaceSize=128m" | tee "$CDIR/.tmux/.gradle/gradle.properties"

    install -m 700 "$DEV_DIR/tmux/bin/project-picker.sh" "$CDIR/.tmux/.local/bin/"
    install -m 700 "$DEV_DIR/tmux/bin/run-service.sh" "$CDIR/.tmux/.local/bin/"
    install -m 700 "$DEV_DIR/tmux/bin/spring-dev.sh" "$CDIR/.tmux/.local/bin/"

    # nvim spring
    echo "org.gradle.jvmargs=-Xmx512m -XX:MaxMetaspaceSize=128m" | tee "$CDIR/.nvim-spring/.gradle/gradle.properties"
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
