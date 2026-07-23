---
title: Export Browser Policies and Registry Settings
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 7
description: "Export applied Edge and Chrome policies to JSON and Windows registry files."
tags: [edge, chrome, policy]
last_modified_date: 2026-07-23
---

## Microsoft Edge

### Export applied policies to JSON

1. Go to `edge://policy` in Microsoft Edge.
2. Select **Export to JSON**, then save the file to disk.

    ![Export to JSON](/assets/images/edgepolicy.png)

### Export registry-backed policies

Run the following commands in PowerShell:

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Microsoft Edge browser policies
reg.exe export 'HKLM\SOFTWARE\Policies\Microsoft\Edge' "$destination\edge-hklm.reg" /y
reg.exe export 'HKCU\SOFTWARE\Policies\Microsoft\Edge' "$destination\edge-hkcu.reg" /y

# Microsoft Edge WebView2 policies
reg.exe export 'HKLM\SOFTWARE\Policies\Microsoft\Edge\WebView2' "$destination\edge-webview2-hklm.reg" /y
reg.exe export 'HKCU\SOFTWARE\Policies\Microsoft\Edge\WebView2' "$destination\edge-webview2-hkcu.reg" /y

# Microsoft Edge and WebView2 Runtime update policies
reg.exe export 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate' "$destination\edge-update-hklm.reg" /y
```

| File | Registry key | Scope |
| --- | --- | --- |
| `edge-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge` | All users on the machine |
| `edge-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge` | The current user |
| `edge-webview2-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\WebView2` | Machine-wide WebView2 policies |
| `edge-webview2-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\WebView2` | Current-user WebView2 policies |
| `edge-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate` | Edge and WebView2 Runtime install/update policies |

The Edge root exports are recursive, so they already include a nested `WebView2` key when it exists. The separate WebView2 files make those policies easier to test independently. `EdgeUpdate` contains update policies for both Microsoft Edge and the WebView2 Runtime.

If `reg.exe` reports that it cannot find a registry key, that policy family or hive is not configured and no file is created for it.

## Google Chrome

### Export applied policies to JSON

1. Go to `chrome://policy` in Google Chrome.
2. Select **Export to JSON**, then save the file to disk.

### Export registry-backed policies

Run the following commands in PowerShell:

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Google Chrome browser policies
reg.exe export 'HKLM\SOFTWARE\Policies\Google\Chrome' "$destination\chrome-hklm.reg" /y
reg.exe export 'HKCU\SOFTWARE\Policies\Google\Chrome' "$destination\chrome-hkcu.reg" /y

# Google Update policies
reg.exe export 'HKLM\SOFTWARE\Policies\Google\Update' "$destination\chrome-update-hklm.reg" /y
```

| File | Registry key | Scope |
| --- | --- | --- |
| `chrome-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome` | All users on the machine |
| `chrome-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Google\Chrome` | The current user |
| `chrome-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update` | Chrome and Google Update policies |

The Chrome root exports include all nested browser policy keys. If `reg.exe` reports that it cannot find a registry key, that policy family or hive is not configured and no file is created for it.

{: .warning }
> The JSON export shows policies from all sources, but the `.reg` files capture only policies stored in these Windows registry keys. Cloud-managed, command-line, or other non-registry policies are not included. Registry exports can contain sensitive internal URLs, identifiers, or enrollment values and should be handled securely.
