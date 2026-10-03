---
title: Capture an IIS ETW Trace
parent: IIS & Web Hosting
grand_parent: Guides
nav_order: 7
description: "Capture an IIS ETW trace with the provided collection script."
tags: [iis, etw, tracing]
last_modified_date: 2026-10-03
---

## Collect a Windows event trace for IIS

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Command Prompt** as an administrator and go to the extracted `toolkit` folder.

3. Run `iisetw.bat` to start tracing and wait for the script to pause.

   ![Run iisetw.bat](/assets/images/iisetw1.png)

4. Reproduce the issue, then press **Enter** in **Command Prompt** to continue the script.

   ![Script paused](/assets/images/iisetw2.png)

5. When the script finishes, collect the `*.etl` files from the current folder.

   ![Generated IIS ETW trace](/assets/images/iisetw3.png)
