---
title: 使用 Fiddler 捕获浏览器流量
permalink: /zh/docs/Browsers/fiddler/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 13
description: "配置 Fiddler Classic 以解密 HTTPS 流量并捕获浏览器请求。"
tags: [fiddler, networking, http]
last_modified_date: 2026-08-02
---

## 使用 Fiddler

### 前提条件

1. [下载](https://www.telerik.com/download/fiddler)并安装 Fiddler。

    {: .note }
    > 有关更多信息，请参阅：[https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/InstallFiddler](https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/InstallFiddler)

2. 打开 Fiddler，转到 `Tools -> Options -> HTTPS tab`，然后勾选 **Decrypt HTTPS traffic**。

    ![解密 HTTPS 流量](/assets/images/fiddler1.jpg)

3. 针对即将安装 FiddlerRoot 的安全警告选择 **OK**。

    ![安装 FiddlerRoot](/assets/images/fiddler2.jpg)

    {: .note }
    > 有关更多信息，请参阅：
    >
    > - [https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/decrypthttps](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/decrypthttps)
    > - [https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/trustfiddlerrootcert](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/trustfiddlerrootcert)

### 捕获 Fiddler 流量

1. 在工具栏中选择 **Remove all** 和 **Clear Cache**。

    ![移除全部](/assets/images/fiddler3.jpg)

    ![清除缓存](/assets/images/fiddler4.jpg)

2. 选择 `File -> Capture Traffic` 开始捕获。

    ![捕获流量 1](/assets/images/fiddler5.jpg)

    ![捕获流量 2](/assets/images/fiddler6.jpg)

3. **重现问题**。

4. 再次选择 `File -> Capture Traffic` 停止捕获。然后选择 `File -> Save -> all Sessions` 将流量保存到磁盘。

    ![停止记录](/assets/images/fiddler7.jpg)

{: .note }
> 有关更多信息，请参阅：[https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/capturing-traffic/configurebrowsers#chrome-edge-and-brave](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/capturing-traffic/configurebrowsers#chrome-edge-and-brave)
