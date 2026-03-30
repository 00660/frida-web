#!/system/bin/sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
MODPATH=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

. "$MODPATH/frida-manager.sh" || exit 1

panel_log() {
    ensure_runtime_dirs
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_DIR/panel.log"
}

prepare_request_data() {
    REQUEST_DATA="$QUERY_STRING"

    case "$REQUEST_METHOD:$CONTENT_LENGTH" in
        POST:[1-9]*)
            body="$(dd bs=1 count="$CONTENT_LENGTH" 2>/dev/null)"
            if [ -n "$REQUEST_DATA" ]; then
                REQUEST_DATA="${REQUEST_DATA}&${body}"
            else
                REQUEST_DATA="$body"
            fi
            ;;
    esac
}

url_decode() {
    value="${1//+/ }"
    printf '%b' "${value//%/\\x}"
}

get_param() {
    key="$1"
    old_ifs="$IFS"
    IFS='&'

    for pair in $REQUEST_DATA; do
        IFS="$old_ifs"
        case "$pair" in
            "$key"=*)
                value="${pair#*=}"
                url_decode "$value"
                IFS="$old_ifs"
                return 0
                ;;
            "$key")
                printf ''
                IFS="$old_ifs"
                return 0
                ;;
        esac
        IFS='&'
    done

    IFS="$old_ifs"
    return 1
}

json_escape() {
    printf '%s' "$1" | busybox sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e ':a;N;$!ba;s/\r/\\r/g;s/\n/\\n/g'
}

send_json() {
    printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n%s\n' "$1"
}

send_error() {
    status="$1"
    message="$2"
    printf 'Status: %s\r\nContent-Type: application/json\r\nCache-Control: no-store\r\n\r\n{"ok":false,"error":"%s"}\n' \
        "$status" \
        "$(json_escape "$message")"
    exit 0
}
