#!/usr/bin/env bash

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly MAX_PARALLEL_JOBS=3

readonly UPGRADE_SCRIPTS=(
    development/upgrade.sh
    reading/upgrade.sh
    internet/browser/upgrade.sh
    multimedia/upgrade.sh
    security/upgrade.sh
    productivity/upgrade.sh
    utilities/upgrade.sh
)

declare -A JOBS=()
failed=0

wait_for_job() {
    local pid="" status=0 script

    if wait -n -p pid "${!JOBS[@]}"; then
        status=0
    else
        status=$?
    fi

    if [[ -z "${pid:-}" ]]; then
        echo "ERROR: Could not identify completed upgrade job" >&2
        return 1
    fi

    script="${JOBS[$pid]}"
    unset 'JOBS[$pid]'

    if ((status != 0)); then
        echo "FAILED (exit $status): $script" >&2
        return 1
    fi

    echo "Completed: $script"
}

for script in "${UPGRADE_SCRIPTS[@]}"; do
    if [[ ! -f "$ROOT_DIR/$script" ]]; then
        echo "ERROR: Upgrade script not found: $script" >&2
        failed=1
        continue
    fi

    echo "Starting: $script"

    bash "$ROOT_DIR/$script" &
    JOBS["$!"]="$script"

    if ((${#JOBS[@]} >= MAX_PARALLEL_JOBS)); then
        wait_for_job || failed=1
    fi
done

while ((${#JOBS[@]} > 0)); do
    wait_for_job || failed=1
done

if ((failed)); then
    echo "One or more upgrades failed." >&2
    exit 1
fi

echo "All upgrades completed successfully."
