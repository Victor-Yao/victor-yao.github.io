---
title: 抓取 IIS 失败请求跟踪（FREB）
permalink: /zh/docs/IIS/freb/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 4
description: "为返回指定 HTTP 状态代码的请求启用 IIS 失败请求跟踪。"
tags: [iis, freb, tracing]
last_modified_date: 2026-08-02
---

## 为特定 HTTP 状态代码启用失败请求跟踪规则

### 前提条件

安装 Freb 跟踪功能。有关详细信息，请参阅：[https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/)

### 收集日志

1. 打开 **IIS Manager**，选择目标网站，然后在 **Features View** 中打开 **Failed Request Tracing Rules**。

   ![打开 Freb](/assets/images/Freb1.png)

2. 添加规则并配置状态代码：

   1. 选择 **Add...**。

      ![添加失败请求跟踪规则](/assets/images/Freb2.png)

   2. 输入要抓取的 HTTP 状态代码（或范围）。例如，`500`。

      ![输入要跟踪的状态代码](/assets/images/Freb7.png)

   3. 选择要抓取的跟踪提供程序，然后选择 **Finish**。

      ![选择跟踪提供程序并完成向导](/assets/images/Freb3.png)

   4. 确认新规则显示在规则列表中。

      ![Failed Request Tracing Rules 列表中的新规则](/assets/images/Freb4.png)

3. 返回站点级别并启用该规则。

   ![启用失败请求跟踪规则](/assets/images/Freb5.png)

4. 重现问题并收集 FREB 日志。

   ![收集失败请求跟踪日志](/assets/images/Freb6.png)
