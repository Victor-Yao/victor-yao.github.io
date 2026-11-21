---
title: 为 PDF 问题收集 Edge 直方图
permalink: /zh/docs/Browsers/edge-histograms-pdf/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 10
description: "为加密 PDF 和 MIP 故障排除收集 Microsoft Edge 直方图数据。"
tags: [edge, pdf, diagnostics]
last_modified_date: 2026-11-21
---

## 为 PDF 故障排除捕获 Edge 直方图

本指南用于 Microsoft Information Protection（MIP）加密的 PDF。如果是未加密 PDF 的呈现或字体问题，请改用[为 PDF 问题捕获 Edge 跟踪]({% link _docs_zh/Browsers/edge-trace-pdf.md %})。

### 环境

- **浏览器**：Microsoft Edge（基于 Chromium）
- **目标内容**：本地保存的 MIP 受保护 PDF 文件
- **诊断 URL**：`edge://histograms/`

### 操作步骤

1. **访问诊断界面**

   启动 Edge 并转到 `edge://histograms/`。

2. **初始化监视模式**

   选择标记为 **Switch to Monitor Mode** 的按钮。

   {: .note }
   > 切换到 Monitor Mode 后，按钮文本会变为 **Switch to Histogram Mode**。

3. **复现问题**

   从你的**本地存储**打开有问题的 MIP 受保护 PDF。

   {: .warning }
   > 此测试不要从 SharePoint 或 OneDrive 打开文件。文件必须存储在本地磁盘上，才能捕获相关的文件系统和敏感度引擎直方图。

4. **停止数据收集**

   返回 `edge://histograms/` 选项卡并选择 **Stop**，以完成录制。

5. **提取特定直方图类别**

   按 **Ctrl+F** 查找以下类别，逐项展开，将标题和**全部数据**复制到同一个 `.txt` 文件中。

   必需类别：

   - `Microsoft.Pdf.Diagnostics`
   - `Microsoft.Pdf.FileOpenError`
   - `Microsoft.Pdf.LoadState`
   - `Microsoft.Pdf.MIP.AccessTokenReceived.SovereigntyDetected`
   - `Microsoft.Pdf.MIPLoadState`
   - 所有以 `Microsoft.Identity.AcquireAccessToken.PdfMip` 开头的类别
   - 所有以 `Microsoft.Profile.AcquireAccessToken.PdfMip` 开头的类别

   {: .tip }
   > 复制时，请确保包含每个标题下方的直方图分布值（数字条/数据点），以便进行正确的统计分析。

## 另请参阅

- [Edge Trace (PDF)]({% link _docs_zh/Browsers/edge-trace-pdf.md %})
- [Edge Tracing]({% link _docs_zh/Browsers/edge-tracing.md %})
