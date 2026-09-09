#!/usr/bin/env bash

readonly LOCAL_BIN="$HOME/.local/bin/"
readonly CDIR="$HOME/.containers"

create_temp_directory() {
    mktemp -d
}

remove_directory() {
    local directory="$1"

    [[ -d "$directory" ]] && rm -rf "$directory"
}

fail() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}


require_programs() {
    local program

    for program in "$@"; do
        command -v "$program" >/dev/null 2>&1 ||
            fail "Required program missing: $program"
    done
}

