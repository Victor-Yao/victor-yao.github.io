---
title: Rollback Edge & WebView2 (MSI/GPO)
parent: Browsers
grand_parent: Guides
nav_order: 23
description: "Roll back Microsoft Edge and WebView2 Runtime versions with MSI installers and Group Policy."
tags: [edge, webview2, rollback]
last_modified_date: 2026-06-06
---

## Rolling back Microsoft Edge and WebView2 runtimes

This guide outlines the procedures for reverting Microsoft Edge and the WebView2 Runtime to a previous version. This is typically required when a specific update introduces regressions in enterprise applications or rendering engines.

### Environment

- **Operating system**: Windows 10 / 11 / Server 2016+
- **Prerequisite**: Access to the [Microsoft Edge for Business](https://www.microsoft.com/en-us/edge/business/download) download portal to obtain specific version MSIs.

### Method 1: Manual rollback via command line (MSI)

This is the most direct method for individual troubleshooting or small-scale deployments.

1. **Download the target MSI**

   Go to the Microsoft Edge for Business download page. Select the **Version**, **Build**, and **Platform** (for example, v131.0.2903.146, x64), then download the `.msi` file for either Edge or the WebView2 Runtime.

2. **Run the rollback command**

   Open a Command Prompt as Administrator. Run the installer with the `ALLOWREVERSION=1` flag to bypass the "newer version already installed" check:

   ```cmd
   msiexec /i "C:\Path\To\MicrosoftEdgeEnterpriseX64.msi" /qn ALLOWREVERSION=1
   ```

   {: .tip }
   > Use the `/qn` switch for a silent installation. For WebView2, the command structure is identical: replace the MSI path with the WebView2 Runtime installer path.

### Method 2: Enterprise rollback via Group Policy (GPO)

For large-scale environments, use Group Policy to automate the rollback and prevent the browser from immediately auto-updating back to the problematic version.

1. **Enable target version override**

   Go to `Computer Configuration > Administrative Templates > Microsoft Edge Update > Applications > Microsoft Edge`. Enable the **Target version override** policy and enter the exact version number (for example, `131.0.2903.146`).

2. **Enable rollback policy**

   Locate the **Rollback to target version** policy and set it to **Enabled**.

3. **Enable update policy override**

   Enable the **Update policy override** policy and set the options to `Always allow updates` or `Automatic silent updates only`.

### Verification

After the rollback completes, verify the current active version:

- **For Edge**: Open the browser and go to `edge://settings/help`.
- **For WebView2**: Run the following PowerShell command:

  ```powershell
  Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F11AF200-9D90-4D44-A6AA-77325D122393} | Select-Object pv
  ```

{: .important }
> Once a rollback is performed via GPO, the browser stays on that specific version indefinitely. Remember to disable the **Target version override** once a fix is released in a newer stable version, so security updates resume.

## See also

- [How to roll back Microsoft Edge to a previous version](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-rollback)
- [Download the WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2#download)
