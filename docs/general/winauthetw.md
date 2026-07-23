---
title: ETW for Windows
parent: Windows & Networking
grand_parent: Guides
nav_order: 5
description: "Capture ETW traces for Windows authentication troubleshooting."
tags: [windows, authentication, etw]
last_modified_date: 2025-12-29
---

## Capture ETW traces for Windows authentication

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Power Shell** as an administrator, then go to `toolkit\Auth-Script`.

3. Run the following command to start capturing.

   ```powershell
   .\start-auth.ps1
   ```

4. Reproduce the issue.

5. Run the following command to stop capturing, then wait for the script to finish.

   ```powershell
   .\stop-auth.ps1
   ```

6. Verify the output files are created at `authlogs` folder in the current directory.
