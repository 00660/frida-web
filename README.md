# FridaWeb

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/00660/frida-web/main.yml?branch=main)
![GitHub repo size](https://img.shields.io/github/repo-size/00660/frida-web)
![GitHub downloads](https://img.shields.io/github/downloads/00660/frida-web/total)

> [Frida](https://frida.re) is a dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers

> [FridaWeb](README.md) lets you run frida-server on boot with multiple root solutions and a LAN panel

## Supported root solutions

[Magisk](https://github.com/topjohnwu/Magisk), [KernelSU](https://github.com/tiann/KernelSU) and [APatch](https://github.com/bmax121/APatch)

## Supported architectures

`arm64`, `arm`, `x86`, `x86_64`

## Instructions

Install `FridaWeb.zip` from [the releases](https://github.com/00660/frida-web/releases)

> :information_source: Do not use the Magisk modules repository, it is obsolete and no longer receives updates

## LAN panel

This fork adds a lightweight LAN panel served directly from the module with BusyBox `httpd`.

- Default panel URL: `http://<device-ip>:28080/`
- Default Frida listen address: `127.0.0.1:27042`

From the panel you can:

 - change the Frida port
 - enable or disable Frida auto-start
 - start, stop, and restart `frida-server`
 - read `service`, `action`, `utils`, `frida`, and `panel` logs

Security note:

- the panel is reachable on your LAN by default
- Frida stays bound to `127.0.0.1`; use `adb forward` from your computer to connect

## How fast are frida-server updates?

Instant! This module is hooked up to the official Frida build process

## Issues?

Check out the [troubleshooting guide](TROUBLESHOOTING.md)

## Building yourself

```bash
uv sync
uv run python3 main.py
```

- Release ZIP will be under `/build`
- frida-server downloads will be under `/downloads`

## Fork-friendly releases

The build now derives release URLs from the current GitHub repository, so your fork can publish its own updater metadata instead of pointing back to upstream.

- GitHub Actions release workflow supports both `master` and `main`
- The workflow injects `MAGISK_FRIDA_REPO_SLUG` and `MAGISK_FRIDA_REPO_BRANCH`
- `module.prop` and `updater.json` will point to your fork when built in your fork
