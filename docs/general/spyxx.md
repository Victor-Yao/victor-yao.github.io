---
title: Monitor Windows Messages with Spy++
parent: Windows & Networking
grand_parent: Guides
nav_order: 9
description: "Use Spy++ to monitor Windows messages sent to an application window."
tags: [windows, debugging, ui]
last_modified_date: 2026-10-03
---

## Monitoring Windows messages via Spy++

Use [Spy++](https://learn.microsoft.com/en-us/visualstudio/debugger/introducing-spy-increment?view=visualstudio) to log Microsoft Edge window messages when investigating UI hangs, input issues, or window-management conflicts.

### Environment

- **Operating system**: Windows 10 / 11
- **Architecture**: x64 (AMD64)
- **Target application**: Microsoft Edge

### Instructions

1. **Initialize the utility**

   Download and extract `Spy++.zip`, then run `spyxx_amd64.exe` as an administrator.

2. **Configure message logging**

   In the top menu, go to **Spy > Log Messages...**.

3. **Target the Microsoft Edge window**

   In **Message Options**, drag **Finder Tool** (the target icon) onto the Edge window. Release it and confirm that the window handle and class are populated.

4. **Adjust capture scope**

   Under the **Windows** tab (or the primary selection screen), make sure additional related window options are selected to capture the full message chain (for example, parent or child windows). Select **OK** to begin monitoring.

5. **Reproduce and capture**

   Reproduce the issue and confirm that messages appear in the Spy++ log window.

6. **Export the log data**

   Once the reproduction is complete, go to **Messages > Save Log to File...** and save the file with the `.sxl` extension.

{: .tip }
>
> - Spy++ generates a significant volume of data. To keep the log file size manageable, start logging immediately before reproducing the issue and stop it immediately after.
> - Make sure `spyxx_amd64.exe` is used for 64-bit applications like Microsoft Edge. Using the 32-bit version (`spyxx.exe`) may fail to hook into the 64-bit process.
