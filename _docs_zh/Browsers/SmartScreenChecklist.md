---
title: 收集 Microsoft Defender SmartScreen 诊断数据
permalink: /zh/docs/Browsers/SmartScreenChecklist/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 11
description: "收集调查 Edge 中 Microsoft Defender SmartScreen 行为所需的日志和跟踪。"
tags: [edge, smartscreen, security]
last_modified_date: 2026-10-03
---

## Edge 的 SmartScreen 检查清单

### 启用 SmartScreen 调试日志

1. 以管理员身份打开 **Command Prompt**。

2. 创建输出文件夹并启用日志：

   ```bat
   if not exist "C:\Logs" mkdir "C:\Logs"
   wevtutil.exe sl "Microsoft-Windows-SmartScreen/Debug" /e:true
   ```

### 启用 Edge 跟踪

1. 打开 Edge 并转到 `edge://tracing`。

2. 选择 **Reload**，然后选择 **Manually select settings**。

   ![显示 Reload 和 Manually select settings 的 Edge 跟踪页面](/assets/images/smartscreen2.png)

3. 在 **Record Categories** 下，仅选择 **SmartScreen**，然后选择 **Record**。

   ![仅选择 SmartScreen 的 Edge 跟踪设置](/assets/images/smartscreen3.png)

### 收集日志

1. 启用 SmartScreen 调试日志和 Edge 跟踪后，复现问题。

2. 停止并保存 Edge 跟踪。

   ![停止并保存 Edge 跟踪](/assets/images/smartscreen4.png)

3. 在同一个管理员 **Command Prompt** 中导出 SmartScreen 日志：

   ```bat
   wevtutil.exe epl "Microsoft-Windows-SmartScreen/Debug" "C:\Logs\SmartScreen-Debug.evtx"
   ```

   若 `SmartScreen-Debug.evtx` 已存在，请使用新的文件名。

4. 进入 **Windows Security > Protection history**，展开相关的已阻止内容记录。

   ![保护历史记录](/assets/images/smartscreen6.png)

### 事件日志位置（参考）

在**事件查看器**中，日志位于 **Applications and Services Logs > Microsoft > Windows > SmartScreen > Debug**。若未显示，选择 **View > Show Analytic and Debug Logs**。

默认日志文件为 `%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-SmartScreen%4Debug.evtx`。
