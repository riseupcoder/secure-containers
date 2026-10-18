#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="/projects"
SESSION="spring-microservices"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Discover valid projects (dirs containing at least one gradlew).
mapfile -t PROJECTS < <(
    find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | while read -r dir; do
        if find "$dir" -name gradlew -type f -not -path '*/build/*' -print -quit 2>/dev/null | grep -q .; then
            echo "$dir"
        fi
    done
)

if ((${#PROJECTS[@]} == 0)); then
    echo -e "${RED}No projects found in $PROJECTS_DIR${NC}"
    exit 1
fi

# Show the picker.
clear
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║       Spring Boot Project Launcher       ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo
echo -e "${BOLD}  Select a project to launch:${NC}"
echo
for i in "${!PROJECTS[@]}"; do
    name=$(basename "${PROJECTS[$i]}")
    svc_count=$(find "${PROJECTS[$i]}" -name gradlew -type f -not -path '*/build/*' 2>/dev/null | wc -l)
    printf "  ${GREEN}[%d]${NC} ${BOLD}%-30s${NC} ${DIM}(%d services)${NC}\n" "$((i+1))" "$name" "$svc_count"
done
echo
echo -e "  ${DIM}[q] Quit${NC}"
echo
read -rp "  Choose: " choice

# Handle quit.
if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    exit 0
fi

# Validate input.
if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#PROJECTS[@]})); then
    echo -e "${RED}  Invalid choice.${NC}"
    exit 1
fi

PROJECT="${PROJECTS[$((choice-1))]}"
PROJECT_NAME=$(basename "$PROJECT")

echo
echo -e "  ${YELLOW}→ Launching ${BOLD}$PROJECT_NAME${NC} from $PROJECT${NC}"
echo

# Initialize the session.
"$HOME/.local/bin/spring-dev.sh" init "$PROJECT"

# Attach to tmux.
if [[ -z "${TMUX:-}" ]]; then
    tmux attach-session -t "$SESSION"
    printf '\n'
    read -r -t 0.2 _ || true
fi   
