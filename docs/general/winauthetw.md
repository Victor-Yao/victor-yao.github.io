---
title: ETW for Windows
parent: General
nav_order: 1
---

## Capture ETW traces for Windows authentication

1. Download [`Auth-Script.zip`](/assets/tools/Auth-Script.zip), then unzip it.

2. Open **PowerShell** as an administrator, then go to the `Auth-Script` folder.

3. Run the following command to start capturing.

   ```powershell
   .\start-auth.ps1
   ```

   ![Start authentication ETW trace collection](/assets/images/winauthetw1.png)

4. Reproduce the issue.

5. Run Run the following command to stop capturing, then wait for the script to finish.

   ```powershell
   .\stop-auth.ps1
   ```

   ![Stop authentication ETW trace collection](/assets/images/winauthetw2.png)

6. Verify the output files are created at `authlogs` folder.

   ![Auth logs folder created by the script](/assets/images/winauthetw3.png)
