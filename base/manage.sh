#!/system/bin/sh
MODPATH=${MODPATH:-${0%/*}}
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

mkdir -p "$MODPATH/logs"
exec 2>> "$MODPATH/logs/manage.log"
set -x

. "$MODPATH/frida-manager.sh" || exit $?

case "$1" in
    start-frida)
        start_frida
        ;;
    stop-frida)
        stop_frida
        ;;
    restart-frida)
        restart_frida
        ;;
    start-panel)
        start_panel
        ;;
    stop-panel)
        stop_panel
        ;;
    restart-panel)
        restart_panel
        ;;
    status)
        load_config
        if frida_is_running; then
            echo "frida=running"
        else
            echo "frida=stopped"
        fi

        if panel_is_running; then
            echo "panel=running"
        else
            echo "panel=stopped"
        fi

        echo "frida_listen=${DEFAULT_FRIDA_BIND}:${FRIDA_PORT}"
        echo "panel_listen=${PANEL_BIND}:${PANEL_PORT}"
        echo "autostart=${AUTO_START_FRIDA}"
        ;;
    *)
        echo "Usage: $0 {start-frida|stop-frida|restart-frida|start-panel|stop-panel|restart-panel|status}"
        exit 1
        ;;
esac
