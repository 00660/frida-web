#!/system/bin/sh
# This script will be executed in late_start service mode
MODPATH=${0%/*}

[ ! -d "$MODPATH/logs" ] && mkdir -p "$MODPATH/logs"

# log
exec 2> "$MODPATH/logs/service.log"
set -x

. "$MODPATH/frida-manager.sh" || exit $?

ensure_runtime_dirs
ensure_config_files

wait_for_boot

[ -f "$MODPATH/disable" ] && {
    echo "[-] Module is disabled"
    set_module_description disabled
    exit 0
}

start_panel || echo "[-] Failed to start LAN panel"

load_config
if [ "$AUTO_START_FRIDA" = "true" ]; then
    start_frida
else
    echo "[-] Frida autostart is disabled"
    set_module_description idle
fi

#EOF
