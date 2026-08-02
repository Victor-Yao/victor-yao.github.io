---
title: 使用 Wireshark 抓取网络跟踪
permalink: /zh/docs/general/wireshark/
parent: Windows 与网络
grand_parent: 指南
nav_order: 7
description: "使用 Wireshark 抓取并保存数据包跟踪。"
tags: [networking, packet-capture, wireshark]
last_modified_date: 2026-08-02
---

## 使用 Wireshark 抓取网络跟踪

1. 在客户端和服务器上下载并安装 [Wireshark](https://www.wireshark.org/download.html)。

   {: .note }
   > 在客户端和服务器上同时执行后续步骤。

2. 在两台系统上以管理员身份运行 Wireshark，选择网络接口，然后开始抓取。

   ![在 Wireshark 中选择网络接口并开始抓取](/assets/images/wireshark1.jpg)

3. 重现问题。

4. 停止抓取。

   ![在 Wireshark 中停止抓取](/assets/images/wireshark2.jpg)

5. 使用有意义的名称保存跟踪文件。
