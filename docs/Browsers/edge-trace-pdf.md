---
title: Edge Trace (PDF)
parent: Browsers
grand_parent: Guides
nav_order: 18
last_modified_date: 2026-06-06
---

## Capturing an Edge trace for PDF troubleshooting

This guide describes how to capture low-level Chromium traces focused on PDF rendering and font-mapping logic in Microsoft Edge.

### Instructions

1. **Terminate all Edge processes**

   Open a Command Prompt and run:

   ```cmd
   taskkill /f /im msedge.exe
   ```

   {: .warning }
   > The `taskkill` command closes all active Edge windows and unsaved data is lost. Make sure all work is saved before running it.

2. **Launch Edge with diagnostic flags**

   Start Edge with the feature flags that enable the target PDF and font libraries:

   ```cmd
   msedge.exe --enable-features="msPdfSharedLibrary,msPdfEnableSkiaFontMap"
   ```

3. **Verify issue reproduction**

   Open the problematic PDF file and confirm that the rendering issue or error still occurs with the flags enabled before proceeding to the trace.

4. **Configure and start tracing**

   Go to `edge://tracing`, select **Record**, then select **Manually select settings**. Make sure the following categories are selected:

   - `pdf_plugin`
   - `fonts`
   - `dwrite`

   Select **Record** to begin the session.

   {: .tip }
   > If you can't find the specific categories in the manual list, make sure "Disabled by Default" categories are also visible, or use the "Edit" function to add the category strings manually.

5. **Capture the rendering event**

   Open or reload the target PDF file in a new tab. Wait until the document has finished attempting to render (or until the error appears).

6. **Save and export**

   Return to the `edge://tracing` tab and select **Stop**. Select **Save** to export the trace as a `.json.gz` file, then share the generated file with the technical support team.

## See also

- [Edge Histograms (PDF)](/docs/browsers/edge-histograms-pdf/)
- [Edge Tracing](/docs/browsers/edge-tracing/)
