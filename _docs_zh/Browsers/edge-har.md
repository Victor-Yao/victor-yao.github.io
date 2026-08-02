---
title: 在 Microsoft Edge 中捕获 HAR 文件
permalink: /zh/docs/Browsers/edge-har/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 1
description: "从 Microsoft Edge DevTools 捕获并导出 HTTP Archive 网络跟踪。"
tags: [edge, har, networking]
last_modified_date: 2026-08-02
---

## 从 Edge Developer tools 收集网络跟踪日志

1. 打开 Microsoft Edge，然后按 **F12** 打开 **Developer tools**。

2. 选择 **Network** 选项卡。然后选择 **Clear cache** 并启用 **Disable cache**。

    ![清除并禁用缓存](/assets/images/edgehar1.png)

3. 选择 **Record** 开始录制，然后**重现问题**。

    ![开始录制](/assets/images/edgehar2.png)

4. 问题重现且请求完成后，再次选择 **Record** 停止录制。然后选择 **Export HAR** 保存跟踪。

    ![导出录制](/assets/images/edgehar3.png)

{: .note }
> 有关详细信息，请参阅：[https://learn.microsoft.com/en-us/azure/azure-portal/capture-browser-trace#microsoft-edge](https://learn.microsoft.com/en-us/azure/azure-portal/capture-browser-trace#microsoft-edge)
