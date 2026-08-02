---
title: Export Browser Policies and Registry Settings
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 7
description: "Export applied Edge and Chrome policies to JSON and Windows registry files."
tags: [edge, chrome, policy]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200), Microsoft Edge Stable 151.0.4129.59, PowerShell 7.6.4
---

## Choose the export you need

Each section on this page is an independent collection task that produces one
specific artifact. Complete only the section you were asked for. These sections
are alternatives, not sequential steps.

| Collect | Section | Contents |
| --- | --- | --- |
| Edge policies as JSON | [Microsoft Edge: applied policies](#edge-policy-json) | Every policy Edge currently applies, from all sources |
| Edge policies as `.reg` | [Microsoft Edge: registry-backed policies](#edge-policy-registry) | Edge, WebView2, and Edge Update policies stored in the registry |
| Chrome policies as JSON | [Google Chrome: applied policies](#chrome-policy-json) | Every policy Chrome currently applies, from all sources |
| Chrome policies as `.reg` | [Google Chrome: registry-backed policies](#chrome-policy-registry) | Chrome and Google Update policies stored in the registry |

{: .important }
> The JSON and `.reg` exports are not interchangeable. A JSON export reports the
> effective policy set from every source, including cloud management and
> command-line policies. A `.reg` export contains only the values stored under
> the registry keys listed in its section, but it can be compared against, or
> reimported on, another machine.

## Microsoft Edge: export applied policies to JSON
{: #edge-policy-json }

{: .note }
> Independent section. Complete only these steps. The other sections on this page are alternative exports, not later steps.

1. Go to `edge://policy` in Microsoft Edge.
2. Select **Export to JSON**, then save the file to disk.

    ![Export to JSON](/assets/images/edgepolicy.png)

## Microsoft Edge: export registry-backed policies
{: #edge-policy-registry }

{: .note }
> Independent section. Complete only these steps. The other sections on this page are alternative exports, not later steps.

Run the following commands in PowerShell:

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

$policyKeys = [ordered]@{
    # Microsoft Edge browser policies
    'HKLM\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hklm.reg'
    'HKCU\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hkcu.reg'
    # Microsoft Edge WebView2 policies
    'HKLM\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hklm.reg'
    'HKCU\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hkcu.reg'
    # Microsoft Edge and WebView2 Runtime update policies
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

| File | Registry key | Scope |
| --- | --- | --- |
| `edge-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge` | All users on the machine |
| `edge-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge` | The current user |
| `edge-webview2-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\WebView2` | Machine-wide WebView2 policies |
| `edge-webview2-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge\WebView2` | Current-user WebView2 policies |
| `edge-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate` | Edge and WebView2 Runtime install/update policies |

The Edge root exports are recursive, so they already include a nested `WebView2` key when it exists. The separate WebView2 files make those policies easier to test independently. `EdgeUpdate` contains update policies for both Microsoft Edge and the WebView2 Runtime.

The script checks each key before exporting and prints one status line per key. A key that reports `Not configured` simply means that policy family or hive is not present, which is normal on most machines, and no file is created for it.

## Google Chrome: export applied policies to JSON
{: #chrome-policy-json }

{: .note }
> Independent section. Complete only these steps. The other sections on this page are alternative exports, not later steps.

1. Go to `chrome://policy` in Google Chrome.
2. Select **Export to JSON**, then save the file to disk.

## Google Chrome: export registry-backed policies
{: #chrome-policy-registry }

{: .note }
> Independent section. Complete only these steps. The other sections on this page are alternative exports, not later steps.

Run the following commands in PowerShell:

```powershell
$destination = Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry'
New-Item -ItemType Directory -Path $destination -Force | Out-Null

$policyKeys = [ordered]@{
    # Google Chrome browser policies
    'HKLM\SOFTWARE\Policies\Google\Chrome' = 'chrome-hklm.reg'
    'HKCU\SOFTWARE\Policies\Google\Chrome' = 'chrome-hkcu.reg'
    # Google Update policies
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

| File | Registry key | Scope |
| --- | --- | --- |
| `chrome-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome` | All users on the machine |
| `chrome-hkcu.reg` | `HKEY_CURRENT_USER\SOFTWARE\Policies\Google\Chrome` | The current user |
| `chrome-update-hklm.reg` | `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update` | Chrome and Google Update policies |

The Chrome root exports include all nested browser policy keys. A key that reports `Not configured` is not present on the machine, and no file is created for it.

## Handling exported policy data

{: .warning }
> Policy exports can contain sensitive internal URLs, identifiers, and enrollment values. Review the JSON and `.reg` files before sharing them, and follow the [usage and data privacy guidance]({% link disclaimer.md %}).
