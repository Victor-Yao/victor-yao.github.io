---
title: Collect IIS Dumps with DebugDiag
parent: IIS & Web Hosting
grand_parent: Guides
nav_order: 7
description: "Configure DebugDiag rules to collect IIS crash or exception memory dumps."
tags: [iis, memory-dump, debugdiag]
last_modified_date: 2026-10-03
---
## Using DebugDiag to collect memory dump for IIS

### Prerequisites

1. Download and install [DebugDiag](https://www.microsoft.com/en-us/download/details.aspx?id=103453).

2. Run `DebugDiag.Collection.exe` as an administrator.

   ![Open DebugDiag Collection as administrator](/assets/images/debugdiag10.png)

### Choose a rule type

Both options use a DebugDiag crash rule. Choose **one** for the target application pool.

| Rule type | Capture when | Section |
| --- | --- | --- |
| Crash rule | The worker process terminates unexpectedly | [Capture a crash dump](#debugdiag-crash) |
| Exception rule | A specific exception is thrown while the process keeps running | [Capture a specific exception](#debugdiag-exception) |

### Capture a crash dump
{: #debugdiag-crash }

1. Add a crash rule using the following settings:

   1. Select **Crash**.

      ![Add Rule option in DebugDiag](/assets/images/debugdiag1.png)

   2. Select **A specific IIS web application pool**, then continue.

      ![Select Crash rule type](/assets/images/debugdiag2.png)

   3. Select the target application pool, then continue.

      ![Select the target process](/assets/images/debugdiag3.png)

   4. Configure the advanced options as shown, then continue.

      ![Configure crash rule options](/assets/images/debugdiag11.png)

   5. Choose the dump folder, leave the default rule name, then continue.

      ![Select the Userdump path](/assets/images/debugdiag7.png)

   6. Activate the rule, then finish.

      ![Activate the crash rule](/assets/images/debugdiag8.png)

2. Wait for the crash, then confirm that a dump file was created in the selected folder.

    ![Wait for the crash to occur](/assets/images/debugdiag9.png)

### Capture a specific exception
{: #debugdiag-exception }

1. Add a crash rule:

   1. Select **Add Rule...**.

      ![Add Rule option in DebugDiag](/assets/images/debugdiag1.png)

   2. Select **A specific IIS web application pool**, then continue.

      ![Select Crash rule type](/assets/images/debugdiag2.png)

   3. Select the target application pool, then continue.

      ![Select the target process](/assets/images/debugdiag3.png)

   4. Choose **Exceptions**, then continue.

      ![Choose Exceptions for crash rule](/assets/images/debugdiag4.png)

   5. Add an exception to capture, then continue.

      ![Select exception type](/assets/images/debugdiag5.png)

      ![finish exception settings](/assets/images/debugdiag6.png)

   6. Choose the dump folder, leave the default rule name, then continue.

      ![Select the Userdump path](/assets/images/debugdiag7.png)

   7. Activate the rule, then finish.

      ![Activate the rule](/assets/images/debugdiag8.png)

2. Wait for the exception, then confirm that a dump file was created in the selected folder.

    ![Activate the crash rule](/assets/images/debugdiag9.png)
