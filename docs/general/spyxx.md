---
title: Spy++ Messages
parent: General
grand_parent: Guides
nav_order: 10
description: "Use Spy++ to monitor Windows messages sent to an application window."
tags: [windows, debugging, ui]
last_modified_date: 2026-06-06
---

## Monitoring Windows messages via Spy++

This guide describes how to use the [Spy++](https://learn.microsoft.com/en-us/visualstudio/debugger/introducing-spy-increment?view=visualstudio) utility to intercept and log Windows messages for Microsoft Edge, which is useful for diagnosing UI-related hangs, input issues, or window-management conflicts.

### Environment

- **Operating system**: Windows 10 / 11
- **Architecture**: x64 (AMD64)
- **Target application**: Microsoft Edge

### Instructions

1. **Initialize the utility**

   Download the `Spy++.zip` archive and extract its contents. Launch `spyxx_amd64.exe` with Administrator privileges.

2. **Configure message logging**

   In the top menu, go to **Spy** > **Log Messages...**.

3. **Target the Microsoft Edge window**

   Locate the **Finder Tool** (the radar/target icon) in the Message Options dialog. Click and drag the icon over the active **Microsoft Edge** window. Release the mouse button; the handle and class information for the Edge window should now be populated in the dialog.

4. **Adjust capture scope**

   Under the **Windows** tab (or the primary selection screen), make sure additional related window options are selected to capture the full message chain (for example, parent or child windows). Select **OK** to begin monitoring.

5. **Reproduce and capture**

   Perform the actions in Edge that trigger the reported issue. Monitor the Spy++ log window to ensure messages are being actively intercepted.

6. **Export the log data**

   Once the reproduction is complete, go to **Messages** > **Save Log to File...** and save the file with the `.sxl` extension.

{: .tip }
>
> - Spy++ generates a significant volume of data. To keep the log file size manageable, start logging immediately before reproducing the issue and stop it immediately after.
> - Make sure `spyxx_amd64.exe` is used for 64-bit applications like Microsoft Edge. Using the 32-bit version (`spyxx.exe`) may fail to hook into the 64-bit process.
