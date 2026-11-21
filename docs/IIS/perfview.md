---
title: Capture IIS Performance Traces with PerfView
parent: IIS & Web Hosting
grand_parent: Guides
nav_order: 10
description: "Collect CPU, memory, and ETW performance traces with PerfView."
tags: [iis, performance, perfview]
last_modified_date: 2026-10-03
---

## Collecting performance traces using PerfView

Use PerfView to collect IIS and thread-time performance data.

### Environment

- **Operating system**: Windows Server / Windows Desktop
- **Tool**: PerfView (latest version)
- **Permissions**: Administrative privileges required

### Procedure

1. Download [PerfView.exe](https://github.com/Microsoft/perfview/releases) and run it as an administrator.

2. Select **Collect > Collect** or press **Alt+C**.

3. **Configure collection parameters**

   Apply these settings:

   - **Zip**: Enabled (checked).
   - **Circular MB**: Set to `1000` or higher to prevent buffer overwrite.
   - **Merge**: Enabled (checked).
   - **Thread Time**: Enabled (checked) to capture CPU usage and blocking.
   - **IIS**: Enabled (checked) to capture web-server-specific events.

   {: .tip }
   > Verify that the configuration screen matches the required parameters before capturing, because missing flags may result in incomplete traces.

4. Select the **Start Collection** button.

5. Reproduce the performance issue while tracing runs, typically for about 2 minutes in this scenario.

6. Select **Stop Collection** once the capture period is complete.

   {: .warning }
   > **Do not close PerfView immediately.** The tool must merge the collected data into a single `.etl.zip` file. This process may take several minutes depending on the trace size.
