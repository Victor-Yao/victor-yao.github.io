---
title: 收集 WebView2 ETW 日志
permalink: /zh/docs/Browsers/webview2-etw/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 24
description: "使用 Windows 自带的 WPR 采集 WebView2 ETW 日志，并提交给支持工程师。"
tags: [webview2, etw, diagnostics]
last_modified_date: 2026-09-14
---

## 收集步骤

[Windows 事件跟踪（ETW）](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows) 日志记录 Windows 系统活动和 WebView2 操作的详细信息。WebView2 提供两种采集配置：

1. [WebView2_CPU.wprp]({% link assets/WebView2_CPU.wprp %})：**推荐用于大多数场景**，包含 CPU 采样。
2. [WebView2.wprp]({% link assets/WebView2.wprp %})：适用于长时间采集，不包含 CPU 采样，以减少日志体积。

以下步骤使用 `WebView2_CPU.wprp`。如需使用 `WebView2.wprp`，请改为下载该文件，并替换开始命令中的配置文件名。

1. **关闭无关应用。** 保存工作，关闭 Edge 及无关的 WebView2 应用（如 Teams、Office），保留待排查的应用。

2. **下载采集配置。** 新建 `C:\Temp\WebView2-ETW` 文件夹。右键 [WebView2_CPU.wprp]({% link assets/WebView2_CPU.wprp %})，选择**链接另存为**，保存到该文件夹。文件名保存为 `WebView2_CPU.wprp`，不要保存成 `WebView2_CPU.wprp.txt`。

3. **开始采集。** 以**管理员身份**打开**命令提示符（CMD）**，运行：

   ```bat
   wpr -start "C:\Temp\WebView2-ETW\WebView2_CPU.wprp" -filemode
   ```

4. **复现问题。**

5. **停止并保存。** 返回同一个管理员 CMD 窗口，运行：

   ```bat
   wpr -stop "C:\Temp\WebView2-ETW\trace.etl" "WebView2 issue"
   ```

6. **确认并压缩。** 等待命令成功完成。确认已生成 `C:\Temp\WebView2-ETW\trace.etl`，然后将其压缩为 ZIP 文件。

参考：[Microsoft WebView2 ETW 采集说明](https://github.com/MicrosoftEdge/WebView2Feedback/blob/main/diagnostics/etw.md)。
