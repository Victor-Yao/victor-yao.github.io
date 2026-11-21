---
title: 使用 Spy++ 监视 Windows 消息
permalink: /zh/docs/general/spyxx/
parent: Windows 与网络
grand_parent: 指南
nav_order: 9
description: "使用 Spy++ 监视发送到应用程序窗口的 Windows 消息。"
tags: [windows, debugging, ui]
last_modified_date: 2026-10-03
---

## 通过 Spy++ 监视 Windows 消息

使用 [Spy++](https://learn.microsoft.com/en-us/visualstudio/debugger/introducing-spy-increment?view=visualstudio) 记录 Edge 窗口消息，排查界面卡死、输入问题或窗口管理冲突。

### 环境

- **操作系统**：Windows 10 / 11
- **体系结构**：x64 (AMD64)
- **目标应用程序**：Microsoft Edge

### 操作步骤

1. **初始化工具**

   下载并解压 `Spy++.zip`，以管理员身份运行 `spyxx_amd64.exe`。

2. **配置消息日志记录**

   在顶部菜单中，转到 **Spy > Log Messages...**。

3. **定位 Microsoft Edge 窗口**

   在 **Message Options** 中，将 **Finder Tool**（目标图标）拖到 Edge 窗口，松开后确认已填入窗口句柄和类名。

4. **调整抓取范围**

   在 **Windows** 选项卡（或主选择屏幕）下，确保选择其他相关窗口选项，以抓取完整消息链（例如父窗口或子窗口）。选择 **OK** 开始监视。

5. **复现并抓取**

   复现问题，确认 Spy++ 日志窗口中有消息输出。

6. **导出日志数据**

   复现完成后，转到 **Messages > Save Log to File...**，并使用 `.sxl` 扩展名保存文件。

{: .tip }
>
> - Spy++ 会生成大量数据。为使日志文件大小可控，请在复现问题前立即开始记录，并在复现后立即停止。
> - 请确保对 Microsoft Edge 这类 64 位应用程序使用 `spyxx_amd64.exe`。使用 32 位版本（`spyxx.exe`）可能无法挂钩到 64 位进程。
