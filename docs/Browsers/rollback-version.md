---
title: Rollback Edge & Webview2 version
parent: Browsers
grand_parent: Guides
nav_order: 9
description: "Configure Group Policy to roll Microsoft Edge and WebView2 back to a target version."
tags: [edge, webview2, group-policy]
last_modified_date: 2026-02-01
---

## Rollback Edge with group policy

1. Open group policy editor and go to *Computer Configuration>Administrative Templates>Microsoft Edge Update>Applications>Microsoft Edge*

2. Select **Rollback to target version** and then select **Enabled**.

3. Select **Target version override** and input the **target version** you want to roll back to. Note: You can only roll back up to 3 versions before the current version. For example, if the current version is 144, you can roll back to 141 at the earliest.

4. Select **Update policy override** and then select **Enabled**. Choose **Always allow updates** under options.

5. Go to `edge://settings/help` and verify the Edge version has been rolled back to the target version.
