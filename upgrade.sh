#!/bin/bash

set -euo pipefail

readonly UPGRADE_SCRIPTS=(
    development/upgrade.sh
    reading/upgrade.sh
    internet/browser/upgrade.sh
    multimedia/upgrade.sh
    security/upgrade.sh
    productivity/upgrade.sh
)

for script in "${UPGRADE_SCRIPTS[@]}"; do
    echo "Running $script"
    bash "$script"
done
