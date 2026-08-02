---
title: 检查已安装的 WebView2 Runtime
permalink: /zh/docs/Browsers/webview2/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 10
description: "在不更改服务注册表值的情况下识别已安装的 Evergreen WebView2 Runtime 版本。"
tags: [webview2, runtime, registry]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 企业版（内部版本 26200）、WebView2 Runtime 151.0.4129.59、PowerShell 7.6.4
---

## 检查已安装的 WebView2 Runtime

使用官方 Microsoft Edge Update 客户端注册信息，确定是否已安装 Evergreen WebView2 Runtime，以及注册的版本。此指南中的检查均为只读。

{: .warning }
> 不要更改 `SystemComponent`、`pv` 或其他 WebView2 和 Edge Update 注册表值来让 Runtime 显示在程序和功能中。WebView2 是共享组件，更改其服务元数据可能干扰应用程序维护和更新。

### 范围

- 注册表检查会检测 **Evergreen WebView2 Runtime**。
- Fixed Version Runtime 随应用程序存储，不会通过这些 Evergreen 注册表项注册。
- 在受影响用户的 Windows 会话中运行按用户检查。
- 这些只读查询不需要管理员权限。

### 使用 PowerShell
{: #check-powershell }

{: .note }
> 本节和[手动检查注册表](#check-registry-manually)执行相同检查。使用更方便的一种即可，无需同时运行两者。

在 PowerShell 中运行以下命令：

```powershell
$clientId = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

$machinePath = if ([Environment]::Is64BitOperatingSystem) {
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$clientId"
} else {
    "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$clientId"
}

Get-ItemProperty -Path $machinePath -Name pv -ErrorAction SilentlyContinue |
    Select-Object @{Name='Scope'; Expression={'Per-machine'}}, @{Name='Version'; Expression={$_.pv}}

Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$clientId" -Name pv -ErrorAction SilentlyContinue |
    Select-Object @{Name='Scope'; Expression={'Per-user'}}, @{Name='Version'; Expression={$_.pv}}
```

至少必须存在一个 `pv` 值，并且包含大于 `0.0.0.0` 的版本。没有输出表示未找到计算机或当前用户的 Evergreen Runtime 注册。

仓库还包含一个只读的
[GetInstalledWV2.ps1 脚本]({% link assets/Scripts/GetInstalledWV2.ps1 %})
，它会执行相同检查并显示匹配的注册表路径。

示例输出：

```text
Scope       Version        RegistryPath
-----       -------        ------------
Per-machine 150.0.4078.48  HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

### 手动检查注册表
{: #check-registry-manually }

{: .note }
> 本节和[使用 PowerShell](#check-powershell)执行相同检查。使用更方便的一种即可，无需同时运行两者。

在 64 位 Windows 上，检查：

```text
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

在 32 位 Windows 上，改用以下按计算机路径：

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

仅读取 `pv` 值。不要修改或导出无关的 Edge Update 客户端注册。

### 应用程序级检测

WebView2 应用程序安装程序应使用 `GetAvailableCoreWebView2BrowserVersionString` 来检测可用 Runtime，而不是仅依赖卸载条目或程序和功能。

## 参考

- [Detect whether the WebView2 Runtime is installed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution#detect-if-a-webview2-runtime-is-already-installed)
- [WebView2 Runtime distribution](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution)
- [Evergreen versus Fixed Version distribution](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/evergreen-vs-fixed-version)
