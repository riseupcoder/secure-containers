#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/selinux.sh"

readonly MAX_PARALLEL_JOBS=3

readonly ENVIRONMENTS=(
    "reading:reading/setup_reading.sh"
    "dev:development/setup_dev.sh"
    "browser:internet/browser/setup_browser.sh"
    "multimedia:multimedia/setup_multimedia.sh"
    "security:security/setup_security.sh"
    "productivity:productivity/setup_productivity.sh"
)

load_environments() {
    local entry
    local environment
    local script

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=':' read -r environment script <<< "$entry"

        source "$ROOT_DIR/$script"
    done
}

run_parallel_setup() {
    local entry
    local environment
    local setup_function
    local running=0
    local failed=0

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=':' read -r environment _ <<< "$entry"

        setup_function="setup_${environment}_environment"

        info "Starting $environment"

        "$setup_function" &

        running=$((running + 1))

        if ((running >= MAX_PARALLEL_JOBS)); then
            if ! wait -n; then
                failed=1
            fi

            running=$((running - 1))
        fi
    done

    # Wait for all remaining setup jobs.
    while ((running > 0)); do
        if ! wait -n; then
            failed=1
        fi

        running=$((running - 1))
    done

    if ((failed)); then
        error "One or more environments failed"
        return 1
    fi
}

install_environment_sepolicy() {
    local entry
    local environment
    local sepolicy_function

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=':' read -r environment _ <<< "$entry"

        sepolicy_function="install_${environment}_sepolicy"

        info "Installing SELinux policy: $environment"

        "$sepolicy_function"
    done
}


main() {
    mkdir -p "$HOME/.local/bin"

    doas dnf install -y selinux-policy-devel udica

    load_environments

    install_selinux_cil "$ROOT_DIR/sepolicy/common/restrict_data.cil"

    # Podman builds and other unprivileged setup work.
    # Run them concurrently with a limit on the number of jobs.
    run_parallel_setup

    # SELinux installation is intentionally sequential and runs
    # in this shell so privileged operations do not happen concurrently.
    install_environment_sepolicy

    success "Setup completed"
}

main "$@"
