---
title: 导出 Windows 事件日志
permalink: /zh/docs/general/windows-event/
parent: Windows 与网络
grand_parent: 指南
nav_order: 1
description: "使用 PowerShell 或事件查看器导出 Windows 应用程序和系统事件日志。"
tags: [windows, event-logs, diagnostics]
last_modified_date: 2026-11-21
---

## 导出 Application 和 System 日志

本指南导出 **Application** 和 **System** 日志。如果是证书链构建或校验问题，请改为收集 [CAPI2 日志]({% link _docs_zh/general/capi2.md %})。

优先使用 PowerShell；只有在无法运行 PowerShell 命令时，才使用事件查看器。

{: .important }
> 不要清空原有事件。导出会覆盖同名文件；如需保留这些文件，请更换输出文件夹。

### 用 PowerShell 导出

1. 创建 `C:\Logs` 文件夹。
2. 在发生问题的电脑上，以管理员身份打开 **PowerShell**，然后运行：

   ```powershell
   $out = 'C:\Logs'
   wevtutil.exe epl Application "$out\Application.evtx" /ow:true
   if ($LASTEXITCODE -ne 0) { throw 'Cannot export Application log.' }
   wevtutil.exe epl System "$out\System.evtx" /ow:true
   if ($LASTEXITCODE -ne 0) { throw 'Cannot export System log.' }
   ```

3. 收集 `C:\Logs` 中的文件：

   | 文件 | 内容 |
   | --- | --- |
   | `Application.evtx` | 应用程序事件 |
   | `System.evtx` | 系统事件 |

### 改用事件查看器导出

1. 创建 `C:\Logs` 文件夹。
2. 以管理员身份打开**事件查看器（Event Viewer）**，展开 **Windows Logs**。
3. 右键 **Application**，选择**将所有事件另存为（Save All Events As...）**。

   ![Event Viewer 中的 Save All Events As 选项](/assets/images/windows-event1.png)

4. 保存类型选择 **Event Files (*.evtx)**，保存为 `C:\Logs\Application.evtx`。

   ![将事件日志另存为 .evtx 文件](/assets/images/windows-event2.png)

5. 对 **System** 重复第 3–4 步，保存为 `C:\Logs\System.evtx`。

## 参考

- [wevtutil](https://learn.microsoft.com/zh-cn/windows-server/administration/windows-commands/wevtutil)
