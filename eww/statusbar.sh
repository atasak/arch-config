#!/bin/bash
# Single entry point for managing the eww statusbar.
# Guarantees at most one eww daemon by serialising all calls with a lock and
# never letting plain client commands auto-spawn a daemon.
#
# Usage: statusbar.sh [open|reload|restart]
#   open    (default) ensure the daemon runs, then open the statusbar
#   reload  reload the config of the running daemon (no-op if none runs)
#   restart kill every eww daemon (incl. orphans), start fresh, open the bar

action="${1:-open}"

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/eww-statusbar.lock"
flock 9

eww_c() { eww --no-daemonize "$@"; }

kill_all() {
    eww_c kill >/dev/null 2>&1
    # Orphaned daemons are not reachable through the socket, kill them directly
    pkill -x eww
    for _ in $(seq 50); do
        pgrep -x eww >/dev/null || return 0
        sleep 0.1
    done
    pkill -9 -x eww
}

start_daemon() {
    # Close the lock fd (9) for the daemon, otherwise it holds the lock forever
    eww daemon 9>&- >/dev/null 2>&1 </dev/null
    for _ in $(seq 100); do
        eww_c ping >/dev/null 2>&1 && return 0
        sleep 0.1
    done
    echo "eww daemon did not come up" >&2
    return 1
}

case "$action" in
    restart)
        kill_all
        start_daemon && eww_c open statusbar
        ;;
    open)
        if ! eww_c ping >/dev/null 2>&1; then
            kill_all
            start_daemon || exit 1
        fi
        eww_c open statusbar
        ;;
    reload)
        eww_c ping >/dev/null 2>&1 && eww_c reload
        ;;
    *)
        echo "Usage: $0 [open|reload|restart]" >&2
        exit 1
        ;;
esac
