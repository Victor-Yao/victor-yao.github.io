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

在发生问题的 Windows 电脑上操作。需要**管理员权限**；`wpr.exe` 为系统自带工具，无需额外安装。

1. **关闭无关应用。** 保存工作，关闭 Edge 及无关的 WebView2 应用（如 Teams、Office），保留待排查的应用。

2. **下载采集配置。** 新建 `C:\Temp\WebView2-ETW` 文件夹。右键 [WebView2_CPU.wprp]({% link assets/WebView2_CPU.wprp %})，选择**链接另存为**，保存到该文件夹。文件名保持为 `WebView2_CPU.wprp`，不要保存成 `.txt`。

3. **开始采集。** 以**管理员身份**打开**命令提示符（CMD）**，运行：

   ```bat
   wpr -start "C:\Temp\WebView2-ETW\WebView2_CPU.wprp" -filemode
   ```

4. **复现问题。** 确认命令执行成功后，在目标应用中复现一次，记下**发生时间（含时区）和操作步骤**。**复现后立即停止采集**，避免日志过大。

5. **停止并保存。** 返回同一个管理员 CMD 窗口，运行：

   ```bat
   wpr -stop "C:\Temp\WebView2-ETW\trace.etl" "WebView2 issue"
   ```

   等待命令成功完成，确认已生成 `C:\Temp\WebView2-ETW\trace.etl`。

{: .tip }
> 需要长时间采集时，先与支持工程师确认是否可改用 [WebView2.wprp]({% link assets/WebView2.wprp %})。该配置不含 CPU 采样，日志更小；确认后下载，并替换开始命令中的配置文件名。

## 提交日志

将 **`trace.etl` 压缩为 ZIP**，连同**发生时间及其时区、复现步骤、实际现象、应用名称和版本、WebView2 Runtime 版本**提交给支持工程师。

{: .warning }
> ETW 日志可能包含敏感信息。请使用支持工程师提供的安全上传通道，不要上传到公开的 GitHub Issue。

参考：[Microsoft WebView2 ETW 采集说明](https://github.com/MicrosoftEdge/WebView2Feedback/blob/main/diagnostics/etw.md)。
