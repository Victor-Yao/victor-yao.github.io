---
title: 使用 Spy++ 监视 Windows 消息
permalink: /zh/docs/general/spyxx/
parent: Windows 与网络
grand_parent: 指南
nav_order: 10
description: "使用 Spy++ 监视发送到应用程序窗口的 Windows 消息。"
tags: [windows, debugging, ui]
last_modified_date: 2026-08-02
---

## 通过 Spy++ 监视 Windows 消息

本指南介绍如何使用 [Spy++](https://learn.microsoft.com/en-us/visualstudio/debugger/introducing-spy-increment?view=visualstudio) 实用工具截获并记录 Microsoft Edge 的 Windows 消息。它适用于诊断与 UI 相关的卡死、输入问题或窗口管理冲突。

### 环境

- **操作系统**：Windows 10 / 11
- **体系结构**：x64 (AMD64)
- **目标应用程序**：Microsoft Edge

### 操作步骤

1. **初始化工具**

   下载 `Spy++.zip` 存档并解压其内容。使用管理员权限启动 `spyxx_amd64.exe`。

2. **配置消息日志记录**

   在顶部菜单中，转到 **Spy** > **Log Messages...**。

3. **定位 Microsoft Edge 窗口**

   在 Message Options 对话框中找到 **Finder Tool**（雷达/目标图标）。单击并将该图标拖动到活动的 **Microsoft Edge** 窗口上。松开鼠标按钮；此时 Edge 窗口的句柄和类信息应已填充到对话框中。

4. **调整抓取范围**

   在 **Windows** 选项卡（或主选择屏幕）下，确保选择其他相关窗口选项，以抓取完整消息链（例如父窗口或子窗口）。选择 **OK** 开始监视。

5. **重现并抓取**

   在 Edge 中执行触发所报告问题的操作。监视 Spy++ 日志窗口，确保正在主动截获消息。

6. **导出日志数据**

   重现完成后，转到 **Messages** > **Save Log to File...**，并使用 `.sxl` 扩展名保存文件。

{: .tip }
>
> - Spy++ 会生成大量数据。为使日志文件大小可控，请在重现问题前立即开始记录，并在重现后立即停止。
> - 请确保对 Microsoft Edge 这类 64 位应用程序使用 `spyxx_amd64.exe`。使用 32 位版本（`spyxx.exe`）可能无法挂钩到 64 位进程。
