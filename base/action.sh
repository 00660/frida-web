#!/system/bin/sh
MODPATH=${0%/*}
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

[ ! -d "$MODPATH/logs" ] && mkdir -p "$MODPATH/logs"

# log
exec 2> "$MODPATH/logs/action.log"
set -x

. "$MODPATH/frida-manager.sh" || exit $?

ensure_runtime_dirs
ensure_config_files

[ -f "$MODPATH/disable" ] && {
    echo "[-] Frida-server is disabled"
    set_module_description disabled
    sleep 1
    exit 0
}

start_panel || echo "[-] Failed to start LAN panel"

if frida_is_running; then
    echo "[-] Stopping Frida-server..."
    stop_frida
    exit 0
else
    echo "[-] Starting Frida-server..."
    start_frida
fi

sleep 1

check_frida_is_up 1

#EOF
