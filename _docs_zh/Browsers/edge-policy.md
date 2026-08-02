---
title: 导出浏览器策略与注册表设置
permalink: /zh/docs/Browsers/edge-policy/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 7
description: "将已生效的 Edge 与 Chrome 策略导出为 JSON 和 Windows 注册表文件。"
tags: [edge, chrome, policy]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 企业版（内部版本 26200）、Microsoft Edge Stable 151.0.4129.59、PowerShell 7.6.4
---

## 选择需要的导出方式

本页的每个小节都是**独立的**收集任务，各自产出一种特定的文件。请只完成对方要求你做的那一节。
这些小节是**互相替代的方案，不是先后执行的步骤**。

| 需要收集 | 小节 | 内容 |
| --- | --- | --- |
| Edge 策略（JSON） | [Microsoft Edge：已生效的策略](#edge-policy-json) | Edge 当前生效的全部策略，涵盖所有来源 |
| Edge 策略（`.reg`） | [Microsoft Edge：注册表中的策略](#edge-policy-registry) | 存放在注册表中的 Edge、WebView2 与 Edge Update 策略 |
| Chrome 策略（JSON） | [Google Chrome：已生效的策略](#chrome-policy-json) | Chrome 当前生效的全部策略，涵盖所有来源 |
| Chrome 策略（`.reg`） | [Google Chrome：注册表中的策略](#chrome-policy-registry) | 存放在注册表中的 Chrome 与 Google Update 策略 |

{: .important }
> JSON 与 `.reg` 两种导出**不能互相替代**。JSON 导出反映的是来自所有来源的最终生效策略集，
> 包括云端管理和命令行下发的策略；`.reg` 导出只包含对应小节所列注册表项下的值，
> 但它可以用于和另一台机器比对，或者导入到另一台机器上。

## Microsoft Edge：导出已生效的策略为 JSON
{: #edge-policy-json }

{: .note }
> 独立小节。只需完成这里的步骤。本页其他小节是可替代的导出方式，不是后续步骤。

1. 在 Microsoft Edge 中访问 `edge://policy`。
2. 选择 **Export to JSON**（导出为 JSON），然后将文件保存到本地。

    ![导出为 JSON](/assets/images/edgepolicy.png)

## Microsoft Edge：导出注册表中的策略
{: #edge-policy-registry }

{: .note }
> 独立小节。只需完成这里的步骤。本页其他小节是可替代的导出方式，不是后续步骤。

在 PowerShell 中运行以下命令：

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

$policyKeys = [ordered]@{
    # Microsoft Edge 浏览器策略
    'HKLM\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hklm.reg'
    'HKCU\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hkcu.reg'
    # Microsoft Edge WebView2 策略
    'HKLM\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hklm.reg'
    'HKCU\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hkcu.reg'
    # Microsoft Edge 与 WebView2 运行时的更新策略
    'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'    = 'edge-update-hklm.reg'
}

foreach ($key in $policyKeys.Keys) {
    if (-not (Test-Path -LiteralPath "Registry::$key")) {
        Write-Host "Not configured : $key"
        continue
    }

    $file = Join-Path $destination $policyKeys[$key]
    $output = reg.exe export $key $file /y 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Exported       : $key"
    } else {
        Write-Host "Export failed  : $key -- $output"
    }
}

Write-Host "Output folder  : $destination"
```

| 文件 | 注册表项 | 作用范围 |
| --- | --- | --- |
| `edge-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge` | 本机所有用户 |
| `edge-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge` | 当前用户 |
| `edge-webview2-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\WebView2` | 本机范围的 WebView2 策略 |
| `edge-webview2-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\WebView2` | 当前用户的 WebView2 策略 |
| `edge-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate` | Edge 与 WebView2 运行时的安装/更新策略 |

Edge 根项的导出是递归的，因此在 `WebView2` 子项存在时已经包含在内。单独导出的 WebView2 文件只是为了便于单独查看这部分策略。`EdgeUpdate` 中同时包含 Microsoft Edge 和 WebView2 运行时的更新策略。

脚本在导出前会先检查每个注册表项，并为每一项打印一行状态。显示 `Not configured` 只表示该策略类别或该注册表配置单元不存在，这在大多数机器上都是正常的，脚本不会为它生成文件。

## Google Chrome：导出已生效的策略为 JSON
{: #chrome-policy-json }

{: .note }
> 独立小节。只需完成这里的步骤。本页其他小节是可替代的导出方式，不是后续步骤。

1. 在 Google Chrome 中访问 `chrome://policy`。
2. 选择 **Export to JSON**（导出为 JSON），然后将文件保存到本地。

## Google Chrome：导出注册表中的策略
{: #chrome-policy-registry }

{: .note }
> 独立小节。只需完成这里的步骤。本页其他小节是可替代的导出方式，不是后续步骤。

在 PowerShell 中运行以下命令：

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

$policyKeys = [ordered]@{
    # Google Chrome 浏览器策略
    'HKLM\SOFTWARE\Policies\Google\Chrome' = 'chrome-hklm.reg'
    'HKCU\SOFTWARE\Policies\Google\Chrome' = 'chrome-hkcu.reg'
    # Google Update 策略
    'HKLM\SOFTWARE\Policies\Google\Update' = 'chrome-update-hklm.reg'
}

foreach ($key in $policyKeys.Keys) {
    if (-not (Test-Path -LiteralPath "Registry::$key")) {
        Write-Host "Not configured : $key"
        continue
    }

    $file = Join-Path $destination $policyKeys[$key]
    $output = reg.exe export $key $file /y 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Exported       : $key"
    } else {
        Write-Host "Export failed  : $key -- $output"
    }
}

Write-Host "Output folder  : $destination"
```

| 文件 | 注册表项 | 作用范围 |
| --- | --- | --- |
| `chrome-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome` | 本机所有用户 |
| `chrome-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Google\Chrome` | 当前用户 |
| `chrome-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update` | Chrome 与 Google Update 策略 |

Chrome 根项的导出包含其下所有浏览器策略子项。显示 `Not configured` 表示该项在本机不存在，脚本不会为它生成文件。

## 导出数据的处理

{: .warning }
> 策略导出文件中可能包含内部 URL、标识符和企业注册信息等敏感内容。在发送之前请先检查 JSON 与 `.reg` 文件的内容，并遵循[使用与数据隐私说明]({% link disclaimer.md %})。
