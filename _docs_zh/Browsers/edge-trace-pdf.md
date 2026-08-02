---
title: 为 PDF 问题捕获 Edge 跟踪
permalink: /zh/docs/Browsers/edge-trace-pdf/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 18
description: "为 Edge 中的 PDF 呈现和字体映射问题捕获聚焦的 Chromium 跟踪。"
tags: [edge, pdf, tracing]
last_modified_date: 2026-08-02
---

## 为 PDF 故障排除捕获 Edge 跟踪

本指南说明如何在 Microsoft Edge 中捕获聚焦于 PDF 呈现和字体映射逻辑的底层 Chromium 跟踪。

### 操作步骤

1. **终止所有 Edge 进程**

   打开 Command Prompt 并运行：

   ```cmd
   taskkill /f /im msedge.exe
   ```

   {: .warning }
   > `taskkill` 命令会关闭所有活动的 Edge 窗口，未保存的数据会丢失。运行前请确保所有工作已保存。

2. **使用诊断标志启动 Edge**

   使用启用目标 PDF 和字体库的功能标志启动 Edge：

   ```cmd
   msedge.exe --enable-features="msPdfSharedLibrary,msPdfEnableSkiaFontMap"
   ```

3. **验证问题重现**

   打开有问题的 PDF 文件，并确认启用这些标志后呈现问题或错误仍然发生，然后再继续跟踪。

4. **配置并开始跟踪**

   转到 `edge://tracing`，选择 **Record**，然后选择 **Manually select settings**。确保已选择以下类别：

   - `pdf_plugin`
   - `fonts`
   - `dwrite`

   选择 **Record** 开始会话。

   {: .tip }
   > 如果在手动列表中找不到特定类别，请确保 "Disabled by Default" 类别也可见，或使用 "Edit" 功能手动添加类别字符串。

5. **捕获呈现事件**

   在新标签页中打开或重新加载目标 PDF 文件。等待文档完成尝试呈现（或直到错误出现）。

6. **保存并导出**

   返回 `edge://tracing` 选项卡并选择 **Stop**。选择 **Save** 将跟踪导出为 `.json.gz` 文件，然后将生成的文件共享给技术支持团队。

## 另请参阅

- [Edge Histograms (PDF)](/zh/docs/Browsers/edge-histograms-pdf/)
- [Edge Tracing](/zh/docs/Browsers/edge-tracing/)
