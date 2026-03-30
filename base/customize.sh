#!/bin/sh
##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

##########################################################################################
# Replace list
##########################################################################################

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

REPLACE="
"

##########################################################################################
# Function Callbacks
##########################################################################################

[ ! -d "$MODPATH/logs" ] && mkdir -p "$MODPATH/logs"

# log
exec 2> "$MODPATH/logs/custom.log"
set -x

PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin
. "$MODPATH/utils.sh" || abort "! Failed to load utilities"

print_modname() {
  ui_print " "
  ui_print "    ********************************************"
  ui_print "    *          Magisk/KernelSU/APatch          *"
  ui_print "    *                FridaWeb                  *"
  ui_print "    ********************************************"
  ui_print "    *            独立品牌模块版本             *"
  ui_print " "
}

on_install() {
  case $ARCH in
    arm64) F_ARCH=$ARCH ;;
    arm)   F_ARCH=$ARCH ;;
    x64)   F_ARCH=x86_64 ;;
    x86)   F_ARCH=$ARCH ;;
    *)     ui_print "Unsupported architecture: $ARCH"; abort ;;
  esac

  ui_print "- Detected architecture: $F_ARCH"

  if [ "$BOOTMODE" ] && [ "$KSU" ]; then
      ui_print "- FridaWeb 安装来源：KernelSU"
      ui_print "- KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  elif [ "$BOOTMODE" ] && [ "$APATCH" ]; then
      ui_print "- FridaWeb 安装来源：APatch"
      ui_print "- APatch version: $APATCH_VER_CODE. Magisk version: $MAGISK_VER_CODE"
  elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
      ui_print "- FridaWeb 安装来源：Magisk"
      ui_print "- Magisk version: $MAGISK_VER_CODE ($MAGISK_VER)"
  else
    ui_print "*********************************************************"
    ui_print "! Install from recovery is not supported"
    ui_print "! Please install from KernelSU or Magisk app"
    abort    "*********************************************************"
  fi

  ui_print "- 正在解压 FridaWeb 模块文件..."
  F_TARGETDIR="$MODPATH/system/bin"
  mkdir -p "$F_TARGETDIR"
  chcon -R u:object_r:system_file:s0 "$F_TARGETDIR"
  chmod -R 755 "$F_TARGETDIR"

  busybox unzip -qq -o "$ZIPFILE" "files/frida-server-$F_ARCH" -j -d "$F_TARGETDIR"
  mv "$F_TARGETDIR/frida-server-$F_ARCH" "$F_TARGETDIR/frida-server"

  ensure_config_files
  ui_print "- FridaWeb 面板地址：http://<device-ip>:${DEFAULT_PANEL_PORT}/"
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0755 0644

  set_perm "$MODPATH/system/bin/frida-server" 0 2000 0755 u:object_r:system_file:s0
  set_perm "$MODPATH/manage.sh" 0 0 0755 u:object_r:system_file:s0
  set_perm_recursive "$MODPATH/panel/cgi-bin" 0 0 0755 0755 u:object_r:system_file:s0
  set_perm "$MODPATH/config/frida-panel.conf" 0 0 0600 u:object_r:system_file:s0
}

print_modname
on_install
set_permissions

[ -f "$MODPATH/disable" ] && {
  string="description=FridaWeb 安装后为禁用状态"
  sed -i "s|^description=.*|$string|g" "$MODPATH/module.prop"
}

#EOF
