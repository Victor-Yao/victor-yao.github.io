---
title: 收集 Microsoft Edge 调试日志
permalink: /zh/docs/Browsers/chromedebug/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 5
description: "启用 Microsoft Edge 命令行日志记录并收集 chrome_debug.log。"
tags: [edge, logging, chromium]
last_modified_date: 2026-08-02
---

## 在 Edge 上收集 chrome_debug.log

1. 完全关闭 Microsoft Edge，然后通过 **运行** 使用以下命令启动：

   ```text
   msedge.exe --enable-logging --v=1
   ```

   ![带有 msedge.exe 日志参数的运行对话框](/assets/images/chrome_debug.png)

2. 重现问题。

3. 从以下位置收集日志文件：

   ```text
   %LOCALAPPDATA%\Microsoft\Edge\User Data\chrome_debug.log
   ```

参考：[https://support.google.com/chrome/a/answer/6271282?hl=en#zippy=%2Cwindows](https://support.google.com/chrome/a/answer/6271282?hl=en#zippy=%2Cwindows)
