---
title: IIS log
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## Collect IIS logs

1. Open **Command Prompt** as an administrator, then run:

   ```bat
   netsh http flush logbuffer
   ```

   ![flush logbuffer](/assets/images/iislog5.png)

   > This flushes HTTP log entries cached in memory.

2. Open **IIS Manager**. Select **Sites**, then note the **Site ID** shown in the right pane.

   ![Site ID](/assets/images/iislog1.png)

3. Expand **Sites**, select the target site, then open **Logging** in the middle pane.

   ![Logging feature](/assets/images/iislog2.png)

4. Note the log file directory, then open it in **File Explorer**.

   ![log file path](/assets/images/iislog3.png)

5. In the log directory, open the folder named `W3SVC<SiteID>` that matches your site ID.

   ![W3SVC site log](/assets/images/iislog4.png)
