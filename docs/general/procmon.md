---
title: Procmon trace
parent: General
nav_order: 1
---

## Capture a Procmon trace

1. Download [Process Monitor (Procmon)](https://docs.microsoft.com/zh-cn/sysinternals/downloads/procmon).

2. Run `procmon.exe` as an administrator, then reset the filter.

   ![Reset filter in Procmon](/assets/images/procmon1.png)

   > Optional: Enable **Boot Logging** if you must reboot the server to reproduce the issue.

   ![Enable Boot Logging in Procmon](/assets/images/procmon2.png)

3. Reproduce the issue.

4. Save `Logfile.pml` to a local disk.

   ![Save Procmon log file](/assets/images/procmon3.png)
   