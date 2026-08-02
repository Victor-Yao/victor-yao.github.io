---
title: 抓取 Procmon 跟踪
permalink: /zh/docs/general/procmon/
parent: Windows 与网络
grand_parent: 指南
nav_order: 3
description: "抓取并保存 Process Monitor 跟踪，用于文件、注册表、进程和网络活动。"
tags: [windows, procmon, tracing]
last_modified_date: 2026-08-02
---

## 抓取 Procmon 跟踪

1. 下载 [Process Monitor（Procmon）](https://docs.microsoft.com/zh-cn/sysinternals/downloads/procmon)。

2. 以管理员身份运行 `procmon.exe`，然后重置筛选器。

   ![在 Procmon 中重置筛选器](/assets/images/procmon1.png)

   {: .tip }
   > 可选：如果必须重启服务器才能重现问题，请启用 **Boot Logging**。

   ![在 Procmon 中启用 Boot Logging](/assets/images/procmon2.png)

3. 重现问题。

4. 将 `Logfile.pml` 保存到本地磁盘。

   ![保存 Procmon 日志文件](/assets/images/procmon3.png)
