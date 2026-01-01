---
title: Edge Crashpad
parent: Browsers
nav_order: 1
last_modified_date: 2025-12-31
---

## Using crashpad to capture Edge crash event.

1. Search for **Environment Variables**, then open it.

    ![Environment Variables dialog](/assets/images/edgecrashpad1.png)

2. Add a new **User variable**:

   * **Variable name:** `ENABLE_HEAP_DUMPS`
   * **Variable value:** `1`

    ![Add ENABLE_HEAP_DUMPS](/assets/images/edgecrashpad2.png)

3. Go to `edge://settings/system`, then turn off **Startup boost**.
    
    ![Startup boost option](/assets/images/edgecrashpad3.png)

   > Tip: If this setting is disabled (grayed out) and you cannot change it, run the following command in an elevated **Command Prompt** or **PowerShell**:

   ```bat
   REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
   ```

4. Click `Settings(...) -> Close Microsoft Edge` to fully exit Edge. Reopen Edge, then **reproduce the issue**.

5. Verify the dump file is generated at `%LOCALAPPDATA%\Microsoft\Edge\User Data\Crashpad\reports`.
