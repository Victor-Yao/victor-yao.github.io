---
title: 收集 Microsoft Teams WebView2 崩溃诊断数据
permalink: /zh/docs/Browsers/teams-webview2-crash/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 22
description: "在不更改 Crashpad 权限的情况下收集受支持的 Teams、Windows 和现有 WebView2 崩溃数据。"
tags: [teams, webview2, crash]
last_modified_date: 2026-08-02
---

## 收集 Microsoft Teams WebView2 崩溃诊断数据

当 Microsoft Teams 桌面客户端因疑似 WebView2 故障而崩溃或关闭时，请使用本指南。

{: .warning }
> 不要拒绝 Teams Crashpad 目录的删除权限，不要添加系统范围的堆转储环境变量，不要启用内部 Teams 工程菜单，也不要故意触发 `edge://crash`。这些不受支持的更改可能干扰 Teams 更新、正常崩溃处理和其他 WebView2 应用程序。

{: .important }
> Teams 日志和内存转储可能包含租户名称、用户标识符、会议和聊天元数据、URL、令牌以及内存中内容。仅收集所需文件，并使用批准的安全传输渠道。

### 1. 记录事件

重启 Teams 前，记录：

- 崩溃的本地日期和时间。
- 对应的 UTC 时间。Teams 诊断日志使用 UTC。
- 崩溃发生时正在执行的操作。
- Teams 版本，以及问题影响一个用户还是多个用户。
- Teams 是自动重启还是保持关闭。

### 2. 收集 Teams 支持文件

崩溃后尽快收集文件：

1. 在 Windows 系统托盘中选择 Teams 图标，然后选择 **Collect
   support files**。
2. 或者，按 `Ctrl + Alt + Shift + 1`。
3. 等待 **Downloading web logs** 横幅消失。
4. 打开用户的 **Downloads** 文件夹。
5. 保留生成的 Web 日志存档，并在传输前压缩 Microsoft Teams 支持日志文件。

当登录了多个帐户时，输出可能包含每个已登录帐户的诊断数据。

### 3. 导出相关 Windows 事件

1. 打开 **事件查看器**。
2. 转到 **Windows Logs > Application**。
3. 将日志筛选到事件时间窗口。
4. 包括应用程序崩溃和 Windows Error Reporting 事件，常见事件 ID 为 `1000` 和 `1001`。
5. 选择 **Save Filtered Log File As...**，并将结果保存为 `Teams-crash-Application.evtx`。

不要直接从 `%SystemRoot%\System32\Winevt\Logs` 复制实时 `Application.evtx` 文件。

### 4. 记录 WebView2 Runtime 版本

按照
[检查已安装的 WebView2 Runtime]({% link _docs_zh/Browsers/webview2.md %})
操作，并记录已安装的 Evergreen Runtime 版本，不要更改任何注册表值。

### 5. 可用时复制现有 Crashpad 转储

对于当前 Teams 包，现有 Crashpad 报告可能出现在：

```text
%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView\Crashpad\reports
```

路径可能会随 Teams 版本变化。如果目录存在，并且已经包含事件时间的转储，请在重启或更新 Teams 前将该文件复制到诊断包。

{: .warning }
> 不要更改目录所有者或访问控制列表，也不要为 `Everyone` 添加 **Deny** 条目。如果没有转储，请继续收集 Teams 和事件日志，而不是强制触发测试崩溃。

### 6. 必要时升级转储收集

如果 Microsoft Support 需要 Teams 未保留的完整转储，请使用当前支持提供的、适用于受影响 Teams 和 WebView2 版本的收集过程。说明必须标识确切进程、转储触发器、输出目录、转储限制和清理步骤。

收集完成后，不要保留已启用的持久性系统范围转储配置。

### 7. 打包并清理

1. 包含事件时间、Teams 版本、WebView2 版本、Teams 支持文件、筛选后的 Application 事件日志以及任何现有匹配转储。
2. 通过批准的支持渠道传输包。
3. 所需保留期结束后，删除临时本地副本。

此过程不会更改 Teams 配置、Crashpad 权限或系统范围转储设置，因此不需要系统回滚。

## 参考

- [Collect Teams client diagnostic logs for Microsoft support](https://learn.microsoft.com/en-us/microsoftteams/log-files)
- [WebView2 end-user FAQ](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq)
