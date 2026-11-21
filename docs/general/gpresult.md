---
title: Export a Group Policy Report
parent: Windows & Networking
grand_parent: Guides
nav_order: 11
description: "Export an HTML report of computer and user Group Policy settings with gpresult."
tags: [windows, group-policy]
last_modified_date: 2026-10-03
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200)
---

## Export Group Policy Report

1. Open **Command Prompt** as an administrator.

2. Run the following command:

   ```bat
   gpresult /h C:\GPReport.html
   ```

3. Collect `C:\GPReport.html`.
