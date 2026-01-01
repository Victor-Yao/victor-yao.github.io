---
title: IIS Related
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## IIS-related information

1. applicationHost.config

    The server-level configuration file for IIS. The path is `%windir%\System32\inetsrv\config\applicationHost.config`.

2. web.config

    The application-level configuration file for a website. It is usually located in the application root directory. It is normal for this file to be missing in some scenarios.

    ![web.config example](/assets/images/webconfig.png)

3. HTTPERR

    HTTP API error logs for Windows. The default path is `%windir%\System32\LogFiles\HTTPERR`.

    ![HTTPERR log folder](/assets/images/httperr.png)

    Reference: [https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3](https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/aspnet/site-behavior-performance/error-logging-http-apis#3)

4. hosts file

    The local hosts file is located at `%windir%\System32\drivers\etc\hosts`. You can open it with Notepad.

    ![Windows hosts file location](/assets/images/hosts.png)
