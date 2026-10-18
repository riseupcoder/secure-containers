#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Config
# ==========================================
SESSION="spring-microservices"
CONTROL_WINDOW="devctl"
RUN_SCRIPT="$HOME/.local/bin/run-service.sh"
AUTOSTART=("config-server" "eureka-server")

# ==========================================
# Shared functions
# ==========================================

get_pane() {
    local window="$1"
    tmux list-panes -s -t "$SESSION" -F '#{pane_id} #{window_name}' 2>/dev/null | \
        awk -v w="$window" '$2 == w {print $1}'
}

service_panes() {
    tmux list-panes -s -t "$SESSION" -F '#{pane_id} #{window_name}' 2>/dev/null | \
        awk -v ctrl="$CONTROL_WINDOW" '$2 != ctrl {print $1}'
}

start_service() {
    local window="$1"
    local pane
    pane=$(get_pane "$window")
    if [[ -n "$pane" ]]; then
        tmux respawn-pane -k -t "$pane" "$RUN_SCRIPT"
        echo "  started: $window"
    fi
}

stop_service() {
    local window="$1"
    local pane
    pane=$(get_pane "$window")
    if [[ -n "$pane" ]]; then
        tmux send-keys -t "$pane" C-c
        echo "  stopped: $window"
    fi
}

stop_all() {
    echo "Stopping all services..."
    while read -r pane; do
        tmux send-keys -t "$pane" C-c
    done < <(service_panes)
    sleep 3
}

start_all_in_order() {
    local -a started=()

    for svc in "${AUTOSTART[@]}"; do
        start_service "$svc"
        started+=("$svc")
        sleep 15
    done

    while read -r pane; do
        local window
        window=$(tmux display-message -p -t "$pane" '#{window_name}')
        local skip=false
        for s in "${started[@]}"; do
            [[ "$window" == "$s" ]] && skip=true && break
        done
        if [[ "$skip" == false ]]; then
            tmux respawn-pane -k -t "$pane" "$RUN_SCRIPT"
            echo "  started: $window"
        fi
    done < <(service_panes)
}

restart_all() {
    echo "Restarting all services..."
    stop_all
    start_all_in_order
    echo "Done."
}

init() {
    local project_root="$1"

    # Discover all Gradle services.
    local -a services=()
    mapfile -t services < <(
        cd "$project_root" && \
        find . -name gradlew -type f \
            -not -path '*/build/*' \
            -printf '%h\n' |
        sed 's|^\./||' |
        sort
    )

    if ((${#services[@]} == 0)); then
        echo "No Gradle services found in $project_root"
        exit 1
    fi

    # Kill existing session to avoid stale windows with wrong CWD.
    if tmux has-session -t "=$SESSION" 2>/dev/null; then
        echo "Killing existing session '$SESSION'..."
        tmux kill-session -t "=$SESSION"
    fi

    # Create fresh session.
    tmux new-session -d -s "$SESSION" -n "$CONTROL_WINDOW" -c "$project_root"

    # Create service windows with correct CWD.
    for svc in "${services[@]}"; do
        tmux new-window -d -t "=$SESSION" -n "$svc" -c "$project_root/$svc"
    done

    # Start autostart services (only if they exist in this project).
    echo "Starting infrastructure..."
    for svc in "${AUTOSTART[@]}"; do
        if tmux list-windows -t "=$SESSION" -F '#{window_name}' | grep -Fxq "$svc"; then
            start_service "$svc"
        fi
    done

    echo "Session ready: $SESSION"
    echo "  Autostarted: $(tmux list-windows -t "=$SESSION" -F '#{window_name}' | grep -vF "$CONTROL_WINDOW" | tr '\n' ' ')"
    echo "  Other services: use C-b s to start individually"
}

# ==========================================
# CLI entry point
# ==========================================
case "${1:-}" in
    init)
        init "${2:?Usage: spring-dev.sh init <project-root>}"
        ;;
    stop-all)
        stop_all
        ;;
    restart-all)
        restart_all
        ;;
    *)
        echo "Usage: spring-dev.sh {init <project-root>|stop-all|restart-all}"
        exit 1
        ;;
esac   
