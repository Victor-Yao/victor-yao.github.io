---
title: PerfView
parent: IIS
nav_order: 9
last_modified_date: 2026-06-06
---

## Collecting performance traces using PerfView

This guide describes how to capture detailed performance data, including IIS and thread-time information, using the PerfView tool.

### Environment

- **Operating system**: Windows Server / Windows Desktop
- **Tool**: PerfView (latest version)
- **Permissions**: Administrative privileges required

### Procedure

1. Download and run the [PerfView.exe](https://github.com/Microsoft/perfview/releases) binary as an Administrator.

2. Select **Collect** from the top menu bar, then select **Collect** (or press `Alt+C`).

3. **Configure collection parameters**

   In the configuration window, apply the following settings to ensure comprehensive data capture:

   - **Zip**: Enabled (checked).
   - **Circular MB**: Set to `1000` or higher to prevent buffer overwrite.
   - **Merge**: Enabled (checked).
   - **Thread Time**: Enabled (checked) to capture CPU usage and blocking.
   - **IIS**: Enabled (checked) to capture web-server-specific events.

   {: .tip }
   > Verify that the configuration screen matches the required parameters before capturing, because missing flags may result in incomplete traces.

4. Select the **Start Collection** button.

5. Allow the trace to run while reproducing the performance issue (typically for approximately **2 minutes** in this scenario).

6. Select **Stop Collection** once the capture period is complete.

   {: .warning }
   > **Do not close PerfView immediately.** The tool must merge the collected data into a single `.etl.zip` file. This process may take several minutes depending on the trace size.
