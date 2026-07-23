---
title: tttrace for IIS
parent: IIS
grand_parent: Guides
nav_order: 8
description: "Capture a Time Travel Tracing recording for an IIS worker process."
tags: [iis, ttd, debugging]
last_modified_date: 2026-01-05
---

## Capture a TTT trace for IIS worker process

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Command Prompt** as an administrator, then go to `TTD_x86` or `TTD_x64` in the toolkit based on your system architecture.

3. Create a destination folder `c:\tttoutput` to save the output logs.

4. Find the **PID** of `w3wp.exe`. For guides, see [Find the PID of the target w3wp.exe process](/docs/IIS/iisprocdump/#appendix-1-how-to-find-the-pid-of-the-target-w3wpexe-process)

5. Replace `PID` with the actual value, then run it to start tracing:

   ```bash
   tttracer -attach PID -bg -noUI -dumpFull -out c:\tttoutput
   ```

6. Reproduce the issue.

7. Once done, stop the trace by running:

   ```bash
   tttracer -stop all
   ```

   ![Stop the TTT trace](/assets/images/ttt1.png)

8. Check if the TTT trace files were generated in `c:\tttoutput`.
