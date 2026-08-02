---
title: 使用 PerfView 抓取 IIS 性能跟踪
permalink: /zh/docs/IIS/perfview/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 9
description: "使用 PerfView 收集 CPU、内存和 ETW 性能跟踪。"
tags: [iis, performance, perfview]
last_modified_date: 2026-08-02
---

## 使用 PerfView 收集性能跟踪

本指南说明如何使用 PerfView 工具抓取详细性能数据，包括 IIS 和线程时间信息。

### 环境

- **操作系统**：Windows Server / Windows Desktop
- **工具**：PerfView（最新版本）
- **权限**：需要管理员权限

### 步骤

1. 下载 [PerfView.exe](https://github.com/Microsoft/perfview/releases) 二进制文件，并以管理员身份运行。

2. 从顶部菜单栏选择 **Collect**，然后选择 **Collect**（或按 `Alt+C`）。

3. **配置收集参数**

   在配置窗口中，应用以下设置以确保抓取完整数据：

   - **Zip**：启用（选中）。
   - **Circular MB**：设置为 `1000` 或更高，以防止缓冲区被覆盖。
   - **Merge**：启用（选中）。
   - **Thread Time**：启用（选中），用于抓取 CPU 使用情况和阻塞。
   - **IIS**：启用（选中），用于抓取 Web 服务器特定事件。

   {: .tip }
   > 抓取前请验证配置屏幕与所需参数一致，因为缺少标志可能导致跟踪不完整。

4. 选择 **Start Collection** 按钮。

5. 在重现性能问题时保持跟踪运行（此场景通常约 **2 分钟**）。

6. 抓取时间结束后，选择 **Stop Collection**。

   {: .warning }
   > **不要立即关闭 PerfView。** 工具必须将收集的数据合并为单个 `.etl.zip` 文件。此过程可能需要几分钟，具体取决于跟踪大小。
