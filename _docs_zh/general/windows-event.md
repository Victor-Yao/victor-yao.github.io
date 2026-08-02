---
title: 导出 Windows 事件日志
permalink: /zh/docs/general/windows-event/
parent: Windows 与网络
grand_parent: 指南
nav_order: 1
description: "将 Windows Application 和 System 事件日志导出为 EVTX 文件。"
tags: [windows, event-logs, diagnostics]
last_modified_date: 2026-08-02
---

## 导出 Application 和 System Windows 事件日志。

1. 搜索 **Event Viewer**，然后打开它。

2. 在左侧窗格中，右键单击 **Application**（或 **System**），然后选择 **Save All Events As...**。

   ![Event Viewer 中的 Save All Events As 选项](/assets/images/windows-event1.png)

3. 使用 `.evtx` 扩展名保存文件。

   ![将事件日志另存为 .evtx 文件](/assets/images/windows-event2.png)
