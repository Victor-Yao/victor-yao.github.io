---
title: SmartScreen Checklist
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## SmartScreen checklist for Edge

### Enable the SmartScreen debug log

1. Open Event Viewer, then go to `Applications and Services Logs > Microsoft > Windows > SmartScreen > Debug`.

2. Select **Enable Log**.

   ![Event Viewer SmartScreen Debug log with Enable Log option](/assets/images/smartscreen1.png)

### Enable Edge tracing

1. Open Edge and go to `edge://tracing`.

2. Select **Reload**, then choose **Manually select settings**.

   ![Edge tracing page showing Reload and Manually select settings](/assets/images/smartscreen2.png)

3. Under Record Categories, select **SmartScreen** only, then select **Record**.

   ![Edge tracing settings with only SmartScreen selected](/assets/images/smartscreen3.png)

### Collect logs

1. **Reproduce the issue** after enabling the *SmartScreen debug log* and *Edge tracing*.

2. Stop and save the Edge tracing.

   ![Stop and save the Edge trace](/assets/images/smartscreen4.png)

3. Verify if any records in the SmartScreen debug log, the select **Save All Events As...**.

   ![Save SmartScreen debug log events](/assets/images/smartscreen5.png)

4. Go to *Windows Security > Protection history*, expand any relevant entries about blocked content.

   ![Protection history](/assets/images/smartscreen6.png)
