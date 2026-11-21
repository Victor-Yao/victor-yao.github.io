---
title: Capture an Edge Trace for PDF Issues
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 18
description: "Capture a focused Chromium trace for PDF rendering and font-mapping issues in Edge."
tags: [edge, pdf, tracing]
last_modified_date: 2026-11-21
---

## Capturing an Edge trace for PDF troubleshooting

Use this guide for PDF rendering and font-mapping issues. Unlike the general [Microsoft Edge trace]({% link docs/Browsers/edge-tracing.md %}), it starts Edge with PDF feature flags and records only the PDF and font categories. For encrypted (MIP) PDFs, use [Collect Edge Histograms for PDF Issues]({% link docs/Browsers/edge-histograms-pdf.md %}) instead.

### Instructions

1. **Terminate all Edge processes**

   Open a **Command Prompt** and run:

   ```bat
   taskkill /f /im msedge.exe
   ```

   {: .warning }
   > The `taskkill` command closes all active Edge windows and unsaved data is lost. Make sure all work is saved before running it.

2. **Launch Edge with diagnostic flags**

   Start Edge with the feature flags that enable the target PDF and font libraries:

   ```bat
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
   > If a category is missing, show **Disabled by Default** categories or use **Edit** to add its name.

5. **Capture the rendering event**

   Open or reload the target PDF file in a new tab. Wait until the document has finished attempting to render (or until the error appears).

6. **Save and export**

   Return to the `edge://tracing` tab and select **Stop**. Select **Save** to export the trace as a `.json.gz` file, then share the generated file with the technical support team.

## See also

- [Edge Histograms (PDF)]({% link docs/Browsers/edge-histograms-pdf.md %})
- [Edge Tracing]({% link docs/Browsers/edge-tracing.md %})
