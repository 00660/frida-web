#!/system/bin/sh
MODPATH=${MODPATH:-${0%/*}}
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

. "$MODPATH/utils.sh" || exit $?

FRIDA_BINARY=$MODPATH/system/bin/frida-server
PANEL_ROOT=$MODPATH/panel
PANEL_PID_FILE=$RUN_DIR/panel.pid
PANEL_LOG_FILE=$LOG_DIR/panel.log
FRIDA_LOG_FILE=$LOG_DIR/frida.log

frida_pid() {
    busybox pgrep 'frida-server' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

frida_is_running() {
    [ -n "$(busybox pgrep 'frida-server' 2>/dev/null)" ]
}

panel_pid() {
    if [ -s "$PANEL_PID_FILE" ]; then
        pid="$(tr -d '\r\n' < "$PANEL_PID_FILE")"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            printf '%s' "$pid"
            return 0
        fi
    fi

    pid="$(busybox pgrep -f "busybox httpd.*$PANEL_ROOT" 2>/dev/null | head -n 1)"
    if [ -n "$pid" ]; then
        printf '%s' "$pid"
        return 0
    fi

    return 1
}

panel_is_running() {
    [ -n "$(panel_pid 2>/dev/null)" ]
}

start_panel() {
    ensure_runtime_dirs
    load_config

    [ -d "$PANEL_ROOT" ] || return 1

    if panel_is_running; then
        return 0
    fi

    touch "$PANEL_LOG_FILE"
    (
        cd "$PANEL_ROOT" || exit 1
        exec busybox httpd -f -p "${PANEL_BIND}:${PANEL_PORT}" -h "$PANEL_ROOT"
    ) >> "$PANEL_LOG_FILE" 2>&1 &
    echo $! > "$PANEL_PID_FILE"

    sleep 1
    panel_is_running
}

stop_panel() {
    pid="$(panel_pid 2>/dev/null)"
    if [ -z "$pid" ]; then
        rm -f "$PANEL_PID_FILE"
        return 0
    fi

    kill "$pid" 2>/dev/null || busybox kill "$pid" 2>/dev/null
    sleep 1
    kill -9 "$pid" 2>/dev/null || busybox kill -9 "$pid" 2>/dev/null
    rm -f "$PANEL_PID_FILE"
}

restart_panel() {
    stop_panel
    start_panel
}

start_frida() {
    ensure_runtime_dirs
    load_config

    if frida_is_running; then
        check_frida_is_up 1
        return 0
    fi

    if [ ! -x "$FRIDA_BINARY" ]; then
        echo "[-] Missing Frida binary: $FRIDA_BINARY"
        set_module_description missing
        return 1
    fi

    touch "$FRIDA_LOG_FILE"
    "$FRIDA_BINARY" -l "${DEFAULT_FRIDA_BIND}:${FRIDA_PORT}" -D >> "$FRIDA_LOG_FILE" 2>&1 || {
        set_module_description failed
        return 1
    }

    check_frida_is_up 6
}

stop_frida() {
    pids="$(busybox pgrep 'frida-server' 2>/dev/null)"
    if [ -n "$pids" ]; then
        busybox kill -9 $pids 2>/dev/null
    fi

    set_module_description stopped
}

restart_frida() {
    stop_frida
    sleep 1
    start_frida
}
