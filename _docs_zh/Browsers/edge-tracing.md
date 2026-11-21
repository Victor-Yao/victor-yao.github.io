---
title: 捕获 Microsoft Edge 跟踪
permalink: /zh/docs/Browsers/edge-tracing/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 8
description: "使用内置 Chromium tracing 工具捕获底层 Microsoft Edge 跟踪。"
tags: [edge, tracing, chromium]
last_modified_date: 2026-11-21
---

## 捕获 Microsoft Edge 跟踪日志

这是记录**全部**类别的通用 Chromium 跟踪。用于没有更具体指南可用的底层浏览器问题，例如插件错误。

以下问题请改用对应的专用指南：

- PDF 呈现或字体问题：[为 PDF 问题捕获 Edge 跟踪]({% link _docs_zh/Browsers/edge-trace-pdf.md %})
- 加密（MIP）PDF：[为 PDF 问题收集 Edge 直方图]({% link _docs_zh/Browsers/edge-histograms-pdf.md %})
- SmartScreen 拦截：[收集 Microsoft Defender SmartScreen 诊断数据]({% link _docs_zh/Browsers/SmartScreenChecklist.md %})

### 环境

- **浏览器**：Microsoft Edge
- **内部工具**：`edge://tracing`

### 操作步骤

1. **访问 tracing 界面**

   启动 Microsoft Edge，转到 `edge://tracing`，然后选择 **Record**。

2. **配置捕获设置**

   在配置覆盖层中，选择 **Manually select settings**。确保列表中的**所有**类别都已选中，以确保跟踪全面，然后选择对话框底部的 **Record** 按钮。

3. **复现问题**

   屏幕顶部会出现进度条，指示缓冲区使用情况。打开新标签页或窗口并触发错误。

4. **停止跟踪**

   错误可见后，立即返回 `edge://tracing` 选项卡并选择 **Stop**。

   {: .tip }
   > 你不需要等待缓冲区使用率达到 100%。问题一旦复现就停止跟踪，以便控制文件大小。

5. **保存并导出**

   选择 **Save**，文件名保持默认或留空，然后选择 **OK**。浏览器会下载扩展名为 `.json.gz` 的文件。

## 另请参阅

- [Edge Trace (PDF)]({% link _docs_zh/Browsers/edge-trace-pdf.md %})
- [Edge Histograms (PDF)]({% link _docs_zh/Browsers/edge-histograms-pdf.md %})
