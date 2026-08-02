---
title: 导出组策略报告
permalink: /zh/docs/general/gpresult/
parent: Windows 与网络
grand_parent: 指南
nav_order: 2
description: "使用 gpresult 导出计算机和用户组策略设置的 HTML 报告。"
tags: [windows, group-policy]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 企业版（内部版本 26200）
---

## 导出组策略报告

1. 以管理员身份启动命令提示符。

2. 运行以下命令：

   ```bat
   gpresult /h C:\GPReport.html
   ```

   ![gpresult 命令的输出示例](/assets/images/gpresult1.png)

3. 复制并发送生成的 `GPReport.html`。

