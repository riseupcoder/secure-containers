#!/usr/bin/env bash

set -Eeuo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly MAX_PARALLEL_JOBS=3

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/selinux.sh"

readonly ENVIRONMENTS=(
    "reading:reading/setup_reading.sh"
    "dev:dev/setup_dev.sh"
    "browser:browser/setup_browser.sh"
    "multimedia:multimedia/setup_multimedia.sh"
    "security:security/setup_security.sh"
    "productivity:productivity/setup_productivity.sh"
    "util:util/setup_util.sh"
)

declare -A JOBS=()

LOG_DIR=$(mktemp -d "${TMPDIR:-/tmp}/install.XXXXXX")
trap 'rm -rf -- "$LOG_DIR"' EXIT

load_environments() {
    local environment script

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=: read -r environment script <<< "$entry"

        [[ -f "$ROOT_DIR/$script" ]] || {
            error "Setup script not found: $script"
            return 1
        }

        source "$ROOT_DIR/$script"
    done
}

wait_for_job() {
    local pid="" status=0 environment

    if wait -n -p pid "${!JOBS[@]}"; then
        status=0
    else
        status=$?
    fi

    environment="${JOBS[$pid]}"
    unset 'JOBS[$pid]'

    if ((status != 0)); then
        error "$environment failed (exit $status)"
        cat -- "$LOG_DIR/$environment.log" >&2
        return 1
    fi

    success "$environment completed"
}

run_parallel_setup() {
    local environment script function pid failed=0

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=: read -r environment script <<< "$entry"
        function="setup_${environment}_environment"

        if ! declare -F "$function" >/dev/null; then
            error "Missing function: $function"
            failed=1
            continue
        fi

        info "Starting $environment"

        "$function" >"$LOG_DIR/$environment.log" 2>&1 &
        pid=$!
        JOBS["$pid"]="$environment"

        if ((${#JOBS[@]} >= MAX_PARALLEL_JOBS)); then
            wait_for_job || failed=1
        fi
    done

    while ((${#JOBS[@]})); do
        wait_for_job || failed=1
    done

    ((failed == 0)) || {
        error "One or more environments failed"
        return 1
    }
}

install_environment_sepolicy() {
    local environment script function

    for entry in "${ENVIRONMENTS[@]}"; do
        IFS=: read -r environment script <<< "$entry"
        function="install_${environment}_sepolicy"

        info "Installing SELinux policy: $environment"
        "$function"
    done
}

main() {

    mkdir -p -- "$HOME/.local/bin"

    doas dnf install -y selinux-policy-devel udica

    load_environments

    install_selinux_cil "$ROOT_DIR/sepolicy/common/restrict_data.cil"
    install_selinux_cil "$ROOT_DIR/sepolicy/common/gui_tmpfs.cil"

    podman pull alpine
    podman pull fedora-minimal

    run_parallel_setup

    # Keep SELinux policy installation sequential.
    install_environment_sepolicy

    success "Setup completed"
}

main "$@"
