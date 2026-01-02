---
title: memory dump with procdump
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---

## Using procdump to collect memory dump of w3wp.exe

### Prerequisites

Download [Procdump](https://download.sysinternals.com/files/Procdump.zip). For more information, see [https://learn.microsoft.com/en-us/sysinternals/downloads/procdump](https://learn.microsoft.com/en-us/sysinternals/downloads/procdump#examples)

### Find the PID of the target w3wp.exe process

* **Option 1: IIS Manager**

   ![Find the worker process PID in IIS Manager](/assets/images/iisprocdump1.png)

   ![Worker process details showing PID](/assets/images/iisprocdump2.png)

* **Option 2: Task Manager**

   ![Find the PID in Task Manager](/assets/images/iisprocdump3.png)

### Capture a single dump

1. Open Command Prompt as an administrator, then go to the Procdump folder.

2. Replace `<pid>` with **the PID of the target process**, then run:

   ```bat
   procdump -ma -accepteula <pid>
   ```

### Capture multiple dumps at a fixed interval

1. Open Command Prompt as an administrator, then go to the Procdump folder.

2. Replace `<pid>` with **the PID of the target process**, then run:

   ```bat
   procdump -ma -accepteula -s 10 -n 3 <pid>
   ```

### Capture an exception memory dump

1. Open **Command Prompt** as an administrator, then go to the Procdump folder.

2. Replace `<keywords>` with **exception message**, then run:

   ```bat
   procdump -ma -n 1 -e 1 -f <keywords> w3wp.exe
   ```

   > Tip: If you want to capture other process, replace `w3wp.exe` with the target process name, (for example, `dotnet.exe`).

### Capture a crash dump

1. Open **Command Prompt** as an administrator, then go to the Procdump folder.

2. Run the following command, then wait for the crash to occur:

   ```bat
   procdump -accepteula -e -ma -w w3wp.exe
   ```

   ![ProcDump waiting for a crash on w3wp.exe](/assets/images/iisprocdump4.png)
