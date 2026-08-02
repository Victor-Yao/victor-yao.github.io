---
title: 查找 IIS 配置和日志文件
permalink: /zh/docs/IIS/iisbasics/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 1
description: "查找基础故障排查中使用的关键 IIS 配置和日志文件。"
tags: [iis, configuration, logging]
last_modified_date: 2026-08-02
---

## IIS 基础信息

### 配置

1. applicationHost.config

    IIS 的服务器级配置文件。路径为 `%windir%\System32\inetsrv\config\applicationHost.config`。

2. web.config

    网站的应用程序级配置文件。它通常位于应用程序根目录。在某些场景中缺少此文件是正常的。

    ![web.config 示例](/assets/images/webconfig.png)

### IIS 日志

1. 以管理员身份打开 **Command Prompt**，然后运行：

   ```bat
   netsh http flush logbuffer
   ```

   ![flush logbuffer](/assets/images/iislog5.png)

   {: .note }
   > 这会刷新缓存在内存中的 HTTP 日志条目。

2. 打开 **IIS Manager**。选择 **Sites**，然后记下右侧窗格中显示的 **Site ID**。

   ![Site ID](/assets/images/iislog1.png)

3. 展开 **Sites**，选择目标站点，然后在中间窗格中打开 **Logging**。

   ![Logging 功能](/assets/images/iislog2.png)

4. 记下日志文件目录，然后在 **File Explorer** 中打开它。

   ![日志文件路径](/assets/images/iislog3.png)

5. 在日志目录中，打开与站点 ID 匹配的 `W3SVC<SiteID>` 文件夹。

   ![W3SVC 站点日志](/assets/images/iislog4.png)

### HTTPERR

Windows 的 HTTP API 错误日志。默认路径为 `%windir%\System32\LogFiles\HTTPERR`。

![HTTPERR 日志文件夹](/assets/images/httperr.png)

参考：[https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3](https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3)

### hosts

文件路径为 `%windir%\System32\drivers\etc\hosts`。

![Windows hosts 文件位置](/assets/images/hosts.png)
