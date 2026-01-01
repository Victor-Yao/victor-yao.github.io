---
title: Freb
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## Enable failed request tracing rule for a specific HTTP status code

### Prerequisites

Install Freb tracing feature. For details, see: [https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/)

### Collect logs

1. Open **IIS Manager**, select the target website, then open **Failed Request Tracing Rules** in the **Features View**.

   ![Open Freb](/assets/images/Freb1.png)

2. Add a rule and configure the status code:

   1. Select **Add...**.

      ![Add a failed request tracing rule](/assets/images/Freb2.png)

   2. Enter the HTTP status code (or a range) to capture. For example, `500`.

      ![Enter the status code to trace](/assets/images/Freb7.png)

   3. Complete the remaining wizard steps, then finish the rule creation.

      ![Finish the rule configuration wizard](/assets/images/Freb4.png)

3. Return to the site level and enable the rule.

   ![Enable the failed request tracing rule](/assets/images/Freb5.png)

4. Reproduce the issue and collect the FREB logs.

   ![Collect failed request tracing logs](/assets/images/Freb6.png)
