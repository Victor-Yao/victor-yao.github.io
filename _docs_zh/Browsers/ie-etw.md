---
title: 捕获 Internet Explorer ETW 跟踪
permalink: /zh/docs/Browsers/ie-etw/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 14
description: "使用提供的脚本为 Internet Explorer 捕获 ETW 跟踪。"
tags: [internet-explorer, etw, tracing]
last_modified_date: 2026-10-03
---

## 为 Internet Explorer 收集 ETW 跟踪

1. 下载 [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip)，然后解压。

2. 以管理员身份打开 **Command Prompt**，进入解压后的 `toolkit` 文件夹。

3. 运行 `CaptureIEEtw.bat` 开始跟踪，等待脚本暂停。

   ![开始跟踪](/assets/images/ieetw1.png)

4. 打开 IE 并复现问题，然后在 **Command Prompt** 中按 **Enter** 继续执行脚本。

   ![继续跟踪](/assets/images/ieetw2.png)

5. 脚本完成后，收集当前文件夹中的 `*.etl` 文件。

   ![停止跟踪](/assets/images/ieetw3.png)

{: .note }
> 有关更多信息，请参阅：[https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows)
