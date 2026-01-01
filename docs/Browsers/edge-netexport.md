---
title: Edge NetExport
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Capture netlog dump on Edge

1. Open Edge and go to `edge://net-export`.

    > Optional: Close all browser tabs except one.

2. Select **Start Logging to Disk**.

    ![net-export](/assets/images/netexport.png)

3. Choose a file name and location to save the traffic log.

4. Open a new tab and **reproduce the issue**.

    > Note, don't close the tab of `edge://net-export`.

5. After reproducing the issue, select **Stop Logging**.

For more information, see: [https://www.chromium.org/for-testers/providing-network-details/](https://www.chromium.org/for-testers/providing-network-details/)
