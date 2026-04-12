---
title: Rollback Edge & Webview2 version
parent: Browsers
nav_order: 9
last_modified_date: 2026-02-01
tags:
  - How-to
---
Rollback Edge with group policy

1. Open group policy editor and go to *Computer Configuration>Administrative Templates>Microsoft Edge Update>Applications>Microsoft Edge*

2. Select **Rollback to target version** and then select **Enabled**.

3. Select **Target version override** and input the **target version** you want to roll back to. 注意，可回退的版本为当前版本之气的3个版本。比如当前版本是144，你最多能退回到141。

4. Select **Update policy override** and then select **Enabled**. Choose **Always allow updates** under options.

Go to *edge://settings/help* and verify 
