---
title: 收集 Microsoft Defender SmartScreen 诊断数据
permalink: /zh/docs/Browsers/SmartScreenChecklist/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 8
description: "收集调查 Edge 中 Microsoft Defender SmartScreen 行为所需的日志和跟踪。"
tags: [edge, smartscreen, security]
last_modified_date: 2026-08-02
---

## Edge 的 SmartScreen 检查清单

### 启用 SmartScreen 调试日志

1. 打开事件查看器，然后转到 `Applications and Services Logs > Microsoft > Windows > SmartScreen > Debug`。

2. 选择 **Enable Log**。

   ![事件查看器 SmartScreen Debug 日志及 Enable Log 选项](/assets/images/smartscreen1.png)

### 启用 Edge 跟踪

1. 打开 Edge 并转到 `edge://tracing`。

2. 选择 **Reload**，然后选择 **Manually select settings**。

   ![显示 Reload 和 Manually select settings 的 Edge 跟踪页面](/assets/images/smartscreen2.png)

3. 在 Record Categories 下，仅选择 **SmartScreen**，然后选择 **Record**。

   ![仅选择 SmartScreen 的 Edge 跟踪设置](/assets/images/smartscreen3.png)

### 收集日志

1. 启用 *SmartScreen 调试日志* 和 *Edge 跟踪* 后，**重现问题**。

2. 停止并保存 Edge 跟踪。

   ![停止并保存 Edge 跟踪](/assets/images/smartscreen4.png)

3. 检查 SmartScreen 调试日志中是否有任何记录，然后选择 **Save All Events As...**。

   ![保存 SmartScreen 调试日志事件](/assets/images/smartscreen5.png)

4. 转到 *Windows Security > Protection history*，展开与已阻止内容相关的任何条目。

   ![保护历史记录](/assets/images/smartscreen6.png)
