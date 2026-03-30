#!/bin/sh
MODPATH=${MODPATH:-${0%/*}}
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin

LOG_DIR=$MODPATH/logs
RUN_DIR=$MODPATH/run
CONFIG_DIR=$MODPATH/config
FRIDA_CONFIG_FILE=$CONFIG_DIR/frida-panel.conf

DEFAULT_FRIDA_BIND=127.0.0.1
DEFAULT_FRIDA_PORT=27042
DEFAULT_PANEL_BIND=0.0.0.0
DEFAULT_PANEL_PORT=28080
DEFAULT_AUTO_START=true

ensure_runtime_dirs() {
    mkdir -p "$LOG_DIR" "$RUN_DIR" "$CONFIG_DIR"
}

normalize_bool_value() {
    case "$1" in
        1|true|TRUE|yes|YES|on|ON)
            printf 'true'
            ;;
        *)
            printf 'false'
            ;;
    esac
}

is_valid_port() {
    case "$1" in
        ''|*[!0-9]*)
            return 1
            ;;
    esac

    [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

is_valid_bind() {
    printf '%s\n' "$1" | grep -Eq '^(localhost|0\.0\.0\.0|127\.0\.0\.1|([0-9]{1,3}\.){3}[0-9]{1,3})$'
}

write_config_file() {
    frida_bind="$DEFAULT_FRIDA_BIND"
    frida_port="$2"
    panel_bind="$3"
    panel_port="$4"
    auto_start="$(normalize_bool_value "$5")"

    ensure_runtime_dirs

    tmp_file="$FRIDA_CONFIG_FILE.tmp"
    cat > "$tmp_file" <<EOF
FRIDA_BIND='$frida_bind'
FRIDA_PORT='$frida_port'
PANEL_BIND='$panel_bind'
PANEL_PORT='$panel_port'
AUTO_START_FRIDA='$auto_start'
EOF
    mv "$tmp_file" "$FRIDA_CONFIG_FILE"
    chmod 600 "$FRIDA_CONFIG_FILE"
}

load_config() {
    if [ ! -s "$FRIDA_CONFIG_FILE" ]; then
        write_config_file \
            "$DEFAULT_FRIDA_BIND" \
            "$DEFAULT_FRIDA_PORT" \
            "$DEFAULT_PANEL_BIND" \
            "$DEFAULT_PANEL_PORT" \
            "$DEFAULT_AUTO_START"
    fi

    unset FRIDA_BIND FRIDA_PORT PANEL_BIND PANEL_PORT AUTO_START_FRIDA
    . "$FRIDA_CONFIG_FILE"

    changed=0

    if [ "$FRIDA_BIND" != "$DEFAULT_FRIDA_BIND" ]; then
        FRIDA_BIND="$DEFAULT_FRIDA_BIND"
        changed=1
    fi

    if ! is_valid_port "$FRIDA_PORT"; then
        FRIDA_PORT="$DEFAULT_FRIDA_PORT"
        changed=1
    fi

    if ! is_valid_bind "$PANEL_BIND"; then
        PANEL_BIND="$DEFAULT_PANEL_BIND"
        changed=1
    fi

    if ! is_valid_port "$PANEL_PORT"; then
        PANEL_PORT="$DEFAULT_PANEL_PORT"
        changed=1
    fi

    AUTO_START_FRIDA="$(normalize_bool_value "$AUTO_START_FRIDA")"

    if [ "$changed" -eq 1 ]; then
        write_config_file \
            "$FRIDA_BIND" \
            "$FRIDA_PORT" \
            "$PANEL_BIND" \
            "$PANEL_PORT" \
            "$AUTO_START_FRIDA"
    fi
}

ensure_config_files() {
    if [ ! -s "$FRIDA_CONFIG_FILE" ]; then
        write_config_file \
            "$DEFAULT_FRIDA_BIND" \
            "$DEFAULT_FRIDA_PORT" \
            "$DEFAULT_PANEL_BIND" \
            "$DEFAULT_PANEL_PORT" \
            "$DEFAULT_AUTO_START"
    else
        load_config >/dev/null 2>&1
    fi
}

set_module_description() {
    state="$1"

    load_config >/dev/null 2>&1

    case "$state" in
        active)
            label="运行中"
            ;;
        idle)
            label="空闲"
            ;;
        stopped)
            label="已停止"
            ;;
        failed)
            label="失败"
            ;;
        disabled)
            label="已禁用"
            ;;
        missing)
            label="缺少二进制文件"
            ;;
        *)
            label="$state"
            ;;
    esac

    if [ -f "$MODPATH/module.prop" ]; then
        description="description=FridaWeb $label | Frida ${FRIDA_BIND}:${FRIDA_PORT} | 面板 ${PANEL_PORT}"
        sed -i "s|^description=.*|$description|g" "$MODPATH/module.prop"
    fi
}

check_frida_is_up() {
    timeout="${1:-4}"
    counter=0

    while [ "$counter" -lt "$timeout" ]; do
        result="$(busybox pgrep 'frida-server' 2>/dev/null)"
        if [ -n "$result" ]; then
            echo "[-] Frida-server is running"
            set_module_description active
            return 0
        fi

        echo "[-] Checking Frida-server status: $counter"
        counter=$((counter + 1))
        sleep 1
    done

    set_module_description failed
    return 1
}

wait_for_boot() {
    while true; do
        result="$(getprop sys.boot_completed)"
        if [ $? -ne 0 ]; then
            exit 1
        elif [ "$result" = "1" ]; then
            break
        fi
        sleep 3
    done
}

#EOF
