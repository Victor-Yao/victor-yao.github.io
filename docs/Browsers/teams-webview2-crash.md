---
title: Teams WebView2 Crash
parent: Browsers
grand_parent: Guides
nav_order: 22
last_modified_date: 2026-06-06
---

## Microsoft Teams WebView2 crash analysis and debugging

This guide describes how to enable full heap dumps and engineering tools to troubleshoot WebView2 crashes within Microsoft Teams.

### Environment

- **Software**: Microsoft Teams (Work or School)
- **Engine**: Microsoft Edge WebView2 Runtime
- **OS**: Windows 10 / 11

### Phase 1: Enable system-wide heap dumps

1. Press `Win + R`, type `sysdm.cpl`, and press **Enter**.

2. Go to the **Advanced** tab and select **Environment Variables**.

3. Under **System variables**, select **New** and add the following entry:

   - **Variable name**: `ENABLE_HEAP_DUMPS`
   - **Variable value**: `1`

4. Select **OK** to save the changes.

### Phase 2: Prevent Crashpad from deleting dump files

By default, the Crashpad process may delete dump files after generation or upload. Follow these steps to lock the directory:

1. Go to `%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView\Crashpad\reports`.

2. Right-click the `reports` folder and select **Properties**.

3. Go to the **Security** tab and select **Advanced**.

4. Select **Add**, then select **Select a principal**.

5. Type `Everyone` and select **OK**.

6. Change the **Type** to **Deny**.

7. Select **Show advanced permissions** and check the following:

   - `Delete subfolders and files`
   - `Delete`

8. Select **OK** on all windows to apply the restriction.

### Phase 3: Enable Teams engineering tools

1. Press `Win + R`, paste the following command, and press **Enter**:

   ```text
   notepad %localappdata%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\configuration.json
   ```

2. Add or modify the configuration to include the following JSON content:

   ```json
   {"core/devMenuEnabled": true}
   ```

3. Save the file and close Notepad.

4. **Restart the operating system** to ensure all environment variables and configurations take effect.

### Phase 4: Verification and data collection

1. **Verify dump generation**

   Launch Teams and sign in. Enter `edge://crash` in the Engineering tool from a chat or the search bar (or trigger a crash via the DevTools console). Check whether a `.dmp` file is generated in `%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView\Crashpad\reports`.

   {: .important }
   > If no dump file appears, re-verify the environment variables and directory permissions set in Phase 1 and Phase 2.

2. **Clean up**

   Manually delete any test dump files created during the verification step.

3. **Reproduce and capture**

   Wait for the actual issue to occur. Once the crash happens, collect the following data:

   {: .note }
   > **Required logs for submission:**
   >
   > - **Memory dumps**: All files inside the `\Crashpad\reports` path mentioned above.
   > - **Teams client logs**: Standard diagnostic logs captured via `Ctrl + Alt + Shift + 1`.
   > - **Event logs**: The `Application.evtx` file located at `%SystemRoot%\System32\Winevt\Logs`.
