---
title: Edge HAR
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Collect a network trace log from Edge DevTools

1. Open Microsoft Edge, then open **Developer tools** by pressing **F12**.

2. Select the **Network** tab. Then select **Clear cache** and enable **Disable cache**.

    ![Clear and disable cache](/assets/images/edgehar1.png)

3. Select **Record** to start recording, then **reproduce the issue**.

    ![Start recording](/assets/images/edgehar2.png)

4. After the issue is reproduced and the requests are complete, select **Record** again to stop recording. Then select **Export HAR** to save the trace.

    ![export record](/assets/images/edgehar3.png)

For more information, refer to:  
[https://learn.microsoft.com/en-us/azure/azure-portal/capture-browser-trace#microsoft-edge](https://learn.microsoft.com/en-us/azure/azure-portal/capture-browser-trace#microsoft-edge)
