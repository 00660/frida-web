# 故障排查

## 先检查这些
- 确认 `adb devices` 能看到你的设备
- 确认 `adb shell` 可以正常进入手机 Shell
- 先尝试通过 [ADB Shell 方式运行 frida-server](https://www.frida.re/docs/android/)
- 确认 Magisk 使用的是稳定版，并且已经更新到较新版本
- 确认 `MagiskHide` 已关闭
- 尽量使用基于 AOSP 的 ROM
- 如果局域网页面板打不开，先确认电脑和手机在同一个局域网，并且 `28080/tcp` 没有被拦截
- 如果修改端口后 Frida 仍显示离线，先在面板里手动点一次重启

## 还没解决？
请提交 issue，并附上尽量详细的设备信息和日志
