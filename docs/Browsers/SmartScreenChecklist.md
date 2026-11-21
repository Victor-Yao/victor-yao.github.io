---
title: Collect Microsoft Defender SmartScreen Diagnostics
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 11
description: "Collect the logs and traces required to investigate Microsoft Defender SmartScreen behavior in Edge."
tags: [edge, smartscreen, security]
last_modified_date: 2026-10-03
---

## SmartScreen checklist for Edge

### Enable the SmartScreen debug log

1. Open **Command Prompt** as an administrator.

2. Create the output folder and enable the log:

   ```bat
   if not exist "C:\Logs" mkdir "C:\Logs"
   wevtutil.exe sl "Microsoft-Windows-SmartScreen/Debug" /e:true
   ```

### Enable Edge tracing

1. Open Edge and go to `edge://tracing`.

2. Select **Reload**, then choose **Manually select settings**.

   ![Edge tracing page showing Reload and Manually select settings](/assets/images/smartscreen2.png)

3. Under **Record Categories**, select **SmartScreen** only, then select **Record**.

   ![Edge tracing settings with only SmartScreen selected](/assets/images/smartscreen3.png)

### Collect logs

1. Enable the SmartScreen debug log and Edge tracing, then reproduce the issue.

2. Stop and save the Edge tracing.

   ![Stop and save the Edge trace](/assets/images/smartscreen4.png)

3. In the same administrator **Command Prompt**, export the SmartScreen log:

   ```bat
   wevtutil.exe epl "Microsoft-Windows-SmartScreen/Debug" "C:\Logs\SmartScreen-Debug.evtx"
   ```

   Use a new filename if `SmartScreen-Debug.evtx` already exists.

4. Go to **Windows Security > Protection history** and expand the relevant blocked-content entries.

   ![Protection history](/assets/images/smartscreen6.png)

### Event log location (reference)

In **Event Viewer**, the log is under **Applications and Services Logs > Microsoft > Windows > SmartScreen > Debug**. If hidden, select **View > Show Analytic and Debug Logs**.

The default log file is `%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-SmartScreen%4Debug.evtx`.
