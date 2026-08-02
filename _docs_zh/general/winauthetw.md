---
title: 抓取 Windows 身份验证 ETW 跟踪
permalink: /zh/docs/general/winauthetw/
parent: Windows 与网络
grand_parent: 指南
nav_order: 5
description: "抓取用于 Windows 身份验证故障排查的 ETW 跟踪。"
tags: [windows, authentication, etw]
last_modified_date: 2026-08-02
---

## 抓取 Windows 身份验证 ETW 跟踪

1. 下载 [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip)，然后解压。

2. 以管理员身份打开 **Power Shell**，然后进入 `toolkit\Auth-Script`。

3. 运行以下命令开始抓取。

   ```powershell
   .\start-auth.ps1
   ```

4. 重现问题。

5. 运行以下命令停止抓取，然后等待脚本完成。

   ```powershell
   .\stop-auth.ps1
   ```

6. 确认输出文件已创建在当前目录的 `authlogs` 文件夹中。
