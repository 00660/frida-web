# FridaWeb

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/00660/frida-web/main.yml?branch=main)
![GitHub repo size](https://img.shields.io/github/repo-size/00660/frida-web)
![GitHub downloads](https://img.shields.io/github/downloads/00660/frida-web/total)

> [Frida](https://frida.re) 是一个面向开发者、逆向工程师和安全研究人员的动态插桩工具

> [FridaWeb](README.md) 让你可以在多种 Root 方案下开机启动 `frida-server`，并通过局域网页面板进行管理

## 支持的 Root 方案

[Magisk](https://github.com/topjohnwu/Magisk), [KernelSU](https://github.com/tiann/KernelSU) and [APatch](https://github.com/bmax121/APatch)

## 支持的架构

`arm64`, `arm`, `x86`, `x86_64`

## 安装方式

从 [Releases](https://github.com/00660/frida-web/releases) 下载并安装 `FridaWeb.zip`

> :information_source: 不要使用旧的 Magisk 模块仓库，那个渠道已经废弃，不再更新

## 局域网页面板

这个版本增加了一个轻量级局域网页面板，直接由模块内的 BusyBox `httpd` 提供服务。

- 默认面板地址：`http://<device-ip>:28080/`
- 默认 Frida 监听地址：`127.0.0.1:27042`

你可以在面板中：

- 修改 Frida 端口
- 开启或关闭 Frida 开机自启
- 启动、停止、重启 `frida-server`
- 查看 `service`、`action`、`utils`、`frida`、`panel` 日志

安全说明：

- 面板默认可被同一局域网内的设备访问
- Frida 始终绑定在 `127.0.0.1`，请通过电脑执行 `adb forward` 进行连接

## 更新速度

基本可以做到同步更新，因为这个项目直接跟随 Frida 官方构建流程

## 遇到问题？

请先查看 [故障排查说明](TROUBLESHOOTING.md)

## 自行构建

```bash
uv sync
uv run python3 main.py
```

- 生成的发布 ZIP 位于 `/build`
- 下载的 `frida-server` 文件位于 `/downloads`

## 适配 Fork 的自动发版

当前构建流程会自动根据当前 GitHub 仓库生成 release 地址，因此你的 fork 会发布自己的更新信息，而不是继续指向上游仓库。

- GitHub Actions 的发版工作流同时支持 `master` 和 `main`
- 工作流会自动注入 `MAGISK_FRIDA_REPO_SLUG` 和 `MAGISK_FRIDA_REPO_BRANCH`
- 在你的 fork 中构建时，`module.prop` 和 `updater.json` 会自动指向你自己的仓库
