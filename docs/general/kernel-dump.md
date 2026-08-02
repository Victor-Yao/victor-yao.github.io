---
title: Capture a Windows Kernel Dump
parent: Windows & Networking
grand_parent: Guides
nav_order: 9
description: "Configure Windows to capture kernel or complete memory dumps for operating system failures."
tags: [windows, memory-dump, kernel]
last_modified_date: 2026-08-02
---

## Capturing Windows kernel dumps

This guide describes two alternative methods for capturing kernel memory dumps.
Choose one method. Do not run both.

### Environment

- **Operating system**: Windows 10 / 11 / Server 2016+
- **Tooling**: Sysinternals Suite (LiveKd, NotMyFault)
- **Dependency**: Debugging Tools for Windows (WinDbg) must be installed for LiveKd to function correctly.

### Choose a method

| Method | Use when | Impact on the machine |
| --- | --- | --- |
| [Method 1: Live kernel dump](#live-kernel-dump) | The system is still running and you need its current kernel state | None. The system keeps running |
| [Method 2: Forced crash dump](#forced-crash-dump) | The system hangs, or the analysis requires a full crash dump | The machine bugchecks (BSOD) and restarts immediately |

{: .warning }
> Method 2 deliberately crashes the machine. Do not run it after Method 1 has
> already produced a usable dump, and do not run it on a production system
> outside an agreed maintenance window.

### Method 1: Live kernel dump (non-invasive)
{: #live-kernel-dump }

{: .note }
> Independent section. Complete only these steps. Method 2 is an alternative, not a later step.

Use this method to capture the kernel state without crashing or restarting the system.

1. **Install Debugging Tools**

   Make sure the Windows SDK or WinDbg is installed so that `kd.exe` or `windbg.exe` is available in the system path.

2. **Launch elevated Command Prompt**

   Run `cmd.exe` as Administrator.

3. **Run LiveKd**

   Go to the folder containing `livekd.exe` and run one of the following commands to generate a mirror dump:

   ```cmd
   livekd -accepteula -ml -o C:\dumps\live_kernel.dmp

   livekd -accepteula -k "C:\Path\To\kd.exe" -o c:\dumps\live_kernel.dmp

   livekd -accepteula -k "C:\Path\To\kd.exe" -mp 13848 -o c:\dumps\live_kernel.dmp
   ```

4. **Verify output**

   Live capture: `C:\dumps\live_kernel.dmp`

   {: .tip }
   > For **LiveKd**, if you encounter symbol errors, set your symbol path environment variable before running the tool:
   >
   > ```cmd
   > set _NT_SYMBOL_PATH=srv*C:\Symbols*https://msdl.microsoft.com/download/symbols
   > ```

### Method 2: Forced crash dump (invasive)
{: #forced-crash-dump }

{: .note }
> Independent section. Complete only these steps. Method 1 is an alternative, not an earlier step.

Use this method if the system is hanging or if a full crash dump is required for root cause analysis.

1. **Configure crash dump settings**

   Press `Win + R`, type `sysdm.cpl`, and go to **Advanced** > **Startup and Recovery** > **Settings**. Make sure **Write debugging information** is set to **Kernel memory dump** or **Complete memory dump**.

2. **Run NotMyFault**

   Open an elevated Command Prompt, go to the `NotMyFault` directory, and run the following command to immediately trigger a system crash (BSOD):

   ```cmd
   notmyfault64.exe /crash
   ```

3. **Retrieve the dump**

   Crash capture: `C:\Windows\MEMORY.DMP`
