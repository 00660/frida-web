#!/system/bin/sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

prepare_request_data

action="$(get_param action)"
[ -n "$action" ] || send_error '400 Bad Request' 'Missing action'

case "$action" in
    start_frida)
        panel_log "Requested start_frida"
        start_frida || send_error '500 Internal Server Error' 'Failed to start Frida'
        ;;
    stop_frida)
        panel_log "Requested stop_frida"
        stop_frida || send_error '500 Internal Server Error' 'Failed to stop Frida'
        ;;
    restart_frida)
        panel_log "Requested restart_frida"
        restart_frida || send_error '500 Internal Server Error' 'Failed to restart Frida'
        ;;
    *)
        send_error '400 Bad Request' 'Unknown action'
        ;;
esac

load_config
running=false
if frida_is_running; then
    running=true
fi

send_json "{
  \"ok\": true,
  \"action\": \"$(json_escape "$action")\",
  \"frida_running\": $running,
  \"frida_port\": $FRIDA_PORT
}"
