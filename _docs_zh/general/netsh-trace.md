---
title: 使用 netsh 抓取网络跟踪
permalink: /zh/docs/general/netsh-trace/
parent: Windows 与网络
grand_parent: 指南
nav_order: 11
description: "使用 netsh 抓取基于 ETW 的 Windows 网络跟踪。"
tags: [windows, networking, etw]
last_modified_date: 2026-08-02
---

## 使用 netsh trace（ETW）抓取网络跟踪

{: .note }
> 以下所有步骤都需要以管理员身份打开 **Command Prompt** 或 **PowerShell**。

### 抓取跟踪

1. 开始抓取。

   ```cmd
   netsh trace start capture=yes tracefile=C:\Temp\nettrace.etl maxsize=2048 overwrite=yes
   ```

   - `capture=yes` 启用数据包抓取（不只是 ETW 事件）。
   - `tracefile` 设置输出路径。请确保该文件夹已存在。
   - `maxsize` 是最大文件大小，单位为 MB（默认值为 250 MB）。达到该大小后，抓取会停止。
   - `overwrite=yes` 会替换现有跟踪文件。

2. 重现问题。

3. 停止抓取，然后等待命令完成文件写入。

   ```cmd
   netsh trace stop
   ```

4. 从 `C:\Temp` 收集输出文件：

   - `nettrace.etl` — 网络数据包抓取。
   - `nettrace.cab` — 系统和配置详细信息。

### 常用选项

- 在固定大小的循环缓冲区中持续抓取，使跟踪仅保留最新数据。

  ```cmd
  netsh trace start capture=yes tracefile=C:\Temp\nettrace.etl maxsize=512 filemode=circular overwrite=yes
  ```

- 按特定 IP 地址筛选，以减小跟踪大小。

  ```cmd
  netsh trace start capture=yes IPv4.Address=10.0.0.5 tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

- 按特定协议和端口筛选。

  ```cmd
  netsh trace start capture=yes Protocol=TCP tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

- 跨重启保留跟踪，用于抓取启动时或重启相关问题。

  ```cmd
  netsh trace start capture=yes persistent=yes tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

  {: .note }
  > 重启后运行 `netsh trace stop` 以完成跟踪。
