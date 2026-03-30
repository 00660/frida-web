#!/system/bin/sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

prepare_request_data

name="$(get_param name)"
lines="$(get_param lines)"

case "$name" in
    service|action|utils|frida|panel|manage)
        log_file="$LOG_DIR/${name}.log"
        ;;
    *)
        send_error '400 Bad Request' 'Unknown log name'
        ;;
esac

case "$lines" in
    ''|*[!0-9]*)
        lines=160
        ;;
esac

if [ "$lines" -lt 20 ]; then
    lines=20
fi

if [ "$lines" -gt 500 ]; then
    lines=500
fi

printf 'Content-Type: text/plain; charset=utf-8\r\nCache-Control: no-store\r\n\r\n'

if [ -f "$log_file" ]; then
    busybox tail -n "$lines" "$log_file"
else
    printf 'No log file yet: %s\n' "$log_file"
fi
