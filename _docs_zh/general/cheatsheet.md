---
title: Cheatsheet 速查笔记
permalink: /zh/docs/general/cheatsheet/
parent: Windows 与网络
grand_parent: 指南
nav_order: 12
description: "按主题整理软件版本、系统信息及配置检查的常用命令和方法。"
tags: [cheatsheet, windows, powershell, dotnet]
last_modified_date: 2026-10-02
---

在 Windows 上运行 **PowerShell**。按需修改 `$outputFile`，目标目录须已存在。

## Windows 版本与架构

```powershell
$outputFile = 'C:\Logs\Windows-version.txt'
Get-ComputerInfo -Property OsName, OsVersion, OsBuildNumber, OsArchitecture |
    Format-List |
    Out-File -LiteralPath $outputFile -Encoding utf8 -ErrorAction Stop
```

## .NET Framework 4.x 版本

第一条覆盖文件，第二条追加。

```powershell
$outputFile = 'C:\Logs\NET-Framework-version.txt'
Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction Stop |
    Select-Object @{Name='Computer'; Expression={$env:COMPUTERNAME}},
                  @{Name='RegistryView'; Expression={
                      if ([Environment]::Is64BitProcess) { '64-bit' } else { '32-bit' }
                  }},
                  Version, Release, Install |
    Format-List |
    Out-File -LiteralPath $outputFile -Encoding utf8 -ErrorAction Stop

Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction Stop |
    Select-Object @{Name='Computer'; Expression={$env:COMPUTERNAME}},
                  @{Name='RegistryView'; Expression={'32-bit'}},
                  Version, Release, Install |
    Format-List |
    Out-File -LiteralPath $outputFile -Encoding utf8 -Append -ErrorAction Stop
```

## 参考

- [Get-ComputerInfo](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.management/get-computerinfo)
- [确定已安装的 .NET Framework 版本](https://learn.microsoft.com/zh-cn/dotnet/framework/install/how-to-determine-which-versions-are-installed)
- [Out-File](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.utility/out-file)
