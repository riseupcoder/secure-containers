#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/setup.conf"
source "$ROOT_DIR/lib/selinux.sh"

declare -a SELECTED

load_modules() {
    local environment name script function

    for environment in "${ENVIRONMENTS[@]}"; do
        IFS='|' read -r name script function <<< "$environment"
        source "$ROOT_DIR/$script"

        if ! declare -F "$function" >/dev/null; then
            error "$function was not defined by $script" >&2
            exit 1
        fi
    done
}

select_environments() {
    local input number index

    SELECTED=()

    for ((index = 0; index < ${#ENVIRONMENTS[@]}; index++)); do
        SELECTED[index]=1
    done

    clear

    echo "===================================="
    echo " Select environments to install"
    echo "===================================="
    echo

    for ((index = 0; index < ${#ENVIRONMENTS[@]}; index++)); do
        IFS='|' read -r name _ _ <<< "${ENVIRONMENTS[index]}"
        printf "[x] %d) %s\n" "$((index + 1))" "$name"
    done

    echo
    echo "Unselect the environments you don't need"
    echo "by entering their number seperated by space, then press ENTER"
    echo "to install the selected environments."
    echo "eg. 1 2 5"
    echo

    read -r -p "Selection: " input

    for number in $input; do
        if [[ "$number" =~ ^[0-9]+$ ]]; then
            index=$((number - 1))

            if ((index >= 0 && index < ${#ENVIRONMENTS[@]})); then
                SELECTED[index]=0
            fi
        fi
    done
}

show_summary() {
    local index name

    echo
    echo "===================================="
    echo " Selected environments"
    echo "===================================="
    echo

    for index in "${!ENVIRONMENTS[@]}"; do
        ((SELECTED[index])) || continue

        IFS='|' read -r name _ _ <<< "${ENVIRONMENTS[index]}"
        echo " ✓ $name"
    done

    echo
}

confirm() {
    local answer

    read -r -p "Continue? [Y/n]: " answer

    [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
}


run_installation() {
    local environment name script function index

    for index in "${!ENVIRONMENTS[@]}"; do
        ((SELECTED[index])) || continue

        IFS='|' read -r name script function <<< "${ENVIRONMENTS[index]}"

        echo
        echo "===================================="
        echo " Running $name"
        echo "===================================="

        "$function"
    done
}


main() {
    mkdir -p "$HOME/.local/bin"

    doas dnf install -y selinux-policy-devel udica

    load_modules
    select_environments
    show_summary

    if ! confirm; then
        echo "Cancelled."
        exit 0
    fi

    install_selinux_cil "$ROOT_DIR/sepolicy/common/restrict_data.cil"

    run_installation

    success "Setup completed"
}


main "$@"
