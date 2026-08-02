---
title: 收集 Microsoft Edge 崩溃转储
permalink: /zh/docs/Browsers/edge-crash/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 6
description: "为 Crashpad 和 Windows Error Reporting 崩溃场景收集 Microsoft Edge 崩溃转储。"
tags: [edge, crash, memory-dump]
last_modified_date: 2026-08-02
---

Edge 浏览器中有两种不同类型的崩溃事件，收集其崩溃转储的方法也不同。请收集与你正在调查的崩溃匹配的类型——这些章节是替代方案，不是连续步骤。

## 选择崩溃类型

| 崩溃类型 | 何时收集 | 章节 |
| --- | --- | --- |
| Crashpad | 标签页、渲染器或 GPU 进程崩溃，但 Edge 本身继续运行或重启 | [Crashpad 崩溃事件](#crashpad-crash-event) |
| Windows Error Reporting | 整个 `msedge.exe` 进程终止，并且 Windows 报告应用程序崩溃 | [Windows 崩溃事件](#windows-crash-event) |

## Crashpad 崩溃事件
{: #crashpad-crash-event }

{: .note }
> 独立章节。只完成这些步骤。Windows 崩溃事件章节是替代方案，不是后续步骤。

1. 搜索 **Environment Variables**，然后打开。

    ![Environment Variables 对话框](/assets/images/edgecrashpad1.png)

2. 添加新的 **User variable**：

   * **Variable name:** `ENABLE_HEAP_DUMPS`
   * **Variable value:** `1`

    ![添加 ENABLE_HEAP_DUMPS](/assets/images/edgecrashpad2.png)

3. 转到 `edge://settings/system`，然后关闭 **Startup boost**。

    ![Startup boost 选项](/assets/images/edgecrashpad3.png)

   {: .tip }
   > 如果此设置已禁用（灰显）且无法更改，请在提升权限的 **Command Prompt** 或 **PowerShell** 中运行以下命令：

   ```bat
   REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
   ```

4. 单击 `Settings(...) -> Close Microsoft Edge` 以完全退出 Edge。重新打开 Edge，然后**重现问题**。

5. 验证转储文件已在 `%LOCALAPPDATA%\Microsoft\Edge\User Data\Crashpad\reports` 生成。

## Windows 崩溃事件
{: #windows-crash-event }

{: .note }
> 独立章节。只完成这些步骤。Crashpad 崩溃事件章节是替代方案，不是前置步骤。

1. 下载 [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip)，然后解压。

2. 将 `toolkit\msedge-wer.reg` 导入注册表。

    ![导入 reg](/assets/images/edgewer1.png)

3. 验证 `msedge.exe` 键中的值与截图中显示的完全相同：

   ```text
   HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\msedge.exe
   ```

    ![开始录制](/assets/images/edgewer2.png)

4. 在 `C:\dumps` 创建文件夹。

5. **重现问题**。

6. 验证转储文件已在 `C:\dumps` 生成。
