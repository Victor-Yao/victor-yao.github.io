---
title: 抓取 ARR 和 URL Rewrite 的 FREB 跟踪
permalink: /zh/docs/IIS/frebARR/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 5
description: "为 Application Request Routing 和 URL Rewrite 问题抓取 IIS 失败请求跟踪。"
tags: [iis, freb, arr]
last_modified_date: 2026-08-02
---

## 使用 FREB 排查 ARR 和 URL Rewrite 规则

### 前提条件

安装 Freb 跟踪功能。有关详细信息，请参阅：[https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/)

### 收集日志

1. 在 **IIS Manager** 中选择目标网站，然后在 **Features View** 中打开 **Failed Request Tracing Rules**。

   ![IIS Features View 中的 Failed Request Tracing Rules](/assets/images/Freb1.png)

2. 添加 FREB 规则：

   1. 选择 **Add...**。

      ![添加失败请求跟踪规则](/assets/images/Freb2.png)

   2. 配置规则以跟踪 **URL Rewrite** 和 **ARR** 事件。

      ![配置用于 rewrite 和 ARR 跟踪的 FREB 规则](/assets/images/Freb8.png)

   3. 按需选择提供程序和详细级别。*如果 rewrite 或 requestRouting 不存在，请重新安装它。*

      ![选择 FREB 提供程序](/assets/images/Freb9.png)

   4. 完成向导。

      ![完成 FREB 规则创建向导](/assets/images/Freb10.png)

3. 返回站点级别并启用该规则。

   ![启用失败请求跟踪规则](/assets/images/Freb5.png)

4. 重现问题并收集 FREB 日志。

   ![收集失败请求跟踪日志](/assets/images/Freb6.png)

其他资源

- 下载 [URLRewrite](https://prod-iis-landing.azurewebsites.net/downloads/microsoft/url-rewrite) 和 [ARR](https://learn.microsoft.com/en-us/iis/extensions/installing-application-request-routing-arr/install-application-request-routing-version-2#step-1---download-microsoft-application-request-routing-version-2)

- [使用 Failed Request Tracing 规则排查 ARR 问题](https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/iis/health-diagnostic-performance/troubleshoot-arr-using-frt-rules)

- [使用 Failed Request Tracing 跟踪 Rewrite 规则](https://learn.microsoft.com/en-us/iis/extensions/url-rewrite-module/using-failed-request-tracing-to-trace-rewrite-rules)
