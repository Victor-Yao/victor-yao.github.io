---
title: 抓取 IIS ETW 跟踪
permalink: /zh/docs/IIS/iisetw/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 7
description: "使用提供的收集脚本抓取 IIS ETW 跟踪。"
tags: [iis, etw, tracing]
last_modified_date: 2026-10-03
---

## 收集 IIS 的 Windows 事件跟踪

1. 下载 [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip)，然后解压。

2. 以管理员身份打开 **Command Prompt**，进入解压后的 `toolkit` 文件夹。

3. 运行 `iisetw.bat` 开始跟踪，等待脚本暂停。

   ![运行 iisetw.bat](/assets/images/iisetw1.png)

4. 复现问题，然后在 **Command Prompt** 中按 **Enter** 继续执行脚本。

   ![脚本已暂停](/assets/images/iisetw2.png)

5. 脚本完成后，收集当前文件夹中的 `*.etl` 文件。

   ![生成的 IIS ETW 跟踪](/assets/images/iisetw3.png)
