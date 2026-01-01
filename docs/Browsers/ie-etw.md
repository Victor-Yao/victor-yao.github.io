---
title: IE ETW
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Collect a ETW trace for Internet Explorer

1. Download [mytools.zip](/assets/mytools.zip), then unzip it.

2. Open **Command Prompt** as an administrator, then go to `mytools`.

3. Run `CaptureIEEtw.bat` for start tracing, then wait it pauses.

   ![start tracing](/assets/images/ieetw1.png)

5. Open IE, reproduce the issue, then press **Enter** in the Command Prompt for continue tracing.

   ![continue tracing](/assets/images/ieetw2.png)

6. After tracing finishes, verify many `*.etl` files are created at current folder.

   ![stop tracing](/assets/images/ieetw3.png)

> For more information, see:[https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows)