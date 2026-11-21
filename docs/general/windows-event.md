---
title: Export Windows Event Logs
parent: Windows & Networking
grand_parent: Guides
nav_order: 1
description: "Export the Windows Application and System event logs with PowerShell or Event Viewer."
tags: [windows, event-logs, diagnostics]
last_modified_date: 2026-11-21
---

## Export the Application and System logs

This guide exports the **Application** and **System** logs. For certificate chain or validation issues, collect [CAPI2 logs]({% link docs/general/capi2.md %}) instead.

Use PowerShell. Use Event Viewer only if you cannot run PowerShell commands.

{: .important }
> Do not clear existing events. The export overwrites files with the same name; use a different output folder if those files must be retained.

### Export with PowerShell

1. Create the `C:\Logs` folder.
2. Open **PowerShell** as an administrator on the affected computer, then run:

   ```powershell
   $out = 'C:\Logs'
   wevtutil.exe epl Application "$out\Application.evtx" /ow:true
   if ($LASTEXITCODE -ne 0) { throw 'Cannot export Application log.' }
   wevtutil.exe epl System "$out\System.evtx" /ow:true
   if ($LASTEXITCODE -ne 0) { throw 'Cannot export System log.' }
   ```

3. Collect the files from `C:\Logs`:

   | File | Contents |
   | --- | --- |
   | `Application.evtx` | Application events |
   | `System.evtx` | System events |

### Export with Event Viewer instead

1. Create the `C:\Logs` folder.
2. Open **Event Viewer** as an administrator, then expand **Windows Logs**.
3. Right-click **Application**, then select **Save All Events As...**.

   ![Save All Events As option in Event Viewer](/assets/images/windows-event1.png)

4. Save it as `C:\Logs\Application.evtx` with the **Event Files (*.evtx)** type.

   ![Save event log as an .evtx file](/assets/images/windows-event2.png)

5. Repeat steps 3–4 for **System**, and save it as `C:\Logs\System.evtx`.

## References

- [wevtutil](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil)
