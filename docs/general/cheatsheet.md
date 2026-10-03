---
title: Cheatsheet
parent: Windows & Networking
grand_parent: Guides
nav_order: 13
description: "Quick commands and methods for checking software versions, system details, and configuration."
tags: [cheatsheet, windows, powershell, dotnet]
last_modified_date: 2026-10-03
---

Run in **PowerShell** on Windows. Set `$outputFile` to your preferred
path; the output directory must already exist.

## Windows version and architecture

```powershell
$outputFile = 'C:\Logs\Windows-version.txt'
Get-ComputerInfo -Property OsName, OsVersion, OsBuildNumber, OsArchitecture |
    Format-List |
    Out-File -LiteralPath $outputFile -Encoding utf8 -ErrorAction Stop
```

## .NET Framework 4.x version

The first query overwrites the file; the second appends.

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

## References

- [Get-ComputerInfo](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-computerinfo)
- [Determine installed .NET Framework versions](https://learn.microsoft.com/en-us/dotnet/framework/install/how-to-determine-which-versions-are-installed)
- [Out-File](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)
