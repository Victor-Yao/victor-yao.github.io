---
title: 在 HAR 文件中捕获身份验证数据
permalink: /zh/docs/Browsers/har-sensitive-data/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 20
description: "配置 DevTools 以在 HAR 捕获中包含身份验证标头和 Cookie。"
tags: [har, authentication, sensitive-data]
last_modified_date: 2026-08-02
---

## 在 HAR 日志中捕获敏感数据

本指南说明如何配置浏览器 Developer Tools，使导出的 HTTP Archive (HAR) 文件包含敏感的身份验证标头和 Cookie 数据。

### 环境

- **浏览器**：Microsoft Edge、Google Chrome 或其他基于 Chromium 的浏览器
- **界面**：Developer Tools（`F12`）

### 操作步骤

1. **打开 Developer Tools**

   启动浏览器并按 `F12` 或 `Ctrl + Shift + I`，然后转到 **Network** 选项卡。

2. **访问设置**

   当 Developer Tools 窗格处于活动状态时按 `F1`，打开 **Settings** 界面。

3. **导航到网络设置**

   在边栏中找到 **Network** 类别，或滚动到 Network 部分。

4. **启用敏感数据捕获**

   选择 **Allow to generate HAR with sensitive data** 选项。

5. **重启 Developer Tools**

   关闭 Developer Tools 窗格，然后重新启动它，确保配置在开始跟踪前生效。

6. **重现并导出**

   在 Network 选项卡记录时重现报告的问题。右键单击网络日志中的任意条目，然后选择 **Save all as HAR with content**。

7. **还原设置**

   跟踪完成后，重复步骤 2 到 4，并**清除**敏感数据选项。

   {: .warning }
   > **关键安全清理**：诊断会话结束后立即禁用此选项。将其保留在客户设备上会带来重大安全风险，因为后续所有 HAR 导出都会包含明文会话 Cookie 和身份验证令牌。
