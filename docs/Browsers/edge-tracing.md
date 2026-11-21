---
title: Capture a Microsoft Edge Trace
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 8
description: "Capture low-level Microsoft Edge traces with the built-in Chromium tracing tool."
tags: [edge, tracing, chromium]
last_modified_date: 2026-11-21
---

## Capturing Microsoft Edge trace logs

This is a general Chromium trace that records **all** categories. Use it for low-level browser issues, such as plug-in errors, when no more specific guide applies.

For these issues, use the specific guide instead:

- PDF rendering or font issues: [Capture an Edge Trace for PDF Issues]({% link docs/Browsers/edge-trace-pdf.md %})
- Encrypted (MIP) PDFs: [Collect Edge Histograms for PDF Issues]({% link docs/Browsers/edge-histograms-pdf.md %})
- SmartScreen blocks: [Collect Microsoft Defender SmartScreen Diagnostics]({% link docs/Browsers/SmartScreenChecklist.md %})

### Environment

- **Browser**: Microsoft Edge
- **Internal tool**: `edge://tracing`

### Instructions

1. **Access the tracing interface**

   Launch Microsoft Edge, go to `edge://tracing`, then select **Record**.

2. **Configure capture settings**

   In the configuration overlay, select **Manually select settings**. Make sure **all** categories in the list are checked to ensure a comprehensive trace, then select the **Record** button at the bottom of the dialog.

3. **Reproduce the issue**

   A progress bar appears at the top of the screen indicating the buffer usage. Open a new tab or window and trigger the error.

4. **Stop the trace**

   Once the error is visible, immediately return to the `edge://tracing` tab and select **Stop**.

   {: .tip }
   > You don't need to wait for the buffer usage to reach 100%. Stop the trace as soon as the issue has been reproduced to keep the file size manageable.

5. **Save and export**

   Select **Save**, leave the filename as default or blank, and select **OK**. The browser downloads a file with a `.json.gz` extension.

## See also

- [Edge Trace (PDF)]({% link docs/Browsers/edge-trace-pdf.md %})
- [Edge Histograms (PDF)]({% link docs/Browsers/edge-histograms-pdf.md %})
