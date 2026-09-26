#!/usr/bin/env bash

set -euo pipefail

readonly MAX_PARALLEL_JOBS=3

readonly UPGRADE_SCRIPTS=(
    development/upgrade.sh
    reading/upgrade.sh
    internet/browser/upgrade.sh
    multimedia/upgrade.sh
    security/upgrade.sh
    productivity/upgrade.sh
)

running=0
failed=0

for script in "${UPGRADE_SCRIPTS[@]}"; do
    echo "Running $script"

    bash "$script" &

    ((running++))

    if ((running >= MAX_PARALLEL_JOBS)); then
        if ! wait -n; then
            failed=1
        fi

        ((running--))
    fi
done

# Wait for remaining upgrades.
while ((running > 0)); do
    if ! wait -n; then
        failed=1
    fi

    ((running--))
done

if ((failed)); then
    echo "One or more upgrades failed." >&2
    exit 1
fi

echo "All upgrades completed successfully."

