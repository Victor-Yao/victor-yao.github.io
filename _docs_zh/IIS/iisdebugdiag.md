---
title: 使用 DebugDiag 抓取 IIS 转储
permalink: /zh/docs/IIS/iisdebugdiag/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 2
description: "配置 DebugDiag 规则以抓取 IIS 崩溃或异常内存转储。"
tags: [iis, memory-dump, debugdiag]
last_modified_date: 2026-08-02
---
## 使用 DebugDiag 为 IIS 抓取内存转储

### 前提条件

1. 下载并安装 [DebugDiag](https://www.microsoft.com/en-us/download/details.aspx?id=103453)。

2. 搜索 **DebugDiag.Collection.exe**，然后以管理员身份运行它。

   ![以管理员身份打开 DebugDiag Collection](/assets/images/debugdiag10.png)

### 选择规则类型

下面两个规则都会为同一个应用程序池创建 DebugDiag 崩溃规则。请配置与你需要抓取的内容匹配的一个规则——这些小节是替代方案，不是顺序步骤。

| 规则类型 | 抓取时机 | 小节 |
| --- | --- | --- |
| 崩溃规则 | 工作进程意外终止 | [抓取崩溃转储](#debugdiag-crash) |
| 异常规则 | 进程保持运行时抛出特定异常 | [抓取特定异常](#debugdiag-exception) |

### 抓取崩溃转储
{: #debugdiag-crash }

{: .note }
> 独立小节。只配置此规则——异常规则是替代方案，不是后续步骤。

1. 添加崩溃规则，并按截图完成向导。

   1. 选择 **Crash**。

      ![DebugDiag 中的 Add Rule 选项](/assets/images/debugdiag1.png)

   2. 选择 **A specific IIS web application pool**，然后继续。

      ![选择 Crash 规则类型](/assets/images/debugdiag2.png)

   3. 选择 **your app pool**，然后继续。

      ![选择目标进程](/assets/images/debugdiag3.png)

   4. 按截图配置高级选项，然后继续。

      ![配置崩溃规则选项](/assets/images/debugdiag11.png)

   5. 选择转储文件夹，保留默认规则名称，然后继续。

      ![选择 Userdump 路径](/assets/images/debugdiag7.png)

   6. 激活规则，然后完成。

      ![激活崩溃规则](/assets/images/debugdiag8.png)

2. 等待崩溃发生，然后验证转储文件夹中是否创建了转储文件。

    ![等待崩溃发生](/assets/images/debugdiag9.png)

### 抓取特定异常
{: #debugdiag-exception }

{: .note }
> 独立小节。只配置此规则——崩溃规则是替代方案，不是前置步骤。

1. 添加崩溃规则：

   1. 选择 **Add Rule...**。

      ![DebugDiag 中的 Add Rule 选项](/assets/images/debugdiag1.png)

   2. 选择 **A specific IIS web application pool**，然后继续。

      ![选择 Crash 规则类型](/assets/images/debugdiag2.png)

   3. 选择 **your app pool**，然后继续。

      ![选择目标进程](/assets/images/debugdiag3.png)

   4. 选择 **Exceptions**，然后继续。

      ![为崩溃规则选择 Exceptions](/assets/images/debugdiag4.png)

   5. 添加要抓取的异常，然后继续。

      ![选择异常类型](/assets/images/debugdiag5.png)

      ![完成异常设置](/assets/images/debugdiag6.png)

   6. 选择转储文件夹，保留默认规则名称，然后继续。

      ![选择 Userdump 路径](/assets/images/debugdiag7.png)

   7. 激活规则，然后完成。

      ![激活规则](/assets/images/debugdiag8.png)

2. 等待异常发生。然后验证转储文件夹中是否创建了转储文件。

    ![激活崩溃规则](/assets/images/debugdiag9.png)
