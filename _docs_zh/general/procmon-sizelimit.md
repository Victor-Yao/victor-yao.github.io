---
title: 抓取限制大小的 Procmon 跟踪
permalink: /zh/docs/general/procmon-sizelimit/
parent: Windows 与网络
grand_parent: 指南
nav_order: 4
description: "使用循环缓冲区或最大文件大小限制抓取 Process Monitor 跟踪。"
tags: [windows, procmon, tracing]
last_modified_date: 2026-08-02
---

## 抓取限制日志大小的 Procmon 跟踪

1. 下载 [Process Monitor（Procmon）](https://docs.microsoft.com/zh-cn/sysinternals/downloads/procmon)。

2. 以管理员身份打开 **Command Prompt**，然后进入包含 `procmon.exe` 的文件夹。

3. 运行以下命令。

   ```bat
   Procmon.exe /AcceptEula /Minimized /Quiet /PagingFile /RingBufferSize 800
   ```

   {: .tip }
   > 可以将 `/RingBufferSize` 增加到最高 **4096**（4 GB）。

   ![使用循环缓冲区通过 Procmon 命令行抓取](/assets/images/procmon4.png)

4. 重现问题。

5. 将 `Logfile.pml` 保存到本地磁盘。

   ![保存 Procmon 日志文件](/assets/images/procmon3.png)

{: .note }
> 参数参考

![Procmon 使用说明输出](/assets/images/procmon5.png)
