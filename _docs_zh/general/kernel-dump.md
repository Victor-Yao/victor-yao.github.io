---
title: 抓取 Windows 内核转储
permalink: /zh/docs/general/kernel-dump/
parent: Windows 与网络
grand_parent: 指南
nav_order: 9
description: "配置 Windows 以便在操作系统故障时抓取内核转储或完整内存转储。"
tags: [windows, memory-dump, kernel]
last_modified_date: 2026-08-02
---

## 抓取 Windows 内核转储

本指南介绍两种**互相替代**的内核内存转储抓取方法。请**只选择其中一种，不要两种都执行**。

### 环境要求

- **操作系统**：Windows 10 / 11 / Server 2016 及以上
- **工具**：Sysinternals Suite（LiveKd、NotMyFault）
- **依赖**：必须安装 Debugging Tools for Windows（WinDbg），LiveKd 才能正常工作。

### 选择方法

| 方法 | 适用场景 | 对机器的影响 |
| --- | --- | --- |
| [方法 1：实时内核转储](#live-kernel-dump) | 系统仍在运行，需要获取当前的内核状态 | 无。系统继续正常运行 |
| [方法 2：强制崩溃转储](#forced-crash-dump) | 系统已经挂起，或分析需要完整的崩溃转储 | 机器会立即蓝屏（BSOD）并重启 |

{: .warning }
> 方法 2 会**故意让机器崩溃**。如果方法 1 已经成功生成可用的转储，就不要再执行方法 2；
> 也不要在生产系统上于约定的维护窗口之外执行它。

### 方法 1：实时内核转储（非侵入式）
{: #live-kernel-dump }

{: .note }
> 独立小节。只需完成这里的步骤。方法 2 是可替代的方案，不是后续步骤。

使用本方法可以在不让系统崩溃或重启的情况下抓取内核状态。

1. **安装调试工具**

   确认已安装 Windows SDK 或 WinDbg，使 `kd.exe` 或 `windbg.exe` 可以在系统路径中找到。

2. **以管理员身份打开命令提示符**

   以管理员身份运行 `cmd.exe`。

3. **运行 LiveKd**

   进入 `livekd.exe` 所在的目录，运行下列命令之一来生成镜像转储：

   ```cmd
   livekd -accepteula -ml -o C:\dumps\live_kernel.dmp

   livekd -accepteula -k "C:\Path\To\kd.exe" -o c:\dumps\live_kernel.dmp

   livekd -accepteula -k "C:\Path\To\kd.exe" -mp 13848 -o c:\dumps\live_kernel.dmp
   ```

4. **确认输出**

   实时抓取的文件位于：`C:\dumps\live_kernel.dmp`

   {: .tip }
   > 使用 **LiveKd** 时如果遇到符号相关的报错，请在运行工具前先设置符号路径环境变量：
   >
   > ```cmd
   > set _NT_SYMBOL_PATH=srv*C:\Symbols*https://msdl.microsoft.com/download/symbols
   > ```

### 方法 2：强制崩溃转储（侵入式）
{: #forced-crash-dump }

{: .note }
> 独立小节。只需完成这里的步骤。方法 1 是可替代的方案，不是前置步骤。

如果系统已经挂起，或者根因分析需要完整的崩溃转储，才使用本方法。

1. **配置崩溃转储设置**

   按 `Win + R`，输入 `sysdm.cpl`，依次进入**高级** > **启动和故障恢复** > **设置**。
   确认**写入调试信息**已设置为**内核内存转储**或**完整内存转储**。

2. **运行 NotMyFault**

   以管理员身份打开命令提示符，进入 `NotMyFault` 目录，运行以下命令立即触发系统崩溃（蓝屏）：

   ```cmd
   notmyfault64.exe /crash
   ```

3. **获取转储文件**

   崩溃转储文件位于：`C:\Windows\MEMORY.DMP`
