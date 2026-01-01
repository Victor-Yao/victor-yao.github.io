---
title: Freb ARR
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## Debug ARR and URL Rewrite rules with FREB

### Prerequisites

Install Freb tracing feature. For details, see: [https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/tracing/)

### Collect logs

1. In **IIS Manager**, select the target website, then open **Failed Request Tracing Rules** in the **Features View**.

   ![Failed Request Tracing Rules in IIS Features View](/assets/images/Freb1.png)

2. Add a FREB rule:

   1. Select **Add...**.

      ![Add a failed request tracing rule](/assets/images/Freb2.png)

   2. Configure the rule to trace **URL Rewrite** and **ARR** events.

      ![Configure FREB rule for rewrite and ARR tracing](/assets/images/Freb8.png)

   3. Select the providers and verbosity as needed.

      ![Select FREB providers](/assets/images/Freb9.png)

   4. Finish the wizard.

      ![Finish FREB rule creation wizard](/assets/images/Freb10.png)

3. Return to the site level and enable the rule.

   ![Enable the failed request tracing rule](/assets/images/Freb5.png)

4. Reproduce the issue and collect the FREB logs.

   ![Collect failed request tracing logs](/assets/images/Freb6.png)

For an example of tracing rewrite rules with FREB, see: [https://learn.microsoft.com/en-us/iis/extensions/url-rewrite-module/using-failed-request-tracing-to-trace-rewrite-rules](https://learn.microsoft.com/en-us/iis/extensions/url-rewrite-module/using-failed-request-tracing-to-trace-rewrite-rules)
