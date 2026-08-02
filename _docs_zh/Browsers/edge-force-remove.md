---
title: 修复 Microsoft Edge 和 WebView2 安装
permalink: /zh/docs/Browsers/edge-force-remove/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 16
description: "使用受支持的修复、重新安装和诊断步骤处理 Microsoft Edge 与 WebView2 安装失败。"
tags: [edge, webview2, installation]
last_modified_date: 2026-08-02
---

## 修复 Microsoft Edge 和 WebView2 安装

当 Microsoft Edge 或 Evergreen WebView2 Runtime 无法正确安装、更新或启动时，请使用受支持的修复和重新安装方法。

{: .warning }
> 不要手动删除 Edge 或 WebView2 程序目录、Edge Update 服务和计划任务、Windows Installer 缓存项，或范围很大的 Edge 注册表树。这些组件可能由 Windows 共享或保护。删除它们可能会损坏维护状态，并破坏 Teams、Outlook、Widgets 和其他 WebView2 应用程序。

以前与此页面关联的旧版强制删除脚本不再由本指南链接或支持。

### 1. 完成基本检查

1. 记录确切的错误代码、受影响版本、安装范围和失败的本地时间。
2. 重启 Windows，以完成挂起的安装程序操作并释放锁定的文件。
3. 确认系统驱动器至少有 1-2 GB 可用空间。
4. 关闭 Microsoft Edge 和所有 WebView2 应用程序，包括 Teams、新 Outlook、Widgets 和业务线应用程序。
5. 在 **Task Manager** 中，确认没有所需应用程序仍在使用 `msedge.exe` 或 `msedgewebview2.exe`。
6. 在受管理设备上，更改本地安装前先查看已应用的更新和安装策略。

### 2. 修复 Microsoft Edge

先使用内置修复：

1. 打开 **Settings > Apps > Installed apps**。
2. 找到 **Microsoft Edge**，选择 **More options**，然后选择 **Modify**。
3. 批准管理员提示并选择 **Repair**。
4. 在 Windows 下载并重新安装 Edge 期间，让设备保持联网。

受支持的修复过程会保留正常的浏览器数据和设置。

如果由于设备受管理而无法使用 **Modify**，请联系设备管理员。否则，请从 [Microsoft Edge 下载页面](https://www.microsoft.com/edge/download)或 [Microsoft Edge for Business 下载页面](https://www.microsoft.com/edge/business/download)下载当前受支持的安装程序，然后以管理员身份运行。

修复后，打开 `edge://settings/help`，确认 Microsoft Edge 可以成功启动和更新。

### 3. 修复 Evergreen WebView2 Runtime

1. 关闭所有使用 WebView2 的应用程序。
2. 从 [WebView2 下载页面](https://developer.microsoft.com/en-us/microsoft-edge/webview2#download-section)下载与操作系统体系结构匹配的 **Evergreen Standalone Installer**。
3. 以管理员身份运行安装程序。
4. 按照[检查已安装的 WebView2 Runtime]({% link _docs_zh/Browsers/webview2.md %})验证已注册的 Runtime 版本。
5. 启动受影响的 WebView2 应用程序并重新测试。

除非应用程序供应商或 Microsoft Support 提供特定版本的恢复过程，否则不要仅为排查某个应用程序的问题而卸载共享的 Evergreen Runtime。

### 4. 收集安装诊断

如果受支持的修复或重新安装仍然失败，请在进行进一步系统更改前收集以下数据。

#### Edge Update 日志

- 按计算机安装：

  ```text
  %ALLUSERSPROFILE%\Microsoft\EdgeUpdate\Log\MicrosoftEdgeUpdate.log
  ```

- 按用户安装：

  ```text
  %LOCALAPPDATA%\Temp\MicrosoftEdgeUpdate.log
  ```

#### 安装程序日志

- 按计算机安装：

  ```text
  %WINDIR%\Temp\msedge_installer.log
  ```

- 按用户安装：

  ```text
  %LOCALAPPDATA%\Temp\msedge_installer.log
  ```

另请收集：

- [导出浏览器策略和注册表设置]({% link _docs_zh/Browsers/edge-policy.md %})。
- 在重现安装失败时，捕获一段简短的 [Process Monitor 跟踪]({% link _docs_zh/general/procmon.md %})。
- 记录安装程序文件名、命令行、错误代码和失败时间。

{: .important }
> 安装程序日志、策略导出和 Process Monitor 跟踪可能包含用户名、路径、URL、策略值和应用程序数据。请先检查内容，并通过批准的支持渠道传输。

### 5. 升级未解决的维护失败

当修复和重新安装失败时，请打包诊断数据并创建 Microsoft 支持请求。不要使用注册表清理器，也不要手动删除 Windows Installer 产品、组件或升级代码注册项作为变通方法。

## 参考

- [Edge and Edge WebView2 的安装、更新或回滚失败](https://learn.microsoft.com/en-us/troubleshoot/microsoft-edge/manageability/update-install-rollback-failures)
- [Microsoft Edge 无法正常工作时该怎么办](https://support.microsoft.com/en-us/edge/what-to-do-if-microsoft-edge-isn-t-working)
- [分发 WebView2 Runtime](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution)
