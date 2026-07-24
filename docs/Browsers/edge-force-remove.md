---
title: Repair Microsoft Edge and WebView2 Installation
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 16
description: "Use supported repair, reinstall, and diagnostic steps for Microsoft Edge and WebView2 installation failures."
tags: [edge, webview2, installation]
last_modified_date: 2026-07-24
---

## Repair Microsoft Edge and WebView2 installation

Use supported repair and reinstall methods when Microsoft Edge or the Evergreen
WebView2 Runtime cannot install, update, or start correctly.

{: .warning }
> Do not manually delete Edge or WebView2 program directories, Edge Update
> services and scheduled tasks, Windows Installer cache entries, or broad Edge
> registry trees. These components can be shared or protected by Windows.
> Removing them can corrupt servicing state and break Teams, Outlook, Widgets,
> and other WebView2 applications.

The legacy force-removal scripts previously associated with this page are no
longer linked or supported by this guide.

### 1. Complete the basic checks

1. Record the exact error code, affected version, installation scope, and local
   time of the failure.
2. Restart Windows to complete pending installer operations and release locked
   files.
3. Confirm that the system drive has at least 1-2 GB of free space.
4. Close Microsoft Edge and all WebView2 applications, including Teams, new
   Outlook, Widgets, and line-of-business applications.
5. In **Task Manager**, confirm that no required application is still using
   `msedge.exe` or `msedgewebview2.exe`.
6. On a managed device, review applied update and installation policies before
   changing the local installation.

### 2. Repair Microsoft Edge

Use the built-in repair first:

1. Open **Settings > Apps > Installed apps**.
2. Find **Microsoft Edge**, select **More options**, then select **Modify**.
3. Approve the administrator prompt and select **Repair**.
4. Keep the device connected to the internet while Windows downloads and
   reinstalls Edge.

The supported repair process preserves normal browser data and settings.

If **Modify** is unavailable because the device is managed, contact the device
administrator. Otherwise, download the current supported installer from the
[Microsoft Edge download page](https://www.microsoft.com/edge/download) or the
[Microsoft Edge for Business download page](https://www.microsoft.com/edge/business/download),
then run it as an administrator.

After repair, open `edge://settings/help` and confirm that Microsoft Edge starts
and updates successfully.

### 3. Repair the Evergreen WebView2 Runtime

1. Close every application that uses WebView2.
2. Download the **Evergreen Standalone Installer** matching the operating-system
   architecture from the
   [WebView2 download page](https://developer.microsoft.com/en-us/microsoft-edge/webview2#download-section).
3. Run the installer as an administrator.
4. Verify the registered Runtime version by following
   [Inspect the Installed WebView2 Runtime]({% link docs/Browsers/webview2.md %}).
5. Start the affected WebView2 application and retest it.

Do not uninstall the shared Evergreen Runtime merely to troubleshoot one
application unless the application vendor or Microsoft Support provides a
version-specific recovery procedure.

### 4. Collect installation diagnostics

If supported repair or reinstall still fails, collect the following data before
making further system changes.

#### Edge Update logs

- Per-machine installation:

  ```text
  %ALLUSERSPROFILE%\Microsoft\EdgeUpdate\Log\MicrosoftEdgeUpdate.log
  ```

- Per-user installation:

  ```text
  %LOCALAPPDATA%\Temp\MicrosoftEdgeUpdate.log
  ```

#### Installer logs

- Per-machine installation:

  ```text
  %WINDIR%\Temp\msedge_installer.log
  ```

- Per-user installation:

  ```text
  %LOCALAPPDATA%\Temp\msedge_installer.log
  ```

Also:

- [Export browser policies and registry settings]({% link docs/Browsers/edge-policy.md %}).
- Capture a short
  [Process Monitor trace]({% link docs/general/procmon.md %}) while reproducing
  the installation failure.
- Record the installer filename, command line, error code, and failure time.

{: .important }
> Installer logs, policy exports, and Process Monitor traces can contain user
> names, paths, URLs, policy values, and application data. Review and transfer
> them through an approved support channel.

### 5. Escalate unresolved servicing failures

Package the diagnostics and open a Microsoft support request when repair and
reinstall fail. Do not use registry cleaners or manually remove Windows
Installer product, component, or upgrade-code registrations as a workaround.

## References

- [Install, update, or roll back failures for Edge and Edge WebView2](https://learn.microsoft.com/en-us/troubleshoot/microsoft-edge/manageability/update-install-rollback-failures)
- [What to do if Microsoft Edge is not working](https://support.microsoft.com/en-us/edge/what-to-do-if-microsoft-edge-isn-t-working)
- [Distribute the WebView2 Runtime](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution)
