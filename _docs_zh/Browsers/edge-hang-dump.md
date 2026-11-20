---
title: 收集 Edge 和 Chrome 无响应转储
permalink: /zh/docs/Browsers/edge-hang-dump/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 25
description: "使用 ProcDump 和收集脚本，为无响应的 Microsoft Edge 或 Google Chrome 抓取完整内存转储。"
tags: [edge, chrome, hang, memory-dump, procdump]
last_modified_date: 2026-11-20
---

## 收集转储

当浏览器显示**未响应**且无法自行恢复时，使用本指南。[Collect-BrowserHangDump.ps1]({% link assets/Scripts/Collect-BrowserHangDump.ps1 %}) 脚本使用 ProcDump，为浏览器主进程和 GPU 进程抓取多个完整转储。

{: .important }
> 必须在**浏览器无响应期间**抓取转储。脚本完成前，不要关闭浏览器。

### 问题发生前的准备

1. 创建 `C:\Dumps` 文件夹。
2. 下载 [ProcDump](https://learn.microsoft.com/sysinternals/downloads/procdump)，将 `procdump64.exe` 解压到 `C:\Dumps`。
3. 下载 [Collect-BrowserHangDump.ps1]({% link assets/Scripts/Collect-BrowserHangDump.ps1 %}) 到 `C:\Dumps`。

   ```text
   C:\Dumps
   ├── procdump64.exe
   └── Collect-BrowserHangDump.ps1
   ```

4. 确保 C 盘至少有 10 GB 可用空间。

### 问题发生时抓取

1. 保持无响应的浏览器打开，不要选择**关闭程序**或**结束任务**。
2. 以管理员身份打开 **PowerShell**，然后运行：

   ```powershell
   cd C:\Dumps
   powershell.exe -ExecutionPolicy Bypass -File .\Collect-BrowserHangDump.ps1
   ```

   如果是 Google Chrome，添加 `-Browser Chrome`。

3. 等待脚本输出以下信息，通常需要 10–30 秒：

   ```text
   Done. You can now close the browser (End task if needed).
   Please compress and upload the whole folder: C:\Dumps\EdgeHang_<timestamp>
   ```

4. 关闭浏览器。如有需要，使用**任务管理器 > 结束任务**。
5. 将整个 `C:\Dumps\EdgeHang_<timestamp>` 文件夹压缩为 ZIP 文件并上传，同时说明问题发生的时间和当时的操作，例如访问的网站和执行的操作。

{: .note }
> 转储文件包含浏览器内存，可能含有网页内容。请按照组织的数据政策处理。

## 可选参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `-Browser` | `Edge` | `Edge` 或 `Chrome` |
| `-ProcDumpPath` | `C:\Dumps\procdump64.exe` | ProcDump 路径 |
| `-OutputRoot` | `C:\Dumps` | 输出根目录 |
| `-DumpCount` | `3` | 每个进程的转储数量 |
| `-IntervalSeconds` | `5` | 两次转储之间的间隔秒数 |
| `-ExePathFilter` | *（空）* | 只针对一个通道，例如 Stable 使用 `Edge\Application` |
| `-SkipGpu` | *（关闭）* | 不抓取 GPU 进程 |

## 故障排除

| 错误 | 解决方法 |
|---|---|
| 脚本未经数字签名或无法加载 | 按上文使用 `-ExecutionPolicy Bypass`，或运行 `Unblock-File .\Collect-BrowserHangDump.ps1`。如果被组策略阻止，请联系 IT 部门。 |
| `ProcDump not found` | 将 `procdump64.exe` 放到 `C:\Dumps`，或使用 `-ProcDumpPath`。 |
| `No msedge.exe process found` | 浏览器已关闭。请在浏览器无响应期间运行脚本。 |
| `Browser process not found` | 以管理员身份运行 PowerShell。 |
| `Found N browser processes` | 同时运行了多个 Edge 通道。使用 `-ExePathFilter`。 |

## 改用任务管理器

仅在脚本或 ProcDump 无法运行时使用此方法。

1. 在浏览器无响应期间，打开**任务管理器 > 详细信息**。
2. 右键单击列标题，选择**选择列**，然后勾选**命令行**。
3. 右键单击命令行中不包含 `--type=` 的 `msedge.exe`，选择**创建内存转储文件**。间隔几秒，重复 2–3 次。
4. 对命令行包含 `--type=gpu-process` 的 `msedge.exe` 重复第 3 步。
5. 上传对话框中显示路径下的转储文件，通常位于 `%LOCALAPPDATA%\Temp`。
