---
title: 抓取 IIS Time Travel 跟踪
permalink: /zh/docs/IIS/iisttt/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 8
description: "为 IIS 工作进程抓取 Time Travel Tracing 录制。"
tags: [iis, ttd, debugging]
last_modified_date: 2026-08-02
---

## 为 IIS 工作进程抓取 TTT 跟踪

1. 下载 [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip)，然后解压缩。

2. 以管理员身份打开 **Command Prompt**，然后根据系统架构转到 toolkit 中的 `TTD_x86` 或 `TTD_x64`。

3. 创建目标文件夹 `c:\tttoutput` 来保存输出日志。

4. 查找 `w3wp.exe` 的 **PID**。有关指南，请参阅[查找目标 w3wp.exe 进程的 PID](/zh/docs/IIS/iisprocdump/#附录-1-如何查找目标-w3wpexe-进程的-pid)

5. 将 `PID` 替换为实际值，然后运行它以开始跟踪：

   ```bash
   tttracer -attach PID -bg -noUI -dumpFull -out c:\tttoutput
   ```

6. 重现问题。

7. 完成后，运行以下命令停止跟踪：

   ```bash
   tttracer -stop all
   ```

   ![停止 TTT 跟踪](/assets/images/ttt1.png)

8. 检查是否已在 `c:\tttoutput` 中生成 TTT 跟踪文件。
