# Troubleshooting

## Try first
- Ensure `adb devices` shows your device
- Ensure `adb shell` opens a working shell on your device
- Try running frida-server [through an ADB shell](https://www.frida.re/docs/android/)
- Ensure Magisk is at a STABLE version and up-to-date
- Ensure MagiskHide is disabled
- Ensure you are on an AOSP-based ROM
- If the LAN panel does not open, verify your phone and computer are on the same LAN and that `28080/tcp` is not blocked
- If Frida still appears offline after saving a new port, use the panel restart button once

## Not solved?
Please open an issue and post detailed information about your device (including logs!)
