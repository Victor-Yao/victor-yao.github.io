---
title: HAR with Sensitive Data
parent: Browsers
nav_order: 20
last_modified_date: 2026-06-06
---

## Capturing sensitive data in HAR logs

This guide describes how to configure browser Developer Tools to include sensitive authentication headers and cookie data when exporting an HTTP Archive (HAR) file.

### Environment

- **Browser**: Microsoft Edge, Google Chrome, or other Chromium-based browsers
- **Interface**: Developer Tools (`F12`)

### Instructions

1. **Open Developer Tools**

   Launch the browser and press `F12` or `Ctrl + Shift + I`, then go to the **Network** tab.

2. **Access settings**

   Press `F1` while the Developer Tools pane is active to open the **Settings** interface.

3. **Navigate to network settings**

   Locate the **Network** category in the sidebar, or scroll to the Network section.

4. **Enable sensitive data capture**

   Select the **Allow to generate HAR with sensitive data** option.

5. **Restart Developer Tools**

   Close the Developer Tools pane, then re-launch it to ensure the configuration takes effect before beginning the trace.

6. **Reproduce and export**

   Reproduce the reported issue while the Network tab is recording. Right-click any entry in the network log and select **Save all as HAR with content**.

7. **Revert settings**

   Once the trace is finalized, repeat steps 2 through 4 and **clear** the sensitive data option.

   {: .warning }
   > **Critical security cleanup**: Disable this option immediately after the diagnostic session. Leaving it enabled on a customer's device is a significant security risk, because all subsequent HAR exports will contain plain-text session cookies and authentication tokens.
