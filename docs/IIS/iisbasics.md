---
title: IIS Related
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## IIS basic information

### Configurations

1. applicationHost.config

    The server-level configuration file for IIS. The path is `%windir%\System32\inetsrv\config\applicationHost.config`.

2. web.config

    The application-level configuration file for a website. It is usually located in the application root directory. It is normal for this file to be missing in some scenarios.

    ![web.config example](/assets/images/webconfig.png)

### IIS log

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

### HTTPERR

HTTP API error logs for Windows. The default path is `%windir%\System32\LogFiles\HTTPERR`.

![HTTPERR log folder](/assets/images/httperr.png)

Reference: [https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3](https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3)

### hosts

The file path is `%windir%\System32\drivers\etc\hosts`.

![Windows hosts file location](/assets/images/hosts.png)
