---
title: Inspect the Installed WebView2 Runtime
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 10
description: "Identify installed Evergreen WebView2 Runtime versions without changing servicing registry values."
tags: [webview2, runtime, registry]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200), WebView2 Runtime 151.0.4129.59, PowerShell 7.6.4
---

## Inspect the installed WebView2 Runtime

Use the official Microsoft Edge Update client registration to determine whether
the Evergreen WebView2 Runtime is installed and which version is registered.
The checks in this guide are read-only.

{: .warning }
> Do not change `SystemComponent`, `pv`, or other WebView2 and Edge Update
> registry values to expose the Runtime in Programs and Features. WebView2 is a
> shared component, and changing its servicing metadata can interfere with
> application maintenance and updates.

### Scope

- The registry checks detect the **Evergreen WebView2 Runtime**.
- A Fixed Version Runtime is stored with the application and is not registered
  through these Evergreen registry keys.
- Run the per-user check in the affected user's Windows session.
- Administrator rights are not required for these read-only queries.

### Use PowerShell
{: #check-powershell }

{: .note }
> This section and [Inspect the registry manually](#check-registry-manually) perform the same check. Use whichever is more convenient — running both is unnecessary.

Run the following commands in PowerShell:

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

At least one `pv` value must exist and contain a version greater than
`0.0.0.0`. No output means that an Evergreen Runtime registration was not found
for the machine or current user.

The repository also contains a read-only
[GetInstalledWV2.ps1 script]({% link assets/Scripts/GetInstalledWV2.ps1 %})
that performs the same checks and displays the matching registry path.

Example output:

```text
Scope       Version        RegistryPath
-----       -------        ------------
Per-machine 150.0.4078.48  HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

### Inspect the registry manually
{: #check-registry-manually }

{: .note }
> This section and [Use PowerShell](#check-powershell) perform the same check. Use whichever is more convenient — running both is unnecessary.

On 64-bit Windows, check:

```text
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

On 32-bit Windows, use this per-machine path instead:

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
```

Read the `pv` value only. Do not modify or export unrelated Edge Update client
registrations.

### Application-level detection

WebView2 application installers should use
`GetAvailableCoreWebView2BrowserVersionString` to detect an available Runtime
instead of relying only on an uninstall entry or Programs and Features.

## References

- [Detect whether the WebView2 Runtime is installed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution#detect-if-a-webview2-runtime-is-already-installed)
- [WebView2 Runtime distribution](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution)
- [Evergreen versus Fixed Version distribution](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/evergreen-vs-fixed-version)
