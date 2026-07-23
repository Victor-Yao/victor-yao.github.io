---
title: Edge Histograms (PDF)
parent: Browsers
grand_parent: Guides
nav_order: 19
last_modified_date: 2026-06-06
---

## Capturing Edge histograms for PDF troubleshooting

This guide describes how to collect browser histogram data to diagnose issues related to Microsoft Information Protection (MIP) encrypted PDFs in Microsoft Edge.

### Environment

- **Browser**: Microsoft Edge (Chromium-based)
- **Target content**: Locally saved MIP-protected PDF files
- **Diagnostic URL**: `edge://histograms/`

### Instructions

1. **Access the diagnostic interface**

   Launch Edge and go to `edge://histograms/`.

2. **Initialize monitoring mode**

   Select the button labeled **Switch to Monitor Mode**.

   {: .note }
   > When it switches to Monitor Mode, the button text changes to **Switch to Histogram Mode**.

3. **Reproduce the issue**

   Open the problematic MIP-protected PDF from your **local storage**.

   {: .warning }
   > Do not open the file from SharePoint or OneDrive for this test. The file must be stored on the local disk to capture the relevant filesystem and sensitivity engine histograms.

4. **Stop data collection**

   Return to the `edge://histograms/` tab and select **Stop** to finalize the recording.

5. **Extract specific histogram categories**

   Locate the following categories by searching for the titles (use `Ctrl + F`). For each category, expand the title, copy the **entire content** (including title and data), and paste it into a single `.txt` file.

   Required categories:

   - `Microsoft.Pdf.Diagnostics`
   - `Microsoft.Pdf.FileOpenError`
   - `Microsoft.Pdf.LoadState`
   - `Microsoft.Pdf.MIP.AccessTokenReceived.SovereigntyDetected`
   - `Microsoft.Pdf.MIPLoadState`
   - All categories starting with `Microsoft.Identity.AcquireAccessToken.PdfMip`
   - All categories starting with `Microsoft.Profile.AcquireAccessToken.PdfMip`

   {: .tip }
   > When copying, make sure you include the histogram distribution values (the numerical bars/data points) beneath each header to allow for proper statistical analysis.

## See also

- [Edge Trace (PDF)](/docs/browsers/edge-trace-pdf/)
- [Edge Tracing](/docs/browsers/edge-tracing/)
