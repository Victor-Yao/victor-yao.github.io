---
title: Collect Edge and Chrome Hang Dumps
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 13
description: "Capture full memory dumps of a hung Microsoft Edge or Google Chrome with ProcDump and a collection script."
tags: [edge, chrome, hang, memory-dump, procdump]
last_modified_date: 2026-11-20
---

## Collect the dumps

Use this guide when the browser shows **Not Responding** and does not recover. The [Collect-BrowserHangDump.ps1]({% link assets/Scripts/Collect-BrowserHangDump.ps1 %}) script uses ProcDump to capture several full dumps of the browser process and the GPU process.

{: .important }
> Capture the dumps **while the browser is hung**. Do not close the browser until the script finishes.

### Prepare before the issue happens

1. Create the `C:\Dumps` folder.
2. Download [ProcDump](https://learn.microsoft.com/sysinternals/downloads/procdump), then extract `procdump64.exe` into `C:\Dumps`.
3. Download [Collect-BrowserHangDump.ps1]({% link assets/Scripts/Collect-BrowserHangDump.ps1 %}) into `C:\Dumps`.

   ```text
   C:\Dumps
   ├── procdump64.exe
   └── Collect-BrowserHangDump.ps1
   ```

4. Make sure drive C: has at least 10 GB of free space.

### Capture when the issue happens

1. Keep the hung browser open. Do not select **Close the program** or **End task**.
2. Open **PowerShell** as an administrator, then run:

   ```powershell
   cd C:\Dumps
   powershell.exe -ExecutionPolicy Bypass -File .\Collect-BrowserHangDump.ps1
   ```

   For Google Chrome, add `-Browser Chrome`.

3. Wait until the script prints the following message, usually after 10–30 seconds:

   ```text
   Done. You can now close the browser (End task if needed).
   Please compress and upload the whole folder: C:\Dumps\EdgeHang_<timestamp>
   ```

4. Close the browser. If needed, use **Task Manager > End task**.
5. Compress the whole `C:\Dumps\EdgeHang_<timestamp>` folder into a ZIP file, then upload it with the time of the issue and what you were doing, such as the website and action.

{: .note }
> Dump files contain browser memory, which can include web page content. Handle them according to your organization's data policy.

## Optional parameters

| Parameter | Default | Description |
|---|---|---|
| `-Browser` | `Edge` | `Edge` or `Chrome` |
| `-ProcDumpPath` | `C:\Dumps\procdump64.exe` | Path to ProcDump |
| `-OutputRoot` | `C:\Dumps` | Output root folder |
| `-DumpCount` | `3` | Dumps per process |
| `-IntervalSeconds` | `5` | Seconds between dumps |
| `-ExePathFilter` | *(empty)* | Target one channel only, for example `Edge\Application` for Stable |
| `-SkipGpu` | *(off)* | Do not dump the GPU process |

## Troubleshooting

| Error | Solution |
|---|---|
| The script is not digitally signed or cannot be loaded | Use `-ExecutionPolicy Bypass` as shown above, or run `Unblock-File .\Collect-BrowserHangDump.ps1`. If Group Policy blocks it, contact your IT team. |
| `ProcDump not found` | Put `procdump64.exe` in `C:\Dumps`, or use `-ProcDumpPath`. |
| `No msedge.exe process found` | The browser was already closed. Run the script while the browser is hung. |
| `Browser process not found` | Run PowerShell as an administrator. |
| `Found N browser processes` | More than one Edge channel is running. Use `-ExePathFilter`. |

## Use Task Manager instead

Use this method only if the script or ProcDump cannot run.

1. Open **Task Manager > Details** while the browser is hung.
2. Right-click a column header, select **Select columns**, then enable **Command line**.
3. Right-click the `msedge.exe` whose command line does not contain `--type=`, then select **Create memory dump file**. Repeat 2–3 times a few seconds apart.
4. Repeat step 3 for the `msedge.exe` whose command line contains `--type=gpu-process`.
5. Upload the dump files from the path shown in the dialog, usually `%LOCALAPPDATA%\Temp`.
