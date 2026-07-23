---
title: Collect Microsoft Edge Debug Logs
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 5
description: "Enable Microsoft Edge command-line logging and collect chrome_debug.log."
tags: [edge, logging, chromium]
last_modified_date: 2025-12-30
---

## Collect chrome_debug.log on Edge

1. Fully close Microsoft Edge, then start it from **Run** using the following command:

   ```text
   msedge.exe --enable-logging --v=1
   ```

   ![Run dialog with msedge.exe logging flags](/assets/images/chrome_debug.png)

2. Reproduce the issue.

3. Collect the log file from:

   ```text
   %LOCALAPPDATA%\Microsoft\Edge\User Data\chrome_debug.log
   ```

Reference: [https://support.google.com/chrome/a/answer/6271282?hl=en#zippy=%2Cwindows](https://support.google.com/chrome/a/answer/6271282?hl=en#zippy=%2Cwindows)
