#!/usr/bin/env bash

readonly READING_DIR="$PWD/reading"
readonly READING_SECPOLICY_DIR="$READING_DIR/sepolicy"

readonly READING_IMAGES=(
    "$READING_DIR/Containerfile-ebook:ebook"
    "$READING_DIR/Containerfile-pdf:pdf-reader"
)

setup_reading_images() {
    local image
    local file
    local tag

    for image in "${READING_IMAGES[@]}"; do
        IFS=":" read -r file tag <<< "$image"

        info "Building $tag image"

        podman build -f "$file" --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t "$tag"
    done
}

setup_reading_dirs() {
    mkdir -p "$CDIR/.foliate"/.{config/foliate,local/share/foliate,cache}

    # pdf
    mkdir -p "$CDIR/.pdf"/.{config/nnn,config/glib-2.0/settings,cache}
}

install_reading_bins() {
    install -m 700 "$READING_DIR/bin/foliate.sh" "$LOCAL_BIN"
    install -m 700 "$READING_DIR/bin/pdf-reader.sh" "$LOCAL_BIN"
}

secpolicy_foliate() {
    install_selinux_policy "foliate_data" "$READING_SECPOLICY_DIR/foliate"
    install_selinux_cil "$READING_SECPOLICY_DIR/foliate/selinux-foliate.cil"
}

secpolicy_pdf_reader() {
    install_selinux_cil "$READING_SECPOLICY_DIR/pdf/selinux-pdf.cil"
}

install_reading_sepolicy() {
    secpolicy_foliate
    secpolicy_pdf_reader
}

setup_reading_environment() {
    setup_reading_images
    setup_reading_dirs
    install_reading_bins
}

