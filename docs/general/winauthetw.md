---
title: ETW for Windows
parent: General
nav_order: 1
last_modified_date: 2025-12-29
---

## Capture ETW traces for Windows authentication

1. Download [mytools.zip](/assets/mytools.zip), then unzip it.

2. Open **Power Shell** as an administrator, then go to `mytools\Auth-Script`.

3. Run the following command to start capturing.

   ```powershell
   .\start-auth.ps1
   ```

4. Reproduce the issue.

5. Run Run the following command to stop capturing, then wait for the script to finish.

   ```powershell
   .\stop-auth.ps1
   ```

6. Verify the output files are created at `authlogs` folder in the current directory.
