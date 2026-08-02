---
title: 捕获 Edge 性能配置文件
permalink: /zh/docs/Browsers/edge-perf/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 3
description: "录制并导出 Microsoft Edge DevTools 性能配置文件。"
tags: [edge, performance, devtools]
last_modified_date: 2026-08-02
---

## 从 Edge Developer tools 收集性能录制

1. 打开 Microsoft Edge，然后按 **F12** 打开 **Developer tools**。

2. 选择 **Performance** 选项卡，选择 **Clear**，然后选择 **Record**。重现问题。

    ![开始录制](/assets/images/edgeperf1.png)

3. **重现**问题。重现后选择 **Stop**。

    ![停止录制](/assets/images/edgeperf2.png)

4. 选择 **Save trace**。

    ![保存跟踪](/assets/images/edgeperf3.png)

{: .note }
> 有关详细信息，请参阅：[https://learn.microsoft.com/en-us/microsoft-edge/devtools-guide-chromium/evaluate-performance/?source=recommendations#record-runtime-performance](https://learn.microsoft.com/en-us/microsoft-edge/devtools-guide-chromium/evaluate-performance/?source=recommendations#record-runtime-performance)
