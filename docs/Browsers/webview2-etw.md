---
title: Collect a WebView2 ETW Trace
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 24
description: "Collect a WebView2 ETW trace with the built-in Windows recorder and send it to support."
tags: [webview2, etw, diagnostics]
last_modified_date: 2026-11-20
---

## Collect the trace

[Event Tracing for Windows (ETW)](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/event-tracing-for-windows) traces capture detailed information about Windows system activity and WebView2 operations. Two WebView2 recording profiles are available:

1. [WebView2_CPU.wprp]({% link assets/Scripts/WebView2_CPU.wprp %}): **recommended for most scenarios**; includes CPU sampling.
2. [WebView2.wprp]({% link assets/Scripts/WebView2.wprp %}): for longer recordings; omits CPU sampling to reduce trace size.

The steps below use `WebView2_CPU.wprp`. To use `WebView2.wprp`, download that file instead and replace the profile filename in the start command.

1. **Close unrelated apps.** Save your work, then close Edge and other WebView2 apps, such as Teams and Office. Keep the app you are troubleshooting open.

2. **Download the recording profile.** Create the folder `C:\Temp\WebView2-ETW`. Right-click [WebView2_CPU.wprp]({% link assets/Scripts/WebView2_CPU.wprp %}), select **Save link as**, and save it in that folder. Save it as `WebView2_CPU.wprp`, not `WebView2_CPU.wprp.txt`.

3. **Start recording.** Open **Command Prompt** as an administrator and run:

   ```bat
   wpr -start "C:\Temp\WebView2-ETW\WebView2_CPU.wprp" -filemode
   ```

4. **Reproduce the issue.**

5. **Stop and save.** In the same elevated **Command Prompt** window, run:

   ```bat
   wpr -stop "C:\Temp\WebView2-ETW\trace.etl" "WebView2 issue"
   ```

6. **Verify and compress.** Wait for the command to complete successfully. Confirm that `C:\Temp\WebView2-ETW\trace.etl` exists, then compress it into a ZIP file.

Source: [Microsoft WebView2 ETW collection instructions](https://github.com/MicrosoftEdge/WebView2Feedback/blob/main/diagnostics/etw.md).
