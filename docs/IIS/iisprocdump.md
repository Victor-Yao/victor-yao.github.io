---
title: Collect IIS Dumps with ProcDump
parent: IIS & Web Hosting
grand_parent: Guides
nav_order: 3
description: "Use ProcDump to collect crash, hang, or exception dumps from an IIS worker process."
tags: [iis, memory-dump, procdump]
last_modified_date: 2026-02-05
---

## Using procdump to collect memory dump of w3wp.exe

### Prerequisites

1. Download [Procdump](https://download.sysinternals.com/files/Procdump.zip). For more information, see [https://learn.microsoft.com/en-us/sysinternals/downloads/procdump](https://learn.microsoft.com/en-us/sysinternals/downloads/procdump#examples)

2. Open Command Prompt as an administrator, then go to the **Procdump** folder.

### Capture a single dump

1. [Prerequisites](#prerequisites)

2. [Find out the PID of the target w3wp.exe process](#appendix-1-how-to-find-the-pid-of-the-target-w3wpexe-process)

3. Replace `<pid>` with **the PID of the target process**, then run

   ```bat
   procdump -ma -accepteula <pid>
   ```

### Capture multiple dumps at a fixed interval

1. [Prerequisites](#prerequisites)

2. [Find out the PID of the target w3wp.exe process](#appendix-1-how-to-find-the-pid-of-the-target-w3wpexe-process)

3. Replace `<pid>` with **the PID of the target process**, then run

   ```bat
   procdump -ma -accepteula -s 10 -n 3 <pid>
   ```

### Capture an exception memory dump

1. [Prerequisites](#prerequisites)

2. Replace `<keywords>` with **exception message**, then run:

   ```bat
   procdump -ma -n 1 -e 1 -f <keywords> w3wp.exe
   ```

   {: .tip }
   > If you want to capture other process, replace `w3wp.exe` with the target process name, (for example, `dotnet.exe`).

### Capture a crash dump

1. [Prerequisites](#prerequisites)

2. Run the following command, then wait for the crash to occur:

   ```bat
   procdump -accepteula -e -ma -w w3wp.exe
   ```

   ![ProcDump waiting for a crash on w3wp.exe](/assets/images/iisprocdump4.png)


#### Appendix 1. How to find the PID of the target w3wp.exe process

- Option 1: IIS Manager
   ![Find the worker process PID in IIS Manager](/assets/images/iisprocdump1.png)
   ![Worker process details showing PID](/assets/images/iisprocdump2.png)
- Option 2: Task Manager
   ![Find the PID in Task Manager](/assets/images/iisprocdump3.png)
 