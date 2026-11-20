---
title: Capture Windows Authentication ETW Traces
parent: Windows & Networking
grand_parent: Guides
nav_order: 5
description: "Capture ETW traces for Windows authentication troubleshooting."
tags: [windows, authentication, etw]
last_modified_date: 2026-11-20
---

## Capture ETW traces for Windows authentication

1. Create the `C:\Temp\Auth` folder. Right-click [start-auth.ps1]({% link assets/Scripts/Auth-Script/start-auth.ps1 %}) and [stop-auth.ps1]({% link assets/Scripts/Auth-Script/stop-auth.ps1 %}), select **Save link as**, and save both files in that folder.

2. Open **PowerShell** as an administrator, then go to `C:\Temp\Auth`.

3. Run the following command to start capturing.

   ```powershell
   .\start-auth.ps1
   ```

4. Reproduce the issue.

5. Run the following command to stop capturing, then wait for the script to finish.

   ```powershell
   .\stop-auth.ps1
   ```

6. Verify the output files are created at `authlogs` folder in the current directory.
