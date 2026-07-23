---
title: IIS Config Auditing
parent: IIS
grand_parent: Guides
nav_order: 10
description: "Enable IIS configuration auditing to identify who changed settings and what was modified."
tags: [iis, configuration, auditing]
last_modified_date: 2026-06-06
---

## Enabling IIS configuration auditing

This guide describes how to enable IIS configuration operational logging to audit who modified IIS settings and what changes were applied.

### Environment

- **OS**: Windows Server
- **Feature**: IIS Configuration (Operational Logs)

### Procedure

1. Launch **Event Viewer** (`eventvwr.msc`).

2. Go to the following path in the console tree:

   `Applications and Services Logs` > `Microsoft` > `Windows` > `IIS-Configuration`

3. Right-click the **Operational** log and select **Enable Log**.

4. Reproduce the issue.

5. Go back to the **Operational** log to view the entries, then right-click **Operational** and select **Save All Events As...**.

6. Alternatively, collect the raw `.evtx` file directly from the system directory:

   ```text
   %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-IIS-Configuration%4Operational.evtx
   ```

{: .tip }
>
> - The log storage location and maximum file size can be modified by right-clicking **Operational**, selecting **Properties**, and updating the **Log path** field.
> - Configuration auditing logs are essential for identifying who modified IIS settings and determining exactly what changes were applied to `applicationHost.config`.
