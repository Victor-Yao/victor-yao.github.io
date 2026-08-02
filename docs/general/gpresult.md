---
title: Export a Group Policy Report
parent: Windows & Networking
grand_parent: Guides
nav_order: 2
description: "Export an HTML report of computer and user Group Policy settings with gpresult."
tags: [windows, group-policy]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200)
---

## Export Group Policy Report

1. Launch Command Prompt as an administrator.

2. Run the following command:

   ```bat
   gpresult /h C:\GPReport.html
   ```

   ![Example output from gpresult command](/assets/images/gpresult1.png)

3. Copy and paste `GPReport.html`.
