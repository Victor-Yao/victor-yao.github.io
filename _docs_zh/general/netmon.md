---
title: 使用 Network Monitor 抓取网络跟踪
permalink: /zh/docs/general/netmon/
parent: Windows 与网络
grand_parent: 指南
nav_order: 6
description: "使用 Microsoft Network Monitor 抓取并保存网络跟踪。"
tags: [windows, networking, packet-capture]
last_modified_date: 2026-08-02
---

## 使用 Network Monitor（NetMon）抓取网络跟踪

1. 在客户端和服务器上下载并安装 [Microsoft Network Monitor（NetMon）](https://www.microsoft.com/en-us/download/details.aspx?id=4865)。

   {: .note }
   > 在客户端和服务器上同时执行后续步骤。

2. 打开 NetMon，然后选择 **New Capture**。

   ![NetMon 中的 New Capture 选项](/assets/images/netmon1.jpg)

3. 选择 **Start**。

   ![NetMon 中的 Start 抓包按钮](/assets/images/netmon2.jpg)

4. 重现问题。

5. 选择 **Stop**。

   ![NetMon 中的 Stop 抓包按钮](/assets/images/netmon3.jpg)

6. 保存跟踪文件。

   ![NetMon 中的保存跟踪选项](/assets/images/netmon4.jpg)
