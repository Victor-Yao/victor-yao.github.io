---
title: Capture a Microsoft Edge Trace
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 17
description: "Capture low-level Microsoft Edge traces with the built-in Chromium tracing tool."
tags: [edge, tracing, chromium]
last_modified_date: 2026-06-06
---

## Capturing Microsoft Edge trace logs

This guide describes how to use the built-in Chromium tracing tool to diagnose low-level browser issues, such as PDF rendering failures or plug-in errors.

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

- [Edge Trace (PDF)](/docs/browsers/edge-trace-pdf/)
- [Edge Histograms (PDF)](/docs/browsers/edge-histograms-pdf/)
