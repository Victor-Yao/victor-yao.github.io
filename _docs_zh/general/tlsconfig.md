---
title: 收集 Windows TLS 配置
permalink: /zh/docs/general/tlsconfig/
parent: Windows 与网络
grand_parent: 指南
nav_order: 8
description: "收集 Windows TLS 协议和密码套件配置以用于故障排查。"
tags: [windows, tls, security]
last_modified_date: 2026-11-20
last_verified_date: 2026-08-02
tested_on: Windows 11 企业版（内部版本 26200）
---

## 从 Windows 获取 TLS 配置

1. 新建 `C:\Temp\TLS` 文件夹。右键 [GetTlsConfig.bat]({% link assets/Scripts/GetTlsConfig.bat %})，选择**链接另存为**，保存到该文件夹。

2. 以管理员身份打开 **Command Prompt**，进入 `C:\Temp\TLS`。

3. 运行 `GetTlsConfig.bat`。

4. 运行 `dir /B reports`，确认输出文件如下。`<computer-name>` 表示 Windows 计算机名：

   ```text
   <computer-name>_ssl1.txt
   <computer-name>_ssl2.txt
   <computer-name>_ssl3.txt
   <computer-name>_ssl4.txt
   ```
