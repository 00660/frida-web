#!/system/bin/sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

prepare_request_data
load_config

frida_running=false
panel_running=false
frida_pid_value=""
panel_pid_value=""

if frida_is_running; then
    frida_running=true
    frida_pid_value="$(frida_pid)"
fi

if panel_is_running; then
    panel_running=true
    panel_pid_value="$(panel_pid)"
fi

send_json "{
  \"ok\": true,
  \"frida\": {
    \"running\": $frida_running,
    \"pid\": \"$(json_escape "$frida_pid_value")\",
    \"port\": $FRIDA_PORT,
    \"autostart\": $AUTO_START_FRIDA
  },
  \"panel\": {
    \"running\": $panel_running,
    \"pid\": \"$(json_escape "$panel_pid_value")\",
    \"bind\": \"$(json_escape "$PANEL_BIND")\",
    \"port\": $PANEL_PORT
  }
}"
