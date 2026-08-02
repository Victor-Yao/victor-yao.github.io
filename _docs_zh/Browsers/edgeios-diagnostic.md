---
title: 收集 Edge for iOS 诊断数据
permalink: /zh/docs/Browsers/edgeios-diagnostic/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 11
description: "从 Microsoft Edge for iOS 收集离线诊断数据。"
tags: [edge, ios, diagnostics]
last_modified_date: 2026-08-02
---

## 从 iOS 上的 Edge 收集离线诊断数据

1. 打开 Microsoft Edge，转到 `edge://flags`，然后启用 **Microsoft Edge for Business debug mode**。关闭并重新打开 Edge。

    ![启用 Microsoft Edge for Business debug mode](/assets/images/edgeios-diagnostic1.jpg)

2. 重现问题。

3. 打开 **帮助和反馈**：

   1. 在 **Normal** 模式下，点击用户配置文件（左上角）。

        ![Normal 模式下的帮助和反馈](/assets/images/edgeios-diagnostic2.jpg)

   2. 在 **InPrivate** 模式下，点击更多设置（右下角）。
        
        ![InPrivate 模式打开帮助和反馈 01](/assets/images/edgeios-diagnostic3.png)

        ![InPrivate 模式打开帮助和反馈 02](/assets/images/edgeios-diagnostic4.png)

3. 打开所有选项，然后点击 **共享**。

    ![勾选所有选项](/assets/images/edgeios-diagnostic5.jpg)

4. 将诊断数据文件保存到本地。

    ![将文件保存到本地](/assets/images/edgeios-diagnostic6.jpg)
