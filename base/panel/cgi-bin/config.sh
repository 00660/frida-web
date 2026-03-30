#!/system/bin/sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

prepare_request_data
load_config

case "$REQUEST_METHOD" in
    GET)
        send_json "{
  \"ok\": true,
  \"frida_port\": $FRIDA_PORT,
  \"auto_start_frida\": $AUTO_START_FRIDA,
  \"panel_bind\": \"$(json_escape "$PANEL_BIND")\",
  \"panel_port\": $PANEL_PORT
}"
        ;;
    POST)
        new_port="$(get_param frida_port)"
        new_auto_start="$(get_param auto_start_frida)"
        restart_after_save="$(get_param restart)"

        [ -n "$new_port" ] || new_port="$FRIDA_PORT"
        [ -n "$new_auto_start" ] || new_auto_start="$AUTO_START_FRIDA"
        new_auto_start="$(normalize_bool_value "$new_auto_start")"

        if ! is_valid_port "$new_port"; then
            send_error '400 Bad Request' 'Invalid port'
        fi

        write_config_file \
            "$DEFAULT_FRIDA_BIND" \
            "$new_port" \
            "$PANEL_BIND" \
            "$PANEL_PORT" \
            "$new_auto_start"

        panel_log "Saved Frida config: ${DEFAULT_FRIDA_BIND}:${new_port} autostart=${new_auto_start}"

        if [ "$restart_after_save" = "true" ]; then
            restart_frida || send_error '500 Internal Server Error' 'Failed to restart Frida'
        fi

        load_config
        send_json "{
  \"ok\": true,
  \"frida_port\": $FRIDA_PORT,
  \"auto_start_frida\": $AUTO_START_FRIDA
}"
        ;;
    *)
        send_error '405 Method Not Allowed' 'Unsupported method'
        ;;
esac
