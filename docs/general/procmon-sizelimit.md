---
title: Procmon trace with size limit
parent: General
nav_order: 1
last_modified_date: 2025-12-29
---

## Capture a Procmon trace with limited log size

1. Download [Process Monitor (Procmon)](https://docs.microsoft.com/zh-cn/sysinternals/downloads/procmon).

2. Open **Command Prompt** as an administrator, then go to the folder that contains `procmon.exe`.

3. Run the following command.

   ```bat
   Procmon.exe /AcceptEula /Minimized /Quiet /PagingFile /RingBufferSize 800
   ```

   > You can increase `/RingBufferSize` up to **4096** (4 GB).

   ![Procmon command-line capture with ring buffer](/assets/images/procmon4.png)

4. Reproduce the issue.

5. Save `Logfile.pml` to a local disk.

   ![Save Procmon log file](/assets/images/procmon3.png)

> Arguments reference

   ![Procmon usage output](/assets/images/procmon5.png)
   