---
title: 审核 IIS 配置更改
permalink: /zh/docs/IIS/iisconfigaudit/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 10
description: "启用 IIS 配置审核，以识别谁更改了设置以及修改了哪些内容。"
tags: [iis, configuration, auditing]
last_modified_date: 2026-08-02
---

## 启用 IIS 配置审核

本指南说明如何启用 IIS 配置操作日志，以审核谁修改了 IIS 设置以及应用了哪些更改。

### 环境

- **OS**：Windows Server
- **Feature**：IIS Configuration（Operational Logs）

### 步骤

1. 启动 **Event Viewer**（`eventvwr.msc`）。

2. 在控制台树中转到以下路径：

   `Applications and Services Logs` > `Microsoft` > `Windows` > `IIS-Configuration`

3. 右键单击 **Operational** 日志并选择 **Enable Log**。

4. 重现问题。

5. 返回 **Operational** 日志查看条目，然后右键单击 **Operational** 并选择 **Save All Events As...**。

6. 或者，直接从系统目录收集原始 `.evtx` 文件：

   ```text
   %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-IIS-Configuration%4Operational.evtx
   ```

{: .tip }
>
> - 可以通过右键单击 **Operational**、选择 **Properties** 并更新 **Log path** 字段，修改日志存储位置和最大文件大小。
> - 配置审核日志对于识别谁修改了 IIS 设置，并准确判断对 `applicationHost.config` 应用了哪些更改非常重要。
