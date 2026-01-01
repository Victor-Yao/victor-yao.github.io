---
title: IIS ETW
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## Collect a Windows event trace for IIS

1. Download [mytools.zip](/assets/mytools.zip), then unzip it.

2. Open **Command Prompt** as an administrator, then go to `mytools`.

3. Run `iisetw.bat` for start tracing, then wait it pauses.

   ![Run iisetw.bat](/assets/images/iisetw1.png)

4. **Reproduce the issue**, then press **Enter** in the Command Prompt for continue tracing.

   ![Script paused](/assets/images/iisetw2.png)

5. After tracing finishes, verify many `*.etl` files are created at current folder.

   ![Generated IIS ETW trace](/assets/images/iisetw3.png)
