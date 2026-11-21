---
title: 抓取 IIS ETW 跟踪
permalink: /zh/docs/IIS/iisetw/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 6
description: "使用提供的收集脚本抓取 IIS ETW 跟踪。"
tags: [iis, etw, tracing]
last_modified_date: 2026-11-20
---

## 收集 IIS 的 Windows 事件跟踪

1. 新建 `C:\Temp\IIS-ETW` 文件夹。右键 [iisetw.bat]({% link assets/Scripts/iisetw.bat %})，选择**链接另存为**，保存到该文件夹。

2. 以管理员身份打开 **Command Prompt**，进入 `C:\Temp\IIS-ETW`。

3. 运行 `iisetw.bat` 开始跟踪，等待脚本暂停。

   ![运行 iisetw.bat](/assets/images/iisetw1.png)

4. 复现问题，然后在 **Command Prompt** 中按 **Enter** 继续执行脚本。

   ![脚本已暂停](/assets/images/iisetw2.png)

5. 脚本完成后，收集当前文件夹中的 `*.etl` 文件。

   ![生成的 IIS ETW 跟踪](/assets/images/iisetw3.png)
